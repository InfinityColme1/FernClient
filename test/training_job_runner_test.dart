// Lo que hace el runner que entrena un modelo.
//
// El motor y el repositorio se doblan: entrenar de verdad son horas y aqui lo
// que se comprueba es el **orden de las cosas**, que es donde estan los fallos
// que dejan la aplicacion inservible:
//
// - Que la marca de «entrenando» se quita pase lo que pase. Si se queda puesta,
//   ese modelo no se deja entrenar nunca mas.
// - Que el dataset se recoge pase lo que pase. Son miles de imagenes copiadas.
// - Que un fallo no borra los pesos que funcionaban.
// - Que cancelar no cuenta como error.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/recognition/data/services/dataset_builder.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/data/services/training_job_runner.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de mentira que anota lo que le piden.
class _FakeRepository implements ModelRepository {
  RecognitionModelEntity model;
  final List<ModelFernieEntity> fernies;

  /// La secuencia de marcas de «entrenando», para poder comprobar que se pone y
  /// se quita.
  final List<bool> trainingFlags = [];
  final List<Map<String, String?>> results = [];

  _FakeRepository({required this.model, this.fernies = const []});

  @override
  Future<DataState<RecognitionModelEntity>> getModel(int id) async =>
      DataSuccess(model);

  @override
  Future<DataState<List<ModelFernieEntity>>> getFerniesOfModel(int id) async =>
      DataSuccess(fernies);

  @override
  Future<DataState<bool>> setTraining({
    required int modelId,
    required bool isTraining,
  }) async {
    trainingFlags.add(isTraining);
    return const DataSuccess(true);
  }

  @override
  Future<DataState<RecognitionModelEntity>> saveTrainingResult({
    required int modelId,
    String? weightsPath,
    String? metrics,
    String? error,
  }) async {
    results.add({
      'weights': weightsPath,
      'metrics': metrics,
      'error': error,
    });

    return DataSuccess(model);
  }

  // El resto del contrato no lo toca el runner.
  @override
  Future<DataState<List<RecognitionModelEntity>>> getModels() async =>
      const DataSuccess([]);

  @override
  Future<DataState<RecognitionModelEntity>> saveModel(
    RecognitionModelEntity model,
  ) async =>
      DataSuccess(model);

  @override
  Future<DataState<bool>> deleteModel(int id) async => const DataSuccess(true);

  @override
  Future<DataState<ModelFernieEntity>> assignFernie({
    required int modelId,
    required int fernieId,
  }) async =>
      DataException(Exception('sin usar'));

  @override
  Future<DataState<bool>> removeFernie(int id) async => const DataSuccess(true);

  @override
  Future<DataState<ModelFernieEntity>> updateSplit({
    required int assignmentId,
    required DatasetSplit split,
  }) async =>
      DataException(Exception('sin usar'));

  @override
  Future<DataState<int>> clearStaleTrainingFlags() async =>
      const DataSuccess(0);
}

/// Constructor de datasets que no toca el disco.
class _FakeBuilder implements DatasetBuilder {
  final List<String> discarded = [];
  DatasetPlan? built;

  @override
  Future<DatasetBuildResult> build({
    required DatasetPlan plan,
    required String root,
    void Function(int done, int total)? onProgress,
    CancellationToken? token,
  }) async {
    token?.throwIfCancelled();
    built = plan;

    return DatasetBuildResult(
      root: root,
      dataYaml: '$root/data.yaml',
      plan: plan,
    );
  }

  @override
  Future<void> discard(String root) async => discarded.add(root);
}

/// Motor de mentira: avisa de unas cuantas épocas y devuelve lo que se le diga.
class _FakeEngine implements RecognitionEngine {
  final int epochs;
  final Object? throws;

  Map<String, dynamic>? params;

  _FakeEngine({this.epochs = 3, this.throws});

