import 'package:Fern/core/constants/app_constants.dart';

/// De qué avisa la aplicación.
///
/// Son las cuatro cosas que tardan y que el usuario lanza y se olvida: si no se
/// le avisa, tiene que acordarse de volver a mirar. Cada una lleva a la pantalla
/// donde se resuelve, que es donde se pone el contador.
enum NotificationKind {
  /// El escaneo automático ha encontrado contenido repetido.
  duplicatesFound(id: 'duplicates', route: repeatedMediaRoute),

  /// Un entrenamiento ha terminado, bien o mal.
  trainingFinished(id: 'training', route: modelsRoute),

  /// Se ha terminado de reconocer un lote y queda contenido por validar.
  recognitionFinished(id: 'recognition', route: importRoute),

  /// Se ha terminado de importar de una fuente remota.
  remoteImportFinished(id: 'remote_import', route: importRoute);

  const NotificationKind({required this.id, required this.route});

  /// Con lo que se guarda en las preferencias. No cambiarlo: los contadores y
  /// los sonidos elegidos se quedarían huérfanos.
  final String id;

  /// La pantalla donde se resuelve. Es donde va el contador y el sitio al que,
  /// al llegar, se da por visto el aviso.
  final String route;

  static NotificationKind? fromId(String id) {
    for (final kind in NotificationKind.values) {
      if (kind.id == id) return kind;
    }

    return null;
  }
}

/// Lo que hay pendiente de mirar en una pantalla.
///
/// No se guarda un histórico de avisos sueltos, sólo cuántos hay por sitio: lo
/// que enseña el menú lateral es un contador, y una lista de avisos que nadie
/// consulta sería estado de más.
class AppNotificationCounts {
  final Map<NotificationKind, int> byKind;

  const AppNotificationCounts(this.byKind);

  static const empty = AppNotificationCounts({});

  int of(NotificationKind kind) => byKind[kind] ?? 0;

  /// Cuánto hay pendiente en una pantalla, sumando todo lo que lleva allí: la
  /// importación recoge tanto lo reconocido como lo recién traído de fuera.
  int forRoute(String route) {
    var total = 0;
    for (final entry in byKind.entries) {
      if (entry.key.route == route) total += entry.value;
    }

    return total;
  }

  bool get isEmpty => byKind.values.every((count) => count == 0);
}
