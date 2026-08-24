import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/presentation/blocs/duplicates_bloc.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_detail.dart';
import 'package:Fern/features/duplicates/presentation/widgets/duplicate_comparison.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Contenido repetido: los grupos a la izquierda y la comparación a la derecha.
///
/// La lista y la comparación van juntas en la misma pantalla, y no una detrás de
/// otra, porque revisar duplicados es repetir cuarenta veces la misma decisión:
/// tener que volver a una lista entre grupo y grupo es lo que hace que se
/// abandone a la mitad.
class RepeatedMediaPage extends StatelessWidget {
  const RepeatedMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DuplicatesBloc>(
      create: (_) => DuplicatesBloc(
        repository: getIt<DuplicateRepository>(),
        jobs: getIt(),
        details: getIt(),
        apply: getIt(),
        dismiss: getIt(),
        lastScan: getIt<PreferencesService>().getLastDuplicateScan,
      )..add(const LoadDuplicatesEvent()),
      child: const _RepeatedMediaView(),
    );
  }
}

class _RepeatedMediaView extends StatelessWidget {
  const _RepeatedMediaView();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<DuplicatesBloc, DuplicatesState>(
          // Al pulsar el botón, no al arrancar cualquier escaneo: el de fondo
          // lo lanza la aplicación por su cuenta y tiene que ser callado, y con
          // la condición anterior sacaba este aviso a quien no había pedido
          // nada.
          listenWhen: (before, after) =>
              before.scanRequests != after.scanRequests,
          // El escaneo corre por detrás y puede tardar horas la primera vez:
          // sin decirlo, pulsar el botón parece no hacer nada.
          listener: (context, state) => showFernToast(
            context,
            texts.duplicatesQueued,
            icon: Icons.info_outline,
          ),
        ),
        BlocListener<DuplicatesBloc, DuplicatesState>(
          listenWhen: (before, after) =>
              before.scanResults != after.scanResults,
          // Y el de llegada. Sin él, un escaneo que no encuentra nada termina
          // en silencio y deja la pantalla igual que estaba: nada distingue
          // «he mirado y no hay» de «no ha pasado nada».
          listener: _announceOutcome,
        ),
      ],
      child: BlocBuilder<DuplicatesBloc, DuplicatesState>(
        builder: (context, state) {
          return Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      texts.navRepeatedMedia,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(width: AppSpacing.l),
                    if (!state.isLoading && state.groups.isNotEmpty)
                      Text(
                        texts.duplicatesGroupCount(state.groups.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.unremarked,
                        ),
                      ),
                    const Spacer(),
                    FernPillButton(
                      label: state.isUserScan
                          ? texts.duplicatesScanning
                          : texts.duplicatesScanNow,
                      icon: Icons.travel_explore_outlined,
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.black,
                      onPressed: state.canScan
                          ? () => context.read<DuplicatesBloc>().add(
                              const ScanForDuplicatesEvent(),
                            )
                          : null,
                    ),
                  ],
                ),
                // Mientras dura, aquí y no sólo en la cola de arriba: quien
                // acaba de pulsar el botón está mirando esta pantalla, y un
                // aviso que se va a los tres segundos no acompaña a un trabajo
                // que puede durar horas.
                if (state.isUserScan) _ScanProgress(state: state),
                const SizedBox(height: AppSpacing.l),
                Expanded(child: _body(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Dice en qué ha quedado el escaneo que se pidió con el botón.
  ///
  /// Los cinco finales se dicen distinto a propósito: «no hay repetidos» y «no
  /// se ha podido terminar» dejan la pantalla igual de vacía, y confundirlos es
  /// dar por limpia una biblioteca que no se ha llegado a mirar.
  void _announceOutcome(BuildContext context, DuplicatesState state) {
    final texts = AppLocalizations.of(context);

    final outcome = state.outcome;
    if (outcome == null) return;

    final (String message, IconData icon) = switch (outcome) {
      DuplicateScanOutcome.found => (
          texts.duplicatesScanFound(state.freshGroups),
          Icons.done_all_outlined,
        ),
      DuplicateScanOutcome.nothingNew => (
          texts.duplicatesScanNothingNew(state.groups.length),
          Icons.done_outlined,
        ),
      DuplicateScanOutcome.clean => (
          texts.duplicatesScanClean,
          Icons.done_outlined,
        ),
      DuplicateScanOutcome.cancelled => (
          texts.duplicatesScanStopped,
          Icons.info_outline,
        ),
      DuplicateScanOutcome.failed => (
          texts.duplicatesScanFailed,
          Icons.error_outline,
        ),
    };

    showFernToast(context, message, icon: icon);
  }

  Widget _body(BuildContext context, DuplicatesState state) {
    final texts = AppLocalizations.of(context);

    // A lo ancho de la pantalla, no de lo que ocupe el texto. La columna de
    // arriba alinea a la izquierda para el título, y sin esto lo que hay dentro
    // se encoge a su contenido y se queda pegado a ese borde: la ilustración y
    // el mensaje aparecían en la esquina de una pantalla por lo demás vacía.
    if (state.isLoading) {
      return const SizedBox(
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.groups.isEmpty) {
      // Con la fecha del último escaneo delante, y distinto según la haya o no:
      // «no hay contenido repetido» sin haber mirado nunca es una respuesta
      // inventada, y es justo lo que veía quien acababa de instalar.
      final last = state.lastScan;

      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FernEmptyState(
              imageAsset: fernEmptyImage,
              message: last == null
                  ? texts.duplicatesNeverScanned
                  : texts.duplicatesNone,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              last == null
                  ? texts.duplicatesNeverScannedHint
                  : texts.duplicatesNoneHint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: context.colors.unremarked),
            ),
            // Lo que de verdad contesta a «¿ha hecho algo el botón?»: el aviso
            // se va solo a los pocos segundos, y esto se queda.
            if (last != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                texts.duplicatesLastScan(_whenLabel(context, last)),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: context.colors.gray),
              ),
            ],
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: duplicateGroupListWidth,
          child: _GroupList(state: state),
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(child: _ComparisonPane(state: state)),
      ],
    );
  }
}

