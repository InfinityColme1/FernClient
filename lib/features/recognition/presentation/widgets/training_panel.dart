import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_checks.dart';
import 'package:Fern/features/recognition/domain/services/training_presets.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Con qué esmero se entrena, qué falta para poder hacerlo, y el botón.
///
/// El bloque cambia de cara según el estado: parado enseña los presets y el
/// botón; en marcha, por dónde va y cómo pararlo. Son el mismo sitio de la
/// pantalla porque son el mismo asunto.
///
/// Va **a lo ancho y a la altura que necesite**: los tres presets uno al lado
/// del otro y el botón a la derecha. En una columna estrecha ocupaban tanto que
/// sólo se veía un preset y había que desplazar dentro del panel para elegir,
/// que es justo la decisión que se viene a tomar aquí.
class TrainingPanel extends StatefulWidget {
  final RecognitionModelEntity model;
  final List<ModelFernieEntity> fernies;

  /// Si el motor de reconocimiento está instalado y listo.
  final bool isEngineReady;

  /// El trabajo en marcha, si lo hay.
  final Job? job;

  /// Los mandos han cambiado y hay que guardarlos.
  final ValueChanged<RecognitionModelEntity>? onSettingsChanged;

  final VoidCallback? onTrain;
  final VoidCallback? onCancel;

  const TrainingPanel({
    super.key,
    required this.model,
    required this.fernies,
    required this.isEngineReady,
    this.job,
    this.onSettingsChanged,
    this.onTrain,
    this.onCancel,
  });

  @override
  State<TrainingPanel> createState() => _TrainingPanelState();
}

class _TrainingPanelState extends State<TrainingPanel> {
  /// Los mandos de dentro, plegados de fábrica.
  ///
  /// Quien los necesita sabe buscarlos; a quien no, verlos abiertos le dice que
  /// hay algo que decidir cuando no lo hay.
  bool _isAdvancedOpen = false;

  /// Cuál de los presets está puesto, o `custom` si los mandos no coinciden con
  /// ninguno.
  TrainingPreset get _preset {
    for (final preset in TrainingPreset.values) {
      if (matchesPreset(widget.model, preset)) return preset;
    }

    return TrainingPreset.custom;
  }

  void _applyPreset(TrainingPreset preset) {
    final settings = settingsFor(
      preset: preset,
      function: widget.model.effectiveFunction,
    );

    widget.onSettingsChanged?.call(widget.model.copyWith(
      preset: preset,
      backbone: settings.backbone,
      epochs: settings.epochs,
      imgsz: settings.imgsz,
      lastError: widget.model.lastError,
    ));
  }

