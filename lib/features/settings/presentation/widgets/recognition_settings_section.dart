import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/presentation/widgets/sidecar_setup_panel.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/settings/presentation/settings_status_labels.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/recognition/data/services/region_merge_overlaps.dart';

/// Ajustes del reconocimiento de contenido.
///
/// De momento sólo dice dónde vive todo (el entorno de entrenamiento, los
/// modelos y los conjuntos de datos), que es lo que hay que decidir antes de
/// que empiece a ocupar sitio. El estado del entorno de Python y los ajustes de
/// reconocimiento automático se añaden aquí cuando existan.
class RecognitionSettingsSection extends StatelessWidget {
  const RecognitionSettingsSection({super.key});

  /// Abre el explorador y avisa al bloc con la carpeta elegida. Si el usuario
  /// cancela no se toca nada.
  Future<void> _pickDirectory(BuildContext context) async {
    final directory = await FilePicker.getDirectoryPath();
    if (directory == null || !context.mounted) return;

    context.read<SettingsBloc>().add(RecognitionDirectoryChangedEvent(directory));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, texts.recognitionFolderTitle),
            _description(context, texts.recognitionFolderDescription),
            const SizedBox(height: AppSpacing.l),
            FernDirectoryField(
              label: texts.recognitionFolder,
              path: state.settings.recognitionPath,
              onPressed:
                  state.isWorking ? null : () => _pickDirectory(context),
            ),
            const SizedBox(height: AppSpacing.l),
            // Mover esto puede tardar: son los modelos y el entorno entero, no
            // un puñado de avatares.
            if (state.isWorking)
              const SizedBox(
                width: AppSizes.iconMedium,
                height: AppSizes.iconMedium,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (state.lastResult case final result?
                when result.status.isRecognition)
              Text(
                result.message(texts),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colors.gray),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // El entorno, **justo detrás de la carpeta en la que se instala**.
            //
            // Es lo primero que hace falta: sin él no reconoce nada, y los tres
            // ajustes de abajo no significan nada. Estaba el último, así que el
            // botón de instalarlo —lo único imprescindible de esta pantalla—
            // quedaba a tres pantallazos de desplazamiento del sitio donde se
            // elige dónde instalarlo.
            const SidecarSetupPanel(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // Reconocer solo lo que llega. Va antes de lo de después de
            // reconocer porque es lo primero que pasa, y leerlo en ese orden es
            // lo que hace que se entienda por qué el contenido se mueve.
            FernCheckboxTile(
              label: texts.recognizeOnImportLabel,
              description: texts.recognizeOnImportDescription,
              value: state.settings.recognizeOnImport,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(RecognizeOnImportToggledEvent(value)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // Lo que pasa **después** de reconocer, que es lo que más sorprende
            // de esta función: el contenido desaparece de la biblioteca sin que
            // nada lo explique si no se sabe que esto existe.
            FernCheckboxTile(
              label: texts.returnRecognizedLabel,
              description: texts.returnRecognizedDescription,
              value: state.settings.returnRecognizedToImport,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(ReturnRecognizedToggledEvent(value)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // Cuántas veces se guarda lo mismo en un contenido. Un modelo puede
            // ver cuatro coches en una foto, y las cuatro detecciones valen
            // porque cada una es una región distinta que se puede marcar.
            _title(context, texts.maxDetectionsLabel),
            Text(
              texts.maxDetectionsDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.gray,
                  ),
            ),
            const SizedBox(height: AppSpacing.m),
            FernDropdownPill<int>(
              value: state.settings.maxDetectionsPerClass,
              items: maxDetectionsPerClassOptions,
              labelBuilder: (value) => '$value',
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(MaxDetectionsChangedEvent(
                    value ?? defaultMaxDetectionsPerClass,
                  )),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(),
            ),
            // Y justo detrás, qué se hace con esas veces cuando caen unas
            // encima de otras: es la otra mitad de la misma pregunta.
            _title(context, texts.regionMergeOverlapLabel),
            Text(
              texts.regionMergeOverlapDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.gray,
                  ),
            ),
            const SizedBox(height: AppSpacing.m),
            FernDropdownPill<int>(
              value: state.settings.regionMergeOverlap,
              items: regionMergeOverlapOptions,
              labelBuilder: (value) => value >= 100
                  ? texts.regionMergeOverlapInside
                  : texts.regionMergeOverlapPercent(value),
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(RegionMergeOverlapChangedEvent(
                    value ?? defaultRegionMergeOverlap,
                  )),
            ),
            const SizedBox(height: AppSpacing.m),
            // Lo que cada fernie haya dicho manda sobre esto: se cuenta cuántos,
            // y se ofrece quitarlo para que todos usen este valor.
            ListenableBuilder(
              listenable: getIt<RegionMergeOverlaps>(),
              builder: (context, _) {
                final overlaps = getIt<RegionMergeOverlaps>();
                final overriding = overlaps.overrideCount;

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        texts.regionMergeOverrideCount(overriding),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.unremarked,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    FernPillButton(
                      label: texts.regionMergeApplyAll,
                      icon: Symbols.done_all,
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.black,
                      onPressed: overriding == 0
                          ? null
                          : () async {
                              await overlaps.clearOverrides();
                              if (!context.mounted) return;

                              showFernToast(
                                context,
                                texts.regionMergeAppliedAll,
                                icon: Symbols.done_all,
                              );
                            },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
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
          ?.copyWith(color: context.colors.gray),
    );
  }
}
