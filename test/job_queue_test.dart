// La cola de trabajos largos.
//
// Lo que hay que sostener son cuatro cosas: que de verdad se solapen (si no, no
// sirve de nada), que no se solapen sin fin, que lo que el usuario acaba de
// pedir pase por delante de lo que la aplicación hace por su cuenta, y que
// cancelar uno no arrastre a los demás. Y que un trabajo que revienta se quede
// en fallido sin llevarse la cola por delante.

import 'dart:async';

import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un trabajo que no termina hasta que se le dice.
class _Gate {
  final Completer<void> completer = Completer<void>();

  void open() {
    if (!completer.isCompleted) completer.complete();
  }
}

Job jobOf(JobQueue queue, String id) =>
    queue.jobs.firstWhere((job) => job.id == id);

void main() {
  test('varios corren a la vez, pero no más de la cuenta', () async {
    final queue = JobQueue(concurrency: 2);
    final started = <String>[];
    final gate = _Gate();

    queue.register(JobType.recognition, (context) async {
      started.add(context.job.id);
      await gate.completer.future;
    });

    final first = queue.enqueue(type: JobType.recognition);
    final second = queue.enqueue(type: JobType.recognition);
    final third = queue.enqueue(type: JobType.recognition);

    await Future<void>.delayed(Duration.zero);

    // Dos en marcha y el tercero esperando turno.
    expect(started, [first, second]);
    expect(jobOf(queue, third).status, JobStatus.queued);

    gate.open();
    await Future<void>.delayed(Duration.zero);

    expect(started, [first, second, third]);

    await queue.dispose();
  });

  test('lo urgente pasa por delante de lo que llegó antes', () async {
    final queue = JobQueue(concurrency: 1);
    final order = <JobType>[];
    final gate = _Gate();

    Future<void> runner(JobContext context) async {
      order.add(context.job.type);
      await gate.completer.future;
    }

    queue.register(JobType.hashing, runner);
    queue.register(JobType.recognition, runner);
    queue.register(JobType.training, runner);

    // El primero arranca solo, porque la cola estaba vacía.
    queue.enqueue(type: JobType.hashing);
    await Future<void>.delayed(Duration.zero);

    queue.enqueue(type: JobType.recognition);
    queue.enqueue(type: JobType.training, priority: JobPriority.high);

    gate.open();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(order, [JobType.hashing, JobType.training, JobType.recognition]);

    await queue.dispose();
  });

  test('lo de fondo espera a que no haya nada más urgente en marcha', () async {
    final queue = JobQueue(concurrency: 2);
    final started = <JobType>[];
    final gate = _Gate();

    Future<void> runner(JobContext context) async {
      started.add(context.job.type);
      await gate.completer.future;
    }

    queue.register(JobType.training, runner);
    queue.register(JobType.duplicateScan, runner);

    queue.enqueue(type: JobType.training);
    final background = queue.enqueue(
      type: JobType.duplicateScan,
      priority: JobPriority.low,
    );

    await Future<void>.delayed(Duration.zero);

    // Cabría por concurrencia, pero es de fondo y hay algo urgente corriendo.
    expect(started, [JobType.training]);
    expect(jobOf(queue, background).status, JobStatus.queued);

    gate.open();
    await Future<void>.delayed(Duration.zero);

    expect(started, [JobType.training, JobType.duplicateScan]);

    await queue.dispose();
  });

  test('cancelar uno no toca a los demás', () async {
    final queue = JobQueue(concurrency: 2);
    final gate = _Gate();
    var survivorFinished = false;

    queue.register(JobType.recognition, (context) async {
      await Future.any([gate.completer.future, context.token.whenCancelled]);
      context.token.throwIfCancelled();
      survivorFinished = true;
    });

    final doomed = queue.enqueue(type: JobType.recognition);
    final survivor = queue.enqueue(type: JobType.recognition);

    await Future<void>.delayed(Duration.zero);

    queue.cancel(doomed);
    await Future<void>.delayed(Duration.zero);

    expect(jobOf(queue, doomed).status, JobStatus.cancelled);
    expect(jobOf(queue, survivor).status, JobStatus.running);

    gate.open();
    await Future<void>.delayed(Duration.zero);

    expect(jobOf(queue, survivor).status, JobStatus.completed);
    expect(survivorFinished, isTrue);

    await queue.dispose();
  });

  test('cancelar lo que aún no ha arrancado lo cierra sin ejecutarlo', () async {
    final queue = JobQueue(concurrency: 1);
    final started = <String>[];
    final gate = _Gate();

    queue.register(JobType.recognition, (context) async {
      started.add(context.job.id);
      await gate.completer.future;
    });

    final running = queue.enqueue(type: JobType.recognition);
    final waiting = queue.enqueue(type: JobType.recognition);

    await Future<void>.delayed(Duration.zero);
    queue.cancel(waiting);

    expect(jobOf(queue, waiting).status, JobStatus.cancelled);

    gate.open();
    await Future<void>.delayed(Duration.zero);

    // Nunca llegó a ejecutarse.
    expect(started, [running]);

    await queue.dispose();
  });

  test('un trabajo que revienta se queda en fallido y la cola sigue', () async {
    final queue = JobQueue(concurrency: 1);

    queue.register(JobType.training, (context) async {
      throw StateError('se ha roto');
    });
    queue.register(JobType.recognition, (context) async {});

    final broken = queue.enqueue(type: JobType.training);
    final next = queue.enqueue(type: JobType.recognition);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(jobOf(queue, broken).status, JobStatus.failed);
    expect(jobOf(queue, broken).error, contains('se ha roto'));
    expect(jobOf(queue, next).status, JobStatus.completed);

    await queue.dispose();
  });

  test('un tipo sin nadie que lo ejecute no se queda esperando', () async {
    final queue = JobQueue();

    final orphan = queue.enqueue(type: JobType.duplicateScan);

    expect(jobOf(queue, orphan).status, JobStatus.failed);

    await queue.dispose();
  });

  test('el avance llega a quien escucha', () async {
    final queue = JobQueue();
    final gate = _Gate();

    queue.register(JobType.hashing, (context) async {
      context.report(3, total: 10);
      await gate.completer.future;
    });

    final id = queue.enqueue(type: JobType.hashing);
    await Future<void>.delayed(Duration.zero);

    expect(jobOf(queue, id).done, 3);
    expect(jobOf(queue, id).total, 10);
    expect(jobOf(queue, id).progress, closeTo(0.3, 0.001));

    gate.open();
    await queue.dispose();
  });

  // **Un cambio sólo de estado tiene que notificar.** La cola descarta la
  // actualización si el trabajo compara igual, así que sin `stage` entre lo que
  // se compara, decir «Cancelando…» sin mover la barra no llegaba a la pantalla:
  // el trabajo seguía diciendo lo de antes.
  test('cambiar sólo en qué se está también se cuenta', () async {
    final queue = JobQueue();
    final gate = _Gate();
    final seen = <String?>[];

    queue.register(JobType.hashing, (context) async {
      context.report(1, total: 10, stage: 'contando');
      await Future<void>.delayed(Duration.zero);
      context.report(1, total: 10, stage: 'cancelando');
      await gate.completer.future;
    });

    final id = queue.enqueue(type: JobType.hashing);
    final subscription = queue.changes.listen((jobs) {
      for (final job in jobs) {
        if (job.id == id) seen.add(job.stage);
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(seen, contains('cancelando'));

    gate.open();
    await subscription.cancel();
    await queue.dispose();
  });

  test('sin total no se finge un porcentaje', () {
    final job = Job(
      id: 'x',
      type: JobType.recognition,
      createdAt: DateTime.now(),
    );

    expect(job.progress, isNull);
  });

  test('lo que llega por el flujo es la cola entera, terminados incluidos',
      () async {
    // Es la trampa en la que cayó el indicador de la pantalla de importación:
    // se suscribía a `changes` y contaba los trabajos de su tipo sin mirar el
    // estado, así que la importación recién terminada —que se queda en la
    // historia— lo dejaba encendido para siempre. Salir de la pantalla y volver
    // lo apagaba, porque al entrar se lee `activeJobs`, que sí filtra.
    //
    // Quien escuche el flujo tiene que filtrar por su cuenta, y esto es lo que
    // lo deja dicho.
    final queue = JobQueue();
    queue.register(JobType.mediaImport, (context) async {});

    final emissions = <List<Job>>[];
    final subscription = queue.changes.listen(emissions.add);

    queue.enqueue(type: JobType.mediaImport);
    await Future<void>.delayed(Duration.zero);

    expect(queue.activeJobs, isEmpty);

    final last = emissions.last;
    expect(last, hasLength(1));
    expect(last.single.status, JobStatus.completed);
    expect(last.any((job) => job.status.isActive), isFalse);

    await subscription.cancel();
    await queue.dispose();
  });

  test('los terminados se pueden quitar de en medio', () async {
    final queue = JobQueue();
    queue.register(JobType.recognition, (context) async {});

    queue.enqueue(type: JobType.recognition);
    await Future<void>.delayed(Duration.zero);

    expect(queue.jobs, hasLength(1));

    queue.clearFinished();

    expect(queue.jobs, isEmpty);
    expect(queue.activeJobs, isEmpty);

    await queue.dispose();
  });
}
