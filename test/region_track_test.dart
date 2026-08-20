// Comprueba el recorrido de un fernie por un contenido que se mueve.
//
// Las regiones de un mismo fernie en un video son el mismo objeto en momentos
// distintos, no cajas sueltas. Lo que se comprueba aqui es que el recorrido
// entre esos momentos es el que se espera y que fuera de ellos no se pinta
// nada.
//
// Lo segundo nace de un fallo visto en la aplicacion: al reproducir un video se
// veia la caja de un fernie de principio a fin, tambien en los fotogramas donde
// no habia ninguna region marcada. El recorrido se quedaba quieto en el extremo
// en vez de desaparecer.

import 'dart:ui';

import 'package:Fern/features/recognition/domain/services/region_track.dart';
import 'package:flutter_test/flutter_test.dart';

TrackKeyframe _at(int frameMs, double left) => TrackKeyframe(
      rect: Rect.fromLTWH(left, 0.2, 0.1, 0.1),
      frameMs: frameMs,
    );

void main() {
  group('donde esta el fernie', () {
    test('sin momentos marcados no hay recorrido', () {
      final track = RegionTrack(const []);

      expect(track.isEmpty, isTrue);
      expect(track.rectAt(500), isNull);
    });

    test('con un solo momento se ve solo en el', () {
      final track = RegionTrack([_at(1000, 0.5)]);

      expect(track.rectAt(1000)!.left, 0.5);
      expect(track.rectAt(0), isNull);
      expect(track.rectAt(99999), isNull);
    });

    test('entre dos momentos va en linea recta', () {
      final track = RegionTrack([_at(0, 0.0), _at(1000, 0.4)]);

      expect(track.rectAt(0)!.left, closeTo(0.0, 0.0001));
      expect(track.rectAt(250)!.left, closeTo(0.1, 0.0001));
      expect(track.rectAt(500)!.left, closeTo(0.2, 0.0001));
      expect(track.rectAt(1000)!.left, closeTo(0.4, 0.0001));
    });

    test('fuera de lo marcado no se pinta nada', () {
      final track = RegionTrack([_at(1000, 0.2), _at(2000, 0.6)]);

      // Antes del primero y despues del ultimo el fernie no esta marcado en
      // ninguna parte: quedarse quieto en el extremo llenaba el resto del video
      // de una caja fija sobre fotogramas vacios.
      expect(track.rectAt(0), isNull);
      expect(track.rectAt(999), isNull);
      expect(track.rectAt(5000), isNull);

      // Los dos extremos si, enteros.
      expect(track.rectAt(1000)!.left, closeTo(0.2, 0.0001));
      expect(track.rectAt(2000)!.left, closeTo(0.6, 0.0001));
    });

    test('el margen de los extremos alarga medio fotograma', () {
      final track = RegionTrack([_at(1000, 0.2), _at(2000, 0.6)]);

      // Sin el, la primera clave y la ultima se verian medio fotograma y el
      // recorrido entraria y saldria cortado.
      expect(track.rectAt(984, toleranceMs: 16)!.left, closeTo(0.2, 0.0001));
      expect(track.rectAt(2016, toleranceMs: 16)!.left, closeTo(0.6, 0.0001));
      expect(track.rectAt(983, toleranceMs: 16), isNull);
      expect(track.rectAt(2017, toleranceMs: 16), isNull);
    });

    test('los momentos se ordenan aunque lleguen desordenados', () {
      final track = RegionTrack([_at(2000, 0.6), _at(0, 0.0), _at(1000, 0.2)]);

      expect(track.keyframes.map((k) => k.frameMs), [0, 1000, 2000]);
      expect(track.rectAt(500)!.left, closeTo(0.1, 0.0001));
    });

    test('recorre los tres tramos seguidos', () {
      final track = RegionTrack([_at(0, 0.0), _at(1000, 0.4), _at(2000, 0.2)]);

      expect(track.rectAt(500)!.left, closeTo(0.2, 0.0001));
      expect(track.rectAt(1500)!.left, closeTo(0.3, 0.0001));
    });
  });
}
