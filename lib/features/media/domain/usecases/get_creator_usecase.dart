import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Un creador por su identificador, con sus etiquetas cargadas.
///
/// Existe por lo segundo: la lista de creadores no las trae —sería una consulta
/// por fila para pintar algo que no se enseña— así que quien las necesita las
/// pide de uno en uno. Devuelve `null` si el creador ya no existe o si el
/// bloqueo lo esconde.
class GetCreatorUseCase extends UseCase<DataState<CreatorEntity?>, int> {
  final LocalMediaRepository _repository;

  GetCreatorUseCase(this._repository);

  @override
  Future<DataState<CreatorEntity?>> call({int? params}) =>
      _repository.getCreator(params!);
}
