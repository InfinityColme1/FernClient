import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/domain/services/model_tree_layout.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_models_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -----------------------------------------------------------------------------
// Eventos
// -----------------------------------------------------------------------------

abstract class ModelTreeEvents extends Equatable {
  const ModelTreeEvents();

  @override
  List<Object?> get props => [];
}

/// Relee el árbol y la lista de modelos.
class LoadModelTreeEvent extends ModelTreeEvents {
  const LoadModelTreeEvent();
}

/// Elige el nodo sobre el que actúan las acciones del panel.
///
/// Con uno elegido, pulsar un modelo lo cuelga de él; sin ninguno, lo mete como
/// raíz. Es el «clic para colocar rápido» del documento.
class SelectTreeNodeEvent extends ModelTreeEvents {
  final int? nodeId;

  const SelectTreeNodeEvent(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

/// Mete un modelo en el árbol, colgando de [parentNodeId] si se indica.
class PlaceModelEvent extends ModelTreeEvents {
  final int modelId;
  final int? parentNodeId;

  const PlaceModelEvent({required this.modelId, this.parentNodeId});

  @override
  List<Object?> get props => [modelId, parentNodeId];
}

/// Saca un nodo del árbol. El modelo no se borra.
class RemoveTreeNodeEvent extends ModelTreeEvents {
  final int nodeId;

  const RemoveTreeNodeEvent(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

/// Cuelga un nodo que ya estaba de otro.
class ConnectTreeNodesEvent extends ModelTreeEvents {
  final int parentNodeId;
  final int childNodeId;

  const ConnectTreeNodesEvent({
    required this.parentNodeId,
    required this.childNodeId,
  });

  @override
  List<Object?> get props => [parentNodeId, childNodeId];
}

/// Cambia de quién cuelga un nodo que ya estaba en el árbol.
///
/// Le quita los padres que tuviera. Es lo que pasa al arrastrar una tarjeta
/// sobre otra: la respuesta esperada es «ahora cuelga de ésta», no «ahora cuelga
/// de las dos».
class ReparentTreeNodeEvent extends ModelTreeEvents {
  final int parentNodeId;
  final int childNodeId;

  const ReparentTreeNodeEvent({
    required this.parentNodeId,
    required this.childNodeId,
  });

  @override
  List<Object?> get props => [parentNodeId, childNodeId];
}

/// Suelta un nodo de todos sus padres, sin sacarlo del árbol.
class PromoteToRootEvent extends ModelTreeEvents {
  final int nodeId;

  const PromoteToRootEvent(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class DisconnectTreeEdgeEvent extends ModelTreeEvents {
  final int edgeId;

  const DisconnectTreeEdgeEvent(this.edgeId);

  @override
  List<Object?> get props => [edgeId];
}

/// Cambia con qué clase del padre se dispara el hijo.
class SetEdgeConditionEvent extends ModelTreeEvents {
  final int edgeId;
  final int? fernieId;

  const SetEdgeConditionEvent({required this.edgeId, required this.fernieId});

  @override
  List<Object?> get props => [edgeId, fernieId];
}

// -----------------------------------------------------------------------------
// Estado
// -----------------------------------------------------------------------------

class ModelTreeState extends Equatable {
  /// El árbol, ya colocado: cada nodo con su fila y su columna.
  final ModelTreeEntity tree;

  /// Todos los modelos que hay, estén o no en el árbol. El panel lateral los
  /// enseña, y los que están fuera van marcados: son los que no se ejecutan
  /// nunca al reconocer.
  final List<RecognitionModelEntity> models;

  final bool isBusy;

  /// El nodo elegido, si hay alguno.
  final int? selectedNodeId;

  /// Lo último que no se ha podido hacer, para poder contarlo.
  ///
  /// Casi siempre es un ciclo: colgar un nodo de uno de sus descendientes.
  final String? lastError;

  /// Cómo se llama cada fernie que dispara alguna arista.
  ///
  /// Se resuelven aquí y no en la pantalla porque la etiqueta de una arista se
  /// pinta **siempre**, y la pantalla sólo tenía los nombres que hubiera pedido
  /// para abrir un diálogo: sin haber abierto ninguno, todas las aristas decían
  /// «cualquier cosa» aunque tuvieran su clase puesta.
  final Map<int, String> fernieNames;

  /// La arista que se acaba de crear, si alguna.
  ///
  /// La pantalla la usa para preguntar de inmediato **con qué clase** se dispara:
  /// una arista recién puesta se dispara con cualquier detección del padre, que
  /// es tener los especializados corriendo todo el rato. El momento de afinarlo
  /// es justo al crearla, no cuando alguien se dé cuenta.
  final int? lastCreatedEdgeId;

  const ModelTreeState({
    this.tree = ModelTreeEntity.empty,
    this.models = const [],
    this.isBusy = false,
    this.selectedNodeId,
    this.lastError,
    this.lastCreatedEdgeId,
    this.fernieNames = const {},
  });

  /// Los modelos que no están en el árbol.
  ///
  /// Es lo que el panel lateral ofrece para meter: los que ya están no se
  /// vuelven a ofrecer, que un modelo aparece una sola vez.
  List<RecognitionModelEntity> get modelsOutside {
    final inside = {for (final node in tree.nodes) node.model.id};

    return models.where((model) => !inside.contains(model.id)).toList();
  }

  ModelTreeState copyWith({
    ModelTreeEntity? tree,
    List<RecognitionModelEntity>? models,
    Map<int, String>? fernieNames,
    bool? isBusy,
    // Ni el nodo elegido ni el error se arrastran con el `??` de siempre:
    // soltarlos es tan normal como ponerlos.
    int? selectedNodeId,
    String? lastError,
    int? lastCreatedEdgeId,
  }) {
    return ModelTreeState(
      tree: tree ?? this.tree,
      models: models ?? this.models,
      fernieNames: fernieNames ?? this.fernieNames,
      isBusy: isBusy ?? this.isBusy,
      selectedNodeId: selectedNodeId,
      lastError: lastError,
      lastCreatedEdgeId: lastCreatedEdgeId,
    );
  }

  @override
  List<Object?> get props => [
        tree,
        models,
        fernieNames,
        isBusy,
        selectedNodeId,
        lastError,
        lastCreatedEdgeId,
      ];
}

// -----------------------------------------------------------------------------
// Bloc
// -----------------------------------------------------------------------------

/// Lo que la pantalla del árbol sabe.
///
/// Después de cualquier cambio se **relee entero**. Es una estructura pequeña
/// —son los modelos que uno tiene— y actualizarla a trozos obligaría a repetir
/// aquí las reglas de qué pasa al quitar un nodo (sus aristas, los hijos que
/// pasan a raíz), que ya están en el repositorio. Dos sitios con la misma regla
/// es un sitio donde se van a desincronizar.
class ModelTreeBloc extends Bloc<ModelTreeEvents, ModelTreeState> {
  final ModelTreeRepository _repository;
  final GetModelsUseCase _getModels;
  final GetFernieUseCase _getFernie;

  ModelTreeBloc({
    required ModelTreeRepository repository,
    required GetModelsUseCase getModels,
    required GetFernieUseCase getFernie,
  })  : _repository = repository,
        _getModels = getModels,
        _getFernie = getFernie,
        super(const ModelTreeState()) {
    on<LoadModelTreeEvent>(_onLoad);
    on<SelectTreeNodeEvent>(_onSelect);
    on<PlaceModelEvent>(_onPlace);
    on<RemoveTreeNodeEvent>(_onRemove);
    on<ConnectTreeNodesEvent>(_onConnect);
    on<ReparentTreeNodeEvent>(_onReparent);
    on<PromoteToRootEvent>(_onPromoteToRoot);
    on<DisconnectTreeEdgeEvent>(_onDisconnect);
    on<SetEdgeConditionEvent>(_onSetCondition);
  }

  Future<void> _onLoad(
    LoadModelTreeEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, selectedNodeId: state.selectedNodeId));

    await _reload(emit);
  }

  void _onSelect(SelectTreeNodeEvent event, Emitter<ModelTreeState> emit) {
    emit(state.copyWith(selectedNodeId: event.nodeId));
  }

  Future<void> _onPlace(
    PlaceModelEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final placed = await _repository.addModel(modelId: event.modelId);

    if (placed is! DataSuccess || placed.data == null) {
      return _fail(emit, placed.exception);
    }

    final parent = event.parentNodeId;
    int? createdEdgeId;

    if (parent != null) {
      final connected = await _repository.connect(
        parentNodeId: parent,
        childNodeId: placed.data!.id,
      );

      if (connected is! DataSuccess) return _fail(emit, connected.exception);

      createdEdgeId = connected.data?.id;
    }

    await _reload(
      emit,
      selectedNodeId: state.selectedNodeId,
      createdEdgeId: createdEdgeId,
    );
  }

  Future<void> _onRemove(
    RemoveTreeNodeEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final removed = await _repository.removeNode(event.nodeId);
    if (removed is! DataSuccess) return _fail(emit, removed.exception);

    // Se suelta lo elegido si era éste: dejar apuntando a un nodo que ya no está
    // haría que la siguiente colocación fuera a ninguna parte.
    final selected =
        state.selectedNodeId == event.nodeId ? null : state.selectedNodeId;

    await _reload(emit, selectedNodeId: selected);
  }

  Future<void> _onConnect(
    ConnectTreeNodesEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final connected = await _repository.connect(
      parentNodeId: event.parentNodeId,
      childNodeId: event.childNodeId,
    );

    if (connected is! DataSuccess) return _fail(emit, connected.exception);

    await _reload(
      emit,
      selectedNodeId: state.selectedNodeId,
      createdEdgeId: connected.data?.id,
    );
  }

  Future<void> _onReparent(
    ReparentTreeNodeEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final moved = await _repository.reparent(
      parentNodeId: event.parentNodeId,
      childNodeId: event.childNodeId,
    );

    if (moved is! DataSuccess) return _fail(emit, moved.exception);

    await _reload(
      emit,
      selectedNodeId: state.selectedNodeId,
      createdEdgeId: moved.data?.id,
    );
  }

  Future<void> _onPromoteToRoot(
    PromoteToRootEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final promoted = await _repository.promoteToRoot(event.nodeId);
    if (promoted is! DataSuccess) return _fail(emit, promoted.exception);

    await _reload(emit, selectedNodeId: state.selectedNodeId);
  }

  Future<void> _onDisconnect(
    DisconnectTreeEdgeEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final removed = await _repository.disconnect(event.edgeId);
    if (removed is! DataSuccess) return _fail(emit, removed.exception);

    await _reload(emit, selectedNodeId: state.selectedNodeId);
  }

  Future<void> _onSetCondition(
    SetEdgeConditionEvent event,
    Emitter<ModelTreeState> emit,
  ) async {
    final saved = await _repository.setEdgeCondition(
      edgeId: event.edgeId,
      conditionFernieId: event.fernieId,
    );

    if (saved is! DataSuccess) return _fail(emit, saved.exception);

    await _reload(emit, selectedNodeId: state.selectedNodeId);
  }

  /// Relee el árbol y lo coloca.
  Future<void> _reload(
    Emitter<ModelTreeState> emit, {
    int? selectedNodeId,
    int? createdEdgeId,
  }) async {
    final tree = await _repository.getTree();
    final models = await _getModels();

    if (tree is! DataSuccess || tree.data == null) {
      return _fail(emit, tree.exception);
    }

    final laid = layoutModelTree(tree.data!);

    emit(state.copyWith(
      tree: laid,
      models: models is DataSuccess ? models.data ?? const [] : const [],
      fernieNames: await _namesOfConditions(laid),
      isBusy: false,
      selectedNodeId: selectedNodeId,
      lastCreatedEdgeId: createdEdgeId,
    ));
  }

  /// Cómo se llaman los fernies que disparan alguna arista.
  ///
  /// Sólo los que hacen falta: en un árbol de veinte nodos hay veinte aristas
  /// como mucho, y pedir la lista entera de fernies para sacar tres nombres es
  /// leer de más en cada relectura.
  ///
  /// **Se preguntan todos cada vez**, y no sólo los que no se supieran. Este
  /// bloc es único y vive mientras viva la aplicación: guardándose lo ya sabido,
  /// un fernie al que se le cambia el nombre seguía apareciendo con el viejo en
  /// la arista hasta reiniciar, y uno borrado seguía dando nombre a una clase
  /// que ya no existe. Son cuatro consultas de nada; el cache costaba más de lo
  /// que ahorraba.
  Future<Map<int, String>> _namesOfConditions(ModelTreeEntity tree) async {
    final names = <int, String>{};

    for (final edge in tree.edges) {
      final fernieId = edge.conditionFernieId;
      if (fernieId == null || names.containsKey(fernieId)) continue;

      final fernie = await _getFernie(params: fernieId);
      if (fernie is DataSuccess && fernie.data != null) {
        names[fernieId] = fernie.data!.name;
      }
    }

    return names;
  }

  void _fail(Emitter<ModelTreeState> emit, Exception? error) {
    emit(state.copyWith(
      isBusy: false,
      selectedNodeId: state.selectedNodeId,
      lastError: '${error ?? 'Error'}',
    ));
  }
}
