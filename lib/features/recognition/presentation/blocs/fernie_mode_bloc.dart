import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/add_fernie_regions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_region_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'fernie_mode_events.dart';
import 'fernie_mode_states.dart';

/// El modo fernie del visor: qué modo está puesto y qué se lleva marcado sin
/// guardar.
///
/// Va aparte del `MediaBloc` a propósito. Aquél tiene tres estados con su
/// `copyWith` cada uno y ya arrastra veinte campos; meterle el modo obligaría a
/// tocar los tres por cada campo nuevo, y esto no es información del contenido
/// sino de lo que se está haciendo con él en esta pantalla. Vive donde vive el
/// visor y muere con él, que es justo lo que se quiere: salir del visor no puede
/// dejar medio marcado en memoria.
///
/// Nada baja a la base de datos hasta aceptar. Ni lo marcado, ni lo movido, ni
/// lo borrado: así cancelar deshace la sesión entera de una pieza.
class FernieModeBloc extends Bloc<FernieModeEvents, FernieModeState> {
  final GetRegionsOfMediaUseCase _getRegions;
  final GetFerniesOfMediaUseCase _getFernies;
  final AddFernieRegionsUseCase _addRegions;
  final UpdateFernieRegionUseCase _updateRegion;
  final DeleteFernieRegionUseCase _deleteRegion;

  FernieModeBloc({
    required GetRegionsOfMediaUseCase getRegions,
    required GetFerniesOfMediaUseCase getFernies,
    required AddFernieRegionsUseCase addRegions,
    required UpdateFernieRegionUseCase updateRegion,
    required DeleteFernieRegionUseCase deleteRegion,
  })  : _getRegions = getRegions,
        _getFernies = getFernies,
        _addRegions = addRegions,
        _updateRegion = updateRegion,
        _deleteRegion = deleteRegion,
        super(const FernieModeState()) {
    on<LoadMediaRegionsEvent>(_onLoadMediaRegions);
    on<EnterFernieModeEvent>(_onEnterFernieMode);
    on<ExitFernieModeEvent>(_onExitFernieMode);
    on<RegionAssignedEvent>(_onRegionAssigned);
    on<FernieToolChangedEvent>(_onToolChanged);
    on<RegionSelectedEvent>(_onRegionSelected);
    on<RegionDraftResizedEvent>(_onDraftResized);
    on<RegionDraftReassignedEvent>(_onDraftReassigned);
    on<RegionEditsConfirmedEvent>(_onEditsConfirmed);
    on<RegionEditsDiscardedEvent>(_onEditsDiscarded);
    on<RegionDeletedEvent>(_onRegionDeleted);
    on<UndoLastRegionEvent>(_onUndoLastRegion);
  }

  /// Lee de la base de datos lo que este contenido tiene marcado.
  ///
  /// Suelta lo pendiente: pasar de un contenido a otro con el modo cerrado no
  /// puede arrastrar regiones del anterior, que se guardarían sobre el fichero
  /// equivocado.
  Future<void> _onLoadMediaRegions(
    LoadMediaRegionsEvent event,
    Emitter<FernieModeState> emit,
  ) async {
    emit(FernieModeState(mediaId: event.mediaId, isBusy: true));

    final regions = await _regionsOf(event.mediaId);
    final fernies = await _ferniesOf(event.mediaId);

    // Mientras se leía puede haberse pasado al contenido siguiente: lo que
    // acaba de llegar ya no es de lo que se está viendo.
    if (state.mediaId != event.mediaId) return;

    emit(state.copyWith(saved: regions, fernies: fernies, isBusy: false));
  }

  void _onEnterFernieMode(
    EnterFernieModeEvent event,
    Emitter<FernieModeState> emit,
  ) {
    if (state.isFernieMode) return;

    emit(state
        .copyWith(
          mode: ViewerMode.fernie,
          tool: FernieTool.mark,
          infoWasOpen: event.infoWasOpen,
          pending: const [],
          edited: const {},
          reassigned: const {},
          deleted: const {},
        )
        .withSelection());
  }

