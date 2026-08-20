import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_of_fernie_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'fernies_events.dart';
import 'fernies_states.dart';

/// Los fernies de la aplicación y las regiones del que esté elegido.
///
/// Es único y vive en el localizador por lo mismo que el de etiquetas: los
/// fernies se crean desde el "+" de la barra superior y desde el visor, y la
/// pantalla de gestión tiene que encontrárselos hechos al volver a ella.
class FerniesBloc extends Bloc<FerniesEvents, FerniesState> {
  final GetFerniesUseCase _getFernies;
  final GetMediaOfFernieUseCase _getMediaOfFernie;
  final DeleteFernieRegionUseCase _deleteRegion;

  /// La última celda con la que se hizo algo, que es desde donde se estira la
  /// selección al pulsar con mayúsculas.
  int? _selectionAnchorId;

  FerniesBloc({
    required GetFerniesUseCase getFernies,
    required GetMediaOfFernieUseCase getMediaOfFernie,
    required DeleteFernieRegionUseCase deleteRegion,
  })  : _getFernies = getFernies,
        _getMediaOfFernie = getMediaOfFernie,
        _deleteRegion = deleteRegion,
        super(const FerniesState()) {
    on<LoadFerniesEvent>(_onLoadFernies);
    on<FernieSelectedEvent>(_onFernieSelected);
    on<ReloadFernieRegionsEvent>(_onReloadRegions);
    on<ToggleRegionSelectionEvent>(_onToggleRegionSelection);
    on<SelectRegionRangeEvent>(_onSelectRegionRange);
    on<ClearRegionSelectionEvent>(_onClearRegionSelection);
    on<DeleteSelectedRegionsEvent>(_onDeleteSelectedRegions);
  }

  /// Relee la lista dejando a la vista la de antes.
  ///
  /// El fernie elegido se conserva si sigue existiendo; si ha desaparecido (lo
  /// normal después de borrarlo) la pantalla se queda sin selección y es ella
  /// quien elige el primero, igual que en la gestión de etiquetas.
  Future<void> _onLoadFernies(
    LoadFerniesEvent event,
    Emitter<FerniesState> emit,
  ) async {
    emit(state.copyWith(isBusy: true));

    final result = await _getFernies();
    final fernies = result is DataSuccess
        ? result.data ?? const <FernieEntity>[]
        : const <FernieEntity>[];

    final stillThere =
        fernies.any((fernie) => fernie.id == state.selectedFernieId);

    emit(FerniesState(
      fernies: fernies,
      isLoaded: true,
      selectedFernieId: stillThere ? state.selectedFernieId : null,
      regions: stillThere ? state.regions : const [],
      selectedRegionIds: stillThere ? state.selectedRegionIds : const {},
    ));
  }

  Future<void> _onFernieSelected(
    FernieSelectedEvent event,
    Emitter<FerniesState> emit,
  ) async {
    if (state.selectedFernieId == event.fernieId) return;

    emit(state.copyWith(
      selectedFernieId: event.fernieId,
      areRegionsBusy: true,
      // Lo marcado era de otro fernie: cambiar de fernie deja la selección sin
      // sentido.
      selectedRegionIds: const {},
    ));

    await _emitRegions(event.fernieId, emit);
  }

  Future<void> _onReloadRegions(
    ReloadFernieRegionsEvent event,
    Emitter<FerniesState> emit,
  ) async {
    final fernieId = state.selectedFernieId;
    if (fernieId == null) return;

    emit(state.copyWith(areRegionsBusy: true));
    await _emitRegions(fernieId, emit);
  }

  Future<void> _emitRegions(int fernieId, Emitter<FerniesState> emit) async {
    final result = await _getMediaOfFernie(params: fernieId);

    // Mientras se leían las regiones puede haberse elegido otro fernie: lo que
    // acaba de llegar ya no es de lo que se está mirando y se descarta.
    if (state.selectedFernieId != fernieId) return;

    emit(state.copyWith(
      regions: result is DataSuccess
          ? result.data ?? const <FernieRegionMediaEntity>[]
          : const <FernieRegionMediaEntity>[],
      areRegionsBusy: false,
    ));
  }

  void _onToggleRegionSelection(
    ToggleRegionSelectionEvent event,
    Emitter<FerniesState> emit,
  ) {
    final selected = Set<int>.from(state.selectedRegionIds);

    // Manda la primera: las de su tramo van con ella, marcadas o desmarcadas
    // todas juntas. En la rejilla son una sola celda y se comportan como tal.
    final wasSelected = selected.remove(event.regionId);
    if (!wasSelected) selected.add(event.regionId);

    for (final id in event.alsoRegionIds) {
      wasSelected ? selected.remove(id) : selected.add(id);
    }

    // Aquí se queda el punto de partida del siguiente estirón.
    _selectionAnchorId = event.regionId;

    emit(state.copyWith(selectedRegionIds: selected));
  }

  /// Marca todo lo que hay entre la última celda tocada y ésta, las dos
  /// incluidas.
  ///
  /// Lo que ya estuviera marcado sigue estándolo: el rango suma, nunca sustituye
  /// a la selección anterior.
  void _onSelectRegionRange(
    SelectRegionRangeEvent event,
    Emitter<FerniesState> emit,
  ) {
    final cells = event.orderedCells;
    final target = event.regionIds.firstOrNull;
    if (target == null) return;

    final targetIndex = cells.indexWhere((cell) => cell.contains(target));
    if (targetIndex < 0) return;

    final anchor = _selectionAnchorId;
    final anchorIndex =
        anchor == null ? -1 : cells.indexWhere((cell) => cell.contains(anchor));

    // Sin punto de partida (no hay nada marcado todavía, o lo que había ya no
    // está en la rejilla) no hay rango que valga: el clic marca esta celda y
    // deja aquí el punto de partida del siguiente.
    if (anchorIndex < 0) {
      _selectionAnchorId = target;
      emit(state.copyWith(
        selectedRegionIds: {...state.selectedRegionIds, ...event.regionIds},
      ));
      return;
    }

    final start = anchorIndex < targetIndex ? anchorIndex : targetIndex;
    final end = anchorIndex < targetIndex ? targetIndex : anchorIndex;

    emit(state.copyWith(selectedRegionIds: {
      ...state.selectedRegionIds,
      for (final cell in cells.sublist(start, end + 1)) ...cell,
    }));
  }

  void _onClearRegionSelection(
    ClearRegionSelectionEvent event,
    Emitter<FerniesState> emit,
  ) {
    _selectionAnchorId = null;
    emit(state.copyWith(selectedRegionIds: const {}));
  }

  /// Borra las regiones marcadas y vuelve a leer.
  ///
  /// Se releen las dos cosas: la rejilla porque le faltan celdas y la lista
  /// porque el recuento del fernie ha cambiado, y ese recuento es lo que decide
  /// si sale el aviso de que hay pocas regiones para entrenar.
  Future<void> _onDeleteSelectedRegions(
    DeleteSelectedRegionsEvent event,
    Emitter<FerniesState> emit,
  ) async {
    final ids = state.selectedRegionIds;
    if (ids.isEmpty) return;

    emit(state.copyWith(areRegionsBusy: true));

    for (final id in ids) {
      await _deleteRegion(params: id);
    }

    emit(state.copyWith(selectedRegionIds: const {}));

    add(const LoadFerniesEvent());
    add(const ReloadFernieRegionsEvent());
  }
}
