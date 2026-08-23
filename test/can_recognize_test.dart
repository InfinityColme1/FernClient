// Si hay con qué reconocer, y si no, por qué.
//
// Las tres respuestas se parecen desde fuera —no sale ninguna sugerencia— y
// hacen falta cosas distintas para arreglarlas. Esto es lo que hizo que pulsar
// «reconocer» no pareciera hacer nada: un trabajo sin modelos entrenados
// termina en milisegundos y ni siquiera llega a verse en la lista de tareas.

import 'package:Fern/core/resources/data_state.dart';
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
  late CanRecognizeUseCase usecase;

  setUp(() {
    tree = _FakeTree();
    usecase = CanRecognizeUseCase(tree);
  });

  test('con un modelo entrenado, se puede', () async {
    tree.nodes = [_node(1, trained: true)];

    expect(await usecase(), RecognitionReadiness.ready);
  });

  test('el árbol vacío se distingue de los modelos sin entrenar', () async {
    tree.nodes = const [];

    // Uno se arregla metiendo un modelo en el árbol y el otro entrenándolo: son
    // dos recados distintos para el usuario.
    expect(await usecase(), RecognitionReadiness.noModelsInTree);
  });

  test('con todo sin entrenar, no se puede', () async {
    tree.nodes = [_node(1, trained: false), _node(2, trained: false)];

    expect(await usecase(), RecognitionReadiness.noTrainedModels);
  });

  test('basta uno entrenado entre varios', () async {
    tree.nodes = [
      _node(1, trained: false),
      _node(2, trained: true),
      _node(3, trained: false),
    ];

    // Los que no estén entrenados se saltan sin parar a los demás.
    expect(await usecase(), RecognitionReadiness.ready);
  });

  test('si el árbol no se puede leer, no se finge que sí', () async {
    tree.fails = true;

    // Decir «listo» aquí encolaría un trabajo que no puede salir bien, y decir
    // «no hay modelos» sería mentir sobre lo que pasa.
    expect(await usecase(), RecognitionReadiness.unknown);
  });
}

class _FakeTree implements ModelTreeRepository {
  List<ModelTreeNodeEntity> nodes = const [];
  bool fails = false;

  @override
  Future<DataState<ModelTreeEntity>> getTree() async {
    if (fails) return DataException(Exception('no se puede leer el árbol'));

    return DataSuccess(ModelTreeEntity(nodes: nodes));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}
