import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/data/datasources/remote_post.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/media/domain/services/pawchive_timestamps.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:http/http.dart' as http;

/// La API de Pawchive, con lo justo para traerse lo que el usuario tiene
/// marcado.
///
/// El sitio está hecho sobre Kemono, así que habla como él: una API bajo
/// `/api/v1` que devuelve JSON pelado y en la que se entra con la galleta de
/// sesión. Los ficheros los sirve un servidor aparte, que los da sin pedir nada.
///
/// Hay dos formas de recorrerlo, y las dos acaban en lo mismo (publicaciones de
/// lo más reciente a lo más antiguo):
///
/// - **Por publicaciones marcadas** ([favoritePosts]): lo que el usuario ha ido
///   guardando, sin más.
/// - **Por creadores marcados** ([creatorPosts]): todo lo que hayan publicado
///   los autores que sigue. Trae mucho más, así que cada autor se recorre por su
///   cuenta y lleva su propia marca de por dónde se iba.
///
/// De cada publicación no sólo interesan sus ficheros: también lo que enlaza,
/// porque en estas plataformas es habitual que lo bueno esté detrás de un
/// enlace y no adjunto. Eso llega clasificado en [RemotePost.links]; qué se hace
/// con ello se decide fuera.
class PawchiveApiClient {
  final http.Client _client;

  PawchiveApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Las publicaciones que el usuario tiene marcadas, de la más reciente a la
  /// más antigua.
  Stream<RemotePost> favoritePosts(
    PawchiveSettingsEntity credentials, {
    String? stopAt,
  }) async* {
    final favorites = await _favorites(credentials, type: 'post');

    for (final post in favorites) {
      final id = post['id']?.toString() ?? '';
      if (id.isEmpty) continue;

      // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
      if (id == stopAt) return;

      yield await _postOf(post, credentials: credentials);
    }
  }

  /// Todo lo de los creadores que el usuario tiene marcados, autor por autor.
  ///
  /// [stopAt] lleva una marca por autor: cada uno se recorre por su cuenta, así
  /// que dónde se quedó uno no dice nada de los demás.
  Stream<RemotePost> creatorPosts(
    PawchiveSettingsEntity credentials, {
    Map<String, String> stopAt = const {},
  }) async* {
    final creators = await _favorites(credentials, type: 'artist');

    for (final creator in creators) {
      final id = creator['id']?.toString() ?? '';
      final service = creator['service'] as String? ?? '';
      if (id.isEmpty || service.isEmpty) continue;

      final collection = pawchiveCreatorCollection(service: service, id: id);

      yield* _postsOf(
        credentials,
        service: service,
        user: id,
        collection: collection,
        stopAt: stopAt[collection],
      );
    }
  }

  /// Los creadores que el usuario tiene marcados, para poder elegir.
  ///
  /// Se devuelven **sin contar** sus publicaciones nuevas: contarlas es una
  /// petición por creador, y con cincuenta marcados eso son cincuenta esperas
  /// antes de poder enseñar nada. La lista sale enseguida y los números van
  /// llegando después.
  Future<List<RemoteCreator>> favoriteCreators(
    PawchiveSettingsEntity credentials,
  ) async {
    final entries = await _favorites(credentials, type: 'artist');

    final creators = <RemoteCreator>[];

    for (final entry in entries) {
      final id = entry['id']?.toString() ?? '';
      final service = entry['service'] as String? ?? '';
      if (id.isEmpty || service.isEmpty) continue;

      creators.add(RemoteCreator(
        id: pawchiveCreatorCollection(service: service, id: id),
        name: (entry['name'] as String?)?.trim().isNotEmpty == true
            ? (entry['name'] as String).trim()
            : id,
        service: service,
        avatarUrl: pawchiveCreatorAvatar(service: service, id: id),
        // Cuándo publicó por última vez. Viene aquí mismo, así que cruzarlo con
        // la fecha de la última importación dice si tiene novedades sin
        // preguntar por él aparte.
        updatedAt: pawchiveTimestamp(entry['updated']),
      ));
    }

    return creators;
  }

