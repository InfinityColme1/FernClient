// Borrar un modelo: la fila y lo que dejo en disco.
//
// Lo que importa aqui es **el orden**. El modelo se lee antes de borrarlo,
// porque despues ya no hay forma de saber donde estaban sus ficheros. Y los
// ficheros se limpian despues de que la fila se haya ido: al reves, un borrado
// que fallara a medias dejaria un modelo en la lista apuntando a unos pesos que
// ya no estan, que es peor que dejar basura en el disco.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_model_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// Apunta en que orden le han pedido las cosas.
class _FakeRepository implements ModelRepository {
  final List<String> calls = [];

  RecognitionModelEntity? model;
  bool failsToDelete = false;

  _FakeRepository(this.model);

  @override
  Future<DataState<RecognitionModelEntity>> getModel(int id) async {
    calls.add('getModel');
    final current = model;

    return current == null
        ? DataException(Exception('no existe'))
        : DataSuccess(current);
  }

  @override
  Future<DataState<bool>> deleteModel(int id) async {
    calls.add('deleteModel');

    if (failsToDelete) return DataException(Exception('ocupado'));

    model = null;

    return const DataSuccess(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

/// Un limpiador de mentira: apunta lo que le mandan borrar.
class _FakeFiles implements ModelFiles {
  final List<int> discarded = [];
  bool throws = false;

  @override
  Future<List<String>> discard(RecognitionModelEntity model) async {
    discarded.add(model.id);

    if (throws) throw Exception('el antivirus lo tiene abierto');

    return const ['C:/fern/recognition/runs/7'];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  late _FakeRepository repository;
  late _FakeFiles files;
  late DeleteModelUseCase deleteModel;

  final model = RecognitionModelEntity(
    id: 7,
    name: 'Personajes',
    weightsPath: r'C:\fern\recognition\runs\7\weights\best.pt',
    createdAt: DateTime(2026),
  );

  setUp(() {
    repository = _FakeRepository(model);
    files = _FakeFiles();
    deleteModel = DeleteModelUseCase(repository, files);
  });

  test('se lee el modelo antes de borrarlo', () async {
    await deleteModel(params: 7);

    // Despues de borrar la fila ya no hay forma de saber donde estaban sus
    // ficheros.
    expect(repository.calls, ['getModel', 'deleteModel']);
  });

  test('se borra la fila y luego los ficheros', () async {
    final result = await deleteModel(params: 7);

    expect(result, isA<DataSuccess<bool>>());
    expect(repository.model, isNull);
    expect(files.discarded, [7]);
  });

  test('si la fila no se puede borrar, los ficheros no se tocan', () async {
    repository.failsToDelete = true;

    final result = await deleteModel(params: 7);

    // Borrar los pesos de un modelo que sigue en la lista lo deja inservible y
    // sin explicacion.
    expect(result, isA<DataException>());
    expect(files.discarded, isEmpty);
  });

  test('un disco que se resiste no deshace el borrado', () async {
    files.throws = true;

    final result = await deleteModel(params: 7);

    // El modelo ya no esta: lo que quede en disco es basura, no un fallo que
    // haya que devolverle al usuario para que lo resuelva.
    expect(result, isA<DataSuccess<bool>>());
    expect(repository.model, isNull);
  });

  test('un modelo que ya no estaba se borra igual, sin ficheros', () async {
    repository.model = null;

    final result = await deleteModel(params: 7);

    expect(result, isA<DataSuccess<bool>>());
    expect(files.discarded, isEmpty);
  });
}
