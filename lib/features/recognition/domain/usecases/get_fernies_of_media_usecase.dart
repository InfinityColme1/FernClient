import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Los fernies que tienen alguna región en este contenido.
///
/// Es lo que enseña la sección de fernies del panel de información: los que se
/// ven ahí son los que están marcados **en esto**, no todos los de la
/// aplicación.
class GetFerniesOfMediaUseCase
    extends UseCase<DataState<List<FernieEntity>>, int> {
  final FernieRepository _repository;

  GetFerniesOfMediaUseCase(this._repository);

  @override
  Future<DataState<List<FernieEntity>>> call({int? params}) {
    return _repository.getFerniesOfMedia(params!);
  }
}
