// La fuente remota de Pawchive.
//
// Tiene dos formas de recorrerse (las publicaciones marcadas o todo lo de los
// creadores marcados) y una particularidad que no tienen las demás: sus
// favoritos llegan todos de una vez y sin orden garantizado, así que ponerlos
// de lo más reciente a lo más antiguo es cosa suya. Y de cada publicación no
// sólo interesa lo que trae adjunto, sino lo que enlaza.

import 'dart:convert';

import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Una publicación tal y como llega.
Map<String, dynamic> post(
  String id, {
  int? favedSeq,
  String published = '2026-01-01T00:00:00',
  String title = 'Una publicación',
  String? file = '/a3/81/portada.jpeg',
  List<String> attachments = const ['/77/fd/uno.jpeg'],
  String? content,
  String service = 'fanbox',
  String user = '1807835',
}) {
  return {
    'id': id,
    'service': service,
    'user': user,
    'title': title,
    'published': published,
    if (favedSeq != null) 'faved_seq': favedSeq,
    if (content != null) 'content': content,
    if (file != null) 'file': {'name': 'portada.jpeg', 'path': file},
    'attachments': [
      for (final path in attachments) {'name': 'x.jpeg', 'path': path},
    ],
  };
}

/// Un creador marcado.
Map<String, dynamic> creator(String id, {int? favedSeq, String service = 'fanbox'}) =>
    {'id': id, 'service': service, if (favedSeq != null) 'faved_seq': favedSeq};

/// Un Pawchive de mentira.
///
/// [favorites] son las publicaciones marcadas, [creators] los autores marcados
/// y [byCreator] lo que publica cada uno.
http.Client fakePawchive({
  List<Map<String, dynamic>> favorites = const [],
  List<Map<String, dynamic>> creators = const [],
  Map<String, List<Map<String, dynamic>>> byCreator = const {},
  List<Uri>? calls,
}) {
  return MockClient((request) async {
    calls?.add(request.url);

    final path = request.url.path;

    if (path == '/api/v1/account/favorites') {
      final type = request.url.queryParameters['type'];
      return http.Response(
        jsonEncode(type == 'artist' ? creators : favorites),
        200,
      );
    }

    // El detalle de una publicación: `/api/v1/<servicio>/user/<id>/post/<id>`.
    if (path.contains('/post/')) {
      final id = path.split('/post/').last;
      final all = [...favorites, ...byCreator.values.expand((each) => each)];
      final found = all.where((each) => each['id'] == id);

      return http.Response(
        jsonEncode(found.isEmpty ? <String, dynamic>{} : found.first),
        200,
      );
    }

    // El listado de un creador: `/api/v1/<servicio>/user/<id>`.
    final user = path.split('/').last;
    final offset = int.parse(request.url.queryParameters['o'] ?? '0');
    final posts = byCreator[user] ?? const [];

    return http.Response(
      jsonEncode(offset >= posts.length ? [] : posts.sublist(offset)),
      200,
    );
  });
}

const credentials = PawchiveSettingsEntity(sessionId: 'la-sesion');

