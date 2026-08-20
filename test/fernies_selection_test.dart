// Comprueba que marcar una celda de la rejilla de fernies marca el tramo
// entero, y que borrar se lleva todas sus regiones.
//
// Agrupar los fotogramas seguidos de un video en una sola celda es cosa de la
// interfaz: por debajo siguen siendo las regiones que son. Si al marcar la celda
// solo entrara la primera, borrar dejaria el resto del tramo suelto en la base
// de datos, con el fernie contando regiones que ya no se ven en ninguna parte.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_of_fernie_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
import 'package:flutter_test/flutter_test.dart';

const _media = MediaSummaryEntity(id: 1, path: 'clip.mp4');

FernieRegionMediaEntity _at(int id, int frameMs) => FernieRegionMediaEntity(
      region: FernieRegionEntity(
        id: id,
        mediaId: _media.id,
        fernieId: 1,
        x: 0.1,
        y: 0.1,
        w: 0.2,
        h: 0.2,
        frameMs: frameMs,
      ),
      media: _media,
    );

/// Repositorio de mentira que anota lo que le borran.
class _FakeRepository implements FernieRepository {
  final List<FernieRegionMediaEntity> entries;
  final List<int> deleted = [];

  _FakeRepository(this.entries);

  @override
  Future<DataState<List<FernieEntity>>> getFernies() async =>
      DataSuccess([FernieEntity(id: 1, name: 'Katara')]);

  @override
  Future<DataState<List<FernieRegionMediaEntity>>> getMediaOfFernie(
    int fernieId,
  ) async {
    return DataSuccess([
      for (final entry in entries)
        if (!deleted.contains(entry.region.id)) entry,
    ]);
  }

  @override
  Future<DataState<bool>> deleteRegion(int id) async {
    deleted.add(id);
    return const DataSuccess(true);
  }

  // El resto del contrato no lo toca esta pantalla.
  @override
  Future<DataState<FernieEntity>> getFernie(int id) async =>
      DataException(Exception('sin usar'));

  @override
  Future<DataState<List<FernieEntity>>> searchFernies(String query) async =>
      const DataSuccess([]);

  @override
  Future<DataState<FernieEntity>> saveFernie(FernieEntity fernie) async =>
      DataSuccess(fernie);

  @override
  Future<DataState<FernieEntity>> updateFernie(FernieEntity fernie) async =>
      DataSuccess(fernie);

  @override
  Future<DataState<bool>> deleteFernie(int id) async => const DataSuccess(true);

  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  ) async =>
      DataSuccess(regions);

  @override
  Future<DataState<FernieRegionEntity>> updateRegion(
    FernieRegionEntity region,
  ) async =>
      DataSuccess(region);

  @override
  Future<DataState<int>> deleteRegionsOfMedia(List<int> mediaIds) async =>
      const DataSuccess(0);

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfFernie(
    int fernieId,
  ) async =>
      const DataSuccess([]);

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(
    int mediaId,
  ) async =>
      const DataSuccess([]);

  @override
  Future<DataState<List<FernieEntity>>> getFerniesOfMedia(int mediaId) async =>
      const DataSuccess([]);
}

FerniesBloc _blocOf(_FakeRepository repository) => FerniesBloc(
      getFernies: GetFerniesUseCase(repository),
      getMediaOfFernie: GetMediaOfFernieUseCase(repository),
      deleteRegion: DeleteFernieRegionUseCase(repository),
    );

/// Deja que el bloc atienda lo que tenga en cola.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('marcar una celda marca todo su tramo', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 33), _at(3, 66)]);
    final bloc = _blocOf(repository);

    bloc.add(const ToggleRegionSelectionEvent(1, alsoRegionIds: [2, 3]));
    await _settle();

    expect(bloc.state.selectedRegionIds, {1, 2, 3});

    // Y desmarcarla los suelta a todos: la celda es una y se comporta como tal.
    bloc.add(const ToggleRegionSelectionEvent(1, alsoRegionIds: [2, 3]));
    await _settle();

    expect(bloc.state.selectedRegionIds, isEmpty);

    await bloc.close();
  });

  test('borrar la celda se lleva el tramo entero', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 33), _at(3, 66)]);
    final bloc = _blocOf(repository);

    bloc.add(const ToggleRegionSelectionEvent(1, alsoRegionIds: [2, 3]));
    bloc.add(const DeleteSelectedRegionsEvent());
    await _settle();
    await _settle();

    // Ninguna se queda atrás: media escena borrada dejaría al fernie contando
    // regiones que ya no salen en ninguna parte.
    expect(repository.deleted..sort(), [1, 2, 3]);

    await bloc.close();
  });

  test('mayusculas estira la seleccion hasta la celda pulsada', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 5000), _at(3, 9000)]);
    final bloc = _blocOf(repository);

    const cells = [
      [1],
      [2],
      [3],
    ];

    // Se marca la primera, y con mayusculas se estira hasta la tercera.
    bloc.add(const ToggleRegionSelectionEvent(1));
    bloc.add(const SelectRegionRangeEvent(
      regionIds: [3],
      orderedCells: cells,
    ));
    await _settle();

    expect(bloc.state.selectedRegionIds, {1, 2, 3});

    await bloc.close();
  });

  test('sin punto de partida, estirar solo marca la celda pulsada', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 5000)]);
    final bloc = _blocOf(repository);

    bloc.add(const SelectRegionRangeEvent(
      regionIds: [2],
      orderedCells: [
        [1],
        [2],
      ],
    ));
    await _settle();

    expect(bloc.state.selectedRegionIds, {2});

    await bloc.close();
  });

  test('el rango se lleva los tramos enteros', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 33), _at(3, 5000)]);
    final bloc = _blocOf(repository);

    // La primera celda agrupa dos fotogramas: entra entera o no entra.
    bloc.add(const ToggleRegionSelectionEvent(3));
    bloc.add(const SelectRegionRangeEvent(
      regionIds: [1, 2],
      orderedCells: [
        [1, 2],
        [3],
      ],
    ));
    await _settle();

    expect(bloc.state.selectedRegionIds, {1, 2, 3});

    await bloc.close();
  });

  test('una celda suelta sigue marcándose sola', () async {
    final repository = _FakeRepository([_at(1, 0), _at(2, 5000)]);
    final bloc = _blocOf(repository);

    bloc.add(const ToggleRegionSelectionEvent(1));
    await _settle();

    expect(bloc.state.selectedRegionIds, {1});

    await bloc.close();
  });
}
