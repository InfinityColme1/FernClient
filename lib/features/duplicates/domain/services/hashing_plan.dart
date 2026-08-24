import 'package:flutter/foundation.dart';

/// Lo que se sabe de un contenido a la hora de decidir si hay que mirarlo.
@immutable
class HashableMedia {
  final int mediaId;
  final String path;

  /// Cuándo se le calcularon los hashes. `null` es «nunca».
  final DateTime? hashedAt;

  /// Cuándo se tocó el fichero por última vez, si se pudo saber.
  ///
  /// `null` cuando el fichero ya no está o no se pudo leer su estado: eso no es
  /// motivo para rehacer nada, porque tampoco se va a poder leer para hashearlo.
  final DateTime? fileModifiedAt;

  const HashableMedia({
    required this.mediaId,
    required this.path,
    this.hashedAt,
    this.fileModifiedAt,
  });
}

/// Si hay que calcularle los hashes a este contenido.
///
/// Es lo que hace que los escaneos sean **incrementales**, y con ello lo que hace
/// que la función sea usable: la primera pasada sobre una biblioteca grande
/// decodifica decenas de miles de imágenes y cuesta lo que cuesta; las siguientes
/// tienen que tocar sólo lo que ha entrado desde entonces. Sin esto, cada escaneo
/// automático repetiría el trabajo entero y no habría manera de dejarlo puesto.
///
/// Se rehace en dos casos: nunca se hizo, o el fichero ha cambiado desde que se
/// hizo. Lo segundo pasa de verdad —la aplicación mueve ficheros a la carpeta de
/// la biblioteca, y hay quien edita una imagen y la guarda encima—, y un hash de
/// una imagen que ya no existe agrupa cosas que no se parecen.
bool needsHashing(HashableMedia media) {
  final hashedAt = media.hashedAt;
  if (hashedAt == null) return true;

  final modifiedAt = media.fileModifiedAt;
  if (modifiedAt == null) return false;

  return modifiedAt.isAfter(hashedAt);
}

/// Los que hay que mirar, en el orden en que se van a mirar.
///
/// Primero **lo que nunca se ha mirado**. Un escaneo se puede cancelar a la mitad
/// o quedarse sin tiempo, y lo que más aporta es lo que todavía no tiene hash: un
/// contenido nuevo no aparece en ningún grupo hasta que se le calcula, mientras
/// que uno que cambió ya está en la comparación aunque sea con el hash viejo.
List<HashableMedia> pendingToHash(Iterable<HashableMedia> media) {
  final never = <HashableMedia>[];
  final changed = <HashableMedia>[];

  for (final one in media) {
    if (!needsHashing(one)) continue;

    (one.hashedAt == null ? never : changed).add(one);
  }

  return [...never, ...changed];
}
