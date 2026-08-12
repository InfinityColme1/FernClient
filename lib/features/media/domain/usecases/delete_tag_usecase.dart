import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Borra una etiqueta de la base de datos, por su identificador.
///
/// Los contenidos que la tenían la pierden, pero no se borran: se quedan con sus
/// demás etiquetas.
class DeleteTagUseCase extends UseCase<DataState, int> {
  final LocalMediaRepository _repository;

  DeleteTagUseCase(this._repository);

  @override
  Future<DataState> call({int? params}) {
    return _repository.deleteTag(params!);
  }
}