  /// Cierra el modo, escribiendo o descartando.
  ///
  /// Al guardar, las tres cosas van seguidas y las altas en una sola
  /// transacción: aceptar es un gesto y tiene que dejar la base de datos como el
  /// usuario ve la pantalla, no a medias.
  Future<void> _onExitFernieMode(
    ExitFernieModeEvent event,
    Emitter<FernieModeState> emit,
  ) async {
    final mediaId = state.mediaId;

    if (!event.save || !state.hasChanges || mediaId == null) {
      emit(state
          .copyWith(
            mode: ViewerMode.viewing,
            pending: const [],
            edited: const {},
            reassigned: const {},
            deleted: const {},
          )
          .withSelection());
      return;
    }

    // El modo se cierra ya, antes de escribir: guardar es un gesto terminado y
    // las regiones tienen que irse con él. Un tramo largo de vídeo son cientos
    // de filas, y dejar los rectángulos encima del contenido hasta que acabe la
    // escritura hace que parezca que el visor se ha quedado colgado. De que se
    // sabe que sigue habiendo trabajo se encarga [isBusy].
    emit(state.copyWith(mode: ViewerMode.viewing, isBusy: true));

    if (state.pending.isNotEmpty) {
      await _addRegions(
        params: [
          for (final region in state.pending)
            FernieRegionEntity(
              id: unsavedId,
              mediaId: mediaId,
              fernieId: region.fernieId,
              x: region.rect.left,
              y: region.rect.top,
              w: region.rect.width,
              h: region.rect.height,
              frameMs: region.frameMs,
            ),
        ],
      );
    }

    // Movidas y reasignadas se escriben de una pasada por región: son la misma
    // fila y un solo `updateRegion` la deja con todo puesto.
    final touched = {...state.edited.keys, ...state.reassigned.keys};

    for (final id in touched) {
      final original = _savedById(id);
      if (original == null) continue;

      final rect = state.edited[id];

      await _updateRegion(
        params: original.copyWith(
          x: rect?.left,
          y: rect?.top,
          w: rect?.width,
          h: rect?.height,
          fernieId: state.reassigned[id],
        ),
      );
    }

    for (final id in state.deleted) {
      await _deleteRegion(params: id);
    }

    // Se relee en vez de recomponer a mano: las altas vuelven con identificador
    // nuevo, y sin releer la próxima edición no sabría a qué fila apunta.
    final regions = await _regionsOf(mediaId);
    final fernies = await _ferniesOf(mediaId);

    emit(FernieModeState(
      mediaId: mediaId,
      saved: regions,
      fernies: fernies,
    ));
  }

  void _onRegionAssigned(
    RegionAssignedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    final isKnown =
        state.fernies.any((fernie) => fernie.id == event.fernie.id);

    emit(state.copyWith(
      pending: [
        ...state.pending,
        PendingRegion(
          rect: event.rect,
          fernieId: event.fernie.id,
          frameMs: event.frameMs,
        ),
      ],
      // El fernie recién elegido pasa a estar entre los de este contenido
      // aunque todavía no tenga ninguna región guardada: es lo que hace que su
      // nombre salga ya sobre el rectángulo.
      fernies: isKnown ? state.fernies : [...state.fernies, event.fernie],
    ));
  }

  /// Cambia de herramienta y suelta lo que hubiera elegido.
  ///
  /// Quien manda el evento ya se ha ocupado del aviso si el borrador tenía
  /// cambios: aquí sólo se aplica lo decidido.
  void _onToolChanged(
    FernieToolChangedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    if (state.tool == event.tool) return;

    emit(state.copyWith(tool: event.tool).withSelection());
  }

  /// Elige una región y arranca su borrador con el rectángulo que ya tenía.
  void _onRegionSelected(
    RegionSelectedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    final index = event.index;

    if (index == null) {
      emit(state.withSelection());
      return;
    }

    final all = state.views;
    if (index < 0 || index >= all.length) {
      emit(state.withSelection());
      return;
    }

    emit(state.withSelection(
      selectedIndex: index,
      draftRect: all[index].rect,
    ));
  }

