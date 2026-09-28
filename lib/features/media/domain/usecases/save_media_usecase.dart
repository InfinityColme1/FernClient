import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué se guarda y si eso lo da por revisado.
typedef SaveMediaParams = ({MediaEntity media, bool confirm});

/// Guarda lo que el panel tiene puesto.
///
/// Con `confirm` es la confirmación de siempre: el contenido pasa a definitivo y
/// la gestión de ficheros lo lleva a su carpeta. Sin él sólo baja lo escrito,
/// que es lo que hace el guardado automático del panel en cada cambio.
class SaveMediaUseCase extends UseCase<DataState, SaveMediaParams> {
  final LocalMediaRepository _repository;

  SaveMediaUseCase(this._repository);

  @override
  Future<DataState> call({SaveMediaParams? params}) {
    return _repository.saveMedia(params!.media, confirm: params.confirm);
  }
}
