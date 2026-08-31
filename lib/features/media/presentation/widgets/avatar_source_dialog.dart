import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// De dónde sale la imagen del avatar.
enum AvatarSource {
  /// De la biblioteca de la propia aplicación.
  library,

  /// De un fichero del equipo, con el explorador de siempre.
  device,
}

/// Pregunta de dónde se saca la imagen del avatar.
///
/// Antes sólo había una respuesta —el explorador— y eso obligaba a ir a buscar
/// en el disco una imagen que la aplicación ya tiene guardada y sabe enseñar. Lo
/// normal es que la cara de una etiqueta esté en su propio contenido.
class AvatarSourceDialog extends StatelessWidget {
  const AvatarSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(texts.avatarSourceTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.l),
          // La biblioteca primero: es la respuesta de casi todas las veces, y la
          // que no existía.
          FernPillButton(
            label: texts.avatarSourceLibrary,
            icon: Symbols.photo_library,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: () => Navigator.of(context).pop(AvatarSource.library),
          ),
          const SizedBox(height: AppSpacing.s),
          FernPillButton(
            label: texts.avatarSourceDevice,
            icon: Symbols.folder_open,
            // `black` es el color del texto, no el negro: el de la superficie
            // es `white`, y ponerlo aquí dejaría la etiqueta invisible.
            backgroundColor: context.colors.background,
            foregroundColor: context.colors.black,
            onPressed: () => Navigator.of(context).pop(AvatarSource.device),
          ),
        ],
      ),
    );
  }
}
