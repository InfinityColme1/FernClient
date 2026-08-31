// Comprueba las transiciones del modo fernie del visor: qué se guarda al
// aceptar, qué se descarta al cancelar y cómo se mezclan las regiones que ya
// estaban en la base de datos con las que se acaban de marcar.
//
// Los casos de uso se doblan a mano, como en el resto de pruebas del proyecto:
// lo que se comprueba es la máquina de estados, no Isar.

import 'dart:async';
import 'dart:ui';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/add_fernie_regions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_region_usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/apply_fernie_link_to_media_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_states.dart';
import 'package:flutter_test/flutter_test.dart';

const _mediaId = 7;

FernieEntity _fernie(int id, String name) => FernieEntity(id: id, name: name);

FernieRegionEntity _region(int id, Rect rect, {int fernieId = 1, int? frameMs}) {
  return FernieRegionEntity(
    id: id,
    mediaId: _mediaId,
    fernieId: fernieId,
    x: rect.left,
    y: rect.top,
    w: rect.width,
    h: rect.height,
    frameMs: frameMs,
  );
}

/// Repositorio de mentira que anota lo que le piden.
///
/// No guarda nada de verdad: lo que se comprueba es qué escrituras salen del
/// bloc y con qué, que es justo lo que decide si aceptar y cancelar hacen lo que
/// dicen que hacen.
class _FakeRepository implements FernieRepository {
  final List<FernieRegionEntity> regions;
  final List<FernieEntity> fernies;

  final List<List<FernieRegionEntity>> addedBatches = [];

  /// Cierre con el que se deja el alta a medias, para mirar el estado del bloc
  /// mientras la base de datos todavía está escribiendo.
  Completer<void>? addGate;
  final List<FernieRegionEntity> updated = [];
  final List<int> deleted = [];

  _FakeRepository({this.regions = const [], this.fernies = const []});

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(int mediaId) async =>
      DataSuccess(regions);

  @override
  Future<DataState<List<FernieEntity>>> getFerniesOfMedia(int mediaId) async =>
      DataSuccess(fernies);

  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  ) async {
    addedBatches.add(regions);
    await addGate?.future;
    return DataSuccess(regions);
  }

  @override
  Future<DataState<FernieRegionEntity>> updateRegion(
    FernieRegionEntity region,
  ) async {
    updated.add(region);
    return DataSuccess(region);
  }

  @override
  Future<DataState<bool>> deleteRegion(int id) async {
    deleted.add(id);
    return const DataSuccess(true);
  }

  // El resto del contrato no lo toca el modo fernie.
  @override
  Future<DataState<int>> deleteRegionsOfMedia(List<int> mediaIds) async =>
      const DataSuccess(0);

  @override
  Future<DataState<bool>> deleteFernie(int id) async => const DataSuccess(true);

  @override
  Future<DataState<bool>> setFernieNsfw(int id, {required bool isNsfw}) async =>
      const DataSuccess(true);

  @override
  Future<DataState<FernieEntity>> getFernie(int id) async =>
      DataSuccess(_fernie(id, 'x'));

  @override
  Future<DataState<List<FernieEntity>>> getFernies() async =>
      DataSuccess(fernies);

  @override
  Future<DataState<List<FernieRegionMediaEntity>>> getMediaOfFernie(
    int fernieId,
  ) async =>
      const DataSuccess([]);

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfFernie(
    int fernieId,
  ) async =>
      DataSuccess(regions);

  @override
  Future<DataState<FernieEntity>> saveFernie(FernieEntity fernie) async =>
      DataSuccess(fernie);

  @override
  Future<DataState<List<FernieEntity>>> searchFernies(String query) async =>
      DataSuccess(fernies);

  @override
  Future<DataState<FernieEntity>> updateFernie(FernieEntity fernie) async =>
      DataSuccess(fernie);
}

FernieModeBloc _blocOf(_FakeRepository repository, {_FakeMedia? media}) {
  return FernieModeBloc(
    getRegions: GetRegionsOfMediaUseCase(repository),
    getFernies: GetFerniesOfMediaUseCase(repository),
    addRegions: AddFernieRegionsUseCase(repository),
    updateRegion: UpdateFernieRegionUseCase(repository),
    deleteRegion: DeleteFernieRegionUseCase(repository),
    applyLink: media == null
        ? null
        : ApplyFernieLinkToMediaUseCase(media),
  );
}

