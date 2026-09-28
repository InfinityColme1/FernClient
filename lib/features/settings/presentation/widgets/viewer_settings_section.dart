import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se comporta el visor al reproducir: qué le hace a un vídeo recorrer su
/// línea de tiempo.
///
/// Qué hace al guardar lo importado está en «Importación», y volver a donde se
/// estaba mirando en «Biblioteca»: son de esas dos, aunque pasen en el visor.
class ViewerSettingsSection extends StatelessWidget {
  const ViewerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.viewerPlaybackSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.viewerPlaybackSectionNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.viewerPauseWhenSeeking,
              description: texts.viewerPauseWhenSeekingDescription,
              value: state.settings.pauseWhenSeeking,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(PauseWhenSeekingToggledEvent(value)),
            ),
          ],
        );
      },
    );
  }
}
