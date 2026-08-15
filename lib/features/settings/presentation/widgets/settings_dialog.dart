import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/widgets/appearance_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/browser_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/files_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/language_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/remote_sources_settings_section.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Las secciones de la pantalla de ajustes, en el orden en el que se listan.
enum SettingsSection {
  language(icon: Icons.language),
  appearance(icon: Icons.palette_outlined),
  files(icon: Icons.folder_outlined),
  remoteSources(icon: Icons.cloud_download_outlined),

  /// Experimental: los ajustes del navegador de dentro de la aplicación.
  browser(icon: Icons.travel_explore_outlined);

  const SettingsSection({required this.icon});

  final IconData icon;

  String title(AppLocalizations texts) => switch (this) {
        SettingsSection.language => texts.settingsLanguage,
        SettingsSection.appearance => texts.settingsAppearance,
        SettingsSection.files => texts.settingsFiles,
        SettingsSection.remoteSources => texts.settingsRemoteSources,
        SettingsSection.browser => texts.settingsBrowser,
      };
}

/// Pantalla de ajustes: la lista de secciones a la izquierda y las opciones de
/// la sección elegida a la derecha.
///
/// Se abre desde el engranaje de la barra superior. La sección elegida es
/// estado de la pantalla y no del bloc: no hay nada que guardar ni que
/// compartir con nadie.
class SettingsDialog extends StatefulWidget {
  /// Por qué sección se abre. La de siempre es la primera; se pide otra cuando
  /// se llega aquí a arreglar algo concreto (unas credenciales que la
  /// plataforma ha rechazado, por ejemplo).
  final SettingsSection initialSection;

  const SettingsDialog({
    super.key,
    this.initialSection = SettingsSection.language,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsSection _section = widget.initialSection;

  @override
  Widget build(BuildContext context) {
    // El bloc es el mismo de la raíz (el idioma lo escucha `MaterialApp`), así
    // que se re-provee con `.value`: no se crea aquí ni se cierra al salir.
    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: Dialog(
        backgroundColor: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusDialog),
        ),
        child: SizedBox(
          width: AppSizes.settingsDialogWidth,
          height: AppSizes.settingsDialogHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionList(context),
              Expanded(child: _sectionContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// Columna izquierda: título y una fila por sección.
  Widget _sectionList(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.settingsNavWidth,
      color: AppColors.secondary,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.m,
              bottom: AppSpacing.xl,
            ),
            child: Text(
              AppLocalizations.of(context).settingsTitle,
              style: theme.textTheme.headlineMedium,
            ),
          ),
          for (final section in SettingsSection.values)
            _sectionTile(context, section),
        ],
      ),
    );
  }

  Widget _sectionTile(BuildContext context, SettingsSection section) {
    final theme = Theme.of(context);
    final isSelected = section == _section;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          onTap: () => setState(() => _section = section),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.m,
            ),
            child: Row(
              children: [
                Icon(section.icon, size: AppSizes.iconMedium),
                const SizedBox(width: AppSpacing.m),
                // El nombre de una sección se recorta antes que desbordar la
                // columna: la columna tiene un ancho fijo y los nombres cambian
                // con el idioma.
                Expanded(
                  child: Text(
                    section.title(AppLocalizations.of(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Columna derecha: cabecera con el nombre de la sección y sus opciones.
  Widget _sectionContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.l,
            top: AppSpacing.l,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _section.title(AppLocalizations.of(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: AppSizes.iconExtraLarge),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: switch (_section) {
              SettingsSection.language => const LanguageSettingsSection(),
              SettingsSection.appearance => const AppearanceSettingsSection(),
              SettingsSection.files => const FilesSettingsSection(),
              SettingsSection.remoteSources =>
                const RemoteSourcesSettingsSection(),
              SettingsSection.browser => const BrowserSettingsSection(),
            },
          ),
        ),
      ],
    );
  }
}
