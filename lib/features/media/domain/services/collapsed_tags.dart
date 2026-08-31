import 'package:Fern/core/services/preferences_service.dart';
import 'package:flutter/foundation.dart';

/// Qué ramas de etiquetas están plegadas.
///
/// El menú lateral y la lista de la pantalla de gestión enseñaban **todas** las
/// etiquetas, madres e hijas, siempre. Con un árbol de cierto tamaño eso es una
/// lista larguísima, y estorba justo donde más se usa: arrastrar contenido hasta
/// una etiqueta obliga a arrastrar y desplazar a la vez.
///
/// **Se guardan las plegadas, no las desplegadas.** El conjunto vacío significa
/// «todo abierto», que es exactamente lo de antes: sin nada guardado el árbol
/// sale entero, así que esto no esconde nada que no se haya pedido esconder.
///
/// Es un [ChangeNotifier] porque lo miran dos pantallas a la vez: plegar una
/// rama desde el menú tiene que verse en la lista de gestión sin salir y volver.
class CollapsedTags extends ChangeNotifier {
  final PreferencesService _preferences;

  late Set<int> _collapsed = _preferences.collapsedTagIds();

  CollapsedTags({required PreferencesService preferences})
      : _preferences = preferences;

  Set<int> get ids => _collapsed;

  bool isCollapsed(int tagId) => _collapsed.contains(tagId);

  Future<void> toggle(int tagId) =>
      isCollapsed(tagId) ? expand(tagId) : collapse(tagId);

  Future<void> collapse(int tagId) async {
    if (!_collapsed.add(tagId)) return;

    _collapsed = {..._collapsed};
    notifyListeners();

    await _preferences.setCollapsedTagIds(_collapsed);
  }

  /// Abre esta rama.
  ///
  /// Lo llama también quien acaba de crear una etiqueta o de elegirla: una
  /// etiqueta que aparece dentro de una rama cerrada no se ve, y parecería que
  /// no se ha creado.
  Future<void> expand(int tagId) async {
    if (!_collapsed.remove(tagId)) return;

    _collapsed = {..._collapsed};
    notifyListeners();

    await _preferences.setCollapsedTagIds(_collapsed);
  }

  /// Abre la rama sin guardarlo, mientras se arrastra algo por encima.
  ///
  /// Es una ayuda del gesto, no una decisión: al soltar, la rama vuelve a como
  /// estaba. Guardarlo dejaría el árbol abierto por haberlo cruzado con el ratón.
  void expandWhileDragging(int tagId) {
    if (!_collapsed.contains(tagId)) return;

    _openedByDrag.add(tagId);
    _collapsed = {..._collapsed}..remove(tagId);
    notifyListeners();
  }

  final Set<int> _openedByDrag = {};

  /// Vuelve a cerrar lo que sólo abrió el arrastre. Se llama al soltar.
  void releaseDragged() {
    if (_openedByDrag.isEmpty) return;

    _collapsed = {..._collapsed, ..._openedByDrag};
    _openedByDrag.clear();
    notifyListeners();
  }

  /// Se olvida de todo. Lo usa el vaciado de la base: sin esto quedarían
  /// plegadas etiquetas que ya no existen.
  Future<void> clear() async {
    if (_collapsed.isEmpty) return;

    _collapsed = const {};
    _openedByDrag.clear();
    notifyListeners();

    await _preferences.setCollapsedTagIds(const {});
  }
}
