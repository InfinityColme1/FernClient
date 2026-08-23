// El único sitio desde el que se manda a reconocer.
//
// Los cuatro puntos de entrada del D16 —el visor, la selección de una rejilla,
// una etiqueta o un creador enteros, y la biblioteca— pasan por aquí. Tenerlo en
// un solo sitio no es sólo por no repetirse: la comprobación de si hay con qué
// reconocer es lo que evita encolar un trabajo que termina en milisegundos sin
// dejar rastro, y basta que **uno** de los cuatro se la salte para que el
// usuario vuelva a encontrarse un botón que no hace nada. Ya pasó una vez.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

ModelTreeNodeEntity _node(int id, {required bool trained}) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'modelo-$id',
      weightsPath: trained ? 'C:/pesos/best.pt' : null,
      createdAt: DateTime(2026),
    ),
  );
}

void main() {
  late _FakeTree tree;
  late JobQueue queue;
  late RecognitionLauncher launcher;

  setUp(() {
    tree = _FakeTree()..nodes = [_node(1, trained: true)];
    queue = JobQueue();

    launcher = RecognitionLauncher(
      canRecognize: CanRecognizeUseCase(tree),
      jobs: queue,
    );
  });

  tearDown(() => queue.dispose());

  group('cuando se puede', () {
    test('encola lo que se le da', () async {
      final request = await launcher.request([1, 2, 3]);

      expect(request.outcome, RecognitionOutcome.queued);
      expect(request.count, 3);

      final job = queue.jobs.single;
      expect(job.type, JobType.recognition);
      expect(job.payload[RecognitionJobRunner.mediaIdsKey], [1, 2, 3]);
    });

    test('va por delante de lo que la aplicación hace por su cuenta', () async {
      await launcher.request([1]);

      // Lo acaba de pedir el usuario y lo está mirando.
      expect(queue.jobs.single.priority, JobPriority.high);
    });

    test('el trabajo lleva nombre, para distinguirlo entre varios', () async {
      await launcher.request([1], name: 'Ladybug');

      // «Etiqueta Ladybug» dice mucho más que «Reconocimiento» cuando hay tres
      // en marcha a la vez.
      expect(queue.jobs.single.payload[Job.nameKey], 'Ladybug');
    });

    test('el total es lo que hay que hacer, para la barra de avance', () async {
      await launcher.request([1, 2, 3, 4]);

      expect(queue.jobs.single.total, 4);
    });

    test('lo repetido se manda una sola vez', () async {
      final request = await launcher.request([1, 2, 1, 3, 2]);

      // La misma selección puede llegar por dos caminos —una etiqueta y un
      // creador que comparten contenido—, y reconocer dos veces lo mismo en el
      // mismo trabajo es pagar dos veces por la misma respuesta.
      expect(request.count, 3);
      expect(queue.jobs.single.payload[RecognitionJobRunner.mediaIdsKey],
          [1, 2, 3]);
    });
  });

  group('cuando no hay con qué', () {
    test('con el árbol vacío no se encola', () async {
      tree.nodes = const [];

      final request = await launcher.request([1]);

      expect(request.outcome, RecognitionOutcome.notReady);
      expect(request.readiness, RecognitionReadiness.noModelsInTree);
      expect(queue.jobs, isEmpty);
    });

    test('con todo sin entrenar tampoco', () async {
      tree.nodes = [_node(1, trained: false)];

      final request = await launcher.request([1]);

      // El motivo viaja con la respuesta: uno se arregla metiendo un modelo en
      // el árbol y el otro entrenándolo, y son dos recados distintos.
      expect(request.readiness, RecognitionReadiness.noTrainedModels);
      expect(queue.jobs, isEmpty);
    });

    test('si el árbol no se puede leer, no se finge que sí', () async {
      tree.fails = true;

      final request = await launcher.request([1]);

      expect(request.outcome, RecognitionOutcome.notReady);
      expect(request.readiness, RecognitionReadiness.unknown);
      expect(queue.jobs, isEmpty);
    });
  });

  group('cuando no hay nada que mandar', () {
    test('una lista vacía se distingue de no tener modelos', () async {
      final request = await launcher.request(const []);

      // No es lo mismo y no se puede juntar: aquí los modelos están listos y lo
      // que falta es contenido, así que el recado para el usuario es otro.
      expect(request.outcome, RecognitionOutcome.nothingToRecognize);
      expect(queue.jobs, isEmpty);
    });

    test('no se molesta en leer el árbol', () async {
      await launcher.request(const []);

      // Preguntarle a la base de datos por el árbol para acabar diciendo «no
      // has seleccionado nada» es trabajo para nada.
      expect(tree.reads, 0);
    });

    test('una lista vacía sin modelos sigue siendo lista vacía', () async {
      tree.nodes = const [];

      final request = await launcher.request(const []);

      expect(request.outcome, RecognitionOutcome.nothingToRecognize);
    });
  });
}

class _FakeTree implements ModelTreeRepository {
  List<ModelTreeNodeEntity> nodes = const [];
  bool fails = false;
  int reads = 0;

  @override
  Future<DataState<ModelTreeEntity>> getTree() async {
    reads++;

    if (fails) return DataException(Exception('no se puede leer el árbol'));

    return DataSuccess(ModelTreeEntity(nodes: nodes));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}
