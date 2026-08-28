import 'package:Fern/core/utils/media_type.dart';
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

/// Lo que queda cuando el usuario no quiere que se mire lo que se mueve.
///
/// Vídeos y GIF fuera. Van juntos en el mismo ajuste porque para quien lo apaga
/// son la misma cosa —«lo que se mueve»—, aunque por dentro cuesten muy
/// distinto: un GIF se lee como cualquier imagen, y de un vídeo hay que abrir el
/// fichero con libmpv y sacarle un fotograma, que es lo que convierte una
/// biblioteca con miles de vídeos en un escaneo de horas.
///
/// Lo ya calculado no se toca: sigue guardado y sigue comparándose. Este ajuste
/// dice qué se mira de aquí en adelante, y para tirar lo de antes está
/// «Recalcular todas las huellas».
List<HashableMedia> withoutMoving(Iterable<HashableMedia> media) => [
      for (final one in media)
        if (!one.path.isVideoPath && !one.path.isGifPath) one,
    ];

