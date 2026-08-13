import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:http/http.dart' as http;

/// Un fichero que hay que descargarse de una fuente remota.
///
/// Una publicación puede dar varios (una galería son varias imágenes), y cada
/// uno acaba siendo un contenido de la aplicación por su cuenta: [id] es único
/// dentro de la fuente y es lo que se usa para nombrar el fichero.
class RemoteMediaItem {
  /// Identificador dentro de la fuente, ya apto para nombrar un fichero.
  final String id;

  /// De dónde se descarga el fichero.
  final String url;

  /// Título de la publicación, que es lo que se guarda como descripción.
  final String title;

  /// Identificador de la publicación de la que sale.
  ///
  /// Varios ficheros de una misma galería lo comparten. Es la marca con la que
  /// se reconoce por dónde se quedó la importación anterior, así que tiene que
  /// ser el de la publicación y no el del fichero.
  final String postId;

  const RemoteMediaItem({
    required this.id,
    required this.url,
    required this.title,
    required this.postId,
  });
}

/// La API de Reddit, con lo justo para traerse lo que el usuario ha guardado en
/// su cuenta.
///
/// Se habla con ella directamente en lugar de con un envoltorio: los que hay
/// para Dart arrastran versiones antiguas de las librerías que ya usa la
/// aplicación, y de toda la API aquí sólo hacen falta dos llamadas.
///
/// El permiso de acceso se pide con el usuario y la contraseña (el flujo que
/// Reddit reserva a las aplicaciones de tipo *script*, que es justo lo que
/// hace el usuario al registrar la suya) y se guarda en memoria mientras dure.
class RedditApiClient {
  final http.Client _client;

  String? _accessToken;
  DateTime? _expiresAt;
  RedditSettingsEntity? _credentials;

  RedditApiClient({http.Client? client}) : _client = client ?? http.Client();

  String _userAgent(String username) =>
      remoteUserAgent.replaceFirst('%s', username);

  /// Permiso de acceso vigente, pidiéndolo si hace falta.
  ///
  /// Se vuelve a pedir cuando caduca y también cuando cambian las credenciales:
  /// el usuario puede haberlas corregido en los ajustes entre dos
  /// importaciones.
  Future<String> _token(RedditSettingsEntity credentials) async {
    final token = _accessToken;
    final expiresAt = _expiresAt;

    if (token != null &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now()) &&
        _credentials == credentials) {
      return token;
    }

    final basic = base64Encode(
      utf8.encode('${credentials.clientId}:${credentials.clientSecret}'),
    );

