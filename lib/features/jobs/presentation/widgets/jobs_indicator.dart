import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se llama cada trabajo en pantalla. El dominio sólo guarda el tipo.
extension JobTypeLabels on JobType {
  String label(AppLocalizations texts) => switch (this) {
        JobType.training => texts.jobTraining,
        JobType.recognition => texts.jobRecognition,
        JobType.duplicateScan => texts.jobDuplicateScan,
        JobType.hashing => texts.jobHashing,
        JobType.mediaImport => texts.jobImport,
        JobType.linkReview => texts.jobLinkReview,
        JobType.linkImport => texts.jobLinkImport,
        JobType.tagRegions => texts.jobTagRegions,
        JobType.fileCleanup => texts.jobFileCleanup,
      };

  /// Con qué se reconoce cada clase de trabajo en la lista.
  ///
  /// Hace falta porque con tres o cuatro en marcha las filas eran cuatro líneas
  /// de texto parecidas y había que leerlas enteras para saber cuál era cuál.
  /// El icono se ve antes de leer.
  IconData get icon => switch (this) {
        JobType.training => Symbols.model_training,
        JobType.recognition => Symbols.auto_awesome,
        JobType.duplicateScan => Symbols.travel_explore,
        JobType.hashing => Symbols.fingerprint,
        JobType.mediaImport => Symbols.move_to_inbox,
        JobType.linkReview => Symbols.help,
        JobType.linkImport => Symbols.link,
        JobType.tagRegions => Symbols.select_all,
        JobType.fileCleanup => Symbols.delete_sweep,
      };
}

/// Lo que hay en marcha por detrás, en la barra superior.
///
/// Está siempre, y **apagado mientras no haya nada**. Aparecer y desaparecer
/// movía los botones de al lado justo cuando se iba a pulsar uno; en gris ocupa
/// su sitio y de paso dice que no hay nada corriendo, que es información.
///
/// Al pulsarlo se despliega la lista con lo que lleva cada trabajo y un botón
/// para pararlo.
class JobsIndicator extends StatelessWidget {
  /// Si de este trabajo hay algo más que enseñar.
  ///
  /// Llega por parámetro para que esto no tenga que saber de reconocimiento: la
  /// lista de tareas es de la aplicación entera, y bastaría un caso especial por
  /// tipo de trabajo para que acabara importando media aplicación.
  final bool Function(Job job)? hasDetail;

  /// Qué hacer al pedir ese detalle.
  final void Function(BuildContext context, Job job)? onDetail;

  const JobsIndicator({super.key, this.hasDetail, this.onDetail});

