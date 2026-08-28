// El trabajo que pasa el arbol de modelos por un monton de contenidos.
//
// Lo que hay que sostener: **un contenido que falle no para el lote**. En una
// biblioteca de miles hay ficheros movidos, corruptos y formatos raros, y que uno
// de ellos deje sin reconocer los otros novecientos noventa y nueve es lo peor
// que podria hacer esto. Peor aun: se veria como «ya termino».
//
// Y que parar pare de verdad, que es lo unico que el usuario puede hacer cuando
// se ha lanzado sobre la biblioteca entera por error.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/recognition/data/services/media_recognizer.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTree implements ModelTreeRepository {
  ModelTreeEntity tree;
  var reads = 0;

  _FakeTree(this.tree);

  @override
  Future<DataState<ModelTreeEntity>> getTree() async {
    reads++;
    return DataSuccess(tree);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _FakeResults implements RecognitionResultRepository {
  /// Lo guardado, por contenido.
  final saved = <int, List<RecognitionResultEntity>>{};

  /// Si a cada contenido se le pidió volver a la pantalla de importación.
  final returnedToReview = <int, bool>{};

  @override
  Future<DataState<int>> replaceSuggestions({
    required int mediaId,
    required List<RecognitionResultEntity> results,
    bool returnToReview = false,
  }) async {
    saved[mediaId] = results;
    returnedToReview[mediaId] = returnToReview;

    return DataSuccess(results.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

ModelTreeEntity _treeWith(int nodes) {
  return ModelTreeEntity(
    nodes: [
      for (var id = 1; id <= nodes; id++)
        ModelTreeNodeEntity(
          id: id,
          model: RecognitionModelEntity(
            id: id,
            name: 'Modelo $id',
            weightsPath: 'C:/runs/$id/best.pt',
            createdAt: DateTime(2026),
          ),
        ),
    ],
  );
}

/// Un reconocedor de mentira: apunta a quién le han preguntado y contesta lo que
/// se le haya dicho, o revienta si toca.
class _FakeRecognizer implements MediaRecognizer {
  /// Cuántas veces se le ha dicho que olvide lo que sabía de los modelos.
  var forgotten = 0;

  @override
  void forgetClasses() => forgotten++;

  final looked = <int>[];

  /// De cuántos en cuántos se le ha ido preguntando.
  final batches = <List<int>>[];

  /// Contenidos que no se pueden mirar: se quedan fuera del resultado, como
  /// hace el de verdad cuando no le puede sacar fotogramas.
  Set<int> broken = const {};

  /// Contenidos que hacen reventar la tanda entera, como haria el motor caido.
  Set<int> explodesOn = const {};

  /// Cuántas sugerencias salen de cada contenido.
  int Function(int mediaId) suggestions = (_) => 1;

  /// Los nombres de modelo que ha ido anunciando, para comprobar que la lista
  /// de tareas se entera de en qué se está yendo el tiempo.
  final List<String> announced = ['Figuras'];

  @override
  Future<DataState<MediaRecognition>> recognize({
    required int mediaId,
    required String path,
    required ModelTreeEntity tree,
    CancellationToken? token,
    ModelProgress? onModel,
  }) async {
    final many = await recognizeMany(
      targets: [RecognitionTarget(mediaId: mediaId, path: path)],
      tree: tree,
      token: token,
      onModel: onModel,
    );

    final mine = many.data?[mediaId];
    if (mine == null) return DataException(Exception('nada'));

    return DataSuccess(mine);
  }

  @override
  Future<DataState<Map<int, MediaRecognition>>> recognizeMany({
    required List<RecognitionTarget> targets,
    required ModelTreeEntity tree,
    CancellationToken? token,
    ModelProgress? onModel,
  }) async {
    token?.throwIfCancelled();

    final ids = [for (final target in targets) target.mediaId];
    batches.add(ids);

    if (ids.any(explodesOn.contains)) throw StateError('el motor se cayo');

    final found = <int, MediaRecognition>{};

    for (final target in targets) {
      looked.add(target.mediaId);

      // Un fichero roto se queda fuera del resultado, como hace el de verdad
      // cuando no le puede sacar fotogramas: los demás de la tanda siguen.
      if (broken.contains(target.mediaId)) continue;

      found[target.mediaId] = MediaRecognition(
        suggestions: [
          for (var index = 0;
              index < suggestions(target.mediaId);
              index++)
            RecognitionResultEntity(
              mediaId: target.mediaId,
              modelId: 1,
              fernieId: 10 + index,
              confidence: 0.9,
              createdAt: DateTime(2026),
            ),
        ],
        log: MediaRecognitionLog(
          mediaId: target.mediaId,
          name: 'media-${target.mediaId}.jpg',
          models: const [],
          at: DateTime(2026),
        ),
      );
    }

    for (final name in announced) {
      onModel?.call(name);
    }

    return DataSuccess(found);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  late _FakeTree tree;
  late _FakeResults results;
  late _FakeRecognizer recognizer;
  late RecognitionLogStore logs;

  var notified = 0;
  var notifiedWith = <int>{};

  setUp(() {
    tree = _FakeTree(_treeWith(1));
    results = _FakeResults();
    recognizer = _FakeRecognizer();
    logs = RecognitionLogStore();
    notified = 0;
  });

  RecognitionJobRunner runner({Set<int> missingPaths = const {}}) {
    return RecognitionJobRunner(
      tree: tree,
      results: results,
      recognizer: recognizer,
      logs: logs,
      pathOf: (id) async => missingPaths.contains(id) ? null : 'C:/media/$id.jpg',
      notifyFinished: (mediaIds) async {
        notified++;
        notifiedWith = mediaIds;
      },
    );
  }

  /// Un contexto de trabajo con la lista de contenidos que se diga.
  ({
    JobContext context,
    List<int> reported,
    List<String> stages,
    CancellationToken token,
  }) job(
    List<int> ids,
  ) {
    final reported = <int>[];
    final stages = <String>[];
    final token = CancellationToken();

    return (
      reported: reported,
      stages: stages,
      token: token,
      context: JobContext(
        job: Job(
          id: 'job-1',
          type: JobType.recognition,
          createdAt: DateTime(2026),
          payload: {RecognitionJobRunner.mediaIdsKey: ids},
        ),
        token: token,
        // El avance y el «en qué se está» son dos señales distintas: el
        // segundo se anuncia entre medias sin que el primero cambie.
        report: (done, {total, stage}) {
          if (stage == null) {
            reported.add(done);
          } else {
            stages.add(stage);
          }
        },
      ),
    );
  }

  group('lo normal', () {
    test('mira todos los contenidos que se le den', () async {
      final work = job([1, 2, 3]);
      await runner().run(work.context);

      expect(recognizer.looked, [1, 2, 3]);
    });

    test('guarda lo propuesto de cada uno', () async {
      final work = job([1, 2]);
      await runner().run(work.context);

      expect(results.saved.keys.toList()..sort(), [1, 2]);
      expect(results.saved[1], hasLength(1));
    });

    test('avisa de por donde va, por contenido', () async {
      final work = job([1, 2, 3]);
      await runner().run(work.context);

      // Un contenido es lo que el usuario entiende por «va por la mitad»; los
      // fotogramas de dentro son cosa nuestra.
      expect(work.reported, [0, 1, 2, 3]);
    });

    test('olvida lo que sabia de los modelos antes de empezar', () async {
      await runner().run(job([1, 2]).context);

      // Entre dos trabajos el usuario ha podido cambiar los fernies de un
      // modelo, y traducir con la tabla vieja pone el nombre de otro fernie en
      // las sugerencias.
      expect(recognizer.forgotten, 1);
    });

    test('el arbol se lee una sola vez', () async {
      final work = job([1, 2, 3, 4, 5]);
      await runner().run(work.context);

      // Releerlo por cada contenido serian mil lecturas para responder siempre
      // lo mismo.
      expect(tree.reads, 1);
    });
  });

  group('devolver a revisión', () {
    test('el ajuste llega hasta lo que guarda', () async {
      final subject = RecognitionJobRunner(
        tree: tree,
        results: results,
        recognizer: recognizer,
        logs: logs,
        returnToReview: () => true,
        pathOf: (id) async => 'C:/media/$id.jpg',
      );

      await subject.run(job([1, 2]).context);

      expect(results.returnedToReview, {1: true, 2: true});
    });

    test('apagado, no se pide mover nada', () async {
      final subject = RecognitionJobRunner(
        tree: tree,
        results: results,
        recognizer: recognizer,
        logs: logs,
        returnToReview: () => false,
        pathOf: (id) async => 'C:/media/$id.jpg',
      );

      await subject.run(job([1]).context);

      expect(results.returnedToReview, {1: false});
    });

    test('el ajuste se lee una sola vez por trabajo', () async {
      var reads = 0;

      final subject = RecognitionJobRunner(
        tree: tree,
        results: results,
        recognizer: recognizer,
        logs: logs,
        returnToReview: () {
          reads++;
          return true;
        },
        pathOf: (id) async => 'C:/media/$id.jpg',
      );

      await subject.run(job([1, 2, 3]).context);

      // Cambiarlo a media faena dejaría medio lote en la biblioteca y medio en
      // importación, que es lo peor de las dos cosas.
      expect(reads, 1);
    });
  });

  group('cuando algo se tuerce', () {
    test('un fichero roto no para el lote', () async {
      recognizer.broken = {2};

      final work = job([1, 2, 3]);
      await runner().run(work.context);

      // Lo peor que podria hacer esto es dejar sin reconocer los otros
      // novecientos noventa y nueve, y encima parecer que termino bien.
      expect(recognizer.looked, [1, 2, 3]);
      expect(results.saved.keys.toList()..sort(), [1, 3]);
    });

    test('una tanda que revienta no para el trabajo', () async {
      recognizer.explodesOn = {2};

      final work = job([1, 2, 3]);
      await runner().run(work.context);

      // La tanda que fallo se pierde entera, pero las demas se guardan y el
      // trabajo termina: un fallo del motor a mitad de biblioteca no puede
      // dejar sin reconocer todo lo que venia detras.
      expect(results.saved.keys.toList()..sort(), [1, 3]);
    });

    test('el avance sigue contando el que fallo', () async {
      recognizer.broken = {2};

      final work = job([1, 2, 3]);
      await runner().run(work.context);

      expect(work.reported, [0, 1, 2, 3]);
    });

    test('un contenido sin ruta se salta', () async {
      final work = job([1, 2]);
      await runner(missingPaths: {1}).run(work.context);

      expect(recognizer.looked, [2]);
    });
  });

  group('de cuantos en cuantos', () {
    test('con pocos contenidos van de uno en uno', () async {
      final work = job([1, 2, 3]);
      await runner().run(work.context);

      // Con pocos, lo que se nota es la barra; el ahorro de agruparlos, no.
      expect(recognizer.batches, [
        [1],
        [2],
        [3],
      ]);
      expect(work.reported, [0, 1, 2, 3]);
    });

    test('con muchos se agrupan sin pasarse del tope', () async {
      final ids = [for (var id = 1; id <= 300; id++) id];

      final work = job(ids);
      await runner().run(work.context);

      expect(recognizer.batches, hasLength(12));
      expect(recognizer.batches.first, hasLength(25));

      // La barra sigue hablando de contenidos: doce tramos de veinticinco.
      expect(work.reported.first, 0);
      expect(work.reported.last, 300);
      expect(work.reported, hasLength(13));
    });

    test('el tope no se pasa aunque haya miles', () {
      expect(RecognitionJobRunner.batchSizeFor(100000),
          recognitionMediaPerBatch);
    });

    test('ninguna tanda se queda vacia ni se pierde nadie', () async {
      final ids = [for (var id = 1; id <= 37; id++) id];

      await runner().run(job(ids).context);

      expect(recognizer.batches.every((one) => one.isNotEmpty), isTrue);
      expect(recognizer.looked, ids);
    });
  });

  group('cuando no hay nada que hacer', () {
    test('sin contenidos no se lee ni el arbol', () async {
      final work = job(const []);
      await runner().run(work.context);

      expect(tree.reads, 0);
    });

    test('con el arbol vacio no se mira nada', () async {
      tree.tree = ModelTreeEntity.empty;

      final work = job([1, 2]);
      await runner().run(work.context);

      // Un modelo que no esta en el arbol no se ejecuta nunca: esto no es un
      // fallo, es que no hay trabajo.
      expect(recognizer.looked, isEmpty);
      expect(results.saved, isEmpty);
    });
  });

  group('parar', () {
    test('cancelar deja de mirar los que quedaban', () async {
      final work = job([1, 2, 3]);
      work.token.cancel();

      await expectLater(
        runner().run(work.context),
        throwsA(isA<JobCancelledException>()),
      );

      expect(recognizer.looked, isEmpty);
    });

    test('lo ya reconocido antes de parar se queda guardado', () async {
      final work = job([1, 2, 3]);

      recognizer.suggestions = (id) {
        if (id == 1) work.token.cancel();
        return 1;
      };

      await expectLater(
        runner().run(work.context),
        throwsA(isA<JobCancelledException>()),
      );

      // Parar no es deshacer: lo que ya se miro vale, y volver a empezar seria
      // pagar otra vez por lo mismo.
      expect(results.saved.keys, [1]);
    });
  });

  group('el aviso', () {
    test('se avisa si ha salido algo que mirar', () async {
      final work = job([1]);
      await runner().run(work.context);

      expect(notified, 1);
    });

    test('el aviso lleva qué contenidos hay que señalar', () async {
      // Sólo los que han acabado con algo que revisar: los demás no tienen nada
      // que mirar, y señalarlos mandaría al usuario a una celda vacía.
      recognizer.suggestions = (mediaId) => mediaId == 2 ? 0 : 1;

      final work = job([1, 2, 3]);
      await runner().run(work.context);

      expect(notifiedWith, {1, 3});
    });

    test('el parte se guarda por trabajo', () async {
      final work = job([1, 2]);
      await runner().run(work.context);

      // Es como se llega a él después: la lista de tareas enseña el trabajo y
      // desde ahí se abre el suyo.
      expect(logs.of('job-1'), hasLength(2));
      expect(logs.forMedia('job-1', 2)?.mediaId, 2);
    });

    test('el parte se guarda aunque no salga ninguna sugerencia', () async {
      recognizer.suggestions = (_) => 0;

      final work = job([1]);
      await runner().run(work.context);

      // Es justamente cuando no sale nada cuando alguien lo abre.
      expect(logs.of('job-1'), hasLength(1));
    });

    test('se dice qué modelo está mirando', () async {
      recognizer.announced.addAll(['Variantes', 'Formas nuevas']);

      final work = job([1]);
      await runner().run(work.context);

      // Con un árbol de tres modelos, saber cuál mira es la diferencia entre una
      // barra que avanza y una que parece colgada.
      expect(work.stages, ['Figuras', 'Variantes', 'Formas nuevas']);
    });

    test('sin sugerencias no se avisa', () async {
      recognizer.suggestions = (_) => 0;

      final work = job([1, 2]);
      await runner().run(work.context);

      // Avisar de que «ya esta» sin nada que revisar manda al usuario a una
      // pantalla vacia.
      expect(notified, 0);
    });

    test('si el aviso falla, el reconocimiento sigue siendo bueno', () async {
      final subject = RecognitionJobRunner(
        tree: tree,
        results: results,
        recognizer: recognizer,
        logs: logs,
        pathOf: (id) async => 'C:/media/$id.jpg',
        notifyFinished: (_) async => throw Exception('sin altavoces'),
      );

      final work = job([1]);
      await subject.run(work.context);

      expect(results.saved.keys, [1]);
    });
  });
}
