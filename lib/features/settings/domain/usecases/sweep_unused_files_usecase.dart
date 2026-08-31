import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';

/// Barre los ficheros de utilidad que ya no usa nadie.
///
/// Hoy son los avatares, que es donde se acumulan: son copias que hace la
/// aplicación al elegir una imagen, y la anterior dejaba de estar apuntada por
/// nadie al cambiarla. Invisible, porque no sale en ninguna pantalla, y
/// creciendo con cada cambio.
///
/// Devuelve cuánto se ha llevado para poder decirlo: una limpieza que no dice
/// nada se ve igual haya barrido doscientos ficheros o ninguno.
class SweepUnusedFilesUseCase extends UseCase<DataState<AvatarSweep>, void> {
  final AvatarJanitor _janitor;

  SweepUnusedFilesUseCase({required AvatarJanitor janitor})
      : _janitor = janitor;

  @override
  Future<DataState<AvatarSweep>> call({void params}) async {
    try {
      return DataSuccess(await _janitor.sweep());
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
