import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  /// Lo que va detrás del nombre, antes del botón de quitar.
  ///
  /// Lo usa el distintivo de las etiquetas NSFW: delante tapaba el avatar, que
  /// es con lo que se reconoce una etiqueta de un vistazo.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Si se indica, la píldora lleva a la derecha el botón de quitarla: el mismo
  /// icono con el que se vacía un campo de texto.
  final VoidCallback? onRemove;

  /// Fondo y color del texto. Se dejan abiertos para poder pintar en tono
  /// apagado las píldoras que todavía no están confirmadas.
  /// Sin decir nada, la superficie de la paleta que esté puesta.
  final Color? backgroundColor;
  final Color? labelColor;

  /// Sin superficie: ni fondo, ni sombra, ni bordes redondeados.
  final bool isPlain;

  const FernChip({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.onRemove,
    this.backgroundColor,
    this.labelColor,
  }) : isPlain = false;

  const FernChip.plain({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.onRemove,
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
        // Cede y se recorta si no llega: la píldora es una fila que no se parte,
        // y el nombre de una etiqueta puede ser largo. En el panel del contenido
        // —350 píxeles, con avatar, marca NSFW y cruz al lado— un nombre normal
        // ya la desbordaba por la derecha.
        //
        // Con `Flexible` y no con `Expanded`: la píldora mide lo que mide su
        // contenido y estirarla dejaría la cruz pegada al borde de la pantalla.
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  // Sin píldora el texto va con el grosor normal del tema.
                  fontWeight: isPlain ? null : FontWeight.bold,
                  color: labelColor,
                ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s),
          trailing!,
        ],
        if (onRemove != null) ...[
          const SizedBox(width: AppSpacing.s),
          // El botón va dentro de la píldora, así que se pinta a mano en vez de
          // con un `IconButton`: el hueco que éste reserva alrededor la
          // deformaría.
          InkWell(
            onTap: onRemove,
            mouseCursor: WidgetStateMouseCursor.clickable,
            customBorder: const CircleBorder(),
            child: Icon(
              Symbols.cancel,
              size: AppSizes.iconCompact,
              color: labelColor ?? context.colors.black,
            ),
          ),
        ],
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
              color: backgroundColor ?? context.colors.white,
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
