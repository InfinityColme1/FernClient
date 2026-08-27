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

  /// Se ha terminado de importar, venga de donde venga.
  ///
  /// El identificador sigue diciendo «remoto» porque antes sólo avisaba de eso
  /// y cambiarlo dejaría huérfanos el contador y el sonido ya elegidos.
  importFinished(id: 'remote_import', route: importRoute),

  /// Una publicación con varios enlaces está esperando a que alguien decida.
  ///
  /// Avisa porque **la importación ya no espera**: si no se dijera, la pregunta
  /// se quedaría en la lista de tareas sin que nadie supiera que está ahí, y
  /// esos enlaces se perderían sin más.
  linkReview(id: 'link_review', route: importRoute);

  const NotificationKind({required this.id, required this.route});

  /// Con lo que se guarda en las preferencias. No cambiarlo: los contadores y
  /// los sonidos elegidos se quedarían huérfanos.
  final String id;

  /// La pantalla donde se resuelve **por defecto**. Es donde va el contador y
  /// el sitio al que, al llegar, se da por visto el aviso.
  ///
  /// Por defecto y no siempre: el reconocimiento se puede lanzar sobre contenido
  /// definitivo, y llevar entonces a la pantalla de importación es mandar al
  /// usuario a un sitio donde no está lo que acaba de reconocer. Quien avisa
  /// puede decir a dónde lleva el suyo.
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

  /// A dónde lleva cada aviso, cuando no es a su pantalla de siempre.
  ///
  /// Lo apunta quien avisa. El caso que lo justifica: reconocer contenido
  /// definitivo termina en la pantalla de contenido, no en la de importación,
  /// que es donde no está.
  final Map<NotificationKind, String> routes;

  const AppNotificationCounts(this.byKind, {this.routes = const {}});

  static const empty = AppNotificationCounts({});

  int of(NotificationKind kind) => byKind[kind] ?? 0;

  /// A dónde lleva este aviso ahora mismo.
  String routeOf(NotificationKind kind) => routes[kind] ?? kind.route;

  /// Cuánto hay pendiente en una pantalla, sumando todo lo que lleva allí: la
  /// importación recoge tanto lo reconocido como lo recién traído de fuera.
  int forRoute(String route) {
    var total = 0;
    for (final entry in byKind.entries) {
      if (routeOf(entry.key) == route) total += entry.value;
    }

    return total;
  }

  bool get isEmpty => byKind.values.every((count) => count == 0);
}
