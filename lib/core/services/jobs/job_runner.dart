import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';

/// Lo que recibe quien ejecuta un trabajo.
///
/// Trae lo que hay que hacer ([job], con su `payload`), por dónde avisar de lo
/// que lleva hecho ([report]) y por dónde enterarse de que hay que parar
/// ([token]).
class JobContext {
  final Job job;
  final CancellationToken token;

  /// Avisa de que van [done] unidades de [total]. Pasar [total] permite
  /// ajustarlo sobre la marcha, que es lo normal: hasta que no se cuenta lo que
  /// hay no se sabe cuánto es.
  ///
  /// Con [stage] se dice además **en qué se está yendo el tiempo**: el nombre
  /// del modelo que mira ahora mismo, por ejemplo. Sin eso, un trabajo largo es
  /// una barra que avanza y nada más.
  final void Function(int done, {int? total, String? stage}) report;

  const JobContext({
    required this.job,
    required this.token,
    required this.report,
  });

  /// Lo que hay en el `payload`, sin que quien lo lee tenga que castear a mano.
  T? payload<T>(String key) {
    final value = job.payload[key];

    return value is T ? value : null;
  }

  /// Este trabajo es de los que la aplicación hace por su cuenta, así que tiene
  /// que dejar respirar a la máquina.
  ///
  /// Quien lo ejecute debe consultarlo y meter una pausa cada tantas unidades:
  /// la cola decide *cuándo* arranca un trabajo de fondo, pero no puede impedir
  /// que, una vez arrancado, se coma el equipo.
  bool get shouldYield => job.priority == JobPriority.low;
}

/// Quien sabe hacer un tipo de trabajo.
///
/// Se registra por [JobType] en la cola: ella decide cuándo toca y con qué
/// prioridad, y esto es lo único que sabe de verdad qué hay que hacer.
typedef JobRunner = Future<void> Function(JobContext context);
