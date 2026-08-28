import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:isar/isar.dart';

class FernieRepositoryImpl implements FernieRepository {
  final Isar _database;
  final AvatarStorageService _avatarStorage;

  /// Qué hacer cuando cambia lo que está marcado como no apto.
  ///
  /// Llega de fuera —es rehacer el índice— porque el índice vive en el dominio
  /// del contenido y aquí no se sabe nada de él. Igual que en el repositorio de
  /// la biblioteca: quien marca no tiene que acordarse de avisar a nadie.
  ///
  /// No sólo lo llama marcar. Un fernie se esconde también por la etiqueta que
  /// propone, y un modelo por los fernies que aprende, así que cambiar el enlace
  /// o borrar un fernie mueve el filtro sin que nadie haya tocado una marca.
  final Future<void> Function()? _onNsfwChanged;

  FernieRepositoryImpl({
    required Isar database,
    required AvatarStorageService avatarStorage,
    Future<void> Function()? onNsfwChanged,
  })  : _database = database,
        _avatarStorage = avatarStorage,
        _onNsfwChanged = onNsfwChanged;

  // ---------------------------------------------------------------------------
  // Fernies
  // ---------------------------------------------------------------------------

  @override
  Future<DataState<List<FernieEntity>>> getFernies() async {
    try {
      final models = await _database.fernieModels.where().findAll();
      return DataSuccess(await _toEntities(models));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<FernieEntity>> getFernie(int id) async {
    try {
      final model = await _database.fernieModels.get(id);
      if (model == null) {
        return DataException(Exception('Fernie $id no existe'));
      }

      final entities = await _toEntities([model]);
      return DataSuccess(entities.first);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Búsqueda por nombre, sin índice: los fernies son pocos comparados con el
  /// contenido, así que se recorren igual que las etiquetas.
  @override
  Future<DataState<List<FernieEntity>>> searchFernies(String query) async {
    try {
      final needle = query.trim();
      if (needle.isEmpty) return const DataSuccess([]);

      final models = await _database.fernieModels
          .filter()
          .nameContains(needle, caseSensitive: false)
          .findAll();

      return DataSuccess(await _toEntities(models));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<FernieEntity>> saveFernie(FernieEntity fernie) async {
    try {
      final model = FernieModel.fromEntity(fernie);

      await _database.writeTxn(() async {
        await _database.fernieModels.put(model);
      });

      return getFernie(model.id);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Escribe los datos nuevos del fernie.
  ///
  /// El avatar anterior se borra cuando ha cambiado: es una copia nuestra en la
  /// carpeta de avatares y, sin el fernie que la usaba, no la reclama nadie.
  @override
  Future<DataState<FernieEntity>> updateFernie(FernieEntity fernie) async {
    try {
      final previous = await _database.fernieModels.get(fernie.id);
      if (previous == null) {
        return DataException(Exception('Fernie ${fernie.id} no existe'));
      }

      final previousPicture = previous.picturePath;

      await _database.writeTxn(() async {
        previous
          ..name = fernie.name
          ..picturePath = fernie.picturePath
          ..linkedTagId = fernie.linkedTagId
          ..linkedCreatorId = fernie.linkedCreatorId;

        await _database.fernieModels.put(previous);
      });

      if (previousPicture != null && previousPicture != fernie.picturePath) {
        await _avatarStorage.remove(previousPicture);
      }

      // El enlace ha podido cambiar, y de él depende si el fernie se esconde.
      await _onNsfwChanged?.call();

      return getFernie(fernie.id);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Marca o desmarca el fernie, y rehace el índice antes de contestar.
  ///
  /// Se escribe sólo este campo y no la fila entera: la ficha puede tener
  /// cambios sin guardar en el nombre o en el enlace, y tocar el interruptor no
  /// es guardarlos.
  @override
  Future<DataState<bool>> setFernieNsfw(int id, {required bool isNsfw}) async {
    try {
      final model = await _database.fernieModels.get(id);
      if (model == null) return DataException(Exception('Fernie $id no existe'));

      if (model.isNsfw == isNsfw) return const DataSuccess(true);

      await _database.writeTxn(() async {
        model.isNsfw = isNsfw;
        await _database.fernieModels.put(model);
      });

      await _onNsfwChanged?.call();

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> deleteFernie(int id) async {
    try {
      final model = await _database.fernieModels.get(id);
      if (model == null) return const DataSuccess(false);

      final regionIds = await _regionIdsOf(id);
      final picturePath = model.picturePath;

      await _database.writeTxn(() async {
        await _database.fernieRegionModels.deleteAll(regionIds);
        await _database.fernieModels.delete(id);
      });

      await _avatarStorage.remove(picturePath);

      // Borrar la última clase normal de un modelo lo deja hablando sólo de lo
      // marcado: lo que se esconde no es sólo este fernie.
      await _onNsfwChanged?.call();

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Regiones
  // ---------------------------------------------------------------------------

  /// Guarda todas las regiones en una sola transacción.
  ///
  /// Es lo que exige el modo fernie: se marcan varias regiones seguidas y
  /// aceptar las guarda todas o ninguna. A medias sería peor que no guardar,
  /// porque el usuario creería que está hecho.
  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  ) async {
    try {
      if (regions.isEmpty) return const DataSuccess([]);

      final saved = <FernieRegionModel>[];

      await _database.writeTxn(() async {
        for (final region in regions) {
          final fernie = await _database.fernieModels.get(region.fernieId);
          if (fernie == null) continue;

          final model = FernieRegionModel.fromEntity(region);
          await _database.fernieRegionModels.put(model);

          model.fernie.value = fernie;
          await model.fernie.save();

          saved.add(model);
        }
      });

      return DataSuccess([
        for (final model in saved) model.toEntity(),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<FernieRegionEntity>> updateRegion(
    FernieRegionEntity region,
  ) async {
    try {
      final model = await _database.fernieRegionModels.get(region.id);
      if (model == null) {
        return DataException(Exception('La región ${region.id} no existe'));
      }

      await _database.writeTxn(() async {
        model
          ..x = region.x
          ..y = region.y
          ..w = region.w
          ..h = region.h
          ..frameMs = region.frameMs;

        await _database.fernieRegionModels.put(model);

        // Reasignar la región a otro fernie es cambiar el enlace, no marcarla de
        // nuevo: las coordenadas ya estaban bien puestas.
        await model.fernie.load();
        if (model.fernie.value?.id != region.fernieId) {
          final fernie = await _database.fernieModels.get(region.fernieId);
          if (fernie != null) {
            model.fernie.value = fernie;
            await model.fernie.save();
          }
        }
      });

      return DataSuccess(model.toEntity(fernieId: region.fernieId));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> deleteRegion(int id) async {
    try {
      var deleted = false;
      await _database.writeTxn(() async {
        deleted = await _database.fernieRegionModels.delete(id);
      });
      return DataSuccess(deleted);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<int>> deleteRegionsOfMedia(List<int> mediaIds) async {
    try {
      if (mediaIds.isEmpty) return const DataSuccess(0);

      final ids = <int>[];
      for (final mediaId in mediaIds) {
        ids.addAll(
          await _database.fernieRegionModels
              .filter()
              .mediaIdEqualTo(mediaId)
              .idProperty()
              .findAll(),
        );
      }

      if (ids.isEmpty) return const DataSuccess(0);

      var count = 0;
      await _database.writeTxn(() async {
        count = await _database.fernieRegionModels.deleteAll(ids);
      });

      return DataSuccess(count);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfFernie(
    int fernieId,
  ) async {
    try {
      final models = await _regionsOf(fernieId);
      return DataSuccess([
        for (final model in models) model.toEntity(fernieId: fernieId),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(
    int mediaId,
  ) async {
    try {
      final models = await _database.fernieRegionModels
          .filter()
          .mediaIdEqualTo(mediaId)
          .findAll();

      final entities = <FernieRegionEntity>[];
      for (final model in models) {
        await model.fernie.load();
        entities.add(model.toEntity());
      }

      return DataSuccess(entities);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<FernieEntity>>> getFerniesOfMedia(int mediaId) async {
    try {
      final models = await _database.fernieRegionModels
          .filter()
          .mediaIdEqualTo(mediaId)
          .findAll();

      final fernies = <int, FernieModel>{};
      for (final model in models) {
        await model.fernie.load();

        final fernie = model.fernie.value;
        if (fernie != null) fernies[fernie.id] = fernie;
      }

      return DataSuccess(await _toEntities(fernies.values.toList()));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<FernieRegionMediaEntity>>> getMediaOfFernie(
    int fernieId,
  ) async {
    try {
      final regions = await _regionsOf(fernieId);
      if (regions.isEmpty) return const DataSuccess([]);

      // Un mismo contenido puede tener varias regiones del mismo fernie, así
      // que se lee una vez y se reparte: la rejilla saca una celda por región,
      // no por contenido.
      final mediaIds = {for (final region in regions) region.mediaId}.toList();
      final summaries = await _database.mediaSummaryModels.getAll(mediaIds);

      final byId = <int, MediaSummaryModel>{
        for (final summary in summaries.nonNulls) summary.id: summary,
      };

      final result = <FernieRegionMediaEntity>[];

      // Regiones que apuntan a contenido que ya no está en la base de datos.
      //
      // No debería haber ninguna: el borrado definitivo se las lleva. Se
      // recogen igual, y se van al vuelo, porque una región huérfana no se
      // puede ver ni entrenar y sí seguiría contando en el recuento del fernie,
      // que es lo que decide si hay muestras suficientes.
      final orphans = <int>[];

      for (final region in regions) {
        final summary = byId[region.mediaId];
        if (summary == null) {
          orphans.add(region.id);
          continue;
        }

        result.add(FernieRegionMediaEntity(
          region: region.toEntity(fernieId: fernieId),
          media: summary.toEntity(),
        ));
      }

      if (orphans.isNotEmpty) {
        await _database.writeTxn(
          () => _database.fernieRegionModels.deleteAll(orphans),
        );
      }

      return DataSuccess(result);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  Future<List<FernieRegionModel>> _regionsOf(int fernieId) async {
    final fernie = await _database.fernieModels.get(fernieId);
    if (fernie == null) return const [];

    await fernie.regions.load();

    // Por orden de marcado: es el orden en el que el usuario las hizo, y es lo
    // único que da una rejilla estable entre visitas.
    final regions = fernie.regions.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return regions;
  }

  Future<List<int>> _regionIdsOf(int fernieId) async {
    final regions = await _regionsOf(fernieId);
    return [for (final region in regions) region.id];
  }

  /// Pasa los modelos a entidades resolviendo lo que no está en la fila: los
  /// cuatro recuentos y el nombre de lo enlazado.
  Future<List<FernieEntity>> _toEntities(List<FernieModel> models) async {
    final entities = <FernieEntity>[];

    // Qué contenidos son definitivos se pregunta **una vez para toda la lista**
    // y no una por fernie: con doce fernies que comparten biblioteca, lo segundo
    // son doce lecturas para responder lo mismo.
    final regionsOf = <int, List<FernieRegionModel>>{};

    for (final model in models) {
      await model.regions.load();
      regionsOf[model.id] = model.regions.toList();
    }

    final definitive = await _definitiveAmong({
      for (final regions in regionsOf.values)
        for (final region in regions) region.mediaId,
    });

    for (final model in models) {
      final regions = regionsOf[model.id] ?? const <FernieRegionModel>[];
      final usable = [
        for (final region in regions)
          if (definitive.contains(region.mediaId)) region,
      ];

      entities.add(model.toEntity(
        regionCount: regions.length,
        mediaCount: {for (final region in regions) region.mediaId}.length,
        usableRegionCount: usable.length,
        usableMediaCount: {for (final region in usable) region.mediaId}.length,
        linkedName: await _linkedName(model),
      ));
    }

    entities.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return entities;
  }

  /// Cuáles de estos contenidos ya son definitivos.
  ///
  /// Lo que no está en la base de datos tampoco está aquí, y eso es lo correcto:
  /// una región huérfana no entrena, igual que una que espera revisión.
  Future<Set<int>> _definitiveAmong(Set<int> mediaIds) async {
    if (mediaIds.isEmpty) return const {};

    final summaries =
        await _database.mediaSummaryModels.getAll(mediaIds.toList());

    return {
      for (final summary in summaries.nonNulls)
        if (summary.isImported) summary.id,
    };
  }

  /// Cómo se llama la etiqueta o el creador enlazado.
  ///
  /// Si ya no está se devuelve `null` y el fernie se lee como auxiliar: el
  /// identificador sigue guardado, pero no hay nada que enseñar ni nada que
  /// proponer. Es lo que pasa al borrar la etiqueta con la que se enlazó.
  Future<String?> _linkedName(FernieModel model) async {
    final tagId = model.linkedTagId;
    if (tagId != null) {
      final tag = await _database.tagModels.get(tagId);
      return tag?.name;
    }

    final creatorId = model.linkedCreatorId;
    if (creatorId != null) {
      final creator = await _database.creatorModels.get(creatorId);
      return creator?.name;
    }

    return null;
  }
}
