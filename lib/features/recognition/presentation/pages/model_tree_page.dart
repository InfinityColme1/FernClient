import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_recognizable_media_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/model_tree_bloc.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/recognition/presentation/widgets/recognize_library_dialog.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_states.dart';
import 'package:Fern/features/recognition/presentation/widgets/edge_condition_dialog.dart';
import 'package:Fern/features/recognition/presentation/widgets/model_side_panel.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_canvas.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_drag_payload.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// En qué orden y bajo qué condición se ejecutan los modelos al reconocer.
///
/// Reconocer con todos siempre es caro y ruidoso. Aquí se encadenan: uno general
/// filtra y, sólo si detecta algo concreto, se ejecutan los especializados que
/// cuelgan de esa detección.
///
/// **El usuario conecta, no coloca.** Las filas y las columnas se calculan
/// solas; ordenar tarjetas a mano con quince modelos es el trabajo aburrido por
/// el que nadie vuelve a abrir una pantalla así.
class ModelTreePage extends StatefulWidget {
  const ModelTreePage({super.key});

  @override
  State<ModelTreePage> createState() => _ModelTreePageState();
}

class _ModelTreePageState extends State<ModelTreePage> {
  final _bloc = getIt<ModelTreeBloc>();
  final _getFernies = getIt<GetFerniesOfModelUseCase>();

  /// El de la rejilla de modelos, para enterarse de que hay uno nuevo.
  ///
  /// Se crean modelos desde el «+» de la barra de arriba **sin salir de aquí**, y
  /// esta pantalla no tiene forma de saberlo por su cuenta: antes había que
  /// salir y volver para que el nuevo apareciera en el panel.
  final _models = getIt<ModelsBloc>();
  StreamSubscription<ModelsState>? _modelsSubscription;

  final _viewer = TransformationController();

  /// El tamaño del lienzo, para poder encajar el árbol dentro.
  final _canvasKey = GlobalKey();

  /// Cuántos nodos había la última vez, para saber cuándo ha entrado uno nuevo.
  int _lastNodeCount = 0;

  /// A cuánto está el zoom, para poder enseñarlo y para simplificar las
  /// tarjetas cuando ya no se leen.
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _bloc.add(const LoadModelTreeEvent());

    _viewer.addListener(_onZoom);

