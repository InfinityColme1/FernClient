import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/display/fern_surface_color.dart';
import 'package:flutter/material.dart';

/// Etiqueta flotante que se apoya sobre el borde de un campo con contorno.
class FernFieldLabel extends StatelessWidget {
  final String text;

  const FernFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // El color de la superficie sobre la que se está pintando, si hay alguna.
    // La etiqueta se apoya encima del borde del campo y tiene que taparlo con lo
    // que haya debajo; pintarla siempre blanca deja un parche que canta en
    // cuanto el campo no está sobre una ficha blanca.
    final background = FernSurfaceColor.maybeOf(context) ?? context.colors.white;

    return Container(
      color: background,
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
