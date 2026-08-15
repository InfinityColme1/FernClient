import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:http/http.dart' as http;

/// La API de Pinterest, con lo justo para traerse lo que el usuario ha guardado
/// en su cuenta.
///
/// Pinterest tiene una API oficial, pero exige registrar una aplicación y pasar
/// por su aprobación, así que aquí se usa la misma con la que se pinta su web
/// (la que responde bajo `/resource`). Para entrar en ella no hace falta la
/// cuenta: lo que un usuario guarda en tableros públicos se puede pedir sólo
/// con su nombre, que es el caso normal.
///
/// Lo que sí hace falta es parecer su web. La petición se rechaza sin más
/// explicación ("Invalid Resource Request") si no lleva las cabeceras con las
/// que su propia página se identifica, incluidas dos que dicen qué pantalla se
/// supone que la está pidiendo. Con ellas contesta; sin ellas, ni con una
/// sesión válida.
///
/// La sesión ([PinterestSettingsEntity.sessionId]) sólo hace falta para lo que
/// el usuario tenga en tableros secretos, y por eso es opcional: se recoge del
/// navegador de la aplicación como la de cualquier otra plataforma.
class PinterestApiClient {
  final http.Client _client;

  PinterestApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Lo que el usuario tiene guardado, de lo más reciente a lo más antiguo.
  ///
  /// [stopAt] es el pin en el que se quedó la importación anterior: cuando se
  /// vuelve a encontrar, se para. Vacío para traerse todo.
  Stream<RemoteMediaItem> savedMedia(
    PinterestSettingsEntity credentials, {
    String? stopAt,
  }) async* {
    final username = credentials.username.trim();
    if (username.isEmpty) {
      throw Exception('There is no Pinterest account to ask for');
    }

    // Por dónde va el recorrido. Pinterest no pagina por número sino con una
    // marca que devuelve en cada respuesta y que hay que devolverle en la
    // siguiente.
    String? bookmark;

    for (var page = 0; page < pinterestMaxPages; page++) {
      final body = await _get(credentials, username: username, bookmark: bookmark);

      final pins = (body['resource_response']
              as Map<String, dynamic>?)?['data'] as List<dynamic>? ??
          const [];
      if (pins.isEmpty) return;

      for (final entry in pins) {
        if (entry is! Map<String, dynamic>) continue;

        final id = entry['id'] as String?;
        if (id == null || id.isEmpty) continue;

        // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
        if (id == stopAt) return;

        final item = _mediaOf(entry, id: id);
        if (item != null) yield item;
      }

      bookmark = _bookmarkOf(body);

      // Sin marca nueva, o con la que dice que ya no queda nada, se acabó.
      if (bookmark == null || bookmark == pinterestEndBookmark) return;
    }
  }

  /// El fichero que sale de un pin, o `null` si de ése no sale ninguno.
  ///
  /// Un pin es una imagen o un vídeo. Los que no son ni una cosa ni otra (los
  /// que sólo llevan a otra página, o los que Pinterest arma con varios bloques)
  /// se quedan fuera: no hay un fichero que descargar.
  RemoteMediaItem? _mediaOf(Map<String, dynamic> pin, {required String id}) {
    final url = _videoUrl(pin) ?? _imageUrl(pin);
    if (url == null) return null;

    // Los pines no tienen título, pero sí un texto que el usuario reconoce.
    final title = (pin['grid_title'] as String?)?.trim().isNotEmpty == true
        ? pin['grid_title'] as String
        : (pin['description'] as String? ?? '').trim();

    return RemoteMediaItem(
      id: 'pinterest_$id',
      url: url,
      title: title,
      postId: id,
      sourceUrls: _sourceUrls(pin, id: id),
    );
  }

  /// La imagen del pin a su tamaño original.
  String? _imageUrl(Map<String, dynamic> pin) {
    final images = pin['images'] as Map<String, dynamic>?;
    final original = images?['orig'] as Map<String, dynamic>?;
    final url = original?['url'] as String?;

    return url == null || url.isEmpty ? null : url;
  }

