import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/media/data/services/import_feed.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';

/// Recorre una fuente y va soltando lo que encuentra, desde la cola de
/// trabajos.
///
/// La importación estaba dentro del bloc, y eso la ataba a la pantalla: no
/// salía en la lista de tareas de fondo, sólo se podía parar desde el botón de
/// la propia pantalla, y no había forma de saber desde ningún otro sitio que
/// había algo en marcha. Traérsela aquí la deja donde está todo lo que tarda.
///
/// Lo que trae no vuelve por el resultado del trabajo sino por [ImportFeed]:
/// son cientos de contenidos que la rejilla tiene que ir pintando conforme
/// llegan, no un montón al final.
class ImportJobRunner {
  final ScanSourceUseCase _scan;
  final ImportFeed _feed;

  ImportJobRunner({
    required ScanSourceUseCase scan,
    required ImportFeed feed,
  })  : _scan = scan,
        _feed = feed;

  /// De dónde se trae, por el identificador de la fuente.
  static const sourceKey = 'source';

  /// Hasta dónde: una cuenta, todo, o hasta la importación anterior.
  static const limitKey = 'limit';

  /// Qué creadores de la fuente, cuando el usuario ha elegido unos cuantos.
  static const creatorsKey = 'creators';

  /// Lo que la cola llama.
  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final source = ImportSource.fromId(context.payload<String>(sourceKey));
    final limit = context.payload<int>(limitKey) ?? unlimitedImportLimit;
    final id = context.job.id;

    var arrived = 0;

    try {
      // La señal del trabajo baja hasta el recorrido de las fuentes: parar desde
      // el panel de tareas tiene que parar la importación de verdad, y sólo
      // ésta, no lo que se haya lanzado al lado.
      final stream = await _scan(params: (
        source: source,
        limit: limit,
        token: context.token,
        creators: {
          for (final one in context.payload<List<dynamic>>(creatorsKey) ?? const [])
            if (one is String) one,
        },
      ));

      await for (final result in stream) {
        _feed.add(id, result);

        // El total no se sabe de antemano —hasta que no se recorre la cuenta no
        // hay forma de saber cuánto hay—, así que la barra da vueltas y lo que
        // se cuenta es lo que ya ha llegado.
        if (result is DataSuccess && result.data != null) {
          context.report(++arrived);
        }
      }
    } finally {
      // Pase lo que pase, la pantalla tiene que enterarse de que ya no viene
      // nada: con la tubería abierta se quedaría esperando con el indicador
      // puesto para siempre.
      await _feed.close(id);
    }
  }
}
