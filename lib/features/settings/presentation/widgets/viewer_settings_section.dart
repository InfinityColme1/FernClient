import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se comporta el visor: por ahora, qué hace al dar por definitivo un
/// contenido importado.
class ViewerSettingsSection extends StatelessWidget {
  const ViewerSettingsSection({super.key});

  String _label(ViewerSaveBehavior behavior, AppLocalizations texts) =>
      switch (behavior) {
        ViewerSaveBehavior.goToNext => texts.viewerSaveNext,
        ViewerSaveBehavior.closeViewer => texts.viewerSaveClose,
      };

  String _description(ViewerSaveBehavior behavior, AppLocalizations texts) =>
      switch (behavior) {
        ViewerSaveBehavior.goToNext => texts.viewerSaveNextDescription,
        ViewerSaveBehavior.closeViewer => texts.viewerSaveCloseDescription,
      };

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
              texts.viewerSaveSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.viewerSaveSectionNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            for (final behavior in ViewerSaveBehavior.values)
              FernRadioTile<ViewerSaveBehavior>(
                value: behavior,
                groupValue: state.settings.viewerSaveBehavior,
                label: _label(behavior, texts),
                description: _description(behavior, texts),
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(ViewerSaveBehaviorChangedEvent(value)),
              ),
          ],
        );
      },
    );
  }
}
