// La importación como trabajo de fondo.
//
// Estaba dentro del bloc, y eso la ataba a la pantalla: no salía en la lista de
// tareas, no se podía parar desde ningún otro sitio, y cambiar de pantalla la
// dejaba corriendo a ciegas. Lo que se sostiene aquí es lo que hace falta para
// que esté en la cola sin perder nada por el camino: que lo que va llegando siga
// llegando a la rejilla de uno en uno, que los fallos también, que la tubería se
// cierre siempre —si no, la pantalla se queda con el indicador puesto para
// siempre— y que pararla desde el panel pare la descarga de verdad, no sólo la
// pinte como parada.

import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/services/import_feed.dart';
import 'package:Fern/features/media/data/services/import_job_runner.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Una fuente remota de mentira.
///
/// Apunta cuánto ha llegado a producir de verdad: es lo único que distingue
/// haber parado la descarga de haber dejado de mirarla.
class _Remote implements RemoteMediaRepository {
  final int count;
  final Exception? failsWith;

  int produced = 0;

  _Remote({this.count = 3, this.failsWith});

  @override
  Future<DataState<List<RemoteCreator>>> remoteCreators(ImportSource source) async =>
      const DataSuccess([]);

  @override
  Future<int?> countNewPosts(ImportSource source, RemoteCreator creator) async =>
      null;

  @override
  Stream<DataState<MediaSummaryEntity>> scanRemoteSource(
    ImportSource source, {
    bool untilLastImport = false,
    Set<String> creators = const {},
  }) async* {
    if (failsWith != null) {
      yield DataException(failsWith!);
      return;
    }

    for (var i = 0; i < count; i++) {
      produced++;
      yield DataSuccess(MediaSummaryEntity(
        id: i,
        path: 'C:/descargas/$i.jpg',
        importSource: source,
      ));
      // Un respiro entre uno y otro: sin él la fuente entera se recorre en un
      // solo turno y no hay hueco en el que parar.
      await Future<void>.delayed(Duration.zero);
    }
  }
}

/// El equipo no pinta nada aquí: la fuente que se recorre es remota.
class _UnusedLocal implements LocalMediaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImportFeed feed;
  late JobQueue queue;

  /// Monta la cola con una fuente que suelta [count] contenidos, o que falla.
  Future<_Remote> setUpQueue({int count = 3, Exception? failsWith}) async {
    SharedPreferences.setMockInitialValues({});

    final remote = _Remote(count: count, failsWith: failsWith);
    final preferences = PreferencesService(await SharedPreferences.getInstance());

    feed = ImportFeed();
    queue = JobQueue();

    final runner = ImportJobRunner(
      scan: ScanSourceUseCase(
        localMediaRepository: _UnusedLocal(),
        remoteMediaRepository: remote,
        preferencesService: preferences,
      ),
      feed: feed,
    );

    queue.register(JobType.mediaImport, runner.run);

    return remote;
  }

  tearDown(() => queue.dispose());

  /// Encola una importación de una fuente remota.
  String enqueueImport() => queue.enqueue(
        type: JobType.mediaImport,
        payload: const {
          ImportJobRunner.sourceKey: 'pixiv',
          ImportJobRunner.limitKey: 0,
        },
      );

  /// Espera a que el trabajo deje de estar vivo y devuelve cómo ha acabado.
  Future<JobStatus> waitFor(String id) async {
    await for (final jobs in queue.changes) {
      final job = jobs.firstWhere((one) => one.id == id);
      if (job.status.isFinished) return job.status;
    }

    throw StateError('la cola se ha cerrado sin terminar el trabajo');
  }

  test('lo que trae la fuente sale por la tubería, de uno en uno', () async {
    await setUpQueue(count: 3);

    final id = enqueueImport();
    final arrived = await feed.of(id).toList();

    expect(arrived.whereType<DataSuccess<MediaSummaryEntity>>(), hasLength(3));
  });

  test('la tubería se cierra al terminar', () async {
    await setUpQueue(count: 2);

    final id = enqueueImport();

    // `toList` sólo devuelve si el flujo termina: si la tubería se quedara
    // abierta, esto no volvería nunca y la pantalla se quedaría con el
    // indicador puesto.
    await feed.of(id).toList().timeout(const Duration(seconds: 5));
  });

  test('un fallo de la fuente también llega, no se lo traga la cola', () async {
    await setUpQueue(failsWith: Exception('la sesión ha caducado'));

    final id = enqueueImport();
    final arrived = await feed.of(id).toList();

    expect(arrived.single, isA<DataException<MediaSummaryEntity>>());
  });

  test('el avance cuenta lo que ha llegado, no lo que se ha intentado',
      () async {
    await setUpQueue(count: 4);

    final id = enqueueImport();
    await feed.of(id).drain<void>();

    expect(queue.jobs.firstWhere((job) => job.id == id).done, 4);
  });

  group('pararla desde el panel de tareas', () {
    test('para la descarga de verdad', () async {
      final remote = await setUpQueue(count: 100);

      final id = enqueueImport();

      // Se para en cuanto han llegado unos pocos, como quien lo ve en la lista
      // y decide que ya vale.
      final arrived = <DataState<MediaSummaryEntity>>[];
      await for (final result in feed.of(id)) {
        arrived.add(result);
        if (arrived.length == 3) queue.cancel(id);
      }

      // Lo que cuenta: la fuente ha dejado de producir. Sin esto se seguiría
      // descargando la cuenta entera con la pantalla diciendo que se ha parado.
      // Y lo hace por la señal del propio trabajo, que es la única que hay: con
      // la global de antes, parar ésta paraba también la de al lado.
      expect(remote.produced, lessThan(100));
    });

    test('y el trabajo queda como parado, no como terminado', () async {
      await setUpQueue(count: 100);

      final id = enqueueImport();
      final finished = waitFor(id);

      unawaited(feed.of(id).drain<void>());
      await Future<void>.delayed(Duration.zero);
      queue.cancel(id);

      expect(await finished, JobStatus.cancelled);
    });
  });
}
