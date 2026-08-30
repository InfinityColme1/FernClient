import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Etiqueta que ya existe y las direcciones que se le quieren dejar puestas.
class SaveTagSourceUrlsParams {
  final int tagId;
  final List<String> urls;

  /// Cuáles de [urls] quedan marcadas como no aptas.
  final List<String> nsfwUrls;

  const SaveTagSourceUrlsParams({
    required this.tagId,
    required this.urls,
    this.nsfwUrls = const [],
  });
}

/// Vincula unas direcciones con una etiqueta: a partir de ahí, lo que se importe
/// de debajo de alguna de ellas nace con esa etiqueta puesta.
class SaveTagSourceUrlsUseCase
    extends UseCase<DataState<TagEntity>, SaveTagSourceUrlsParams> {
  final LocalMediaRepository _repository;

  SaveTagSourceUrlsUseCase(this._repository);

  @override
  Future<DataState<TagEntity>> call({SaveTagSourceUrlsParams? params}) {
    return _repository.saveTagSourceUrls(
      params!.tagId,
      params.urls,
      nsfwUrls: params.nsfwUrls,
    );
  }
}
