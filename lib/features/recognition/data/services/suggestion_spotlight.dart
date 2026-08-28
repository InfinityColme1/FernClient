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
class SuggestionSpotlight extends ChangeNotifier {
  ({double x, double y, double w, double h})? _box;
  String? _label;
  int? _frameMs;

  /// La sugerencia cuya caja se ha dejado puesta a propósito.
  ///
  /// Fijar manda sobre el ratón: quien ha pulsado una fila quiere ver **esa**
  /// caja mientras decide, y que se la quite el puntero al moverse es justo lo
  /// que hace inservible el enseñar-al-pasar.
  int? _pinned;

  int? get pinnedId => _pinned;

  /// De qué sugerencia es la caja que se está enseñando.
  ///
  /// Hace falta para soltarla cuando su fila desaparece: contestar quita la fila
  /// de la lista, y una fila que ya no está no puede avisar de que el ratón ha
  /// salido de ella.
  int? _showing;

  int? get showingId => _showing;

  /// El rectángulo señalado, normalizado (0..1).
  ({double x, double y, double w, double h})? get box => _box;

  /// Cómo se llama lo que hay dentro.
  String? get label => _label;

  /// De qué fotograma es, en vídeo y GIF.
  int? get frameMs => _frameMs;

  bool get isEmpty => _box == null;

  /// Señala esta detección.
  ///
  /// Una sola cada vez: enseñar todas las cajas a la vez sobre un contenido con
  /// seis sugerencias lo llena de rectángulos que se pisan, y la pregunta que
  /// se está contestando es «dónde ha visto **esto**».
  void show({
    required int id,
    required ({double x, double y, double w, double h}) box,
    required String label,
    int? frameMs,
  }) {
    if (_pinned != null) return;

    _showing = id;
    _set(box: box, label: label, frameMs: frameMs);
  }

  /// Deja puesta la caja de [id], o la quita si ya era la fijada.
  ///
  /// Devuelve si ha quedado fijada, que es lo que la fila necesita saber para
  /// pintarse como elegida.
  bool pin({
    required int id,
    required ({double x, double y, double w, double h}) box,
    required String label,
    int? frameMs,
  }) {
    if (_pinned == id) {
      _pinned = null;
      clear();

      return false;
    }

    _pinned = id;
    _showing = id;
    _set(box: box, label: label, frameMs: frameMs);

    return true;
  }

  void _set({
    required ({double x, double y, double w, double h}) box,
    required String label,
    int? frameMs,
  }) {
    if (_box == box && _label == label) return;

    _box = box;
    _label = label;
    _frameMs = frameMs;
    notifyListeners();
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

  /// Suelta la caja si es de una de [ids].
  ///
  /// Lo llama quien contesta sugerencias: la fila que la enseñaba acaba de irse
  /// de la lista y ya no puede apagarla ella, así que la caja se quedaría
  /// pintada sobre el contenido hasta cambiar de imagen. Con una sola sugerencia
  /// es lo normal, porque contestarla vacía la lista entera.
  ///
  /// Sólo si es de una de ésas: contestar una fila no puede apagar la caja que
  /// el usuario dejó puesta en otra.
  void releaseIf(Iterable<int> ids) {
    final showing = _showing;
    if (showing == null || !ids.contains(showing)) return;

    release();
  }

  /// Deja de señalar.
  ///
  /// Lo fijado sólo lo suelta quien lo fijó: el ratón al salir de una fila no
  /// puede quitar lo que el usuario dejó puesto a propósito.
  void clear() {
    if (_pinned != null) return;

    _showing = null;

    if (_box == null && _label == null) return;

    _box = null;
    _label = null;
    _frameMs = null;
    notifyListeners();
  }
}
