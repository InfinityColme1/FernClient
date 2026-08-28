import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';

/// Si al arrancar toca que la aplicación busque repetidos por su cuenta.
///
/// Está aparte y sin dependencias a propósito: decidir *cuándo* toca es lo único
/// que puede salir mal de un escaneo automático sin que nadie se entere. Que
/// arranque de más se paga en horas de disco; que no arranque nunca deja la
/// función apagada sin decirlo. Una función de tres argumentos se prueba con
/// todos los casos de borde y se lee de una vez.
///
/// [lastScan] nulo significa que nunca se ha escaneado, y entonces **sí toca**:
/// la primera vez es justo cuando más hay que encontrar.
bool isDuplicateScanDue({
  required bool enabled,
  required DuplicateScanPeriod period,
  required DateTime? lastScan,
  required DateTime now,
}) {
  if (!enabled) return false;
  if (lastScan == null) return true;

  // Una marca en el futuro no puede dejar el escaneo apagado hasta entonces: el
  // reloj del equipo se puede haber movido, y la alternativa es que la función
  // no vuelva a correr en meses sin que nada lo explique.
  if (lastScan.isAfter(now)) return true;

  return now.difference(lastScan) >= period.span;
}
