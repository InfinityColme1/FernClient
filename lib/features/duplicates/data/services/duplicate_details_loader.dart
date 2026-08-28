import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_detail.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:flutter/foundation.dart';

/// De dónde salen los datos de un contenido.
typedef MediaDetailsReader = Future<DataState<MediaEntity>> Function(int mediaId);

/// El tamaño en píxeles de un fichero, o `null` si no se pudo saber.
typedef PixelSizeReader = Future<({int width, int height})?> Function(String path);

/// El peso de un fichero en bytes, o `null` si ya no está.
typedef FileWeightReader = int? Function(String path);

/// Reúne lo que hace falta para comparar las copias de un grupo.
///
/// Va aparte del repositorio porque no todo sale de la base: la entidad sí, pero
/// el tamaño y el peso hay que ir a buscarlos al disco. Los tres por parámetro
/// para poder probarlo sin base de datos ni ficheros.
class DuplicateDetailsLoader {
  final MediaDetailsReader _details;
  final PixelSizeReader _pixels;
  final FileWeightReader _weight;

  DuplicateDetailsLoader({
    required MediaDetailsReader details,
    PixelSizeReader? pixels,
    FileWeightReader? weight,
  })  : _details = details,
        _pixels = pixels ?? pixelSizeOf,
        _weight = weight ?? fileWeightOf;

  /// Las copias del grupo, en el orden en que se piden.
  ///
  /// Lo que no se puede leer **se queda fuera**. Un grupo puede sobrevivir a que
  /// una de sus copias se haya borrado por otro camino, y enseñar una tarjeta
  /// vacía con un botón de conservar debajo es peor que enseñar una menos.
  Future<List<DuplicateCopy>> load(Iterable<int> mediaIds) async {
    final copies = <DuplicateCopy>[];

    for (final mediaId in mediaIds) {
      final copy = await _copyOf(mediaId);
      if (copy != null) copies.add(copy);
    }

    return copies;
  }

  Future<DuplicateCopy?> _copyOf(int mediaId) async {
    final details = await _details(mediaId);
    final media = details is DataSuccess ? details.data : null;
    if (media == null) {
      debugPrint('No se pudo leer el contenido $mediaId: ${details.exception}');

      return null;
    }

    // Que no se sepa el tamaño no descarta la copia: el fichero puede estar y
    // ser ilegible para el decodificador y seguir mereciendo compararse por lo
    // demás. Lo que la descarta es no existir en la base.
    final size = await _pixelsOf(media.path);

    return DuplicateCopy(
      media: media,
      width: size?.width,
      height: size?.height,
      sizeInBytes: _weight(media.path),
    );
  }

  Future<({int width, int height})?> _pixelsOf(String path) async {
    try {
      return await _pixels(path);
    } on Object catch (error) {
      debugPrint('No se pudo medir $path: $error');

      return null;
    }
  }
}

/// El tamaño real del contenido, imagen o vídeo.
///
/// Se apoya en el servicio de previsualizaciones porque ya sabe sacarlo de las
/// dos cosas y porque lo tiene cacheado de haber pintado la rejilla.
Future<({int width, int height})?> pixelSizeOf(String path) async {
  final preview = await MediaPreviewService.instance.load(path);
  final width = preview?.width;
  final height = preview?.height;
  if (width == null || height == null) return null;

  return (width: width, height: height);
}

int? fileWeightOf(String path) {
  final file = File(path);

  return file.existsSync() ? file.lengthSync() : null;
}
