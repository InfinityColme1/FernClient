import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_icons.dart';
import 'package:Fern/core/ui/menus/fern_popup_panel.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Desplegable compacto sobre fondo de color, del mismo alto que
/// [FernPillButton], para las cabeceras de las pantallas.
///
/// **Por qué no es un `DropdownButton`.** Lo era, y por eso se veía distinto de
/// todo lo demás que se despliega en la aplicación: Material pinta su menú con
/// sus propios colores, su propia elevación y su propia barra de desplazamiento,
/// y ninguna de las tres sale de la paleta. Al lado del menú de crear —que sí es
/// nuestro— parecían dos aplicaciones.
///
/// Ahora es el mismo panel que aquél ([FernPopupPanel]): mismo color de
/// superficie levantada, mismo trazo fino, mismo radio. Lo único que añade es la
/// marca de cuál está puesta, que un menú de acciones no necesita y un
/// desplegable sí.
///
/// Las opciones que no caben en [maxVisibleItems] no se quedan fuera: el panel se
/// queda de ese alto y se desplaza, con la barra por dentro.
class FernDropdownPill<T> extends StatefulWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T value)? labelBuilder;

  /// Sin decir nada, el fondo suave de la paleta que esté puesta.
  final Color? backgroundColor;
  final double height;

  /// Cuántas opciones se ven a la vez antes de que haya que desplazarse.
  final int maxVisibleItems;

  /// Ancho del panel que se abre. El de la píldora lo decide su contenido.
  final double menuWidth;

  const FernDropdownPill({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.labelBuilder,
    this.backgroundColor,
    this.height = AppSizes.buttonHeightSmall,
    this.maxVisibleItems = dropdownMaxVisibleItems,
    this.menuWidth = AppSizes.menuWidth,
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
    final background = widget.backgroundColor ?? context.colors.secondary;
    if (!_isHovered || !_isEnabled) return background;

    return Color.alphaBlend(
      context.colors.black.withValues(alpha: sidebarHoverOverlayOpacity),
      background,
    );
  }

  /// Lo alto que puede ponerse el panel: [maxVisibleItems] filas enteras.
  ///
  /// Sale de la cuenta y no de un número a ojo, así que la última opción que se
  /// ve queda entera y no cortada por la mitad, que es lo que dice «esto sigue».
  double get _menuMaxHeight =>
      widget.maxVisibleItems * AppSizes.buttonHeight + dropdownMenuPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FernPopupPanel(
      width: widget.menuWidth,
      maxHeight: widget.items.length > widget.maxVisibleItems
          ? _menuMaxHeight
          : null,
      children: [
        for (final item in widget.items)
          _Option(
            label: _label(item),
            isSelected: item == widget.value,
            onPressed: () => widget.onChanged?.call(item),
          ),
      ],
      builder: (context, toggle) => MouseRegion(
        cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _isEnabled ? toggle : null,
          child: AnimatedContainer(
            duration: hoverAnimationDuration,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _label(widget.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isEnabled
                          ? context.colors.black
                          : context.colors.unremarked,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Symbols.keyboard_arrow_down,
                  size: AppSizes.iconCompact,
                  color: _isEnabled
                      ? context.colors.black
                      : context.colors.unremarked,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Una opción del panel.
///
/// Es un [MenuItemButton] como los del menú de crear —así el panel se cierra
/// solo al elegir— con la marca de cuál está puesta a la derecha. La marca va
/// ahí y no delante para que los rótulos empiecen todos en la misma vertical:
/// con el hueco por delante sólo en la elegida, la lista se lee torcida.
class _Option extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _Option({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuItemButton(
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(0, AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      // Del mismo color que el texto de la opción, y dicho a mano.
      //
      // Iba con el primario, que en el tema oscuro es un morado profundo y sobre
      // la superficie del panel casi no se ve — justo en lo único que dice cuál
      // está puesta. Y dejarlo heredar tampoco vale: `MenuItemButton` pinta sus
      // iconos con un color propio, más apagado que el del texto que llevan al
      // lado.
      trailingIcon: isSelected
          ? Icon(
              AppIcons.check,
              size: AppSizes.iconCompact,
              color: context.colors.black,
            )
          : null,
      onPressed: onPressed,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}
