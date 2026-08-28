// Empezar de cero: borrar todas las huellas para que se recalculen.
//
// Lo que se comprueba, además de que borra, es que **olvida la fecha del último
// escaneo**. Sin eso queda una biblioteca sin una sola huella y una marca
// diciendo que se miró hace un momento: la búsqueda automática no volvería hasta
// que pasara el periodo entero —tres meses de fábrica— y quien pulsó el botón se
// quedaría sin detección de repetidos sin que nada se lo dijera.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/usecases/rehash_library_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeDuplicates duplicates;
  late int forgotten;

  setUp(() {
    duplicates = _FakeDuplicates();
    forgotten = 0;
  });

  RehashLibraryUseCase rehash() => RehashLibraryUseCase(
        duplicates,
        forgetLastScan: () async => forgotten++,
      );

  test('borra las huellas y dice cuántas', () async {
    duplicates.cleared = 349;

    final result = await rehash()();

    expect(result.data, 349);
  });

  test('olvida cuándo se escaneó, para que vuelva a tocar', () async {
    await rehash()();

    expect(forgotten, 1);
  });

  // Si el borrado falla, las huellas siguen ahí y la fecha del último escaneo
  // sigue siendo verdad. Olvidarla entonces provocaría un escaneo completo que
  // no hacía ninguna falta.
  test('si no se pueden borrar, la fecha se queda como estaba', () async {
    duplicates.isBroken = true;

    final result = await rehash()();

    expect(result, isA<DataException>());
    expect(forgotten, 0);
  });

  test('sin nada que borrar, la fecha se olvida igual', () async {
    // La biblioteca puede estar vacía y aun así el usuario quiere empezar de
    // cero: dejar la marca haría que no se mirara al entrar contenido nuevo.
    duplicates.cleared = 0;

    await rehash()();

    expect(forgotten, 1);
  });
}

class _FakeDuplicates implements DuplicateRepository {
  int cleared = 0;
  bool isBroken = false;

  @override
  Future<DataState<int>> clearHashes() async =>
      isBroken ? DataException(Exception('roto')) : DataSuccess(cleared);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
