import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';

/// Qué le pasa a un modelo que va a entrenarse.
enum TrainingIssueKind {
  /// El modelo no tiene ningún fernie: no hay nada que aprender.
  noFernies,

  /// Un fernie no llega al mínimo de regiones. **Impide entrenar**.
  tooFewRegions,

  /// Un fernie llega, pero por poco.
  fewRegions,

  /// Las regiones de un fernie salen de muy pocos contenidos distintos.
  ///
  /// Es el aviso más importante y el que menos se nota: el modelo aprenderá el
  /// fondo en vez del objeto, y **eso no sale en las métricas**.
  tooFewMedia,

  /// Un fernie tiene diez veces más regiones que otro.
  imbalanced,

  /// El reparto de un fernie no deja nada con que validar.
  noValidation,

  /// El motor de reconocimiento no está listo.
  engineNotReady,
}

/// Algo que hay que decirle al usuario antes de entrenar.
class TrainingIssue {
  final TrainingIssueKind kind;

  /// Impide entrenar. Los demás son avisos: se entrena igual, sabiendo.
  final bool isBlocking;

  /// A qué fernie se refiere, cuando es de uno concreto.
  final String? fernieName;

  /// El número que hace falta para contarlo (el mínimo, el recuento...).
  final int? amount;

  const TrainingIssue({
    required this.kind,
    required this.isBlocking,
    this.fernieName,
    this.amount,
  });
}

/// Todo lo que hay que mirar antes de dejar que alguien entrene.
///
/// Entrenar cuesta entre minutos y horas. Casi todo lo que sale mal se puede
/// saber **antes** mirando los recuentos, y decirlo entonces es la diferencia
/// entre corregirlo en un minuto y descubrirlo por la mañana.
///
/// Se devuelven todos, no el primero: quien vaya a arreglarlo prefiere la lista
/// entera a irlos descubriendo de uno en uno.
List<TrainingIssue> checkTraining({
  required RecognitionModelEntity model,
  required List<ModelFernieEntity> fernies,
  required bool isEngineReady,
}) {
  final issues = <TrainingIssue>[];

  if (!isEngineReady) {
    issues.add(const TrainingIssue(
      kind: TrainingIssueKind.engineNotReady,
      isBlocking: true,
    ));
  }

  if (fernies.isEmpty) {
    issues.add(const TrainingIssue(
      kind: TrainingIssueKind.noFernies,
      isBlocking: true,
    ));

    // Sin fernies no hay nada más que mirar: todo lo demás es sobre ellos.
    return issues;
  }

  for (final assignment in fernies) {
    final fernie = assignment.fernie;

    // Se mira **lo que entrena**, no lo marcado: una región sobre contenido sin
    // confirmar se queda fuera del conjunto de datos, y contarla aquí dejaba
    // pasar a entrenar con cero muestras a un fernie que decía tener ciento.
    if (fernie.usableRegionCount < minRegionsPerClass) {
      issues.add(TrainingIssue(
        kind: TrainingIssueKind.tooFewRegions,
        isBlocking: true,
        fernieName: fernie.name,
        amount: minRegionsPerClass,
      ));
    } else if (fernie.usableRegionCount < lowRegionsPerClass) {
      issues.add(TrainingIssue(
        kind: TrainingIssueKind.fewRegions,
        isBlocking: false,
        fernieName: fernie.name,
        amount: lowRegionsPerClass,
      ));
    }

    if (fernie.usableMediaCount < minMediaPerClass) {
      issues.add(TrainingIssue(
        kind: TrainingIssueKind.tooFewMedia,
        isBlocking: false,
        fernieName: fernie.name,
        amount: minMediaPerClass,
      ));
    }

    // Un reparto sin validación deja al entrenamiento sin saber cuándo parar ni
    // qué tal va: ultralytics necesita ese conjunto.
    if (!assignment.split.hasValidation) {
      issues.add(TrainingIssue(
        kind: TrainingIssueKind.noValidation,
        isBlocking: true,
        fernieName: fernie.name,
      ));
    }
  }

  // El desequilibrio se mira entre el que más tiene y el que menos: con diez a
  // uno, el modelo aprende a contestar siempre el mayoritario y acierta el
  // noventa por ciento de las veces sin haber aprendido nada.
  final counts = [for (final a in fernies) a.fernie.usableRegionCount]..sort();
  final fewest = counts.first;
  final most = counts.last;

  if (fewest > 0 && most >= fewest * maxClassImbalance) {
    issues.add(TrainingIssue(
      kind: TrainingIssueKind.imbalanced,
      isBlocking: false,
      amount: maxClassImbalance,
    ));
  }

  return issues;
}

/// Si con estos avisos se puede entrenar.
bool canTrain(List<TrainingIssue> issues) =>
    !issues.any((issue) => issue.isBlocking);
