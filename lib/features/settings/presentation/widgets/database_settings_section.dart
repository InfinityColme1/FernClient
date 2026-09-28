import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';
import 'package:Fern/features/settings/presentation/widgets/wipe_database_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// La base de datos: por ahora, vaciarla.
///
/// Es la única sección de los ajustes que no cambia cómo se comporta la
/// aplicación sino que **destruye** algo, así que va al final de la lista y con
/// el botón del color de lo que no se puede deshacer.
class DatabaseSettingsSection extends StatefulWidget {
  const DatabaseSettingsSection({super.key});

  @override
  State<DatabaseSettingsSection> createState() =>
      _DatabaseSettingsSectionState();
}

class _DatabaseSettingsSectionState extends State<DatabaseSettingsSection> {
  /// Dos diálogos, no uno: primero qué hace esto, y sólo después la frase.
  ///
  /// El primero puede cerrarse sin más; del segundo sólo se sale escribiendo la
  /// frase entera o cerrándolo.
  Future<void> _wipe(BuildContext context) async {
    final options = await showFernDialog<DatabaseWipeOptions, MediaBloc>(
      context: context,
      builder: (_) => WipeDatabaseWarningDialog(
        // Con el bloqueo cerrado no se ofrece vaciar «sólo lo no apto»: ese
        // contenido no se ve, así que sería borrar a ciegas.
        canWipeNsfwOnly: getIt<NsfwModeService>().isUnlocked,
      ),
    );

    if (options == null || !context.mounted) return;

    final wiped = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => WipeDatabaseConfirmDialog(options: options),
    );

    if (wiped != true || !context.mounted) return;

    // Lo que estuviera pintado habla de una base de datos que ya no existe. Sin
    // releer, la rejilla y el menú siguen enseñando etiquetas y contenidos que
    // no están, y el primer clic sobre cualquiera de ellos falla.
    getIt<TagsBloc>().add(const LoadTagsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());

    showFernToast(context, AppLocalizations.of(context).databaseWipeDone);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.databaseSectionTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.databaseSectionNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(texts.databaseWipeTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.databaseWipeSectionNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          // No ocupa el ancho entero: un botón de borrarlo todo del tamaño del de
          // guardar se pulsa por costumbre.
          Align(
            alignment: Alignment.centerLeft,
            child: FernPillButton(
              label: texts.databaseWipeAction,
              icon: Symbols.delete_forever,
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.white,
              onPressed: () => _wipe(context),
            ),
          ),
        ],
      ),
    );
  }
}
