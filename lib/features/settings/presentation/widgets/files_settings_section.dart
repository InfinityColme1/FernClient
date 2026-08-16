import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se nombra cada criterio de ordenación en la pantalla. El criterio en sí
/// (el dominio) sólo guarda su identificador.
extension FileOrganizationCriteriaLabels on FileOrganizationCriteria {
  String label(AppLocalizations texts) => switch (this) {
        FileOrganizationCriteria.flat => texts.organizationFlat,
        FileOrganizationCriteria.byTag => texts.organizationByTag,
        FileOrganizationCriteria.bySource => texts.organizationBySource,
        FileOrganizationCriteria.byCreator => texts.organizationByCreator,
      };

  String description(AppLocalizations texts) => switch (this) {
        FileOrganizationCriteria.flat => texts.organizationFlatDescription,
        FileOrganizationCriteria.byTag => texts.organizationByTagDescription,
        FileOrganizationCriteria.bySource => texts.organizationBySourceDescription,
        FileOrganizationCriteria.byCreator => texts.organizationByCreatorDescription,
      };
}

/// Gestión de los ficheros locales: si la aplicación los ordena, dónde, cómo y
/// dónde guarda las imágenes de los avatares.
class FilesSettingsSection extends StatelessWidget {
  const FilesSettingsSection({super.key});

  /// Abre el explorador y avisa al bloc con la carpeta elegida. Si el usuario
  /// cancela no se toca nada.
  Future<void> _pickDirectory(
    BuildContext context,
    SettingsEvents Function(String path) event,
  ) async {
    final directory = await FilePicker.getDirectoryPath();
    if (directory == null || !context.mounted) return;

    context.read<SettingsBloc>().add(event(directory));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final bloc = context.read<SettingsBloc>();
        final syncEnabled = settings.syncLocalFiles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, texts.filesLocalTitle),
            FernCheckboxTile(
              label: texts.syncLocalFiles,
              description: texts.syncLocalFilesDescription,
              value: syncEnabled,
              onChanged: (value) => bloc.add(SyncLocalFilesToggledEvent(value)),
            ),
            const SizedBox(height: AppSpacing.xl),
            FernDirectoryField(
              label: texts.libraryFolder,
              path: settings.libraryPath,
              onPressed: syncEnabled
                  ? () => _pickDirectory(
                        context,
                        LibraryDirectoryChangedEvent.new,
                      )
                  : null,
            ),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.copyFiles,
              description: texts.copyFilesDescription,
              value: settings.copyFiles,
              onChanged: syncEnabled
                  ? (value) => bloc.add(CopyFilesToggledEvent(value))
                  : null,
            ),

            _separator(),
            _title(context, texts.avatarsTitle),
            _description(context, texts.avatarsDescription),
            const SizedBox(height: AppSpacing.l),
            FernDirectoryField(
              label: texts.avatarsFolder,
              path: settings.avatarsPath,
              onPressed: state.isWorking
                  ? null
                  : () => _pickDirectory(
                        context,
                        AvatarsDirectoryChangedEvent.new,
                      ),
            ),

            _separator(),
            _title(context, texts.organizationTitle),
            _description(context, texts.organizationDescription),
            const SizedBox(height: AppSpacing.s),
            for (final criteria in FileOrganizationCriteria.values)
              FernRadioTile<FileOrganizationCriteria>(
                value: criteria,
                groupValue: settings.organization,
                label: criteria.label(texts),
                description: criteria.description(texts),
                onChanged: syncEnabled
                    ? (value) => bloc.add(FileOrganizationChangedEvent(value))
                    : null,
              ),

            _separator(),
            _title(context, texts.migrationTitle),
            _description(context, texts.migrationDescription),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                FernPillButton(
                  label: texts.migrateFiles,
                  icon: Icons.drive_file_move_outline,
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.black,
                  onPressed: settings.managesFiles && !state.isWorking
                      ? () => bloc.add(const MigrateLibraryRequestedEvent())
                      : null,
                ),
                const SizedBox(width: AppSpacing.l),
                if (state.isWorking)
                  const SizedBox(
                    width: AppSizes.iconMedium,
                    height: AppSizes.iconMedium,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (state.lastResult != null)
                  Expanded(
                    child: Text(
                      _resultMessage(texts, state.lastResult!),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: context.colors.gray),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// El resultado se guarda en datos y se traduce aquí, así que cambiar de
  /// idioma reescribe también el aviso de la última migración.
  String _resultMessage(AppLocalizations texts, SettingsResult result) {
    return switch (result.status) {
      SettingsStatus.avatarsMigrated => texts.avatarsMoved(result.count),
      SettingsStatus.avatarsFailed => texts.avatarsMoveFailed,
      SettingsStatus.filesOrganized => texts.filesOrganized(result.count),
      SettingsStatus.filesFailed => texts.filesOrganizeFailed,
    };
  }

  Widget _title(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _description(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.gray),
    );
  }

  Widget _separator() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Divider(),
      );
}
