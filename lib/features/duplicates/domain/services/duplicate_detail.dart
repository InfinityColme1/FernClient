import 'package:Fern/features/duplicates/domain/services/duplicate_merge.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:flutter/foundation.dart';

/// Una copia del grupo con todo lo que hace falta para compararla.
///
/// La entidad no basta: el tamaño en píxeles y el peso no viven en ella, salen
/// del fichero. Y son justo los dos datos que más pesan al elegir cuál se queda,
/// porque son los únicos que no se pueden recuperar después.
@immutable
class DuplicateCopy {
  final MediaEntity media;
  final int? width;
  final int? height;
  final int? sizeInBytes;

  const DuplicateCopy({
    required this.media,
    this.width,
    this.height,
    this.sizeInBytes,
  });

  int get mediaId => media.id;

  int get tagCount => media.tags?.length ?? 0;

  /// Si se sabe de qué tamaño es. Un fichero que no se pudo leer no lo dice.
  bool get hasSize => width != null && height != null;

  /// Lo que la heurística necesita saber de esta copia.
  DuplicateCandidate get candidate => DuplicateCandidate(
        mediaId: media.id,
        width: width,
        height: height,
        sizeInBytes: sizeInBytes,
        tagCount: tagCount,
        downloaded: media.downloaded,
      );
}

/// Cuál viene marcada al abrir el grupo.
///
/// Es sólo una propuesta —el usuario la ve y puede cambiarla—, pero es la que se
/// aplica cuando revisa cuarenta grupos seguidos sin mirar mucho.
int? preselectedKeeper(List<DuplicateCopy> copies) =>
    bestCopyOf([for (final one in copies) one.candidate])?.mediaId;

/// Las copias que se descartan si se conserva [keeperId].
List<MediaEntity> discardedOf(List<DuplicateCopy> copies, int? keeperId) => [
      for (final one in copies)
        if (one.mediaId != keeperId) one.media,
    ];

/// Qué grupo se abre después de resolver [resolvedId].
///
/// El que pasa a ocupar su sitio, no el primero de la lista. Es lo que hace
/// tolerable revisar cuarenta grupos seguidos: volver arriba cada vez obliga a
/// buscar otra vez por dónde se iba, y al final se abandona a la mitad.
///
/// Cuando el resuelto era el último, se retrocede al que queda antes. Con la
/// lista vacía no hay siguiente y la pantalla vuelve a decir que no hay nada.
int? nextGroupId(List<int> groupIds, int resolvedId) {
  final position = groupIds.indexOf(resolvedId);
  final rest = [...groupIds]..remove(resolvedId);

  if (rest.isEmpty) return null;
  if (position < 0) return rest.first;

  return rest[position.clamp(0, rest.length - 1)];
}
