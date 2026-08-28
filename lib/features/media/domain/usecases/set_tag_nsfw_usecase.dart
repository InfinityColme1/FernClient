import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué etiqueta se marca y cómo.
class SetTagNsfwParams {
  final int tagId;
  final bool isNsfw;

  const SetTagNsfwParams({required this.tagId, required this.isNsfw});
}

/// Marca o desmarca una etiqueta como contenido no apto.
///
/// Devuelve a cuántos contenidos afecta —los suyos y los de toda su rama de
/// hijas—, que es lo que la ficha enseña: marcar sin decir cuánto desaparece es
/// pedirle al usuario que lo descubra por su cuenta.
class SetTagNsfwUseCase extends UseCase<DataState<int>, SetTagNsfwParams> {
  final LocalMediaRepository _repository;

  SetTagNsfwUseCase(this._repository);

  @override
  Future<DataState<int>> call({SetTagNsfwParams? params}) {
    return _repository.setTagNsfw(params!.tagId, isNsfw: params.isNsfw);
  }
}
