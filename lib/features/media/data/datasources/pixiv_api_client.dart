import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/pixiv_settings_entity.dart';
import 'package:http/http.dart' as http;

/// La API de Pixiv, con lo justo para traerse lo que el usuario ha marcado en
/// su cuenta.
///
/// Pixiv no tiene una API pública: la que se usa aquí es la misma con la que su
/// web se pinta a sí misma (la que responde bajo `/ajax`), y se entra en ella
/// igual que entra la web, con la cookie de sesión del usuario. Por eso las
/// peticiones se identifican como un navegador y dicen venir de su sitio: una
/// que no lo haga no recibe respuesta.
///
/// Se habla con ella directamente y no con un envoltorio por lo mismo que con
/// Reddit: los que hay para Dart llevan años sin tocarse y arrastran versiones
/// antiguas de las librerías que ya usa la aplicación.
class PixivApiClient {
  final http.Client _client;

  PixivApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Las cabeceras con las que Pixiv atiende: la sesión del usuario, un
  /// navegador y la página desde la que se supone que se pide.
  Map<String, String> _headers(
    PixivSettingsEntity credentials, {
    required String referer,
  }) {
    return {
      'Cookie': '$pixivSessionCookieName=${credentials.sessionId.trim()}',
      'User-Agent': pixivUserAgent,
      'Referer': referer,
      'Accept': 'application/json',
    };
  }

  /// Cabeceras con las que se descarga una imagen de Pixiv.
  ///
  /// Su servidor de contenidos sólo la da si la petición dice venir de su web;
  /// sin esto responde que no hay permiso por mucho que la dirección sea buena.
  /// Viajan con cada fichero porque quien lo descarga no sabe de qué plataforma
  /// vino.
  static const Map<String, String> imageHeaders = {
    'User-Agent': pixivUserAgent,
    'Referer': '$pixivSiteUrl/',
  };

  /// El contenido de todo lo que el usuario tiene marcado en su cuenta, de lo
  /// más reciente a lo más antiguo.
  ///
  /// Se recorren los dos listados de marcadores, el público y el privado, uno
  /// detrás de otro y cada uno por páginas hasta que Pixiv deja de dar más (o
  /// hasta [pixivMaxPages]). Cada obra lleva su listado en
  /// [RemoteMediaItem.collection]: son dos recorridos independientes, y quien
  /// lleve la cuenta de por dónde se quedó la última importación tiene que
  /// llevarla por separado.
  ///
  /// Las animaciones (*ugoira*) también salen, montadas: Pixiv las sirve como
  /// un zip de fotogramas, así que lo que se da es la dirección del paquete y
  /// lo que dura cada uno, y quien descarga las junta en un fichero.
  Stream<RemoteMediaItem> bookmarkedMedia(
    PixivSettingsEntity credentials, {
    /// Por dónde se quedó la vez anterior en cada listado. Cuando se vuelve a
    /// encontrar esa obra, ese listado se da por recorrido y se pasa al
    /// siguiente. Vacío para traerse todo.
    Map<String, String> stopAt = const {},

    /// Si una obra no hace falta, **por su identificador y antes de
    /// resolverla**. Lo caro aquí es una animación: baja su paquete de
    /// fotogramas para armar el GIF, y hacerlo para tirarlo después es el viaje
    /// más caro de esta fuente.
    bool Function(String remoteId, String postId)? skip,
  }) async* {
    final userId = credentials.userId;
    if (userId == null) {
      throw Exception('The Pixiv session cookie does not carry an account');
    }

    for (final collection in pixivBookmarkCollections) {
      yield* _bookmarks(
        credentials,
        userId: userId,
        collection: collection,
        stopAt: stopAt[collection],
        skip: skip,
      );
    }
  }

