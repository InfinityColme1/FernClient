import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/database_maintenance_service.dart';
import 'package:Fern/features/settings/data/services/file_deletion_job_runner.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';

/// Vacía la base de datos: entera, o sólo el contenido no apto.
///
/// Devuelve un [DataState] y no un `void` porque quien lo pide tiene que poder
/// decir si ha ido: un borrado que falla a medias y se anuncia como hecho deja
/// al usuario creyendo que empieza de cero cuando no.
///
/// Los ficheros del disco, si se han pedido, **no se borran aquí**: se encolan.
/// Son miles y tardan minutos, y esperarlos dejaría la ventana bloqueada sin
/// poder decir por dónde va. Para la aplicación ese contenido ya no existe en
/// cuanto sus filas se han ido; lo que queda en el disco es lo que el trabajo
/// está borrando.
class WipeDatabaseUseCase
    extends UseCase<DataState<void>, DatabaseWipeOptions> {
  final DatabaseMaintenanceService _maintenance;
  final JobQueue _jobs;

  WipeDatabaseUseCase({
    required DatabaseMaintenanceService maintenance,
    required JobQueue jobs,
  })  : _maintenance = maintenance,
        _jobs = jobs;

  @override
  Future<DataState<void>> call({DatabaseWipeOptions? params}) async {
    try {
      final paths = await _maintenance.wipe(
        params ?? const DatabaseWipeOptions(),
      );

      if (paths.isNotEmpty) {
        _jobs.enqueue(
          type: JobType.fileCleanup,
          payload: {FileDeletionJobRunner.pathsKey: paths},
        );
      }

      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
