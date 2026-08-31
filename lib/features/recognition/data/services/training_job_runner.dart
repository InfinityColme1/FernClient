import 'dart:async';
import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/recognition/data/services/dataset_builder.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:Fern/features/recognition/domain/services/model_slug.dart';
import 'package:path/path.dart' as p;

/// De dónde salen las regiones con las que se monta el dataset.
///
/// Va por parámetro porque juntar las regiones de todos los fernies de un modelo
/// toca dos repositorios (los modelos y los fernies) y este runner no tiene por
/// qué saber de ninguno de los dos.
typedef DatasetSource = Future<List<DatasetRegion>> Function(int modelId);

/// Dónde vive todo lo del reconocimiento.
typedef RecognitionRoot = Future<String> Function();

/// Con qué se avisa de que el entrenamiento ha terminado.
///
/// Va por parámetro y no como el servicio entero porque de todo lo que sabe
/// hacer el servicio, aquí sólo se usa una cosa, y así el runner se prueba sin
/// preferencias ni sonidos de por medio.
typedef TrainingNotifier = Future<void> Function();

/// Entrena un modelo: monta el dataset, se lo pasa al motor y guarda lo que
/// salga.
///
/// Es el que va detrás de un trabajo de tipo `training` en la cola, así que
/// puede tardar horas mientras se sigue usando la aplicación. Lo que cuenta como
/// «una unidad» de avance es **una época**, que es lo que el usuario entiende
/// por «va por la mitad».
class TrainingJobRunner {
  final ModelRepository _models;
  final DatasetBuilder _datasets;
  final RecognitionEngine _engine;
  final DatasetSource _regionsOf;
  final RecognitionRoot _root;

  /// Si el dataset se conserva al terminar.
  ///
  /// De fábrica no: son miles de imágenes copiadas y la verdad sigue estando en
  /// la base de datos. Conservarlo sirve para mirar con qué se entrenó cuando un
  /// modelo no aprende, que es cuando hace falta de verdad.
  final bool Function() _keepDatasets;

  /// A quién se avisa al terminar. Ver [_notify].
  final TrainingNotifier? _notifyFinished;

  TrainingJobRunner({
    required ModelRepository models,
    required DatasetBuilder datasets,
    required RecognitionEngine engine,
    required DatasetSource regionsOf,
    required RecognitionRoot root,
    bool Function()? keepDatasets,
    TrainingNotifier? notifyFinished,
    this.grace = trainingCancelGrace,
  })  : _notifyFinished = notifyFinished,
        _models = models,
        _datasets = datasets,
        _engine = engine,
        _regionsOf = regionsOf,
        _root = root,
        _keepDatasets = keepDatasets ?? _never;

  static bool _never() => false;

  /// La clave con la que viaja el modelo en el `payload` del trabajo.
  static const modelIdKey = 'modelId';

  /// Lo que se enseña en la barra de tareas mientras se está parando.
  ///
  /// Parar no es inmediato: la señal se mira al cerrar cada época, así que lo
  /// que se estaba entrenando termina la suya. Sin decirlo, el botón parece no
  /// haber hecho nada y se pulsa otra vez.
  static const cancellingStage = 'cancelling';

  /// Cuánto se espera a que pare por las buenas antes de matar el sidecar.
  /// Parámetro para poder medirlo sin esperar un minuto en cada prueba.
  final Duration grace;

  /// Lo que la cola llama.
  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final modelId = context.payload<int>(modelIdKey);
    if (modelId == null) return;

    final model = await _modelOf(modelId);
    if (model == null) return;

    await _models.setTraining(modelId: modelId, isTraining: true);

    String? root;

    // Lo que hace que «cancelar» termine siempre: se pide parar por las buenas y,
    // pasado el plazo, se mata el sidecar. Sin esto, una época larga dejaba la
    // interfaz diciendo «Cancelando…» durante horas.
    final killer = _killAfterGrace(context);

