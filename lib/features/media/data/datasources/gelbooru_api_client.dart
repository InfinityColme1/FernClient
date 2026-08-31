import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:http/http.dart' as http;

/// La API de Gelbooru, con lo justo para traerse lo que el usuario tiene en
/// favoritos.
///
/// Su API es pública y se entra con el identificador de la cuenta y su clave,
/// pero el listado de favoritos es el más incómodo de todos los que usa la
/// aplicación, y por dos motivos:
///
/// - **No devuelve publicaciones, sino referencias a ellas**: de cada favorito
///   llega su identificador y cuándo se marcó, así que hay que pedir cada
///   publicación aparte.
/// - **No siempre viene en el mismo orden**: según la cuenta, los favoritos
///   llegan del más antiguo al más reciente o al revés. Como todo lo demás en
///   la aplicación se apoya en recibir primero lo más nuevo (es lo que permite
///   parar donde se quedó la importación anterior), aquí hay que averiguar
///   primero en qué orden vienen y recorrerlos en consecuencia.
///
/// El pedir cada publicación aparte tiene una ventaja: sólo se pide la de lo
/// que se va a traer de verdad. Al parar en la marca, de las anteriores no se
/// llega a preguntar nada.
class GelbooruApiClient {
  final http.Client _client;

  GelbooruApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Cabeceras con las que se descarga un fichero de Gelbooru.
  ///
  /// Su servidor de imágenes sólo lo da si la petición dice venir de su web. A
  /// quien no lo dice no le contesta con un error, que sería fácil de ver: le
  /// devuelve la **página** de la publicación, con código de acierto y todo, y
  /// por eso hace falta esto para bajar una imagen y no un montón de HTML.
  ///
  /// Viajan con cada fichero porque quien lo descarga no sabe de qué plataforma
  /// vino.
  static const Map<String, String> imageHeaders = {
    'Referer': '$gelbooruSiteUrl/',
  };

  /// Lo que el usuario tiene en favoritos, de lo más reciente a lo más antiguo.
  ///
  /// [stopAt] es la publicación en la que se quedó la importación anterior:
  /// cuando se vuelve a encontrar, se para. Vacío para traerse todo.
  /// [skip] dice si una pieza no hace falta, **por su identificador y antes de
  /// pedirla**.
  ///
  /// Aquí importa más que en las demás fuentes: el listado de favoritos de
  /// Gelbooru no trae las publicaciones, sólo referencias, así que cada una
  /// cuesta su propia petición. Preguntando después de pedirla, saltarse cien
  /// bloqueadas costaba cien viajes al servidor para tirar lo que llegaba.
  ///
  /// El identificador se puede componer aquí porque sale del propio favorito.
  /// Va con el de la publicación porque quien pregunta lleva la cuenta de por
  /// dónde se quedó, y ésa avanza también con lo que se salta: es contenido que
  /// ya se ha mirado.
  Stream<RemoteMediaItem> favoriteMedia(
    GelbooruSettingsEntity credentials, {
    String? stopAt,
    bool Function(String remoteId, String postId)? skip,
  }) async* {
    final newestFirst = await _isNewestFirst(credentials);

    final favorites = newestFirst
        ? _forward(credentials)
        : _backward(credentials);

    // Cuántas publicaciones se han pedido y cuántas han llegado. Una que se
    // pierda es normal (se habrá borrado desde que se marcó); que se pierdan
    // todas no lo es, y sin esto pasaría por "esta cuenta no tiene favoritos".
    var asked = 0;
    var missing = 0;

    await for (final favorite in favorites) {
      final postId = favorite['favorite']?.toString() ?? '';
      if (postId.isEmpty) continue;

      // Aquí se quedó la vez anterior: de este punto para atrás ya se miró.
      if (postId == stopAt) return;

      // Antes de pedirla: es lo que convierte cien bloqueadas en cien
      // comprobaciones en memoria en vez de cien peticiones.
      if (skip?.call(_remoteIdOf(postId), postId) ?? false) continue;

      asked++;
      final item = await _post(postId, credentials: credentials);

      if (item == null) {
        missing++;
        if (asked >= gelbooruMinAskedToGiveUp && missing == asked) {
          throw Exception(
            'Gelbooru listed $asked favorites but did not give any of their '
            'posts',
          );
        }
        continue;
      }

      yield item;
    }
  }

