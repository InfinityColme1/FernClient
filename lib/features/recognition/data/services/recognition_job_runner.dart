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
    // por «va por la mitad». Los fotogramas de dentro son cosa nuestra.
    context.report(0, total: ids.length);

    var suggested = 0;

    // Los que han acabado con algo que revisar. Son los que se señalan al llegar
    // a la pantalla: los demás no tienen nada que mirar.
    final withSuggestions = <int>{};

    for (var index = 0; index < ids.length; index++) {
      context.token.throwIfCancelled();

      final found = await _recognizeOne(
        ids[index],
        tree.data!,
        context,
        done: index,
        total: ids.length,
        returnToReview: returnToReview,
      );

      suggested += found;
      if (found > 0) withSuggestions.add(ids[index]);

      context.report(index + 1, total: ids.length);
    }

    // Sólo si hay algo que mirar. Avisar de que «ya está» cuando no ha salido
    // ninguna sugerencia manda al usuario a una pantalla donde no hay nada.
    if (suggested > 0) await _notify(withSuggestions);
  }

  /// Reconoce un contenido y guarda lo que salga. Devuelve cuántas propuestas.
  ///
  /// Un contenido que falle **no para el lote**: en una biblioteca de miles hay
  /// ficheros movidos, corruptos y formatos raros, y que uno de ellos deje sin
  /// reconocer los otros novecientos noventa y nueve es lo peor que podría
  /// hacer esto.
  Future<int> _recognizeOne(
    int mediaId,
    ModelTreeEntity tree,
    JobContext context, {
    required int done,
    required int total,
    required bool returnToReview,
  }) async {
    try {
      final path = await _pathOf(mediaId);
      if (path == null) return 0;

      final found = await _recognizer.recognize(
        mediaId: mediaId,
        path: path,
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
        debugPrint('No se pudo reconocer $mediaId: ${found.exception}');
        return 0;
      }

      // El parte se guarda **siempre**, hayan salido sugerencias o no: es
      // justamente cuando no sale ninguna cuando alguien lo abre.
      _logs.add(context.job.id, found.data!.log);

      final saved = await _results.replaceSuggestions(
        mediaId: mediaId,
        results: found.data!.suggestions,
        returnToReview: returnToReview,
      );

      return saved is DataSuccess ? saved.data ?? 0 : 0;
    } on JobCancelledException {
      // Parar sí para: es lo que el usuario acaba de pedir.
      rethrow;
    } on Object catch (error) {
      debugPrint('No se pudo reconocer $mediaId: $error');
      return 0;
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
