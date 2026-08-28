import 'dart:math';

/// Con qué se baraja el contenido cuando se pide verlo al azar.
///
/// **Por qué esto no es un `shuffle()` y ya.** Barajar en cada lectura sería lo
/// obvio y está mal: la rejilla vuelve a pedir el contenido al desplazarse y al
/// volver del visor, así que se recolocaría sola por el camino. El resultado es
/// que se ve lo mismo dos veces y hay contenido que no aparece nunca.
///
/// Entonces la semilla tiene que quedarse quieta. Pero si se queda quieta para
/// siempre, «al azar» sale una sola vez y a partir de ahí es un orden fijo más.
///
/// La respuesta es que la semilla cambia **cuando alguien lo pide**, no cuando
/// alguien lee: al pulsar «al azar» se baraja de nuevo, y de ahí hasta la
/// siguiente pulsación el orden es estable. Pulsarlo estando ya en «al azar»
/// vuelve a barajar, que es lo que se espera de ese botón.
class ShuffleSeed {
  int _value = _now();

  static int _now() => DateTime.now().microsecondsSinceEpoch;

  /// La semilla de la baraja que está puesta.
  int get value => _value;

  /// Baraja de nuevo.
  ///
  /// Se asegura de que salga una distinta: dos pulsaciones seguidas dentro del
  /// mismo microsegundo darían la misma semilla y el mismo orden, y desde fuera
  /// eso se ve como un botón que no ha hecho nada.
  void renew() {
    final anterior = _value;
    var siguiente = _now();

    while (siguiente == anterior) {
      siguiente = _now() + Random().nextInt(1000) + 1;
    }

    _value = siguiente;
  }
}
