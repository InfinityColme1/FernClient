import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/database_maintenance_service.dart';

/// Vacía la base de datos entera.
///
/// Devuelve un [DataState] y no un `void` porque quien lo pide tiene que poder
/// decir si ha ido: un borrado que falla a medias y se anuncia como hecho deja
/// al usuario creyendo que empieza de cero cuando no.
class WipeDatabaseUseCase extends UseCase<DataState<void>, void> {
  final DatabaseMaintenanceService _maintenance;

  WipeDatabaseUseCase({required DatabaseMaintenanceService maintenance})
      : _maintenance = maintenance;

  @override
  Future<DataState<void>> call({void params}) async {
    try {
      await _maintenance.wipe();

      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
