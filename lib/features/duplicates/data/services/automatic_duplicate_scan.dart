import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/duplicates/domain/services/scan_schedule.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';

/// La aplicación busca contenido repetido por su cuenta cada cierto tiempo.
///
/// Corre al arrancar y no vuelve a mirar: si el equipo lleva meses encendido y
/// se cumple el periodo mientras tanto, el escaneo espera al arranque siguiente.
/// Es a propósito. Lo contrario es un temporizador vivo toda la sesión para
/// disparar algo que se mide en meses, y arrancar un trabajo de horas en mitad
/// de lo que el usuario estuviera haciendo es justo lo que la prioridad baja
/// intenta evitar.
///
/// Va con [JobPriority.low]: no arranca mientras haya algo más importante en
/// marcha, y puede tardar lo que haga falta. El usuario no lo ha pedido y no lo
/// está mirando; lo único que verá es el aviso, y sólo si aparece algo.
class AutomaticDuplicateScan {
  final JobQueue _jobs;
  final AppSettingsEntity Function() _settings;
  final DateTime? Function() _lastScan;
  final DateTime Function() _now;

  AutomaticDuplicateScan({
    required JobQueue jobs,
    required AppSettingsEntity Function() settings,
    required DateTime? Function() lastScan,
    DateTime Function()? now,
  })  : _jobs = jobs,
        _settings = settings,
        _lastScan = lastScan,
        _now = now ?? DateTime.now;

  /// Encola el escaneo si toca, y dice si lo ha hecho.
  ///
  /// No espera a que termine: encolar es decir que hay que hacerlo, y esto corre
  /// mientras la aplicación todavía se está montando.
  bool runIfDue() {
    final settings = _settings();

    final isDue = isDuplicateScanDue(
      enabled: settings.automaticDuplicateScan,
      period: settings.duplicateScanPeriod,
      lastScan: _lastScan(),
      now: _now(),
    );

    if (!isDue) return false;

    // Si ya hay uno en marcha o esperando turno no se encola otro: el trabajo
    // es el mismo y dos a la vez sería hashear la biblioteca dos veces.
    final already = _jobs.activeJobs.any((job) => job.type == JobType.duplicateScan);
    if (already) return false;

    _jobs.enqueue(type: JobType.duplicateScan, priority: JobPriority.low);

    return true;
  }
}
