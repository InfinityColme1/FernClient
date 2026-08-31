/// Una pregunta cada vez.
///
/// Preguntar es **esperar**, y ahí está el problema: entre que se pulsa la tecla
/// y el diálogo llega a montarse caben más pulsaciones, y cada una abre el suyo.
/// Aporreando escape para salir del modo fernie —que es justo lo que se hace
/// para salir de algo— salían tres y cuatro preguntas idénticas apiladas, y
/// había que contestarlas todas.
///
/// No vale con mirar si la tecla venía repetida: eso sólo tapa el caso de
/// tenerla pulsada, y con pulsaciones sueltas y rápidas pasa igual. Lo que hay
/// que saber es si **ya hay una pregunta en pantalla**, y eso sólo lo sabe quien
/// la abrió.
class SinglePrompt {
  bool _isOpen = false;

  /// Si hay una pregunta puesta ahora mismo.
  bool get isOpen => _isOpen;

  /// Abre la pregunta, o no hace nada si ya había una.
  ///
  /// Devuelve `null` cuando no la abre, que es lo mismo que devuelve cerrar una
  /// sin contestar: quien pregunta ya sabe tratar ese caso, así que no hace
  /// falta que distinga «no te he preguntado» de «no me has contestado» — en los
  /// dos casos no se sigue adelante.
  Future<T?> ask<T>(Future<T?> Function() open) async {
    if (_isOpen) return null;

    _isOpen = true;

    try {
      return await open();
    } finally {
      // Pase lo que pase, también si la pregunta revienta: una bandera que se
      // queda puesta deja la pantalla sin poder volver a preguntar nunca.
      _isOpen = false;
    }
  }
}
