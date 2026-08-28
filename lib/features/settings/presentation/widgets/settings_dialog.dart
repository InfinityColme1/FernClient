import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/widgets/duplicates_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/nsfw_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/appearance_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/browser_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/help_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section_list.dart';
import 'package:Fern/features/settings/presentation/widgets/database_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/files_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/language_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/recognition_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/remote_sources_settings_section.dart';
import 'package:Fern/features/settings/presentation/widgets/viewer_settings_section.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


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
        backgroundColor: context.colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusDialog),
        ),
        // El tamaño que pide, o el que quepa. Era fijo, y en una ventana más
        // baja que el diálogo lo que sobraba se salía por abajo en vez de
        // encogerse: la aplicación se puede reescalar y esto tiene que
        // acompañar.
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: math.min(
              AppSizes.settingsDialogWidth,
              constraints.maxWidth,
            ),
            height: math.min(
              AppSizes.settingsDialogHeight,
              constraints.maxHeight,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsSectionList(
                  selected: _section,
                  onSelected: (section) => setState(() => _section = section),
                ),
                Expanded(child: _sectionContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                tooltip: AppLocalizations.of(context).actionClose,
                icon: const Icon(Symbols.close, size: AppSizes.iconExtraLarge),
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
              SettingsSection.viewer => const ViewerSettingsSection(),
              SettingsSection.files => const FilesSettingsSection(),
              SettingsSection.remoteSources =>
                const RemoteSourcesSettingsSection(),
              SettingsSection.recognition =>
                const RecognitionSettingsSection(),
              SettingsSection.duplicates =>
                const DuplicatesSettingsSection(),
              SettingsSection.nsfw => const NsfwSettingsSection(),
              SettingsSection.notifications =>
                const NotificationSettingsSection(),
              SettingsSection.browser => const BrowserSettingsSection(),
              SettingsSection.help => const HelpSettingsSection(),
              SettingsSection.database => const DatabaseSettingsSection(),
            },
          ),
        ),
      ],
    );
  }
}
