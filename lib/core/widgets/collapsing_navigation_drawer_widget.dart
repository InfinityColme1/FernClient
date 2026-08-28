import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/core/navigation/sidebar_selection.dart';
import 'package:Fern/core/ui/interaction/fern_drag_watch.dart';
import 'package:Fern/core/ui/interaction/fern_drop_absorb.dart';
import 'package:flutter/material.dart';
import 'collapsing_list_tile_widget.dart';


/// Menú lateral desplegable: sus botones repartidos en secciones.
///
/// Encogerlo hasta dejar sólo los iconos no se pide desde aquí: el botón que lo
/// hace está en la cabecera, junto al logo, y llega como [isCollapsed].
///
/// Las secciones se separan con una línea horizontal y llevan su rótulo encima.
/// Todo el contenido va en un desplazable: las etiquetas pueden ser muchas y
/// desbordar el alto de la pantalla.
class CollapsingNavigationDrawer extends StatefulWidget {

  final List<SidebarSection> sections;
  final double maxWidth;
  final double minWidth;
  final TextStyle textStyle;
  final double iconSize;

  final Color backgroundColor;
  final Color selectedColor;
  final Color textSelectedColor;
  final Color unselectedColor;
  final Color textUnselectedColor;

  /// Si va plegado. Lo dice quien lo monta, que es quien tiene el botón de la
  /// cabecera y quien lo pliega solo al estrecharse la ventana.
  final bool isCollapsed;

  /// En qué pantalla se está.
  ///
  /// Es lo que decide qué botón se ve marcado. Llega por parámetro y no se
  /// pregunta aquí al enrutador para que el menú se pueda montar y comprobar sin
  /// uno: lo que tiene que hacer con la dirección no depende de quién se la dé.
  final String currentLocation;

  const CollapsingNavigationDrawer({
    super.key,
    required this.sections,
    this.maxWidth = 210,
    this.minWidth = 70,
    required this.textStyle,
    required this.iconSize,

    required this.backgroundColor,
    required this.selectedColor,
    required this.textSelectedColor,
    required this.unselectedColor,
    required this.textUnselectedColor,

    this.isCollapsed = false,
    this.currentLocation = '',
  });

  @override
  State<StatefulWidget> createState() => _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> widthAnimation;

