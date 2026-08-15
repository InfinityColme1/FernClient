import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:http/http.dart' as http;

/// La API de Danbooru, con lo justo para traerse lo que el usuario tiene en
/// favoritos.
///
/// A diferencia de Reddit y de Pixiv, aquí la API es pública y está pensada
/// para esto: son las mismas direcciones que se ven en el navegador con `.json`
/// detrás, y se entra con el nombre de la cuenta y una clave que el usuario
/// saca de su perfil (no su contraseña, y puede revocarla cuando quiera).
///
/// Los favoritos se piden como una búsqueda de publicaciones con la etiqueta
/// especial `ordfav:`, que es la única forma de que lleguen **en el orden en el
/// que se marcaron**, de lo más reciente a lo más antiguo. Eso es justo lo que
/// hace falta para poder traerse sólo lo de después de la última importación:
/// pedir el listado de favoritos a secas los da ordenados por publicación, que
/// no dice nada de cuándo los marcó el usuario.
class DanbooruApiClient {
  final http.Client _client;

  /// Lo que se espera entre página y página. Se puede quitar en las pruebas,
  /// que no tienen a quién no molestar.
  final Duration pageDelay;

  DanbooruApiClient({http.Client? client, this.pageDelay = danbooruPageDelay})
      : _client = client ?? http.Client();

  /// Con qué se identifica quien pide: la cuenta y su clave, como en cualquier
  /// autenticación básica.
  Map<String, String> _headers(DanbooruSettingsEntity credentials) {
    final secret = base64Encode(
      utf8.encode('${credentials.username.trim()}:${credentials.apiKey.trim()}'),
    );

    return {
      'Authorization': 'Basic $secret',
      'User-Agent': remoteUserAgent.replaceFirst('%s', credentials.username),
      'Accept': 'application/json',
    };
  }

  /// Lo que el usuario tiene en favoritos, de lo más reciente a lo más antiguo.
  ///
  /// [stopAt] es la publicación en la que se quedó la importación anterior:
  /// cuando se vuelve a encontrar, se para. Vacío para traerse todo.
  Stream<RemoteMediaItem> favoriteMedia(
    DanbooruSettingsEntity credentials, {
    String? stopAt,
  }) async* {
    final headers = _headers(credentials);
    final username = credentials.username.trim();

    for (var page = 1; page <= danbooruMaxPages; page++) {
      // Las páginas van de uno en uno y no por desplazamiento: es lo que
      // entiende su listado de publicaciones.
      if (page > 1) await Future<void>.delayed(pageDelay);

      final uri = Uri.https(danbooruApiHost, '/posts.json', {
        'tags': 'ordfav:$username',
        'limit': '$danbooruPageSize',
        'page': '$page',
      });

      final posts = await _get(uri, headers: headers);
      if (posts.isEmpty) return;

      for (final entry in posts) {
        if (entry is! Map<String, dynamic>) continue;

        final id = (entry['id'] as num?)?.toInt();
        if (id == null) continue;

        // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
        if ('$id' == stopAt) return;

        final item = _mediaOf(entry, id: id);
        if (item != null) yield item;
      }

      // El listado se ha acabado si esta página no venía llena.
      if (posts.length < danbooruPageSize) return;
    }
  }

  /// El fichero que sale de una publicación, o `null` si de ésta no sale
  /// ninguno.
  ///
  /// Una publicación de Danbooru es siempre un fichero, así que no hay galerías
  /// que repartir. Lo que sí hay es publicaciones sin fichero que dar: las
  /// borradas y las que sólo ven las cuentas de pago siguen saliendo en el
  /// listado, pero sin dirección detrás.
  ///
  /// Las animaciones que Danbooru guarda como un paquete de fotogramas (un
  /// `zip`) se cogen de su versión convertida a vídeo, que es la que sirve para
  /// verlas.
  RemoteMediaItem? _mediaOf(Map<String, dynamic> post, {required int id}) {
    final isZip = post['file_ext'] == 'zip';
    final url = (isZip ? post['large_file_url'] : post['file_url']) as String?;
    if (url == null || url.isEmpty) return null;

    return RemoteMediaItem(
      id: 'danbooru_$id',
      url: url,
      title: '',
      postId: '$id',
      sourceUrls: _sourceUrls(post, id: id),
    );
  }

  /// De dónde sale la publicación, en direcciones que el usuario reconoce y
  /// puede haber vinculado con una etiqueta.
  ///
  /// De lo más general a lo más concreto: el listado del autor dentro de
  /// Danbooru, de dónde salió originalmente (que suele ser la publicación en
  /// otra plataforma, y puede estar vinculada igual que si se hubiera importado
  /// de ella) y la propia publicación.
  List<String> _sourceUrls(Map<String, dynamic> post, {required int id}) {
    final artists = (post['tag_string_artist'] as String? ?? '')
        .split(' ')
        .where((tag) => tag.isNotEmpty);

    final source = post['source'] as String? ?? '';

    return [
      for (final artist in artists) '$danbooruSiteUrl/posts?tags=$artist',
      if (source.startsWith('https://')) source,
      '$danbooruSiteUrl/posts/$id',
    ];
  }

  /// Pide un listado a la API y devuelve lo que traiga.
  ///
  /// Danbooru contesta con la lista pelada, sin envoltura, así que lo único que
  /// hay que mirar es el código de la respuesta. Un fallo de credenciales llega
  /// como código de error y significa que no hay nada que importar hasta que el
  /// usuario los corrija.
  Future<List<dynamic>> _get(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    final response =
        await _client.get(uri, headers: headers).timeout(remoteRequestTimeout);

    // Que no acepte las credenciales se cuenta aparte: no es que algo haya
    // ido mal, es que el usuario tiene que revisarlas, y eso hay que poder
    // decírselo.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const RemoteSessionExpiredException(ImportSource.danbooru);
    }

    if (response.statusCode != 200) {
      throw Exception('Danbooru refused the favorites (${response.statusCode})');
    }

    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Danbooru did not answer with what it should');
    }

    // Cuando la búsqueda no vale, Danbooru contesta con un objeto que lo
    // explica en lugar de con la lista de siempre.
    if (body is Map<String, dynamic>) {
      final message = body['message'] as String? ?? '';
      throw Exception(
        'Danbooru refused the favorites${message.isEmpty ? '' : ': $message'}',
      );
    }

    return body is List ? body : const [];
  }

  void close() => _client.close();
}
