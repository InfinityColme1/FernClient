import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se llama cada trabajo en pantalla. El dominio sólo guarda el tipo.
extension JobTypeLabels on JobType {
  String label(AppLocalizations texts) => switch (this) {
        JobType.training => texts.jobTraining,
        JobType.recognition => texts.jobRecognition,
        JobType.duplicateScan => texts.jobDuplicateScan,
        JobType.hashing => texts.jobHashing,
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
            icon: const Icon(Icons.sync),
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
      state.active.isEmpty ? Icons.error_outline : Icons.sync,
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

/// Una fila del panel: qué es, por dónde va y el botón de pararlo.
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

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _title(texts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              // El detalle se ofrece esté vivo o terminado: mientras corre ya
              // hay algo que mirar de lo que lleva hecho.
              if (onDetail != null)
                IconButton(
                  tooltip: texts.jobDetailTooltip,
                  iconSize: AppSizes.iconMedium,
                  onPressed: onDetail,
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
              if (job.status.isActive)
                IconButton(
                  tooltip: texts.jobCancelTooltip,
                  iconSize: AppSizes.iconMedium,
                  onPressed: () => context
                      .read<JobsBloc>()
                      .add(CancelJobEvent(job.id)),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (job.status == JobStatus.failed)
            Text(
              texts.jobFailed,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.error),
            )
          else if (job.status == JobStatus.completed)
            Text(
              texts.jobDone,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.unremarked),
            )
          else if (job.status == JobStatus.queued)
            Text(
              texts.jobQueued,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            )
          else ...[
            // Sin total no se sabe cuánto queda, así que la barra da vueltas en
            // lugar de mentir con un porcentaje.
            LinearProgressIndicator(value: job.progress),
            // En qué se está yendo el tiempo ahora mismo: con un árbol de tres
            // modelos, saber cuál está mirando es la diferencia entre una barra
            // que avanza y una que parece colgada.
            if (job.stage case final stage?)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  stage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: context.colors.unremarked),
                ),
              ),
            if (job.total > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  texts.jobProgress(job.done, job.total),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: context.colors.gray),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
