import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Desplegable compacto sobre fondo de color, del mismo alto que
/// [FernPillButton], para las cabeceras de las pantallas.
class FernDropdownPill<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T value)? labelBuilder;
  final Color backgroundColor;
  final double height;

  const FernDropdownPill({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.labelBuilder,
    this.backgroundColor = AppColors.secondary,
    this.height = AppSizes.buttonHeightSmall,
  });

  String _label(T item) => labelBuilder?.call(item) ?? item.toString();

  @override
  Widget build(BuildContext context) {
    // El cursor se marca en toda la píldora, no sólo sobre el texto del
    // desplegable, que es la zona que cubre el [DropdownButton].
    return MouseRegion(
      cursor: onChanged == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            icon:
                const Icon(Icons.keyboard_arrow_down, size: AppSizes.iconCompact),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(_label(item)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
