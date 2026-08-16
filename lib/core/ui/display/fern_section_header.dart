import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Cabecera de sección: icono + título en color atenuado.
class FernSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const FernSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: context.colors.gray),
        const SizedBox(width: AppSpacing.s),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: context.colors.gray),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}