  @override
  Future<Map<String, dynamic>> train(
    Map<String, dynamic> params, {
    void Function(Map<String, dynamic> data)? onProgress,
  }) async {
    this.params = params;

    if (throws != null) throw throws!;

    for (var epoch = 1; epoch <= epochs; epoch++) {
      onProgress?.call({'epoch': epoch, 'epochs': epochs});
    }

    return {
      'weights': 'C:/runs/best.pt',
      'metrics': {'map50': 0.83},
    };
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repository;
  late _FakeBuilder builder;

  final model = RecognitionModelEntity(
    id: 7,
    name: 'Personajes de Miraculous',
    epochs: 3,
    createdAt: DateTime(2026),
  );

  final fernies = [
    ModelFernieEntity(
      id: 1,
      modelId: 7,
      fernie: FernieEntity(id: 1, name: 'Marinette', regionCount: 20),
      classIndex: 0,
    ),
  ];

  /// Cuantas veces se ha avisado de que esto termino.
  var notified = 0;

  setUp(() {
    repository = _FakeRepository(model: model, fernies: fernies);
    builder = _FakeBuilder();
    notified = 0;
  });

  /// Un contexto de trabajo, con su cuenta de avance.
  ({JobContext context, List<int> reported, CancellationToken token}) job() {
    final reported = <int>[];
    final token = CancellationToken();

    return (
      token: token,
      reported: reported,
      context: JobContext(
        job: Job(
          id: 'job-1',
          type: JobType.training,
          createdAt: DateTime(2026),
          payload: const {TrainingJobRunner.modelIdKey: 7},
        ),
        token: token,
        report: (done, {total, stage}) => reported.add(done),
      ),
    );
  }

  TrainingJobRunner runnerWith(
    RecognitionEngine engine, {
    bool keepDatasets = false,
    bool notifyThrows = false,
  }) {
    return TrainingJobRunner(
      models: repository,
      datasets: builder,
      engine: engine,
      regionsOf: (modelId) async => [
        for (var id = 1; id <= 20; id++)
          DatasetRegion(
            regionId: id,
            mediaId: id,
            mediaPath: 'C:/biblioteca/$id.jpg',
            x: 0.1,
            y: 0.1,
            w: 0.2,
            h: 0.2,
            classIndex: 0,
          ),
      ],
      root: () async => r'C:\fern\recognition',
      keepDatasets: () => keepDatasets,
      notifyFinished: () async {
        notified++;
        if (notifyThrows) throw Exception('sin altavoces');
      },
    );
  }

  test('entrena y guarda lo que sale', () async {
    final work = job();
    await runnerWith(_FakeEngine()).run(work.context);

    expect(repository.results, hasLength(1));
    expect(repository.results.single['weights'], 'C:/runs/best.pt');
    expect(repository.results.single['metrics'], '{"map50":0.83}');
    expect(repository.results.single['error'], isNull);
  });

  test('avisa de por donde va, por epocas', () async {
    final work = job();
    await runnerWith(_FakeEngine(epochs: 3)).run(work.context);

    // Una epoca es lo que el usuario entiende por «va por la mitad».
    expect(work.reported, [0, 1, 2, 3, 3]);
  });

  test('la marca de entrenando se pone y se quita', () async {
    final work = job();
    await runnerWith(_FakeEngine()).run(work.context);

    expect(repository.trainingFlags, [true, false]);
  });

  group('el aviso de que ya esta', () {
    test('al terminar bien se avisa', () async {
      final work = job();
      await runnerWith(_FakeEngine()).run(work.context);

      // Un entrenamiento tarda horas y se lanza y se olvida: sin aviso hay que
      // acordarse de volver a mirar.
      expect(notified, 1);
    });

    test('al fallar tambien se avisa', () async {
      final work = job();
      final engine = _FakeEngine(throws: Exception('OUT_OF_MEMORY'));

      await expectLater(
        runnerWith(engine).run(work.context),
        throwsA(isA<Exception>()),
      );

      // Lo que hace falta saber es que ya no hay que esperar. Enterarse del
      // fallo dos horas despues es justo lo que el aviso evita.
      expect(notified, 1);
    });

    test('al cancelar no se avisa', () async {
      final work = job();
      work.token.cancel();

      await expectLater(
        runnerWith(_FakeEngine()).run(work.context),
        throwsA(isA<JobCancelledException>()),
      );

      // Pararlo lo ha hecho el usuario hace un momento y ya lo sabe.
      expect(notified, 0);
    });

    test('si el aviso falla, el entrenamiento sigue siendo bueno', () async {
      final work = job();

      await runnerWith(_FakeEngine(), notifyThrows: true).run(work.context);

      // Los pesos ya estan guardados: tirar abajo el trabajo por no poder dar
      // un aviso seria perder horas de maquina por un sonido.
      expect(repository.results.single['weights'], 'C:/runs/best.pt');
      expect(repository.trainingFlags, [true, false]);
    });
  });

  test('el dataset se recoge al terminar', () async {
    final work = job();
    await runnerWith(_FakeEngine()).run(work.context);

    expect(builder.discarded, hasLength(1));
    expect(builder.discarded.single, contains('7-personajes-de-miraculous'));
  });

  test('con el ajuste puesto, el dataset se queda', () async {
    final work = job();
    await runnerWith(_FakeEngine(), keepDatasets: true).run(work.context);

    // Para mirar por que un modelo no aprende no hay nada mejor que ver con que
    // se le enseño.
    expect(builder.discarded, isEmpty);
  });

  group('cuando algo se tuerce', () {
    test('un fallo se apunta y no lleva pesos', () async {
      final work = job();
      final engine = _FakeEngine(throws: Exception('OUT_OF_MEMORY'));

      await expectLater(
        runnerWith(engine).run(work.context),
        throwsA(isA<Exception>()),
      );

      expect(repository.results.single['error'], contains('OUT_OF_MEMORY'));
      expect(repository.results.single['weights'], isNull);
    });

    test('y aun asi se limpia todo', () async {
      final work = job();
      final engine = _FakeEngine(throws: Exception('roto'));

      await expectLater(
        runnerWith(engine).run(work.context),
        throwsA(isA<Exception>()),
      );

      // Si la marca se quedara puesta, ese modelo no se dejaria entrenar nunca
      // mas; si el dataset se quedara, el disco se llena.
      expect(repository.trainingFlags, [true, false]);
      expect(builder.discarded, hasLength(1));
    });

    test('cancelar no cuenta como error', () async {
      final work = job();
      work.token.cancel();

      await expectLater(
        runnerWith(_FakeEngine()).run(work.context),
        throwsA(isA<JobCancelledException>()),
      );

      // Parar es una decision, no un fallo: no se apunta ningun error y el
      // modelo se queda como estaba.
      expect(repository.results.single['error'], isNull);
      expect(repository.trainingFlags, [true, false]);
    });
  });

  group('lo que se le pasa al motor', () {
    test('las rutas van con barras normales', () async {
      final work = job();
      final engine = _FakeEngine();
      await runnerWith(engine).run(work.context);

      // Lo lee Python: una barra invertida dentro de una cadena es un escape.
      expect(engine.params!['dataset'], isNot(contains(r'\')));
      expect(engine.params!['project'], isNot(contains(r'\')));
    });

    test('el nombre se convierte en algo que vale de carpeta', () async {
      final work = job();
      final engine = _FakeEngine();
      await runnerWith(engine).run(work.context);

      expect(engine.params!['name'], '7-personajes-de-miraculous');
    });

    test('los mandos salen del modelo', () async {
      final work = job();
      final engine = _FakeEngine();
      await runnerWith(engine).run(work.context);

      expect(engine.params!['epochs'], 3);
      expect(engine.params!['backbone'], model.backbone);
      expect(engine.params!['imgsz'], model.imgsz);
    });
  });

  test('el reparto del dataset sale de los fernies del modelo', () async {
    final work = job();
    await runnerWith(_FakeEngine()).run(work.context);

    expect(builder.built, isNotNull);
    expect(builder.built!.classNames[0], 'marinette');
  });
}
