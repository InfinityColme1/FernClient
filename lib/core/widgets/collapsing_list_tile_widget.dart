import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;

  /// Imagen con la que se pinta el botón en lugar del icono. Es lo que deja
  /// reconocer una etiqueta con el menú plegado, cuando el icono es el único que
  /// se ve y es igual para todas.
  final String? avatarPath;

  final AnimationController animationController;
  final bool isSelected;

  /// Si el menú está abierto del todo. Lo decide el menú, no el botón, para que
  /// todo lo que sólo cabe estando abierto (el título y la sangría) aparezca a
  /// la vez.
  final bool isExpanded;

  final VoidCallback ? onTap;
  final double iconSize;

  /// Nivel del botón en la jerarquía de etiquetas: cuanto más honda, más
  /// adentro empieza.
  final int depth;

  final TextStyle textStyle;

  final Color selectedColor;
  final Color textSelectedColor;
  final Color unselectedColor;
  final Color textUnselectedColor;

  const CollapsingListTile({
    super.key,
    required this.title,
    required this.icon,
    this.avatarPath,
    required this.animationController,
    this.isSelected = false,
    this.isExpanded = true,
    this.onTap,
    this.depth = 0,
    required this.iconSize,
    required this.textStyle,
    required this.selectedColor,
    required this.textSelectedColor,
    required this.unselectedColor,
    required this.textUnselectedColor
  });

  @override
  State<StatefulWidget> createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  late Animation<double> widthAnimation, sizedBoxAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    widthAnimation =
        Tween<double>(begin: 200, end: 70).animate(widget.animationController);
    sizedBoxAnimation =
        Tween<double>(begin: 10, end: 0).animate(widget.animationController);
  }

  /// Fondo del botón: el del elemento seleccionado y, mientras el ratón está
  /// encima, un velo oscuro por encima.
  ///
  /// El velo va aquí y no en el `hoverColor` del `InkWell` porque la tinta se
  /// pinta por debajo del `Container`, que es quien lleva el fondo.
  Color _backgroundColor(BuildContext context) {
    final background = widget.isSelected
        ? Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: sidebarSelectedOpacity)
        : Colors.transparent;

    if (!_isHovered) return background;

    return Color.alphaBlend(
      context.colors.black.withValues(alpha: sidebarHoverOverlayOpacity),
      background,
    );
  }

  /// Cuánto entra el botón por colgar de otro. Deja de crecer en
  /// [sidebarMaxIndentDepth]: más adentro no quedaría sitio para el título.
  double get _indent {
    if (!widget.isExpanded) return 0;

    return sidebarDepthIndent *
        math.min(widget.depth, sidebarMaxIndentDepth);
  }

  /// Lo que queda por debajo del último nivel con sangría se marca con una
  /// flecha: la jerarquía se sigue viendo aunque el botón ya no entre más.
  bool get _showsDepthMark =>
      widget.isExpanded && widget.depth > sidebarMaxIndentDepth;

  /// La imagen del botón, o su icono si no tiene ninguna.
  ///
  /// El avatar ocupa lo mismo que el icono al que sustituye: los botones con
  /// imagen y sin ella se alinean igual y la lista no se descuadra.
  Widget _leading() {
    final avatarPath = widget.avatarPath;

    if (avatarPath == null) {
      return Icon(widget.icon, color: context.colors.black, size: widget.iconSize);
    }

    return FernAvatar(
      imagePath: avatarPath,
      fallbackIcon: widget.icon,
      radius: widget.iconSize / 2,
      iconSize: widget.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        mouseCursor: WidgetStateMouseCursor.clickable,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            color: _backgroundColor(context),
          ),
          width: widthAnimation.value,
          margin: EdgeInsets.only(left: 8.0 + _indent, right: 8.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: <Widget>[
              if (_showsDepthMark) ...[
                Icon(
                  Icons.subdirectory_arrow_right,
                  color: context.colors.unremarked,
                  size: AppSizes.iconSmall,
                ),
                SizedBox(width: sizedBoxAnimation.value),
              ],
              _leading(),
              SizedBox(width: sizedBoxAnimation.value),
              if (widget.isExpanded)
                Expanded(
                  child: Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.textStyle.copyWith(
                        color: widget.isSelected
                            ? widget.textSelectedColor
                            : widget.textUnselectedColor
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
