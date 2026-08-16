import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/browser/domain/entities/browser_session_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// La plataforma ha rechazado lo que la aplicación le daba para entrar.
///
/// No es un aviso que se pueda quedar en un rincón de la pantalla: la
/// importación no va a funcionar hasta que el usuario lo arregle, y sólo él
/// puede hacerlo. Por eso se le corta el paso y se le ofrece ir a donde se
/// arregla, que no es el mismo sitio en todas las plataformas:
///
/// - En las que se entra desde el navegador de la aplicación, lo que hace falta
///   es volver a iniciar sesión ahí.
/// - En las que se configuran con sus propias credenciales (una clave de API),
///   lo que hace falta es revisarlas en los ajustes.
///
/// Se cierra con `true` cuando el usuario quiere ir a arreglarlo, y con `null`
/// cuando lo deja para luego.
class SessionExpiredDialog extends StatelessWidget {
  final ImportSource source;

  const SessionExpiredDialog({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = source.label ?? source.id;

    // Si la sesión de esta plataforma se recoge del navegador, lo que hay que
    // hacer es entrar otra vez; si no, es que sus credenciales están en los
    // ajustes y hay que repasarlas.
    final isBrowserSession = browserSessionFor(source) != null;

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBrowserSession
                ? texts.sessionExpiredTitle(name)
                : texts.credentialsRejectedTitle(name),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            isBrowserSession
                ? texts.sessionExpiredDescription(name)
                : texts.credentialsRejectedDescription(name),
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
        ],
      ),
      actionButton: FernPillButton(
        label: isBrowserSession
            ? texts.sourceLogIn(name)
            : texts.actionOpenRemoteSettings,
        icon: isBrowserSession ? Icons.login : Icons.settings,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
