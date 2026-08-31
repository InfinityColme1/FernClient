// Olvidar lo entrenado de un modelo sin perder como se pidio.
//
// Un modelo entrenado con lo que no era —las regiones equivocadas, un reparto
// mal hecho— se queda con unos pesos que reconocen mal y una ficha que dice que
// esta listo. Borrarlo entero y volver a crearlo era la unica salida, y con eso
// se perdian tambien los hiperparametros, los fernies y el reparto, que no
// tenian nada de malo.
//
// Lo que importa aqui es **el orden**: los ficheros se borran mirando la fila,
// asi que hay que llevarselos antes de vaciarla. Al reves, la ruta de los pesos
// ya no estaria y quedarian cien megas en el disco que nadie apunta.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/forget_training_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// Apunta en que orden le han pedido las cosas.
class _FakeRepository implements ModelRepository {
  final List<String> calls = [];
  RecognitionModelEntity model;

  _FakeRepository(this.model);

  @override
  Future<DataState<RecognitionModelEntity>> forgetTraining(int modelId) async {
    calls.add('forgetTraining');
    // El de verdad los pone en nulo; aqui basta con dejar constancia de que se
    // ha pedido y devolver algo sin pesos.
    model = RecognitionModelEntity(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
    );

    return DataSuccess(model);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _FakeFiles implements ModelFiles {
  final List<String> calls;
  final List<int> discarded = [];

  _FakeFiles(this.calls);

  @override
  Future<List<String>> discard(RecognitionModelEntity model) async {
    calls.add('discard');
    discarded.add(model.id);

    return const ['C:/fern/reconocimiento/pesos/best.pt'];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  final model = RecognitionModelEntity(
    id: 7,
    name: 'Personajes',
    weightsPath: 'C:/fern/reconocimiento/pesos/best.pt',
    createdAt: DateTime(2026),
  );

  late _FakeRepository repository;
  late _FakeFiles files;
  late ForgetTrainingUseCase forget;

  setUp(() {
    repository = _FakeRepository(model);
    files = _FakeFiles(repository.calls);
    forget = ForgetTrainingUseCase(models: repository, files: files);
  });

  test('se lleva los ficheros y vacia la fila', () async {
    await forget(params: model);

    expect(files.discarded, [7]);
    expect(repository.calls, contains('forgetTraining'));
  });

  // La ruta de los pesos sale de la fila: vaciandola primero, no habria por
  // donde encontrarlos y se quedarian cien megas que no apunta nadie.
  test('y los ficheros van primero', () async {
    await forget(params: model);

    expect(repository.calls, ['discard', 'forgetTraining']);
  });

  test('sin modelo no toca nada', () async {
    final result = await forget();

    expect(result is DataSuccess, isFalse);
    expect(files.discarded, isEmpty);
    expect(repository.calls, isEmpty);
  });

  test('devuelve el modelo ya sin pesos', () async {
    final result = await forget(params: model);

    expect(result.data?.weightsPath, isNull);
  });
}