/// Apunta qué se le ha puesto al contenido.
class _FakeMedia implements LocalMediaRepository {
  final tagged = <({int mediaId, List<int> tagIds})>[];
  final credited = <int>[];

  @override
  Future<DataState<int>> addTagsToMedia(int mediaId, List<int> tagIds) async {
    tagged.add((mediaId: mediaId, tagIds: tagIds));

    return DataSuccess(tagIds.length);
  }

  @override
  Future<DataState<bool>> setMediaCreator(
    int mediaId,
    int creatorId, {
    bool onlyIfMissing = false,
  }) async {
    credited.add(creatorId);

    return const DataSuccess(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Deja que el bloc atienda lo que tenga en cola.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('entrar y salir', () {
    test('el modo arranca en visualización', () {
      final bloc = _blocOf(_FakeRepository());

      expect(bloc.state.mode, ViewerMode.viewing);
      expect(bloc.state.isFernieMode, isFalse);
      expect(bloc.state.hasChanges, isFalse);
    });

    test('entrar recuerda si el panel estaba abierto', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const EnterFernieModeEvent(infoWasOpen: true));
      await _settle();

      expect(bloc.state.isFernieMode, isTrue);
      expect(bloc.state.infoWasOpen, isTrue);
    });

    test('guardar cierra el modo antes de escribir', () async {
      final gate = Completer<void>();
      final repository = _FakeRepository()..addGate = gate;
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'Katara'),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      // La escritura sigue en marcha...
      expect(repository.addedBatches, hasLength(1));
      expect(gate.isCompleted, isFalse);

      // ...y el modo ya está cerrado. Guardar es un gesto terminado y los
      // rectángulos se van con él: un tramo largo de vídeo son cientos de filas,
      // y dejarlos encima del contenido hasta que acabe la base de datos hace
      // que parezca que el visor se ha colgado.
      expect(bloc.state.mode, ViewerMode.viewing);
      expect(bloc.state.isBusy, isTrue, reason: 'pero se sabe que sigue');

      gate.complete();
      await _settle();

      expect(bloc.state.isBusy, isFalse);
    });

    test('salir sin cambios no escribe nada', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(bloc.state.mode, ViewerMode.viewing);
      expect(repository.addedBatches, isEmpty);
      expect(repository.updated, isEmpty);
      expect(repository.deleted, isEmpty);
    });
  });

  group('marcar regiones', () {
    test('cuatro regiones para dos fernies se guardan de una vez', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));

      for (var index = 0; index < 4; index++) {
        bloc.add(RegionAssignedEvent(
          rect: Rect.fromLTWH(0.1 * index, 0.1, 0.2, 0.2),
          fernie: _fernie(index.isEven ? 1 : 2, 'fernie ${index.isEven ? 1 : 2}'),
        ));
      }
      await _settle();

      expect(bloc.state.pending, hasLength(4));
      expect(bloc.state.hasChanges, isTrue);

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      // Una sola llamada con las cuatro: o entran todas, o no entra ninguna.
      expect(repository.addedBatches, hasLength(1));
      expect(repository.addedBatches.single, hasLength(4));

      final fernieIds =
          repository.addedBatches.single.map((region) => region.fernieId);
      expect(fernieIds, containsAll([1, 2]));
    });

    test('cancelar no escribe nada y suelta lo marcado', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.2, 0.2, 0.3, 0.3),
        fernie: _fernie(1, 'uno'),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: false));
      await _settle();

      expect(repository.addedBatches, isEmpty);
      expect(bloc.state.pending, isEmpty);
      expect(bloc.state.hasChanges, isFalse);
      expect(bloc.state.mode, ViewerMode.viewing);
    });

    test('deshacer quita la última marcada', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0, 0, 0.2, 0.2),
        fernie: _fernie(1, 'uno'),
      ));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.5, 0.5, 0.2, 0.2),
        fernie: _fernie(2, 'dos'),
      ));
      bloc.add(const UndoLastRegionEvent());
      await _settle();

      expect(bloc.state.pending, hasLength(1));
      expect(bloc.state.pending.single.fernieId, 1);
    });

    test('el fotograma se guarda con la región', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'uno'),
        frameMs: 12000,
      ));
      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(repository.addedBatches.single.single.frameMs, 12000);
    });
  });

  group('regiones que ya estaban', () {
    test('editar y borrar sólo baja a la base de datos al aceptar', () async {
      final repository = _FakeRepository(
        regions: [
          _region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2)),
          _region(11, const Rect.fromLTWH(0.5, 0.5, 0.2, 0.2)),
        ],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const FernieToolChangedEvent(FernieTool.edit));

      // Índice 0 es la primera guardada; índice 1, la segunda.
      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(Rect.fromLTWH(0.3, 0.3, 0.4, 0.4)));
      bloc.add(const RegionEditsConfirmedEvent());
      bloc.add(const RegionDeletedEvent(1));
      await _settle();

      expect(repository.updated, isEmpty, reason: 'todavía no se ha aceptado');
      expect(repository.deleted, isEmpty, reason: 'todavía no se ha aceptado');
      expect(bloc.state.hasChanges, isTrue);

      // Lo borrado desaparece de lo que se pinta, aunque siga en la base.
      expect(bloc.state.views, hasLength(1));
      expect(bloc.state.views.single.rect,
          const Rect.fromLTWH(0.3, 0.3, 0.4, 0.4));

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(repository.updated, hasLength(1));
      expect(repository.updated.single.id, 10);
      expect(repository.updated.single.x, closeTo(0.3, 0.0001));
      expect(repository.deleted, [11]);
    });

    test('cancelar revierte también los borrados', () async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const RegionDeletedEvent(0));
      await _settle();

      expect(bloc.state.views, isEmpty);

      bloc.add(const ExitFernieModeEvent(save: false));
      await _settle();

      expect(repository.deleted, isEmpty);
      // La región vuelve a estar a la vista: nunca llegó a irse.
      expect(bloc.state.views, hasLength(1));
      expect(bloc.state.views.single.savedId, 10);
    });

    test('las guardadas se pintan antes que las de esta sesión', () async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.6, 0.6, 0.2, 0.2),
        fernie: _fernie(2, 'dos'),
      ));
      await _settle();

      final views = bloc.state.views;
      expect(views, hasLength(2));
      expect(views.first.savedId, 10);
      expect(views.last.pendingIndex, 0);
      // El nombre del fernie recién elegido está disponible en el acto, aunque
      // todavía no tenga ninguna región guardada en este contenido.
      expect(views.last.label, 'dos');
    });
  });

  group('editar una región', () {
    /// Un bloc con una región guardada, ya en modo fernie y con la herramienta
    /// de editar puesta.
    Future<(FernieModeBloc, _FakeRepository)> editing() async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const FernieToolChangedEvent(FernieTool.edit));
      await _settle();

      return (bloc, repository);
    }

    test('el modo arranca con la herramienta de marcar', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      await _settle();

      expect(bloc.state.tool, FernieTool.mark);
      expect(bloc.state.isEditing, isFalse);
    });

    test('elegir una región arranca su borrador donde estaba', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      await _settle();

      expect(bloc.state.selectedIndex, 0);
      expect(bloc.state.draftRect, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2));
      // Sin tocar nada todavía no hay cambios que perder.
      expect(bloc.state.hasDraftEdits, isFalse);
    });

    test('estirar la región cuenta como cambio y no toca la sesión', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(Rect.fromLTWH(0.2, 0.2, 0.5, 0.5)));
      await _settle();

      expect(bloc.state.hasDraftEdits, isTrue);
      // El borrador se ve, pero todavía no es un cambio de la sesión.
      expect(bloc.state.visibleViews.single.rect,
          const Rect.fromLTWH(0.2, 0.2, 0.5, 0.5));
      expect(bloc.state.hasChanges, isFalse);
    });

    test('confirmar pasa el borrador a los cambios de la sesión', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(Rect.fromLTWH(0.2, 0.2, 0.5, 0.5)));
      bloc.add(const RegionEditsConfirmedEvent());
      await _settle();

      expect(bloc.state.selectedIndex, isNull, reason: 'se suelta al confirmar');
      expect(bloc.state.hasChanges, isTrue);
      expect(bloc.state.views.single.rect,
          const Rect.fromLTWH(0.2, 0.2, 0.5, 0.5));
    });

    test('descartar deja la región como estaba', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(Rect.fromLTWH(0.9, 0.9, 0.1, 0.1)));
      bloc.add(const RegionEditsDiscardedEvent());
      await _settle();

      expect(bloc.state.selectedIndex, isNull);
      expect(bloc.state.hasChanges, isFalse);
      expect(bloc.state.views.single.rect,
          const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2));
    });

    test('reasignar cambia el fernie de la región al confirmar', () async {
      final (bloc, repository) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(RegionDraftReassignedEvent(_fernie(2, 'dos')));
      await _settle();

      expect(bloc.state.hasDraftEdits, isTrue);
      expect(bloc.state.visibleViews.single.label, 'dos');

      bloc.add(const RegionEditsConfirmedEvent());
      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(repository.updated, hasLength(1));
      expect(repository.updated.single.fernieId, 2);
    });

    test('cambiar de herramienta suelta lo que hubiera elegido', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(Rect.fromLTWH(0.4, 0.4, 0.2, 0.2)));
      bloc.add(const FernieToolChangedEvent(FernieTool.mark));
      await _settle();

      expect(bloc.state.selectedIndex, isNull);
      expect(bloc.state.draftRect, isNull);
      // Lo del borrador se va con la selección: nunca llegó a ser un cambio.
      expect(bloc.state.hasChanges, isFalse);
    });

    test('borrar la región elegida la suelta', () async {
      final (bloc, _) = await editing();

      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDeletedEvent(0));
      await _settle();

      expect(bloc.state.selectedIndex, isNull);
      expect(bloc.state.views, isEmpty);
    });
  });

  group('qué fernies quedan atados al contenido', () {
    test('marcar una región ata su fernie al contenido', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'uno'),
      ));
      await _settle();

      expect(bloc.state.ferniesInMedia.map((f) => f.name), ['uno']);
    });

    test('borrar la única región de un fernie lo desata', () async {
      // El caso que reportó el usuario: marcar, asignar y borrar deja el fernie
      // colgando en el panel aunque no tenga ya nada marcado aquí.
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'uno'),
      ));
      await _settle();

      bloc.add(const RegionDeletedEvent(0));
      await _settle();

      expect(bloc.state.ferniesInMedia, isEmpty);

      // El catálogo sí se lo queda: el fernie se puede volver a elegir en el
      // mismo gesto y su nombre y su avatar tienen que seguir a mano. Lo que no
      // puede es seguir contando como atado al contenido.
      expect(bloc.state.fernies, hasLength(1));
    });

    test('borrar una región guardada desata su fernie en el acto', () async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      expect(bloc.state.ferniesInMedia, hasLength(1));

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const RegionDeletedEvent(0));
      await _settle();

      // Todavía no ha bajado a la base de datos, pero el contenido ya no está
      // atado a ese fernie: es lo que hay que enseñar.
      expect(bloc.state.ferniesInMedia, isEmpty);
    });

    test('con otra región del mismo fernie, borrar una no lo desata', () async {
      final repository = _FakeRepository(
        regions: [
          _region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2)),
          _region(11, const Rect.fromLTWH(0.5, 0.5, 0.2, 0.2)),
        ],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const RegionDeletedEvent(0));
      await _settle();

      expect(bloc.state.ferniesInMedia, hasLength(1));
    });

    test('reasignar la última región desata el fernie de origen', () async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const FernieToolChangedEvent(FernieTool.edit));
      bloc.add(const RegionSelectedEvent(0));
      bloc.add(RegionDraftReassignedEvent(_fernie(2, 'dos')));
      bloc.add(const RegionEditsConfirmedEvent());
      await _settle();

      expect(bloc.state.ferniesInMedia.map((f) => f.name), ['dos']);
    });

    test('cancelar devuelve el fernie que se había desatado', () async {
      final repository = _FakeRepository(
        regions: [_region(10, const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2))],
        fernies: [_fernie(1, 'uno')],
      );
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      await _settle();

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(const RegionDeletedEvent(0));
      bloc.add(const ExitFernieModeEvent(save: false));
      await _settle();

      // El borrado nunca llegó a pasar, así que el fernie sigue atado.
      expect(bloc.state.ferniesInMedia, hasLength(1));
    });
  });

  group('cambiar de contenido', () {
    test('leer otro contenido suelta lo pendiente del anterior', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'uno'),
      ));
      await _settle();

      bloc.add(const LoadMediaRegionsEvent(99));
      await _settle();

      expect(bloc.state.mediaId, 99);
      expect(bloc.state.pending, isEmpty);
      expect(bloc.state.hasChanges, isFalse);
    });
  });

  // Marcar una región de un fernie es decir que eso sale ahí. Si el fernie
  // enlaza una etiqueta, ponérsela al contenido es la consecuencia evidente — y
  // hasta ahora había que ir a ponerla a mano justo después de haber dicho de
  // qué se trataba.
  group('lo que el fernie enlaza', () {
    /// Un fernie con su etiqueta, que es lo que hace que haya algo que poner.
    FernieEntity linked(int id, String name, {int? tagId, int? creatorId}) =>
        FernieEntity(
          id: id,
          name: name,
          linkedTagId: tagId,
          linkedCreatorId: creatorId,
        );

    test('se le pone al contenido al guardar', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Marinette', tagId: 42)],
      );
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: linked(1, 'Marinette', tagId: 42),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(media.tagged, hasLength(1));
      expect(media.tagged.single.mediaId, _mediaId);
      expect(media.tagged.single.tagIds, [42]);
    });

    test('y el creador también', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Alguien', creatorId: 9)],
      );
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: linked(1, 'Alguien', creatorId: 9),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(media.credited, [9]);
    });

    // Un fernie que no enlaza nada no tiene nada que poner, y marcarlo sigue
    // siendo perfectamente válido: es lo que se hace al montar uno nuevo.
    test('sin enlace no se pone nada', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(fernies: [_fernie(1, 'suelto')]);
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'suelto'),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(media.tagged, isEmpty);
    });

    // Cancelar no escribe la región, así que tampoco puede etiquetar: sería
    // ponerle una etiqueta por un gesto que se ha deshecho.
    test('cancelar no etiqueta nada', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Marinette', tagId: 42)],
      );
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: linked(1, 'Marinette', tagId: 42),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: false));
      await _settle();

      expect(media.tagged, isEmpty);
    });

    // El panel tiene que enterarse en el momento. Sin esto había que salir del
    // visor y volver a entrar para ver la etiqueta puesta, y eso hacía dudar de
    // si se había puesto siquiera.
    test('y se avisa de que hay que releer las etiquetas', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Marinette', tagId: 42)],
      );
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: linked(1, 'Marinette', tagId: 42),
      ));
      await _settle();

      final before = bloc.state.appliedLinks;

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(bloc.state.appliedLinks, greaterThan(before));
    });

    // Un contador y no un interruptor: dos veces seguidas tienen que dar dos
    // avisos, o la segunda no se releería.
    test('y el aviso vale también la segunda vez', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Marinette', tagId: 42)],
      );
      final bloc = _blocOf(repository, media: media);

      for (var vuelta = 0; vuelta < 2; vuelta++) {
        bloc.add(const LoadMediaRegionsEvent(_mediaId));
        bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
        bloc.add(RegionAssignedEvent(
          rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
          fernie: linked(1, 'Marinette', tagId: 42),
        ));
        await _settle();

        bloc.add(const ExitFernieModeEvent(save: true));
        await _settle();
      }

      expect(media.tagged, hasLength(2));
    });

    // Sin nada que poner no hay nada que releer: avisar movería el panel para
    // enseñar lo mismo.
    test('sin enlace no se avisa', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(fernies: [_fernie(1, 'suelto')]);
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
        fernie: _fernie(1, 'suelto'),
      ));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(bloc.state.appliedLinks, 0);
    });

    // Los que ya estaban marcados de antes no vuelven a etiquetar: si lo
    // hicieran, mover un rectángulo un píxel devolvería una etiqueta que alguien
    // acababa de quitar a mano.
    test('los que ya estaban no vuelven a etiquetar', () async {
      final media = _FakeMedia();
      final repository = _FakeRepository(
        fernies: [linked(1, 'Marinette', tagId: 42)],
        regions: [
          FernieRegionEntity(
            id: 1,
            mediaId: _mediaId,
            fernieId: 1,
            x: 0.1,
            y: 0.1,
            w: 0.2,
            h: 0.2,
          ),
        ],
      );
      final bloc = _blocOf(repository, media: media);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      await _settle();

      // Se mueve la que ya estaba, sin marcar ninguna nueva.
      bloc.add(const RegionSelectedEvent(0));
      bloc.add(const RegionDraftResizedEvent(
        Rect.fromLTWH(0.15, 0.15, 0.2, 0.2),
      ));
      bloc.add(const RegionEditsConfirmedEvent());
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(media.tagged, isEmpty);
    });
  });

  // Lo que un modelo detecta, ofrecido para confirmarlo.
  //
  // El botón de «guardar como región» guardaba a ciegas lo que el modelo vio. Un
  // modelo que ve cuatro coches puede estar acertando en tres, y eso dejaba tres
  // regiones buenas y una que había que buscar y borrar. Ahora se dibujan y se
  // pulsa lo que esté bien.
  group('lo que el modelo propone', () {
    ProposedRegion proposal(double x, {double confidence = 0.9}) =>
        ProposedRegion(
          rect: Rect.fromLTWH(x, 0.1, 0.1, 0.1),
          fernieId: 1,
          confidence: confidence,
          label: 'coche',
        );

    test('entra al modo con ellas dibujadas', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4)],
      ));
      await _settle();

      expect(bloc.state.isFernieMode, isTrue);
      expect(bloc.state.proposed, hasLength(2));
    });

    // **Ninguna puesta**: que entraran solas obligaría a repasarlas para quitar
    // las malas, y salir sin mirar dejaría marcado lo que nadie ha confirmado.
    test('pero sin marcar ninguna', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4)],
      ));
      await _settle();

      expect(bloc.state.pending, isEmpty);
      expect(bloc.state.hasChanges, isFalse);
    });

    test('pulsar una la marca y la saca de las propuestas', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4)],
      ));
      await _settle();

      bloc.add(const ProposedRegionAcceptedEvent(0));
      await _settle();

      expect(bloc.state.pending, hasLength(1));
      expect(bloc.state.pending.single.rect.left, 0.1);
      expect(bloc.state.proposed, hasLength(1));
      expect(bloc.state.proposed.single.rect.left, 0.4);
    });

    // Con doce coches bien detectados, pulsarlos de uno en uno es el trabajo que
    // esto venía a ahorrar.
    test('y hay un botón para todas', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4), proposal(0.7)],
      ));
      await _settle();

      bloc.add(const AllProposedRegionsAcceptedEvent());
      await _settle();

      expect(bloc.state.pending, hasLength(3));
      expect(bloc.state.proposed, isEmpty);
    });

    test('una que no existe no rompe nada', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1)],
      ));
      await _settle();

      bloc.add(const ProposedRegionAcceptedEvent(9));
      await _settle();

      expect(bloc.state.pending, isEmpty);
      expect(bloc.state.proposed, hasLength(1));
    });

    // Proponer no es marcar: guardar lo que nadie ha confirmado sería marcar por
    // él.
    test('lo que quede sin aceptar no se guarda', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4)],
      ));
      await _settle();

      bloc.add(const ProposedRegionAcceptedEvent(0));
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: true));
      await _settle();

      expect(repository.addedBatches.single, hasLength(1));
      expect(bloc.state.proposed, isEmpty);
    });

    test('y cancelar no guarda ninguna', () async {
      final repository = _FakeRepository();
      final bloc = _blocOf(repository);

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1)],
      ));
      await _settle();

      bloc.add(const AllProposedRegionsAcceptedEvent());
      await _settle();

      bloc.add(const ExitFernieModeEvent(save: false));
      await _settle();

      expect(repository.addedBatches, isEmpty);
      expect(bloc.state.proposed, isEmpty);
    });

    // Cada fila del panel ofrece **sus** detecciones: arrastrar las de la
    // anterior mezclaría dos cosas distintas sobre el mismo contenido.
    test('ofrecer otras sustituye a las de antes', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1), proposal(0.4)],
      ));
      await _settle();

      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.7)],
      ));
      await _settle();

      expect(bloc.state.proposed, hasLength(1));
      expect(bloc.state.proposed.single.rect.left, 0.7);
    });

    // Ya dentro del modo, lo que se llevara marcado a mano se queda: ofrecer
    // detecciones no puede tirar el trabajo empezado.
    test('y no se lleva por delante lo ya marcado', () async {
      final bloc = _blocOf(_FakeRepository());

      bloc.add(const LoadMediaRegionsEvent(_mediaId));
      bloc.add(const EnterFernieModeEvent(infoWasOpen: false));
      bloc.add(RegionAssignedEvent(
        rect: const Rect.fromLTWH(0.5, 0.5, 0.1, 0.1),
        fernie: _fernie(1, 'a mano'),
      ));
      await _settle();

      bloc.add(ProposedRegionsOfferedEvent(
        infoWasOpen: false,
        regions: [proposal(0.1)],
      ));
      await _settle();

      expect(bloc.state.pending, hasLength(1));
      expect(bloc.state.proposed, hasLength(1));
    });
  });
}
