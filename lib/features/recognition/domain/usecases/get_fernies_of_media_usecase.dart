import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Los fernies que tienen alguna región en este contenido.
///
/// Es lo que enseña la sección de fernies del panel de información: los que se
/// ven ahí son los que están marcados **en esto**, no todos los de la
/// aplicación. Los escondidos tampoco salen: el panel es una lista de nombres, y
/// un nombre no se puede enseñar a medias.
class GetFerniesOfMediaUseCase
    extends UseCase<DataState<List<FernieEntity>>, int> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  GetFerniesOfMediaUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<FernieEntity>>> call({int? params}) async {
    final result = await _repository.getFerniesOfMedia(params!);
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final fernie in result.data ?? const <FernieEntity>[])
        if (!_visibility.hidesFernie(fernie.id)) fernie,
    ]);
  }
}
