// Las regiones de fernies que se llevan a la copia que se conserva.
//
// Las regiones no viven en el contenido, viven aparte y apuntan a él, así que
// quedarse con una copia y tirar las otras se lleva por delante todo lo que
// alguien marcó sobre las descartadas en cuanto la papelera se vacíe. Y marcar
// un fernie es dibujar un rectángulo a mano: no hay de dónde recuperarlo.
//
// Lo que se comprueba es que se copian, que apuntan a la copia buena y que no se
// repite lo que ya estaba marcado en ella.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/duplicates/domain/services/region_merge.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:flutter_test/flutter_test.dart';

FernieRegionEntity _region({
  int id = 1,
  int mediaId = 2,
  int fernieId = 10,
  double x = 0.1,
  double y = 0.2,
  double w = 0.3,
  double h = 0.4,
  int? frameMs,
}) {
  return FernieRegionEntity(
    id: id,
    mediaId: mediaId,
    fernieId: fernieId,
    x: x,
    y: y,
    w: w,
    h: h,
    frameMs: frameMs,
  );
}

void main() {
  group('lo que se lleva', () {
    test('las marcas de la descartada pasan a la que se queda', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        discardedRegions: [_region()],
      );

      expect(copied, hasLength(1));
      expect(copied.single.mediaId, 1);
      expect(copied.single.fernieId, 10);
    });

    // Sin esto Isar las tomaría por las de la copia descartada y las movería en
    // vez de copiarlas, o directamente fallaría por identificador repetido.
    test('entran como marcas nuevas, sin el identificador de la vieja', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        discardedRegions: [_region(id: 77)],
      );

      expect(copied.single.id, unsavedId);
    });

    test('el rectángulo se conserva tal cual', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        // Las coordenadas van normalizadas, así que el rectángulo que rodeaba
        // una cara en la copia de 1920 rodea la misma en la de 640.
        discardedRegions: [_region(x: 0.25, y: 0.5, w: 0.1, h: 0.2)],
      );

      expect(copied.single.x, 0.25);
      expect(copied.single.y, 0.5);
      expect(copied.single.w, 0.1);
      expect(copied.single.h, 0.2);
    });

    test('el fotograma marcado viaja con la región', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        discardedRegions: [_region(frameMs: 4200)],
      );

      expect(copied.single.frameMs, 4200);
    });

    test('varias descartadas aportan las suyas', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        discardedRegions: [
          _region(mediaId: 2, fernieId: 10),
          _region(mediaId: 3, fernieId: 20, x: 0.6),
        ],
      );

      expect(copied, hasLength(2));
      expect(copied.every((one) => one.mediaId == 1), isTrue);
    });
  });

  group('lo que no se repite', () {
    // Dos rectángulos superpuestos sobre la misma cara ensucian el conjunto de
    // datos de entrenamiento con el mismo recorte dos veces.
    test('lo que ya estaba marcado en la que se queda no se copia', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: [_region(mediaId: 1)],
        discardedRegions: [_region(mediaId: 2)],
      );

      expect(copied, isEmpty);
    });

    test('un rectángulo casi igual cuenta como el mismo', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: [_region(mediaId: 1, x: 0.100)],
        // Nadie dibuja dos veces el mismo rectángulo al píxel.
        discardedRegions: [_region(mediaId: 2, x: 0.105)],
      );

      expect(copied, isEmpty);
    });

    test('el mismo sitio con otro fernie sí se copia', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: [_region(mediaId: 1, fernieId: 10)],
        discardedRegions: [_region(mediaId: 2, fernieId: 99)],
      );

      expect(copied.single.fernieId, 99);
    });

    test('el mismo fernie en otro sitio también', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: [_region(mediaId: 1, x: 0.1)],
        discardedRegions: [_region(mediaId: 2, x: 0.8)],
      );

      expect(copied, hasLength(1));
    });

    // Dos caras distintas en el mismo sitio de dos fotogramas distintos de un
    // vídeo son dos marcas, no una.
    test('el mismo sitio en otro fotograma es otra marca', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: [_region(mediaId: 1, frameMs: 1000)],
        discardedRegions: [_region(mediaId: 2, frameMs: 9000)],
      );

      expect(copied, hasLength(1));
    });

    test('dos descartadas con la misma marca sólo la ponen una vez', () {
      final copied = regionsToCopy(
        keeperId: 1,
        keeperRegions: const [],
        discardedRegions: [
          _region(mediaId: 2),
          _region(mediaId: 3),
        ],
      );

      expect(copied, hasLength(1));
    });
  });

  test('sin nada marcado no hay nada que llevar', () {
    expect(
      regionsToCopy(keeperId: 1, keeperRegions: const [], discardedRegions: const []),
      isEmpty,
    );
  });
}
