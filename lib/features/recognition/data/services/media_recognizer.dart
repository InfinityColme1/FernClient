import 'package:Fern/core/constants/app_constants.dart';
import 'package:path/path.dart' as p;
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';
import 'package:Fern/features/recognition/domain/services/model_tree_traversal.dart';
import 'package:flutter/foundation.dart';

/// Una detección tal y como sale del motor, todavía sin traducir.
///
/// Trae el **número de clase**, que es lo único que sabe unos pesos entrenados:
/// quién es ese número lo dice el modelo que lo entrenó.
class RawDetection {
  final int classIndex;
  final double confidence;

  final double? x;
  final double? y;
  final double? w;
  final double? h;

  const RawDetection({
    required this.classIndex,
    required this.confidence,
    this.x,
    this.y,
    this.w,
    this.h,
  });
}

/// Un fotograma que mirar, con el momento del que salió.
class SampledFrame {
  /// El fichero de imagen que se le pasa al motor.
  final String path;

  /// En qué momento del vídeo. `null` en imágenes.
  final int? frameMs;

  const SampledFrame({required this.path, this.frameMs});
}

/// Qué contesta el motor sobre una imagen concreta.
///
/// Va por parámetro porque predecir es cosa del sidecar, y esto tiene que poder
/// probarse sin levantar Python.
///
/// La confianza se pide desde fuera y **no es la del modelo**: se pregunta muy
/// por debajo de su listón para poder contar después qué vio y descartó. Sin
/// eso, «no ha detectado nada» y «lo vio al 27 % y tu listón está en el 35 %»
/// son indistinguibles, y el segundo es el que el usuario puede arreglar.
typedef ImagePredictor = Future<List<RawDetection>> Function(
  RecognitionModelEntity model,
  String imagePath,
  double confidence,
);

/// Lo mismo, pero preguntando por **varias imágenes de una vez**.
///
/// Contesta una lista por imagen, en el mismo orden en que se pidieron. Es lo
/// que hace que reconocer una biblioteca entera no sean tres peticiones por
/// contenido: el motor carga los pesos una vez y contesta por todo el lote.
///
/// Es opcional: sin él, el reconocedor pregunta de una en una con
/// [ImagePredictor], que es lo que hace que esto se pueda probar sin motor.
typedef ImagesPredictor = Future<List<List<RawDetection>>> Function(
  RecognitionModelEntity model,
  List<String> imagePaths,
  double confidence,
  CancellationToken? token,
);

/// Un contenido al que hay que pasarle el árbol.
class RecognitionTarget {
  final int mediaId;
  final String path;

  const RecognitionTarget({required this.mediaId, required this.path});
}

/// De dónde salen los fotogramas de un contenido que se mueve.
///
/// También por parámetro: sacarlos abre un reproductor, y eso no puede ser
/// requisito para probar en qué orden se ejecutan los modelos.
typedef FrameExtractor = Future<List<SampledFrame>> Function(
  String path,
  List<Duration> at,
);

/// Cuánto dura un contenido. `null` si no se mueve o no se sabe.
typedef DurationReader = Future<Duration?> Function(String path);

/// Con qué modelo se está trabajando ahora mismo.
///
/// Sirve para que la lista de tareas diga algo más que «reconociendo»: con un
/// árbol de tres modelos, saber cuál está mirando es la diferencia entre una
/// barra que avanza y una barra que se ha quedado colgada.
typedef ModelProgress = void Function(String modelName);

/// Lo que sale de reconocer un contenido: lo que se propone y lo que pasó.
///
/// Las dos cosas van juntas porque la segunda es la única explicación de la
/// primera cuando la primera está vacía.
class MediaRecognition {
  final List<RecognitionResultEntity> suggestions;
  final MediaRecognitionLog log;

  const MediaRecognition({required this.suggestions, required this.log});
}