    try {
      final plan = await _planFor(modelId);
      context.token.throwIfCancelled();

      root = p.join(
        await _root(),
        recognitionDatasetsFolderName,
        modelFolderName(id: modelId, name: model.name),
      );

      // Montar el dataset puede tardar tanto como entrenar cuando hay muchos
      // fotogramas de vídeo: hay que sacar cada uno con el reproductor.
      final dataset = await _datasets.build(
        plan: plan,
        root: root,
        token: context.token,
      );

      context.token.throwIfCancelled();

      // Las épocas son lo que se cuenta: es lo que el motor avisa y lo que el
      // usuario entiende por «va por la mitad».
      context.report(0, total: model.epochs);

      // La señal de parada llega hasta el sidecar, que la mira al cerrar cada
      // época. Sin pasarla, cancelar dejaba el trabajo marcado en la cola y el
      // Python entrenando hasta el final.
      final result = await _engine.train(
        _paramsFor(model, dataset),
        onProgress: (data) => _onEpoch(context, data),
        token: context.token,
      );

      await _models.saveTrainingResult(
        modelId: modelId,
        weightsPath: result['weights'] as String?,
        metrics: jsonEncode(result['metrics'] ?? const {}),
      );

      context.report(model.epochs, total: model.epochs);
      await _notify();
    } on JobCancelledException {
      // Parar no es un fallo: se deja el modelo como estaba y se sale sin
      // apuntar ningún error. Tampoco se avisa: pararlo lo ha hecho el usuario
      // hace un momento y ya lo sabe.
      await _models.saveTrainingResult(modelId: modelId);
      rethrow;
    } on Exception catch (error) {
      // Matar el sidecar rompe la petición en curso, así que lo que llega aquí
      // al cancelar es un fallo del canal. No lo es: lo ha parado el usuario, y
      // apuntarlo como error dejaría la ficha del modelo diciendo que se rompió
      // algo que se paró a propósito.
      if (context.token.isCancelled) {
        await _models.saveTrainingResult(modelId: modelId);
        throw const JobCancelledException();
      }

      await _models.saveTrainingResult(
        modelId: modelId,
        error: error.toString(),
      );

      // También se avisa cuando sale mal: lo que hace falta saber es que ya no
      // hay que esperar, y enterarse del fallo dos horas después de que pasara
      // es justo lo que el aviso evita.
      await _notify();
      rethrow;
    } finally {
      killer.cancel();

      // Pase lo que pase, la marca de «entrenando» se quita y el dataset se
      // recoge: dejarlos puestos impediría volver a entrenar y llenaría el
      // disco.
      await _models.setTraining(modelId: modelId, isTraining: false);

      if (root != null && !_keepDatasets()) {
        await _datasets.discard(root);
      }
    }
  }

  /// Al pedir parar: se dice que se está cancelando y se pone el reloj.
  ///
  /// Lo que se para de verdad lo decide el sidecar, que mira la señal **al
  /// cerrar cada época**. Si para, esto se cancela en el `finally` y no llega a
  /// matar nada. Si no para —una época larga, o el proceso atascado—, se le
  /// acaba el plazo y se cierra el sidecar a la fuerza.
  ///
  /// **Se lleva por delante lo que estuviera reconociéndose en paralelo**, y es
  /// a propósito: cancelar tarda siempre lo mismo, y lo que caiga sale contado en
  /// la lista de tareas para poder relanzarlo. Esperar a la otra tanda podía ser
  /// esperar horas por algo que el usuario acaba de pedir que pare.
  _Killer _killAfterGrace(JobContext context) {
    final killer = _Killer();

    unawaited(context.token.whenCancelled.then((_) async {
      if (killer.isCancelled) return;

      // Que se vea que se ha enterado: el botón ya no responde y sin decir nada
      // parece que no ha hecho nada.
      context.report(context.job.done, stage: cancellingStage);

      await Future<void>.delayed(grace);
      if (killer.isCancelled) return;

      await _engine.stop();
    }));

    return killer;
  }

  /// Avisa de que esto ha terminado, bien o mal.
  ///
  /// Un entrenamiento puede tardar horas y el usuario lo lanza y se va: si no se
  /// le avisa, tiene que acordarse de volver a mirar. Que el aviso falle no
  /// puede tirar abajo un entrenamiento que ya está guardado.
  Future<void> _notify() async {
    try {
      await _notifyFinished?.call();
    } on Exception catch (error) {
      debugPrint('No se pudo avisar del fin del entrenamiento: $error');
    }
  }

  /// Traduce el aviso del motor a unidades de la cola.
  void _onEpoch(JobContext context, Map<String, dynamic> data) {
    final epoch = data['epoch'];
    final epochs = data['epochs'];

    if (epoch is! int) return;

    context.report(epoch, total: epochs is int ? epochs : null);
  }

  Future<RecognitionModelEntity?> _modelOf(int id) async {
    final result = await _models.getModel(id);

    return result is DataSuccess ? result.data : null;
  }

  Future<DatasetPlan> _planFor(int modelId) async {
    final assignments = await _models.getFerniesOfModel(modelId);
    final fernies = assignments is DataSuccess
        ? assignments.data ?? const []
        : const [];

    return planDataset(
      regions: await _regionsOf(modelId),
      splitByClass: {
        for (final assignment in fernies) assignment.classIndex: assignment.split,
      },
      namesByClass: {
        for (final assignment in fernies)
          assignment.classIndex: modelSlug(assignment.fernie.name),
      },
      // Con el identificador del modelo por semilla, reentrenar el mismo da el
      // mismo reparto y las métricas se pueden comparar; modelos distintos no
      // heredan el reparto del vecino.
      seed: modelId,
    );
  }

  /// Lo que se le pasa al motor.
  ///
  /// `workers: 0` no es un capricho: en Windows, el cargador de datos de PyTorch
  /// con procesos aparte falla con entornos empotrados y rutas raras.
  Map<String, dynamic> _paramsFor(
    RecognitionModelEntity model,
    DatasetBuildResult dataset,
  ) {
    return {
      'dataset': dataset.dataYaml.replaceAll(r'\', '/'),
      'backbone': model.backbone,
      'epochs': model.epochs,
      'imgsz': model.imgsz,
      'batch': model.batch,
      'project': p.join(p.dirname(p.dirname(dataset.root)), 'runs')
          .replaceAll(r'\', '/'),
      'name': modelFolderName(id: model.id, name: model.name),
      'workers': defaultTargetPlatform == TargetPlatform.windows ? 0 : 4,
    };
  }
}

/// El reloj de la cancelación, para poder pararlo cuando ya no hace falta.
///
/// No es un `Timer`: lo que se espera es una pausa dentro de un `async`, y lo
/// único que hace falta es poder decir «déjalo» cuando el entrenamiento sí ha
/// parado por las buenas.
class _Killer {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
