import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Botón de acción principal a ancho completo (guardar, importar, borrar...).
///
/// Cuando [onPressed] es `null` el botón se muestra deshabilitado con el color
/// de fondo atenuado.
class FernActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Sin decir nada, los colores del botón principal de la paleta que esté
  /// puesta. Se dan sólo cuando el botón es otra cosa (borrar, descartar).
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;

  const FernActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height = AppSizes.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? context.colors.primary;
    final foregroundColor = this.foregroundColor ?? context.colors.black;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
