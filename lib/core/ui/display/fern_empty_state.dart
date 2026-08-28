import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Lo que se enseña donde no hay nada todavía.
///
/// **Un sitio vacío es el peor momento para ser escueto.** Es cuando quien mira
/// tiene menos con lo que orientarse, y hasta ahora lo único que había era una
/// ilustración y una frase suelta. Ahora van tres cosas y cada una hace su
/// trabajo:
///
/// - **El título** dice qué pasa, en pocas palabras.
/// - **La explicación**, opcional, dice por qué está vacío o qué hay que hacer.
///   Es lo que convierte «no hay nada» en «no hay nada *todavía*».
/// - **La acción**, opcional, es el camino de salida.
///
/// La explicación se acota en ancho a propósito: una línea que cruza la pantalla
/// entera no se lee, se sobrevuela.
class FernEmptyState extends StatelessWidget {
  final String imageAsset;

  /// Qué pasa. Es lo primero y lo único obligatorio.
  final String message;

  /// Por qué está vacío, o qué hacer. Opcional: donde no hay nada que añadir,
  /// añadir por añadir es ruido.
  final String? description;

  final double imageSize;
  final Widget? action;

  const FernEmptyState({
    super.key,
    required this.imageAsset,
    required this.message,
    this.description,
    this.imageSize = AppSizes.emptyStateImage,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
            style: theme.textTheme.titleMedium,
          ),
          if (description case final description?) ...[
            const SizedBox(height: AppSpacing.s),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.emptyStateTextWidth,
              ),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.gray),
              ),
            ),
          ],
          if (action case final action?) ...[
            const SizedBox(height: AppSpacing.xl),
            action,
          ],
        ],
      ),
    );
  }
}
