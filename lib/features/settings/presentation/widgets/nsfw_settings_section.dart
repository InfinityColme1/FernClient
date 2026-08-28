import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_change_password_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_disable_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recovery_code_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_setup_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_unlock_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// El bloqueo de contenido no apto: ponerlo, abrirlo, cerrarlo y quitarlo.
///
/// Vive en los ajustes y no en una pantalla propia porque no es un sitio al que
/// se vaya: es un interruptor que se toca dos veces al año. Y porque el resto de
/// la aplicación no debe tener ni un botón que recuerde que esto existe cuando
/// está cerrado.
class NsfwSettingsSection extends StatefulWidget {
  const NsfwSettingsSection({super.key});

  @override
  State<NsfwSettingsSection> createState() => _NsfwSettingsSectionState();
}

class _NsfwSettingsSectionState extends State<NsfwSettingsSection> {
  NsfwModeService get _mode => getIt<NsfwModeService>();

  /// Lo último que ha pasado, para poder decirlo sin sacar otro diálogo.
  String? _result;

  Future<void> _configure() async {
    final code = await showFernDialog<String, Never>(
      context: context,
      builder: (_) => const NsfwSetupDialog(),
    );

    if (!mounted || code == null) return;

    await showNsfwRecoveryCode(context, code);

    if (!mounted) return;
    setState(() => _result = null);
  }

  Future<void> _unlock() async {
    await showFernDialog<bool, Never>(
      context: context,
      builder: (_) => const NsfwUnlockDialog(),
    );

    if (!mounted) return;
    setState(() => _result = null);
  }

  Future<void> _changePassword(AppLocalizations texts) async {
    final changed = await showFernDialog<bool, Never>(
      context: context,
      builder: (_) => const NsfwChangePasswordDialog(),
    );

    if (!mounted || changed != true) return;
    setState(() => _result = texts.nsfwChangeDone);
  }