  /// Con qué nombre se conoce aquí una publicación.
  ///
  /// En un solo sitio a propósito: se compone antes de pedirla —para saber si
  /// hace falta— y al construirla, y dos formas distintas de escribirlo harían
  /// que el salto nunca coincidiera con lo guardado.
  static String _remoteIdOf(String postId) => 'gelbooru_$postId';

  /// En qué orden devuelve esta cuenta sus favoritos.
  ///
  /// Se mira pidiendo los dos primeros y comparando sus identificadores: los de
  /// los favoritos van subiendo según se marcan, así que si el primero es menor
  /// que el segundo es que llegan del más antiguo al más reciente.
  ///
  /// Con menos de dos favoritos da igual el orden que se suponga: lo que haya
  /// se recorre entero de una forma o de la otra.
  Future<bool> _isNewestFirst(GelbooruSettingsEntity credentials) async {
    final first = await _favoritePage(credentials, page: 0, limit: 2);

    // Gelbooru ha contestado, dice que la cuenta tiene favoritos y no ha dado
    // ninguno: eso no es una cuenta vacía, es una respuesta que no sirve, y
    // callarlo dejaría la importación en cero sin explicar por qué.
    final count = first.count;
    if (first.items.isEmpty && count != null && count > 0) {
      throw Exception(
        'Gelbooru says the account has $count favorites but listed none',
      );
    }

    if (first.items.length < 2) return true;

    final one = (first.items[0]['id'] as num?)?.toInt() ?? 0;
    final two = (first.items[1]['id'] as num?)?.toInt() ?? 0;

    return one > two;
  }

  /// Los favoritos recorriendo el listado hacia delante, que es lo que vale
  /// cuando la cuenta los devuelve empezando por el más reciente.
  Stream<Map<String, dynamic>> _forward(
    GelbooruSettingsEntity credentials,
  ) async* {
    for (var page = 0; page < gelbooruMaxPages; page++) {
      final favorites = await _favoritePage(credentials, page: page);
      if (favorites.items.isEmpty) return;

      yield* Stream.fromIterable(favorites.items);
    }
  }

  /// Los favoritos del más reciente al más antiguo cuando la cuenta los
  /// devuelve al revés.
  ///
  /// Aquí no se puede ir a la última página y volver: el número de favoritos
  /// que dice Gelbooru no cuadra con las páginas que acaba dando, así que
  /// calcular dónde está el final se equivoca. Lo que sí se puede es recorrer
  /// el listado entero hacia delante —que es barato, porque son referencias y
  /// no publicaciones— y darle la vuelta.
  Stream<Map<String, dynamic>> _backward(
    GelbooruSettingsEntity credentials,
  ) async* {
    final all = <Map<String, dynamic>>[];

    for (var page = 0; page < gelbooruMaxPages; page++) {
      final favorites = await _favoritePage(credentials, page: page);
      if (favorites.items.isEmpty) break;

      all.addAll(favorites.items);
    }

    yield* Stream.fromIterable(all.reversed);
  }

  /// Una página del listado de favoritos, con lo que Gelbooru diga que hay en
  /// total.
  Future<({List<Map<String, dynamic>> items, int? count})> _favoritePage(
    GelbooruSettingsEntity credentials, {
    required int page,
    int limit = gelbooruPageSize,
  }) {
    return _get(
      credentials,
      {
        's': 'favorite',
        // El favorito es de esta cuenta: aquí va de quién son los que se piden.
        'id': credentials.userId.trim(),
        'limit': '$limit',
        'pid': '$page',
      },
      key: 'favorite',
    );
  }

