import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// La plataforma ha rechazado la sesión guardada y hay que volver a entrar.
///
/// No es un aviso que se pueda quedar en un rincón de la pantalla: la
/// importación no va a funcionar hasta que el usuario entre otra vez, y sólo él
/// puede hacerlo. Por eso se le corta el paso y se le ofrece ir a donde se
/// arregla.
///
/// Se cierra con `true` cuando el usuario quiere ir a iniciar sesión, y con
/// `null` cuando lo deja para luego.
class SessionExpiredDialog extends StatelessWidget {
  final ImportSource source;

  const SessionExpiredDialog({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = source.label ?? source.id;

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.sessionExpiredTitle(name),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            texts.sessionExpiredDescription(name),
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: texts.sourceLogIn(name),
        icon: Icons.login,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
