import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Desplegable compacto sobre fondo de color, del mismo alto que
/// [FernPillButton], para las cabeceras de las pantallas.
///
/// Las opciones que no caben en [maxVisibleItems] no se quedan fuera: el
/// desplegable se queda de ese alto y se desplaza. Es lo que permite que una
/// lista siga creciendo (las fuentes de las que se importa, sin ir más lejos)
/// sin comerse la pantalla de arriba abajo.
class FernDropdownPill<T> extends StatefulWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T value)? labelBuilder;
  final Color backgroundColor;
  final double height;

  /// Cuántas opciones se ven a la vez antes de que haya que desplazarse.
  final int maxVisibleItems;

  const FernDropdownPill({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.labelBuilder,
    this.backgroundColor = AppColors.secondary,
    this.height = AppSizes.buttonHeightSmall,
    this.maxVisibleItems = dropdownMaxVisibleItems,
  });

  @override
  State<FernDropdownPill<T>> createState() => _FernDropdownPillState<T>();
}

class _FernDropdownPillState<T> extends State<FernDropdownPill<T>> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onChanged != null;

  String _label(T item) => widget.labelBuilder?.call(item) ?? item.toString();

  /// El velo oscuro del ratón encima, el mismo que llevan los botones del menú
  /// lateral: la píldora se abre al pulsarla y tiene que decirlo.
  Color get _background {
    if (!_isHovered || !_isEnabled) return widget.backgroundColor;

    return Color.alphaBlend(
      AppColors.black.withValues(alpha: sidebarHoverOverlayOpacity),
      widget.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // El cursor y el velo se marcan en toda la píldora, no sólo sobre el texto
    // del desplegable, que es la zona que cubre el [DropdownButton].
    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: hoverAnimationDuration,
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            // El desplegable trae de fábrica un cursor que fuera de la web es
            // el normal, y como va por encima de la píldora se lleva por
            // delante el que ella pone. Se le dice el que toca a él también.
            mouseCursor: WidgetStateMouseCursor.clickable,
            icon:
                const Icon(Icons.keyboard_arrow_down, size: AppSizes.iconCompact),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            onChanged: widget.onChanged,
            // Alto fijo por opción para que el tope de altura del desplegable
            // sea justo el de [maxVisibleItems] y no una aproximación.
            itemHeight: kMinInteractiveDimension,
            menuMaxHeight: widget.maxVisibleItems * kMinInteractiveDimension +
                dropdownMenuPadding,
            items: widget.items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(_label(item)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
