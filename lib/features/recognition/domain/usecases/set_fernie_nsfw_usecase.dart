import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

class SetFernieNsfwParams {
  final int fernieId;
  final bool isNsfw;

  const SetFernieNsfwParams({required this.fernieId, required this.isNsfw});
}

/// Marca o desmarca un fernie como contenido no apto.
///
/// Lo que hace es esconderlo, no apagarlo: el fernie marcado sigue entrenando a
/// los modelos que lo tengan y sigue proponiendo lo suyo al detectarse. Con el
/// filtro puesto, simplemente deja de aparecer en pantalla.
class SetFernieNsfwUseCase
    extends UseCase<DataState<bool>, SetFernieNsfwParams> {
  final FernieRepository _repository;

  SetFernieNsfwUseCase(this._repository);

  @override
  Future<DataState<bool>> call({SetFernieNsfwParams? params}) {
    return _repository.setFernieNsfw(params!.fernieId, isNsfw: params.isNsfw);
  }
}
