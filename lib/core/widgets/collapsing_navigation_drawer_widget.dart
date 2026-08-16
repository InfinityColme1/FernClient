import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
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
  });

  @override
  State<StatefulWidget> createState() => _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> widthAnimation;

  /// El botón que se ve marcado. Mientras no se pulse nada lo está el primero,
  /// que es la pantalla con la que arranca la aplicación.
  String? _selectedId;

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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            itemCount: content.length,
            itemBuilder: (context, index) => content[index],
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
    final selectedId = _selectedId ?? _defaultSelectedId;

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

      if (_isExpanded) content.add(_sectionTitle(context, section.title));

      if (isEmpty) {
        content.add(_sectionMessage(section.emptyMessage!));
        continue;
      }

      content.addAll(section.items.map((item) => CollapsingListTile(
            onTap: () {
              setState(() => _selectedId = item.id);
              item.onTap.call();
            },
            isSelected: selectedId == item.id,
            isExpanded: _isExpanded,
            title: item.title,
            icon: item.icon,
            avatarPath: item.avatarPath,
            depth: item.depth,
            animationController: _animationController,
            textStyle: widget.textStyle,
            selectedColor: widget.selectedColor,
            textSelectedColor: widget.textSelectedColor,
            unselectedColor: widget.unselectedColor,
            textUnselectedColor: widget.textUnselectedColor,
            iconSize: widget.iconSize,
          )));
    }

    return content;
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