void main() {
  group('los ajustes', () {
    test('sin sesión no hay nada que pedir', () {
      expect(credentials.isComplete, isTrue);
      expect(const PawchiveSettingsEntity().isComplete, isFalse);
    });

    test('de partida se van a buscar las publicaciones marcadas', () {
      expect(credentials.byFavoriteCreators, isFalse);
      expect(
        credentials.copyWith(byFavoriteCreators: true).byFavoriteCreators,
        isTrue,
      );
    });
  });

  group('las publicaciones marcadas', () {
    test('se piden con la galleta de la cuenta', () async {
      final calls = <Uri>[];
      final client = PawchiveApiClient(
        client: fakePawchive(favorites: [post('1', content: '')], calls: calls),
      );

      await client.favoritePosts(credentials).toList();

      expect(calls.first.path, '/api/v1/account/favorites');
      expect(calls.first.queryParameters['type'], 'post');
    });

    test('salen de la más reciente a la más antigua, aunque lleguen revueltas',
        () async {
      final client = PawchiveApiClient(
        client: fakePawchive(favorites: [
          post('1', favedSeq: 10, content: ''),
          post('3', favedSeq: 30, content: ''),
          post('2', favedSeq: 20, content: ''),
        ]),
      );

      final posts = await client.favoritePosts(credentials).toList();

      expect(posts.map((each) => each.id), ['3', '2', '1']);
    });

    test('una publicación trae sus ficheros, sin repetir la portada', () async {
      final client = PawchiveApiClient(
        client: fakePawchive(favorites: [
          post(
            '7',
            content: '',
            file: '/a/uno.jpeg',
            attachments: const ['/a/uno.jpeg', '/b/dos.png'],
          ),
        ]),
      );

      final posts = await client.favoritePosts(credentials).toList();

      expect(posts.single.media.map((item) => item.url), [
        'https://file.pawchive.pw/data/a/uno.jpeg',
        'https://file.pawchive.pw/data/b/dos.png',
      ]);
      expect(posts.single.sourceUrls, [
        'https://pawchive.pw/fanbox/user/1807835',
        'https://pawchive.pw/fanbox/user/1807835/post/7',
      ]);
    });

    test('y trae sus enlaces, ya clasificados', () async {
      final client = PawchiveApiClient(
        client: fakePawchive(favorites: [
          post('7', content: '''
            <p>Aquí está la entrega:</p>
            <a href="https://cdn.algo.test/entrega.zip">el zip</a>
            <a href="https://cdn.algo.test/extra.png">una imagen</a>
            <a href="https://mega.nz/folder/abc">en Mega</a>
            <a href="https://www.fanbox.cc/@alguien">mi Fanbox</a>
          '''),
        ]),
      );

      final posts = await client.favoritePosts(credentials).toList();

      expect(
        posts.single.links.map((link) => link.kind),
        [
          PostLinkKind.archive,
          PostLinkKind.media,
          PostLinkKind.repositoryFolder,
          // La plataforma de pago no da el contenido: se queda fuera.
          PostLinkKind.other,
        ],
      );
      expect(posts.single.downloadableLinks, hasLength(2));
      expect(posts.single.linksNeedingUser, hasLength(1));
    });

    test('se pide el cuerpo sólo cuando el listado no lo trae', () async {
      final calls = <Uri>[];
      final client = PawchiveApiClient(
        client: fakePawchive(
          favorites: [post('1', content: '<p>ya viene</p>'), post('2')],
          calls: calls,
        ),
      );

      await client.favoritePosts(credentials).toList();

      final detalles = calls.where((url) => url.path.contains('/post/'));
      expect(detalles.map((url) => url.path.split('/post/').last), ['2']);
    });

    test('se para donde se quedó la vez anterior', () async {
      final client = PawchiveApiClient(
        client: fakePawchive(favorites: [
          post('1', favedSeq: 10, content: ''),
          post('2', favedSeq: 20, content: ''),
          post('3', favedSeq: 30, content: ''),
        ]),
      );

      final posts =
          await client.favoritePosts(credentials, stopAt: '2').toList();

      expect(posts.map((each) => each.id), ['3']);
    });
  });

  group('los creadores marcados', () {
    test('se recorre lo de cada uno, y cada publicación dice de quién viene',
        () async {
      final client = PawchiveApiClient(
        client: fakePawchive(
          creators: [creator('100', favedSeq: 1), creator('200', favedSeq: 2)],
          byCreator: {
            '100': [post('11', user: '100', content: '')],
            '200': [post('22', user: '200', content: '')],
          },
        ),
      );

      final posts = await client.creatorPosts(credentials).toList();

      expect(
        {for (final each in posts) each.id: each.collection},
        {'22': 'fanbox-200', '11': 'fanbox-100'},
      );
    });

    test('la marca de un autor no para el recorrido de otro', () async {
      final client = PawchiveApiClient(
        client: fakePawchive(
          creators: [creator('100', favedSeq: 2), creator('200', favedSeq: 1)],
          byCreator: {
            '100': [
              post('11', user: '100', content: ''),
              post('12', user: '100', content: ''),
            ],
            '200': [
              post('21', user: '200', content: ''),
              post('22', user: '200', content: ''),
            ],
          },
        ),
      );

      final posts = await client.creatorPosts(
        credentials,
        stopAt: {'fanbox-100': '12', 'fanbox-200': '22'},
      ).toList();

      expect(posts.map((each) => each.id), ['11', '21']);
    });
  });

  test('una sesión que ya no vale se cuenta aparte, para poder avisar',
      () async {
    final client = PawchiveApiClient(
      client: MockClient((request) async => http.Response('{}', 401)),
    );

    await expectLater(
      client.favoritePosts(credentials),
      emitsError(isA<RemoteSessionExpiredException>()
          .having((error) => error.source, 'fuente', ImportSource.pawchive)),
    );
  });
}
