// Tirar los rechazos que ya no dicen nada de nadie.
//
// Un rechazo no es basura: es la única medida honesta del acierto de un modelo,
// porque cuenta las veces que se equivocó. Pero esa medida caduca, y lo que no
// caduca nunca es lo aceptado. Lo que se comprueba aquí es que la línea está
// donde tiene que estar.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/purge_old_rejections_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeResults results;

  final hoy = DateTime(2026, 8, 23, 12);

  PurgeOldRejectionsUseCase usecase() =>
      PurgeOldRejectionsUseCase(results, now: () => hoy);

  setUp(() => results = _FakeResults());

  test('borra lo anterior al plazo de siempre', () async {
    await usecase()();

    expect(results.cutoff, hoy.subtract(rejectionRetention));
  });

  test('el plazo se puede decir', () async {
    await usecase()(params: const Duration(days: 1));

    expect(results.cutoff, hoy.subtract(const Duration(days: 1)));
  });

  test('el plazo de fábrica es de meses, no de días', () {
    // Lo que mide un rechazo tarda en cambiar: el acierto de un modelo se juzga
    // sobre meses de uso, no sobre una tarde.
    expect(rejectionRetention.inDays, greaterThanOrEqualTo(30));
  });

  test('dice cuántos ha tirado', () async {
    results.deleted = 12;

    expect((await usecase()()).data, 12);
  });

  test('si la base falla, se dice', () async {
    results.broken = true;

    expect(await usecase()(), isA<DataException>());
  });
}

class _FakeResults implements RecognitionResultRepository {
  DateTime? cutoff;
  var deleted = 0;
  var broken = false;

  @override
  Future<DataState<int>> purgeRejectedBefore(DateTime before) async {
    if (broken) return DataException(Exception('no se pudo'));

    cutoff = before;

    return DataSuccess(deleted);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
