import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Configuración de las plataformas de las que la aplicación puede traerse
/// contenido con sus propias credenciales: Reddit, Danbooru, Gelbooru y
/// Pinterest.
///
/// Las plataformas en las que se entra desde el navegador de la aplicación no
/// están aquí: su sesión no se escribe, se recoge.
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
  late final TextEditingController _danbooruUsername;
  late final TextEditingController _danbooruApiKey;
  late final TextEditingController _gelbooruUserId;
  late final TextEditingController _gelbooruApiKey;
  late final TextEditingController _pinterestUsername;

  @override
  void initState() {
    super.initState();

    final settings = getIt<SettingsBloc>().state.settings;

    final reddit = settings.reddit;
    _clientId = TextEditingController(text: reddit.clientId);
    _clientSecret = TextEditingController(text: reddit.clientSecret);
    _username = TextEditingController(text: reddit.username);
    _password = TextEditingController(text: reddit.password);

    final danbooru = settings.danbooru;
    _danbooruUsername = TextEditingController(text: danbooru.username);
    _danbooruApiKey = TextEditingController(text: danbooru.apiKey);

    final gelbooru = settings.gelbooru;
    _gelbooruUserId = TextEditingController(text: gelbooru.userId);
    _gelbooruApiKey = TextEditingController(text: gelbooru.apiKey);

    _pinterestUsername =
        TextEditingController(text: settings.pinterest.username);
  }

  @override
  void dispose() {
    _clientId.dispose();
    _clientSecret.dispose();
    _username.dispose();
    _password.dispose();
    _danbooruUsername.dispose();
    _danbooruApiKey.dispose();
    _gelbooruUserId.dispose();
    _gelbooruApiKey.dispose();
    _pinterestUsername.dispose();
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

  /// Guarda las dos credenciales de Danbooru tal y como están en sus campos.
  void _saveDanbooru() {
    context.read<SettingsBloc>().add(DanbooruSettingsChangedEvent(
          DanbooruSettingsEntity(
            username: _danbooruUsername.text,
            apiKey: _danbooruApiKey.text,
          ),
        ));
  }

  /// Guarda las dos credenciales de Gelbooru tal y como están en sus campos.
  void _saveGelbooru() {
    context.read<SettingsBloc>().add(GelbooruSettingsChangedEvent(
          GelbooruSettingsEntity(
            userId: _gelbooruUserId.text,
            apiKey: _gelbooruApiKey.text,
          ),
        ));
  }

  /// Guarda el nombre de la cuenta de Pinterest, sin tocar la sesión: ésa la
  /// recoge el navegador y no se escribe aquí.
  void _savePinterest() {
    final pinterest = getIt<SettingsBloc>().state.settings.pinterest;

    context.read<SettingsBloc>().add(PinterestSettingsChangedEvent(
          pinterest.copyWith(username: _pinterestUsername.text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arriba del todo y fuera de los apartados de cada plataforma: vale para
        // todas, y por eso no cuelga de ninguna. Esta sí es de `BlocSelector`,
        // que una casilla se repinta entera con cada cambio sin mover ningún
        // cursor de sitio.
        BlocSelector<SettingsBloc, SettingsState, bool>(
          selector: (state) => state.settings.autoTagRemoteSource,
          builder: (context, enabled) => FernCheckboxTile(
            label: texts.autoTagRemoteSource,
            description: texts.autoTagRemoteSourceDescription,
            value: enabled,
            onChanged: (value) => context
                .read<SettingsBloc>()
                .add(AutoTagRemoteSourceToggledEvent(value)),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
        const SizedBox(height: AppSpacing.xl),
        _title(context, texts.danbooruTitle),
        _description(context, texts.danbooruDescription),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.danbooruUsername,
          hintText: texts.danbooruUsernameHint,
          controller: _danbooruUsername,
          onChanged: (_) => _saveDanbooru(),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.danbooruApiKey,
          hintText: texts.danbooruApiKeyHint,
          controller: _danbooruApiKey,
          obscureText: true,
          onChanged: (_) => _saveDanbooru(),
        ),
        const SizedBox(height: AppSpacing.l),
        _description(context, texts.danbooruApiKeyNote),
        const SizedBox(height: AppSpacing.xl),
        _title(context, texts.gelbooruTitle),
        _description(context, texts.gelbooruDescription),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.gelbooruUserId,
          hintText: texts.gelbooruUserIdHint,
          controller: _gelbooruUserId,
          onChanged: (_) => _saveGelbooru(),
        ),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.gelbooruApiKey,
          hintText: texts.gelbooruApiKeyHint,
          controller: _gelbooruApiKey,
          obscureText: true,
          onChanged: (_) => _saveGelbooru(),
        ),
        const SizedBox(height: AppSpacing.l),
        _description(context, texts.gelbooruApiKeyNote),
        const SizedBox(height: AppSpacing.xl),
        _title(context, texts.pinterestTitle),
        _description(context, texts.pinterestDescription),
        const SizedBox(height: AppSpacing.l),
        FernLabeledTextField(
          label: texts.pinterestUsername,
          hintText: texts.pinterestUsernameHint,
          controller: _pinterestUsername,
          onChanged: (_) => _savePinterest(),
        ),
        const SizedBox(height: AppSpacing.l),
        _description(context, texts.pinterestSecretBoardsNote),
        const SizedBox(height: AppSpacing.xl),
        _title(context, texts.pawchiveTitle),
        _description(context, texts.pawchiveDescription),
        const SizedBox(height: AppSpacing.l),
        // Esta sí es de `BlocSelector`: es una casilla, se repinta entera con
        // cada cambio y no hay ningún cursor que mover de sitio.
        BlocSelector<SettingsBloc, SettingsState, bool>(
          selector: (state) => state.settings.pawchive.byFavoriteCreators,
          builder: (context, enabled) => FernCheckboxTile(
            label: texts.pawchiveByCreators,
            description: texts.pawchiveByCreatorsDescription,
            value: enabled,
            onChanged: (value) {
              final pawchive = getIt<SettingsBloc>().state.settings.pawchive;

              context.read<SettingsBloc>().add(PawchiveSettingsChangedEvent(
                    pawchive.copyWith(byFavoriteCreators: value),
                  ));
            },
          ),
        ),
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
