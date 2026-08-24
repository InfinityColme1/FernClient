// La pantalla de contenido repetido por dentro.
//
// Lo que se comprueba aquí es sobre todo lo que protege al usuario de sí mismo:
// que no se pueda aplicar sin haber elegido copia, que resolver un grupo lleve
// al siguiente sin volver arriba, y que un fallo a media faena deje la pantalla
// como estaba en vez de dar por hecho algo que no pasó.

import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_details_loader.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/usecases/apply_duplicate_group_usecase.dart';
import 'package:Fern/features/duplicates/presentation/blocs/duplicates_bloc.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:flutter_test/flutter_test.dart';

MediaEntity _media(int id) => MediaEntity(
      id: id,
      path: 'C:/$id.jpg',
      downloaded: DateTime(2026),
      creator: const CreatorEntity(id: 1, name: 'Unknown'),
    );

DuplicateGroupSummary _group(int id, List<int> mediaIds) =>
    DuplicateGroupSummary(
      id: id,
      mediaIds: mediaIds,
      maxDistance: 2,
      foundAt: DateTime(2026),
    );

void main() {
  late _FakeDuplicates duplicates;
  late _FakeMedia media;
  late JobQueue jobs;
  late Map<int, int> pixelsById;

  /// Lo que hay anotado de la última vez que se miró la biblioteca. Lo sella
  /// quien escanea, así que las pruebas lo mueven a mano.
  DateTime? lastScanAt;

  setUp(() {
    duplicates = _FakeDuplicates();
    media = _FakeMedia();
    jobs = JobQueue();
    pixelsById = {};
    lastScanAt = null;
  });

  tearDown(() => jobs.dispose());

  DuplicatesBloc bloc() {
    return DuplicatesBloc(
      repository: duplicates,
      jobs: jobs,
      details: DuplicateDetailsLoader(
        details: (id) async => DataSuccess(_media(id)),
        // El ancho decide la preselección: así cada prueba puede decir cuál
        // debería salir marcada sin depender de ficheros de verdad.
        pixels: (path) async {
          final id = int.parse(path.split('/').last.split('.').first);

          return (width: pixelsById[id] ?? 100, height: 100);
        },
        weight: (_) => 1000,
      ),
      apply: ApplyDuplicateGroupUseCase(
        media: media,
        duplicates: duplicates,
        fernies: _NoFernies(),
      ),
      dismiss: DismissDuplicateGroupUseCase(duplicates),
      lastScan: () => lastScanAt,
    );
  }

  Future<DuplicatesBloc> loaded() async {
    final subject = bloc()..add(const LoadDuplicatesEvent());
    await Future<void>.delayed(Duration.zero);

    return subject;
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('al abrir', () {
    test('lee los grupos guardados', () async {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];

      final subject = await loaded();

      expect(subject.state.groups, hasLength(2));
      expect(subject.state.isLoading, isFalse);
      await subject.close();
    });

    test('abre el primero sin que haya que pulsarlo', () async {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];

      final subject = await loaded();

      // Entrar y encontrarse una lista con la parte útil en blanco obliga a un
      // clic que no decide nada.
      expect(subject.state.selectedGroupId, 1);
      expect(subject.state.copies.map((one) => one.mediaId), [10, 11]);
      await subject.close();
    });

    test('sin grupos no se abre nada', () async {
      final subject = await loaded();

      expect(subject.state.selectedGroupId, isNull);
      expect(subject.state.canApply, isFalse);
      await subject.close();
    });

    test('marca la copia que propone la heurística', () async {
      duplicates.groups = [_group(1, [10, 11])];
      pixelsById = {11: 1920};

      final subject = await loaded();

      expect(subject.state.keeperId, 11);
      await subject.close();
    });
  });

  group('elegir', () {
    test('se puede cambiar la copia que se conserva', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();
      subject.add(const ChooseDuplicateKeeperEvent(11));
      await settle();

      expect(subject.state.keeperId, 11);
      await subject.close();
    });

    test('cambiar de grupo trae sus copias', () async {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];

      final subject = await loaded();
      subject.add(const SelectDuplicateGroupEvent(2));
      await settle();

      expect(subject.state.selectedGroupId, 2);
      expect(subject.state.copies.map((one) => one.mediaId), [20, 21]);
      await subject.close();
    });

    test('la fusión viene encendida', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();

      // Lo que se pierde al no fusionar no se recupera, así que lo que hay que
      // decidir a mano es apagarla, no encenderla.
      expect(subject.state.mergeMetadata, isTrue);

      subject.add(const ToggleDuplicateMergeEvent(false));
      await settle();

      expect(subject.state.mergeMetadata, isFalse);
      await subject.close();
    });
  });

  group('aplicar', () {
    test('conserva la elegida y tira las demás', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();
      subject
        ..add(const ChooseDuplicateKeeperEvent(10))
        ..add(const ApplyDuplicateGroupEvent());
      await settle();

      expect(media.trashed, [11]);
      expect(duplicates.resolved, [1]);
      await subject.close();
    });

    test('salta al grupo siguiente sin volver a la lista', () async {
      duplicates.groups = [
        _group(1, [10, 11]),
        _group(2, [20, 21]),
      ];

      final subject = await loaded();
      subject.add(const ApplyDuplicateGroupEvent());
      await settle();

      // Es lo que hace tolerable revisar cuarenta grupos seguidos.
      expect(subject.state.groups.map((one) => one.id), [2]);
      expect(subject.state.selectedGroupId, 2);
      expect(subject.state.copies.map((one) => one.mediaId), [20, 21]);
      await subject.close();
    });

    test('resolver uno de en medio abre el de después, no el primero', () async {
      duplicates.groups = [
        _group(1, [10, 11]),
        _group(2, [20, 21]),
        _group(3, [30, 31]),
      ];

      final subject = await loaded();
      subject.add(const SelectDuplicateGroupEvent(2));
      await settle();

      subject.add(const ApplyDuplicateGroupEvent());
      await settle();

      // Volver arriba obliga a buscar otra vez por dónde se iba, y con cuarenta
      // grupos eso es lo que hace que se abandone la revisión.
      expect(subject.state.selectedGroupId, 3);
      await subject.close();
    });

    test('el último resuelto deja la pantalla sin nada abierto', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();
      subject.add(const ApplyDuplicateGroupEvent());
      await settle();

      expect(subject.state.groups, isEmpty);
      expect(subject.state.selectedGroupId, isNull);
      expect(subject.state.copies, isEmpty);
      await subject.close();
    });

    test('sin copia elegida no se aplica', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();
      // Aplicar sin elegir mandaría el grupo entero a la papelera.
      expect(subject.state.canApply, isTrue);

      subject.emit(subject.state.copyWith(keeperId: null));
      expect(subject.state.canApply, isFalse);

      subject.add(const ApplyDuplicateGroupEvent());
      await settle();

      expect(media.trashed, isEmpty);
      await subject.close();
    });

    test('si falla, el grupo se queda donde estaba', () async {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];
      media.brokenTrash = true;

      final subject = await loaded();
      subject.add(const ApplyDuplicateGroupEvent());
      await settle();

      // Dar por hecho lo que no pasó haría desaparecer un grupo con sus
      // duplicados dentro.
      expect(subject.state.groups, hasLength(2));
      expect(subject.state.selectedGroupId, 1);
      expect(subject.state.isApplying, isFalse);
      await subject.close();
    });
  });

  group('no son duplicados', () {
    test('descarta el grupo y pasa al siguiente', () async {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];

      final subject = await loaded();
      subject.add(const DismissCurrentGroupEvent());
      await settle();

      expect(duplicates.dismissed, [1]);
      expect(media.trashed, isEmpty);
      expect(subject.state.selectedGroupId, 2);
      await subject.close();
    });

    test('descartar no borra nada aunque haya copia elegida', () async {
      duplicates.groups = [_group(1, [10, 11])];

      final subject = await loaded();
      subject
        ..add(const ChooseDuplicateKeeperEvent(10))
        ..add(const DismissCurrentGroupEvent());
      await settle();

      expect(media.trashed, isEmpty);
      expect(duplicates.resolved, isEmpty);
      await subject.close();
    });
  });

  group('el escaneo', () {
    test('lo pide con prioridad alta y lo dice mientras dura', () async {
      // Un trabajo que no termina solo: sin esto la cola daría el escaneo por
      // acabado antes de poder mirar si la pantalla lo estaba enseñando.
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (_) => running.future);

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      // Lo acaba de pedir el usuario y está mirando la pantalla.
      expect(jobs.jobs.single.priority, JobPriority.high);
      expect(subject.state.isScanning, isTrue);

      running.complete();
      await settle();

      expect(subject.state.isScanning, isFalse);
      await subject.close();
    });

    test('no se pide dos veces seguidas', () async {
      final subject = await loaded();
      subject
        ..add(const ScanForDuplicatesEvent())
        ..add(const ScanForDuplicatesEvent());
      await settle();

      expect(jobs.jobs, hasLength(1));
      await subject.close();
    });

    test('el avance del trabajo llega a la pantalla', () async {
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (context) {
        context.report(30, total: 120);

        return running.future;
      });

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      // Sin esto, lo único que dice que se está trabajando es un aviso que se
      // va a los tres segundos y una tarea en la barra que puede durar dos.
      expect(subject.state.scanDone, 30);
      expect(subject.state.scanTotal, 120);
      expect(subject.state.scanProgress, closeTo(0.25, 0.001));

      running.complete();
      await settle();

      expect(subject.state.scanTotal, 0);
      await subject.close();
    });
  });

  // Un escaneo que no encuentra nada deja la pantalla exactamente igual que
  // estaba. Sin decir en qué ha quedado, pulsar el botón y que no pase nada es
  // indistinguible de pulsarlo y que no funcione.
  group('el parte de lo que ha quedado', () {
    /// Un escaneo del usuario que corre y termina dejando la lista en [after].
    Future<DuplicatesBloc> scanEnding({
      List<DuplicateGroupSummary> after = const [],
      Object? failure,
    }) async {
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (_) => running.future);

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      duplicates.groups = after;
      lastScanAt = DateTime(2026, 8, 24, 12, 52);

      if (failure == null) {
        running.complete();
      } else {
        running.completeError(failure);
      }

      await settle();

      return subject;
    }

    test('sin repetidos, lo dice', () async {
      final subject = await scanEnding();

      expect(subject.state.scanResults, 1);
      expect(subject.state.outcome, DuplicateScanOutcome.clean);
      await subject.close();
    });

    test('lo que aparece de nuevo se cuenta', () async {
      duplicates.groups = [_group(1, [10, 11])];
      final subject = await scanEnding(
        after: [_group(1, [10, 11]), _group(2, [20, 21])],
      );

      // Uno solo: el que ya estaba conserva su identificador al reconciliarse,
      // y volver a verlo no es haberlo encontrado.
      expect(subject.state.outcome, DuplicateScanOutcome.found);
      expect(subject.state.freshGroups, 1);
      await subject.close();
    });

    test('nada nuevo no es lo mismo que nada que revisar', () async {
      duplicates.groups = [_group(1, [10, 11])];
      final subject = await scanEnding(after: [_group(1, [10, 11])]);

      expect(subject.state.outcome, DuplicateScanOutcome.nothingNew);
      expect(subject.state.freshGroups, 0);
      await subject.close();
    });

    // Dar por limpia una biblioteca que no se ha llegado a mirar es la peor de
    // las respuestas posibles: es la que hace que nadie vuelva a mirarla.
    test('lo que falla no sale como biblioteca limpia', () async {
      final subject = await scanEnding(failure: Exception('sin disco'));

      expect(subject.state.outcome, DuplicateScanOutcome.failed);
      await subject.close();
    });

    test('parar el escaneo también se dice', () async {
      jobs.register(
        JobType.duplicateScan,
        (context) async {
          while (!context.token.isCancelled) {
            await Future<void>.delayed(Duration.zero);
          }

          context.token.throwIfCancelled();
        },
      );

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      jobs.cancel(jobs.activeJobs.single.id);
      await settle();

      expect(subject.state.outcome, DuplicateScanOutcome.cancelled);
      await subject.close();
    });

    // Pedir un escaneo aparta el de fondo, y el de fondo puede tardar en darse
    // por muerto más de lo que tarda el nuevo en acabar. Mirando el último
    // trabajo terminado, esa cancelación se colaba como el parte de una
    // búsqueda que había ido bien.
    test('cancelar el de fondo no ensucia el parte del que se pidió', () async {
      final background = Completer<void>();
      final user = Completer<void>();
      var first = true;

      jobs.register(JobType.duplicateScan, (_) {
        if (first) {
          first = false;

          return background.future;
        }

        return user.future;
      });

      jobs.enqueue(type: JobType.duplicateScan, priority: JobPriority.low);
      final subject = await loaded();
      await settle();

      subject.add(const ScanForDuplicatesEvent());
      await settle();

      // El del usuario acaba antes de que el de fondo se entere de que lo han
      // parado.
      user.complete();
      await settle();
      background.complete();
      await settle();

      expect(subject.state.outcome, DuplicateScanOutcome.clean);
      expect(subject.state.scanResults, 1);
      await subject.close();
    });

    test('el de fondo no da parte de nada', () async {
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (_) => running.future);
      jobs.enqueue(type: JobType.duplicateScan, priority: JobPriority.low);

      final subject = await loaded();
      await settle();

      running.complete();
      await settle();

      // Nadie lo ha pedido ni lo está esperando: un aviso aquí sale encima de
      // lo que sea que se estuviera haciendo.
      expect(subject.state.scanResults, 0);
      expect(subject.state.outcome, isNull);
      await subject.close();
    });

    test('la fecha del último escaneo se relee al terminar', () async {
      final subject = await scanEnding();

      // Es lo que se queda en la pantalla cuando el aviso se va: sin ella, «no
      // hay contenido repetido» no dice si alguien ha llegado a mirar.
      expect(subject.state.lastScan, DateTime(2026, 8, 24, 12, 52));
      await subject.close();
    });

    test('sin haber escaneado nunca, no hay fecha que enseñar', () async {
      final subject = await loaded();

      expect(subject.state.lastScan, isNull);
      await subject.close();
    });
  });

  group('cuando el escaneo se lleva por delante lo que se estaba mirando', () {
    setUp(() {
      duplicates.groups = [_group(1, [10, 11]), _group(2, [20, 21])];
    });

    /// Un escaneo que deja la lista en [after].
    Future<DuplicatesBloc> scanLeaving(List<DuplicateGroupSummary> after) async {
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (_) => running.future);

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      duplicates.groups = after;
      running.complete();
      await settle();

      return subject;
    }

    // Bajar el listón deja fuera de golpe todo lo que ya no lo cumple, y con
    // ello el grupo que estaba abierto. Sin esto, la mitad derecha se quedaba en
    // blanco con la lista llena y había que elegir a mano.
    test('abre otro si el que se miraba ya no está', () async {
      final subject = await scanLeaving([_group(9, [7, 8])]);

      expect(subject.state.selectedGroupId, 9);
      expect(subject.state.copies, hasLength(2));
      await subject.close();
    });

    test('no cambia el que se estaba mirando si sigue ahí', () async {
      final running = Completer<void>();
      jobs.register(JobType.duplicateScan, (_) => running.future);

      final subject = await loaded();
      await settle();

      // El segundo de la lista, para que no coincida con el que se abriría solo.
      subject.add(SelectDuplicateGroupEvent(duplicates.groups[1].id));
      await settle();
      final open = subject.state.selectedGroupId;

      subject.add(const ScanForDuplicatesEvent());
      await settle();
      running.complete();
      await settle();

      // Cambiarle el grupo de debajo a quien está comparando le haría aplicar
      // sobre otra cosa.
      expect(subject.state.selectedGroupId, open);
      await subject.close();
    });

    test('sin grupos que queden, no se queda nada abierto', () async {
      final subject = await scanLeaving(const []);

      expect(subject.state.selectedGroupId, isNull);
      expect(subject.state.copies, isEmpty);
      await subject.close();
    });
  });

  group('el escaneo de fondo no estorba', () {
    /// Un escaneo de los que lanza la aplicación por su cuenta, en marcha.
    ///
    /// El ejecutor mira su señal de parada, como hace el de verdad: la cola
    /// avisa, pero es quien trabaja el que decide dejarlo.
    Future<DuplicatesBloc> withBackgroundScan() async {
      jobs.register(JobType.duplicateScan, (context) async {
        while (!context.token.isCancelled) {
          await Future<void>.delayed(Duration.zero);
        }

        context.token.throwIfCancelled();
      });
      jobs.enqueue(type: JobType.duplicateScan, priority: JobPriority.low);

      final subject = await loaded();
      await settle();

      return subject;
    }

    // El de fondo puede tardar horas la primera vez. Dejar el botón muerto todo
    // ese rato deja sin salida a quien acaba de importar y quiere mirar ya.
    test('el botón sigue disponible con uno de fondo en marcha', () async {
      final subject = await withBackgroundScan();

      expect(subject.state.canScan, isTrue);
      await subject.close();
    });

    test('pedirlo aparta el de fondo y lo relanza con prisa', () async {
      final subject = await withBackgroundScan();

      subject.add(const ScanForDuplicatesEvent());
      await settle();

      final alive = jobs.activeJobs
          .where((job) => job.type == JobType.duplicateScan)
          .toList();

      // Uno solo, y con prisa: el mismo trabajo dos veces sería hashear la
      // biblioteca entera por duplicado. Cortarlo no pierde nada, porque las
      // huellas se guardan una a una según se calculan.
      expect(alive, hasLength(1));
      expect(alive.single.priority, JobPriority.high);
      await subject.close();
    });

    test('con uno del usuario en marcha, el botón sí se bloquea', () async {
      jobs.register(JobType.duplicateScan, (_) => Completer<void>().future);

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      expect(subject.state.canScan, isFalse);
      await subject.close();
    });

    // El aviso responde a la pulsación. Con la condición anterior —«ha empezado
    // a escanear»— le salía también a quien no había pedido nada.
    test('el de fondo no cuenta como pulsación', () async {
      final subject = await withBackgroundScan();

      expect(subject.state.scanRequests, 0);
      expect(subject.state.isUserScan, isFalse);
      await subject.close();
    });

    test('pulsar el botón sí la cuenta', () async {
      jobs.register(JobType.duplicateScan, (_) => Completer<void>().future);

      final subject = await loaded();
      subject.add(const ScanForDuplicatesEvent());
      await settle();

      expect(subject.state.scanRequests, 1);
      await subject.close();
    });
  });
}

class _FakeDuplicates implements DuplicateRepository {
  List<DuplicateGroupSummary> groups = const [];

  final resolved = <int>[];
  final dismissed = <int>[];

  @override
  Future<DataState<List<DuplicateGroupSummary>>> getGroupsToReview() async =>
      DataSuccess(groups);

  @override
  Future<DataState<bool>> markResolved(int groupId) async {
    resolved.add(groupId);

    return const DataSuccess(true);
  }

  @override
  Future<DataState<bool>> markDismissed(int groupId) async {
    dismissed.add(groupId);

    return const DataSuccess(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeMedia implements LocalMediaRepository {
  final saved = <MediaEntity>[];
  final trashed = <int>[];

  var brokenTrash = false;

  @override
  Future<DataState> saveMedia(MediaEntity media) async {
    saved.add(media);

    return const DataSuccess(null);
  }

  @override
  Future<DataState> markMediaListAsDeleted(List<int> ids) async {
    if (brokenTrash) return DataException(Exception('roto'));

    trashed.addAll(ids);

    return const DataSuccess(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Sin fernies marcados: lo que se comprueba aquí es el bloc, no la fusión.
class _NoFernies implements FernieRepository {
  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(int mediaId) async =>
      const DataSuccess([]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