  void _onDraftResized(
    RegionDraftResizedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    if (state.selectedIndex == null) return;

    emit(state.withSelection(
      selectedIndex: state.selectedIndex,
      draftRect: event.rect,
      draftFernie: state.draftFernie,
    ));
  }

  void _onDraftReassigned(
    RegionDraftReassignedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    if (state.selectedIndex == null) return;

    emit(state.withSelection(
      selectedIndex: state.selectedIndex,
      draftRect: state.draftRect,
      draftFernie: event.fernie,
    ));
  }

  /// Baja el borrador a los cambios de la sesión y suelta la región.
  ///
  /// Sigue sin tocar la base de datos: lo que hace es pasar de «esto es lo que
  /// estoy tocando ahora» a «esto es lo que se guardará al aceptar el modo».
  void _onEditsConfirmed(
    RegionEditsConfirmedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    final region = state.selectedRegion;
    if (region == null || !state.hasDraftEdits) {
      emit(state.withSelection());
      return;
    }

    final rect = state.draftRect;
    final fernie = state.draftFernie;

    if (region.savedId case final id?) {
      emit(state
          .copyWith(
            edited: rect == null ? state.edited : {...state.edited, id: rect},
            reassigned: fernie == null
                ? state.reassigned
                : {...state.reassigned, id: fernie.id},
            fernies: _withFernie(fernie),
          )
          .withSelection());
      return;
    }

    final index = region.pendingIndex;
    if (index == null) {
      emit(state.withSelection());
      return;
    }

    final pending = [...state.pending];
    pending[index] = pending[index].copyWith(
      rect: rect,
      fernieId: fernie?.id,
    );

    emit(state
        .copyWith(pending: pending, fernies: _withFernie(fernie))
        .withSelection());
  }

  void _onEditsDiscarded(
    RegionEditsDiscardedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    emit(state.withSelection());
  }

  /// La lista de fernies con [fernie] dentro, para que su nombre se pueda pintar
  /// en el acto aunque todavía no tenga ninguna región guardada aquí.
  List<FernieEntity> _withFernie(FernieEntity? fernie) {
    if (fernie == null) return state.fernies;
    if (state.fernies.any((other) => other.id == fernie.id)) {
      return state.fernies;
    }

    return [...state.fernies, fernie];
  }

  void _onRegionDeleted(
    RegionDeletedEvent event,
    Emitter<FernieModeState> emit,
  ) {
    final view = _viewAt(event.index);
    if (view == null) return;

    if (view.savedId case final id?) {
      emit(state
          .copyWith(
            deleted: {...state.deleted, id},
            // Lo que se borra deja de tener edición que guardar.
            edited: {...state.edited}..remove(id),
            reassigned: {...state.reassigned}..remove(id),
          )
          .withSelection());
      return;
    }

    final index = view.pendingIndex;
    if (index == null) return;

    emit(state
        .copyWith(pending: [...state.pending]..removeAt(index))
        .withSelection());
  }

  void _onUndoLastRegion(
    UndoLastRegionEvent event,
    Emitter<FernieModeState> emit,
  ) {
    if (state.pending.isEmpty) return;

    emit(state.copyWith(pending: [...state.pending]..removeLast()));
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  RegionView? _viewAt(int index) {
    final views = state.views;
    if (index < 0 || index >= views.length) return null;

    return views[index];
  }

  FernieRegionEntity? _savedById(int id) {
    for (final region in state.saved) {
      if (region.id == id) return region;
    }
    return null;
  }

  Future<List<FernieRegionEntity>> _regionsOf(int mediaId) async {
    final result = await _getRegions(params: mediaId);

    return result is DataSuccess
        ? result.data ?? const <FernieRegionEntity>[]
        : const <FernieRegionEntity>[];
  }

  Future<List<FernieEntity>> _ferniesOf(int mediaId) async {
    final result = await _getFernies(params: mediaId);

    return result is DataSuccess
        ? result.data ?? const <FernieEntity>[]
        : const <FernieEntity>[];
  }
}
