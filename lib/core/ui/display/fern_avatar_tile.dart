import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:flutter/material.dart';

/// Avatar con su etiqueta debajo, para listados horizontales de personas,
/// colecciones o etiquetas.
class FernAvatarTile extends StatelessWidget {
  final String label;
  final String? imagePath;
  final IconData fallbackIcon;
  final double radius;
  final VoidCallback? onTap;

  const FernAvatarTile({
    super.key,
    required this.label,
    this.imagePath,
    this.fallbackIcon = Icons.person,
    this.radius = AppSizes.avatarLarge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FernAvatar(
          imagePath: imagePath,
          fallbackIcon: fallbackIcon,
          radius: radius,
          backgroundColor: AppColors.lightgray,
          iconColor: AppColors.white,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: content,
    );
  }
}
