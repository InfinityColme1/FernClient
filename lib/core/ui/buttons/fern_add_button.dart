import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Cómo se coloca la etiqueta respecto al círculo, y con qué peso.
enum _AddButtonLayout { stacked, inline, compact }

/// Botón circular con un "+" y una etiqueta, en tres variantes:
///
/// * la de por defecto, con la etiqueta debajo del círculo, para las rejillas de
///   avatares (añadir una etiqueta, un creador, un fernie);
/// * [FernAddButton.inline], con la etiqueta al lado, para que encaje en un
///   listado vertical de filas con avatar (las etiquetas del panel de
///   información, por ejemplo);
/// * [FernAddButton.compact], la misma fila pero menuda, para añadir campos
///   dentro de un formulario, donde el círculo grande pesaría demasiado.
///
/// Las tres son el mismo botón porque son la misma acción: antes la variante
/// menuda era un componente aparte y acabaron divergiendo dos veces.
class FernAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  final _AddButtonLayout _layout;

  const FernAddButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  }) : _layout = _AddButtonLayout.stacked;

  const FernAddButton.inline({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  }) : _layout = _AddButtonLayout.inline;

  const FernAddButton.compact({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.add,
  }) : _layout = _AddButtonLayout.compact;

  bool get _isCompact => _layout == _AddButtonLayout.compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final circle = Container(
      padding: EdgeInsets.all(_isCompact ? AppSpacing.xxs : AppSpacing.s),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.black,
          width: _isCompact ? AppSizes.borderThin : AppSizes.borderRegular,
        ),
      ),
      child: Icon(
        icon,
        size: _isCompact ? AppSizes.iconSmall : AppSizes.iconLarge,
        color: context.colors.black,
      ),
    );

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: switch (_layout) {
        _AddButtonLayout.stacked => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        _AddButtonLayout.inline => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(width: AppSpacing.m),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        // La menuda lleva su propio relleno porque va suelta entre campos de un
        // formulario y necesita algo de aire alrededor.
        _AddButtonLayout.compact => Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(width: AppSpacing.s),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
      },
    );
  }
}
