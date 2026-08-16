import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Opción única de un grupo: círculo marcado o vacío, etiqueta y, si hace
/// falta, una línea de explicación.
///
/// El círculo se pinta con iconos en lugar de con un [Radio] porque así el
/// grupo no necesita ningún ancestro que lo coordine: quien lo usa compara
/// [value] con [groupValue] y ya está.
class FernRadioTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final String? description;
  final ValueChanged<T>? onChanged;

  const FernRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.description,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onChanged != null;
    final isSelected = value == groupValue;

    return Opacity(
      opacity: isEnabled ? 1.0 : disabledOptionOpacity,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        onTap: isEnabled ? () => onChanged!(value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: AppSizes.iconMedium,
                color: isSelected ? context.colors.black : context.colors.lightgray,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyLarge),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.gray),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
