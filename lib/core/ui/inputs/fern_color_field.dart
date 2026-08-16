import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/dialogs/fern_color_picker_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Fila de un color que se puede cambiar: la muestra, cómo se llama, su código
/// y el botón de devolverlo a como estaba.
///
/// Con [onChanged] a `null` queda desactivada y toda la fila se atenúa, igual
/// que las casillas: la opción se sigue viendo (para saber que está ahí y qué se
/// podría cambiar) pero no se puede tocar.
///
/// [isCustom] es si ese color lo ha puesto el usuario. Cuando no, lo que se
/// enseña es el que se hereda del tema de fábrica y no hay nada que restablecer.
class FernColorField extends StatelessWidget {
  final String label;
  final Color color;
  final bool isCustom;
  final ValueChanged<Color>? onChanged;
  final VoidCallback? onReset;

  const FernColorField({
    super.key,
    required this.label,
    required this.color,
    required this.isCustom,
    this.onChanged,
    this.onReset,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showFernColorPicker(context, initialColor: color);
    if (picked == null) return;

    onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final colors = context.colors;
    final isEnabled = onChanged != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : disabledOptionOpacity,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        onTap: isEnabled ? () => _pick(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Tooltip(
                message: texts.customColorPick,
                child: Container(
                  width: AppSizes.colorSwatch,
                  height: AppSizes.colorSwatch,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: colors.lightgray),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyLarge),
                    Text(
                      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.gray),
                    ),
                  ],
                ),
              ),
              // Sólo hay algo que restablecer si el color lo ha puesto el
              // usuario; el heredado ya es el de fábrica.
              IconButton(
                tooltip: texts.customColorReset,
                icon: const Icon(Icons.restart_alt, size: AppSizes.iconMedium),
                onPressed: isEnabled && isCustom ? onReset : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
