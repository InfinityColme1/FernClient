import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Casilla de verificación con etiqueta y, opcionalmente, una línea de
/// explicación debajo.
///
/// Con [onChanged] a `null` queda desactivada y todo el bloque se atenúa: es la
/// forma de enseñar una opción que existe pero que todavía no se puede tocar
/// (por ejemplo "copiar archivos" mientras la sincronización está apagada).
class FernCheckboxTile extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const FernCheckboxTile({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onChanged != null;
    final opacity = isEnabled ? 1.0 : disabledOptionOpacity;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        onTap: isEnabled ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: isEnabled ? (checked) => onChanged!(checked ?? false) : null,
              ),
              const SizedBox(width: AppSpacing.s),
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
