import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué creador se marca y cómo.
class SetCreatorNsfwParams {
  final int creatorId;
  final bool isNsfw;

  const SetCreatorNsfwParams({required this.creatorId, required this.isNsfw});
}

/// Marca o desmarca un creador como contenido no apto.
///
/// Devuelve a cuántos contenidos afecta, que es lo que la ficha enseña: marcar
/// sin decir cuánto desaparece es pedirle al usuario que lo descubra por su
/// cuenta.
class SetCreatorNsfwUseCase
    extends UseCase<DataState<int>, SetCreatorNsfwParams> {
  final LocalMediaRepository _repository;

  SetCreatorNsfwUseCase(this._repository);

  @override
  Future<DataState<int>> call({SetCreatorNsfwParams? params}) {
    return _repository.setCreatorNsfw(
      params!.creatorId,
      isNsfw: params.isNsfw,
    );
  }
}
