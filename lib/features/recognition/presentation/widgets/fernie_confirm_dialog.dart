import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Aviso de una sola pregunta para las cosas del modo fernie que no tienen
/// vuelta atrás: tirar lo que se lleva marcado, tirar los cambios de una región
/// o borrarla.
///
/// Se cierra de dos maneras y quien lo abre las distingue: con `null` cuando se
/// sigue como se estaba (el aspa, escape, pulsar fuera) y con `true` cuando se
/// confirma. Es el mismo aviso para los tres casos porque son la misma
/// pregunta; lo único que cambia es el texto.
class FernieConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final IconData confirmIcon;

  const FernieConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.confirmIcon = Symbols.delete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: confirmLabel,
        icon: confirmIcon,
        backgroundColor: context.colors.error,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
