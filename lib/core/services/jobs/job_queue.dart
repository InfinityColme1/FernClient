import 'dart:async';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';

/// Los trabajos largos que corren por detrás mientras se sigue usando la
/// aplicación.
///
/// Entrenar un modelo, reconocer cinco mil contenidos y buscar repetidos son
/// tres cosas que duran minutos u horas, que pueden coincidir en el tiempo y
/// que el usuario tiene que poder parar por separado. Antes de esto sólo había
/// `Isolate.run` suelto y una señal global de cancelación, que no distingue una
/// tarea de otra.
///
/// Lo que hace la cola es decidir **cuándo** arranca cada cosa; qué hay que
/// hacer lo sabe el [JobRunner] que se registra por tipo.
///
/// Dos reglas de reparto:
///
/// - Como mucho [concurrency] trabajos a la vez, para no ahogar la máquina.
/// - Los de prioridad baja (lo que la aplicación hace por su cuenta) no
///   arrancan mientras haya algo de más prioridad esperando o en marcha. Una
///   vez arrancados, es cosa suya ir dejando respirar: ver
///   [JobContext.shouldYield].
class JobQueue {
  /// Cuántos trabajos pueden estar en marcha a la vez.
  final int concurrency;

  /// Cuántos trabajos ya terminados se conservan para poder enseñarlos. Los
  /// fallidos son la razón de que esto no sea cero: si desaparecieran al
  /// terminar, nadie llegaría a ver que algo ha fallado.
  final int historyLimit;

  final Map<JobType, JobRunner> _runners = {};
  final List<Job> _jobs = [];
  final Map<String, CancellationToken> _tokens = {};
  final StreamController<List<Job>> _controller =
      StreamController<List<Job>>.broadcast();

  var _sequence = 0;
  var _running = 0;
  var _isDisposed = false;

  JobQueue({this.concurrency = 2, this.historyLimit = 20});

  /// Quién sabe hacer los trabajos de [type]. Registrar dos veces el mismo tipo
  /// reemplaza al anterior.
  void register(JobType type, JobRunner runner) {
    _runners[type] = runner;
  }

  /// Cómo está todo ahora mismo. La lista es de sólo lectura: para cambiar algo
  /// se pasa por [enqueue] o [cancel].
  List<Job> get jobs => List.unmodifiable(_jobs);

  /// Los que siguen vivos, que es lo que mira la interfaz para decidir si
  /// enseña algo.
  List<Job> get activeJobs =>
      _jobs.where((job) => job.status.isActive).toList(growable: false);

  /// El estado completo cada vez que algo cambia.
  Stream<List<Job>> get changes => _controller.stream;

  /// Da de alta un trabajo y devuelve su identificador, con el que luego se
  /// puede cancelar.
  ///
  /// No espera a que termine: encolar es decir "esto hay que hacerlo", y la
  /// cola decide cuándo.
  String enqueue({
    required JobType type,
    JobPriority priority = JobPriority.normal,
    Map<String, Object?> payload = const {},
    int total = 0,
  }) {
    final job = Job(
      id: 'job-${_sequence++}',
      type: type,
      priority: priority,
      payload: payload,
      total: total,
      createdAt: DateTime.now(),
    );

    _jobs.add(job);
    _notify();
    _pump();

    return job.id;
  }

  /// Para el trabajo [id], esté esperando su turno o en marcha.
  ///
  /// Lo que ya se hubiera hecho se queda hecho: pararse a medias no es motivo
  /// para deshacer nada.
  void cancel(String id) {
    final index = _indexOf(id);
    if (index < 0) return;

    final job = _jobs[index];
    if (job.status.isFinished) return;

    _tokens[id]?.cancel();

    // El que todavía no había arrancado se cierra aquí mismo: nadie va a
    // mirarle la señal.
    if (job.status == JobStatus.queued) {
      _jobs[index] = job.copyWith(
        status: JobStatus.cancelled,
        finishedAt: DateTime.now(),
      );
      _trimHistory();
      _notify();
    }
  }

  /// Para todos los trabajos de un tipo. Lo usa quien apaga una función entera
  /// (desactivar el escaneo automático de repetidos, por ejemplo).
  void cancelAllOfType(JobType type) {
    final ids = _jobs
        .where((job) => job.type == type && job.status.isActive)
        .map((job) => job.id)
        .toList(growable: false);

    for (final id in ids) {
      cancel(id);
    }
  }

