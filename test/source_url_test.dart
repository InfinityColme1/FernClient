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

  // El fallo que dejaba el etiquetado automático inservible en las plataformas
  // que identifican una galería con lo que va detrás del `?`: se tiraba todo,
  // así que **todas** las publicaciones de Danbooru se guardaban como
  // `danbooru.donmai.us/posts`. No es que una regla por artista no encontrara
  // nada: es que se los llevaba a todos.
  group('las galerías que viven detrás del interrogante', () {
    test('dos artistas de Danbooru no son la misma dirección', () {
      expect(
        normalizedSourceUrl('https://danbooru.donmai.us/posts?tags=uno'),
        isNot(normalizedSourceUrl('https://danbooru.donmai.us/posts?tags=otro')),
      );
    });

    test('la regla de un artista recoge lo suyo', () {
      expect(
        covers(
          'danbooru.donmai.us/posts?tags=uno',
          'https://danbooru.donmai.us/posts?tags=uno',
        ),
        isTrue,
      );
    });

    test('y no lo del otro', () {
      expect(
        covers(
          'danbooru.donmai.us/posts?tags=uno',
          'https://danbooru.donmai.us/posts?tags=otro',
        ),
        isFalse,
      );
    });

    test('dos publicaciones de Gelbooru tampoco', () {
      expect(
        normalizedSourceUrl(
          'https://gelbooru.com/index.php?page=post&s=view&id=1',
        ),
        isNot(normalizedSourceUrl(
          'https://gelbooru.com/index.php?page=post&s=view&id=2',
        )),
      );
    });

    // Escritos en distinto orden son el mismo enlace, y hay que compararlos
    // igual: los ordena la normalización.
    test('el orden de los parámetros no cambia la dirección', () {
      expect(
        normalizedSourceUrl('gelbooru.com/index.php?s=view&page=post&id=7'),
        normalizedSourceUrl('gelbooru.com/index.php?page=post&id=7&s=view'),
      );
    });

    test('lo de seguimiento se sigue tirando', () {
      expect(
        normalizedSourceUrl(
          'https://danbooru.donmai.us/posts?tags=uno&utm_campaign=x&fbclid=y',
        ),
        'danbooru.donmai.us/posts?tags=uno',
      );
    });

    // Una regla sin parámetros manda por ruta, lleve la dirección los que
    // lleve: es lo que recoge un sitio entero.
    test('una regla sin parámetros recoge lo que cuelgue de ella', () {
      expect(
        covers('danbooru.donmai.us', 'https://danbooru.donmai.us/posts?tags=x'),
        isTrue,
      );
      expect(
        covers(
          'danbooru.donmai.us/posts',
          'https://danbooru.donmai.us/posts?tags=x',
        ),
        isTrue,
      );
    });
  });

  // Lo que genera cada cliente al importar, tal cual, contra lo que el usuario
  // escribiría a mano. Es la comprobación que pedía la ficha del item 14.
  group('las seis fuentes', () {
    test('Reddit: la comunidad recoge su publicación', () {
      expect(
        covers(
          'reddit.com/r/gifs',
          'https://www.reddit.com/r/gifs/comments/abc123/un_titulo/',
        ),
        isTrue,
      );
    });

    test('Pixiv: el autor recoge su ilustración', () {
      expect(
        covers('pixiv.net/users/123', 'https://www.pixiv.net/users/123/artworks'),
        isTrue,
      );
    });

    test('Pinterest: el tablero recoge su pin', () {
      expect(
        covers('pinterest.com/alguien/tablero',
            'https://www.pinterest.com/alguien/tablero/'),
        isTrue,
      );
    });

    test('Pawchive: el creador recoge su publicación', () {
      expect(
        covers('pawchive.com/creadora', 'https://pawchive.com/creadora/post/9'),
        isTrue,
      );
    });

    test('Danbooru: la publicación cae bajo el sitio', () {
      expect(
        covers('danbooru.donmai.us', 'https://danbooru.donmai.us/posts/12345'),
        isTrue,
      );
    });

    test('Gelbooru: una publicación no recoge a otra', () {
      expect(
        covers(
          'gelbooru.com/index.php?id=1&page=post&s=view',
          'https://gelbooru.com/index.php?page=post&s=view&id=2',
        ),
        isFalse,
      );
    });
  });
}

