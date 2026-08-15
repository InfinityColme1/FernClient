// La fuente remota de Danbooru.
//
// Es la más sencilla de las tres, y justo por eso lo que hay que comprobar está
// en los bordes: que se pida el listado que devuelve los favoritos en el orden
// en el que se marcaron (y no en otro), que se entre con la clave del usuario,
// que lo que la plataforma no da se salte, y que se pare donde se quedó la vez
// anterior.

import 'dart:convert';

import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Una publicación tal y como llega en el listado.
Map<String, dynamic> post(
  int id, {
  String? fileUrl,
  String fileExt = 'jpg',
  String? largeFileUrl,
  String artists = 'algun_autor',
  String source = '',
}) {
  return {
    'id': id,
    'file_ext': fileExt,
    if (fileUrl != null) 'file_url': fileUrl,
    if (largeFileUrl != null) 'large_file_url': largeFileUrl,
    'tag_string_artist': artists,
    'source': source,
  };
}

/// Un Danbooru de mentira: devuelve las publicaciones que se le den, repartidas
/// en páginas del tamaño que se le diga.
http.Client fakeDanbooru(
  List<Map<String, dynamic>> posts, {
  List<http.Request>? calls,
  int pageSize = 200,
}) {
  return MockClient((request) async {
    calls?.add(request);

    final page = int.parse(request.url.queryParameters['page'] ?? '1');
    final from = (page - 1) * pageSize;

    final slice = from >= posts.length
        ? const <Map<String, dynamic>>[]
        : posts.sublist(from, (from + pageSize).clamp(0, posts.length));

    return http.Response(jsonEncode(slice), 200);
  });
}

const credentials = DanbooruSettingsEntity(
  username: 'usuaria',
  apiKey: 'clave-secreta',
);

void main() {
  group('las credenciales', () {
    test('hacen falta las dos', () {
      expect(credentials.isComplete, isTrue);
      expect(
        const DanbooruSettingsEntity(username: 'usuaria').isComplete,
        isFalse,
      );
      expect(
        const DanbooruSettingsEntity(apiKey: 'clave').isComplete,
        isFalse,
      );
      expect(
        const DanbooruSettingsEntity(username: '  ', apiKey: 'clave')
            .isComplete,
        isFalse,
      );
    });
  });

  group('los favoritos', () {
    test('se piden en el orden en el que se marcaron, y con la clave',
        () async {
      final calls = <http.Request>[];
      final client = DanbooruApiClient(
        client: fakeDanbooru(
          [post(111, fileUrl: 'https://cdn.donmai.us/original/a.jpg')],
          calls: calls,
        ),
        pageDelay: Duration.zero,
      );

      await client.favoriteMedia(credentials).toList();

      // `ordfav:` es lo único que los da del más reciente al más antiguo, que es
      // lo que hace posible parar donde se quedó la importación anterior.
      expect(calls.single.url.queryParameters['tags'], 'ordfav:usuaria');
      expect(
        calls.single.headers['Authorization'],
        'Basic ${base64Encode(utf8.encode('usuaria:clave-secreta'))}',
      );
    });

    test('cada publicación da un fichero, con su origen', () async {
      final client = DanbooruApiClient(
        client: fakeDanbooru([
          post(
            111,
            fileUrl: 'https://cdn.donmai.us/original/a.jpg',
            artists: 'autora',
            source: 'https://www.pixiv.net/artworks/999',
          ),
        ]),
        pageDelay: Duration.zero,
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items, hasLength(1));
      expect(items.single.id, 'danbooru_111');
      expect(items.single.url, 'https://cdn.donmai.us/original/a.jpg');
      expect(items.single.postId, '111');
      // De lo más general a lo más concreto, y con el sitio del que salió por
      // medio: cualquiera de las tres puede estar vinculada a una etiqueta.
      expect(items.single.sourceUrls, [
        'https://danbooru.donmai.us/posts?tags=autora',
        'https://www.pixiv.net/artworks/999',
        'https://danbooru.donmai.us/posts/111',
      ]);
    });

    test('lo que la plataforma no da se salta', () async {
      final client = DanbooruApiClient(
        client: fakeDanbooru([
          // Borrada, o sólo para cuentas de pago: sale en el listado sin nada
          // detrás.
          post(111),
          post(222, fileUrl: 'https://cdn.donmai.us/original/b.png'),
        ]),
        pageDelay: Duration.zero,
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items.map((item) => item.postId), ['222']);
    });

    test('una animación se coge de su versión en vídeo', () async {
      final client = DanbooruApiClient(
        client: fakeDanbooru([
          post(
            111,
            fileExt: 'zip',
            fileUrl: 'https://cdn.donmai.us/original/a.zip',
            largeFileUrl: 'https://cdn.donmai.us/sample/a.webm',
          ),
        ]),
        pageDelay: Duration.zero,
      );

      final items = await client.favoriteMedia(credentials).toList();

      expect(items.single.url, 'https://cdn.donmai.us/sample/a.webm');
    });

    test('se recorren las páginas hasta que se acaban', () async {
      final calls = <http.Request>[];
      final client = DanbooruApiClient(
        client: fakeDanbooru(
          [
            for (var id = 1; id <= 250; id++)
              post(id, fileUrl: 'https://cdn.donmai.us/original/$id.jpg'),
          ],
          calls: calls,
        ),
        pageDelay: Duration.zero,
      );

      final items = await client.favoriteMedia(credentials).toList();

      // La primera página viene llena (doscientos, que es su máximo), así que se
      // pide otra; la segunda no, y ahí se acaba.
      expect(items, hasLength(250));
      expect(calls.map((call) => call.url.queryParameters['page']), ['1', '2']);
    });

    test('se para donde se quedó la vez anterior', () async {
      final client = DanbooruApiClient(
        client: fakeDanbooru([
          for (var id = 1; id <= 5; id++)
            post(id, fileUrl: 'https://cdn.donmai.us/original/$id.jpg'),
        ]),
        pageDelay: Duration.zero,
      );

      final items =
          await client.favoriteMedia(credentials, stopAt: '3').toList();

      expect(items.map((item) => item.postId), ['1', '2']);
    });

    test('unas credenciales que no valen se cuentan aparte, para poder avisar',
        () async {
      final client = DanbooruApiClient(
        client: MockClient((request) async => http.Response('nope', 401)),
        pageDelay: Duration.zero,
      );

      await expectLater(
        client.favoriteMedia(credentials),
        emitsError(isA<RemoteSessionExpiredException>()
            .having((error) => error.source, 'fuente', ImportSource.danbooru)),
      );
    });

    test('una respuesta que no es el listado tampoco pasa por vacía', () async {
      // Cuando la búsqueda no vale, Danbooru contesta con un objeto que lo
      // explica en lugar de con la lista de siempre.
      final client = DanbooruApiClient(
        client: MockClient(
          (request) async => http.Response('{"message":"nope"}', 200),
        ),
        pageDelay: Duration.zero,
      );

      await expectLater(
        client.favoriteMedia(credentials),
        emitsError(isA<Exception>()),
      );
    });
  });
}
