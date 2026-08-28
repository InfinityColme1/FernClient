import 'dart:io';
import 'dart:typed_data';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:flutter/foundation.dart';

/// De dónde salen los bytes que hay que mirar de un contenido.
///
/// Va por parámetro porque de una imagen son los del propio fichero y de un vídeo
/// hay que sacar un fotograma, que es cosa del servicio de previsualizaciones.
/// Así el escáner se prueba sin abrir nada.
typedef BytesReader = Future<Uint8List?> Function(String path);

/// Dónde se guarda lo calculado.
typedef HashWriter = Future<void> Function(int mediaId, PerceptualHashes hashes);

/// Le calcula los hashes a lo que no los tiene.
///
/// El trabajo de verdad —decodificar la imagen y hacer la transformada— va en
/// **otro hilo**. Decodificar una imagen grande son decenas de milisegundos, y
/// hacerlo en el hilo de la interfaz por cada uno de diez mil contenidos es la
/// diferencia entre un escaneo que corre por detrás y una aplicación que no
/// responde durante media hora.
///
/// Y con eso basta para que no se note: el bucle espera a ese otro hilo en cada
/// vuelta, y esperar ya devuelve el turno. Hubo aquí una pausa cada veinticinco
/// contenidos «para dejar respirar a la interfaz»; se quitó al no poder escribir
/// ninguna prueba que notara la diferencia, porque no la hay.
class DuplicateScanner {
  final BytesReader _read;
  final HashWriter _write;

  DuplicateScanner({
    required BytesReader read,
    required HashWriter write,
  })  : _read = read,
        _write = write;

  /// Mira lo que haga falta de [media] y devuelve cuántos ha hasheado.
  ///
  /// [onProgress] recibe cuántos van y cuántos hay, para la barra de la cola.
  ///
  /// Un contenido que falle **no para el escaneo**: en una biblioteca de miles
  /// hay ficheros movidos, corruptos y formatos que el decodificador no conoce, y
  /// que uno de ellos deje sin hashear los otros novecientos noventa y nueve es
  /// lo peor que podría hacer esto.
  Future<int> hashPending(
    List<HashableMedia> media, {
    CancellationToken? token,
    void Function(int done, int total)? onProgress,
  }) async {
    final pending = pendingToHash(media);
    if (pending.isEmpty) return 0;

    var hashed = 0;

    for (var index = 0; index < pending.length; index++) {
      token?.throwIfCancelled();

      final one = pending[index];

      try {
        final bytes = await _read(one.path);

        if (bytes != null) {
          final hashes = await compute(hashesOfBytes, bytes);

          if (hashes != null) {
            await _write(one.mediaId, hashes);
            hashed++;
          }
        }
      } on Object catch (error) {
        debugPrint('No se pudo hashear ${one.path}: $error');
      }

      onProgress?.call(index + 1, pending.length);
    }

    return hashed;
  }
}

/// Los bytes de un fichero, o `null` si no se puede leer.
///
/// De una imagen son los suyos. De lo que se mueve hay que sacar un fotograma, y
/// eso lo resuelve quien monte el escáner: aquí sólo se distingue para no
/// intentar decodificar un MP4 como si fuera un PNG.
Future<Uint8List?> imageBytesOf(String path) async {
  if (path.isVideoPath) return null;

  try {
    final file = File(path);
    if (!file.existsSync()) return null;

    return await file.readAsBytes();
  } on Object {
    return null;
  }
}
