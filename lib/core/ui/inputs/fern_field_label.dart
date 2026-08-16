import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Etiqueta flotante que se apoya sobre el borde de un campo con contorno.
class FernFieldLabel extends StatelessWidget {
  final String text;

  const FernFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
      ),
    );
  }
}
