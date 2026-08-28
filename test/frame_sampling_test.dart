// En que momentos se mira un video al reconocer, y como se junta lo visto.
//
// Es el ajuste que mas afecta al tiempo total: mirar un video entero es pagar
// una prediccion por fotograma —treinta por segundo— para responder algo que
// casi siempre se decide con cinco.
//
// Lo que hay que sostener: que **no se miren los extremos**. El primer fotograma
// de un video es a menudo negro y el ultimo un cartel de cierre; empezar en cero
// y terminar en la duracion es tirar dos de las cinco miradas en nada.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una deteccion de mentira: el fernie, lo seguro que esta y de donde sale.
class _Seen {
  final int fernieId;
  final double confidence;
  final int frameMs;

  const _Seen(this.fernieId, this.confidence, this.frameMs);
}

List<_Seen> _best(List<_Seen> all) => bestPerFernie(
      all,
      fernieOf: (one) => one.fernieId,
      confidenceOf: (one) => one.confidence,
    );

void main() {
  group('donde se mira', () {
    test('se piden tantos como se han dicho', () {
      final frames = sampleFrames(
        duration: const Duration(seconds: 10),
        count: 5,
      );

      expect(frames, hasLength(5));
    });

    test('ni el principio ni el final', () {
      final frames = sampleFrames(
        duration: const Duration(seconds: 10),
        count: 5,
      );

      // Un negro de entrada y un cartel de cierre no dicen nada de lo que hay
      // en el video.
      expect(frames.first, greaterThan(Duration.zero));
      expect(frames.last, lessThan(const Duration(seconds: 10)));
    });

    test('repartidos por igual', () {
      final frames = sampleFrames(
        duration: const Duration(seconds: 10),
        count: 5,
      );

      final gaps = [
        for (var index = 1; index < frames.length; index++)
          frames[index].inMilliseconds - frames[index - 1].inMilliseconds,
      ];

      for (final gap in gaps) {
        expect(gap, closeTo(2000, 1));
      }
    });

    test('en orden', () {
      final frames = sampleFrames(
        duration: const Duration(seconds: 30),
        count: 7,
      );

      for (var index = 1; index < frames.length; index++) {
        expect(frames[index], greaterThan(frames[index - 1]));
      }
    });

    test('con uno solo, el de en medio', () {
      final frames = sampleFrames(
        duration: const Duration(seconds: 10),
        count: 1,
      );

      // Es el que menos probabilidades tiene de ser un negro.
      expect(frames, [const Duration(seconds: 5)]);
    });

    test('todos caen dentro del video', () {
      const duration = Duration(milliseconds: 3333);

      for (final frame in sampleFrames(duration: duration, count: 20)) {
        expect(frame, greaterThanOrEqualTo(Duration.zero));
        expect(frame, lessThan(duration));
      }
    });
  });

  group('lo que se pide de mas', () {
    test('un video de duracion cero da un solo momento', () {
      // Un GIF de un fotograma, o un fichero que todavia no sabe lo que dura.
      expect(sampleFrames(duration: Duration.zero), [Duration.zero]);
    });

    test('pedir cero o menos da uno', () {
      expect(
        sampleFrames(duration: const Duration(seconds: 4), count: 0),
        hasLength(1),
      );
    });

    test('pedir mas del tope se queda en el tope', () {
      final frames = sampleFrames(
        duration: const Duration(minutes: 5),
        count: 500,
      );

      // El coste es una prediccion por fotograma: sin tope, un descuido en un
      // ajuste deja la biblioteca reconociendose durante horas.
      expect(frames, hasLength(maxFrameSamples));
    });
  });

  group('recomponer el orden', () {
    test('vuelven en el orden en que se pidieron', () {
      // Sacarlos de una sola apertura obliga a saltar de menor a mayor, y a
      // devolverlos por momento en vez de en una lista.
      final asked = [
        const Duration(seconds: 1),
        const Duration(seconds: 5),
        const Duration(seconds: 9),
      ];

      final extracted = {
        const Duration(seconds: 9): 'c',
        const Duration(seconds: 1): 'a',
        const Duration(seconds: 5): 'b',
      };

      expect(framesInOrder(asked, extracted), ['a', 'b', 'c']);
    });

    test('lo que no salió simplemente no está', () {
      final asked = [
        const Duration(seconds: 1),
        const Duration(seconds: 5),
        const Duration(seconds: 9),
      ];

      // Un fotograma que no se pudo sacar es una mirada menos, no un hueco que
      // rellenar con nada.
      expect(
        framesInOrder(asked, {
          const Duration(seconds: 1): 'a',
          const Duration(seconds: 9): 'c',
        }),
        ['a', 'c'],
      );
    });

    test('sin nada extraído, nada', () {
      expect(framesInOrder([const Duration(seconds: 1)], <Duration, String>{}),
          isEmpty);
    });
  });

  group('los fotogramas de un GIF', () {
    /// Un GIF de tres fotogramas de un segundo: el índice es el segundo.
    int indexAt(Duration moment) => (moment.inMilliseconds ~/ 1000).clamp(0, 2);

    test('dos momentos en el mismo fotograma dan una sola mirada', () {
      final moments = [
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 900),
        const Duration(milliseconds: 1500),
      ];

      // Mirar dos veces la misma imagen es pagar dos predicciones por una
      // respuesta que ya se tenía.
      expect(distinctFrames(moments, indexAt), [0, 1]);
    });

    test('salen en el orden en que aparecen', () {
      final moments = [
        const Duration(milliseconds: 2500),
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 1200),
      ];

      expect(distinctFrames(moments, indexAt), [2, 0, 1]);
    });

    test('cinco miradas sobre tres fotogramas son tres', () {
      final moments = sampleFrames(
        duration: const Duration(seconds: 3),
        count: 5,
      );

      expect(distinctFrames(moments, indexAt).length, 3);
    });

    test('sin momentos, nada', () {
      expect(distinctFrames(const [], indexAt), isEmpty);
    });
  });

  group('juntar lo visto', () {
    test('un fernie en varios fotogramas se queda con el mejor', () {
      final best = _best(const [
        _Seen(1, 0.4, 1000),
        _Seen(1, 0.9, 5000),
        _Seen(1, 0.6, 9000),
      ]);

      expect(best, hasLength(1));
      expect(best.single.confidence, 0.9);

      // Y con el momento de ese, que es donde de verdad se le vio.
      expect(best.single.frameMs, 5000);
    });

    test('cada fernie va por su cuenta', () {
      final best = _best(const [
        _Seen(1, 0.4, 1000),
        _Seen(2, 0.8, 1000),
        _Seen(1, 0.9, 5000),
      ]);

      expect(best.map((one) => one.fernieId).toList()..sort(), [1, 2]);
    });

    test('aparecer en un solo fotograma basta', () {
      final best = _best(const [_Seen(3, 0.7, 4000)]);

      // Un personaje que sale tres segundos en un video de dos minutos aparece
      // en un fotograma de cinco, y es justo el que se quiere encontrar.
      expect(best.single.fernieId, 3);
    });

    test('sin nada visto, nada', () {
      expect(_best(const []), isEmpty);
    });
  });

  group('la caja de una detección', () {
    test('el centro pasa a ser la esquina', () {
      // Ultralytics da centro y tamaño; FeRN guarda esquina y tamaño. Una caja
      // mal convertida sale desplazada media anchura, que es exactamente el
      // aspecto de un modelo que detecta regular.
      expect(
        boxFromCenter([0.5, 0.5, 0.2, 0.4]),
        (x: 0.4, y: 0.3, w: 0.2, h: 0.4),
      );
    });

    test('una caja que ocupa todo empieza en cero', () {
      expect(boxFromCenter([0.5, 0.5, 1.0, 1.0]), (x: 0.0, y: 0.0, w: 1.0, h: 1.0));
    });

    test('lo que sobra de la lista se ignora', () {
      expect(
        boxFromCenter([0.5, 0.5, 0.2, 0.4, 99]),
        (x: 0.4, y: 0.3, w: 0.2, h: 0.4),
      );
    });

    test('lo que no tiene forma de caja no lo es', () {
      expect(boxFromCenter(null), isNull);
      expect(boxFromCenter('0.5,0.5'), isNull);
      expect(boxFromCenter([0.5, 0.5, 0.2]), isNull);
      expect(boxFromCenter([0.5, 0.5, 0.2, 'x']), isNull);
    });

    test('una caja sin superficie no es una caja', () {
      expect(boxFromCenter([0.5, 0.5, 0, 0.4]), isNull);
      expect(boxFromCenter([0.5, 0.5, 0.2, -1]), isNull);
    });
  });
}