  /// Uno de los dos listados de marcadores, del más reciente al más antiguo.
  Stream<RemoteMediaItem> _bookmarks(
    PixivSettingsEntity credentials, {
    required String userId,
    required String collection,
    required String? stopAt,
    bool Function(String remoteId, String postId)? skip,
  }) async* {
    final headers = _headers(credentials, referer: '$pixivSiteUrl/');

    for (var page = 0; page < pixivMaxPages; page++) {
      final uri = Uri.https(
        pixivApiHost,
        '/ajax/user/$userId/illusts/bookmarks',
        {
          // El filtro por etiqueta va vacío, pero tiene que ir: sin él la
          // llamada no vale.
          'tag': '',
          'offset': '${page * pixivPageSize}',
          'limit': '$pixivPageSize',
          'rest': collection,
        },
      );

      final body = await _get(uri, headers: headers, what: 'the bookmarks');
      final works = (body?['works'] as List<dynamic>?) ?? const [];
      if (works.isEmpty) return;

      for (final entry in works) {
        if (entry is! Map<String, dynamic>) continue;

        final id = entry['id'] as String?;
        if (id == null || id.isEmpty) continue;

        // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
        if (id == stopAt) return;

        // Una obra que la cuenta ya no puede ver (borrada, o de un autor que se
        // ha ido) sigue apareciendo en los marcadores, pero sin nada detrás.
        if (entry['isMasked'] == true) continue;

        // Antes de resolverla: una animación baja su paquete de fotogramas aquí
        // dentro, y hacerlo para tirarlo después es el viaje más caro de esta
        // fuente. Con el nombre basta — es el identificador de una obra de una
        // sola pieza, que es justo el caso de las animaciones.
        if (skip?.call(_fileSafe(_nameOf(entry)), id) ?? false) continue;

        yield* Stream.fromIterable(
          await _mediaOf(entry, credentials: credentials, collection: collection),
        );
      }

      // El listado se ha acabado si esta página no venía llena.
      if (works.length < pixivPageSize) return;
    }
  }

  /// Con qué nombre se conoce aquí una obra, antes de limpiarlo.
  ///
  /// En un solo sitio a propósito: se compone antes de resolverla —para saber si
  /// hace falta— y al construirla, y dos formas distintas de escribirlo harían
  /// que el salto nunca coincidiera con lo guardado.
  static String _nameOf(Map<String, dynamic> work) {
    final id = work['id'] as String? ?? '';
    final authorId = work['userId'] as String? ?? '';

    return authorId.isEmpty ? id : '${authorId}_$id';
  }

  /// Los ficheros que salen de una obra.
  ///
  /// Una obra de varias páginas da uno por página, y una de una sola, uno. Una
  /// animación da uno también: el paquete de fotogramas del que sale. El
  /// listado de marcadores no trae las direcciones de los originales (sólo la
  /// miniatura), así que se le preguntan a Pixiv obra por obra.
  ///
  /// Si esa consulta no sale, la obra se queda fuera y la importación sigue:
  /// es contenido que no llega, no un fallo de la importación.
  Future<List<RemoteMediaItem>> _mediaOf(
    Map<String, dynamic> work, {
    required PixivSettingsEntity credentials,
    required String collection,
  }) async {
    final id = work['id'] as String? ?? '';
    final title = work['title'] as String? ?? '';
    final authorId = work['userId'] as String? ?? '';
    final name = _fileSafe(_nameOf(work));
    final sourceUrls = _sourceUrls(id, authorId: authorId);

    if (work['illustType'] == pixivUgoiraIllustType) {
      final animation = await _ugoira(id, credentials: credentials);
      if (animation == null) return const [];

      return [
        RemoteMediaItem(
          id: name,
          url: animation.url,
          title: title,
          postId: id,
          sourceUrls: sourceUrls,
          headers: imageHeaders,
          collection: collection,
          frameDelays: animation.delays,
        ),
      ];
    }

    final List<String> pages;
    try {
      pages = await _pageUrls(id, credentials: credentials);
    } on RemoteSessionExpiredException {
      // Esto no es una obra que no llega: es que ya no se puede pedir nada más.
      rethrow;
    } on Exception {
      return const [];
    }

    return [
      for (var i = 0; i < pages.length; i++)
        RemoteMediaItem(
          id: '${name}_p$i',
          url: pages[i],
          title: title,
          postId: id,
          sourceUrls: sourceUrls,
          headers: imageHeaders,
          collection: collection,
        ),
    ];
  }

  /// De dónde sale la obra, en direcciones que el usuario reconoce y puede
  /// haber vinculado con una etiqueta.
  ///
  /// De la más general a la más concreta: la galería del autor y la propia
  /// obra. Se dan las dos porque una etiqueta puede estar vinculada a
  /// cualquiera de ellas, y quien las compara ya sabe que una regla recoge todo
  /// lo que cuelga de ella.
  List<String> _sourceUrls(String id, {required String authorId}) {
    return [
      if (authorId.isNotEmpty) '$pixivSiteUrl/users/$authorId',
      '$pixivSiteUrl/artworks/$id',
    ];
  }

