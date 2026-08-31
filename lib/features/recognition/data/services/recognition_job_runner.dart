import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/recognition/data/services/media_recognizer.dart';
import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:flutter/foundation.dart';

/// Dónde está cada contenido que hay que reconocer.
///
/// Va por parámetro y no leyendo el repositorio de contenidos porque este runner
/// no tiene por qué saber de la biblioteca: lo único que necesita de un
/// contenido es su ruta.
typedef MediaPathReader = Future<String?> Function(int mediaId);

/// Si lo reconocido tiene que volver a la pantalla de importación.
///
/// Se pregunta y no se guarda: el usuario puede cambiarlo entre dos trabajos, y
/// lo que vale es lo que tenga puesto cuando el trabajo arranca.
typedef ReturnToReviewSetting = bool Function();

/// Con qué se avisa de que hay sugerencias esperando.
///
/// Lleva **qué contenidos** y no sólo «ya está»: un aviso que sólo lleva a una
/// pantalla deja al usuario delante de una rejilla de trescientas miniaturas sin
/// saber cuáles son las suyas.
typedef RecognitionNotifier = Future<void> Function(Set<int> mediaIds);
/// Lo que salió mal reconociendo, dicho de una vez.
///
/// El texto sale tal cual en la lista de tareas, así que lleva el motivo y no
/// sólo el recuento: «fallaron 3 de 3» no le dice a nadie que su tarjeta no sabe
/// ejecutar el modelo, y eso es justo lo que hay que leer para arreglarlo.
class RecognitionFailedException implements Exception {
  /// Cuántas tandas se rompieron y cuántas se intentaron.
  final int failed;
  final int total;

  final Object cause;

  const RecognitionFailedException({
    required this.failed,
    required this.total,
    required this.cause,
  });

  /// Si no funcionó ni una: entonces no es «algo se ha perdido», es que el
  /// reconocimiento no se ha hecho.
  bool get isTotal => failed >= total;

  @override
  String toString() => '$failed/$total: $cause';
}


/// Pasa el árbol de modelos por una lista de contenidos.
///
/// Es lo que va detrás de un trabajo de tipo `recognition`. Puede tardar mucho
/// —una biblioteca entera son miles de predicciones— así que va por la cola: se
/// puede parar, sobrevive a cambiar de pantalla, y avisa al terminar como todo
/// lo demás.
class RecognitionJobRunner {
  final ModelTreeRepository _tree;
  final RecognitionResultRepository _results;
  final MediaRecognizer _recognizer;
  final MediaPathReader _pathOf;
  final RecognitionLogStore _logs;
  final ReturnToReviewSetting? _returnToReview;
  final RecognitionNotifier? _notifyFinished;

  RecognitionJobRunner({
    required ModelTreeRepository tree,
    required RecognitionResultRepository results,
    required MediaRecognizer recognizer,
    required MediaPathReader pathOf,
    required RecognitionLogStore logs,
    ReturnToReviewSetting? returnToReview,
    RecognitionNotifier? notifyFinished,
  })  : _tree = tree,
        _results = results,
        _recognizer = recognizer,
        _pathOf = pathOf,
        _logs = logs,
        _returnToReview = returnToReview,
        _notifyFinished = notifyFinished;

  /// La clave con la que viajan los contenidos en el `payload`.
  static const mediaIdsKey = 'mediaIds';

  /// De cuántos en cuántos se recorre el árbol, según cuántos haya.
  ///
  /// El lote ahorra peticiones al motor, pero el lote entero termina a la vez y
  /// la barra sólo puede avanzar cuando termina. Con pocos contenidos eso se
  /// nota y el ahorro no, así que van de uno en uno; con la biblioteca entera es
  /// al revés. El corte no es un número inventado: sale de querer que la barra
  /// tenga siempre al menos [recognitionProgressSteps] tramos.
  static int batchSizeFor(int total) {
    if (total <= recognitionProgressSteps) return 1;

    return (total / recognitionProgressSteps)
        .ceil()
        .clamp(1, recognitionMediaPerBatch);
  }

  /// Lo que la cola llama.
  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final ids = _idsOf(context);
    if (ids.isEmpty) return;

    // Entre dos trabajos el usuario ha podido cambiar los fernies de un modelo,
    // así que lo que el reconocedor recuerde de la vez anterior ya no vale.
    _recognizer.forgetClasses();

    // El árbol se lee una vez. No cambia a media faena, y releerlo por cada
    // contenido serían mil lecturas para responder siempre lo mismo.
    final tree = await _tree.getTree();
    if (tree is! DataSuccess || tree.data == null) return;

    // Sin nada en el árbol no hay nada que ejecutar. Un modelo que no está
    // dentro no se ejecuta nunca, así que esto no es un fallo: es que no hay
    // trabajo.
    if (tree.data!.nodes.isEmpty) return;

    // El ajuste se lee una vez, como el árbol: cambiarlo a media faena dejaría
    // medio lote en la biblioteca y medio en importación, que es lo peor de las
    // dos cosas.
    final returnToReview = _returnToReview?.call() ?? false;

    // Lo que se cuenta es **un contenido**, que es lo que el usuario entiende
    // por «va por la mitad». Los fotogramas de dentro, y que se recorra el árbol
    // por tandas, son cosa nuestra: la barra avanza de tanda en tanda pero sigue
    // hablando de contenidos.
    context.report(0, total: ids.length);

    var suggested = 0;

