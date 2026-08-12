import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Panel blanco redondeado anclado a un botón: el armazón de todo lo que cuelga
/// de la cabecera de una pantalla.
///
/// El panel cae justo por debajo del disparador, alineado con su borde
/// izquierdo, y sólo se corre hacia la izquierda lo justo para no pegarse al
/// borde de la ventana ([windowMargin]). Así un botón del extremo derecho de una
/// cabecera abre el panel hacia dentro sin separarse de él más de lo necesario.
///
/// [builder] recibe una función que abre y cierra el panel, así que el
/// disparador puede ser cualquier widget. Los [children] no se cierran solos: lo
/// hacen los que sean un [MenuItemButton] (una acción se elige y se acaba), no
/// los controles que se dejan tocar varias veces sin salir.
///
/// Para un desplegable de acciones no hace falta armarlo a mano: [FernPopupMenu]
/// es este mismo panel con sus filas ya hechas.
class FernPopupPanel extends StatefulWidget {
  final List<Widget> children;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  /// Ancho del panel.
  final double width;

  /// Separación entre el disparador y el panel.
  final double gap;

  /// Hueco que se le deja al borde de la ventana.
  final double windowMargin;

  /// Relleno de los bordes del panel, por dentro.
  final EdgeInsetsGeometry padding;

  const FernPopupPanel({
    super.key,
    required this.children,
    required this.builder,
    this.width = AppSizes.menuWidth,
    this.gap = AppSpacing.s,
    this.windowMargin = AppSpacing.xxl,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.l),
  });

  @override
  State<FernPopupPanel> createState() => _FernPopupPanelState();
}

class _FernPopupPanelState extends State<FernPopupPanel> {
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
    return MenuAnchor(
      controller: _controller,
      alignmentOffset: _offset,
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.white),
        padding: WidgetStatePropertyAll(widget.padding),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          ),
        ),
      ),
      // El ancho lo fija el panel, no su contenido: las filas se ajustan a él.
      menuChildren: [
        for (final child in widget.children)
          SizedBox(width: widget.width, child: child),
      ],
      builder: (context, controller, _) => KeyedSubtree(
        key: _anchorKey,
        child: widget.builder(context, _toggle),
      ),
    );
  }
}
