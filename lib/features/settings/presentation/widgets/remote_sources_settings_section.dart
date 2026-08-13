import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Configuración de las plataformas de las que la aplicación puede traerse
/// contenido. Por ahora sólo Reddit.
///
/// Los campos son de estado propio y no de un `BlocBuilder`: se guardan según
/// se escriben, y repintarlos con cada tecla movería el cursor de sitio. El
/// valor de partida se lee una sola vez, al abrir la sección.
class RemoteSourcesSettingsSection extends StatefulWidget {
  const RemoteSourcesSettingsSection({super.key});

  @override
  State<RemoteSourcesSettingsSection> createState() =>
      _RemoteSourcesSettingsSectionState();
}

class _RemoteSourcesSettingsSectionState
    extends State<RemoteSourcesSettingsSection> {
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;
  late final TextEditingController _username;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();

    final reddit = getIt<SettingsBloc>().state.settings.reddit;
    _clientId = TextEditingController(text: reddit.clientId);
    _clientSecret = TextEditingController(text: reddit.clientSecret);
    _username = TextEditingController(text: reddit.username);
    _password = TextEditingController(text: reddit.password);
  }

  @override
  void dispose() {
    _clientId.dispose();
    _clientSecret.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Guarda las cuatro credenciales tal y como están en los campos. Se llama
  /// desde cualquiera de ellos: se guardan juntas porque juntas se usan.
  void _save() {
    context.read<SettingsBloc>().add(RedditSettingsChangedEvent(
          RedditSettingsEntity(
            clientId: _clientId.text,
            clientSecret: _clientSecret.text,
            username: _username.text,
            password: _password.text,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(context, texts.redditTitle),
        _description(context, texts.redditDescription),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.redditClientId,
          hintText: texts.redditClientIdHint,
          controller: _clientId,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.redditClientSecret,
          hintText: texts.redditClientSecretHint,
          controller: _clientSecret,
          obscureText: true,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.redditUsername,
          hintText: texts.redditUsernameHint,
          controller: _username,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.redditPassword,
          hintText: texts.redditPasswordHint,
          controller: _password,
          obscureText: true,
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.l),
        _description(context, texts.redditCredentialsNote),
      ],
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
}
