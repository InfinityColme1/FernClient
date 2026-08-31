import 'package:flutter/foundation.dart';

/// Qué detección se está señalando sobre el contenido.
///
/// El panel enseña «Estrella 66 %» y la pregunta inmediata es **dónde**. Sin
/// esto la respuesta no existe: el modelo apuntó el rectángulo al detectar, se
/// guarda con la sugerencia, y no se enseñaba en ninguna parte.
///
/// Vive fuera de las dos pantallas porque son dos: el panel es quien sabe sobre
/// qué fila está el ratón, y el visor es quien puede pintar encima del
/// contenido. Pasarlo por el árbol de widgets obligaría a que el visor conociera
/// el panel, que es justo lo que no debe.
/// Una detección señalada: dónde está, cómo se llama y de qué fotograma es.
typedef SpottedBox = ({
  int id,
  ({double x, double y, double w, double h}) box,
  String label,
  int? frameMs,
});

class SuggestionSpotlight extends ChangeNotifier {
  /// Lo que se está señalando ahora mismo.
  ///
  /// **Varias y no una**: un modelo puede ver cuatro coches en una foto, y ésas
  /// son cuatro detecciones de la misma fila del panel. Señalar la fila tiene
  /// que enseñar los cuatro rectángulos — con uno solo, las otras tres seguían
  /// existiendo y no había forma de verlas.
  List<SpottedBox> _spotted = const [];

  /// La fila cuya caja se ha dejado puesta a propósito.
  ///
  /// Fijar manda sobre el ratón: quien ha pulsado una fila quiere ver **esas**
  /// cajas mientras decide, y que se las quite el puntero al moverse es justo lo
  /// que hace inservible el enseñar-al-pasar.
  ///
  /// Se guarda el identificador de la primera del grupo, que es la que la fila
  /// usa para reconocerse.
  int? _pinned;

  int? get pinnedId => _pinned;

  List<SpottedBox> get spotted => _spotted;

  /// De qué detecciones son las cajas que se están enseñando.
  ///
  /// Hace falta para soltarlas cuando su fila desaparece: contestar quita la
  /// fila de la lista, y una fila que ya no está no puede avisar de que el ratón
  /// ha salido de ella.
  Set<int> get showingIds => {for (final one in _spotted) one.id};

  bool get isEmpty => _spotted.isEmpty;

  /// Señala estas detecciones.
  ///
  /// Las de una sola fila cada vez: enseñar todas las cajas de un contenido con
  /// seis sugerencias lo llena de rectángulos que se pisan, y la pregunta que se
  /// está contestando es «dónde ha visto **esto**».
  void show(List<SpottedBox> boxes) {
    if (_pinned != null) return;

    _set(boxes);
  }

  /// Deja puestas las cajas de este grupo, o las quita si ya eran las fijadas.
  ///
  /// Devuelve si han quedado fijadas, que es lo que la fila necesita saber para
  /// pintarse como elegida.
  bool pin(List<SpottedBox> boxes) {
    if (boxes.isEmpty) return false;

    final id = boxes.first.id;

    if (_pinned == id) {
      _pinned = null;
      clear();

      return false;
    }

    _pinned = id;
    _set(boxes);

    return true;
  }

  void _set(List<SpottedBox> boxes) {
    if (_sameAs(boxes)) return;

    _spotted = List.unmodifiable(boxes);
    notifyListeners();
  }

  bool _sameAs(List<SpottedBox> boxes) {
    if (boxes.length != _spotted.length) return false;

    for (var index = 0; index < boxes.length; index++) {
      if (boxes[index] != _spotted[index]) return false;
    }

    return true;
  }

  /// Suelta todo, incluido lo fijado.
  ///
  /// Es lo que hay que llamar al cambiar de contenido o al salir del visor: lo
  /// fijado sobrevive al ratón **a propósito**, así que sin esto se quedaría
  /// puesto para siempre, pintando la caja de una imagen sobre otra y sin dejar
  /// que el ratón vuelva a mandar nunca.
  void release() {
    _pinned = null;
    clear();
  }

  /// Suelta las cajas si son de alguna de [ids].
  ///
  /// Lo llama quien contesta sugerencias: la fila que las enseñaba acaba de irse
  /// de la lista y ya no puede apagarlas ella, así que se quedarían pintadas
  /// sobre el contenido hasta cambiar de imagen.
  void releaseIf(Iterable<int> ids) {
    final showing = showingIds;
    if (showing.isEmpty) return;
    if (!ids.any(showing.contains)) return;

    release();
  }

  /// Deja de señalar.
  ///
  /// Lo fijado sólo lo suelta quien lo fijó: el ratón al salir de una fila no
  /// puede quitar lo que el usuario dejó puesto a propósito.
  void clear() {
    if (_pinned != null) return;
    if (_spotted.isEmpty) return;

    _spotted = const [];
    notifyListeners();
  }
}
