import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Las etiquetas que están por encima de las indicadas.
///
/// Es lo que deja al diálogo de etiquetas enseñar la rama entera según se
/// elige: el guardado las pone igualmente, pero aparecerían sin avisar.
class GetTagAncestorsUseCase
    extends UseCase<DataState<List<TagEntity>>, List<TagEntity>> {
  final LocalMediaRepository _repository;

  GetTagAncestorsUseCase(this._repository);

  @override
  Future<DataState<List<TagEntity>>> call({List<TagEntity>? params}) {
    return _repository.getTagAncestors(params ?? const []);
  }
}
