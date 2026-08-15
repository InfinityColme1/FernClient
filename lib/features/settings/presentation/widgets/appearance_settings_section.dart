import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se ve la aplicación: por ahora, si la lista de etiquetas del menú
/// lateral enseña los avatares.
class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.sidebarSectionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.sidebarSectionNote,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.showListAvatars,
              description: texts.showListAvatarsDescription,
              value: state.settings.showListAvatars,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(ShowListAvatarsToggledEvent(value)),
            ),
          ],
        );
      },
    );
  }
}
