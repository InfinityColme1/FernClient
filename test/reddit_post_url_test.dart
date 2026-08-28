import 'package:Fern/features/media/domain/services/reddit_post_url.dart';
import 'package:flutter_test/flutter_test.dart';

/// De donde sale el fichero de una publicacion de Reddit.
///
/// El caso que importa es el de la copia muda: Reddit se hace una de todo lo que
/// se enlaza desde fuera, y esa copia no tiene sonido nunca. Si gana ella, la
/// biblioteca se llena de videos mudos sin que nada falle.
void main() {
  group('un enlace a un sitio conocido', () {
    test('gana a la copia que Reddit se hace de el', () {
      final url = redditPostUrl({
        'url': 'https://www.redgifs.com/watch/algo',
        'preview': {
          'reddit_video_preview': {
            'fallback_url': 'https://v.redd.it/abc/DASH_480.mp4',
          },
        },
      });

      expect(url, 'https://www.redgifs.com/watch/algo');
    });

    test('y tambien cuando viene en url_overridden_by_dest', () {
      final url = redditPostUrl({
        'url': 'https://www.reddit.com/r/algo/comments/x/',
        'url_overridden_by_dest': 'https://www.redgifs.com/watch/algo',
        'preview': {
          'reddit_video_preview': {
            'fallback_url': 'https://v.redd.it/abc/DASH_480.mp4',
          },
        },
      });

      expect(url, 'https://www.redgifs.com/watch/algo');
    });
  });

  group('la copia de Reddit', () {
    test('se usa si el enlace lleva a un sitio al que no se va', () {
      // Sin forma de llegar al original, algo mudo es mejor que nada.
      final url = redditPostUrl({
        'url': 'https://un-sitio-cualquiera.com/algo',
        'preview': {
          'reddit_video_preview': {
            'fallback_url': 'https://v.redd.it/abc/DASH_480.mp4',
          },
        },
      });

      expect(url, 'https://v.redd.it/abc/DASH_480.mp4');
    });
  });

  group('lo que aloja Reddit', () {
    test('va por delante de todo lo demas', () {
      final url = redditPostUrl({
        'url': 'https://v.redd.it/abc',
        'media': {
          'reddit_video': {'fallback_url': 'https://v.redd.it/abc/DASH_1080.mp4'},
        },
      });

      expect(url, 'https://v.redd.it/abc/DASH_1080.mp4');
    });

    test('y vale igual si viene por la version segura', () {
      final url = redditPostUrl({
        'url': 'https://v.redd.it/abc',
        'secure_media': {
          'reddit_video': {'fallback_url': 'https://v.redd.it/abc/DASH_720.mp4'},
        },
      });

      expect(url, 'https://v.redd.it/abc/DASH_720.mp4');
    });
  });

  group('lo que no lleva a ninguna parte', () {
    test('una publicacion de texto no da nada', () {
      expect(redditPostUrl({'is_self': true, 'url': 'https://x.com/a'}), isNull);
    });

    test('y una direccion que no es https tampoco', () {
      expect(redditPostUrl({'url': 'http://x.com/a.jpg'}), isNull);
    });
  });

  group('los sitios a los que se va a buscar', () {
    test('valen el dominio y sus subdominios', () {
      expect(isExternalMediaUrl('https://redgifs.com/watch/algo'), isTrue);
      expect(isExternalMediaUrl('https://www.redgifs.com/watch/algo'), isTrue);
    });

    test('pero no uno que solo acabe pareciendose', () {
      expect(isExternalMediaUrl('https://noredgifs.com/watch/algo'), isFalse);
    });
  });
}