  /// Las direcciones de los ficheros originales de una obra, en el orden en el
  /// que las puso quien publicó.
  Future<List<String>> _pageUrls(
    String id, {
    required PixivSettingsEntity credentials,
  }) async {
    final body = await _get(
      Uri.https(pixivApiHost, '/ajax/illust/$id/pages'),
      headers: _headers(credentials, referer: '$pixivSiteUrl/artworks/$id'),
      what: 'the pages of $id',
      // La respuesta de este es una lista, no un objeto.
      asList: true,
    );

    final pages = (body?['body'] as List<dynamic>?) ?? const [];

    return [
      for (final page in pages)
        if (page is Map<String, dynamic>)
          if ((page['urls'] as Map<String, dynamic>?)?['original']
              case final String url)
            if (url.isNotEmpty) url,
    ];
  }

  /// El paquete de fotogramas de una animación y lo que dura cada uno, o `null`
  /// si Pixiv no lo da.
  ///
  /// Pixiv no guarda estas obras como un vídeo sino como un zip de imágenes
  /// numeradas más los tiempos, y los sirve por su cuenta: hay que preguntar
  /// por ellos aparte de las páginas de la obra. Se pide el paquete de los
  /// originales y, si no está, el de tamaño reducido, que es el que siempre
  /// hay.
  Future<({String url, List<int> delays})?> _ugoira(
    String id, {
    required PixivSettingsEntity credentials,
  }) async {
    final Map<String, dynamic>? body;
    try {
      body = await _get(
        Uri.https(pixivApiHost, '/ajax/illust/$id/ugoira_meta'),
        headers: _headers(credentials, referer: '$pixivSiteUrl/artworks/$id'),
        what: 'the animation of $id',
      );
    } on RemoteSessionExpiredException {
      rethrow;
    } on Exception {
      return null;
    }

    final url = (body?['originalSrc'] ?? body?['src']) as String?;
    if (url == null || url.isEmpty) return null;

    final frames = (body?['frames'] as List<dynamic>?) ?? const [];

    return (
      url: url,
      delays: [
        for (final frame in frames)
          if (frame is Map<String, dynamic>)
            (frame['delay'] as num?)?.toInt() ?? defaultAnimationFrameDelay,
      ],
    );
  }

  /// Pide algo a la API y devuelve su contenido.
  ///
  /// Pixiv contesta siempre con la misma envoltura: un `error` que dice si ha
  /// ido bien y un `body` con lo pedido. Un fallo de sesión llega como código
  /// de error o como `error: true`, y en los dos casos significa lo mismo: la
  /// cookie ya no vale y no hay nada que se pueda importar.
  ///
  /// Cuando el `body` es una lista se devuelve envuelto en un mapa bajo la
  /// clave `body` ([asList]), que es lo que espera quien lo lee.
  Future<Map<String, dynamic>?> _get(
    Uri uri, {
    required Map<String, String> headers,
    required String what,
    bool asList = false,
  }) async {
    final response =
        await _client.get(uri, headers: headers).timeout(remoteRequestTimeout);

    // Una sesión que ya no vale se cuenta aparte: no es que algo haya ido mal,
    // es que el usuario tiene que volver a entrar en su cuenta, y eso hay que
    // poder decírselo.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const RemoteSessionExpiredException(ImportSource.pixiv);
    }

    if (response.statusCode != 200) {
      throw Exception('Pixiv refused $what (${response.statusCode})');
    }

    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      // Lo que ha llegado no es la API: cuando la sesión no vale, Pixiv
      // devuelve la página de inicio de sesión con un código de acierto.
      throw const RemoteSessionExpiredException(ImportSource.pixiv);
    }

    if (envelope['error'] == true) {
      final message = envelope['message'] as String? ?? '';
      throw Exception(
        'Pixiv refused $what${message.isEmpty ? '' : ': $message'}',
      );
    }

    final body = envelope['body'];
    if (asList) return body is List ? {'body': body} : null;

    return body is Map<String, dynamic> ? body : null;
  }

  /// Deja el texto en algo que sirva como nombre de fichero en cualquier
  /// sistema.
  String _fileSafe(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  void close() => _client.close();
}
