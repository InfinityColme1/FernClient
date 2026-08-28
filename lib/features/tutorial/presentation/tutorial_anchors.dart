import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:flutter/material.dart';

/// Los sitios a los que el tutorial puede señalar.
///
/// Los pasos del tutorial no saben nada de widgets: nombran uno de éstos y el
/// velo pregunta dónde está. Así ningún componente tiene que recibir nada desde
/// arriba para poder ser señalado, y añadir un paso nuevo no obliga a pasar una
/// clave por media aplicación.
abstract final class TutorialAnchorId {
  /// El botón que pliega y despliega el menú lateral.
  static const sidebarToggle = 'sidebar-toggle';

  /// El menú lateral entero.
  static const sidebar = 'sidebar';

  // Las filas del menú no están aquí: cada una se apunta sola con su propio
  // identificador, que es la ruta a la que lleva (`importRoute`, `mediaRoute`…).
  // Así añadir un paso que señale a una fila no obliga a tocar nada de esto.

  /// La sección de etiquetas del menú, que es además donde se sueltan.
  static const sidebarTags = 'sidebar-tags';

  /// El buscador de la barra de arriba.
  static const search = 'search';

  /// El «+» de la barra de arriba.
  static const create = 'create';

  /// El botón de ajustes.
  static const settings = 'settings';

  /// Lo que ocupa la pantalla, sea la rejilla de contenido o lo que la
  /// sustituya mientras no hay nada.
  static const content = 'content';

  // Las cuatro piezas de las que está hecha **la pantalla que se esté viendo**,
  // sea cual sea.
  //
  // Las pone el armazón de las pantallas y no cada página, así que un paso que
  // diga «la cabecera» señala a la cabecera de donde se esté. Vale porque sólo
  // hay una pantalla montada a la vez: es lo que permite que cinco recorridos
  // distintos se apoyen en las mismas cuatro anclas.

  /// La fila de arriba: cuentas, filtros y botones de la pantalla.
  static const screenHeader = 'screen-header';

  /// Lo que ocupa el resto: la rejilla, o la lista de grupos, o el lienzo.
  static const screenBody = 'screen-body';

  /// La ficha editable de las pantallas de gestión.
  static const screenCard = 'screen-card';

  /// La lista de la derecha de las pantallas de gestión.
  static const screenList = 'screen-list';
}

/// Dónde está cada cosa señalable, mientras está montada.
///
/// Se guarda el `BuildContext` de cada una y no un `GlobalKey`: una clave global
/// repetida —y el menú lateral se monta en dos maquetaciones distintas— tira
/// abajo la construcción entera. Aquí lo peor que puede pasar es que gane el
/// último que se haya montado, que es justamente el que se está viendo.
abstract final class TutorialAnchors {
  static final _anchors = <String, BuildContext>{};

  static void register(String id, BuildContext context) {
    _anchors[id] = context;
  }

  /// Sólo se borra si el que se va es el que estaba apuntado: al cambiar de
  /// maquetación el nuevo se apunta antes de que el viejo se desmonte, y sin
  /// esta comprobación el viejo se llevaría por delante al que acaba de entrar.
  static void unregister(String id, BuildContext context) {
    if (_anchors[id] == context) _anchors.remove(id);
  }

  /// Qué trozo de pantalla ocupa, en coordenadas de la ventana.
  ///
  /// `null` si no está montado —una fila del menú con el menú plegado, por
  /// ejemplo— o si todavía no se ha medido. El velo lo entiende como «ese paso
  /// no señala a nada» y lo enseña en medio de la pantalla, que es preferible a
  /// señalar a un sitio equivocado.
  static Rect? rectOf(String id) {
    final context = _anchors[id];
    if (context == null || !context.mounted) return null;

    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;

    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Si lo que hay ahí ha **terminado de colocarse**.
  ///
  /// Una pantalla entra con su animación —el panel de la derecha de los gestores
  /// llega deslizándose desde fuera—, y medir mientras tanto da el sitio por el
  /// que va pasando, no donde acaba.
  ///
  /// No se adivina mirando si el sitio deja de cambiar: cuando el tutorial acaba
  /// de pedir la pantalla, la animación todavía no ha empezado, así que dos
  /// fotogramas seguidos dan lo mismo y parecería que ya está. Se pregunta a la
  /// propia animación de la pantalla, que es quien lo sabe.
  ///
  /// Lo que no vive dentro de una pantalla que se anime —el menú lateral, la
  /// barra de arriba— está colocado siempre.
  static bool isSettled(String id) {
    final context = _anchors[id];
    if (context == null || !context.mounted) return false;

    // Sin crear dependencia: esto se pregunta desde fuera de una construcción.
    final scope =
        context.getInheritedWidgetOfExactType<ScreenTransitionScope>();
    if (scope == null) return true;

    // Entrando del todo y sin nadie tapándola: cualquier otra cosa es una
    // pantalla a medio camino.
    return scope.entering.status == AnimationStatus.completed &&
        scope.leaving.status == AnimationStatus.dismissed;
  }

  @visibleForTesting
  static void reset() => _anchors.clear();
}

/// Marca a lo que envuelve como algo a lo que el tutorial puede señalar.
///
/// No pinta nada ni cambia la maquetación: sólo se apunta mientras está en
/// pantalla.
class TutorialAnchor extends StatefulWidget {
  final String id;
  final Widget child;

  const TutorialAnchor({super.key, required this.id, required this.child});

  @override
  State<TutorialAnchor> createState() => _TutorialAnchorState();
}

class _TutorialAnchorState extends State<TutorialAnchor> {
  @override
  void initState() {
    super.initState();
    TutorialAnchors.register(widget.id, context);
  }

  @override
  void didUpdateWidget(TutorialAnchor old) {
    super.didUpdateWidget(old);
    if (old.id == widget.id) return;

    TutorialAnchors.unregister(old.id, context);
    TutorialAnchors.register(widget.id, context);
  }

  @override
  void dispose() {
    TutorialAnchors.unregister(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
