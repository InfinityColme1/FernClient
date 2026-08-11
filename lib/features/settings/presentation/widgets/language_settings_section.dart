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

/// Idioma de la aplicación.
///
/// Cada idioma se nombra en el suyo propio (English, Français, Castellano,
/// Català), que es como se reconocen cuando no se entiende el que está puesto;
/// por eso esos nombres no están traducidos.
class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({super.key});

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
              texts.languageSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.languageSectionNote,
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
