import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:equatable/equatable.dart';

/// Los modelos de reconocimiento y, si se está mirando uno, con qué se entrena.
class ModelsState extends Equatable {
  final List<RecognitionModelEntity> models;

  /// Se está leyendo la lista. La rejilla enseña el indicador y conserva lo que
  /// tuviera: releer no puede dejar la pantalla en blanco un instante.
  final bool isBusy;

  /// El modelo abierto en la pantalla de detalle, o `null` fuera de ella.
  final RecognitionModelEntity? selected;

  /// Los fernies del modelo abierto, en orden de número de clase.
  final List<ModelFernieEntity> fernies;

  /// Se está leyendo o cambiando lo del modelo abierto.
  final bool isDetailBusy;

  const ModelsState({
    this.models = const [],
    this.isBusy = false,
    this.selected,
    this.fernies = const [],
    this.isDetailBusy = false,
  });

  ModelsState copyWith({
    List<RecognitionModelEntity>? models,
    bool? isBusy,
    List<ModelFernieEntity>? fernies,
    bool? isDetailBusy,
    // El modelo elegido no se arrastra con el `??` de siempre: soltarlo al salir
    // del detalle es tan normal como ponerlo, y con aquél no habría manera de
    // dejarlo en nada.
    RecognitionModelEntity? selected,
  }) {
    return ModelsState(
      models: models ?? this.models,
      isBusy: isBusy ?? this.isBusy,
      selected: selected,
      fernies: fernies ?? this.fernies,
      isDetailBusy: isDetailBusy ?? this.isDetailBusy,
    );
  }

  /// El mismo estado conservando el modelo elegido.
  ModelsState keepingSelection({
    List<RecognitionModelEntity>? models,
    bool? isBusy,
    List<ModelFernieEntity>? fernies,
    bool? isDetailBusy,
  }) {
    return ModelsState(
      models: models ?? this.models,
      isBusy: isBusy ?? this.isBusy,
      selected: selected,
      fernies: fernies ?? this.fernies,
      isDetailBusy: isDetailBusy ?? this.isDetailBusy,
    );
  }

  @override
  List<Object?> get props => [models, isBusy, selected, fernies, isDetailBusy];
}
