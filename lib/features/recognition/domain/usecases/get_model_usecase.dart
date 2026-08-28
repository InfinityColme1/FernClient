import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';

/// Un modelo por su identificador.
///
/// El escondido se contesta como el que no existe: a la pantalla de detalle se
/// llega por una dirección, y una dirección se puede escribir a mano.
class GetModelUseCase extends UseCase<DataState<RecognitionModelEntity>, int> {
  final ModelRepository _repository;
  final ContentVisibility _visibility;

  GetModelUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<RecognitionModelEntity>> call({int? params}) async {
    if (_visibility.hidesModel(params!)) {
      return DataException(Exception('Modelo $params no existe'));
    }

    return _repository.getModel(params);
  }
}
