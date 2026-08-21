import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ModelsEvents extends Equatable {
  const ModelsEvents();

  @override
  List<Object?> get props => [];
}

/// Relee la lista de modelos.
class LoadModelsEvent extends ModelsEvents {
  const LoadModelsEvent();
}

/// Elige el modelo que se está mirando en la pantalla de detalle.
///
/// Trae también sus fernies asignados, que es lo que la pantalla enseña.
class ModelSelectedEvent extends ModelsEvents {
  final int modelId;

  const ModelSelectedEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Suelta el modelo elegido. Al salir del detalle, para que volver a entrar no
/// enseñe un momento el de antes.
class ModelDeselectedEvent extends ModelsEvents {
  const ModelDeselectedEvent();
}

class DeleteModelEvent extends ModelsEvents {
  final int modelId;

  const DeleteModelEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Mete un fernie en el modelo que se está mirando.
class AssignFernieEvent extends ModelsEvents {
  final int fernieId;

  const AssignFernieEvent(this.fernieId);

  @override
  List<Object?> get props => [fernieId];
}

class RemoveFernieEvent extends ModelsEvents {
  final int assignmentId;

  const RemoveFernieEvent(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}

/// Cambia cómo se reparten las regiones de un fernie del modelo.
class SplitChangedEvent extends ModelsEvents {
  final int assignmentId;
  final DatasetSplit split;

  const SplitChangedEvent({required this.assignmentId, required this.split});

  @override
  List<Object?> get props => [assignmentId, split];
}
