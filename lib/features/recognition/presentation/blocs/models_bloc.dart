import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/assign_fernie_to_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_models_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/remove_fernie_from_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_model_split_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Los modelos de reconocimiento: la rejilla de gestión y el detalle de uno.
///
/// Los dos comparten bloc porque comparten datos: crear o borrar en la rejilla
/// tiene que verse al volver del detalle, y meterle un fernie a un modelo cambia
/// el recuento que enseña su tarjeta.
class ModelsBloc extends Bloc<ModelsEvents, ModelsState> {
  final GetModelsUseCase _getModels;
  final GetModelUseCase _getModel;
  final DeleteModelUseCase _deleteModel;
  final GetFerniesOfModelUseCase _getFernies;
  final AssignFernieToModelUseCase _assignFernie;
  final RemoveFernieFromModelUseCase _removeFernie;
  final UpdateModelSplitUseCase _updateSplit;

  ModelsBloc({
    required GetModelsUseCase getModels,
    required GetModelUseCase getModel,
    required DeleteModelUseCase deleteModel,
    required GetFerniesOfModelUseCase getFernies,
    required AssignFernieToModelUseCase assignFernie,
    required RemoveFernieFromModelUseCase removeFernie,
    required UpdateModelSplitUseCase updateSplit,
  })  : _getModels = getModels,
        _getModel = getModel,
        _deleteModel = deleteModel,
        _getFernies = getFernies,
        _assignFernie = assignFernie,
        _removeFernie = removeFernie,
        _updateSplit = updateSplit,
        super(const ModelsState()) {
    on<LoadModelsEvent>(_onLoadModels);
    on<ModelSelectedEvent>(_onModelSelected);
    on<ModelDeselectedEvent>(_onModelDeselected);
    on<DeleteModelEvent>(_onDeleteModel);
    on<AssignFernieEvent>(_onAssignFernie);
    on<RemoveFernieEvent>(_onRemoveFernie);
    on<SplitChangedEvent>(_onSplitChanged);
  }

  /// Relee la lista dejando a la vista la de antes.
  ///
  /// Vaciarla mientras se lee haría parpadear la rejilla entera cada vez que se
  /// crea un modelo, que es justo cuando se está mirando.
  Future<void> _onLoadModels(
    LoadModelsEvent event,
    Emitter<ModelsState> emit,
  ) async {
    emit(state.keepingSelection(isBusy: true));

    final result = await _getModels();

    emit(state.keepingSelection(
      models: result is DataSuccess ? result.data ?? const [] : state.models,
      isBusy: false,
    ));
  }

  Future<void> _onModelSelected(
    ModelSelectedEvent event,
    Emitter<ModelsState> emit,
  ) async {
    emit(state.keepingSelection(isDetailBusy: true));

    final model = await _getModel(params: event.modelId);
    final fernies = await _getFernies(params: event.modelId);

    emit(state.copyWith(
      selected: model is DataSuccess ? model.data : null,
      fernies: fernies is DataSuccess ? fernies.data ?? const [] : const [],
      isDetailBusy: false,
    ));
  }

  void _onModelDeselected(
    ModelDeselectedEvent event,
    Emitter<ModelsState> emit,
  ) {
    emit(state.copyWith(fernies: const [], isDetailBusy: false));
  }

  Future<void> _onDeleteModel(
    DeleteModelEvent event,
    Emitter<ModelsState> emit,
  ) async {
    emit(state.keepingSelection(isBusy: true));

    await _deleteModel(params: event.modelId);

    // Si el que se ha borrado era el abierto, se suelta: no se puede seguir
    // enseñando el detalle de algo que ya no existe.
    final wasOpen = state.selected?.id == event.modelId;
    if (wasOpen) emit(state.copyWith(fernies: const []));

    add(const LoadModelsEvent());
  }

  Future<void> _onAssignFernie(
    AssignFernieEvent event,
    Emitter<ModelsState> emit,
  ) async {
    final model = state.selected;
    if (model == null) return;

    emit(state.keepingSelection(isDetailBusy: true));

    await _assignFernie(
      params: AssignFernieParams(modelId: model.id, fernieId: event.fernieId),
    );

    await _refreshDetail(model.id, emit);
  }

  Future<void> _onRemoveFernie(
    RemoveFernieEvent event,
    Emitter<ModelsState> emit,
  ) async {
    final model = state.selected;
    if (model == null) return;

    emit(state.keepingSelection(isDetailBusy: true));

    await _removeFernie(params: event.assignmentId);

    await _refreshDetail(model.id, emit);
  }

  Future<void> _onSplitChanged(
    SplitChangedEvent event,
    Emitter<ModelsState> emit,
  ) async {
    final model = state.selected;
    if (model == null) return;

    // Sin indicador de espera: esto se dispara al arrastrar un tirador y un velo
    // parpadeando en cada movimiento sería peor que la espera que evita.
    final result = await _updateSplit(
      params: UpdateSplitParams(
        assignmentId: event.assignmentId,
        split: event.split,
      ),
    );

    if (result is! DataSuccess || result.data == null) return;

    emit(state.keepingSelection(
      fernies: [
        for (final fernie in state.fernies)
          if (fernie.id == event.assignmentId) result.data! else fernie,
      ],
    ));
  }

  /// Relee el modelo abierto y sus fernies.
  ///
  /// Se relee entero y no se recompone a mano porque meter o quitar un fernie
  /// cambia más cosas de las que parece: los recuentos del modelo y, con ellos,
  /// si un clasificatorio sigue siéndolo.
  Future<void> _refreshDetail(int modelId, Emitter<ModelsState> emit) async {
    final model = await _getModel(params: modelId);
    final fernies = await _getFernies(params: modelId);

    emit(state.copyWith(
      selected: model is DataSuccess ? model.data : state.selected,
      fernies: fernies is DataSuccess ? fernies.data ?? const [] : state.fernies,
      isDetailBusy: false,
    ));

    // La tarjeta de la rejilla enseña cuántos fernies tiene: si no se relee,
    // volver del detalle la deja mintiendo.
    add(const LoadModelsEvent());
  }

  /// Los fernies que este modelo **no** tiene todavía, para el buscador que los
  /// añade.
  Set<int> get assignedFernieIds =>
      {for (final assignment in state.fernies) assignment.fernie.id};

  /// El reparto que tiene puesto un fernie del modelo abierto.
  DatasetSplit splitOf(int assignmentId) {
    for (final assignment in state.fernies) {
      if (assignment.id == assignmentId) return assignment.split;
    }

    return DatasetSplit.balanced;
  }

  /// Los modelos que ya se pueden usar para reconocer algo.
  List<RecognitionModelEntity> get usable =>
      [for (final model in state.models) if (model.isUsable) model];
}
