// El trabajo que busca contenido repetido.
//
// Junta las dos mitades —calcular huellas y agrupar— porque desde fuera son una
// sola cosa: el usuario pide «buscar repetidos» y lo que espera es la lista. Lo
// que se comprueba aquí es el pegamento: que se agrupe con lo que se acaba de
// hashear, que se avise sólo cuando hay algo nuevo, y que nada de lo que pueda
// fallar por el camino tire abajo un escaneo ya guardado.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scan_runner.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scanner.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRepository repository;
  late List<String> hashed;
  late List<int> notified;
  late List<DateTime> stamped;
  late List<(int, int?)> progress;

  setUp(() {
    repository = _FakeRepository();
    hashed = [];
    notified = [];
    stamped = [];
    progress = [];
  });

  DuplicateScanRunner runner({int threshold = 8, bool includesMoving = true}) {
    return DuplicateScanRunner(
      repository: repository,
      threshold: () => threshold,
      includesMoving: () => includesMoving,
      notify: (count) async => notified.add(count),
      stamp: () async => stamped.add(DateTime(2026, 8, 24)),
      // Aquí mismo y no en otro hilo: levantar un isolate por prueba es lento y
      // lo que se comprueba es el pegamento, no dónde corre la comparación.
      grouper: (request) async => groupRequest(request),
      scanner: DuplicateScanner(
        read: (path) async {
          hashed.add(path);

          return null;
        },
        write: (_, __) async {},
      ),
    );
  }

  JobContext context({CancellationToken? token}) {
    return JobContext(
      job: Job(
        id: 'job-1',
        type: JobType.duplicateScan,
        createdAt: DateTime(2026),
      ),
      token: token ?? CancellationToken(),
      report: (done, {total, stage}) => progress.add((done, total)),
    );
  }

  group('lo normal', () {
    test('hashea lo que falta', () async {
      repository.hashable = [
        const HashableMedia(mediaId: 1, path: 'C:/uno.jpg'),
        const HashableMedia(mediaId: 2, path: 'C:/dos.jpg'),
      ];

      await runner().run(context());

      expect(hashed, ['C:/uno.jpg', 'C:/dos.jpg']);
    });

    test('guarda los grupos que encuentra', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 0x1234, pHash: 0x1234),
        HashedMedia(mediaId: 2, dHash: 0x1234, pHash: 0x1234),
      ];

      await runner().run(context());

      expect(repository.saved.single.group.mediaIds, [1, 2]);
    });

    test('el avance cuenta el hasheo, que es lo que tarda', () async {
      repository.hashable = [
        for (var id = 1; id <= 3; id++)
          HashableMedia(mediaId: id, path: 'C:/$id.jpg'),
      ];

      await runner().run(context());

      // Agrupar es un momento; hashear cuesta horas la primera vez. La barra
      // tiene que medir lo segundo o parecerá que no avanza.
      expect(progress, [(1, 3), (2, 3), (3, 3)]);
    });

    test('el listón se lee una sola vez', () async {
      var reads = 0;

      final subject = DuplicateScanRunner(
        repository: repository,
        grouper: (request) async => groupRequest(request),
        threshold: () {
          reads++;

          return 8;
        },
        scanner: DuplicateScanner(
          read: (_) async => null,
          write: (_, __) async {},
        ),
      );

      await subject.run(context());

      // Cambiarlo a media faena dejaría medio catálogo agrupado con un criterio
      // y medio con otro.
      expect(reads, 1);
    });

    test('usa el listón que se le dice', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 0, pHash: 0),
        HashedMedia(mediaId: 2, dHash: 0xff, pHash: 0xff),
      ];

      await runner(threshold: 2).run(context());
      expect(repository.saved, isEmpty);

      await runner(threshold: 10).run(context());
      expect(repository.saved, hasLength(1));
    });
  });

  // Un GIF se lee como cualquier imagen, pero de cada vídeo hay que abrir el
  // fichero y sacarle un fotograma. Con miles de vídeos eso es la diferencia
  // entre un escaneo largo y uno de toda la noche, y por eso se puede apagar.
  group('lo que se mueve', () {
    setUp(() {
      repository.hashable = [
        const HashableMedia(mediaId: 1, path: 'C:/una.jpg'),
        const HashableMedia(mediaId: 2, path: 'C:/otro.mp4'),
        const HashableMedia(mediaId: 3, path: 'C:/tercero.gif'),
      ];
    });

    test('de fábrica se mira todo', () async {
      await runner().run(context());

      expect(hashed, ['C:/una.jpg', 'C:/otro.mp4', 'C:/tercero.gif']);
    });

    test('apagado, ni vídeos ni GIF', () async {
      await runner(includesMoving: false).run(context());

      expect(hashed, ['C:/una.jpg']);
    });

    // Se lee al empezar cada escaneo, no al arrancar la aplicación: entre uno y
    // otro el usuario puede haberlo tocado.
    test('se lee en cada escaneo', () async {
      var includes = false;
      final subject = DuplicateScanRunner(
        repository: repository,
        threshold: () => 8,
        includesMoving: () => includes,
        grouper: (request) async => groupRequest(request),
        scanner: DuplicateScanner(
          read: (path) async {
            hashed.add(path);

            return null;
          },
          write: (_, __) async {},
        ),
      );

      await subject.run(context());
      expect(hashed, ['C:/una.jpg']);

      includes = true;
      hashed.clear();
      await subject.run(context());

      expect(hashed, ['C:/una.jpg', 'C:/otro.mp4', 'C:/tercero.gif']);
    });
  });

  group('el aviso', () {
    test('avisa de lo que ha aparecido', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];
      repository.freshCount = 1;

      await runner().run(context());

      expect(notified, [1]);
    });

    test('no avisa si no hay nada nuevo', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];
      repository.freshCount = 0;

      await runner().run(context());

      // Un aviso que lleva a una pantalla donde no hay nada que hacer deja de
      // mirarse, y con él los que sí valían la pena.
      expect(notified, isEmpty);
    });

    // La marca es lo que decide cuándo vuelve a tocar el escaneo automático.
    // Se sella también cuando no ha aparecido nada: lo que dice es cuándo se
    // miró, y mirar y no encontrar es haber mirado.
    test('sella la fecha aunque no haya aparecido nada', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];
      repository.freshCount = 0;

      await runner().run(context());

      expect(stamped, hasLength(1));
    });

    test('un escaneo cancelado no sella nada', () async {
      final token = CancellationToken();
      repository.hashable = [
        HashableMedia(mediaId: 1, path: 'C:/1.jpg'),
      ];

      final subject = DuplicateScanRunner(
        repository: repository,
        grouper: (request) async => groupRequest(request),
        stamp: () async => stamped.add(DateTime(2026, 8, 24)),
        scanner: DuplicateScanner(
          read: (_) async {
            token.cancel();

            return null;
          },
          write: (_, __) async {},
        ),
      );

      await expectLater(
        subject.run(context(token: token)),
        throwsA(isA<JobCancelledException>()),
      );

      // Sellarlo aquí dejaría la biblioteca sin escanear durante todo el
      // periodo por haber parado un escaneo a los dos segundos.
      expect(stamped, isEmpty);
    });

    test('si la marca falla, el escaneo se queda guardado igual', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];

      final subject = DuplicateScanRunner(
        repository: repository,
        grouper: (request) async => groupRequest(request),
        scanner: DuplicateScanner(
          read: (_) async => null,
          write: (_, __) async {},
        ),
        stamp: () async => throw StateError('sin preferencias'),
      );

      await subject.run(context());

      expect(repository.saved, isNotEmpty);
    });

    // Retirar lo que ya no se encuentra es lo que evita que la lista sólo crezca,
    // pero sólo vale si el escaneo ha comparado algo de verdad.
    test('pide retirar lo que ya no se encuentra', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];

      await runner().run(context());

      expect(repository.retired, isTrue);
    });

    test('sin una sola huella que mirar no retira nada', () async {
      repository.hashedMedia = const [];

      await runner().run(context());

      // «No he encontrado nada» sin nada que comparar no dice que no haya nada:
      // tirar lo pendiente por eso borraría trabajo por hacer.
      expect(repository.retired, isFalse);
    });

    test('si el aviso falla, el escaneo se queda guardado igual', () async {
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];
      repository.freshCount = 1;

      final subject = DuplicateScanRunner(
        repository: repository,
        grouper: (request) async => groupRequest(request),
        scanner: DuplicateScanner(
          read: (_) async => null,
          write: (_, __) async {},
        ),
        notify: (_) async => throw StateError('sin sonido'),
      );

      await subject.run(context());

      expect(repository.saved, isNotEmpty);
    });
  });

  group('lo que sale mal', () {
    test('sin poder leer la biblioteca no se inventa nada', () async {
      repository.brokenHashable = true;

      await runner().run(context());

      expect(hashed, isEmpty);
      expect(repository.saved, isEmpty);
    });

    test('sin poder leer las huellas no se guarda nada', () async {
      repository.brokenHashed = true;

      await runner().run(context());

      expect(repository.saved, isEmpty);
    });

    test('sin poder leer lo conocido se sigue igual', () async {
      repository.brokenKnown = true;
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];

      // Perder lo que se sabía es molesto —vuelven a proponerse los descartes—
      // pero no es motivo para no encontrar nada.
      await runner().run(context());

      expect(repository.saved, hasLength(1));
    });
  });

  group('parar', () {
    test('cancelar durante el hasheo no guarda grupos', () async {
      final token = CancellationToken();

      repository.hashable = [
        for (var id = 1; id <= 3; id++)
          HashableMedia(mediaId: id, path: 'C:/$id.jpg'),
      ];
      repository.hashedMedia = const [
        HashedMedia(mediaId: 1, dHash: 1, pHash: 1),
        HashedMedia(mediaId: 2, dHash: 1, pHash: 1),
      ];

      final subject = DuplicateScanRunner(
        repository: repository,
        grouper: (request) async => groupRequest(request),
        scanner: DuplicateScanner(
          read: (path) async {
            token.cancel();

            return null;
          },
          write: (_, __) async {},
        ),
      );

      await expectLater(
        subject.run(context(token: token)),
        throwsA(isA<JobCancelledException>()),
      );

      expect(repository.saved, isEmpty);
    });
  });
}

