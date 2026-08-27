// Las preguntas aparcadas en la lista de tareas.
//
// Una publicacion con varios enlaces es una pregunta, no trabajo: no hay nada
// que ejecutar hasta que alguien conteste. Por eso su tipo de tarea **no se
// ejecuta nunca** y se queda esperando en la lista.
//
// Lo que se comprueba aqui es lo que romperia la aplicacion entera si fallara:
// que cinco preguntas sin contestar no dejen la cola atascada. Con dos huecos y
// cinco preguntas ocupandolos, no volveria a correr nada.

import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/media/data/services/pending_link_reviews.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('la cola', () {
    late JobQueue queue;

    setUp(() => queue = JobQueue());
    tearDown(() => queue.dispose());

    test('una pregunta no se ejecuta nunca', () async {
      var ran = 0;
      queue.register(JobType.linkReview, (_) async => ran++);

      queue.enqueue(type: JobType.linkReview);
      await Future<void>.delayed(Duration.zero);

      expect(ran, 0, reason: 'no hay nada que hacer hasta que se conteste');
      expect(queue.jobs.single.status, JobStatus.queued);
    });

    test('y no le quita el turno a lo que si es trabajo', () async {
      var ran = 0;
      queue.register(JobType.linkReview, (_) async => ran++);
      queue.register(JobType.mediaImport, (_) async => ran++);

      // Mas preguntas que huecos tiene la cola: si ocuparan turno, lo de abajo
      // no llegaria a correr nunca.
      for (var i = 0; i < 5; i++) {
        queue.enqueue(type: JobType.linkReview);
      }
      queue.enqueue(type: JobType.mediaImport);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(ran, 1);
    });

    test('cancelarla la cierra', () {
      final id = queue.enqueue(type: JobType.linkReview);

      queue.cancel(id);

      expect(queue.jobs.single.status, JobStatus.cancelled);
    });
  });

  group('lo aparcado', () {
    const link = PostLink(
      url: 'https://cdn.test/una.jpg',
      kind: PostLinkKind.media,
    );

    LinkReview review(String jobId) => LinkReview(
          jobId: jobId,
          postTitle: 'Una',
          links: const [link],
          source: ImportSource.pawchive,
          namePrefix: 'pawchive_1_link',
        );

    test('se guarda y se encuentra por su tarea', () {
      final reviews = PendingLinkReviews()..add(review('job-1'));

      expect(reviews.has('job-1'), isTrue);
      expect(reviews.of('job-1')?.postTitle, 'Una');
      expect(reviews.has('job-2'), isFalse);
    });

    test('quitar la tarea se lleva la pregunta', () {
      final reviews = PendingLinkReviews()
        ..add(review('job-1'))
        ..add(review('job-2'));

      // Quitar la tarea de la lista es decir que esa pregunta no interesa: sin
      // esto quedarian aparcadas preguntas a las que ya no se puede llegar.
      reviews.keepOnly({'job-2'});

      expect(reviews.has('job-1'), isFalse);
      expect(reviews.has('job-2'), isTrue);
    });

    test('avisa cuando cambia, que es lo que repinta la lista', () {
      var changes = 0;
      final reviews = PendingLinkReviews()..addListener(() => changes++);

      reviews.add(review('job-1'));
      reviews.remove('job-1');
      reviews.remove('job-1');

      expect(changes, 2, reason: 'quitar lo que no esta no cambia nada');
    });
  });
}