  /// Quita de la lista lo que ya ha terminado. Lo pide la interfaz cuando el
  /// usuario da por vistos los avisos.
  void clearFinished() {
    _jobs.removeWhere((job) => job.status.isFinished);
    _notify();
  }

  Future<void> dispose() async {
    _isDisposed = true;

    for (final token in _tokens.values) {
      token.cancel();
    }

    await _controller.close();
  }

  int _indexOf(String id) => _jobs.indexWhere((job) => job.id == id);

  void _notify() {
    if (_isDisposed || _controller.isClosed) return;

    _controller.add(jobs);
  }

  /// Arranca lo que quepa, por orden de prioridad y de llegada.
  void _pump() {
    if (_isDisposed) return;

    while (_running < concurrency) {
      final queued = _jobs.where((job) => job.status == JobStatus.queued).toList()
        ..sort(_byPriorityThenArrival);

      if (queued.isEmpty) return;

      final next = queued.first;

      // Si el primero de la cola es de fondo, es que no hay nada más urgente
      // esperando; queda mirar que tampoco haya nada más urgente en marcha.
      if (next.priority == JobPriority.low && _hasUrgentRunning) return;

      _start(next);
    }
  }

  bool get _hasUrgentRunning => _jobs.any((job) =>
      job.status == JobStatus.running && job.priority != JobPriority.low);

  /// Más prioridad primero y, a igualdad, el que lleve más tiempo esperando.
  int _byPriorityThenArrival(Job a, Job b) {
    final byPriority = b.priority.index.compareTo(a.priority.index);
    if (byPriority != 0) return byPriority;

    return a.createdAt.compareTo(b.createdAt);
  }

  void _start(Job job) {
    final runner = _runners[job.type];

    // Un tipo sin nadie que sepa hacerlo no puede quedarse esperando para
    // siempre: se cierra como fallido y se sigue.
    if (runner == null) {
      _finish(job.id, JobStatus.failed, error: 'No runner for ${job.type.name}');
      return;
    }

    final token = CancellationToken();
    _tokens[job.id] = token;
    _running++;

    _update(job.id, (current) => current.copyWith(
          status: JobStatus.running,
          startedAt: DateTime.now(),
        ));

    // Se pasa el trabajo ya marcado como en marcha: quien lo ejecute no debería
    // encontrarse a sí mismo en la cola diciendo que todavía espera turno.
    final context = JobContext(
      job: _jobs[_indexOf(job.id)],
      token: token,
      report: (done, {total}) => _report(job.id, done, total),
    );

    // Deliberadamente sin `await`: encolar no bloquea a quien encola, y el
    // final del trabajo se recoge aquí.
    unawaited(_run(job.id, runner, context, token));
  }

  Future<void> _run(
    String id,
    JobRunner runner,
    JobContext context,
    CancellationToken token,
  ) async {
    try {
      await runner(context);

      _finish(
        id,
        token.isCancelled ? JobStatus.cancelled : JobStatus.completed,
      );
    } on JobCancelledException {
      _finish(id, JobStatus.cancelled);
    } on Object catch (error) {
      // Cancelar por la vía rápida suele salir como una excepción cualquiera;
      // si la señal está levantada, no es un fallo.
      _finish(
        id,
        token.isCancelled ? JobStatus.cancelled : JobStatus.failed,
        error: token.isCancelled ? null : error.toString(),
      );
    }
  }

  void _report(String id, int done, int? total) {
    _update(id, (current) {
      if (current.status != JobStatus.running) return current;

      return current.copyWith(done: done, total: total ?? current.total);
    });
  }

  void _finish(String id, JobStatus status, {String? error}) {
    _running = _running > 0 ? _running - 1 : 0;
    _tokens.remove(id);

    _update(id, (current) => current.copyWith(
          status: status,
          error: error,
          finishedAt: DateTime.now(),
        ));

    _trimHistory();
    _pump();
  }

  void _update(String id, Job Function(Job current) change) {
    final index = _indexOf(id);
    if (index < 0) return;

    final updated = change(_jobs[index]);
    if (updated == _jobs[index]) return;

    _jobs[index] = updated;
    _notify();
  }

  /// Deja como mucho [historyLimit] trabajos terminados, los más recientes.
  void _trimHistory() {
    final finished = _jobs.where((job) => job.status.isFinished).toList();
    if (finished.length <= historyLimit) return;

    finished.sort((a, b) =>
        (a.finishedAt ?? a.createdAt).compareTo(b.finishedAt ?? b.createdAt));

    final excess = finished.take(finished.length - historyLimit).toSet();
    _jobs.removeWhere(excess.contains);
  }
}