/// Reconoce un contenido recorriendo el árbol de modelos.
///
/// Aquí es donde todo lo anterior se convierte en algo: los fernies marcados
/// entrenaron unos modelos, el árbol dice en qué orden se ejecutan, y esto los
/// pasa por un contenido y devuelve **propuestas**. Nada de lo que salga de aquí
/// toca el contenido: eso lo decide el usuario después.
///
/// No sabe de Isar ni de pantallas. Lo que sí sabe es traducir el número de
/// clase que devuelven unos pesos al fernie que representa, que es lo único que
/// nadie más puede hacer: ese número sólo significa algo junto al modelo que lo
/// entrenó.
class MediaRecognizer {
  final ModelRepository _models;
  final ImagePredictor _predict;

  /// Con qué se preguntan varias imágenes de una vez, si hay con qué.
  final ImagesPredictor? _predictMany;

  final FrameExtractor _extractFrames;
  final DurationReader _durationOf;

  /// Cuántos fotogramas se miran de un contenido que se mueve.
  final int Function() _frameSamples;

  MediaRecognizer({
    required ModelRepository models,
    required ImagePredictor predict,
    ImagesPredictor? predictMany,
    required FrameExtractor extractFrames,
    required DurationReader durationOf,
    int Function()? frameSamples,
  })  : _models = models,
        _predict = predict,
        _predictMany = predictMany,
        _extractFrames = extractFrames,
        _durationOf = durationOf,
        _frameSamples = frameSamples ?? _defaultSamples;

  static int _defaultSamples() => defaultFrameSamples;

  /// Pasa [tree] por el contenido de [path]: lo que proponen y lo que pasó.
  ///
  /// Las propuestas salen **sin identificador y sin guardar**: quién las guarda
  /// es el trabajo que llama a esto, que es también quien sabe si hay que borrar
  /// antes las de la vez anterior.
  Future<DataState<MediaRecognition>> recognize({
    required int mediaId,
    required String path,
    required ModelTreeEntity tree,
    CancellationToken? token,
    ModelProgress? onModel,
  }) async {
    final many = await recognizeMany(
      targets: [RecognitionTarget(mediaId: mediaId, path: path)],
      tree: tree,
      token: token,
      onModel: onModel,
    );

    if (many is! DataSuccess || many.data == null) {
      return DataException(many.exception ?? Exception('No se pudo reconocer'));
    }

    final mine = many.data![mediaId];
    if (mine == null) {
      return DataException(Exception('No se pudo reconocer $mediaId'));
    }

    return DataSuccess(mine);
  }