  /// Cuántas publicaciones nuevas tiene un creador desde [stopAt].
  ///
  /// Sólo se mira la primera página: con más de una hoja de publicaciones
  /// nuevas, el número exacto deja de importar —lo que dice la tarjeta es «hay
  /// mucho»— y seguir pidiendo páginas por cada uno de cincuenta creadores es
  /// mucho pedirle al sitio.
  ///
  /// Sin [stopAt] no hay con qué comparar: nunca se ha mirado esa cuenta, así
  /// que no hay «nuevas», hay todas.
  Future<int?> newPostCount(
    PawchiveSettingsEntity credentials, {
    required String service,
    required String user,
    required String? stopAt,
  }) async {
    if (stopAt == null || stopAt.isEmpty) return null;

    try {
      final posts = await _get(
        credentials,
        '/api/v1/$service/user/$user',
        {'o': '0'},
      );

      if (posts is! List) return null;

      var count = 0;

      for (final entry in posts) {
        if (entry is! Map<String, dynamic>) continue;
        if (entry['id']?.toString() == stopAt) return count;

        count++;
      }

      return count;
    } on Exception {
      return null;
    }
  }

  /// Todo lo de **estos** creadores, y no lo de todos los marcados.
  ///
  /// Es lo que hay detrás de elegir unos cuantos en la pantalla de importación.
  /// [only] lleva las claves de colección; una lista vacía significa todos, que
  /// es como se comportaba antes de poder elegir.
  ///
  /// [onCreator] avisa de cada creador **cuando se ha terminado de recorrerlo**,
  /// y hace falta porque uno que no ha publicado nada nuevo no suelta ni una
  /// publicación: sin esto, quien escucha no se entera de que se le ha mirado, y
  /// «cuándo se miró por última vez» se quedaría clavado en la vez que sí trajo
  /// algo.
  ///
  /// Al terminar y no al empezar, que es lo que hace que cortar la importación a
  /// medias no deje a nadie por mirado sin haberlo mirado entero.
  Stream<RemotePost> postsOfCreators(
    PawchiveSettingsEntity credentials, {
    Set<String> only = const {},
    Map<String, String> stopAt = const {},
    void Function(String collection)? onCreator,
  }) async* {
    final creators = await _favorites(credentials, type: 'artist');

    for (final creator in creators) {
      final id = creator['id']?.toString() ?? '';
      final service = creator['service'] as String? ?? '';
      if (id.isEmpty || service.isEmpty) continue;

      final collection = pawchiveCreatorCollection(service: service, id: id);
      if (only.isNotEmpty && !only.contains(collection)) continue;

      yield* _postsOf(
        credentials,
        service: service,
        user: id,
        collection: collection,
        stopAt: stopAt[collection],
      );

      onCreator?.call(collection);
    }
  }

  /// Si la cuenta tiene creadores marcados.
  ///
  /// Sirve para explicar una importación vacía: no es lo mismo "no tienes nada
  /// marcado" que "lo que tienes marcado son creadores y estás pidiendo
  /// publicaciones".
  Future<bool> hasFavoriteCreators(PawchiveSettingsEntity credentials) async {
    try {
      return (await _favorites(credentials, type: 'artist')).isNotEmpty;
    } on Exception {
      return false;
    }
  }