  /// El fichero de una publicación, o `null` si Gelbooru no da ninguno.
  ///
  /// Que una publicación no llegue no corta la importación: puede haberse
  /// borrado desde que se marcó. Lo que sí la corta es que **no llegue
  /// ninguna**, y de eso se encarga quien llama: una a una no se distingue una
  /// obra perdida de una API que ha dejado de contestar como debía.
  Future<RemoteMediaItem?> _post(
    String postId, {
    required GelbooruSettingsEntity credentials,
  }) async {
    final List<Map<String, dynamic>> posts;
    try {
      posts = (await _get(
        credentials,
        {'s': 'post', 'id': postId},
        key: 'post',
      ))
          .items;
    } on RemoteSessionExpiredException {
      // Esto no es una publicación que no llega: es que ya no se puede pedir
      // nada más.
      rethrow;
    } on Exception {
      return null;
    }

    if (posts.isEmpty) return null;

    final post = posts.first;
    final url = post['file_url'] as String?;
    if (url == null || url.isEmpty) return null;

    final source = post['source'] as String? ?? '';

    return RemoteMediaItem(
      id: _remoteIdOf('$postId'),
      url: url,
      title: '',
      postId: postId,
      headers: imageHeaders,
      sourceUrls: [
        if (source.startsWith('https://')) source,
        '$gelbooruSiteUrl/index.php?page=post&s=view&id=$postId',
      ],
    );
  }

  /// Pide algo a la API y devuelve la lista que traiga bajo [key].
  ///
  /// Todo cuelga de la misma dirección y se distingue por parámetros. Cuando no
  /// hay resultados, Gelbooru contesta sin la lista (o directamente con nada),
  /// que es su forma de decir que ahí no queda ya nada.
  Future<({List<Map<String, dynamic>> items, int? count})> _get(
    GelbooruSettingsEntity credentials,
    Map<String, String> params, {
    required String key,
  }) async {
    final uri = Uri.https(gelbooruApiHost, gelbooruApiPath, {
      'page': 'dapi',
      'q': 'index',
      'json': '1',
      ...params,
      'api_key': credentials.apiKey.trim(),
      'user_id': credentials.userId.trim(),
    });

    final response = await _client.get(
      uri,
      headers: {'User-Agent': remoteUserAgent.replaceFirst('%s', 'fern')},
    ).timeout(remoteRequestTimeout);

    // Igual que en las demás: unas credenciales que no valen no son un fallo
    // cualquiera, son algo que sólo el usuario puede arreglar.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const RemoteSessionExpiredException(ImportSource.gelbooru);
    }

    if (response.statusCode != 200) {
      throw Exception('Gelbooru refused the request (${response.statusCode})');
    }

    if (response.body.trim().isEmpty) {
      return (items: const <Map<String, dynamic>>[], count: null);
    }

    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Gelbooru did not answer with what it should');
    }

    // Según lo que se pida, lo que interesa llega dentro de un objeto o pelado.
    final found = body is Map<String, dynamic> ? body[key] : body;

    // Gelbooru dice de paso cuántos hay en total. No sirve para paginar (ese
    // número no cuadra con las páginas que acaba dando), pero sí para saber si
    // una respuesta vacía significa "no hay nada" o "algo no va".
    final attributes =
        body is Map<String, dynamic> ? body['@attributes'] : null;
    final count = attributes is Map<String, dynamic>
        ? int.tryParse('${attributes['count']}')
        : null;

    // Y cuando sólo hay un resultado, Gelbooru lo manda suelto en lugar de en
    // una lista de uno. Pedir una publicación por su identificador es
    // justamente el caso en el que siempre hay uno, así que sin esto no llegaba
    // ninguna.
    if (found is Map<String, dynamic>) return (items: [found], count: count);

    if (found is! List) {
      return (items: const <Map<String, dynamic>>[], count: count);
    }

    return (
      items: [
        for (final entry in found)
          if (entry is Map<String, dynamic>) entry,
      ],
      count: count,
    );
  }

  void close() => _client.close();
}
