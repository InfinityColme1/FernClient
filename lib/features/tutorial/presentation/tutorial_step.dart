/// Un paso del tutorial: a qué señala, qué cuenta y dónde pasa.
class TutorialStep {
  /// A qué parte de la pantalla señala, de `TutorialAnchorId` o el
  /// identificador de una fila del menú. Sin ello el paso se enseña en medio,
  /// que es lo que hace falta para dar la bienvenida, para despedirse y para
  /// contar algo que pasa en un sitio al que el tutorial no puede llevar —el
  /// visor, sin ir más lejos, que se abre encima de todo.
  final String? anchorId;

  /// A qué pantalla hay que ir antes de enseñarlo.
  ///
  /// Es lo que permite que un recorrido cruce pantallas: el de los gestores
  /// empieza en creadores y termina en etiquetas sin que nadie tenga que pulsar
  /// nada. Sólo se navega si no se está ya ahí.
  ///
  /// **Nunca al visor.** El visor se abre por encima del marco de la aplicación,
  /// y el velo del tutorial vive dentro de ese marco: llevar ahí sería taparlo
  /// con la pantalla que se quería enseñar.
  final String? route;

  final String title;
  final String body;

  const TutorialStep({
    required this.title,
    required this.body,
    this.anchorId,
    this.route,
  });
}