    // Cuántas tandas se han roto y con qué. Se levanta al final: seguir con las
    // demás es lo correcto —un fichero ilegible no puede llevarse por delante las
    // otras cien— pero terminar sin decirlo es lo que hacía que un fallo de la
    // tarjeta pareciera «aquí no había nada que encontrar».
    var failedBatches = 0;
    var batches = 0;
    Object? lastError;

    // Los que han acabado con algo que revisar. Son los que se señalan al llegar
    // a la pantalla: los demás no tienen nada que mirar.
    final withSuggestions = <int>{};

    final batch = batchSizeFor(ids.length);

    for (var from = 0; from < ids.length; from += batch) {
      context.token.throwIfCancelled();

      final to = (from + batch).clamp(0, ids.length);

      final found = await _recognizeBatch(
        ids.sublist(from, to),
        tree.data!,
        context,
        done: from,
        total: ids.length,
        returnToReview: returnToReview,
      );

      batches++;
      if (found.error != null) {
        failedBatches++;
        lastError = found.error;
      }

      for (final entry in found.saved.entries) {
        suggested += entry.value;
        if (entry.value > 0) withSuggestions.add(entry.key);
      }

      context.report(to, total: ids.length);
    }

    // Sólo si hay algo que mirar. Avisar de que «ya está» cuando no ha salido
    // ninguna sugerencia manda al usuario a una pantalla donde no hay nada.
    if (suggested > 0) await _notify(withSuggestions);

    // Lo guardado se queda guardado —esto va después de escribirlo—, pero el
    // trabajo termina en rojo y contando por qué.
    if (lastError != null) {
      throw RecognitionFailedException(
        failed: failedBatches,
        total: batches,
        cause: lastError,
      );
    }
  }

  /// Reconoce una tanda de contenidos y guarda lo que salga.
  ///
  /// Devuelve cuántas propuestas por contenido. La tanda entera recorre el árbol
  /// junta: un árbol de tres modelos sobre veinticinco contenidos son tres
  /// peticiones al motor en vez de setenta y cinco, y el motor deja de ir y
  /// volver entre unos pesos y otros. La poda sigue siendo por contenido, así
  /// que el resultado es el mismo que reconociéndolos de uno en uno.
  ///
  /// Una tanda que falle **no para el trabajo**: se cuenta y se sigue con la
  /// siguiente. Lo que sí para es que el usuario lo pida.
  ///
  /// Pero se cuenta de verdad: devuelve también el fallo, y quien llama lo
  /// levanta al terminar. Antes se escribía en la consola y se devolvía vacío,
  /// así que un reconocimiento que no podía funcionar —una tarjeta que no sabe
  /// ejecutar el modelo, unos pesos ilegibles— terminaba «bien» sin una sola
  /// sugerencia y sin nada que mirar.
  Future<({Map<int, int> saved, Object? error})> _recognizeBatch(
    List<int> mediaIds,
    ModelTreeEntity tree,
    JobContext context, {
    required int done,
    required int total,
    required bool returnToReview,
  }) async {
    try {
      final targets = <RecognitionTarget>[];

      for (final mediaId in mediaIds) {
        final path = await _pathOf(mediaId);
        if (path == null) continue;

        targets.add(RecognitionTarget(mediaId: mediaId, path: path));
      }

      if (targets.isEmpty) return (saved: const <int, int>{}, error: null);

      final found = await _recognizer.recognizeMany(
        targets: targets,
        tree: tree,
        token: context.token,
        // Qué modelo está mirando ahora mismo. Con un árbol de tres, saberlo es
        // la diferencia entre una barra que avanza y una que parece colgada.
        //
        // El avance va explícito y **no se lee de `context.job`**: eso es una
        // foto del trabajo tal y como estaba al arrancar, con el contador a
        // cero, así que anunciar el modelo reiniciaría la barra cada vez.
        onModel: (name) => context.report(done, total: total, stage: name),
      );

      if (found is! DataSuccess || found.data == null) {
        return (
          saved: const <int, int>{},
          error: found.exception ?? Exception('recognizeMany'),
        );
      }

      final saved = <int, int>{};

      for (final entry in found.data!.entries) {
        // El parte se guarda **siempre**, hayan salido sugerencias o no: es
        // justamente cuando no sale ninguna cuando alguien lo abre.
        _logs.add(context.job.id, entry.value.log);

        final written = await _results.replaceSuggestions(
          mediaId: entry.key,
          results: entry.value.suggestions,
          returnToReview: returnToReview,
        );

        saved[entry.key] = written is DataSuccess ? written.data ?? 0 : 0;
      }

      return (saved: saved, error: null);
    } on JobCancelledException {
      // Parar sí para: es lo que el usuario acaba de pedir.
      rethrow;
    } on Object catch (error) {
      return (saved: const <int, int>{}, error: error);
    }
  }

  List<int> _idsOf(JobContext context) {
    final raw = context.job.payload[mediaIdsKey];
    if (raw is! List) return const [];

    return [
      for (final one in raw)
        if (one is int) one,
    ];
  }

  /// Avisa de que hay sugerencias esperando.
  ///
  /// Que el aviso falle no puede tirar abajo un reconocimiento ya guardado.
  Future<void> _notify(Set<int> mediaIds) async {
    try {
      await _notifyFinished?.call(mediaIds);
    } on Object catch (error) {
      debugPrint('No se pudo avisar del fin del reconocimiento: $error');
    }
  }
}
