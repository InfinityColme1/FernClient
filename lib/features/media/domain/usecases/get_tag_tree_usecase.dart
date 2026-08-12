import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Las etiquetas de la aplicación con su jerarquía: las raíces, cada una con sus
/// descendientes. Es lo que lista la sección de etiquetas del menú lateral.
class GetTagTreeUseCase extends UseCase<DataState<List<TagEntity>>, void> {
  final LocalMediaRepository _localMediaRepository;

  GetTagTreeUseCase({required LocalMediaRepository localMediaRepository})
      : _localMediaRepository = localMediaRepository;

  @override
  Future<DataState<List<TagEntity>>> call({void params}) {
    return _localMediaRepository.getTagTree();
  }
}