  /// Los trabajos terminados que tienen algo que enseñar.
  List<Job> _finishedWithDetail(JobsState state) {
    final has = hasDetail;
    if (has == null) return const [];

    return [for (final job in state.completed) if (has(job)) job];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        final texts = AppLocalizations.of(context);
        final finished = _finishedWithDetail(state);
        final visible = [...state.active, ...state.failed, ...finished];

        if (visible.isEmpty) {
          return IconButton(
            tooltip: texts.jobsNone,
            // Sin nada que enseñar no se abre: un panel que sólo dice «no hay
            // nada» es un clic tirado.
            onPressed: null,
            icon: const Icon(Symbols.sync),
          );
        }

        return FernPopupPanel(
          width: AppSizes.jobsPanelWidth,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.l,
            horizontal: AppSpacing.l,
          ),
          builder: (context, toggle) => IconButton(
            tooltip: texts.jobsTooltip,
            onPressed: toggle,
            icon: _icon(context, state),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Text(
                texts.jobsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final job in visible)
              _JobRow(
                job: job,
                onDetail: hasDetail?.call(job) == true && onDetail != null
                    ? () => onDetail!(context, job)
                    : null,
              ),
            if (finished.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context
                      .read<JobsBloc>()
                      .add(const ClearFinishedJobsEvent()),
                  child: Text(texts.jobsClearFinished),
                ),
              ),
          ],
        );
      },
    );
  }

  /// El icono lleva encima cuántos trabajos hay vivos: con uno solo no hace
  /// falta decir nada, con varios sí.
  Widget _icon(BuildContext context, JobsState state) {
    final count = state.active.length;
    final icon = Icon(
      state.active.isEmpty ? Symbols.error : Symbols.sync,
      color: state.active.isEmpty ? context.colors.error : null,
    );

    if (count < 2) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -AppSpacing.xs,
          top: -AppSpacing.xs,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: context.colors.terciary,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              '$count',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una fila del panel, con la forma de un gestor de descargas.
///
/// Icono a la izquierda, nombre arriba y estado debajo en pequeño, acciones a la
/// derecha. Antes era todo texto apilado: con tres trabajos en marcha había que
/// leer cuatro líneas parecidas para saber cuál era cuál, y el «terminada» caía
/// tan abajo que parecía de la fila siguiente.
class _JobRow extends StatelessWidget {
  final Job job;

  /// Qué hacer al pedir el detalle, si este trabajo tiene alguno.
  final VoidCallback? onDetail;

  const _JobRow({required this.job, this.onDetail});

  /// Cómo se llama esto en la lista.
  ///
  /// Cuando el trabajo dice sobre qué va, se dice: se pueden encolar varios del
  /// mismo tipo, y «Entrenando modelo» tres veces seguidas no distingue cuál se
  /// está parando al pulsar el aspa.
  String _title(AppLocalizations texts) {
    final name = job.name;
    if (name == null) return job.type.label(texts);

    return switch (job.type) {
      JobType.training => texts.jobTrainingModel(name),
      _ => '${job.type.label(texts)} · $name',
    };
  }

  /// La línea de debajo del nombre: en qué punto está.
  ///
  /// Una sola línea siempre, terminado o no. Antes el estado y el avance eran
  /// bloques distintos de alto distinto, y la lista se movía sola al cambiar
  /// cualquiera de ellos.
  /// La línea de debajo del nombre: en qué punto está.
  ///
  /// Cuando ha fallado se dice **por qué** y no sólo que ha fallado. Un trabajo
  /// en rojo que no cuenta nada obliga a mirar la consola para enterarse, y a la
  /// consola no llega el usuario.
  String _status(AppLocalizations texts) => switch (job.status) {
        JobStatus.failed => job.error ?? texts.jobFailed,
        JobStatus.completed => texts.jobDone,
        JobStatus.cancelled => texts.jobCancelled,
        JobStatus.queued => texts.jobQueued,
        JobStatus.running => job.total > 0
            ? texts.jobProgress(job.done, job.total)
            : job.stage ?? texts.jobRunning,
      };

  Color _statusColor(BuildContext context) => switch (job.status) {
        JobStatus.failed => context.colors.error,
        JobStatus.completed => context.colors.terciary,
        _ => context.colors.unremarked,
      };

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            job.type.icon,
            size: AppSizes.iconMedium,
            color: job.status == JobStatus.failed
                ? context.colors.error
                : context.colors.gray,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title(texts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xxs),
                // Con el motivo entero al pasar por encima: en una línea de
                // panel no cabe una traza, pero recortarla sin dejar forma de
                // leerla es volver a esconderla.
                Tooltip(
                  message: _status(texts),
                  child: Text(
                    _status(texts),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: _statusColor(context)),
                  ),
                ),
                // La barra sólo mientras corre, y pegada a su texto. Sin total
                // da vueltas en vez de mentir con un porcentaje.
                if (job.status == JobStatus.running) ...[
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(value: job.progress),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          // El detalle se ofrece esté vivo o terminado: mientras corre ya hay
          // algo que mirar de lo que lleva hecho.
          if (onDetail != null)
            IconButton(
              // El icono y lo que dice cambian con lo que hay detrás: un parte
              // de lo que hicieron los modelos y una pregunta sin contestar no
              // son lo mismo, y con el mismo icono la segunda parecía lo
              // primero.
              tooltip: job.type == JobType.linkReview
                  ? texts.jobReviewTooltip
                  : texts.jobDetailTooltip,
              iconSize: AppSizes.iconMedium,
              onPressed: onDetail,
              icon: Icon(
                job.type == JobType.linkReview
                    ? Symbols.rule
                    : Symbols.receipt_long,
              ),
            ),
          // Vivo se para; terminado se quita de la lista. Nunca las dos a la
          // vez, y ya no son el mismo dibujo: `close` y `clear` son el mismo
          // glifo, así que dos botones que hacen cosas distintas —uno interrumpe
          // trabajo, el otro sólo ordena la lista— se veían idénticos.
          if (job.status.isActive)
            IconButton(
              tooltip: texts.jobCancelTooltip,
              iconSize: AppSizes.iconMedium,
              onPressed: () =>
                  context.read<JobsBloc>().add(CancelJobEvent(job.id)),
              icon: const Icon(Symbols.stop_circle),
            )
          else
            IconButton(
              tooltip: texts.jobDismissTooltip,
              iconSize: AppSizes.iconMedium,
              onPressed: () =>
                  context.read<JobsBloc>().add(DismissJobEvent(job.id)),
              icon: const Icon(Symbols.close),
            ),
        ],
      ),
    );
  }
}
