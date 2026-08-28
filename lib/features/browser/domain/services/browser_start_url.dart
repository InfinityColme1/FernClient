import 'package:Fern/core/constants/app_constants.dart';

/// Si esta dirección puede llegar a enseñar una página.
///
/// El navegador se queda en blanco de vez en cuando y no había forma de saber
/// por qué. Ésta es una de las sospechas y la única que se puede descartar sin
/// reproducir el fallo: la dirección con la que arranca sale de donde se quedó
/// la última vez, y ahí puede haberse guardado cualquier cosa —un `about:blank`
/// de una redirección, un `data:` de una página que se dibujó sola, una entrada
/// a medio escribir—. Ninguna de ésas enseña nada al volver.
bool isBrowsableUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;

  final parsed = Uri.tryParse(url.trim());
  if (parsed == null) return false;

  // Sólo la web. `about:`, `data:`, `file:` y `javascript:` son direcciones
  // válidas y ninguna sirve para volver a donde uno estaba.
  if (parsed.scheme != 'http' && parsed.scheme != 'https') return false;

  return parsed.host.isNotEmpty;
}

/// Por dónde arranca el navegador, de lo más concreto a lo más general.
///
/// [requested] es lo que haya pedido quien abrió la pantalla; [lastVisited] es
/// dónde se quedó la última vez —volver a la pantalla no devuelve al principio,
/// igual que en cualquier otra— y [home] es la página de inicio de los ajustes.
///
/// Cada una se salta si no puede enseñar nada, y si ninguna vale queda la de
/// fábrica: es preferible arrancar en un sitio que no es el que uno esperaba a
/// arrancar en una pantalla en blanco.
String browserStartUrl({
  String? requested,
  String? lastVisited,
  String? home,
}) {
  for (final candidate in [requested, lastVisited, home]) {
    if (isBrowsableUrl(candidate)) return candidate!.trim();
  }

  return browserHomeUrl;
}

/// Qué hacer cuando una carga se cae.
enum BrowserRecovery {
  /// Contarlo y quedarse donde se está.
  ///
  /// Es lo que toca casi siempre: si ya se estaba viendo algo, una carga fallida
  /// es una página que no ha ido, no un navegador roto, y tirar de ahí al
  /// usuario sería peor que el fallo.
  report,

  /// Volver a la página de inicio.
  ///
  /// Sólo cuando no hay nada que perder: la pantalla está en blanco, es la carga
  /// principal la que ha fallado y no se ha intentado ya.
  goHome,
}

/// Si un fallo de carga merece volver a la página de inicio.
///
/// [hasPageShown] es si el navegador ha llegado a enseñar algo en esta visita.
/// [alreadyRecovered] evita el bucle: si la página de inicio es la que falla,
/// insistir deja la pantalla dando vueltas en vez de en blanco, que es peor.
/// [isMainFrame] descarta lo que falla dentro de una página que sí ha cargado
/// (un anuncio, un marco, una imagen), que no tiene nada que ver con esto.
BrowserRecovery browserRecoveryFor({
  required bool hasPageShown,
  required bool alreadyRecovered,
  required bool isMainFrame,
}) {
  if (hasPageShown || alreadyRecovered || !isMainFrame) {
    return BrowserRecovery.report;
  }

  return BrowserRecovery.goHome;
}
