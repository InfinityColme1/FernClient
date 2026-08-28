import 'package:flutter/widgets.dart';

/// A qué se parecen por dentro las pantallas de la aplicación.
///
/// **Para qué sirve agruparlas.** Cambiar de una pantalla a otra no es siempre
/// el mismo gesto. Pasar de la biblioteca a la importación es cambiar de
/// contenido: la pantalla está montada igual, y lo único que cambia es lo que
/// hay dentro. Pasar de la biblioteca a la gestión de etiquetas es cambiar de
/// sitio: lo que había se va y llega otra cosa con otra forma.
///
/// Si las dos se animan igual, una de las dos sale mal. Con la primera sobra
/// todo movimiento —la maquetación no cambia, así que moverla es mentir— y con
/// la segunda hace falta, porque hay que entender que la pantalla se ha
/// reorganizado entera.
enum ScreenFamily {
  /// Una cabecera arriba y una rejilla de contenido debajo: la biblioteca, la
  /// importación, la papelera, los favoritos y los modelos.
  grid,

  /// Tres piezas: la ficha editable, la lista de la derecha y la rejilla de lo
  /// que cuelga de lo elegido. La gestión de etiquetas y la de creadores.
  management,

  /// El comparador de contenido repetido: los grupos a un lado y lo que se está
  /// comparando al otro.
  repeated,

  /// Todo lo demás. Sin coreografía: entra y sale con un fundido.
  plain,

  /// El navegador: **se cambia de golpe, sin animación ninguna**.
  ///
  /// No es pereza. Lo que ocupa esa pantalla no lo pinta Flutter: es el motor de
  /// navegación del sistema, incrustado como una superficie propia. Desvanecerlo
  /// o moverlo obliga a copiar esa superficie entera en cada fotograma, y el
  /// resultado o no se ve o va a tirones — que es exactamente lo que se veía.
  ///
  /// Un corte limpio es más honesto que una animación que no puede salir bien.
  instant,
}

/// Qué papel hace un trozo de pantalla dentro de su familia.
///
/// De aquí sale **por dónde entra y por dónde se va** cada uno. Los que ocupan
/// la parte de abajo se van hacia abajo, los de arriba hacia arriba, y los de un
/// lado hacia su lado: cada pieza se retira por donde estaba, que es lo que hace
/// que el conjunto se lea como una sola cosa moviéndose y no como cuatro trozos
/// sueltos.
enum ScreenSlot {
  /// La cabecera de una pantalla de rejilla. Se va por arriba.
  header,

  /// La rejilla de contenido. Se va por abajo.
  grid,

  /// La ficha editable de las pantallas de gestión. Se va por arriba.
  card,

  /// La lista lateral de las pantallas de gestión. Se va por la derecha.
  list,

  /// Los grupos del comparador de repetidos. Se van por la izquierda.
  groups,

  /// El comparador en sí. Se va por la derecha.
  compare,
}

/// Hacia dónde se retira cada papel, en fracción del tamaño de lo que se mueve.
///
/// Fracciones y no píxeles: lo que se mueve es de tamaños muy distintos —una
/// cabecera es una franja y una rejilla es media pantalla— y una distancia fija
/// se quedaría corta en una y larga en la otra.
const Map<ScreenSlot, Offset> screenSlotExit = {
  ScreenSlot.header: Offset(0, -screenSlotShift),
  ScreenSlot.grid: Offset(0, screenSlotShift),
  ScreenSlot.card: Offset(0, -screenSlotShift),
  ScreenSlot.list: Offset(screenSlotShift, 0),
  ScreenSlot.groups: Offset(-screenSlotShift, 0),
  ScreenSlot.compare: Offset(screenSlotShift, 0),
};

/// Cuánto se aparta cada pieza, en proporción a su propio tamaño.
///
/// Un cuarto: lo justo para que se lea la dirección. Sacarlas del todo obligaría
/// a recorrer media pantalla en el tiempo que dura la transición, y eso o va
/// lento o va a tirones.
const screenSlotShift = 0.25;

/// De dónde viene y a dónde va la navegación que esté en marcha.
///
/// **Por qué esto no vive en la pantalla.** La animación de una transición la
/// pintan las dos pantallas a la vez, y ninguna de las dos sabe cuál es la otra:
/// la que sale no sabe qué llega y la que entra no sabe qué había. Lo único que
/// puede saberlo es quien las cambia.
///
/// Se lee en cada fotograma en vez de guardarse al empezar, y a propósito: así
/// las dos pantallas leen lo mismo y no puede pasar que una crea que es un
/// cambio dentro de la familia y la otra crea que no.
class ScreenChoreography extends ChangeNotifier {
  ScreenFamily _from = ScreenFamily.plain;
  ScreenFamily _to = ScreenFamily.plain;
  String? _location;

  ScreenFamily get from => _from;
  ScreenFamily get to => _to;

  /// Si en el cambio interviene una pantalla que no se puede animar.
  ///
  /// Entonces no se anima **ninguno de los dos lados**: media transición sí y
  /// media no se ve peor que ninguna.
  bool get isInstant =>
      _from == ScreenFamily.instant || _to == ScreenFamily.instant;

  /// Si el cambio es entre dos pantallas de la misma familia.
  ///
  /// Entonces no se mueve nada de sitio: sólo se cambia el contenido con un
  /// fundido. La maquetación es la misma a los dos lados, y animarla sería
  /// enseñar un movimiento que no ocurre.
  bool get isWithinFamily => _from == _to;

  /// Se va a [location], que es de la familia [family].
  ///
  /// Repetir la misma dirección no cuenta: una pantalla se reconstruye muchas
  /// veces sin que nadie haya navegado, y dar eso por un cambio dejaría a media
  /// transición creyendo que sale de donde en realidad está entrando.
  void moveTo(String location, ScreenFamily family) {
    if (location == _location) return;

    _location = location;
    _from = _to;
    _to = family;
    notifyListeners();
  }
}