/// Cuándo pasó algo, en el idioma que esté puesto.
String _whenLabel(BuildContext context, DateTime at) => DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    ).add_Hm().format(at);

/// Por dónde va el escaneo que se ha pedido con el botón.
///
/// La barra da vueltas mientras no se sepa cuántas huellas hay que calcular:
/// contarlas es lo primero que hace el escaneo, y un porcentaje inventado
/// durante ese rato es peor que no dar ninguno.
class _ScanProgress extends StatelessWidget {
  final DuplicatesState state;

  const _ScanProgress({required this.state});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                texts.duplicatesScanning,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: context.colors.unremarked),
              ),
              if (state.scanTotal > 0) ...[
                const SizedBox(width: AppSpacing.s),
                Text(
                  texts.jobProgress(state.scanDone, state.scanTotal),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: context.colors.gray),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(value: state.scanProgress),
        ],
      ),
    );
  }
}

/// Lo que mide la columna de grupos.
///
/// Fija y estrecha: lo que hay que mirar es la comparación, y la lista sólo está
/// para saber cuánto queda y poder saltar.
const double duplicateGroupListWidth = 220;

class _GroupList extends StatelessWidget {
  final DuplicatesState state;

  const _GroupList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: state.groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (context, index) {
        final group = state.groups[index];

        return _GroupRow(
          group: group,
          isSelected: group.id == state.selectedGroupId,
          onTap: () => context.read<DuplicatesBloc>().add(
                SelectDuplicateGroupEvent(group.id),
              ),
        );
      },
    );
  }
}

/// Un grupo: cuántas copias y lo lejos que están entre sí.
class _GroupRow extends StatelessWidget {
  final DuplicateGroupSummary group;
  final bool isSelected;
  final VoidCallback? onTap;

  const _GroupRow({
    required this.group,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.colors;

    return FernSurface(
      color: isSelected ? colors.primary.withValues(alpha: 0.18) : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_none_outlined,
                    size: AppSizes.iconSmall,
                    color: colors.unremarked,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      // Copias, no grupos: lo que hay en esta fila son las veces
                      // que el mismo contenido está repetido.
                      texts.duplicatesCopyCount(group.mediaIds.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                // Cero no es «distancia cero», es idéntico. Decirlo con la
                // palabra ahorra tener que saber qué mide el número.
                group.maxDistance == 0
                    ? texts.duplicatesIdentical
                    : texts.duplicatesDistance(group.maxDistance),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: group.maxDistance == 0
                      ? colors.terciary
                      : colors.unremarked,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El grupo abierto: las copias, la fusión y los dos botones que lo resuelven.
class _ComparisonPane extends StatelessWidget {
  final DuplicatesState state;

  const _ComparisonPane({required this.state});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bloc = context.read<DuplicatesBloc>();
    final group = state.selectedGroup;

    if (group == null) {
      return Center(
        child: Text(
          texts.duplicatesPickGroup,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.unremarked,
          ),
        ),
      );
    }

    if (state.isLoadingGroup) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              texts.duplicatesGroupPosition(
                state.selectedPosition,
                state.groups.length,
              ),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: AppSpacing.m),
            Text(
              group.maxDistance == 0
                  ? texts.duplicatesIdentical
                  : texts.duplicatesDistance(group.maxDistance),
              style: theme.textTheme.labelMedium?.copyWith(
                color: group.maxDistance == 0
                    ? context.colors.terciary
                    : context.colors.unremarked,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: DuplicateComparison(
            copies: state.copies,
            keeperId: state.keeperId,
            onKeep: state.isApplying
                ? null
                : (mediaId) => bloc.add(ChooseDuplicateKeeperEvent(mediaId)),
            onOpen: state.isApplying ? null : (copy) => _openInViewer(context, copy),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        FernCheckboxTile(
          label: texts.duplicatesMergeMetadata,
          description: texts.duplicatesMergeMetadataHint,
          value: state.mergeMetadata,
          onChanged: state.isApplying
              ? null
              : (value) => bloc.add(ToggleDuplicateMergeEvent(value)),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            FernPillButton(
              label: texts.duplicatesNotDuplicates,
              icon: Icons.block_outlined,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: state.isApplying
                  ? null
                  : () => bloc.add(const DismissCurrentGroupEvent()),
            ),
            const Spacer(),
            FernPillButton(
              label: texts.duplicatesApplyAndNext,
              icon: Icons.done_all_outlined,
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.black,
              onPressed: state.canApply
                  ? () => bloc.add(const ApplyDuplicateGroupEvent())
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Abre una copia en el visor de siempre, encima de esta pantalla.
///
/// Va por el `MediaBloc` como el resto de la aplicación: es quien lee los
/// detalles y quien el visor consulta. Al no estar la copia en su lista, las
/// flechas del visor no llevan a ninguna parte —el bloc ya lo contempla— y eso
/// es lo que se quiere: aquí se ha venido a mirar **esta**, y pasar a la
/// siguiente de otra lista sería perder el grupo que se estaba comparando.
void _openInViewer(BuildContext context, DuplicateCopy copy) {
  getIt<MediaBloc>().add(
    MediaClickedEvent(
      media: MediaSummaryEntity(
        id: copy.media.id,
        path: copy.media.path,
        isImported: copy.media.isImported,
      ),
    ),
  );

  context.push(viewerRoute);
}
