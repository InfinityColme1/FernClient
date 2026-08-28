import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_failure.dart';
import 'package:Fern/features/recognition/domain/services/training_metrics.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Qué tal salió el último entrenamiento, y qué tal va de verdad.
///
/// Son dos bloques a propósito, y el segundo es el que importa: las métricas del
/// entrenamiento dicen lo bien que el modelo se sabe **su propio material**, y
/// eso puede salir estupendo con un modelo que luego no acierta nada. El
/// rendimiento real —cuántas sugerencias se aceptan y cuántas se rechazan— es la
/// única medida honesta, y llega con la fase 5.
///
/// Mientras tanto el bloque de la derecha dice que aún no hay datos, en vez de
/// no existir: que falte se entiende, y que no esté hace pensar que no se mide.
class MetricsPanel extends StatelessWidget {
  final RecognitionModelEntity model;

  /// Abrir la carpeta de la run en el explorador del sistema.
  ///
  /// Va por parámetro porque abrir carpetas es cosa del sistema operativo y este
  /// widget no tiene por qué saber de eso.
  final ValueChanged<String>? onOpenFolder;

  /// Enseñar las imágenes que dejó ultralytics.
  final void Function(String directory, RunImageKind kind)? onShowImages;

  /// Volver a intentarlo cuando el último entrenamiento falló.
  final VoidCallback? onRetry;

