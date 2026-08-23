import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'suggestions_events.dart';
import 'suggestions_states.dart';

/// Las sugerencias del contenido que se está viendo, y el botón de pedirlas.
///
/// Vive con el visor y muere con él, igual que el modo fernie: lo que hay
/// propuesto sobre un contenido no es información del contenido, y arrastrarlo
/// en un bloc global sería tener sugerencias de algo que ya no se está mirando.
///
/// Escucha la cola de trabajos porque es la única forma de que lo reconocido
/// aparezca solo. Sin eso, pulsar «reconocer» dejaría al usuario mirando un
/// panel vacío sin saber si ha pasado algo, y habría que salir del visor y
/// volver a entrar para ver el resultado.
class SuggestionsBloc extends Bloc<SuggestionsEvents, SuggestionsState> {
  final GetMediaSuggestionsUseCase _getSuggestions;
  final AnswerSuggestionsUseCase _answer;
  final RecognitionLauncher _launcher;
  final JobQueue _jobs;

  StreamSubscription<List<Job>>? _subscription;

  SuggestionsBloc({
    required GetMediaSuggestionsUseCase getSuggestions,
    required AnswerSuggestionsUseCase answer,
    required RecognitionLauncher launcher,
    required JobQueue jobs,
  })  : _getSuggestions = getSuggestions,
        _answer = answer,
        _launcher = launcher,
        _jobs = jobs,
        super(const SuggestionsState()) {
    on<LoadSuggestionsEvent>(_onLoad);
    on<RecognizeCurrentMediaEvent>(_onRecognize);
    on<JobsChangedEvent>(_onJobsChanged);
    on<SuggestionsAcceptedEvent>(_onAccepted);
    on<SuggestionsRejectedEvent>(_onRejected);
    on<SuggestionsCommittedEvent>(_onCommitted);

    // Lo que ya hubiera en marcha al abrir el visor cuenta desde el primer
    // momento: se puede estar reconociendo la biblioteca entera y haber entrado
    // a mirar justo uno de los que están en la lista.
    add(JobsChangedEvent(_jobs.jobs));
    _subscription = _jobs.changes.listen((jobs) => add(JobsChangedEvent(jobs)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadSuggestionsEvent event,
    Emitter<SuggestionsState> emit,
  ) async {
    // Se suelta lo del anterior a la vez que se apunta el nuevo: dejar puestas
    // las de antes mientras se lee enseñaría durante un instante las sugerencias
    // de otro contenido, que es lo peor que puede hacer un panel del que se
    // aceptan etiquetas.
    emit(state.copyWith(
      mediaId: event.mediaId,
      suggestions: const [],
      accepted: const [],
      isLoading: true,
    ));

    final found = await _getSuggestions(params: event.mediaId);

    // Mientras se leía puede haberse pasado al siguiente: lo que acaba de llegar
    // ya no es de lo que se está viendo.
    if (state.mediaId != event.mediaId) return;

    final suggestions =
        found is DataSuccess ? found.data ?? const <MediaSuggestionEntity>[] : const <MediaSuggestionEntity>[];

    emit(state.copyWith(
      suggestions: suggestions,
      isLoading: false,
      // Un reconocimiento que termina tiene que decir en qué ha quedado, salga
      // algo o no: sin ello, «no ha visto nada» y «está roto» son lo mismo.
      finishedRuns: event.afterRecognizing
          ? state.finishedRuns + 1
          : state.finishedRuns,
      lastRunSuggestions:
          event.afterRecognizing ? suggestions.length : state.lastRunSuggestions,
    ));
  }

  /// Saca de la lista lo que se acaba de contestar y lo aparta como aceptado.
  void _onAccepted(
    SuggestionsAcceptedEvent event,
    Emitter<SuggestionsState> emit,
  ) {
    if (event.suggestions.isEmpty) return;

    final ids = {for (final one in event.suggestions) one.id};

    emit(state.copyWith(
      suggestions: _without(ids),
      accepted: [...state.accepted, ...event.suggestions],
    ));
  }

  Future<void> _onRejected(
    SuggestionsRejectedEvent event,
    Emitter<SuggestionsState> emit,
  ) async {
    if (event.suggestions.isEmpty) return;

    final ids = {for (final one in event.suggestions) one.id};

    // Se quita de la lista antes de escribir: el usuario acaba de pulsar y la
    // fila tiene que irse en ese momento, no cuando la base de datos conteste.
    // Que la escritura falle no cambia lo que ha decidido.
    emit(state.copyWith(suggestions: _without(ids)));

    await _answer(params: AnswerSuggestionsParams(
      ids: ids.toList(),
      status: SuggestionStatus.rejected,
    ));
  }

  /// El contenido se ha guardado: lo aceptado pasa a estarlo de verdad.
  Future<void> _onCommitted(
    SuggestionsCommittedEvent event,
    Emitter<SuggestionsState> emit,
  ) async {
    final pending = state.accepted;
    if (pending.isEmpty) return;

    emit(state.copyWith(accepted: const []));

    await _answer(params: AnswerSuggestionsParams(
      ids: [for (final one in pending) one.id],
      status: SuggestionStatus.accepted,
    ));
  }

  /// Lo que queda propuesto quitando estos.
  List<MediaSuggestionEntity> _without(Set<int> ids) => [
        for (final one in state.suggestions)
          if (!ids.contains(one.id)) one,
      ];

  Future<void> _onRecognize(
    RecognizeCurrentMediaEvent event,
    Emitter<SuggestionsState> emit,
  ) async {
    final mediaId = state.mediaId;
    if (mediaId == null || state.isRecognizing) return;

    // Por el mismo sitio que los otros tres puntos de entrada del D16. Es él
    // quien mira si hay con qué reconocer, y lo mira **ahora**: entre abrir el
    // contenido y pulsar puede haberse entrenado un modelo en otra pantalla, y
    // sobre todo puede que la primera lectura ni siquiera haya terminado
    // —pulsar nada más abrir es lo normal—.
    final request = await _launcher.request([mediaId]);

    if (state.mediaId != mediaId) return;

    emit(state.copyWith(
      readiness: request.readiness,
      lastAttempt: request.isQueued
          ? RecognitionAttempt.queued
          : RecognitionAttempt.refused,
      attempts: state.attempts + 1,
      lastJobId: request.jobId,
    ));
  }

  Future<void> _onJobsChanged(
    JobsChangedEvent event,
    Emitter<SuggestionsState> emit,
  ) async {
    final mediaId = state.mediaId;
    final isRecognizing = _isRecognizing(event.jobs, mediaId);

    if (isRecognizing == state.isRecognizing) return;

    // Pasar de reconociendo a no reconociendo es la señal de que hay algo nuevo
    // que leer. Se relee aunque el trabajo haya fallado: puede haber dejado
    // hechos unos cuantos antes de romperse.
    final hasFinished = state.isRecognizing && !isRecognizing;

    emit(state.copyWith(isRecognizing: isRecognizing));

    if (hasFinished && mediaId != null) {
      add(LoadSuggestionsEvent(mediaId, afterRecognizing: true));
    }
  }

  /// Si alguno de los trabajos vivos incluye este contenido.
  bool _isRecognizing(List<Job> jobs, int? mediaId) {
    if (mediaId == null) return false;

    for (final job in jobs) {
      if (job.type != JobType.recognition || !job.status.isActive) continue;

      final ids = job.payload[RecognitionJobRunner.mediaIdsKey];
      if (ids is List && ids.contains(mediaId)) return true;
    }

    return false;
  }
}
