import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:isar/isar.dart';

part 'model_fernie_model.g.dart';

/// Un fernie metido en un modelo.
///
/// Es una tabla puente con cosas propias: el reparto entre entrenar, validar y
/// probar, y el número de clase con el que el modelo entrenado conoce a este
/// fernie. Por eso es una colección y no un simple enlace entre las dos.
@collection
@Name("ModelFernies")
class ModelFernieModel {
  Id id = Isar.autoIncrement;

  final model = IsarLink<RecognitionModelModel>();
  final fernie = IsarLink<FernieModel>();

  /// El reparto de sus regiones, en tantos por ciento. Suman cien.
  int trainPercent = 70;
  int valPercent = 20;
  int testPercent = 10;

  /// Qué número tiene esta clase dentro del modelo.
  ///
  /// **No se reindexa nunca.** Quitar un fernie de un modelo ya entrenado deja
  /// un hueco; correr los de detrás para taparlo cambiaría lo que significan
  /// unos pesos entrenados con los números de antes. El hueco se queda hasta que
  /// se reentrena.
  late int classIndex;

  ModelFernieModel();
}
