import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/presentation/widgets/sidecar_setup_panel.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/settings/presentation/settings_status_labels.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ajustes del reconocimiento de contenido.
///
/// De momento sólo dice dónde vive todo (el entorno de entrenamiento, los
/// modelos y los conjuntos de datos), que es lo que hay que decidir antes de
/// que empiece a ocupar sitio. El estado del entorno de Python y los ajustes de
/// reconocimiento automático se añaden aquí cuando existan.
class RecognitionSettingsSection extends StatelessWidget {
  const RecognitionSettingsSection({super.key});

  /// Abre el explorador y avisa al bloc con la carpeta elegida. Si el usuario
  /// cancela no se toca nada.
  Future<void> _pickDirectory(BuildContext context) async {
    final directory = await FilePicker.getDirectoryPath();
    if (directory == null || !context.mounted) return;

    context.read<SettingsBloc>().add(RecognitionDirectoryChangedEvent(directory));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, texts.recognitionFolderTitle),
            _description(context, texts.recognitionFolderDescription),
            const SizedBox(height: AppSpacing.l),
            FernDirectoryField(
              label: texts.recognitionFolder,
              path: state.settings.recognitionPath,
              onPressed:
                  state.isWorking ? null : () => _pickDirectory(context),
            ),
            const SizedBox(height: AppSpacing.l),
            // Mover esto puede tardar: son los modelos y el entorno entero, no
            // un puñado de avatares.
            if (state.isWorking)
              const SizedBox(
                width: AppSizes.iconMedium,
                height: AppSizes.iconMedium,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (state.lastResult case final result?
                when result.status.isRecognition)
              Text(
                result.message(texts),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colors.gray),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            const SidecarSetupPanel(),
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
          ?.copyWith(color: context.colors.gray),
    );
  }
}
