// Las direcciones con las que una etiqueta reconoce de dónde viene un contenido.
//
// Es la pieza de la que depende el etiquetado automático, y lo que más importa
// aquí es lo que **no** debe recoger: una regla no puede llevarse contenido de
// otra comunidad por empezar igual, ni de otro sitio por acabar igual.

import 'package:Fern/core/utils/source_url.dart';
import 'package:flutter_test/flutter_test.dart';

/// Si la regla [rule] recoge la dirección [url], las dos tal y como se
/// escribirían a mano.
bool covers(String rule, String url) => sourceUrlMatches(
      normalizedSourceUrl(url),
      normalizedSourceUrl(rule),
    );

void main() {
  group('normalización', () {
    test('se quita lo que dice cómo se pidió el enlace, no a qué apunta', () {
      const expected = 'reddit.com/r/gifs';

      for (final url in [
        'https://www.reddit.com/r/gifs',
        'http://reddit.com/r/gifs/',
        'REDDIT.COM/R/GIFS',
        'https://www.reddit.com/r/gifs/?utm_source=share',
        'https://reddit.com/r/gifs#top',
      ]) {
        expect(normalizedSourceUrl(url), expected, reason: url);
      }
    });

    test('lo que no sirve como enlace se queda en nada', () {
      expect(normalizedSourceUrl(''), '');
      expect(normalizedSourceUrl('   '), '');
    });

    test('se quitan las repetidas conservando el orden en el que se escribieron',
        () {
      expect(
        normalizedSourceUrls([
          'https://www.reddit.com/r/gifs',
          '  ',
          'reddit.com/r/gifs/',
          'https://pixiv.net/users/123',
        ]),
        ['reddit.com/r/gifs', 'pixiv.net/users/123'],
      );
    });
  });

  group('qué recoge una regla', () {
    test('una comunidad recoge sus publicaciones', () {
      expect(
        covers(
          'https://www.reddit.com/r/gifs',
          'https://www.reddit.com/r/gifs/comments/abc123/un_titulo/',
        ),
        isTrue,
      );
    });

    test('y a sí misma', () {
      expect(covers('reddit.com/r/gifs', 'https://reddit.com/r/gifs/'), isTrue);
    });

    // Lo importante: la comparación es por tramos de la ruta, no por texto.
    test('no recoge otra comunidad que empieza igual', () {
      expect(covers('reddit.com/r/gifs', 'reddit.com/r/gifsdegatos'), isFalse);
    });

    test('no recoge otro sitio que acaba igual', () {
      expect(covers('reddit.com', 'noreddit.com/r/gifs'), isFalse);
    });

    test('una regla que es sólo el sitio recoge todo lo suyo', () {
      expect(covers('reddit.com', 'https://www.reddit.com/user/alguien'), isTrue);
    });

    test('una regla vacía no recoge nada', () {
      expect(covers('', 'reddit.com/r/gifs'), isFalse);
    });

    test('vale igual para una plataforma sin API', () {
      expect(
        covers('pixiv.net/users/123', 'https://www.pixiv.net/users/123/artworks'),
        isTrue,
      );
      expect(covers('pixiv.net/users/123', 'pixiv.net/users/1234'), isFalse);
    });
  });
}
