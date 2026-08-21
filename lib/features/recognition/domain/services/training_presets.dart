import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';

/// Los mandos con los que se entrena.
///
/// Van juntos porque se eligen juntos: subir el tamaño de imagen sin subir el
/// backbone no sirve de nada, y bajar las épocas con un backbone grande es tirar
/// el tiempo de arranque.
class TrainingSettings {
  final String backbone;
  final int epochs;
  final int imgsz;
  final int batch;

  const TrainingSettings({
    required this.backbone,
    required this.epochs,
    required this.imgsz,
    this.batch = RecognitionModelEntity.autoBatch,
  });
}

/// Qué pone cada preset, según lo que el modelo tenga que aprender.
///
/// Existe para que nadie tenga que saber qué es un backbone. Los tres presets
/// son el mismo compromiso a distintas alturas: **cuánto tiempo se está
/// dispuesto a esperar** a cambio de cuánto acierta.
///
/// La función importa porque distinguir entre varias cosas es más difícil que
/// decir si una está: un clasificatorio necesita más red para el mismo resultado.
TrainingSettings settingsFor({
  required TrainingPreset preset,
  required ModelFunction function,
  bool hasGpu = true,
}) {
  final isClassification = function == ModelFunction.classification;

  return switch (preset) {
    // Para ver si la idea funciona antes de dejar el equipo toda la noche. Es
    // también lo razonable sin tarjeta gráfica, donde cada época cuesta lo que
    // cuesta.
    TrainingPreset.fast => const TrainingSettings(
        backbone: 'yolo11n.pt',
        epochs: 50,
        imgsz: 512,
      ),

    TrainingPreset.balanced => TrainingSettings(
        backbone: isClassification ? 'yolo11s.pt' : 'yolo11n.pt',
        epochs: 100,
        imgsz: 640,
      ),

    TrainingPreset.accurate => TrainingSettings(
        backbone: isClassification ? 'yolo11m.pt' : 'yolo11s.pt',
        epochs: 200,
        imgsz: 640,
      ),

    // Personalizado no rellena nada: ya lo ha rellenado el usuario, y
    // machacárselo con un preset sería quitarle lo que acaba de escribir.
    TrainingPreset.custom => TrainingSettings(
        backbone: RecognitionModelEntity.defaultBackbone,
        epochs: RecognitionModelEntity.defaultEpochs,
        imgsz: RecognitionModelEntity.defaultImageSize,
      ),
  };
}

/// El preset de partida de un modelo recién creado.
///
/// Sin tarjeta gráfica, el rápido: con el equilibrado, cien épocas en procesador
/// son horas, y quien acaba de crear su primer modelo no sabe todavía que eso va
/// a pasar.
TrainingPreset defaultPresetFor({required bool hasGpu}) =>
    hasGpu ? TrainingPreset.balanced : TrainingPreset.fast;

/// Si [model] lleva puestos exactamente los valores de [preset].
///
/// Es lo que decide si la pantalla enseña un preset marcado o «personalizado»:
/// tocar cualquier mando a mano deja de coincidir, y entonces manda lo que el
/// usuario puso.
bool matchesPreset(RecognitionModelEntity model, TrainingPreset preset) {
  if (preset == TrainingPreset.custom) return false;

  final settings = settingsFor(
    preset: preset,
    function: model.effectiveFunction,
  );

  return model.backbone == settings.backbone &&
      model.epochs == settings.epochs &&
      model.imgsz == settings.imgsz;
}
