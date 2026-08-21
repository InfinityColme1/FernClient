import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:equatable/equatable.dart';

/// Las tres partes en las que se reparte lo marcado de un fernie.
///
/// Con **entrenar** aprende, con **validar** se comprueba a sí mismo mientras
/// aprende (y decide cuándo parar), y con **probar** se le examina al final con
/// material que no ha visto nunca. Si las tres se mezclaran, el examen estaría
/// copiado y las métricas dirían lo que uno quiere oír.
class DatasetSplit extends Equatable {
  final int train;
  final int validation;
  final int test;

  const DatasetSplit({
    this.train = 70,
    this.validation = 20,
    this.test = 10,
  });

  static const balanced = DatasetSplit();

  int get total => train + validation + test;

  /// Los tres suman cien y ninguno es negativo.
  bool get isValid =>
      total == 100 && train >= 0 && validation >= 0 && test >= 0;

  /// Sin nada con que validar, entrenar no sabe cuándo parar ni qué tal va.
  bool get hasValidation => validation > 0;

  /// El mismo reparto con una parte cambiada, repartiendo el resto.
  ///
  /// Mover un tirador no puede dejar el reparto sumando otra cosa que cien, así
  /// que lo que se le quita a uno se le da al siguiente. Se toca **el de al
  /// lado** y no los dos: repartir la diferencia entre los otros dos hace que
  /// arrastrar un tirador mueva los otros dos a la vez, y eso no hay quien lo
  /// maneje.
  DatasetSplit withTrain(int value) {
    final clamped = value.clamp(0, 100);
    final rest = 100 - clamped;

    // La validación se queda con lo que puede de lo que tenía; el resto va a
    // pruebas.
    final nextValidation = validation.clamp(0, rest);

    return DatasetSplit(
      train: clamped,
      validation: nextValidation,
      test: rest - nextValidation,
    );
  }

  DatasetSplit withValidation(int value) {
    final clamped = value.clamp(0, 100 - train);

    return DatasetSplit(
      train: train,
      validation: clamped,
      test: 100 - train - clamped,
    );
  }

  @override
  List<Object?> get props => [train, validation, test];
}

/// Un fernie metido en un modelo, con lo que eso añade: su reparto y el número
/// de clase con el que lo conoce el modelo entrenado.
class ModelFernieEntity extends Equatable {
  final int id;
  final int modelId;

  /// El fernie, con sus recuentos ya puestos: la pantalla necesita saber cuántas
  /// regiones aporta para avisar de si son pocas.
  final FernieEntity fernie;

  final DatasetSplit split;

  /// Qué número tiene esta clase dentro del modelo.
  ///
  /// **No se reindexa nunca.** Quitar un fernie de un modelo ya entrenado
  /// dejaría un hueco; correr los de detrás para taparlo cambiaría lo que
  /// significan los pesos, que fueron entrenados con los números de antes. El
  /// hueco se queda, y sólo un reentrenamiento los vuelve a apretar.
  final int classIndex;

  const ModelFernieEntity({
    required this.id,
    required this.modelId,
    required this.fernie,
    this.split = DatasetSplit.balanced,
    required this.classIndex,
  });

  ModelFernieEntity copyWith({DatasetSplit? split, FernieEntity? fernie}) {
    return ModelFernieEntity(
      id: id,
      modelId: modelId,
      fernie: fernie ?? this.fernie,
      split: split ?? this.split,
      classIndex: classIndex,
    );
  }

  @override
  List<Object?> get props => [id, modelId, fernie, split, classIndex];
}
