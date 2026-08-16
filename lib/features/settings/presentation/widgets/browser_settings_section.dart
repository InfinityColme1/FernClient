import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
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
      ],
    );
  }
}

/// Un ejemplo de dirección, que no se traduce: una dirección es una dirección
/// en cualquier idioma.
const browserHomeHint = 'https://www.google.com';
