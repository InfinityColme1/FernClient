import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Con cuánta seguridad tiene que ver algo este modelo para proponerlo.
///
/// Este mando existía en el modelo desde el principio y no se podía tocar desde
/// ninguna parte. Con el listón fijo en el 35 %, un modelo que veía una figura al
/// 27 % no proponía nada y la aplicación decía «no ha detectado nada»: cierto,
/// inútil, y sin manera de arreglarlo.
///
/// Es del modelo y no de la aplicación entera a propósito: lo seguro que está un
/// modelo depende de con cuánto material se entrenó y de lo parecidas que sean
/// sus clases entre sí. Un listón que valga para el de figuras no vale para el
/// que distingue dos rombos casi iguales.
class RecognitionPanel extends StatelessWidget {
  final RecognitionModelEntity model;

  /// Se llama con el modelo ya cambiado, listo para guardar.
  final ValueChanged<RecognitionModelEntity> onChanged;

  const RecognitionPanel({
    super.key,
    required this.model,
    required this.onChanged,
  });

  /// El listón en tanto por ciento, que es como se enseña y como se mueve.
  int get _percent => (model.confidenceThreshold * 100).round();

  /// Lo más bajo que se puede pedir.
  ///
  /// Es el suelo con el que se le pregunta al motor: por debajo de eso no hay
  /// nada que enseñar porque ni siquiera se ha preguntado, y un mando que se
  /// puede mover sin que cambie nada es peor que uno que se para.
  static int get _min => (recognitionFloor * 100).round();

  /// Lo más alto. El cien por cien no lo alcanza casi nunca nada, y un listón que
  /// no deja pasar jamás una sugerencia es lo mismo que apagar el modelo.
  static const _max = 95;

  void _move(int by) {
    final next = (_percent + by).clamp(_min, _max);
    if (next == _percent) return;

    onChanged(model.copyWith(confidenceThreshold: next / 100));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // En el mínimo se propone todo lo que el motor haya visto. Se dice con
    // palabras y no con el número: «5 %» no le dice a nadie que eso significa
    // «enséñamelo todo».
    final isEverything = _percent <= _min;

    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.recognitionPanelTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts.recognitionThresholdLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      isEverything
                          ? texts.recognitionThresholdEverything
                          : texts.recognitionThresholdDescription,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: context.colors.unremarked),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: texts.recognitionThresholdLower,
                onPressed: _percent > _min ? () => _move(-5) : null,
                icon: const Icon(Icons.remove),
                iconSize: AppSizes.iconMedium,
              ),
              SizedBox(
                width: AppSizes.avatarXLarge,
                child: Text(
                  isEverything ? texts.recognitionThresholdAll : '$_percent %',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: texts.recognitionThresholdRaise,
                onPressed: _percent < _max ? () => _move(5) : null,
                icon: const Icon(Icons.add),
                iconSize: AppSizes.iconMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          // Lo que ya está guardado no cambia al mover esto: las sugerencias se
          // filtraron con el listón que había. Decirlo evita que alguien lo baje,
          // vuelva al contenido y crea que el mando no hace nada.
          Text(
            texts.recognitionThresholdApplies,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      ),
    );
  }
}