  /// El vídeo del pin, en la mejor calidad que dé Pinterest.
  ///
  /// Los reparte por formatos, y no todos son un fichero que se pueda guardar:
  /// los hay que son una lista de trozos para ir reproduciendo. Aquí sólo vale
  /// lo que sea un fichero de vídeo entero.
  String? _videoUrl(Map<String, dynamic> pin) {
    final videos = pin['videos'] as Map<String, dynamic>?;
    final list = videos?['video_list'] as Map<String, dynamic>?;
    if (list == null) return null;

    String? best;
    var bestWidth = 0;

    for (final entry in list.values) {
      if (entry is! Map<String, dynamic>) continue;

      final url = entry['url'] as String?;
      if (url == null || !url.endsWith('.mp4')) continue;

      final width = (entry['width'] as num?)?.toInt() ?? 0;
      if (best == null || width > bestWidth) {
        best = url;
        bestWidth = width;
      }
    }

    return best;
  }

  /// De dónde sale el pin, en direcciones que el usuario reconoce y puede haber
  /// vinculado con una etiqueta.
  ///
  /// De lo más general a lo más concreto: el tablero en el que lo guardó, la
  /// página de la que salió (que es de otra plataforma, y puede estar vinculada
  /// igual que si se hubiera importado de ella) y el propio pin.
  List<String> _sourceUrls(Map<String, dynamic> pin, {required String id}) {
    final board = pin['board'] as Map<String, dynamic>?;
    final boardUrl = board?['url'] as String? ?? '';
    final link = pin['link'] as String? ?? '';

    return [
      if (boardUrl.isNotEmpty) '$pinterestSiteUrl$boardUrl',
      if (link.startsWith('https://')) link,
      '$pinterestSiteUrl/pin/$id/',
    ];
  }

  /// La marca con la que se pide la página siguiente.
  String? _bookmarkOf(Map<String, dynamic> body) {
    final resource = body['resource'] as Map<String, dynamic>?;
    final options = resource?['options'] as Map<String, dynamic>?;
    final bookmarks = options?['bookmarks'] as List<dynamic>?;

    if (bookmarks == null || bookmarks.isEmpty) return null;

    final first = bookmarks.first;

    return first is String && first.isNotEmpty ? first : null;
  }

  /// Pide una página de lo guardado y devuelve la respuesta entera.
  Future<Map<String, dynamic>> _get(
    PinterestSettingsEntity credentials, {
    required String username,
    String? bookmark,
  }) async {
    final options = <String, dynamic>{
      // Con sesión se piden también los tableros secretos, que es lo único que
      // no se ve desde fuera.
      'is_own_profile_pins': credentials.hasSession,
      'username': username,
      'field_set_key': 'grid_item',
      'pin_filter': null,
      if (bookmark != null) 'bookmarks': [bookmark],
    };

    final source = '/$username/_saved/';

    final uri = Uri.https(pinterestApiHost, pinterestResourcePath, {
      'source_url': source,
      'data': jsonEncode({'options': options, 'context': <String, dynamic>{}}),
    });

    final response = await _client
        .get(uri, headers: _headers(credentials, source: source))
        .timeout(remoteRequestTimeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const RemoteSessionExpiredException(ImportSource.pinterest);
    }

    if (response.statusCode != 200) {
      throw Exception('Pinterest refused the saved pins '
          '(${response.statusCode})');
    }

    try {
      final body = jsonDecode(response.body);

      return body is Map<String, dynamic> ? body : <String, dynamic>{};
    } on FormatException {
      throw Exception('Pinterest did not answer with what it should');
    }
  }

  /// Las cabeceras con las que Pinterest atiende.
  ///
  /// Además de decir que es su web quien pide, van dos que dicen qué pantalla
  /// suya se supone que lo está haciendo ([pinterestPwsHandler] y la dirección
  /// de origen): sin ellas la petición se rechaza aunque todo lo demás esté
  /// bien.
  ///
  /// La protección contra peticiones de terceros se cumple mandando el mismo
  /// valor en la galleta y en la cabecera, que es lo que ella comprueba; no
  /// hace falta que venga de ninguna parte.
  Map<String, String> _headers(
    PinterestSettingsEntity credentials, {
    required String source,
  }) {
    final session = credentials.sessionId.trim();

    return {
      'User-Agent': browserUserAgent,
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-APP-VERSION': pinterestAppVersion,
      'X-Pinterest-AppState': 'active',
      'X-Pinterest-PWS-Handler': pinterestPwsHandler,
      'X-Pinterest-Source-Url': source,
      'X-CSRFToken': pinterestCsrfToken,
      'Referer': '$pinterestSiteUrl$source',
      'Cookie': [
        'csrftoken=$pinterestCsrfToken',
        if (session.isNotEmpty) '$pinterestSessionCookieName=$session',
      ].join('; '),
    };
  }

  void close() => _client.close();
}
