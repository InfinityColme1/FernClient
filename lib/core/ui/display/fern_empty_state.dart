import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Estado vacío reutilizable: ilustración, mensaje y acción opcional.
class FernEmptyState extends StatelessWidget {
  final String imageAsset;
  final String message;
  final double imageSize;
  final Widget? action;

  const FernEmptyState({
    super.key,
    required this.imageAsset,
    required this.message,
    this.imageSize = 150,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Image.asset(imageAsset),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (action != null) ...[
          const SizedBox(height: AppSpacing.l),
          action!,
        ],
      ],
    );
  }
}
