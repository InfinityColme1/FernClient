// Reconocer solo lo que acaba de importarse.
//
// Lo que se comprueba aquí es sobre todo lo que **no** hace: no encolar un
// trabajo por fichero, no ponerse a trabajar con el ajuste apagado, y no
// adelantar a un reconocimiento que el usuario sí ha pedido.

import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/features/recognition/data/services/import_recognition_hook.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeLauncher launcher;
  var enabled = true;

  const wait = Duration(seconds: 3);

  ImportRecognitionHook hookWith({int batchMax = 200}) {
    return ImportRecognitionHook(
      launcher: launcher,
      isEnabled: () => enabled,
      name: () => 'Recién importado',
      wait: wait,
      batchMax: batchMax,
    );
  }

  setUp(() {
    launcher = _FakeLauncher();
    enabled = true;
  });

  group('agrupar', () {
    test('lo que llega junto sale de una vez', () {
      fakeAsync((async) {
        final hook = hookWith();

        hook.mediaArrived(1);
        hook.mediaArrived(2);
        hook.mediaArrived(3);

        // Nada todavía: la importación sigue soltando ficheros.
        expect(launcher.batches, isEmpty);

        async.elapse(wait);

        // Un trabajo con los tres dentro, no tres trabajos de uno.
        expect(launcher.batches, [
          [1, 2, 3]
        ]);
      });
    });

    test('cada contenido nuevo reinicia la espera', () {
      fakeAsync((async) {
        final hook = hookWith();

        hook.mediaArrived(1);
        async.elapse(const Duration(seconds: 2));
        hook.mediaArrived(2);
        async.elapse(const Duration(seconds: 2));

        // Han pasado cuatro segundos, pero sólo dos desde el último.
        expect(launcher.batches, isEmpty);

        async.elapse(const Duration(seconds: 1));

        expect(launcher.batches, [
          [1, 2]
        ]);
      });
    });

    test('el mismo contenido dos veces cuenta una', () {
      fakeAsync((async) {
        final hook = hookWith();

        hook.mediaArrived(7);
        hook.mediaArrived(7);
        async.elapse(wait);

        expect(launcher.batches, [
          [7]
        ]);
      });
    });

    test('sin nada que mandar no se encola nada', () {
      fakeAsync((async) {
        hookWith();

        async.elapse(const Duration(minutes: 1));

        expect(launcher.batches, isEmpty);
      });
    });
  });

  group('el tope', () {
    test('con el tope lleno se manda sin esperar', () {
      fakeAsync((async) {
        final hook = hookWith(batchMax: 3);

        hook.mediaArrived(1);
        hook.mediaArrived(2);
        hook.mediaArrived(3);

        // Sin tope, una importación de miles que dure media hora no dejaría
        // nada que revisar hasta el final.
        expect(launcher.batches, [
          [1, 2, 3]
        ]);

        async.elapse(wait);

        // Y lo mandado no se vuelve a mandar.
        expect(launcher.batches.length, 1);
      });
    });

    test('lo que sigue llegando va en la tanda siguiente', () {
      fakeAsync((async) {
        final hook = hookWith(batchMax: 2);

        hook.mediaArrived(1);
        hook.mediaArrived(2);
        hook.mediaArrived(3);
        async.elapse(wait);

        expect(launcher.batches, [
          [1, 2],
          [3],
        ]);
      });
    });
  });

  group('el ajuste', () {
    test('apagado no acumula nada', () {
      fakeAsync((async) {
        enabled = false;

        final hook = hookWith();
        hook.mediaArrived(1);

        expect(hook.pendingCount, 0);

        async.elapse(wait);

        expect(launcher.batches, isEmpty);
      });
    });

    test('apagarlo a mitad tira lo acumulado', () {
      fakeAsync((async) {
        final hook = hookWith();

        hook.mediaArrived(1);
        hook.mediaArrived(2);
        enabled = false;

        async.elapse(wait);

        // Apagarlo tiene que servir de algo también cuando ya se estaba
        // esperando: si no, el equipo se pone a trabajar justo después de que
        // el usuario haya dicho que no.
        expect(launcher.batches, isEmpty);
      });
    });
  });

  group('cómo se encola', () {
    test('con prioridad baja', () {
      fakeAsync((async) {
        hookWith().mediaArrived(1);
        async.elapse(wait);

        // Esto no lo ha pedido nadie. Un reconocimiento lanzado a mano está
        // esperando una respuesta y tiene que pasar por delante.
        expect(launcher.priorities, [JobPriority.low]);
      });
    });

    test('con nombre, para distinguirlo en la lista de tareas', () {
      fakeAsync((async) {
        hookWith().mediaArrived(1);
        async.elapse(wait);

        expect(launcher.names, ['Recién importado']);
      });
    });
  });

  group('al cerrar', () {
    test('no queda ningún aviso pendiente', () {
      fakeAsync((async) {
        final hook = hookWith();

        hook.mediaArrived(1);
        hook.dispose();

        async.elapse(const Duration(minutes: 1));

        // Un temporizador vivo después de cerrar encola un trabajo contra una
        // aplicación que ya no está.
        expect(launcher.batches, isEmpty);
      });
    });
  });
}

class _FakeLauncher implements RecognitionLauncher {
  final batches = <List<int>>[];
  final priorities = <JobPriority>[];
  final names = <String?>[];

  @override
  Future<RecognitionRequest> request(
    List<int> mediaIds, {
    String? name,
    JobPriority priority = JobPriority.high,
  }) async {
    batches.add(mediaIds);
    priorities.add(priority);
    names.add(name);

    return const RecognitionRequest(
      outcome: RecognitionOutcome.queued,
      readiness: RecognitionReadiness.ready,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
