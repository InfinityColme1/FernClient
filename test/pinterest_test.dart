// La fuente remota de Pinterest.
//
// Lo que hay que sostener aquí es lo que costó averiguar: su API sólo contesta
// si la petición se identifica como su propia web, las páginas se piden con una
// marca que ella devuelve (y no con un número), y un pin puede ser una imagen,
// un vídeo o nada que se pueda descargar.

import 'dart:convert';

import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Un pin tal y como llega en el listado de lo guardado.
Map<String, dynamic> pin(
  String id, {
  String? image = 'https://i.pinimg.com/originals/a.jpg',
  Map<String, dynamic>? videos,
  String title = 'Un pin',
  String board = '/usuaria/tablero/',
  String link = '',
}) {
  return {
    'id': id,
    'grid_title': title,
    'board': {'url': board},
    'link': link,
    if (image != null)
      'images': {
        'orig': {'url': image, 'width': 800, 'height': 600},
      },
    if (videos != null) 'videos': videos,
  };
}

/// Un Pinterest de mentira: reparte los pines en páginas y va dando la marca de
/// la siguiente, como hace el de verdad.
http.Client fakePinterest(
  List<List<Map<String, dynamic>>> pages, {
  List<http.Request>? calls,
}) {
  return MockClient((request) async {
    calls?.add(request);

    final data = jsonDecode(request.url.queryParameters['data'] ?? '{}');
    final options = (data as Map<String, dynamic>)['options'] as Map<String, dynamic>;
    final bookmarks = options['bookmarks'] as List<dynamic>?;

    final index = bookmarks == null ? 0 : int.parse('${bookmarks.first}');
    final isLast = index >= pages.length - 1;

    return http.Response(
      jsonEncode({
        'resource_response': {'status': 'success', 'data': pages[index]},
        'resource': {
          'options': {
            'bookmarks': [isLast ? '-end-' : '${index + 1}'],
          },
        },
      }),
      200,
    );
  });
}

const credentials = PinterestSettingsEntity(username: 'usuaria');

void main() {
  group('la cuenta', () {
    test('con el nombre basta, y la sesión es un extra', () {
      expect(credentials.isComplete, isTrue);
      expect(credentials.hasSession, isFalse);
      expect(const PinterestSettingsEntity().isComplete, isFalse);
      expect(
        const PinterestSettingsEntity(username: 'usuaria', sessionId: 'abc')
            .hasSession,
        isTrue,
      );
    });
  });

  group('lo guardado', () {
    test('se pide identificándose como su propia web', () async {
      final calls = <http.Request>[];
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111')],
        ], calls: calls),
      );

      await client.savedMedia(credentials).toList();

      final headers = calls.single.headers;
      // Sin estas dos, Pinterest responde que la petición no vale, dé igual lo
      // demás que se le mande.
      expect(headers['X-Pinterest-PWS-Handler'], isNotNull);
      expect(headers['X-Pinterest-Source-Url'], '/usuaria/_saved/');
      // Su protección contra peticiones de terceros se cumple mandando el mismo
      // valor en la galleta y en la cabecera.
      expect(
        headers['Cookie'],
        contains('csrftoken=${headers['X-CSRFToken']}'),
      );
    });

    test('sin sesión sólo se pide lo que se ve desde fuera', () async {
      final calls = <http.Request>[];
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111')],
        ], calls: calls),
      );

      await client.savedMedia(credentials).toList();

      final data = jsonDecode(calls.single.url.queryParameters['data']!);
      final options = (data as Map<String, dynamic>)['options'];
      expect((options as Map<String, dynamic>)['is_own_profile_pins'], isFalse);
      expect(calls.single.headers['Cookie'], isNot(contains('_pinterest_sess')));
    });

    test('con sesión se piden también los tableros secretos', () async {
      final calls = <http.Request>[];
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111')],
        ], calls: calls),
      );

      await client
          .savedMedia(const PinterestSettingsEntity(
            username: 'usuaria',
            sessionId: 'la-sesion',
          ))
          .toList();

      final data = jsonDecode(calls.single.url.queryParameters['data']!);
      final options =
          (data as Map<String, dynamic>)['options'] as Map<String, dynamic>;
      expect(options['is_own_profile_pins'], isTrue);
      expect(
        calls.single.headers['Cookie'],
        contains('_pinterest_sess=la-sesion'),
      );
    });

    test('cada pin da su fichero, con su origen', () async {
      final client = PinterestApiClient(
        client: fakePinterest([
          [
            pin(
              '111',
              image: 'https://i.pinimg.com/originals/uno.jpg',
              link: 'https://www.deviantart.com/algo',
            ),
          ],
        ]),
      );

      final items = await client.savedMedia(credentials).toList();

      expect(items.single.id, 'pinterest_111');
      expect(items.single.url, 'https://i.pinimg.com/originals/uno.jpg');
      expect(items.single.title, 'Un pin');
      expect(items.single.sourceUrls, [
        'https://www.pinterest.com/usuaria/tablero/',
        'https://www.deviantart.com/algo',
        'https://www.pinterest.com/pin/111/',
      ]);
    });

    test('de un vídeo se coge la mejor calidad que sea un fichero', () async {
      final client = PinterestApiClient(
        client: fakePinterest([
          [
            pin('111', image: 'https://i.pinimg.com/originals/miniatura.jpg',
                videos: {
                  'video_list': {
                    'V_720P': {
                      'url': 'https://v.pinimg.com/720.mp4',
                      'width': 720,
                    },
                    'V_HLSV4': {
                      'url': 'https://v.pinimg.com/lista.m3u8',
                      'width': 1080,
                    },
                    'V_480P': {
                      'url': 'https://v.pinimg.com/480.mp4',
                      'width': 480,
                    },
                  },
                }),
          ],
        ]),
      );

      final items = await client.savedMedia(credentials).toList();

      // La lista de trozos no es un fichero que se pueda guardar, aunque sea la
      // de más resolución.
      expect(items.single.url, 'https://v.pinimg.com/720.mp4');
    });

    test('un pin sin nada que descargar se queda fuera', () async {
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111', image: null), pin('222')],
        ]),
      );

      final items = await client.savedMedia(credentials).toList();

      expect(items.map((item) => item.postId), ['222']);
    });

    test('se recorren las páginas hasta que dice que no queda nada', () async {
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111'), pin('222')],
          [pin('333')],
        ]),
      );

      final items = await client.savedMedia(credentials).toList();

      expect(items.map((item) => item.postId), ['111', '222', '333']);
    });

    test('se para donde se quedó la vez anterior', () async {
      final client = PinterestApiClient(
        client: fakePinterest([
          [pin('111'), pin('222')],
          [pin('333')],
        ]),
      );

      final items =
          await client.savedMedia(credentials, stopAt: '222').toList();

      expect(items.map((item) => item.postId), ['111']);
    });

    test('una sesión que Pinterest rechaza se cuenta aparte, para poder avisar',
        () async {
      final client = PinterestApiClient(
        client: MockClient((request) async => http.Response('nope', 403)),
      );

      await expectLater(
        client.savedMedia(credentials),
        emitsError(isA<RemoteSessionExpiredException>()
            .having((error) => error.source, 'fuente', ImportSource.pinterest)),
      );
    });
  });
}
