import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Una opción del desplegable: icono, etiqueta y el valor que se devuelve al
/// elegirla.
class FernMenuOption<T> {
  final T value;
  final String label;
  final IconData icon;

  const FernMenuOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Desplegable pequeño anclado a un botón, para elegir entre unas pocas
/// acciones.
///
/// El panel cuelga justo por debajo del disparador, alineado con su borde
/// izquierdo, y sólo se corre hacia la izquierda lo justo para no pegarse al
/// borde de la ventana ([windowMargin]). Así un botón del extremo derecho de la
/// barra superior abre el menú hacia dentro sin separarse de él más de lo
/// necesario.
///
/// [builder] recibe una función que abre y cierra el menú, así que el disparador
/// puede ser cualquier widget:
///
/// ```dart
/// FernPopupMenu<CreateOption>(
///   options: const [
///     FernMenuOption(value: CreateOption.tag, label: "Tag", icon: Icons.label_outline),
///   ],
///   onSelected: _create,
///   builder: (context, toggle) =>
///       IconButton(onPressed: toggle, icon: const Icon(Icons.add)),
/// );
/// ```
class FernPopupMenu<T> extends StatefulWidget {
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
  State<FernPopupMenu<T>> createState() => _FernPopupMenuState<T>();
}

class _FernPopupMenuState<T> extends State<FernPopupMenu<T>> {
  final MenuController _controller = MenuController();
  final GlobalKey _anchorKey = GlobalKey();

  /// Desplazamiento respecto a la esquina inferior izquierda del disparador. Se
  /// recalcula al abrir, cuando ya se sabe dónde ha quedado el botón.
  Offset _offset = Offset.zero;

  /// Cuánto hay que correr el panel hacia la izquierda para que su borde derecho
  /// no rebase el margen de la ventana. Cero mientras quepa tal cual.
  double get _horizontalShift {
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return 0;

    final anchorLeft = renderObject.localToGlobal(Offset.zero).dx;
    final maxLeft =
        MediaQuery.sizeOf(context).width - widget.windowMargin - widget.width;

    return math.min<double>(0, maxLeft - anchorLeft);
  }

  void _toggle() {
    if (_controller.isOpen) {
      _controller.close();
      return;
    }

    // El desplazamiento se mide con el botón ya en su sitio, y el panel se abre
    // en el fotograma siguiente para que salga con la posición nueva y no con la
    // del cálculo anterior.
    setState(() => _offset = Offset(_horizontalShift, widget.gap));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.open();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: _offset,
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.white),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: AppSpacing.l),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          ),
        ),
      ),
      // El menú se cierra solo al pulsar una opción, así que basta con avisar
      // de lo elegido. El ancho lo fija cada fila: el panel se ajusta a ellas.
      menuChildren: widget.options
          .map((option) => SizedBox(
                width: widget.width,
                child: MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.buttonHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                  ),
                  leadingIcon: Icon(option.icon, size: AppSizes.iconLarge),
                  onPressed: () => widget.onSelected(option.value),
                  child: Text(
                    option.label,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ))
          .toList(),
      builder: (context, controller, _) => KeyedSubtree(
        key: _anchorKey,
        child: widget.builder(context, _toggle),
      ),
    );
  }
}
