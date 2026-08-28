import 'dart:io';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:path/path.dart' as p;

/// De dónde sale la imagen de un fotograma concreto.
///
/// Va por parámetro para poder montar un dataset sin abrir un reproductor: quien
/// lo prueba le pasa el suyo. Devuelve la ruta de un fichero de imagen ya
/// escrito, o `null` si no se pudo sacar.
typedef FrameExtractor = Future<String?> Function(String path, Duration at);

/// Lo que ha quedado montado en disco.
class DatasetBuildResult {
  /// La carpeta del dataset entero. Es lo que hay que borrar al terminar.
  final String root;

  /// El `data.yaml`, que es lo único que se le pasa al entrenamiento.
  final String dataYaml;

  final DatasetPlan plan;

  /// Los ficheros que ya no estaban en su sitio.
  ///
  /// No es un fallo: el contenido se pudo mover o borrar fuera de la aplicación.
  /// Sus regiones se quedan fuera del dataset y quien entrena avisa de cuántas.
  final List<String> missing;

  const DatasetBuildResult({
    required this.root,
    required this.dataYaml,
    required this.plan,
    this.missing = const [],
  });
}

/// Escribe en disco el dataset que YOLO necesita para entrenar.
///
/// Las regiones viven en la base de datos como coordenadas; YOLO quiere carpetas
/// con imágenes y ficheros de texto al lado. Esto materializa lo segundo a
/// partir de lo primero, y es **desechable**: se monta para entrenar y se borra
/// al terminar, porque la verdad sigue estando en la base de datos.
///
/// Qué va a cada parte no se decide aquí: eso es [planDataset], que es una
/// función pura y se comprueba sin tocar el disco. Esto sólo escribe lo que
/// aquélla ya decidió.
class DatasetBuilder {
  final FrameExtractor _extractFrame;

  DatasetBuilder({FrameExtractor? extractFrame})
      : _extractFrame = extractFrame ?? _extractWithPlayer;

  /// Monta [plan] en [root].
  ///
  /// Avisa por [onProgress] de cuántas imágenes lleva, que es lo que la pantalla
  /// enseña mientras prepara: con muchos fotogramas de vídeo esto tarda tanto
  /// como el entrenamiento.
  Future<DatasetBuildResult> build({
    required DatasetPlan plan,
    required String root,
    void Function(int done, int total)? onProgress,
    CancellationToken? token,
  }) async {
    final directory = Directory(root);

    // De cero siempre: un dataset a medias de un intento anterior mezclaría
    // imágenes que ya no tocan.
    if (directory.existsSync()) directory.deleteSync(recursive: true);

    for (final kind in DatasetSplitKind.values) {
      await Directory(p.join(root, 'images', kind.folder)).create(recursive: true);
      await Directory(p.join(root, 'labels', kind.folder)).create(recursive: true);
    }

    final missing = <String>[];
    var done = 0;

    for (final image in plan.images) {
      token?.throwIfCancelled();

      final written = await _writeImage(image, root);
      if (!written) {
        missing.add(image.sourcePath);
        continue;
      }

      await File(p.join(root, 'labels', image.split.folder, '${image.stem}.txt'))
          .writeAsString(image.labelFile);

      onProgress?.call(++done, plan.images.length);
    }

    final dataYaml = File(p.join(root, 'data.yaml'));
    await dataYaml.writeAsString(_dataYaml(root, plan));

    return DatasetBuildResult(
      root: root,
      dataYaml: dataYaml.path,
      plan: plan,
      missing: missing,
    );
  }

  /// Deja el dataset donde estaba: en ningún sitio.
  ///
  /// Se llama al terminar de entrenar. Un ajuste puede pedir conservarlo, que
  /// para mirar por qué un modelo no aprende no hay nada mejor que ver con qué
  /// se le enseñó.
  Future<void> discard(String root) async {
    final directory = Directory(root);
    if (directory.existsSync()) await directory.delete(recursive: true);
  }

  /// Pone la imagen de [image] en su carpeta. `false` si el fichero ya no está.
  Future<bool> _writeImage(DatasetImage image, String root) async {
    final source = File(image.sourcePath);
    if (!source.existsSync()) return false;

    final target = p.join(
      root,
      'images',
      image.split.folder,
      '${image.stem}${_extensionOf(image)}',
    );

    // Una imagen se copia tal cual: es lo que hay que enseñarle al modelo.
    if (!image.needsFrameExtraction) {
      await source.copy(target);
      return true;
    }

    final at = Duration(milliseconds: image.frameMs!);

    // Un GIF se abre entero y se coge el fotograma que toca; un vídeo se lo pide
    // al reproductor, que lo devuelve a la resolución del vídeo.
    final frame = image.sourcePath.isGifPath
        ? await _gifFrame(image.sourcePath, at, target)
        : await _extractFrame(image.sourcePath, at);

    if (frame == null) return false;
    if (frame == target) return true;

    await File(frame).copy(target);
    return true;
  }

  /// Los fotogramas de un GIF salen de descodificarlo entero, que es lo mismo
  /// que hace el visor para recorrerlo.
  Future<String?> _gifFrame(String path, Duration at, String target) async {
    final frames = await GifFrames.load(path);
    if (frames == null) return null;

    await File(target).writeAsBytes(frames.frames[frames.indexAt(at)]);
    return target;
  }

  /// Con qué extensión se guarda.
  ///
  /// Lo que sale de un vídeo o de un GIF es una imagen suelta, y se guarda como
  /// tal; lo demás conserva la suya para no reescribir píxeles sin motivo.
  String _extensionOf(DatasetImage image) {
    if (image.needsFrameExtraction) {
      return image.sourcePath.isGifPath ? '.png' : '.jpg';
    }

    final extension = p.extension(image.sourcePath);
    return extension.isEmpty ? '.jpg' : extension;
  }

  /// El `data.yaml`, que es lo único que ve el entrenamiento.
  ///
  /// Las rutas van con barras normales aunque sea Windows: lo lee Python, y allí
  /// una barra invertida dentro de una cadena es un escape.
  String _dataYaml(String root, DatasetPlan plan) {
    final names = plan.classNames.keys.toList()..sort();

    return [
      'path: ${root.replaceAll(r'\', '/')}',
      'train: images/train',
      'val: images/val',
      'test: images/test',
      'names:',
      for (final index in names) '  $index: ${plan.classNames[index]}',
      '',
    ].join('\n');
  }
}

/// El sacador de fotogramas de verdad.
///
/// Se apoya en el mismo servicio que dibuja las miniaturas de la rejilla: saca
/// el fotograma a la resolución del vídeo y lo deja cacheado en disco, así que
/// reentrenar el mismo modelo no vuelve a abrir un reproductor por cada uno.
Future<String?> _extractWithPlayer(String path, Duration at) async {
  final preview = await MediaPreviewService.instance.load(path, frame: at);

  return preview?.thumbnailPath;
}
