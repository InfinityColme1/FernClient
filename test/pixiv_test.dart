// La fuente remota de Pixiv.
//
// Dos piezas de las que depende todo lo demás: que de la cookie de sesión se
// saque la cuenta (es lo único que el usuario configura, y sin ella no se sabe
// ni a quién pedirle los marcadores) y que el recorrido de los marcadores
// devuelva lo que hay, se salte lo que no se puede descargar y pare donde se
// quedó la vez anterior.

import 'dart:convert';

import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/settings/domain/entities/pixiv_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Una obra tal y como llega en el listado de marcadores.
Map<String, dynamic> work(
  String id, {
  String author = '999',
  int illustType = 0,
  bool isMasked = false,
}) {
  return {
    'id': id,
    'title': 'Obra $id',
    'userId': author,
    'illustType': illustType,
    'isMasked': isMasked,
  };
}

/// Un Pixiv de mentira: responde a los dos sitios a los que se le pregunta, el
/// listado de marcadores de cada visibilidad y las páginas de cada obra.
///
/// [bookmarks] son las obras de cada listado (`show` y `hide`), ya en el orden
/// en el que Pixiv las devolvería: de lo más nuevo a lo más antiguo.
http.Client fakePixiv({
  required Map<String, List<Map<String, dynamic>>> bookmarks,
  List<Uri>? calls,
}) {
  return MockClient((request) async {
    calls?.add(request.url);

    final path = request.url.path;

    if (path.endsWith('/illusts/bookmarks')) {
      final rest = request.url.queryParameters['rest'];
      final offset = int.parse(request.url.queryParameters['offset'] ?? '0');
      final works = bookmarks[rest] ?? const [];

      return http.Response(
        jsonEncode({
          'error': false,
          'body': {
            'works': offset >= works.length ? [] : works.sublist(offset),
            'total': works.length,
          },
        }),
        200,
      );
    }

    final id = path.split('/')[3];

    // Una animación no tiene páginas: tiene un paquete de fotogramas y lo que
    // dura cada uno.
    if (path.endsWith('/ugoira_meta')) {
      return http.Response(
        jsonEncode({
          'error': false,
          'body': {
            'originalSrc': 'https://i.pximg.net/img-zip/${id}_ugoira.zip',
            'src': 'https://i.pximg.net/img-zip/${id}_small.zip',
            'frames': [
              {'file': '000000.jpg', 'delay': 120},
              {'file': '000001.jpg', 'delay': 80},
            ],
          },
        }),
        200,
      );
    }

    // Cada obra tiene dos páginas, para que se vea que una obra puede dar más
    // de un fichero.
    return http.Response(
      jsonEncode({
        'error': false,
        'body': [
          for (var page = 0; page < 2; page++)
            {
              'urls': {
                'original': 'https://i.pximg.net/img-original/${id}_p$page.png',
              },
            },
        ],
      }),
      200,
    );
  });
}

const credentials = PixivSettingsEntity(sessionId: '1234567_abcdefghij');

