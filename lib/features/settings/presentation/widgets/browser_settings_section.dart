import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ajustes del navegador de dentro de la aplicación. **Es una prueba**, igual
/// que la pantalla a la que configura.
///
/// De momento sólo hay uno: por dónde empieza. El campo es de estado propio y no
/// de un `BlocBuilder` por lo mismo que los de las fuentes remotas: se guarda
/// según se escribe, y repintarlo con cada tecla movería el cursor de sitio.
class BrowserSettingsSection extends StatefulWidget {
  const BrowserSettingsSection({super.key});

  @override
  State<BrowserSettingsSection> createState() => _BrowserSettingsSectionState();
}

class _BrowserSettingsSectionState extends State<BrowserSettingsSection> {
  late final TextEditingController _home;

  @override
  void initState() {
    super.initState();

    _home = TextEditingController(
      text: getIt<SettingsBloc>().state.settings.browserHome,
    );
  }

  @override
  void dispose() {
    _home.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.browserHomeTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        Text(
          texts.browserHomeDescription,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.colors.gray),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.browserHomeLabel,
          hintText: browserHomeHint,
          controller: _home,
          onChanged: (value) =>
              context.read<SettingsBloc>().add(BrowserHomeChangedEvent(value)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(texts.browserAsideTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        Text(
          texts.browserAsideNote,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.colors.gray),
        ),
        const SizedBox(height: AppSpacing.l),
        // De `BlocSelector`: son tres opciones excluyentes y se repintan
        // enteras con cada cambio, sin ningún cursor que mover de sitio.
        BlocSelector<SettingsBloc, SettingsState, BrowserAsidePolicy>(
          selector: (state) => state.settings.browserAside,
          builder: (context, policy) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final option in BrowserAsidePolicy.values)
                FernRadioTile<BrowserAsidePolicy>(
                  value: option,
                  groupValue: policy,
                  label: _asideLabel(option, texts),
                  description: _asideDescription(option, texts),
                  onChanged: (chosen) => context
                      .read<SettingsBloc>()
                      .add(BrowserAsideChangedEvent(chosen)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _asideLabel(BrowserAsidePolicy policy, AppLocalizations texts) =>
    switch (policy) {
      BrowserAsidePolicy.always => texts.browserAsideAlways,
      BrowserAsidePolicy.largeImports => texts.browserAsideLarge,
      BrowserAsidePolicy.never => texts.browserAsideNever,
    };

String _asideDescription(BrowserAsidePolicy policy, AppLocalizations texts) =>
    switch (policy) {
      BrowserAsidePolicy.always => texts.browserAsideAlwaysDescription,
      BrowserAsidePolicy.largeImports => texts.browserAsideLargeDescription,
      BrowserAsidePolicy.never => texts.browserAsideNeverDescription,
    };

/// Un ejemplo de dirección, que no se traduce: una dirección es una dirección
/// en cualquier idioma.
const browserHomeHint = 'https://www.google.com';