  Future<void> _disable(AppLocalizations texts) async {
    final cleared = await showFernDialog<int, Never>(
      context: context,
      builder: (_) => const NsfwDisableDialog(),
    );

    if (!mounted || cleared == null) return;
    setState(() => _result = texts.nsfwDisableDone(cleared));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    // Se repinta con el modo: abrirlo desde el diálogo cambia lo que hay aquí
    // debajo, y quedarse enseñando «cerrado» encima de contenido que ya se ve es
    // peor que no decir nada.
    return StreamBuilder<bool>(
      stream: _mode.changes,
      builder: (context, _) {
        final isConfigured = _mode.isConfigured;
        final isUnlocked = _mode.isUnlocked;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.nsfwSectionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.nsfwSectionNote),
            const SizedBox(height: AppSpacing.s),
            // En negrita y aparte: es la frase que evita que alguien tome por
            // cifrado lo que sólo es una cortina, y de ahí salen decisiones que
            // no se toman sabiendo la verdad.
            _warning(context, texts.nsfwSectionWarning),
            const SizedBox(height: AppSpacing.l),
            if (!isConfigured) ...[
              _note(context, texts.nsfwNotConfiguredNote),
              const SizedBox(height: AppSpacing.l),
              FernActionButton(
                label: texts.nsfwConfigureAction,
                onPressed: _configure,
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    isUnlocked ? Symbols.lock_open : Symbols.lock,
                    color: isUnlocked
                        ? context.colors.terciary
                        : context.colors.unremarked,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    isUnlocked
                        ? texts.nsfwStateUnlocked
                        : texts.nsfwStateLocked,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              // Cerrar no pregunta nada. Es la única acción de aquí que no puede
              // costar un paso más de lo imprescindible.
              FernActionButton(
                label: isUnlocked
                    ? texts.nsfwCloseAction
                    : texts.nsfwOpenAction,
                onPressed: isUnlocked
                    ? () {
                        _mode.lock();
                        setState(() => _result = null);
                      }
                    : _unlock,
              ),
              const SizedBox(height: AppSpacing.l),
              FernCheckboxTile(
                label: texts.nsfwRememberLabel,
                description: texts.nsfwRememberDescription,
                value: _mode.isRemembered,
                onChanged: (value) async {
                  await _mode.setRemembered(remembered: value);

                  if (context.mounted) setState(() {});
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Divider(),
              ),
              _views(context, texts),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Divider(),
              ),
              FernActionButton(
                label: texts.nsfwChangePasswordAction,
                backgroundColor: context.colors.secondary,
                foregroundColor: context.colors.black,
                onPressed: () => _changePassword(texts),
              ),
              const SizedBox(height: AppSpacing.l),
              _note(context, texts.nsfwDisableNote),
              const SizedBox(height: AppSpacing.m),
              FernActionButton(
                label: texts.nsfwDisableAction,
                backgroundColor: context.colors.error,
                foregroundColor: context.colors.white,
                onPressed: () => _disable(texts),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: AppSpacing.m),
              _note(context, result),
            ],
          ],
        );
      },
    );
  }

  /// Cómo se comporta el bloqueo: qué se ve abierto y qué se ve cerrado.
  ///
  /// Cuelga del bloc de ajustes y no del estado de esta pantalla porque son
  /// ajustes como los demás: se guardan solos y los lee quien filtra, que no es
  /// nadie de aquí.
  Widget _views(BuildContext context, AppLocalizations texts) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.nsfwViewsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.nsfwViewsNote),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                SizedBox(
                  width: AppSizes.settingsLabelWidth,
                  child: Text(
                    texts.nsfwUnlockedViewLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                FernDropdownPill<NsfwUnlockedView>(
                  value: settings.nsfwUnlockedView,
                  items: NsfwUnlockedView.values,
                  labelBuilder: (view) => switch (view) {
                    NsfwUnlockedView.mixed => texts.nsfwUnlockedViewMixed,
                    NsfwUnlockedView.onlyNsfw => texts.nsfwUnlockedViewOnly,
                  },
                  onChanged: (view) {
                    if (view == null) return;

                    context
                        .read<SettingsBloc>()
                        .add(NsfwUnlockedViewChangedEvent(view));
                    _repaintLibrary();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.nsfwUnlockedViewNote),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                SizedBox(
                  width: AppSizes.settingsLabelWidth,
                  child: Text(
                    texts.nsfwLockedViewLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                FernDropdownPill<NsfwLockedView>(
                  value: settings.nsfwLockedView,
                  items: NsfwLockedView.values,
                  labelBuilder: (view) => switch (view) {
                    NsfwLockedView.hidden => texts.nsfwLockedViewHidden,
                    NsfwLockedView.blurred => texts.nsfwLockedViewBlurred,
                  },
                  onChanged: (view) {
                    if (view == null) return;

                    context
                        .read<SettingsBloc>()
                        .add(NsfwLockedViewChangedEvent(view));
                    _repaintLibrary();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.nsfwLockedViewNote),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // Va con los otros dos y no con la contraseña: los tres contestan a
            // «cómo se comporta», y éste es el que decide **cuánto** abarca una
            // marca antes de que los otros decidan cómo se pinta.
            //
            // Sin `_repaintLibrary` aquí: el bloc ya rehace el índice y manda
            // repintar, porque esto cambia qué está escondido y no sólo cómo se
            // ve. Hacerlo también desde la pantalla lo recargaría dos veces.
            FernCheckboxTile(
              label: texts.nsfwChildTagsLabel,
              description: texts.nsfwChildTagsDescription,
              value: settings.nsfwMarksChildTags,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(NsfwChildTagsToggledEvent(value)),
            ),
          ],
        );
      },
    );
  }

  /// Vuelve a leer lo que haya pintado detrás de los ajustes.
  ///
  /// Estos dos ajustes no cambian el contenido, cambian qué se ve de él, así
  /// que la rejilla de debajo se queda con lo de antes: el usuario cerraría los
  /// ajustes convencido de que no ha pasado nada.
  void _repaintLibrary() {
    getIt<TagsBloc>().add(const LoadTagsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());
  }

  /// Lo mismo que [_note] pero en negrita: para lo que no se puede leer por
  /// encima.
  ///
  /// Se pinta como texto y no como markdown porque aquí no hay quien lo
  /// interprete: los asteriscos de la negrita salían tal cual en pantalla.
  Widget _warning(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
              fontWeight: FontWeight.w700,
            ),
      );

  Widget _note(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.colors.gray),
      );
}