class _FakeRepository implements DuplicateRepository {
  /// Si el último guardado pidió retirar lo que ya no se encuentra.
  bool retired = false;

  List<HashableMedia> hashable = const [];
  List<HashedMedia> hashedMedia = const [];
  List<KnownGroup> known = const [];

  final saved = <ReconciledGroup>[];
  int freshCount = 1;

  var brokenHashable = false;
  var brokenHashed = false;
  var brokenKnown = false;

  @override
  Future<DataState<List<HashableMedia>>> getHashable() async =>
      brokenHashable ? DataException(Exception('roto')) : DataSuccess(hashable);

  @override
  Future<DataState<List<HashedMedia>>> getHashed() async =>
      brokenHashed ? DataException(Exception('roto')) : DataSuccess(hashedMedia);

  @override
  Future<DataState<List<KnownGroup>>> getKnownGroups() async =>
      brokenKnown ? DataException(Exception('roto')) : DataSuccess(known);

  @override
  Future<DataState<int>> saveGroups(
    List<ReconciledGroup> groups, {
    bool retireUnseen = false,
  }) async {
    saved.addAll(groups);
    retired = retireUnseen;

    return DataSuccess(freshCount);
  }

  @override
  Future<DataState<bool>> saveHashes(int mediaId, PerceptualHashes hashes) async =>
      const DataSuccess(true);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