  /// Las publicaciones de un creador, de la más reciente a la más antigua.
  Stream<RemotePost> _postsOf(
    PawchiveSettingsEntity credentials, {
    required String service,
    required String user,
    required String collection,
    required String? stopAt,
  }) async* {
    for (var page = 0; page < pawchiveMaxPages; page++) {
      final posts = await _get(
        credentials,
        '/api/v1/$service/user/$user',
        {'o': '${page * pawchivePageSize}'},
      );

      if (posts is! List || posts.isEmpty) return;

      for (final entry in posts) {
        if (entry is! Map<String, dynamic>) continue;

        final id = entry['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        if (id == stopAt) return;

        yield await _postOf(
          entry,
          credentials: credentials,
          collection: collection,
        );
      }

      if (posts.length < pawchivePageSize) return;
    }
  }

  /// Lo que el usuario tiene marcado, del tipo que se pida, ya ordenado.
  ///
  /// Llega todo de una vez y sin un orden garantizado, así que se ordena aquí
  /// por el número que le tocó a cada uno al marcarlo, que es lo único que dice
  /// en qué orden se marcaron.
  Future<List<Map<String, dynamic>>> _favorites(
    PawchiveSettingsEntity credentials, {
    required String type,
  }) async {
    final body = await _get(credentials, pawchiveFavoritesPath, {'type': type});
    if (body is! List) return const [];

    final entries = [
      for (final entry in body)
        if (entry is Map<String, dynamic>) entry,
    ];

    entries.sort((a, b) => _orderOf(b).compareTo(_orderOf(a)));

    return entries;
  }

  /// Con qué se ordena un favorito: el número que le tocó al marcarlo, y si no
  /// lo hay, su fecha.
  String _orderOf(Map<String, dynamic> entry) {
    final sequence = entry[pawchiveFavoriteSequence];
    if (sequence != null) return sequence.toString().padLeft(20, '0');

    return (entry['published'] ?? entry['updated'] ?? '').toString();
  }

  /// Una publicación con todo lo que trae: sus ficheros y sus enlaces.
  ///
  /// El listado de publicaciones no trae el cuerpo, y es ahí donde están los
  /// enlaces, así que hay que pedir la publicación entera. Sólo se pide cuando
  /// hace falta: si el listado ya vino con cuerpo, no se vuelve a preguntar.
  Future<RemotePost> _postOf(
    Map<String, dynamic> post, {
    required PawchiveSettingsEntity credentials,
    String? collection,
  }) async {
    final id = post['id']?.toString() ?? '';
    final service = post['service'] as String? ?? '';
    final user = post['user']?.toString() ?? '';

    var full = post;
    if (post['content'] == null && service.isNotEmpty && user.isNotEmpty) {
      full = await _detailOf(
            credentials,
            service: service,
            user: user,
            id: id,
          ) ??
          post;
    }

    final sourceUrls = _sourceUrls(id, service: service, user: user);
    final title = full['title'] as String? ?? '';

    return RemotePost(
      id: id,
      title: title,
      collection: collection,
      sourceUrls: sourceUrls,
      media: _mediaOf(full, id: id, title: title, sourceUrls: sourceUrls),
      links: linksInPost(full['content'] as String?),
    );
  }

  /// La publicación entera, o `null` si no se puede traer.
  ///
  /// Que no llegue no corta nada: se trabaja con lo que traía el listado, que
  /// es lo que hay.
  Future<Map<String, dynamic>?> _detailOf(
    PawchiveSettingsEntity credentials, {
    required String service,
    required String user,
    required String id,
  }) async {
    final Object? body;
    try {
      body = await _get(
        credentials,
        '/api/v1/$service/user/$user/post/$id',
        const {},
      );
    } on RemoteSessionExpiredException {
      rethrow;
    } on Exception {
      return null;
    }

    if (body is! Map<String, dynamic>) return null;

    // Según la versión, la publicación llega pelada o dentro de un envoltorio.
    final post = body['post'];

    return post is Map<String, dynamic> ? post : body;
  }

  /// Los ficheros que trae puestos una publicación.
  ///
  /// Además de sus adjuntos suele traer uno suelto que hace de portada, y ése
  /// ya viene entre los adjuntos casi siempre: se descartan los repetidos.
  List<RemoteMediaItem> _mediaOf(
    Map<String, dynamic> post, {
    required String id,
    required String title,
    required List<String> sourceUrls,
  }) {
    final paths = <String>{};
    for (final file in [
      post['file'],
      ...?(post['attachments'] as List<dynamic>?),
    ]) {
      if (file is! Map<String, dynamic>) continue;

      final path = file['path'] as String?;
      if (path == null || path.isEmpty) continue;

      paths.add(path);
    }

    return [
      for (final (index, path) in paths.indexed)
        RemoteMediaItem(
          id: 'pawchive_${id}_$index',
          url: '$pawchiveFileUrl$path',
          title: title,
          postId: id,
          sourceUrls: sourceUrls,
        ),
    ];
  }

  /// De dónde sale la publicación, de lo más general a lo más concreto.
  List<String> _sourceUrls(
    String id, {
    required String service,
    required String user,
  }) {
    if (service.isEmpty || user.isEmpty) return const [];

    final creator = '$pawchiveSiteUrl/$service/user/$user';

    return [creator, '$creator/post/$id'];
  }

  /// Pide algo a la API y devuelve lo que traiga, tal cual.
  Future<Object?> _get(
    PawchiveSettingsEntity credentials,
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.https(pawchiveApiHost, path, params.isEmpty ? null : params);

    final response = await _client.get(
      uri,
      headers: {
        'User-Agent': remoteUserAgent.replaceFirst('%s', 'fern'),
        'Accept': 'application/json',
        'Cookie': '$pawchiveSessionCookieName=${credentials.sessionId.trim()}',
      },
    ).timeout(remoteRequestTimeout);

    // Sin sesión, o con una que ya no vale, contesta que no hay permiso.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const RemoteSessionExpiredException(ImportSource.pawchive);
    }

    if (response.statusCode != 200) {
      throw Exception('Pawchive refused $path (${response.statusCode})');
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw Exception('Pawchive did not answer with what it should');
    }
  }

  void close() => _client.close();
}
