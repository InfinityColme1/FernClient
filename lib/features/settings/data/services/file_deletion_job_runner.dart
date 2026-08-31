import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';

/// Borra del disco una lista de ficheros, uno a uno y contándolo.
///
/// Va por la cola y no en el diálogo que lo pide porque **son miles**: vaciar
/// una biblioteca entera con sus ficheros es una operación de minutos, y hacerla
/// en el hilo de la interfaz deja la ventana bloqueada sin poder decir por dónde
/// va ni cuánto queda.
///
/// Que las filas ya no estén y los ficheros tarden en irse no deja nada a medias
/// a la vista: para la aplicación ese contenido ya no existe, y lo que queda en
/// el disco es exactamente lo que este trabajo está borrando.
///
/// **Un fichero que no se deja borrar no para al resto.** Lo que se pidió fue
/// vaciar; que el antivirus tenga uno abierto no puede dejar los otros mil
/// donde estaban.
class FileDeletionJobRunner {
  final MediaFileOrganizer _organizer;

  FileDeletionJobRunner({required MediaFileOrganizer organizer})
      : _organizer = organizer;

  /// La clave con la que viajan las rutas en el `payload` del trabajo.
  static const pathsKey = 'paths';

  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final paths = context.payload<List<Object?>>(pathsKey) ?? const [];
    if (paths.isEmpty) return;

    context.report(0, total: paths.length);

    var done = 0;

    for (final path in paths) {
      if (context.token.isCancelled) break;

      if (path is String) await deleteFileAt(path);

      context.report(++done);
    }

    // Las carpetas que se hayan quedado sin nada dentro. Sin esto, vaciar la
    // biblioteca deja el árbol de carpetas entero en pie con todos los cajones
    // vacíos, y parece que no se ha borrado nada.
    await _organizer.removeEmptyFolders();
  }
}