  /// Tocar un mando a mano deja el preset en «personalizado»: lo que vale es lo
  /// que el usuario acaba de poner, no lo que decía la etiqueta.
  void _change(RecognitionModelEntity changed) {
    widget.onSettingsChanged?.call(
      changed.copyWith(
        preset: TrainingPreset.custom,
        lastError: widget.model.lastError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    final issues = checkTraining(
      model: widget.model,
      fernies: widget.fernies,
      isEngineReady: widget.isEngineReady,
    );

    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.trainingTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          // Con algo en marcha, el avance manda y ocupa el ancho entero: la
          // época y lo que queda son lo que se viene a mirar, y en la columnita
          // del botón no cabían.
          if (widget.job case final job?) ...[
            _progress(context, texts, job),
            const SizedBox(height: AppSpacing.m),
            _presetRow(context, texts),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _presetRow(context, texts)),
                const SizedBox(width: AppSpacing.xl),
                // El botón a la derecha y con ancho propio: es la única acción
                // del bloque y así no se va al fondo de una columna larga.
                SizedBox(
                  width: AppSizes.trainingActionWidth,
                  child: _action(context, texts, issues),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.m),
          _advanced(context, texts),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            ..._issues(context, texts, issues),
          ],
        ],
      ),
    );
  }

  /// Los presets, uno al lado del otro.
  ///
  /// Son tres opciones excluyentes y cortas: en fila se ven las tres a la vez y
  /// se comparan, que es de lo que va elegir. En columna, cada una con su
  /// párrafo, ocupaban media pantalla.
  Widget _presetRow(BuildContext context, AppLocalizations texts) {
    final tiles = _presets(context, texts);

    // Todas del alto de la más larga, para que se lean como una fila de
    // opciones y no como tres cajas sueltas. Con `IntrinsicHeight` y no con
    // `stretch` porque el panel ya no tiene alto fijo: estirarse a un alto
    // infinito no es estirarse.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < tiles.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.s),
            Expanded(child: tiles[index]),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Presets
  // ---------------------------------------------------------------------------

  List<Widget> _presets(BuildContext context, AppLocalizations texts) {
    final current = _preset;

    return [
      for (final preset in TrainingPreset.values)
        // «Personalizado» sólo se enseña si es lo que hay puesto: no es algo que
        // se elija, es lo que queda al tocar los mandos.
        if (preset != TrainingPreset.custom || current == preset)
          FernRadioTile<TrainingPreset>(
            value: preset,
            groupValue: current,
            label: _presetLabel(preset, texts),
            description: _presetDescription(preset, texts),
            onChanged: widget.job == null ? _applyPreset : null,
          ),
    ];
  }

  String _presetLabel(TrainingPreset preset, AppLocalizations texts) =>
      switch (preset) {
        TrainingPreset.fast => texts.presetFast,
        TrainingPreset.balanced => texts.presetBalanced,
        TrainingPreset.accurate => texts.presetAccurate,
        TrainingPreset.custom => texts.presetCustom,
      };

  String _presetDescription(TrainingPreset preset, AppLocalizations texts) =>
      switch (preset) {
        TrainingPreset.fast => texts.presetFastDescription,
        TrainingPreset.balanced => texts.presetBalancedDescription,
        TrainingPreset.accurate => texts.presetAccurateDescription,
        TrainingPreset.custom => texts.presetCustomDescription,
      };

  // ---------------------------------------------------------------------------
  // Avanzado
  // ---------------------------------------------------------------------------

  Widget _advanced(BuildContext context, AppLocalizations texts) {
    final model = widget.model;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isAdvancedOpen = !_isAdvancedOpen),
          mouseCursor: WidgetStateMouseCursor.clickable,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isAdvancedOpen ? Symbols.expand_more : Symbols.chevron_right,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  texts.trainingAdvanced,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
        if (_isAdvancedOpen) ...[
          const SizedBox(height: AppSpacing.s),
          _stepper(
            context,
            label: texts.trainingEpochsLabel,
            value: model.epochs,
            step: 10,
            min: minTrainingEpochs,
            max: maxTrainingEpochs,
            onChanged: (value) => _change(model.copyWith(epochs: value)),
          ),
          const SizedBox(height: AppSpacing.s),
          _stepper(
            context,
            label: texts.trainingImageSizeLabel,
            value: model.imgsz,
            // De treinta y dos en treinta y dos porque YOLO trabaja con
            // múltiplos de esa cifra: un número cualquiera lo redondea por su
            // cuenta y lo que se ve deja de ser lo que se entrena.
            step: 32,
            min: minTrainingImageSize,
            max: maxTrainingImageSize,
            onChanged: (value) => _change(model.copyWith(imgsz: value)),
          ),
          const SizedBox(height: AppSpacing.s),
          _stepper(
            context,
            label: texts.trainingBatchLabel,
            value: model.batch,
            step: 1,
            // `-1` es «que lo decida él según la memoria que haya libre», y es
            // lo razonable salvo que la tarjeta se quede sin.
            min: RecognitionModelEntity.autoBatch,
            max: maxTrainingBatch,
            caption: model.batch == RecognitionModelEntity.autoBatch
                ? texts.trainingBatchAuto
                : null,
            onChanged: (value) => _change(model.copyWith(batch: value)),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.trainingBackboneIs(model.backbone),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      ],
    );
  }

  /// Un mando de los de dentro: menos, el número, más.
  ///
  /// A pasos y no escribiendo: son tres números con un rango razonable, y un
  /// campo libre deja poner cero épocas o un tamaño de imagen que YOLO va a
  /// redondear por su cuenta. Además evita tener que gestionar controladores de
  /// texto para algo que se toca una vez cada muchos meses.
  Widget _stepper(
    BuildContext context, {
    required String label,
    required int value,
    required int step,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    String? caption,
  }) {
    final texts = AppLocalizations.of(context);
    final isEnabled = widget.job == null;

    void move(int by) {
      final next = (value + by).clamp(min, max);
      if (next != value) onChanged(next);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              if (caption != null)
                Text(
                  caption,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.colors.unremarked),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: texts.actionDecrease,
          onPressed: isEnabled && value > min ? () => move(-step) : null,
          icon: const Icon(Symbols.remove),
          iconSize: AppSizes.iconMedium,
        ),
        SizedBox(
          width: AppSizes.avatarXLarge,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          tooltip: texts.actionIncrease,
          onPressed: isEnabled && value < max ? () => move(step) : null,
          icon: const Icon(Symbols.add),
          iconSize: AppSizes.iconMedium,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Avisos
  // ---------------------------------------------------------------------------

  List<Widget> _issues(
    BuildContext context,
    AppLocalizations texts,
    List<TrainingIssue> issues,
  ) {
    return [
      for (final issue in issues)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                issue.isBlocking
                    ? Symbols.block
                    : Symbols.warning_amber,
                size: AppSizes.iconSmall,
                color: issue.isBlocking
                    ? context.colors.error
                    : context.colors.unremarked,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _issueText(issue, texts),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: issue.isBlocking
                            ? context.colors.error
                            : context.colors.unremarked,
                      ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  String _issueText(TrainingIssue issue, AppLocalizations texts) {
    final name = issue.fernieName ?? '';
    final amount = issue.amount ?? 0;

    return switch (issue.kind) {
      TrainingIssueKind.noFernies => texts.modelNoFernies,
      TrainingIssueKind.engineNotReady => texts.trainingEngineNotReady,
      TrainingIssueKind.tooFewRegions =>
        '$name: ${texts.modelTooFewRegions(amount)}',
      TrainingIssueKind.fewRegions => '$name: ${texts.modelFewRegions(amount)}',
      TrainingIssueKind.tooFewMedia => '$name: ${texts.modelTooFewMedia}',
      TrainingIssueKind.noValidation => '$name: ${texts.trainingNoValidation}',
      TrainingIssueKind.imbalanced => texts.trainingImbalanced(amount),
    };
  }

  // ---------------------------------------------------------------------------
  // El botón, o el progreso
  // ---------------------------------------------------------------------------

  Widget _action(
    BuildContext context,
    AppLocalizations texts,
    List<TrainingIssue> issues,
  ) {
    final blocked = !canTrain(issues);

    return SizedBox(
      width: double.infinity,
      child: FernPillButton(
        label: widget.model.isUsable
            ? texts.trainingRetrain
            : texts.trainingStart,
        icon: Symbols.play_arrow,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: blocked ? null : widget.onTrain,
      ),
    );
  }

  Widget _progress(BuildContext context, AppLocalizations texts, Job job) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.total > 0
              ? texts.trainingEpoch(job.done, job.total)
              : texts.trainingPreparing,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: LinearProgressIndicator(
            value: job.progress,
            minHeight: trackHeight,
            backgroundColor: context.colors.lightgray,
            color: context.colors.terciary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Los dos juntos y a la izquierda: con el panel a lo ancho, un `Spacer`
        // mandaba el botón de parar a un palmo del texto que explica por qué
        // querrías pararlo.
        Row(
          children: [
            if (_remaining(job) case final left?) ...[
              Text(
                texts.trainingRemaining(left.inMinutes),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: context.colors.unremarked),
              ),
              const SizedBox(width: AppSpacing.m),
            ],
            TextButton(
              onPressed: widget.onCancel,
              child: Text(texts.jobCancelTooltip),
            ),
          ],
        ),
      ],
    );
  }

  /// Cuánto queda, a ojo.
  ///
  /// Sale de lo que ha tardado en llegar hasta aquí, no de lo que diga nadie: es
  /// una cuenta de tres números y acierta lo bastante para saber si da tiempo a
  /// un café o hay que dejarlo toda la noche.
  Duration? _remaining(Job job) {
    final startedAt = job.startedAt;
    if (startedAt == null || job.done <= 0 || job.total <= 0) return null;

    final elapsed = DateTime.now().difference(startedAt);
    final perEpoch = elapsed.inSeconds / job.done;

    return Duration(seconds: (perEpoch * (job.total - job.done)).round());
  }
}
