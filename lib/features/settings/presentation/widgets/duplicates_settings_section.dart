import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/duplicates/domain/usecases/rehash_library_usecase.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Ajustes del contenido repetido: cada cuánto se busca solo, con qué listón se
/// agrupa y por dónde se empieza de cero.
///
/// El listón vive aquí y no en la propia pantalla de repetidos a propósito: se
/// toca una vez y se olvida, y en la cabecera de la pantalla sería un mando
/// grande al lado del botón de buscar, invitando a moverlo entre grupo y grupo
/// cuando lo que hace es rehacer el criterio del escaneo siguiente.
class DuplicatesSettingsSection extends StatefulWidget {
  const DuplicatesSettingsSection({super.key});

  @override
  State<DuplicatesSettingsSection> createState() =>
      _DuplicatesSettingsSectionState();
}

class _DuplicatesSettingsSectionState extends State<DuplicatesSettingsSection> {
  bool _isRehashing = false;

  /// Lo que ha dado el último borrado de huellas, para poder decirlo. Nulo
  /// mientras no se haya pulsado nada.
  String? _rehashResult;

  String _periodLabel(DuplicateScanPeriod period, AppLocalizations texts) =>
      switch (period) {
        DuplicateScanPeriod.monthly => texts.duplicatesPeriodMonthly,
        DuplicateScanPeriod.quarterly => texts.duplicatesPeriodQuarterly,
        DuplicateScanPeriod.biannual => texts.duplicatesPeriodBiannual,
        DuplicateScanPeriod.yearly => texts.duplicatesPeriodYearly,
      };

  /// Cuándo se miró por última vez. Es lo que da sentido al periodo: sin ello,
  /// «cada tres meses» no dice si el próximo es mañana o dentro de un trimestre.
  String _lastScanLabel(AppLocalizations texts) {
    final last = getIt<PreferencesService>().getLastDuplicateScan();
    if (last == null) return texts.duplicatesLastScanNever;

    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    ).add_Hm().format(last);

    return texts.duplicatesLastScan(date);
  }

  /// Tira las huellas. No encola el escaneo detrás: quien pulsa esto está
  /// arreglando algo, y arrancarle sin avisar un trabajo de horas es lo
  /// contrario de lo que espera. La pantalla de repetidos tiene su botón.
  Future<void> _rehash(AppLocalizations texts) async {
    setState(() {
      _isRehashing = true;
      _rehashResult = null;
    });

    final result = await getIt<RehashLibraryUseCase>()();
    if (!mounted) return;

    setState(() {
      _isRehashing = false;
      _rehashResult = result is DataSuccess
          ? texts.duplicatesRehashDone(result.data ?? 0)
          : texts.duplicatesRehashFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(theme, texts.duplicatesScanSectionTitle),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.duplicatesScanSectionNote),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.duplicatesAutoScanLabel,
              description: texts.duplicatesAutoScanDescription,
              value: settings.automaticDuplicateScan,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(AutomaticDuplicateScanToggledEvent(value)),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                SizedBox(
                  width: AppSizes.settingsLabelWidth,
                  child: Text(
                    texts.duplicatesScanPeriodLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                FernDropdownPill<DuplicateScanPeriod>(
                  value: settings.duplicateScanPeriod,
                  items: DuplicateScanPeriod.values,
                  labelBuilder: (period) => _periodLabel(period, texts),
                  // Apagado el automático, el periodo no gobierna nada. Dejarlo
                  // vivo invita a ajustar algo que no va a pasar.
                  onChanged: settings.automaticDuplicateScan
                      ? (period) {
                          if (period == null) return;

                          context
                              .read<SettingsBloc>()
                              .add(DuplicateScanPeriodChangedEvent(period));
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _note(context, _lastScanLabel(texts)),
            const SizedBox(height: AppSpacing.l),
            // Debajo del periodo y no arriba del todo: esto no decide si se
            // busca, decide qué se mira cuando se busque. Y vale para los dos
            // escaneos, el automático y el del botón.
            FernCheckboxTile(
              label: texts.duplicatesMovingLabel,
              description: texts.duplicatesMovingDescription,
              value: settings.duplicateScanIncludesMoving,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(DuplicateScanMovingToggledEvent(value)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            _title(theme, texts.duplicatesThresholdSectionTitle),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.duplicatesThresholdSectionNote),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                SizedBox(
                  width: AppSizes.settingsLabelWidth,
                  child: Text(
                    texts.duplicatesThresholdLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings.duplicateThreshold
                        .clamp(0, maxDuplicateThreshold)
                        .toDouble(),
                    max: maxDuplicateThreshold.toDouble(),
                    divisions: maxDuplicateThreshold,
                    onChanged: (value) => context
                        .read<SettingsBloc>()
                        .add(DuplicateThresholdChangedEvent(value.round())),
                  ),
                ),
                SizedBox(
                  width: AppSizes.settingsValueWidth,
                  child: Text(
                    '${settings.duplicateThreshold}',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.gray),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            _title(theme, texts.duplicatesRehashSectionTitle),
            const SizedBox(height: AppSpacing.s),
            _note(context, texts.duplicatesRehashSectionNote),
            const SizedBox(height: AppSpacing.l),
            FernActionButton(
              label: _isRehashing
                  ? texts.duplicatesRehashRunning
                  : texts.duplicatesRehashButton,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: _isRehashing ? null : () => _rehash(texts),
            ),
            if (_rehashResult case final result?) ...[
              const SizedBox(height: AppSpacing.m),
              _note(context, result),
            ],
          ],
        );
      },
    );
  }

  Widget _title(ThemeData theme, String text) =>
      Text(text, style: theme.textTheme.titleMedium);

  Widget _note(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.colors.gray),
      );
}
