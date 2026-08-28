import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';

/// Cómo acabó una petición de reconocer.
enum RecognitionOutcome {
  /// Está en la cola.
  queued,

  /// No hay con qué reconocer. El motivo está en [RecognitionRequest.readiness].
  notReady,

  /// No había ningún contenido que mandar.
  ///
  /// No es lo mismo que lo anterior y no se puede juntar: aquí los modelos están
  /// listos y lo que falta es contenido —una etiqueta sin nada, una selección
  /// vacía, una biblioteca ya reconocida entera—, y el recado para el usuario es
  /// otro.
  nothingToRecognize,

  /// El usuario ha dicho que no al aviso previo.
  ///
  /// No se cuenta ni se avisa: acaba de decidirlo él, y contárselo sería repetir
  /// lo que él mismo ha hecho hace un segundo.
  cancelled,
}

/// En qué quedó una petición de reconocer.
class RecognitionRequest {
  final RecognitionOutcome outcome;

  /// Por qué no se pudo, cuando no se pudo.
  final RecognitionReadiness readiness;

  /// Cuántos contenidos se han encolado.
  final int count;

  /// Con qué identificador ha quedado el trabajo, para poder volver a él.
  ///
  /// Es lo que permite abrir después el parte de lo que hicieron los modelos:
  /// el parte se guarda por trabajo, y sin su identificador no hay forma de
  /// llegar al que uno acaba de lanzar.
  final String? jobId;

  const RecognitionRequest({
    required this.outcome,
    required this.readiness,
    this.count = 0,
    this.jobId,
  });

  bool get isQueued => outcome == RecognitionOutcome.queued;
}

/// El único sitio desde el que se manda a reconocer.
///
/// Los cuatro puntos de entrada del D16 —el visor, la selección de una rejilla,
/// una etiqueta o un creador enteros, y la biblioteca— acaban aquí. Tenerlo en
/// un solo sitio no es sólo por no repetirse: la comprobación de si hay con qué
/// reconocer es lo que evita encolar un trabajo que termina en milisegundos sin
/// dejar rastro, y basta que **uno** de los cuatro se la salte para que el
/// usuario vuelva a encontrarse un botón que no hace nada.
class RecognitionLauncher {
  final CanRecognizeUseCase _canRecognize;
  final JobQueue _jobs;

  RecognitionLauncher({
    required CanRecognizeUseCase canRecognize,
    required JobQueue jobs,
  })  : _canRecognize = canRecognize,
        _jobs = jobs;

  /// Manda [mediaIds] a la cola, si hay con qué y hay algo que mandar.
  ///
  /// [name] es cómo se llama el trabajo en la lista de tareas: «Etiqueta
  /// Ladybug» dice mucho más que «Reconocimiento» cuando hay tres en marcha.
  Future<RecognitionRequest> request(
    List<int> mediaIds, {
    String? name,
    JobPriority priority = JobPriority.high,
  }) async {
    // Se mira el contenido antes que los modelos: preguntarle a la base de
    // datos por el árbol para acabar diciendo «no has seleccionado nada» es
    // trabajo para nada.
    if (mediaIds.isEmpty) {
      return const RecognitionRequest(
        outcome: RecognitionOutcome.nothingToRecognize,
        readiness: RecognitionReadiness.ready,
      );
    }

    final readiness = await _canRecognize();

    if (readiness != RecognitionReadiness.ready) {
      return RecognitionRequest(
        outcome: RecognitionOutcome.notReady,
        readiness: readiness,
      );
    }

    // Sin repetidos: la misma selección puede llegar por dos caminos —una
    // etiqueta y un creador que comparten contenido—, y reconocer dos veces lo
    // mismo en el mismo trabajo es pagar dos veces por la misma respuesta.
    final unique = mediaIds.toSet().toList();

    final jobId = _jobs.enqueue(
      type: JobType.recognition,
      priority: priority,
      payload: {
        RecognitionJobRunner.mediaIdsKey: unique,
        if (name != null) Job.nameKey: name,
      },
      total: unique.length,
    );

    return RecognitionRequest(
      outcome: RecognitionOutcome.queued,
      readiness: readiness,
      count: unique.length,
      jobId: jobId,
    );
  }
}
