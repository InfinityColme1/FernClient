import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'collapsing_list_tile_widget.dart';


/// Menú lateral desplegable: sus botones repartidos en secciones, y abajo el
/// botón que lo encoge hasta dejar sólo los iconos.
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

  /// Con qué estado lo quiere quien lo monta. Es una petición, no una orden
  /// permanente: cambiarla pliega o despliega el menú, pero después el botón
  /// del propio menú sigue mandando hasta que vuelva a cambiar.
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

  /// Si el menú está encogido. Empieza como lo pida quien lo monta y luego lo
  /// cambian su botón o los cambios de esa petición.
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: drawerAnimationDuration);
    widthAnimation = Tween<double>(begin: widget.maxWidth, end: widget.minWidth)
        .animate(_animationController);

    // De arranque no se anima: el menú ya aparece como toca.
    _isCollapsed = widget.isCollapsed;
    if (_isCollapsed) _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(CollapsingNavigationDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sólo al cruzar el umbral: si se comparara con el estado actual, plegarlo
    // a mano en una ventana ancha se desharía en la reconstrucción siguiente.
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      _setCollapsed(widget.isCollapsed);
    }
  }

  void _setCollapsed(bool isCollapsed) {
    setState(() => _isCollapsed = isCollapsed);
    isCollapsed
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
        child: Column(
          children: <Widget>[
            Expanded(
              child: Builder(builder: (context) {
                // Los botones se arman todos, pero sólo se pintan los que se
                // ven: las etiquetas pueden ser muchas.
                final content = _sectionsContent(context);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  itemCount: content.length,
                  itemBuilder: (context, index) => content[index],
                );
              }),
            ),
            InkWell(
              onTap: () => _setCollapsed(!_isCollapsed),
              child: AnimatedIcon(
                icon: AnimatedIcons.close_menu,
                progress: _animationController,
                color: widget.selectedColor,
                size: widget.iconSize,
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
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
