import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:Fern/features/settings/data/services/leftover_files.dart';

/// Los ficheros de la carpeta de trabajo que ya no usa nadie.
///
/// Va en dos pasos —mirar y barrer— y no en uno, a diferencia de casi todo lo
/// demás: aquí no se van sólo copias nuestras, se van también **descargas**, y
/// un fichero borrado no vuelve. Primero se dice qué hay y cuánto ocupa, y sólo
/// se borra si el usuario dice que sí.
class SweepUnusedFilesUseCase {
  final LeftoverFiles _leftovers;

  SweepUnusedFilesUseCase({required LeftoverFiles leftovers})
      : _leftovers = leftovers;

  /// Qué se llevaría la limpieza, sin llevarse nada.
  Future<DataState<LeftoverPlan>> find() async {
    try {
      return DataSuccess(await _leftovers.find());
    } on Exception catch (error) {
      return DataException(error);
    }
  }

  /// Y ahora sí.
  Future<DataState<AvatarSweep>> sweep(LeftoverPlan plan) async {
    try {
      return DataSuccess(await _leftovers.sweep(plan.all));
    } on Exception catch (error) {
      return DataException(error);
    }
  }
}
