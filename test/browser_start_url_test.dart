// Que el navegador no arranque en blanco.
//
// El fallo («a veces no muestra ninguna página») no está identificado, así que
// esto no lo arregla entero: descarta la sospecha que se puede descartar sin
// reproducirlo —que la dirección guardada de la última vez no sea una página— y
// fija qué hacer cuando una carga se cae, que es volver a un sitio conocido en
// vez de quedarse mirando el vacío.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/browser/domain/services/browser_start_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('qué dirección puede enseñar algo', () {
    test('una página de la web', () {
      expect(isBrowsableUrl('https://www.pixiv.net/'), isTrue);
      expect(isBrowsableUrl('http://localhost:8080/algo'), isTrue);
    });

    test('y lo que no lo es', () {
      // Todo esto se puede haber guardado como «la última página»: una
      // redirección que pasó por en medio, una página que se dibujó sola, una
      // dirección a medio escribir.
      expect(isBrowsableUrl('about:blank'), isFalse);
      expect(isBrowsableUrl('data:text/html,<p>hola</p>'), isFalse);
      expect(isBrowsableUrl('file:///C:/algo.html'), isFalse);
      expect(isBrowsableUrl('javascript:void(0)'), isFalse);
      expect(isBrowsableUrl('https://'), isFalse);
      expect(isBrowsableUrl('pixiv.net'), isFalse);
      expect(isBrowsableUrl('   '), isFalse);
      expect(isBrowsableUrl(null), isFalse);
    });
  });

  group('por dónde arranca', () {
    test('por lo que le hayan pedido, si vale', () {
      expect(
        browserStartUrl(
          requested: 'https://www.reddit.com/login',
          lastVisited: 'https://www.pixiv.net/',
          home: 'https://duckduckgo.com',
        ),
        'https://www.reddit.com/login',
      );
    });

    test('si no, por donde se quedó', () {
      expect(
        browserStartUrl(
          lastVisited: 'https://www.pixiv.net/',
          home: 'https://duckduckgo.com',
        ),
        'https://www.pixiv.net/',
      );
    });

    // Esto es lo que dejaba la pantalla en blanco.
    test('saltándose lo que no es una página', () {
      expect(
        browserStartUrl(
          lastVisited: 'about:blank',
          home: 'https://duckduckgo.com',
        ),
        'https://duckduckgo.com',
      );
    });

    test('y si no vale ninguna, la de fábrica', () {
      expect(
        browserStartUrl(lastVisited: 'about:blank', home: ''),
        browserHomeUrl,
      );
      expect(browserStartUrl(), browserHomeUrl);
    });
  });

  group('cuando una carga se cae', () {
    BrowserRecovery recovery({
      bool hasPageShown = false,
      bool alreadyRecovered = false,
      bool isMainFrame = true,
    }) =>
        browserRecoveryFor(
          hasPageShown: hasPageShown,
          alreadyRecovered: alreadyRecovered,
          isMainFrame: isMainFrame,
        );

    test('con la pantalla en blanco, se va a la de inicio', () {
      expect(recovery(), BrowserRecovery.goHome);
    });

    test('con algo ya a la vista, sólo se cuenta', () {
      // Una página que no va no es un navegador roto: tirar de ahí al usuario
      // sería peor que el fallo.
      expect(recovery(hasPageShown: true), BrowserRecovery.report);
    });

    test('lo que falla dentro de una página no cuenta', () {
      // Un anuncio, un marco, una imagen. La página está delante.
      expect(recovery(isMainFrame: false), BrowserRecovery.report);
    });

    test('y no se insiste dos veces', () {
      // Si la que falla es la propia página de inicio, insistir deja la
      // pantalla dando vueltas, que es peor que quedarse quieto.
      expect(recovery(alreadyRecovered: true), BrowserRecovery.report);
    });
  });
}
