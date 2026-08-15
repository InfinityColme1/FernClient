// La fuente remota de Gelbooru.
//
// Aquí lo que hay que comprobar no es lo de siempre, sino lo que hace rara a
// esta plataforma: su listado de favoritos no devuelve publicaciones sino
// referencias, y no siempre las da en el mismo orden. Todo lo demás de la
// aplicación da por hecho que lo primero que llega es lo más reciente, así que
// el cliente tiene que dejarlo así venga como venga.

import 'dart:convert';

import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Un favorito tal y como llega en el listado: su propio identificador (que
/// sube según se marcan) y el de la publicación a la que apunta.
Map<String, dynamic> favorite(int id, {required int postId}) =>
    {'id': id, 'favorite': postId};

/// Un Gelbooru de mentira.
///
/// [favorites] son los favoritos en el orden en el que la cuenta los devuelve,
/// que es justo lo que cambia de una a otra. Cada publicación se responde con su
/// fichero, salvo las que se digan en [missing].
http.Client fakeGelbooru({
  required List<Map<String, dynamic>> favorites,
  Set<String> missing = const {},
  List<Uri>? calls,
  int pageSize = 100,
  bool singlePostAsList = false,
}) {
  return MockClient((request) async {
    calls?.add(request.url);

    final params = request.url.queryParameters;

    if (params['s'] == 'favorite') {
      final page = int.parse(params['pid'] ?? '0');
      final limit = int.parse(params['limit'] ?? '$pageSize');
      final from = page * limit;

      final slice = from >= favorites.length
          ? const <Map<String, dynamic>>[]
          : favorites.sublist(from, (from + limit).clamp(0, favorites.length));

      return http.Response(
        jsonEncode({
          '@attributes': {'count': favorites.length},
          'favorite': slice,
        }),
        200,
      );
    }

    final id = params['id'] ?? '';
    if (missing.contains(id)) {
      return http.Response(jsonEncode({'@attributes': {}}), 200);
    }

    final post = {
      'id': int.parse(id),
      'file_url': 'https://img3.gelbooru.com/images/$id.jpg',
      'source': '',
    };

    // Con un solo resultado, Gelbooru manda la publicación suelta en lugar de
    // en una lista de uno. Es justo lo que pasa al pedirla por su
    // identificador, que es como se piden aquí todas.
    return http.Response(
      jsonEncode({'post': singlePostAsList ? [post] : post}),
      200,
    );
  });
}

const credentials = GelbooruSettingsEntity(userId: '4242', apiKey: 'clave');

void main() {
  group('las credenciales', () {
    test('hacen falta la clave y un identificador que sea un número', () {
      expect(credentials.isComplete, isTrue);
      expect(const GelbooruSettingsEntity(userId: '4242').isComplete, isFalse);
      expect(
        const GelbooruSettingsEntity(userId: 'usuaria', apiKey: 'clave')
            .isComplete,
        isFalse,
      );
    });
  });

  group('los favoritos', () {
    test('cuando la cuenta los da del más reciente al más antiguo, se recorren '
        'tal cual', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(favorites: [
          favorite(30, postId: 300),
          favorite(20, postId: 200),
          favorite(10, postId: 100),
        ]),
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items.map((item) => item.postId), ['300', '200', '100']);
    });

    test('cuando los da al revés, se le da la vuelta al listado', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(favorites: [
          favorite(10, postId: 100),
          favorite(20, postId: 200),
          favorite(30, postId: 300),
        ]),
      );

      final items = await client.favoriteMedia(credentials).toList();

      // Lo primero que sale tiene que ser lo último que se marcó, venga como
      // venga de la plataforma.
      expect(items.map((item) => item.postId), ['300', '200', '100']);
    });

    test('se para donde se quedó la vez anterior', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(favorites: [
          favorite(30, postId: 300),
          favorite(20, postId: 200),
          favorite(10, postId: 100),
        ]),
      );

      final items =
          await client.favoriteMedia(credentials, stopAt: '200').toList();

      expect(items.map((item) => item.postId), ['300']);
    });

    test('de lo que ya se miró no se llega a preguntar nada', () async {
      final calls = <Uri>[];
      final client = GelbooruApiClient(
        client: fakeGelbooru(
          favorites: [
            favorite(30, postId: 300),
            favorite(20, postId: 200),
            favorite(10, postId: 100),
          ],
          calls: calls,
        ),
      );

      await client.favoriteMedia(credentials, stopAt: '200').toList();

      // Cada publicación cuesta una llamada, así que parar pronto tiene que
      // ahorrarlas: sólo se ha preguntado por la que se ha traído.
      final asked = calls
          .where((url) => url.queryParameters['s'] == 'post')
          .map((url) => url.queryParameters['id']);
      expect(asked, ['300']);
    });

    test('una publicación que ya no está no corta el resto', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(
          favorites: [
            favorite(30, postId: 300),
            favorite(20, postId: 200),
          ],
          missing: {'300'},
        ),
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items.map((item) => item.postId), ['200']);
    });

    test('se recorren todas las páginas del listado', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(
          favorites: [
            for (var i = 250; i >= 1; i--) favorite(i, postId: i),
          ],
          pageSize: 100,
        ),
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items, hasLength(250));
      expect(items.first.postId, '250');
      expect(items.last.postId, '1');
    });

    test('unas credenciales que no valen se cuentan aparte, para poder avisar',
        () async {
      final client = GelbooruApiClient(
        client: MockClient((request) async => http.Response('nope', 401)),
      );

      await expectLater(
        client.favoriteMedia(credentials),
        emitsError(isA<RemoteSessionExpiredException>()
            .having((error) => error.source, 'fuente', ImportSource.gelbooru)),
      );
    });

    test('lo que se traiga lleva la cabecera con la que su servidor lo da',
        () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(favorites: [favorite(30, postId: 300)]),
      );

      final items = await client.favoriteMedia(credentials).toList();

      // Sin esto, su servidor de imágenes devuelve la página de la publicación
      // en lugar del fichero, con código de acierto: la descarga no falla, trae
      // otra cosa.
      expect(items.single.headers['Referer'], 'https://gelbooru.com/');
    });

    test('una publicación que llega en una lista también se lee', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(
          favorites: [favorite(30, postId: 300)],
          singlePostAsList: true,
        ),
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items.single.url, 'https://img3.gelbooru.com/images/300.jpg');
    });

    test('si no llega ninguna publicación, se avisa en vez de acabar vacío',
        () async {
      // Es lo que separa "esta cuenta no tiene favoritos" de "la API ha dejado
      // de contestar como debía": sin esto, las dos cosas se ven igual.
      final client = GelbooruApiClient(
        client: fakeGelbooru(
          favorites: [
            for (var i = 10; i >= 1; i--) favorite(i, postId: i),
          ],
          missing: {for (var i = 1; i <= 10; i++) '$i'},
        ),
      );

      await expectLater(
        client.favoriteMedia(credentials),
        emitsError(isA<Exception>()),
      );
    });

    test('si dice que hay favoritos y no da ninguno, se avisa', () async {
      // Gelbooru ha contestado, dice que la cuenta tiene favoritos y la lista
      // viene vacía: eso no es una cuenta vacía, es una respuesta que no sirve.
      final client = GelbooruApiClient(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              '@attributes': {'count': 120},
              'favorite': const [],
            }),
            200,
          ),
        ),
      );

      await expectLater(
        client.favoriteMedia(credentials),
        emitsError(isA<Exception>()),
      );
    });

    test('una cuenta sin favoritos no da nada, y no falla', () async {
      final client = GelbooruApiClient(
        client: fakeGelbooru(favorites: const []),
      );

      expect(await client.favoriteMedia(credentials).toList(), isEmpty);
    });
  });
}
