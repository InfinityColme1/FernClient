import 'package:equatable/equatable.dart';

/// Qué hizo un modelo con un contenido.
///
/// Las cinco respuestas se parecen desde fuera —no sale ninguna sugerencia— y
/// significan cosas muy distintas. Sin separarlas, «los modelos no han detectado
/// nada» es lo único que se le puede decir al usuario, y eso no le deja saber si
/// el problema es el modelo, el listón o el árbol.
enum RecognitionVerdict {
  /// Vio algo y pasó el listón: hay sugerencia.
  proposed,

  /// Vio algo, pero por debajo de su listón de confianza.
  ///
  /// Es el caso que más desconcierta: el modelo **sí** ha reconocido la figura,
  /// sólo que sin la seguridad suficiente. Enseñarlo es lo que convierte «no ha
  /// detectado nada» en «lo vio al 27 %, y tu listón está en el 35 %».
  belowThreshold,

  /// Miró y no vio absolutamente nada.
  sawNothing,

  /// No llegó a ejecutarse: su rama no se abrió.
  ///
  /// No es un fallo, es el árbol haciendo su trabajo. Pero desde fuera es
  /// idéntico a que el modelo haya fallado, así que hay que decirlo.
  notReached,

  /// No se ejecutó porque no tiene pesos.
  untrained,
}

/// Una cosa que un modelo dijo ver, con cuánta seguridad.
class RecognitionSighting extends Equatable {
  final int fernieId;
  final String fernieName;
  final double confidence;

  const RecognitionSighting({
    required this.fernieId,
    required this.fernieName,
    required this.confidence,
  });

  int get percent => (confidence * 100).round();

  @override
  List<Object?> get props => [fernieId, fernieName, confidence];
}

/// Lo que un modelo concreto hizo con un contenido concreto.
class RecognitionLogEntry extends Equatable {
  final int modelId;
  final String modelName;

  /// La cara del modelo, la misma con la que se le conoce en el árbol.
  ///
  /// El log es una lista de nombres parecidos —«Figuras», «Formas nuevas»— y
  /// leerlos uno a uno para encontrar el que interesa es justo lo que el árbol
  /// evita poniéndoles cara. Sin ella aquí, el usuario tiene que traducir de
  /// vuelta a nombre lo que en el resto de la aplicación reconoce de un vistazo.
  final String? picturePath;

  final RecognitionVerdict verdict;

  /// Todo lo que vio, pasara o no el listón, de más seguro a menos.
  final List<RecognitionSighting> sightings;

  /// El listón con el que se le juzgó.
  final double threshold;

  const RecognitionLogEntry({
    required this.modelId,
    required this.modelName,
    required this.verdict,
    required this.threshold,
    this.picturePath,
    this.sightings = const [],
  });

  /// Lo que pasó el listón.
  List<RecognitionSighting> get accepted =>
      [for (final one in sightings) if (one.confidence >= threshold) one];

  /// Lo que se quedó a las puertas.
  List<RecognitionSighting> get rejected =>
      [for (final one in sightings) if (one.confidence < threshold) one];

  @override
  List<Object?> get props =>
      [modelId, modelName, picturePath, verdict, sightings, threshold];
}

/// Todo lo que pasó al reconocer un contenido.
///
/// Es lo que se enseña cuando el usuario pregunta «¿por qué aquí no ha salido
/// nada?». Sin esto la única respuesta posible es «pues no ha salido», que no
/// deja arreglar nada.
class MediaRecognitionLog extends Equatable {
  final int mediaId;

  /// Cómo se llama el fichero, para poder enseñarlo sin volver a la biblioteca.
  final String name;

  /// Qué hizo cada modelo, en el orden en que el árbol los recorrió.
  final List<RecognitionLogEntry> models;

  final DateTime at;

  const MediaRecognitionLog({
    required this.mediaId,
    required this.name,
    required this.models,
    required this.at,
  });

  /// Cuántas sugerencias salieron de aquí.
  int get proposed => [
        for (final entry in models) ...entry.accepted,
      ].length;

  /// Si algún modelo vio algo que no llegó al listón.
  ///
  /// Es lo que decide si merece la pena empujar al usuario a mirar el detalle:
  /// cuando no ha salido nada pero **casi**, hay algo que hacer.
  bool get hasNearMisses =>
      models.any((entry) => entry.verdict == RecognitionVerdict.belowThreshold);

  @override
  List<Object?> get props => [mediaId, name, models, at];
}
