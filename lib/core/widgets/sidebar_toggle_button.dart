import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// El botón que pliega y despliega el menú lateral.
///
/// Vive en la esquina superior izquierda, junto al logo: es donde se busca lo
/// que abre y cierra el menú, y desde ahí se ve tanto con el menú abierto como
/// cerrado.
///
/// No decide nada: enseña el estado que se le dice ([isCollapsed]) y avisa de que
/// se le ha pulsado. Quien manda es el armazón de la pantalla, que es también
/// quien pliega el menú solo cuando la ventana se estrecha.
class SidebarToggleButton extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onPressed;

  const SidebarToggleButton({
    super.key,
    required this.isCollapsed,
    required this.onPressed,
  });

  @override
  State<SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<SidebarToggleButton>
    with SingleTickerProviderStateMixin {
  /// El icono pasa de aspa a rayas y al revés, al mismo paso que el menú se
  /// pliega, de modo que los dos cuentan el mismo movimiento.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: drawerAnimationDuration,
    // De arranque no se anima: el botón ya aparece como toca, igual que el menú.
    value: widget.isCollapsed ? 1.0 : 0.0,
  );

  @override
  void didUpdateWidget(covariant SidebarToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed == oldWidget.isCollapsed) return;

    widget.isCollapsed ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return IconButton(
      tooltip: widget.isCollapsed ? texts.sidebarExpand : texts.sidebarCollapse,
      onPressed: widget.onPressed,
      icon: AnimatedIcon(
        icon: AnimatedIcons.close_menu,
        progress: _controller,
        size: AppSizes.iconLarge,
      ),
    );
  }
}
