import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';

/// Las regiones que hay que copiar a la copia que se conserva.
///
/// Las regiones de fernies no viven en el contenido, viven aparte y apuntan a él.
/// Así que quedarse con una copia y tirar las otras pierde todo lo que alguien
/// marcó sobre las descartadas: cuando la papelera se vacíe a los siete días, las
/// regiones se van con ellas. Y son trabajo puro a mano —marcar un fernie es
/// dibujar un rectángulo— que no se puede recuperar.
///
/// Se pueden copiar tal cual porque las coordenadas van normalizadas (0..1) y las
/// copias son la misma imagen a otro tamaño: el rectángulo que rodeaba una cara
/// en la copia de 1920 rodea la misma cara en la de 640.
///
/// **Sin repetir lo que ya está.** Si alguien marcó el mismo fernie en las dos
/// copias, copiarlo dejaría dos rectángulos superpuestos sobre la misma cara, y
/// eso ensucia el conjunto de datos de entrenamiento con el mismo recorte dos
/// veces. Se consideran la misma marca el mismo fernie, el mismo fotograma y un
/// rectángulo que cae dentro de [_sameSpot].
List<FernieRegionEntity> regionsToCopy({
  required int keeperId,
  required List<FernieRegionEntity> keeperRegions,
  required List<FernieRegionEntity> discardedRegions,
}) {
  final copied = <FernieRegionEntity>[];

  bool isAlreadyThere(FernieRegionEntity region) {
    for (final existing in [...keeperRegions, ...copied]) {
      if (_isSameMark(existing, region)) return true;
    }

    return false;
  }

  for (final region in discardedRegions) {
    if (isAlreadyThere(region)) continue;

    copied.add(
      region.copyWith(id: unsavedId, mediaId: keeperId),
    );
  }

  return copied;
}

/// Cuánto se pueden separar dos rectángulos y seguir siendo la misma marca.
///
/// Un dos por ciento del lado. Nadie dibuja dos veces el mismo rectángulo al
/// píxel, y en cambio dos caras distintas de una imagen no caen nunca a esta
/// distancia.
const _sameSpot = 0.02;

bool _isSameMark(FernieRegionEntity one, FernieRegionEntity other) =>
    one.fernieId == other.fernieId &&
    one.frameMs == other.frameMs &&
    _isClose(one.x, other.x) &&
    _isClose(one.y, other.y) &&
    _isClose(one.w, other.w) &&
    _isClose(one.h, other.h);

bool _isClose(double one, double other) => (one - other).abs() <= _sameSpot;
