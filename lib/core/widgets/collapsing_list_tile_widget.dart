import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final AnimationController animationController;
  final bool isSelected;
  final VoidCallback ? onTap;
  final double iconSize;

  final TextStyle textStyle;

  final Color selectedColor;
  final Color textSelectedColor;
  final Color unselectedColor;
  final Color textUnselectedColor;

  const CollapsingListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.animationController,
    this.isSelected = false,
    this.onTap,
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
      AppColors.black.withValues(alpha: sidebarHoverOverlayOpacity),
      background,
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
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: <Widget>[
              Icon(
                widget.icon,
                color: AppColors.black,
                size: widget.iconSize,
              ),
              SizedBox(width: sizedBoxAnimation.value),
              (widthAnimation.value >= 190)
                  ? Text(widget.title,
                      style: widget.textStyle.copyWith(
                        color: widget.isSelected
                            ? widget.textSelectedColor
                            : widget.textUnselectedColor
                      ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
