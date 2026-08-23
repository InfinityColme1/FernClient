import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';

/// Tira lo rechazado que ya no dice nada de nadie.
///
/// Los rechazos no son basura: son **la única medida honesta** del acierto de un
/// modelo, porque cuentan las veces que se equivocó. Pero esa medida caduca. Un
/// rechazo de hace tres meses es de un modelo que se ha entrenado dos veces
/// desde entonces, así que no habla de él; lo único que hace es ocupar sitio en
/// una colección que crece con cada contenido y cada modelo del árbol.
///
/// Lo aceptado no se toca nunca. Eso es lo que el usuario ha dicho que sí, y
/// borrarlo sería borrar su trabajo.
class PurgeOldRejectionsUseCase extends UseCase<DataState<int>, Duration> {
  final RecognitionResultRepository _repository;

  /// De dónde sale «ahora». Inyectable para poder probarlo sin esperar meses.
  final DateTime Function() _now;

  PurgeOldRejectionsUseCase(
    this._repository, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<DataState<int>> call({Duration? params}) {
    return _repository.purgeRejectedBefore(
      _now().subtract(params ?? rejectionRetention),
    );
  }
}
