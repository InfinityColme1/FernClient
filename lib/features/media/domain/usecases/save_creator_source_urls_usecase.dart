import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Creador que ya existe y las direcciones que se le quieren dejar puestas.
class SaveCreatorSourceUrlsParams {
  final int creatorId;
  final List<String> urls;

  /// Cuáles de [urls] quedan marcadas como no aptas.
  final List<String> nsfwUrls;

  const SaveCreatorSourceUrlsParams({
    required this.creatorId,
    required this.urls,
    this.nsfwUrls = const [],
  });
}

/// Vincula unas direcciones con un creador: a partir de ahí, lo que se importe
/// de debajo de alguna de ellas nace con ese creador puesto.
class SaveCreatorSourceUrlsUseCase
    extends UseCase<DataState<CreatorEntity>, SaveCreatorSourceUrlsParams> {
  final LocalMediaRepository _repository;

  SaveCreatorSourceUrlsUseCase(this._repository);

  @override
  Future<DataState<CreatorEntity>> call({SaveCreatorSourceUrlsParams? params}) {
    return _repository.saveCreatorSourceUrls(
      params!.creatorId,
      params.urls,
      nsfwUrls: params.nsfwUrls,
    );
  }
}
