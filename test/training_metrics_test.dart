// Lo que el sidecar devolvio, traducido a algo que se pueda pintar.
//
// Lo que importa aqui es **que nunca lance**. Esto se llama al pintar la
// pantalla de un modelo, y las metricas se guardan en crudo: un entrenamiento de
// hace meses, una version anterior de ultralytics o un JSON a medias de un fallo
// tienen que dejar la pantalla en pie, no en blanco.
//
// Y que lo que no se sabe **no se enseña**: un `null` es «no hay dato», y
// convertirlo en cero seria decir que el modelo acierta cero, que es una cifra
// muy distinta de no tenerla.

import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/services/training_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que devuelve el sidecar cuando todo va bien.
String _raw({Map<String, dynamic> changes = const {}}) {
  return jsonEncode({
    'map50': 0.83,
    'map50_95': 0.61,
    'precision': 0.88,
    'recall': 0.79,
    'per_class': {'marinette': 0.91, 'adrien': 0.87},
    'curves_dir': r'C:\fern\recognition\runs\1-personajes',
    'elapsed_seconds': 754,
    ...changes,
  });
}

void main() {
  group('lo que viene bien', () {
    test('se lee entero', () {
      final metrics = TrainingMetrics.parse(_raw())!;

      expect(metrics.map50, closeTo(0.83, 1e-9));
      expect(metrics.map50to95, closeTo(0.61, 1e-9));
      expect(metrics.precision, closeTo(0.88, 1e-9));
      expect(metrics.recall, closeTo(0.79, 1e-9));
      expect(metrics.perClass, {'marinette': 0.91, 'adrien': 0.87});
      expect(metrics.curvesDirectory, contains('1-personajes'));
      expect(metrics.elapsed, const Duration(seconds: 754));
      expect(metrics.isEmpty, isFalse);
    });

    test('un entero es tan numero como un decimal', () {
      // Python manda `1` cuando la cifra es redonda y JSON no distingue.
      final metrics = TrainingMetrics.parse(_raw(changes: {'map50': 1}))!;

      expect(metrics.map50, 1.0);
    });
  });

  group('lo que viene mal', () {
    test('sin nada no hay metricas', () {
      expect(TrainingMetrics.parse(null), isNull);
      expect(TrainingMetrics.parse(''), isNull);
      expect(TrainingMetrics.parse('   '), isNull);
    });

    test('un JSON roto no tumba la pantalla', () {
      expect(TrainingMetrics.parse('{"map50": '), isNull);
      expect(TrainingMetrics.parse('no soy json'), isNull);
    });

    test('un JSON que no es un objeto tampoco', () {
      expect(TrainingMetrics.parse('[1, 2, 3]'), isNull);
      expect(TrainingMetrics.parse('42'), isNull);
    });

    test('las claves que faltan se quedan sin dato, no a cero', () {
      final metrics = TrainingMetrics.parse('{"map50": 0.7}')!;

      // Un cero diria que el modelo acierta cero, que es muy distinto de no
      // saberlo.
      expect(metrics.map50, 0.7);
      expect(metrics.map50to95, isNull);
      expect(metrics.precision, isNull);
      expect(metrics.recall, isNull);
      expect(metrics.perClass, isEmpty);
    });

    test('lo que no es numero se descarta', () {
      final metrics = TrainingMetrics.parse(
        jsonEncode({'map50': 'muy bueno', 'recall': null, 'precision': 0.5}),
      )!;

      expect(metrics.map50, isNull);
      expect(metrics.recall, isNull);
      expect(metrics.precision, 0.5);
    });

    test('un numero en texto si vale', () {
      final metrics = TrainingMetrics.parse('{"map50": "0.42"}')!;

      expect(metrics.map50, closeTo(0.42, 1e-9));
    });

    test('un infinito o un NaN no pintan una barra imposible', () {
      // No salen de un JSON valido, pero si de uno escrito a mano o de una
      // version futura del sidecar.
      final metrics = TrainingMetrics.parse('{"map50": "Infinity"}')!;

      expect(metrics.map50, isNull);
    });

    test('la carpeta vacia es como no tenerla', () {
      final metrics = TrainingMetrics.parse(_raw(changes: {'curves_dir': ''}))!;

      // Con cadena vacia se ofreceria un boton de «ver curvas» que no lleva a
      // ningun sitio.
      expect(metrics.curvesDirectory, isNull);
    });

    test('un per_class que no es un mapa se ignora', () {
      final metrics =
          TrainingMetrics.parse(_raw(changes: {'per_class': 'ninguna'}))!;

      expect(metrics.perClass, isEmpty);
      expect(metrics.map50, closeTo(0.83, 1e-9));
    });

    test('dentro de per_class, lo que no es numero se cae solo', () {
      final metrics = TrainingMetrics.parse(_raw(changes: {
        'per_class': {'marinette': 0.9, 'adrien': 'bien'},
      }))!;

      expect(metrics.perClass, {'marinette': 0.9});
    });
  });

  group('vacio', () {
    test('un objeto sin nada dentro no tiene nada que enseñar', () {
      final metrics = TrainingMetrics.parse('{}')!;

      expect(metrics.isEmpty, isTrue);
    });

    test('con la carpeta pero sin cifras sigue vacio', () {
      // Es lo que pasaria con una version que dejara de dar metricas: hay run,
      // pero no hay numeros que enseñar.
      final metrics = TrainingMetrics.parse('{"curves_dir": "C:/runs/1"}')!;

      expect(metrics.isEmpty, isTrue);
      expect(metrics.curvesDirectory, 'C:/runs/1');
    });
  });

  group('las clases flojas', () {
    test('salen de peor a mejor', () {
      final metrics = TrainingMetrics.parse(_raw(changes: {
        'per_class': {'marinette': 0.91, 'alya': 0.42, 'adrien': 0.18},
      }))!;

      // Lo importante es cual esta peor: es con el que va a fallar.
      expect(metrics.weakClasses.map((entry) => entry.key), ['adrien', 'alya']);
    });

    test('con todas por encima del liston no hay ninguna', () {
      final metrics = TrainingMetrics.parse(_raw())!;

      expect(metrics.weakClasses, isEmpty);
    });

    test('justo en el liston no cuenta como floja', () {
      final metrics = TrainingMetrics.parse(_raw(changes: {
        'per_class': {'alya': weakClassThreshold},
      }))!;

      expect(metrics.weakClasses, isEmpty);
    });
  });
}
