// Cual de las direcciones de Redgifs es la que hay que descargar.
//
// Redgifs sirve el mismo video en varias formas, y una es **muda a proposito**:
// la que su web usa para la previsualizacion que se reproduce sola al pasar por
// encima. Se llama igual que las demas salvo por un sufijo, asi que quedarse con
// la primera que venga es como se acaba con una biblioteca entera de videos sin
// sonido, sin que nada haya fallado por el camino.
//
// No da ningun error y no se ve al importar: se ve al darle al play un mes
// despues. Por eso esto se comprueba aqui.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/services/redgifs_urls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cual se coge', () {
    test('la de calidad alta antes que la normal', () {
      final url = redgifsVideoUrl({
        'sd': 'https://media.redgifs.com/Algo-mobile.mp4',
        'hd': 'https://media.redgifs.com/Algo.mp4',
      });

      expect(url, 'https://media.redgifs.com/Algo.mp4');
    });

    test('la normal si no hay alta', () {
      final url = redgifsVideoUrl({
        'sd': 'https://media.redgifs.com/Algo-mobile.mp4',
      });

      expect(url, 'https://media.redgifs.com/Algo-mobile.mp4');
    });

    test('nunca la muda ni las miniaturas', () {
      // Aunque sea lo unico que venga: es mejor no traerse nada que traerse un
      // video sin sonido o una miniatura haciendose pasar por el contenido.
      final url = redgifsVideoUrl({
        'silent': 'https://media.redgifs.com/Algo-silent.mp4',
        'poster': 'https://media.redgifs.com/Algo-poster.jpg',
        'thumbnail': 'https://media.redgifs.com/Algo-mini.jpg',
        'vthumbnail': 'https://media.redgifs.com/Algo-mini.mp4',
      });

      expect(url, isNull);
    });

    test('sin nada que valga, nada', () {
      expect(redgifsVideoUrl(const {}), isNull);
      expect(redgifsVideoUrl(const {'hd': ''}), isNull);
      expect(redgifsVideoUrl(const {'hd': 42}), isNull);
    });
  });

  group('las cabeceras de descarga', () {
    test('dicen de donde viene la peticion', () {
      // Su servidor de contenidos mira de donde dice venir, igual que el de
      // Pixiv. Es uno de los sospechosos de que los videos llegaran mudos: hay
      // servidores que en vez de negarse dan **otra cosa**, y entonces la
      // descarga funciona y lo que llega no es lo que se pidio.
      expect(redgifsDownloadHeaders['Referer'], contains('redgifs.com'));
      expect(redgifsDownloadHeaders['Origin'], contains('redgifs.com'));
    });
  });

  group('la copia muda', () {
    test('se reescribe a la que tiene sonido', () {
      // Es el caso que deja la biblioteca muda: Redgifs devuelve la copia sin
      // sonido en la clave del video bueno.
      final url = redgifsVideoUrl({
        'hd': 'https://media.redgifs.com/Algo-silent.mp4',
      });

      expect(url, 'https://media.redgifs.com/Algo.mp4');
    });

    test('pero no si ese video nunca tuvo sonido', () {
      // Pedir la copia con sonido de algo que no lo tiene da un fichero que no
      // existe, y entonces no se trae nada en vez de traerse el video mudo.
      final url = redgifsVideoUrl(
        {'hd': 'https://media.redgifs.com/Algo-silent.mp4'},
        hasAudio: false,
      );

      expect(url, 'https://media.redgifs.com/Algo-silent.mp4');
    });

    test('un -silent en medio del nombre no es el suyo', () {
      // Quitarlo daria una direccion que no existe, y ese contenido se perderia
      // sin que nada fallara.
      expect(
        withRedgifsAudio('https://media.redgifs.com/Silent-silentnight.mp4'),
        'https://media.redgifs.com/Silent-silentnight.mp4',
      );
    });

    test('y el del final se quita aunque haya parametros detras', () {
      expect(
        withRedgifsAudio('https://media.redgifs.com/Algo-silent.mp4?t=1'),
        'https://media.redgifs.com/Algo.mp4?t=1',
      );
    });

    test('una direccion normal no se toca', () {
      expect(
        withRedgifsAudio('https://media.redgifs.com/Algo.mp4'),
        'https://media.redgifs.com/Algo.mp4',
      );
    });
  });

  group('de quien es un servidor', () {
    test('la pagina y el de los ficheros son los dos de Redgifs', () {
      expect(isRedgifsHost('www.redgifs.com'), isTrue);
      expect(isRedgifsHost('media.redgifs.com'), isTrue);
    });

    test('pero no uno que solo acabe pareciendose', () {
      // Si la comparacion no fuera por punto, cualquiera podria hacerse pasar
      // por Redgifs registrando un nombre que termine igual.
      expect(isRedgifsHost('noredgifs.com'), isFalse);
    });
  });
}
