import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final bloc = context.read<SettingsBloc>();
        final syncEnabled = settings.syncLocalFiles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, "Local files"),
            FernCheckboxTile(
              label: "Sync local files",
              description:
                  "Fern moves the media it works with into a folder of its own, "
                  "both what is already imported and what comes next.",
              value: syncEnabled,
              onChanged: (value) => bloc.add(SyncLocalFilesToggledEvent(value)),
            ),
            const SizedBox(height: AppSpacing.xl),
            FernDirectoryField(
              label: "Library folder",
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
              label: "Copy files",
              description:
                  "Keep the original file where it was and work with a copy "
                  "inside the library folder.",
              value: settings.copyFiles,
              onChanged: syncEnabled
                  ? (value) => bloc.add(CopyFilesToggledEvent(value))
                  : null,
            ),

            _separator(),
            _title(context, "Avatars"),
            _description(
              context,
              "Avatar images are always copied into their own folder, whether "
              "local files are synced or not. Changing the folder brings the "
              "existing avatars along.",
            ),
            const SizedBox(height: AppSpacing.l),
            FernDirectoryField(
              label: "Avatars folder",
              path: settings.avatarsPath,
              onPressed: state.isWorking
                  ? null
                  : () => _pickDirectory(
                        context,
                        AvatarsDirectoryChangedEvent.new,
                      ),
            ),

            _separator(),
            _title(context, "Organization"),
            _description(
              context,
              "How the files are laid out inside the library folder. It does "
              "not affect avatar images.",
            ),
            const SizedBox(height: AppSpacing.s),
            for (final criteria in FileOrganizationCriteria.values)
              FernRadioTile<FileOrganizationCriteria>(
                value: criteria,
                groupValue: settings.organization,
                label: criteria.label,
                description: criteria.description,
                onChanged: syncEnabled
                    ? (value) => bloc.add(FileOrganizationChangedEvent(value))
                    : null,
              ),

            _separator(),
            _title(context, "Migration"),
            _description(
              context,
              "Sort every file already in the library with the criteria above.",
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                FernPillButton(
                  label: "Migrate files",
                  icon: Icons.drive_file_move_outline,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
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
                else if (state.statusMessage != null)
                  Expanded(
                    child: Text(
                      state.statusMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.gray),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
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
          ?.copyWith(color: AppColors.gray),
    );
  }

  Widget _separator() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Divider(),
      );
}
