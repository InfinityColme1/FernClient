import 'dart:typed_data';

import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scanner.dart';

/// Cuánto dura un vídeo, o `null` si no se puede saber.
typedef VideoDuration = Future<Duration?> Function(String path);

/// El fotograma de un instante, ya escrito en el disco. `null` si no se pudo
/// sacar.
typedef VideoFrameAt = Future<String?> Function(String path, Duration moment);

/// El instante que representa a un vídeo: el **10 % de su duración**.
///
/// No el primer fotograma. Los vídeos empiezan en negro, con una carátula o con
/// el logotipo de quien los publica, y por ahí tres vídeos que no tienen nada
/// que ver dan el mismo hash y salen agrupados como si fueran el mismo. Un
/// décimo de la duración ya está dentro de lo que se está viendo.
///
/// Y es el mismo décimo en dos copias del mismo vídeo aunque una esté
/// recomprimida: lo que se compara después es el aspecto del fotograma, que
/// sobrevive a la recompresión.
Duration hashedMomentOf(Duration duration) =>
    Duration(microseconds: duration.inMicroseconds ~/ 10);

/// Saca de un vídeo los bytes con los que se le reconoce.
///
/// Las tres piezas llegan por parámetro porque sacar un fotograma es abrir el
/// fichero con libmpv, esperar a que diga cuánto dura, saltar y capturar. Eso no
/// se puede probar, y lo que hay que probar es lo de alrededor: qué instante se
/// elige, y que un vídeo que no se deja leer no tumbe el escaneo.
class VideoFrameReader {
  final VideoDuration _duration;
  final VideoFrameAt _frameAt;
  final BytesReader _read;

  const VideoFrameReader({
    required VideoDuration duration,
    required VideoFrameAt frameAt,
    BytesReader read = imageBytesOf,
  })  : _duration = duration,
        _frameAt = frameAt,
        _read = read;

  /// Los bytes del fotograma que representa al vídeo de [path], o `null` si no
  /// hay forma de sacarlo.
  ///
  /// Sin duración no se sigue: un fichero que no dice cuánto dura es uno que
  /// libmpv no ha podido abrir, y capturar de él el instante cero daría un
  /// fotograma negro —el hash que agrupa entre sí a todo lo que no se pudo
  /// leer—.
  Future<Uint8List?> bytesOf(String path) async {
    final total = await _duration(path);
    if (total == null || total <= Duration.zero) return null;

    final framePath = await _frameAt(path, hashedMomentOf(total));
    if (framePath == null) return null;

    return _read(framePath);
  }
}

/// De dónde salen los bytes que se miran de cada contenido.
///
/// De una imagen —y un GIF es una imagen— son los del propio fichero: el
/// decodificador se queda con el primer fotograma, que en un GIF es la imagen
/// entera y no un negro de cabecera. De un vídeo hay que sacarlo, y eso lo
/// resuelve [video].
BytesReader hashableBytesReader(
  VideoFrameReader video, {
  BytesReader image = imageBytesOf,
}) =>
    (path) => path.isVideoPath ? video.bytesOf(path) : image(path);