void main() {
  group('la cuenta sale de la cookie', () {
    test('es lo que va antes del guión', () {
      expect(credentials.userId, '1234567');
      expect(credentials.isComplete, isTrue);
    });

    test('los espacios de un pegado no estorban', () {
      const pasted = PixivSettingsEntity(sessionId: '  42_zzz  ');
      expect(pasted.userId, '42');
    });

    test('lo que no tiene esa forma no vale', () {
      for (final value in ['', '   ', 'abcdefghij', '_abc', 'abc_123']) {
        final settings = PixivSettingsEntity(sessionId: value);
        expect(settings.userId, isNull, reason: value);
        expect(settings.isComplete, isFalse, reason: value);
      }
    });
  });

  group('los marcadores', () {
    test('cada obra da un fichero por página, con su origen y su cabecera',
        () async {
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: {
          'show': [work('111')],
          'hide': const [],
        }),
      );

      final items = await client.bookmarkedMedia(credentials).toList();

      expect(items, hasLength(2));
      expect(items.map((item) => item.id), ['999_111_p0', '999_111_p1']);
      expect(items.first.url, 'https://i.pximg.net/img-original/111_p0.png');
      // Las dos páginas son la misma obra: es lo que marca por dónde se quedó
      // la importación.
      expect(items.map((item) => item.postId), everyElement('111'));
      expect(items.first.sourceUrls, [
        'https://www.pixiv.net/users/999',
        'https://www.pixiv.net/artworks/111',
      ]);
      // Sin esto su servidor de contenidos no da la imagen.
      expect(items.first.headers['Referer'], 'https://www.pixiv.net/');
    });

    test('salen los dos listados, y cada obra dice de cuál viene', () async {
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: {
          'show': [work('111')],
          'hide': [work('222')],
        }),
      );

      final items = await client.bookmarkedMedia(credentials).toList();

      expect(
        {for (final item in items) item.postId: item.collection},
        {'111': 'show', '222': 'hide'},
      );
    });

    test('lo que no se puede descargar no sale', () async {
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: {
          'show': [
            // Una obra que la cuenta ya no puede ver.
            work('222', isMasked: true),
            work('333'),
          ],
          'hide': const [],
        }),
      );

      final items = await client.bookmarkedMedia(credentials).toList();

      expect(items.map((item) => item.postId).toSet(), {'333'});
    });

    test('una animación sale como su paquete de fotogramas', () async {
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: {
          'show': [work('111', illustType: 2)],
          'hide': const [],
        }),
      );

      final items = await client.bookmarkedMedia(credentials).toList();

      // Una sola pieza, no una por página: la animación es un fichero cuando
      // esté montada.
      expect(items, hasLength(1));
      expect(items.single.id, '999_111');
      expect(items.single.url, 'https://i.pximg.net/img-zip/111_ugoira.zip');
      // Con esto sabe quien descarga que lo que hay detrás no es un fichero.
      expect(items.single.frameDelays, [120, 80]);
    });

    test('se para donde se quedó la vez anterior, listado por listado',
        () async {
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: {
          'show': [work('111'), work('222'), work('333')],
          'hide': [work('444'), work('555')],
        }),
      );

      final items = await client.bookmarkedMedia(
        credentials,
        stopAt: {'show': '222', 'hide': '555'},
      ).toList();

      // De la marca para atrás ya se miró, y la marca de un listado no para el
      // otro: el privado llega hasta la suya, no hasta la del público.
      expect(
        items.map((item) => item.postId).toSet(),
        {'111', '444'},
      );
    });

    test('una cookie sin cuenta no llega a pedir nada', () async {
      final calls = <Uri>[];
      final client = PixivApiClient(
        client: fakePixiv(bookmarks: const {}, calls: calls),
      );

      await expectLater(
        client.bookmarkedMedia(const PixivSettingsEntity(sessionId: 'nada')),
        emitsError(isA<Exception>()),
      );
      expect(calls, isEmpty);
    });

    test('una sesión que ya no vale se cuenta aparte, no como un fallo más',
        () async {
      // Cuando la cookie caduca, Pixiv devuelve su página de inicio de sesión
      // con un código de acierto: parece que ha ido bien y no lo ha hecho. Se
      // distingue del resto de fallos porque la salida es otra: que el usuario
      // vuelva a entrar en su cuenta.
      final client = PixivApiClient(
        client: MockClient(
          (request) async => http.Response('<!DOCTYPE html>', 200),
        ),
      );

      await expectLater(
        client.bookmarkedMedia(credentials),
        emitsError(isA<RemoteSessionExpiredException>()
            .having((error) => error.source, 'fuente', ImportSource.pixiv)),
      );
    });

    test('y también cuando Pixiv contesta que no hay permiso', () async {
      final client = PixivApiClient(
        client: MockClient((request) async => http.Response('nope', 403)),
      );

      await expectLater(
        client.bookmarkedMedia(credentials),
        emitsError(isA<RemoteSessionExpiredException>()),
      );
    });
  });
}