    final response = await _client
        .post(
          Uri.parse(redditTokenUrl),
          headers: {
            'Authorization': 'Basic $basic',
            'User-Agent': _userAgent(credentials.username),
          },
          body: {
            'grant_type': 'password',
            'username': credentials.username,
            'password': credentials.password,
          },
        )
        .timeout(remoteRequestTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Reddit rejected the credentials (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = body['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('Reddit did not return an access token');
    }

    _accessToken = accessToken;
    _credentials = credentials;
    // Un minuto de margen: un permiso a punto de caducar no llega a usarse.
    _expiresAt = DateTime.now().add(
      Duration(seconds: (body['expires_in'] as int? ?? 3600) - 60),
    );

    return accessToken;
  }

  /// El contenido multimedia de todo lo que el usuario tiene guardado en su
  /// cuenta, de lo más reciente a lo más antiguo.
  ///
  /// Se recorre el listado por páginas hasta que Reddit deja de dar más (o
  /// hasta [redditMaxPages], que es donde su histórico se acaba de todas
  /// formas). Lo guardado que no lleva a ningún contenido (un comentario, una
  /// publicación de texto) no aparece.
  Stream<RemoteMediaItem> savedMedia(RedditSettingsEntity credentials) async* {
    final token = await _token(credentials);
    final headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': _userAgent(credentials.username),
    };

    String? after;

    for (var page = 0; page < redditMaxPages; page++) {
      final uri = Uri.https(
        redditApiHost,
        '/user/${credentials.username}/saved',
        {
          'limit': '$redditPageSize',
          'raw_json': '1',
          if (after != null) 'after': after,
        },
      );

      final response =
          await _client.get(uri, headers: headers).timeout(remoteRequestTimeout);
      if (response.statusCode != 200) {
        throw Exception(
          'Reddit refused the saved listing (${response.statusCode})',
        );
      }

      final listing =
          (jsonDecode(response.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>?;
      final children = listing?['children'] as List<dynamic>? ?? const [];

      for (final child in children) {
        final entry = child as Map<String, dynamic>;
        // Sólo las publicaciones llevan contenido: un comentario guardado
        // (`t1`) no tiene nada que descargar.
        if (entry['kind'] != 't3') continue;

        yield* Stream.fromIterable(
          _mediaOf(entry['data'] as Map<String, dynamic>),
        );
      }

      after = listing?['after'] as String?;
      if (after == null || children.isEmpty) return;
    }
  }

  /// Los ficheros que salen de una publicación.
  ///
  /// Una galería da uno por imagen y el resto de casos, uno solo. Sale tanto lo
  /// que aloja Reddit (imágenes, gifs y vídeos) como el enlace a otro sitio: si
  /// ese enlace lleva a un fichero descargable lo dirá el resolvedor, que es
  /// quien conoce los sitios a los que se puede ir.
  List<RemoteMediaItem> _mediaOf(Map<String, dynamic> post) {
    final id = post['id'] as String? ?? '';
    final subreddit = post['subreddit'] as String? ?? 'reddit';
    final title = post['title'] as String? ?? '';
    final name = _fileSafe('${subreddit}_$id');

    final gallery = _galleryUrls(post);
    if (gallery.isNotEmpty) {
      return [
        for (var i = 0; i < gallery.length; i++)
          RemoteMediaItem(
            id: '${name}_$i',
            url: gallery[i],
            title: title,
            postId: id,
          ),
      ];
    }

    final url = _singleUrl(post);
    if (url == null) return const [];

    return [RemoteMediaItem(id: name, url: url, title: title, postId: id)];
  }

  /// Las imágenes de una galería, en el orden en el que las puso quien publicó.
  List<String> _galleryUrls(Map<String, dynamic> post) {
    if (post['is_gallery'] != true) return const [];

    final metadata = post['media_metadata'] as Map<String, dynamic>?;
    if (metadata == null) return const [];

    // El orden está en `gallery_data`; el contenido de cada imagen, en
    // `media_metadata`. Sin lo primero se recorre lo segundo tal cual.
    final items = (post['gallery_data'] as Map<String, dynamic>?)?['items']
        as List<dynamic>?;
    final Iterable<String?> keys = items == null
        ? metadata.keys
        : [
            for (final item in items)
              (item as Map<String, dynamic>)['media_id'] as String?,
          ];

    final urls = <String>[];
    for (final key in keys) {
      final entry = metadata[key] as Map<String, dynamic>?;
      if (entry == null || entry['status'] != 'valid') continue;

      final source = entry['s'] as Map<String, dynamic>?;
      if (source == null) continue;

      // Una imagen animada trae también su versión en vídeo, que pesa mucho
      // menos que el gif original.
      final url = (source['mp4'] ?? source['u'] ?? source['gif']) as String?;
      if (url != null) urls.add(url);
    }

    return urls;
  }

  /// De dónde se descarga una publicación que no es una galería.
  ///
  /// Puede ser el fichero directamente (lo que aloja Reddit) o el enlace a otro
  /// sitio: de ese se encarga el resolvedor al descargar, que es quien sabe a
  /// qué sitios se puede ir a buscar el vídeo. Aquí sólo se descarta lo que
  /// desde luego no lleva a ninguna parte, como una publicación de texto.
  String? _singleUrl(Map<String, dynamic> post) {
    final video = _videoUrl(post['media']) ??
        _videoUrl(post['secure_media']) ??
        _fallbackUrl(
          (post['preview'] as Map<String, dynamic>?)?['reddit_video_preview'],
        );
    if (video != null) return video;

    if (post['is_self'] == true) return null;

    final url = (post['url_overridden_by_dest'] ?? post['url']) as String?;
    if (url == null || !url.startsWith('https')) return null;

    return url;
  }

  String? _videoUrl(Object? media) {
    if (media is! Map<String, dynamic>) return null;
    return _fallbackUrl(media['reddit_video']);
  }

  String? _fallbackUrl(Object? video) {
    if (video is! Map<String, dynamic>) return null;
    return video['fallback_url'] as String?;
  }

  /// Deja el texto en algo que sirva como nombre de fichero en cualquier
  /// sistema.
  String _fileSafe(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  void close() => _client.close();
}