  const MetricsPanel({
    super.key,
    required this.model,
    this.onOpenFolder,
    this.onShowImages,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final metrics = TrainingMetrics.parse(model.lastMetrics);

    // Sin desplazamiento propio: el panel ocupa lo que ocupe y la que se
    // desplaza es la página. Dos barras anidadas para un bloque que casi siempre
    // cabe entero es la peor de las dos opciones.
    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _lastTraining(context, texts, metrics)),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: 2, child: _realPerformance(context, texts)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // El último entrenamiento
  // ---------------------------------------------------------------------------

  Widget _lastTraining(
    BuildContext context,
    AppLocalizations texts,
    TrainingMetrics? metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts.metricsLastTraining,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.m),
        if (model.lastError != null)
          _failure(context, texts)
        else if (metrics == null || metrics.isEmpty)
          _noMetrics(context, texts)
        else ...[
          _bar(context, texts.metricMap50, metrics.map50),
          _bar(context, texts.metricMap50to95, metrics.map50to95),
          _bar(context, texts.metricPrecision, metrics.precision),
          _bar(context, texts.metricRecall, metrics.recall),
          if (metrics.perClass.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            _perClass(context, texts, metrics),
          ],
        ],
        if (metrics?.curvesDirectory != null) ...[
          const SizedBox(height: AppSpacing.m),
          _runActions(context, texts, metrics!.curvesDirectory!),
        ],
      ],
    );
  }

  /// Una métrica, con su barra.
  ///
  /// La barra está porque un `0,83` suelto no dice si es bueno; al lado de otras
  /// tres barras, se ve de un vistazo cuál cojea. Todas van de cero a uno, que es
  /// el rango real de estas cuatro cifras.
  Widget _bar(BuildContext context, String label, double? value) {
    if (value == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final fraction = value.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.metricLabelWidth,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          SizedBox(
            width: AppSizes.metricValueWidth,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: AppSizes.metricBarHeight,
                backgroundColor: context.colors.lightgray,
                // El acento y no el primario: el primario es el lavanda con el
                // que están pintadas las propias superficies, y una barra de ese
                // color sobre una de ellas parece vacía.
                color: fraction < weakClassThreshold
                    ? context.colors.error
                    : context.colors.terciary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// El acierto de cada clase, con aviso en las que cojean.
  ///
  /// Es la parte que dice **cuál** de los fernies ha salido mal. Una media de
  /// 0,80 con un fernie a 0,20 se ve estupenda y falla justo con ése.
  Widget _perClass(
    BuildContext context,
    AppLocalizations texts,
    TrainingMetrics metrics,
  ) {
    final theme = Theme.of(context);
    final entries = metrics.perClass.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts.metricsPerClass,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: context.colors.unremarked),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: [
            for (final entry in entries)
              FernChip(
                label: '${entry.key} ${entry.value.toStringAsFixed(2)}',
                leading: entry.value < weakClassThreshold
                    ? Icon(
                        Symbols.warning_amber,
                        size: AppSizes.iconSmall,
                        color: context.colors.error,
                      )
                    : null,
                labelColor: entry.value < weakClassThreshold
                    ? context.colors.error
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  /// Los botones de la run: las imágenes que dejó ultralytics y la carpeta.
  ///
  /// La matriz de confusión y las curvas las dibuja ultralytics en PNG. No hace
  /// falta redibujarlas: enseñarlas es más fiel, y así se ven exactamente las
  /// mismas que si se mirara la carpeta a mano.
  Widget _runActions(
    BuildContext context,
    AppLocalizations texts,
    String directory,
  ) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        FernPillButton(
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.black,
          label: texts.metricsConfusionMatrix,
          icon: Symbols.grid_on,
          onPressed: onShowImages == null
              ? null
              : () => onShowImages!(directory, RunImageKind.confusion),
        ),
        FernPillButton(
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.black,
          label: texts.metricsCurves,
          icon: Symbols.show_chart,
          onPressed: onShowImages == null
              ? null
              : () => onShowImages!(directory, RunImageKind.curves),
        ),
        FernPillButton(
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.black,
          label: texts.metricsOpenRunFolder,
          icon: Symbols.folder_open,
          onPressed:
              onOpenFolder == null ? null : () => onOpenFolder!(directory),
        ),
      ],
    );
  }

  /// Qué se rompió, y volver a intentarlo.
  ///
  /// Se guarda en el modelo y no en la cola porque la cola se vacía: al día
  /// siguiente la pantalla tiene que poder decir todavía qué pasó.
  Widget _failure(BuildContext context, AppLocalizations texts) {
    final failure = TrainingFailure.from(model.lastError!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.error,
              size: AppSizes.iconSmall,
              color: context.colors.error,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                _failureText(failure, texts),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.colors.error),
              ),
            ),
          ],
        ),
        // El detalle técnico sólo cuando la frase no dice nada: en los casos
        // conocidos ya está dicho qué hacer, y añadir la traza sólo asusta.
        if (failure.showsDetail) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            failure.detail,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.s),
          FernPillButton(
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            label: texts.metricsRetry,
            icon: Symbols.refresh,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }

  /// Qué se le dice al usuario, que no es lo que dijo el sidecar.
  ///
  /// Lo que importa de un fallo no es su código: es **qué hacer ahora**. Un
  /// «SidecarException(SIDECAR_NOT_READY)» no se lo dice a nadie.
  String _failureText(TrainingFailure failure, AppLocalizations texts) {
    return switch (failure.kind) {
      TrainingFailureKind.engineStopped => texts.trainingFailedEngineStopped,
      TrainingFailureKind.outOfMemory => texts.trainingFailedOutOfMemory,
      TrainingFailureKind.datasetInvalid => texts.trainingFailedDataset,
      TrainingFailureKind.weightsMissing => texts.trainingFailedWeights,
      TrainingFailureKind.notEnoughSpace => texts.trainingFailedNoSpace,
      TrainingFailureKind.unknown => texts.trainingFailedUnknown,
    };
  }

  Widget _noMetrics(BuildContext context, AppLocalizations texts) {
    return Text(
      model.isImportedWeights
          ? texts.metricsImportedWeights
          : texts.metricsNotTrainedYet,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: context.colors.unremarked),
    );
  }

  // ---------------------------------------------------------------------------
  // El rendimiento real
  // ---------------------------------------------------------------------------

  /// Lo que el modelo acierta **usándolo**, que llega con la fase 5.
  ///
  /// Está vacío y a la vista a propósito: es la medida que de verdad dice si el
  /// modelo sirve, y esconderla hasta que exista haría pensar que no se mide.
  Widget _realPerformance(BuildContext context, AppLocalizations texts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.metricsRealPerformance, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.m),
        Text(
          texts.metricsRealPerformanceEmpty,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: context.colors.unremarked),
        ),
      ],
    );
  }
}

/// Cuál de las imágenes de la run se quiere ver.
enum RunImageKind { confusion, curves }