  /// Pasa [tree] por **varios contenidos a la vez**.
  ///
  /// Es el mismo recorrido que uno a uno —mismos niveles, misma poda, mismas
  /// reglas para abrir una rama— pero pidiendo las predicciones de todo un nivel
  /// juntas. La diferencia es de coste, no de resultado: reconocer veinticinco
  /// contenidos con un árbol de tres modelos pasa de setenta y cinco peticiones
  /// al motor a tres, y el motor deja de ir y volver entre unos pesos y otros.
  ///
  /// **La poda sigue siendo por contenido**: al segundo nivel sólo bajan los
  /// contenidos cuyo padre abrió esa rama, no todos los del lote. Que el
  /// resultado sea idéntico al de recorrerlos de uno en uno está comprobado en
  /// `test/model_tree_traversal_test.dart`.
  Future<DataState<Map<int, MediaRecognition>>> recognizeMany({
    required List<RecognitionTarget> targets,
    required ModelTreeEntity tree,
    CancellationToken? token,
    ModelProgress? onModel,
  }) async {
    try {
      if (targets.isEmpty) return const DataSuccess({});

      // Los fotogramas se sacan **una vez por contenido**, antes de empezar: el
      // mismo contenido pasa por varios modelos y abrir el fichero es lo caro.
      final framesOf = <int, List<SampledFrame>>{};
      final pathOf = <int, String>{};

      for (final target in targets) {
        token?.throwIfCancelled();

        pathOf[target.mediaId] = target.path;

        try {
          framesOf[target.mediaId] = await _framesOf(target.path);
        } on JobCancelledException {
          rethrow;
        } on Object catch (error) {
          // Un fichero movido, corrupto o de un formato raro **no tumba el
          // lote**: en una biblioteca de miles hay unos cuantos, y que uno de
          // ellos deje sin reconocer a los otros veinticuatro es lo peor que
          // podria hacer esto. Se queda sin recorrido y los demas siguen.
          debugPrint('Sin fotogramas de ${target.path}: $error');
        }
      }

      final mediaIds = [
        for (final target in targets)
          if (framesOf.containsKey(target.mediaId)) target.mediaId,
      ];

      final found = {for (final id in mediaIds) id: <RecognitionResultEntity>[]};
      final entries = {for (final id in mediaIds) id: <RecognitionLogEntry>[]};
      final executed = {for (final id in mediaIds) id: <int>{}};

      await runModelTreeBatched(
        tree: tree,
        mediaIds: mediaIds,
        predict: (node, ofThisLevel) async {
          token?.throwIfCancelled();

          onModel?.call(node.model.name);

          final byClass = await _classesOf(node);
          final raw = await _lookAtMany(node.model, ofThisLevel, framesOf, token);

          final detections = <int, List<TreeDetection>>{};

          for (final mediaId in ofThisLevel) {
            executed[mediaId]!.add(node.id);

            final reading = _read(
              node: node,
              mediaId: mediaId,
              byClass: byClass,
              raw: raw[mediaId] ?? const [],
            );

            found[mediaId]!.addAll(reading.suggestions);
            entries[mediaId]!.add(reading.entry);
            detections[mediaId] = reading.detections;
          }

          return detections;
        },
      );

      final result = <int, MediaRecognition>{};

      for (final mediaId in mediaIds) {
        // Los que no llegaron a ejecutarse también van al parte. Que un modelo
        // no se ejecute es el árbol haciendo su trabajo, pero desde fuera es
        // idéntico a que haya fallado.
        for (final node in tree.nodes) {
          if (executed[mediaId]!.contains(node.id)) continue;

          entries[mediaId]!.add(RecognitionLogEntry(
            modelId: node.model.id,
            modelName: node.model.name,
            picturePath: node.model.picturePath,
            verdict: node.isRunnable
                ? RecognitionVerdict.notReached
                : RecognitionVerdict.untrained,
            threshold: node.model.confidenceThreshold,
          ));
        }

        // Un mismo fernie puede salir de dos modelos distintos del árbol. Se
        // deja uno por fernie y modelo: dos propuestas del mismo modelo sobre el
        // mismo fernie son la misma sugerencia vista dos veces, y obligarían al
        // usuario a decir dos veces que sí.
        result[mediaId] = MediaRecognition(
          suggestions: _bestPerModelAndFernie(found[mediaId]!),
          log: MediaRecognitionLog(
            mediaId: mediaId,
            name: p.basename(pathOf[mediaId] ?? ''),
            models: entries[mediaId]!,
            at: DateTime.now(),
          ),
        );
      }

      return DataSuccess(result);
    } on JobCancelledException {
      rethrow;
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Lo que un modelo dice de **un** contenido, ya traducido.
  ///
  /// Se pregunta muy por debajo del listón del modelo y se filtra aquí. Lo que
  /// se queda fuera no se tira: es la única forma de poder decir después «lo
  /// vio, pero no lo suficiente».
  _Reading _read({
    required ModelTreeNodeEntity node,
    required int mediaId,
    required Map<int, FernieEntity> byClass,
    required List<_Located> raw,
  }) {
    final threshold = node.model.confidenceThreshold;

    final suggestions = <RecognitionResultEntity>[];
    final sightings = <RecognitionSighting>[];
    final detections = <TreeDetection>[];

    for (final one in raw) {
      final fernie = byClass[one.detection.classIndex];
      if (fernie == null) continue;

      sightings.add(RecognitionSighting(
        fernieId: fernie.id,
        fernieName: fernie.name,
        confidence: one.detection.confidence,
      ));

      if (one.detection.confidence < threshold) continue;

      suggestions.add(RecognitionResultEntity(
        mediaId: mediaId,
        modelId: node.model.id,
        fernieId: fernie.id,
        confidence: one.detection.confidence,
        x: one.detection.x,
        y: one.detection.y,
        w: one.detection.w,
        h: one.detection.h,
        frameMs: one.frameMs,
        createdAt: DateTime.now(),
      ));

      detections.add(TreeDetection(
        fernieId: fernie.id,
        confidence: one.detection.confidence,
      ));
    }

    sightings.sort((a, b) => b.confidence.compareTo(a.confidence));

    return _Reading(
      suggestions: suggestions,
      detections: detections,
      entry: RecognitionLogEntry(
        modelId: node.model.id,
        modelName: node.model.name,
        picturePath: node.model.picturePath,
        verdict: detections.isNotEmpty
            ? RecognitionVerdict.proposed
            : sightings.isEmpty
                ? RecognitionVerdict.sawNothing
                : RecognitionVerdict.belowThreshold,
        threshold: threshold,
        sightings: sightings,
      ),
    );
  }

  /// Qué fernie es cada número de clase de un modelo.
  ///
  /// Unos pesos entrenados sólo conocen números; quién es cada uno lo dice la
  /// asignación de fernies del modelo que los entrenó. Sin esta traducción, una
  /// detección no significa nada.
  ///
  /// Se guarda el fernie entero y no sólo su identificador porque el parte de lo
  /// que pasó lo enseña **por su nombre**: un log lleno de números no explica
  /// nada a quien lo abre para entender por qué no salió una sugerencia.
  /// La traducción no cambia mientras el trabajo corre —los fernies de un modelo
  /// se tocan desde su pantalla, no a media faena—, así que se lee una vez por
  /// modelo y no una por contenido. Con trescientos contenidos y un árbol de
  /// tres, la diferencia son novecientas lecturas de la base contra tres.
  final Map<int, Map<int, FernieEntity>> _classes = {};

  Future<Map<int, FernieEntity>> _classesOf(ModelTreeNodeEntity node) async {
    final cached = _classes[node.model.id];
    if (cached != null) return cached;

    final assignments = await _models.getFerniesOfModel(node.model.id);
    if (assignments is! DataSuccess || assignments.data == null) return const {};

    return _classes[node.model.id] = {
      for (final assignment in assignments.data!)
        assignment.classIndex: assignment.fernie,
    };
  }

  /// Olvida las traducciones leídas.
  ///
  /// Lo llama quien lanza un trabajo, antes de empezar: entre dos trabajos el
  /// usuario ha podido cambiar los fernies de un modelo, y seguir traduciendo
  /// con la tabla vieja pondría el nombre de otro fernie en las sugerencias.
  void forgetClasses() => _classes.clear();

  /// Los fotogramas que hay que mirar de un contenido.
  ///
  /// Una imagen es ella misma y ya. Lo que se mueve se muestrea, que es la
  /// diferencia entre una predicción y treinta por segundo.
  Future<List<SampledFrame>> _framesOf(String path) async {
    if (!path.isVideoPath && !path.isGifPath) {
      return [SampledFrame(path: path)];
    }

    final duration = await _durationOf(path);
    final at = sampleFrames(
      duration: duration ?? Duration.zero,
      count: _frameSamples(),
    );

    final frames = await _extractFrames(path, at);

    // Si no se pudo sacar ninguno, se mira el fichero tal cual: peor que nada es
    // no reconocerlo, y para un GIF el propio fichero suele valer.
    return frames.isEmpty ? [SampledFrame(path: path)] : frames;
  }

  /// Lo que ve un modelo en los fotogramas de **varios contenidos**.
  ///
  /// Se juntan todas las imágenes del nivel en una sola tanda y se reparten
  /// después: el motor carga los pesos una vez y contesta por todas. Se pregunta
  /// en tandas de [recognitionImagesPerCall] y no de una sola vez porque una
  /// petición sin límite es una petición que no se puede parar hasta que acabe.
  ///
  /// Devuelve, por contenido, lo mejor de cada clase entre todos sus fotogramas.
  Future<Map<int, List<_Located>>> _lookAtMany(
    RecognitionModelEntity model,
    List<int> mediaIds,
    Map<int, List<SampledFrame>> framesOf,
    CancellationToken? token,
  ) async {
    // Qué imagen es de quién. Va en dos listas paralelas y no en un mapa porque
    // dos contenidos pueden compartir fichero —el mismo GIF importado dos veces—
    // y ahí la ruta deja de identificar a nadie.
    final owners = <int>[];
    final frames = <SampledFrame>[];

    for (final mediaId in mediaIds) {
      for (final frame in framesOf[mediaId] ?? const <SampledFrame>[]) {
        owners.add(mediaId);
        frames.add(frame);
      }
    }

    final all = {for (final mediaId in mediaIds) mediaId: <_Located>[]};

    for (var from = 0; from < frames.length; from += recognitionImagesPerCall) {
      // Entre tanda y tanda: un lote de veinticinco vídeos son quinientas
      // predicciones seguidas, y sin esto parar tarda las quinientas.
      token?.throwIfCancelled();

      final to = (from + recognitionImagesPerCall).clamp(0, frames.length);
      final chunk = frames.sublist(from, to);

      final answers = await _askFor(model, chunk, token);

      for (var index = 0; index < chunk.length; index++) {
        final detections = index < answers.length ? answers[index] : const [];

        for (final detection in detections) {
          all[owners[from + index]]!.add(_Located(
            detection: detection,
            frameMs: chunk[index].frameMs,
          ));
        }
      }
    }

    return {
      for (final entry in all.entries)
        entry.key: bestPerFernie(
          entry.value,
          // Todavía por número de clase: la traducción a fernie viene después, y
          // dos clases distintas no se pueden juntar aunque acaben en el mismo.
          fernieOf: (one) => one.detection.classIndex,
          confidenceOf: (one) => one.detection.confidence,
        ),
    };
  }

  /// Lo que contesta el motor sobre estas imágenes, en el mismo orden.
  ///
  /// Con un predictor de lote es una petición; sin él, una por imagen. Lo
  /// segundo es lo que permite probar todo esto sin levantar Python.
  Future<List<List<RawDetection>>> _askFor(
    RecognitionModelEntity model,
    List<SampledFrame> frames,
    CancellationToken? token,
  ) async {
    final paths = [for (final frame in frames) frame.path];

    // La señal viaja con la petición: una tanda de sesenta imágenes no se puede
    // cortar desde aquí una vez mandada, pero el motor la mira entre imagen e
    // imagen y contesta que se paró.
    final many = _predictMany;
    if (many != null) return many(model, paths, recognitionFloor, token);

    final byImage = <List<RawDetection>>[];

    for (final path in paths) {
      // Sin motor de lote esto es una petición por fotograma, y parar no puede
      // tardar las que queden: un vídeo son veinte seguidas.
      token?.throwIfCancelled();

      byImage.add(await _predict(model, path, recognitionFloor));
    }

    return byImage;
  }

  List<RecognitionResultEntity> _bestPerModelAndFernie(
    List<RecognitionResultEntity> found,
  ) {
    final best = <String, RecognitionResultEntity>{};

    for (final one in found) {
      final key = '${one.modelId}:${one.fernieId}';
      final current = best[key];

      if (current == null || one.confidence > current.confidence) {
        best[key] = one;
      }
    }

    return best.values.toList();
  }
}

/// Lo que un modelo dice de un contenido: qué se propone, qué abre rama y qué
/// se cuenta en el parte.
///
/// Las tres cosas salen de la misma pasada y se devuelven juntas: separarlas
/// obligaría a recorrer tres veces lo mismo o a que el que llama las recompusiera
/// por su cuenta, que es justo donde se descuadran.
class _Reading {
  final List<RecognitionResultEntity> suggestions;
  final List<TreeDetection> detections;
  final RecognitionLogEntry entry;

  const _Reading({
    required this.suggestions,
    required this.detections,
    required this.entry,
  });
}

/// Una detección con el fotograma del que salió.
class _Located {
  final RawDetection detection;
  final int? frameMs;

  const _Located({required this.detection, this.frameMs});
}
