import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Idioma de la aplicación.
///
/// La elección se guarda, pero los textos todavía no se traducen: la
/// localización se conectará a esta preferencia cuando exista.
class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application language",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              "Translations are on the way; for now this only remembers your choice.",
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            for (final language in AppLanguage.values)
              FernRadioTile<AppLanguage>(
                value: language,
                groupValue: state.settings.language,
                label: language.label,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(LanguageChangedEvent(value)),
              ),
          ],
        );
      },
    );
  }
}