  /// El último botón que se pulsó, y la pantalla en la que se estaba al
  /// pulsarlo.
  ///
  /// Hace falta por las etiquetas: filtrar por una no cambia de pantalla, así
  /// que la dirección no puede contarlo. Para todo lo demás manda la dirección.
  String? _tappedId;
  String? _tappedLocation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: drawerAnimationDuration);
    widthAnimation = Tween<double>(begin: widget.maxWidth, end: widget.minWidth)
        .animate(_animationController);

    // De arranque no se anima: el menú ya aparece como toca.
    if (widget.isCollapsed) _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(CollapsingNavigationDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sólo cuando cambia lo que se pide: una reconstrucción con lo mismo no
    // reinicia la animación a medio camino.
    if (widget.isCollapsed == oldWidget.isCollapsed) return;

    widget.isCollapsed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  /// Si el menú está lo bastante abierto para que quepan los textos. Se mira
  /// aquí y se reparte a los botones para que rótulos, títulos y sangrías
  /// aparezcan y desaparezcan a la vez.
  bool get _isExpanded => widthAnimation.value >= widget.maxWidth - 20;

  String? get _defaultSelectedId {
    for (final section in widget.sections) {
      if (section.items.isNotEmpty) return section.items.first.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, w) => getWidget(context, w, widget),
    );
  }

  Widget getWidget(BuildContext context, w, drawer) {
    return Material(
      elevation: 0.0,
      child: Container(
        width: widthAnimation.value,
        color: widget.backgroundColor,
        child: Builder(builder: (context) {
          // Los botones se arman todos, pero sólo se pintan los que se ven:
          // las etiquetas pueden ser muchas.
          final content = _sectionsContent(context);

          // **El menú es el único sitio sin carril para la barra, y va pegada
          // al canto.**
          //
          // En cualquier otra lista el contenido se aparta y la barra corre por
          // el hueco. Aquí no cabe: la fila es un rótulo que ya viene justo —los
          // nombres largos se cortan con puntos suspensivos en cuanto se les
          // quita ancho— y plegado el menú la fila es un icono del ancho del
          // menú entero, así que no hay nada que quitarle. Entre una barra que
          // pasa por encima del borde de la fila y un menú que corta «Gestor de
          // creadores», pasa la barra.
          return ScrollbarTheme(
            data: ScrollbarTheme.of(context).copyWith(crossAxisMargin: 0),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              itemCount: content.length,
              itemBuilder: (context, index) => content[index],
            ),
          );
        }),
      ),
    );
  }

  /// Las secciones una detrás de otra, con su separador en medio.
  ///
  /// Una sección sin botones sólo ocupa sitio si tiene algo que decir (y hay
  /// ancho para leerlo); si no, desaparece con su separador.
  List<Widget> _sectionsContent(BuildContext context) {
    final selectedId = sidebarSelectedId(
          location: widget.currentLocation,
          ids: [
            for (final section in widget.sections)
              for (final item in section.items) item.id,
          ],
          tapped: _tappedId,
          tappedLocation: _tappedLocation,
        ) ??
        _defaultSelectedId;

    final content = <Widget>[];
    for (final section in widget.sections) {
      final isEmpty = section.items.isEmpty;
      if (isEmpty && (section.emptyMessage == null || !_isExpanded)) continue;

      if (content.isNotEmpty) {
        content.add(const Divider(
          indent: AppSpacing.l,
          endIndent: AppSpacing.l,
        ));
      }

      if (_isExpanded) {
        final title = _sectionTitle(context, section.title);
        final anchorId = section.anchorId;

        content.add(anchorId == null
            ? title
            : TutorialAnchor(id: anchorId, child: title));
      }

      if (isEmpty) {
        content.add(_sectionMessage(section.emptyMessage!));
        continue;
      }

      // Cada fila se apunta con su propio identificador, que es la pantalla a la
      // que lleva: así el tutorial puede señalar cualquiera de ellas sin que
      // haya que preparar aquí nada por cada paso que se añada.
      content.addAll(section.items.map((item) => TutorialAnchor(
            id: item.id,
            child: _dropTarget(
            item,
            CollapsingListTile(
            onTap: () {
              // La pantalla de **antes** de navegar: mientras se siga en ella,
              // lo pulsado manda; en cuanto se cambie, manda la dirección.
              setState(() {
                _tappedId = item.id;
                _tappedLocation = widget.currentLocation;
              });
              item.onTap.call();
            },
            isSelected: selectedId == item.id,
            isExpanded: _isExpanded,
            title: item.title,
            icon: item.icon,
            isNsfw: item.isNsfw,
            avatarPath: item.avatarPath,
            depth: item.depth,
            badgeCount: item.badgeCount,
            animationController: _animationController,
            textStyle: widget.textStyle,
            selectedColor: widget.selectedColor,
            textSelectedColor: widget.textSelectedColor,
            unselectedColor: widget.unselectedColor,
            textUnselectedColor: widget.textUnselectedColor,
            iconSize: widget.iconSize,
          ),
          ),
          )));
    }

    return content;
  }

  /// La fila, envuelta en un destino de arrastre si acepta contenido.
  ///
  /// Sin destino se devuelve tal cual: montar un `DragTarget` por cada fila del
  /// menú sería pagar por nada en las que no significan algo que se le pueda
  /// poner a un contenido.
  Widget _dropTarget(SidebarItem item, Widget tile) {
    final onDropped = item.onMediaDropped;
    if (onDropped == null) return tile;

    // El contexto **de esta fila**, que es lo que dice dónde tiene que aterrizar
    // lo que se suelta. El del método es el del menú entero, y con él la
    // miniatura viajaba al centro del menú en vez de a la etiqueta.
    BuildContext? fila;

    return DragTarget<List<int>>(
      onWillAcceptWithDetails: (details) {
        final acepta = details.data.isNotEmpty;
        // Estas filas no van por `FernDropSlot` —montar uno por cada fila del
        // menú sería pagar por nada en las que no aceptan contenido—, así que el
        // aviso a la miniatura hay que darlo aquí. Sin esto, encoger y
        // oscurecerse al llegar a una etiqueta no ocurría **justo en las
        // etiquetas**, que es donde se suelta.
        if (acepta) fernDragIsOverTarget.value = true;

        return acepta;
      },
      onLeave: (_) => fernDragIsOverTarget.value = false,
      onAcceptWithDetails: (details) {
        fernDragIsOverTarget.value = false;
        // Se ve entrar dentro de la fila. Es la confirmación de que ha ido a
        // donde se quería, y llega antes que cualquier aviso escrito.
        if (fila case final destino? when destino.mounted) {
          playFernDropAbsorb(context: destino, pointer: details.offset);
        }
        onDropped(details.data);
      },
      builder: (context, candidate, _) {
        fila = context;

        return DecoratedBox(
        // Encendida sólo mientras algo está encima: es lo que dice dónde se va
        // a soltar, que con veinte etiquetas en fila no se adivina.
        decoration: BoxDecoration(
          color: candidate.isEmpty
              ? Colors.transparent
              : widget.selectedColor.withValues(alpha: dropTargetHighlight),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
          child: tile,
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.s,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: widget.textUnselectedColor),
      ),
    );
  }

  Widget _sectionMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        message,
        style: widget.textStyle.copyWith(color: widget.textUnselectedColor),
      ),
    );
  }
}