    // Al crear un modelo, la rejilla se relee: eso es lo que se escucha, y con
    // ello se relee el árbol. Antes había que salir de la pantalla y volver.
    //
    // Se comparan **cuáles** son y no cuántos: crear uno y borrar otro deja el
    // mismo número, y el panel se quedaría ofreciendo el que ya no está.
    _modelsSubscription = _models.stream.listen((state) {
      final known = {for (final model in _bloc.state.models) model.id};
      final now = {for (final model in state.models) model.id};

      if (known.length == now.length && known.containsAll(now)) return;

      _bloc.add(const LoadModelTreeEvent());
    });
  }

  @override
  void dispose() {
    unawaited(_modelsSubscription?.cancel());

    _viewer
      ..removeListener(_onZoom)
      ..dispose();

    super.dispose();
  }

  void _onZoom() {
    final scale = _viewer.value.getMaxScaleOnAxis();
    if ((scale - _scale).abs() < 0.01) return;

    setState(() => _scale = scale);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocProvider<ModelTreeBloc>.value(
      value: _bloc,
      child: BlocConsumer<ModelTreeBloc, ModelTreeState>(
        bloc: _bloc,
        // Lo que no se ha podido hacer se cuenta y no se traga: casi siempre es
        // un ciclo, y sin decirlo el nodo simplemente no se cuelga y nadie sabe
        // por qué.
        listenWhen: (before, after) =>
            (after.lastError != null && before.lastError != after.lastError) ||
            (after.lastCreatedEdgeId != null &&
                before.lastCreatedEdgeId != after.lastCreatedEdgeId) ||
            before.tree.nodes.length != after.tree.nodes.length,
        listener: (context, state) {
          if (state.lastError != null) {
            showFernToast(context, texts.treeCannotConnect);
            return;
          }

          // Un nodo nuevo puede caer fuera de lo que se ve. Se encaja el árbol
          // entero en el fotograma siguiente, cuando el lienzo ya se ha medido
          // con la tarjeta nueva dentro.
          if (state.tree.nodes.length != _lastNodeCount) {
            _lastNodeCount = state.tree.nodes.length;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fitToView();
            });
          }

          final edgeId = state.lastCreatedEdgeId;
          if (edgeId != null) unawaited(_askConditionFor(state, edgeId));
        },
        builder: (context, state) {
          return Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TutorialAnchor(
                  id: TutorialAnchorId.screenHeader,
                  child: _header(context, texts, state),
                ),
                const SizedBox(height: AppSpacing.l),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TutorialAnchor(
                          id: TutorialAnchorId.screenBody,
                          child: _canvas(context, texts, state),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                      SizedBox(
                        width: AppSizes.treeSidePanelWidth,
                        child: TutorialAnchor(
                          id: TutorialAnchorId.screenList,
                          child: ModelSidePanel(
                            models: state.modelsOutside,
                            selectedName: _selectedName(state),
                            onPlace: (model) => _bloc.add(PlaceModelEvent(
                              modelId: model.id,
                              parentNodeId: state.selectedNodeId,
                            )),
                            onClearSelection: () =>
                                _bloc.add(const SelectTreeNodeEvent(null)),
                            onRemoveNode: (nodeId) =>
                                _bloc.add(RemoveTreeNodeEvent(nodeId)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _selectedName(ModelTreeState state) {
    final id = state.selectedNodeId;
    if (id == null) return null;

    return state.tree.nodeById(id)?.model.name;
  }

  // ---------------------------------------------------------------------------
  // Cabecera
  // ---------------------------------------------------------------------------

  Widget _header(
    BuildContext context,
    AppLocalizations texts,
    ModelTreeState state,
  ) {
    final outside = state.modelsOutside.length;

    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          IconButton(
            tooltip: texts.viewerBack,
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.arrow_back),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(texts.treeTitle, style: Theme.of(context).textTheme.titleMedium),
          if (outside > 0) ...[
            const SizedBox(width: AppSpacing.m),
            // Los que están fuera no se ejecutan nunca. Sin decirlo aquí, se
            // entrenan modelos que no llegan a usarse jamás.
            Text(
              texts.treeOutsideCount(outside),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.colors.unremarked),
            ),
          ],
          const Spacer(),
          // Reconocer la biblioteca entera se pide desde aquí y no desde la
          // rejilla: ésta es la pantalla que enseña **qué va a ejecutarse**, y
          // es donde se entiende que el resultado depende del árbol que se está
          // mirando.
          FernPillButton(
            label: texts.recognizeLibrary,
            icon: Symbols.auto_awesome,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: _recognizeLibrary,
          ),
          const SizedBox(width: AppSpacing.m),
          _zoomControls(context, texts),
        ],
      ),
    );
  }

  /// Manda a reconocer la biblioteca, preguntando antes cuánto hay que mirar.
  ///
  /// Se pregunta porque las dos respuestas son legítimas y cuestan cosas muy
  /// distintas: quien acaba de importar cuatro cosas quiere sólo lo nuevo, y
  /// quien acaba de entrenar un modelo mejor lo quiere todo. Lanzarlo sobre todo
  /// sin avisar puede dejar el equipo trabajando horas.
  Future<void> _recognizeLibrary() async {
    final fresh = await _idsOf(onlyUnrecognized: true);
    final all = await _idsOf(onlyUnrecognized: false);

    if (!mounted) return;

    final scope = await showFernDialog<RecognitionScope, ModelTreeBloc>(
      context: context,
      builder: (_) => RecognizeLibraryDialog(
        unrecognized: fresh.length,
        total: all.length,
      ),
    );

    if (scope == null || !mounted) return;

    await requestRecognition(
      context,
      scope == RecognitionScope.onlyUnrecognized ? fresh : all,
      name: AppLocalizations.of(context).recognizeJobLibrary,
    );
  }

  Future<List<int>> _idsOf({required bool onlyUnrecognized}) async {
    final found = await getIt<GetRecognizableMediaUseCase>()(
      params: RecognizableMediaParams(onlyUnrecognized: onlyUnrecognized),
    );

    return found is DataSuccess ? found.data ?? const [] : const [];
  }

  Widget _zoomControls(BuildContext context, AppLocalizations texts) {
    return Row(
      children: [
        IconButton(
          tooltip: texts.treeZoomOut,
          onPressed: () => _zoomBy(1 / treeZoomStep),
          icon: const Icon(Symbols.remove),
        ),
        SizedBox(
          width: AppSizes.avatarXLarge,
          child: Text(
            '${(_scale * 100).round()} %',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: texts.treeZoomIn,
          onPressed: () => _zoomBy(treeZoomStep),
          icon: const Icon(Symbols.add),
        ),
        IconButton(
          tooltip: texts.treeFitToView,
          onPressed: _fitToView,
          icon: const Icon(Symbols.fit_screen),
        ),
      ],
    );
  }

  void _zoomBy(double factor) {
    final next = (_scale * factor).clamp(treeMinZoom, treeMaxZoom);

    setState(() {
      _scale = next;
      _viewer.value = Matrix4.identity()..scaleByDouble(next, next, next, 1);
    });
  }

  /// Encaja el árbol entero en lo que se ve.
  ///
  /// Sin esto, meter un modelo que cae fuera de la vista no da ningún retorno:
  /// se pulsa, aparentemente no pasa nada, y el nodo está ahí abajo a la derecha
  /// donde nadie va a mirar.
  ///
  /// Nunca agranda por encima del 100 %: un árbol de dos nodos ocupando la
  /// pantalla entera se ve ridículo, y además deja de parecerse a lo que se verá
  /// en cuanto haya cinco.
  void _fitToView() {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;

    final content = treeCanvasSize(_bloc.state.tree);
    if (content.width <= 0 || content.height <= 0) return;

    // Menos el relleno del panel: lo medido es la superficie entera, y el árbol
    // se dibuja dentro de ella. Sin descontarlo, «encajar» dejaba el borde de
    // los nodos de los extremos justo por fuera.
    final visible = Size(
      box.size.width - AppSpacing.l * 2,
      box.size.height - AppSpacing.l * 2,
    );

    if (visible.width <= 0 || visible.height <= 0) return;

    final scale = math
        .min(visible.width / content.width, visible.height / content.height)
        .clamp(treeMinZoom, 1.0);

    setState(() {
      _scale = scale;
      _viewer.value = Matrix4.identity()..scaleByDouble(scale, scale, scale, 1);
    });
  }

  // ---------------------------------------------------------------------------
  // Lienzo
  // ---------------------------------------------------------------------------

  Widget _canvas(
    BuildContext context,
    AppLocalizations texts,
    ModelTreeState state,
  ) {
    if (state.isBusy && state.tree.nodes.isEmpty) {
      return const Center(child: FernProgressIndicator());
    }

    // El vacío va **dentro** de la zona que recoge, no en vez de ella. Estaba
    // fuera, así que con el árbol vacío arrastrar un modelo al lienzo no hacía
    // nada: justo lo primero que se intenta, y justo lo que el propio mensaje
    // está pidiendo que se haga.
    return FernDropSlot<TreeDragPayload>(
      // El fondo del lienzo es «aquí no cuelga de nadie»: un modelo se mete
      // suelto y un nodo se suelta de sus padres. Las dos cosas acaban en lo
      // mismo, que es ejecutarse siempre.
      canAccept: (_) => true,
      onAccept: _onDropOnCanvas,
      isPlain: true,
      builder: (context, dropState) => FernSurface(
        key: _canvasKey,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: state.tree.nodes.isEmpty
            ? _empty(context, texts)
            : _zoomableCanvas(context, texts, state),
      ),
    );
  }

  Widget _empty(BuildContext context, AppLocalizations texts) {
    return Center(
      child: Text(
        texts.treeEmpty,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.colors.unremarked),
      ),
    );
  }

  Widget _zoomableCanvas(
    BuildContext context,
    AppLocalizations texts,
    ModelTreeState state,
  ) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _panFrom = null,
      onPointerCancel: (_) => _panFrom = null,
      child: InteractiveViewer(
        transformationController: _viewer,
        minScale: treeMinZoom,
        maxScale: treeMaxZoom,
        // Con sitio de sobra alrededor: si no, desplazar el lienzo se detiene
        // en seco al llegar al borde del árbol y parece atascado.
        boundaryMargin: const EdgeInsets.all(AppSpacing.xxxl * 4),
        constrained: false,
        // Desplazar es con el botón central, **el mismo reparto de gestos que
        // el modo fernie**: dos convenciones distintas en la misma aplicación
        // es lo que hace que no se recuerde ninguna. De paso, el botón
        // izquierdo queda entero para arrastrar tarjetas.
        panEnabled: false,
        child: TreeCanvas(
          tree: state.tree,
          selectedNodeId: state.selectedNodeId,
          edgeLabels: _edgeLabels(state, texts),
          isSimplified: _scale < treeSimplifyBelow,
          onNodeTap: (id) => _bloc.add(SelectTreeNodeEvent(
            state.selectedNodeId == id ? null : id,
          )),
          onNodeRemove: (id) => _bloc.add(RemoveTreeNodeEvent(id)),
          onEdgeTap: (id) => _openEdge(state, id),
          onDropOnNode: _onDropOnNode,
        ),
      ),
    );
  }

  /// Desde dónde se está desplazando el lienzo con el botón central.
  Offset? _panFrom;

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons != kMiddleMouseButton) return;

    _panFrom = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final from = _panFrom;
    if (from == null || event.buttons != kMiddleMouseButton) return;

    _panFrom = event.position;

    // Se mueve la matriz a mano porque el visor tiene el desplazamiento
    // apagado: dejárselo a él sería dejarle también el botón izquierdo.
    final delta = event.position - from;
    _viewer.value = _viewer.value.clone()..translateByDouble(
        delta.dx,
        delta.dy,
        0,
        1,
      );
  }

  /// Se ha soltado algo sobre un nodo: pasa a ser su padre.
  void _onDropOnNode(TreeDragPayload payload, int parentNodeId) {
    switch (payload) {
      case TreeModelPayload(:final modelId):
        _bloc.add(PlaceModelEvent(modelId: modelId, parentNodeId: parentNodeId));

      case TreeNodePayload(:final nodeId):
        // Reengancha, no añade otro padre: al arrastrar una tarjeta sobre otra
        // lo que se espera es «ahora cuelga de ésta».
        _bloc.add(ReparentTreeNodeEvent(
          parentNodeId: parentNodeId,
          childNodeId: nodeId,
        ));
    }
  }

  /// Se ha soltado algo en el hueco del lienzo: queda sin padres.
  void _onDropOnCanvas(TreeDragPayload payload) {
    switch (payload) {
      case TreeModelPayload(:final modelId):
        _bloc.add(PlaceModelEvent(modelId: modelId));

      case TreeNodePayload(:final nodeId):
        _bloc.add(PromoteToRootEvent(nodeId));
    }
  }

  /// Pregunta con qué clase se dispara una arista recién creada.
  ///
  /// Sólo si el padre distingue entre varias: con una sola clase no hay nada que
  /// elegir, y abrir un diálogo para una única opción es un paso de más en el
  /// camino de todos los días.
  Future<void> _askConditionFor(ModelTreeState state, int edgeId) async {
    final edge = state.tree.edges.where((one) => one.id == edgeId).firstOrNull;
    if (edge == null) return;

    final parent = state.tree.nodeById(edge.parentNodeId);
    if (parent == null) return;

    final fernies = await _ferniesOf(parent.model.id);
    if (fernies.length < 2 || !mounted) return;

    await _openEdge(state, edgeId);
  }

  /// Cómo se llama la clase que dispara cada arista.
  ///
  /// Sin nombre, la etiqueta diría un número y no significaría nada. El fernie
  /// se busca entre los del padre, que son los que ese modelo sabe distinguir.
  Map<int, String> _edgeLabels(ModelTreeState state, AppLocalizations texts) {
    return {
      for (final edge in state.tree.edges)
        edge.id: _nameOfCondition(state, edge, texts),
    };
  }

  String _nameOfCondition(
    ModelTreeState state,
    ModelTreeEdgeEntity edge,
    AppLocalizations texts,
  ) {
    final fernieId = edge.conditionFernieId;
    if (fernieId == null) return texts.treeEdgeAnyDetection;

    // El nombre lo trae el estado. Antes salía de lo que la pantalla hubiera
    // pedido para abrir un diálogo, así que sin haber abierto ninguno todas las
    // aristas decían «cualquier cosa» aunque tuvieran su clase puesta.
    return state.fernieNames[fernieId] ?? texts.treeEdgeAnyDetection;
  }

  /// Los fernies de cada modelo, según se van necesitando.
  ///
  /// Sólo para el diálogo, que necesita **los del padre** y en su orden. Los
  /// nombres de las etiquetas los trae el estado: se pintan siempre, y depender
  /// de haber abierto un diálogo antes era justo lo que las dejaba en blanco.
  final Map<int, List<ModelFernieEntity>> _ferniesByModel = {};

  Future<List<ModelFernieEntity>> _ferniesOf(int modelId) async {
    final cached = _ferniesByModel[modelId];
    if (cached != null) return cached;

    final result = await _getFernies(params: modelId);
    final fernies = result is DataSuccess
        ? result.data ?? const <ModelFernieEntity>[]
        : const <ModelFernieEntity>[];

    _ferniesByModel[modelId] = fernies;

    return fernies;
  }

  Future<void> _openEdge(ModelTreeState state, int edgeId) async {
    final edge = state.tree.edges.where((one) => one.id == edgeId).firstOrNull;
    if (edge == null) return;

    final parent = state.tree.nodeById(edge.parentNodeId);
    final child = state.tree.nodeById(edge.childNodeId);
    if (parent == null || child == null) return;

    final fernies = await _ferniesOf(parent.model.id);
    if (!mounted) return;

    final result = await showFernDialog<EdgeConditionResult, ModelTreeBloc>(
      context: context,
      builder: (_) => EdgeConditionDialog(
        parentName: parent.model.name,
        childName: child.model.name,
        parentFernies: fernies,
        conditionFernieId: edge.conditionFernieId,
      ),
    );

    if (result == null || !mounted) return;

    if (result.isDisconnected) {
      _bloc.add(DisconnectTreeEdgeEvent(edgeId));
      return;
    }

    // La etiqueta nueva sale sola: el nombre lo resuelve el bloc al releer.
    _bloc.add(SetEdgeConditionEvent(edgeId: edgeId, fernieId: result.fernieId));
  }
}
