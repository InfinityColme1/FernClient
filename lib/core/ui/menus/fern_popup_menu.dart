import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/menus/fern_popup_panel.dart';
import 'package:flutter/material.dart';

/// Una opción del desplegable: icono, etiqueta y el valor que se devuelve al
/// elegirla.
class FernMenuOption<T> {
  final T value;
  final String label;
  final IconData icon;

  /// Icono en forma de imagen del paquete, para lo que no tiene glifo propio.
  /// Manda sobre [icon] cuando viene.

  const FernMenuOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Desplegable pequeño anclado a un botón, para elegir entre unas pocas
/// acciones.
///
/// Es un [FernPopupPanel] con las filas ya hechas, así que se coloca igual: cae
/// por debajo del disparador y sólo se corre hacia dentro lo justo para no
/// pegarse al borde de la ventana.
///
/// [builder] recibe una función que abre y cierra el menú, así que el disparador
/// puede ser cualquier widget:
///
/// ```dart
/// FernPopupMenu<CreateOption>(
///   options: const [
///     FernMenuOption(value: CreateOption.tag, label: "Tag", icon: Symbols.label),
///   ],
///   onSelected: _create,
///   builder: (context, toggle) =>
///       IconButton(onPressed: toggle, icon: const Icon(Symbols.add)),
/// );
/// ```
class FernPopupMenu<T> extends StatelessWidget {
  final List<FernMenuOption<T>> options;
  final ValueChanged<T> onSelected;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  /// Ancho del panel.
  final double width;

  /// Separación entre el disparador y el panel.
  final double gap;

  /// Hueco que se le deja al borde de la ventana.
  final double windowMargin;

  const FernPopupMenu({
    super.key,
    required this.options,
    required this.onSelected,
    required this.builder,
    this.width = AppSizes.menuWidth,
    this.gap = AppSpacing.s,
    this.windowMargin = AppSpacing.xxl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FernPopupPanel(
      width: width,
      gap: gap,
      windowMargin: windowMargin,
      builder: builder,
      // El menú se cierra solo al pulsar una opción, así que basta con avisar de
      // lo elegido.
      children: options
          .map((option) => MenuItemButton(
                style: MenuItemButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                ),
                leadingIcon: Icon(option.icon, size: AppSizes.iconLarge),
                onPressed: () => onSelected(option.value),
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium,
                ),
              ))
          .toList(),
    );
  }
}
