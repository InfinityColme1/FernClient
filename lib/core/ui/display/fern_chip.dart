import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Un widget opcional a la izquierda y un texto, en dos variantes:
///
/// * la de por defecto, una píldora blanca con sombra suave;
/// * [FernChip.plain], sin fondo, sin sombra y sin esquinas redondeadas, para
///   los listados que van directamente sobre el fondo de la pantalla.
///
/// Se usa para las etiquetas y es reutilizable para colecciones, filtros o
/// cualquier elemento seleccionable compacto.
class FernChip extends StatelessWidget {
  final String label;
  final Widget? leading;
  final VoidCallback? onTap;

  /// Fondo y color del texto. Se dejan abiertos para poder pintar en tono
  /// apagado las píldoras que todavía no están confirmadas.
  final Color backgroundColor;
  final Color? labelColor;

  /// Sin superficie: ni fondo, ni sombra, ni bordes redondeados.
  final bool isPlain;

  const FernChip({
    super.key,
    required this.label,
    this.leading,
    this.onTap,
    this.backgroundColor = AppColors.white,
    this.labelColor,
  }) : isPlain = false;

  const FernChip.plain({
    super.key,
    required this.label,
    this.leading,
    this.onTap,
    this.labelColor,
  })  : backgroundColor = Colors.transparent,
        isPlain = true;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSizes.radiusLarge);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.m),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // Sin píldora el texto va con el grosor normal del tema.
                fontWeight: isPlain ? null : FontWeight.bold,
                color: labelColor,
              ),
        ),
      ],
    );

    final content = isPlain
        ? row
        : Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: row,
          );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: isPlain ? null : borderRadius,
      child: content,
    );
  }
}
