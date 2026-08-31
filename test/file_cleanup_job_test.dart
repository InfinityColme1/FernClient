// Borrar del disco los ficheros de lo que se acaba de vaciar.
//
// Va por la cola de tareas y no en el diálogo que lo pide porque **son miles**:
// vaciar una biblioteca entera con sus ficheros es una operación de minutos, y
// hacerla en el hilo de la interfaz deja la ventana bloqueada sin poder decir
// por dónde va ni cuánto queda.
//
// Lo que hay que sostener:
//
// - **Un fichero que no se deja borrar no para al resto.** Lo que se pidió fue
//   vaciar; que el antivirus tenga uno abierto no puede dejar los otros mil
//   donde estaban.
// - **Se puede parar.** Es un trabajo largo como cualquier otro.
// - **Las carpetas vacías se podan.** Sin eso, vaciar la biblioteca deja el
//   árbol de carpetas entero en pie y parece que no se ha borrado nada.

import 'dart:io';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/settings/data/services/file_deletion_job_runner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late _FakeOrganizer organizer;
  late FileDeletionJobRunner runner;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_cleanup');
    organizer = _FakeOrganizer();
    runner = FileDeletionJobRunner(organizer: organizer);
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<String> file(String name) async {
    final target = File(p.join(directory.path, name));
    await target.writeAsBytes(const [1, 2, 3]);

    return target.path;
  }

  /// El contexto del trabajo, con lo que va contando y su señal de parada.
  ({JobContext context, List<int> reported, CancellationToken token}) job(
    List<String> paths,
  ) {
    final reported = <int>[];
    final token = CancellationToken();

    return (
      token: token,
      reported: reported,
      context: JobContext(
        job: Job(
          id: 'job-1',
          type: JobType.fileCleanup,
          createdAt: DateTime(2026),
          payload: {FileDeletionJobRunner.pathsKey: paths},
        ),
        token: token,
        report: (done, {total, stage}) => reported.add(done),
      ),
    );
  }

  test('borra lo que se le da', () async {
    final one = await file('uno.jpg');
    final other = await file('dos.jpg');

    await runner.run(job([one, other]).context);

    expect(await File(one).exists(), isFalse);
    expect(await File(other).exists(), isFalse);
  });

  test('y va contando por dónde va', () async {
    final paths = [await file('uno.jpg'), await file('dos.jpg')];

    final one = job(paths);
    await runner.run(one.context);

    expect(one.reported, [0, 1, 2]);
  });

  // Que el antivirus tenga uno abierto no puede dejar los otros mil donde
  // estaban.
  test('uno que ya no está no para al resto', () async {
    final missing = p.join(directory.path, 'no_existe.jpg');
    final real = await file('uno.jpg');

    await runner.run(job([missing, real]).context);

    expect(await File(real).exists(), isFalse);
  });

  test('parar deja lo que quedaba donde estaba', () async {
    final paths = [await file('uno.jpg'), await file('dos.jpg')];

    final one = job(paths);
    one.token.cancel();

    await runner.run(one.context);

    expect(await File(paths.first).exists(), isTrue);
  });

  // Sin esto, vaciar la biblioteca deja el árbol de carpetas entero en pie con
  // todos los cajones vacíos.
  test('las carpetas que se quedan vacías se podan', () async {
    await runner.run(job([await file('uno.jpg')]).context);

    expect(organizer.pruned, 1);
  });

  test('sin rutas no hace nada', () async {
    await runner.run(job(const []).context);

    expect(organizer.pruned, 0);
  });
}

class _FakeOrganizer implements MediaFileOrganizer {
  int pruned = 0;

  @override
  Future<void> removeEmptyFolders() async => pruned++;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
