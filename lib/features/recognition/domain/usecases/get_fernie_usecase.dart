import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Un fernie concreto, con sus recuentos ya resueltos.
///
/// El escondido se contesta igual que el que no existe. Distinguirlos sería
/// contestar «existe, pero no te lo enseño», que es media respuesta y delata la
/// otra media.
class GetFernieUseCase extends UseCase<DataState<FernieEntity>, int> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  GetFernieUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<FernieEntity>> call({int? params}) async {
    if (_visibility.hidesFernie(params!)) {
      return DataException(Exception('Fernie $params no existe'));
    }

    return _repository.getFernie(params);
  }
}
