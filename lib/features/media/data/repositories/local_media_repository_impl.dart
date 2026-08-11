import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:isar/isar.dart';


class LocalMediaRepositoryImpl implements LocalMediaRepository {

  final Isar _appDatabase;

  LocalMediaRepositoryImpl({required this._appDatabase});


  int _fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xff;
      hash *= 0x100000001b3;
    }
    return hash;
  }


  Future<void> _saveBatch(List<MediaModel> models) async {
    await _appDatabase.writeTxn(() async {
      await _appDatabase.mediaModels.putAll(models);
    });
  }


  /// Creador "Unknown", creándolo la primera vez que hace falta.
  ///
  /// Es el creador con el que nacen los contenidos recién escaneados y el
  /// respaldo cuando el creador de un contenido ya no existe en la base.
  Future<CreatorModel> _unknownCreator() async {
    final existing = await _appDatabase.creatorModels
        .filter()
        .nameEqualTo(unknownCreator.name)
        .findFirst();
    if (existing != null) return existing;

    final model = CreatorModel.fromEntity(unknownCreator);
    await _appDatabase.writeTxn(() async {
      model.id = await _appDatabase.creatorModels.put(model);
    });
    return model;
  }


  @override
  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath) {
    return scanDirectory(rootPath);
  }


  @override
  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath) async* {
    try {
      final dir = Directory(rootPath);
      if (!await dir.exists()) {
        yield DataException(Exception("Directory does not exist: $rootPath"));
        return;
      }

      final validExtensions = {'.jpg', '.jpeg', '.webp', '.gif', '.png', '.mp4', '.mov', '.avi'};

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final path = entity.path;
          final lastDotIndex = path.lastIndexOf('.');

          if (lastDotIndex != -1) {
            final extension = path.substring(lastDotIndex).toLowerCase();
            if (validExtensions.contains(extension)) {
              final id = _fastHash(path);

              // 1. COMPROBAR SI YA EXISTE (Escaneado o Definitivo)
              final existing = await _appDatabase.mediaSummaryModels.get(id);

              if (existing == null) {
                // 2. CREAR NUEVO SUMARIO
                final newSummary = MediaSummaryModel()
                  ..id = id
                  ..path = path
                  ..isImported = false;

                // 3. CREAR LOS DETALLES POR DEFECTO: sin descripción, sin
                // etiquetas, sin origen y con el creador desconocido. Queda
                // marcado como no importado, es decir, pendiente de revisión.
                final details = MediaModel(id: id, path: path)
                  ..downloaded = DateTime.now()
                  ..isFavorite = false
                  ..description = null;

                final creator = await _unknownCreator();

                // 4. GUARDAR AUTOMÁTICAMENTE
                await _appDatabase.writeTxn(() async {
                  await _appDatabase.mediaSummaryModels.put(newSummary);
                  await _appDatabase.mediaModels.put(details);

                  details.creator.value = creator;
                  await details.creator.save();

                  newSummary.details.value = details;
                  await newSummary.details.save();
                });

                yield DataSuccess(newSummary.toEntity());
              }
            }
          }
        }
      }
    } on Exception catch (e) {
      yield DataException(e);
    }
  }

  @override
  Future<DataState> saveScannedMedia(List<MediaEntity> mediaList) async {
    try {
      final models = mediaList.map((e) => MediaModel.fromEntity(e)).toList();
      await _saveBatch(models);

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }


  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaList() async {
    try {
      // Devolvemos solo el contenido DEFINITIVO
      final query = await _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(true)
          .findAll();

      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<MediaSummaryEntity>>> getScannedMedia() async {
    try {
      // Devolvemos solo el contenido ESCANEADO pendiente de importar
      final query = await _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(false)
          .findAll();

      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<MediaEntity>> getMediaDetails(int id) async {
    try {
      final query = await _appDatabase.mediaModels.get(id);
      if (query == null) {
        return DataException(Exception("Media not found"));
      }

      // Los enlaces de Isar son perezosos: sin cargarlos, el creador y las
      // etiquetas llegarían vacíos a la pantalla de información.
      await query.creator.load();
      await query.tags.load();
      await query.source.load();

      final summary = await _appDatabase.mediaSummaryModels.get(id);

      return DataSuccess(query.toEntity(isImported: summary?.isImported ?? false));

    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState> saveMedia(MediaEntity media) async {
    try {
      // 1. Get or fallback for Creator
      final creatorModel = await _appDatabase.creatorModels.get(media.creator.id)
          ?? await _unknownCreator();

      // 2. Handle Tags
      final List<TagModel> tagModels = [];
      if (media.tags != null) {
        for (final tagEntity in media.tags!) {
          final tagModel = await _appDatabase.tagModels.get(tagEntity.id);
          if (tagModel == null) {
            return DataException(Exception("Tag '${tagEntity.name}' does not exist."));
          }
          tagModels.add(tagModel);
        }
      }

      // 3. Get or fallback for Source
      TagModel? sourceModel;
      if (media.source != null) {
        sourceModel = await _appDatabase.tagModels.get(media.source!.id);
        if (sourceModel == null) {
          sourceModel = await _appDatabase.tagModels.filter().nameEqualTo("Unknown").findFirst();
          if (sourceModel == null) {
            sourceModel = TagModel.fromEntity(unknownTag);
            await _appDatabase.writeTxn(() async {
              sourceModel!.id = await _appDatabase.tagModels.put(sourceModel!);
            });
          }
        }
      }

      final model = MediaModel.fromEntity(media);

      await _appDatabase.writeTxn(() async {
        // Guardar detalles
        await _appDatabase.mediaModels.put(model);

        // MARCAR COMO IMPORTADO en el sumario
        final summary = await _appDatabase.mediaSummaryModels.get(media.id);
        if (summary != null) {
          summary.isImported = true;
          await _appDatabase.mediaSummaryModels.put(summary);
        }

        model.creator.value = creatorModel;
        await model.creator.save();

        model.tags.clear();
        model.tags.addAll(tagModels);
        await model.tags.save();

        if (sourceModel != null) {
          model.source.value = sourceModel;
          await model.source.save();
        }
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borra el contenido de la base de datos, sumario y detalles.
  ///
  /// El fichero del disco **no se toca**: al desaparecer su fila, la ruta
  /// vuelve a estar disponible y el siguiente escaneo la recoge otra vez.
  @override
  Future<DataState> deleteMedia(int id) async {
    try {
      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaSummaryModels.delete(id);
        await _appDatabase.mediaModels.delete(id);
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borrado masivo, en una sola transacción.
  ///
  /// Mismo criterio que [deleteMedia]: los ficheros del disco no se tocan, así
  /// que el siguiente escaneo vuelve a recoger esas rutas.
  @override
  Future<DataState> deleteMediaList(List<int> ids) async {
    try {
      if (ids.isEmpty) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaSummaryModels.deleteAll(ids);
        await _appDatabase.mediaModels.deleteAll(ids);
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Confirmación masiva: sólo se marca el sumario como importado.
  ///
  /// Los detalles ya existen desde el escaneo (creador desconocido, sin
  /// descripción ni etiquetas), así que confirmar sin revisar es exactamente
  /// dejarlos como están; no hace falta reescribirlos.
  @override
  Future<DataState> confirmMediaList(List<int> ids) async {
    try {
      if (ids.isEmpty) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        final summaries = await _appDatabase.mediaSummaryModels.getAll(ids);
        final pending = summaries.nonNulls.where((s) => !s.isImported).toList();
        if (pending.isEmpty) return;

        for (final summary in pending) {
          summary.isImported = true;
        }
        await _appDatabase.mediaSummaryModels.putAll(pending);
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Guarda la etiqueta y, si se indica [parent], la cuelga de ella para
  /// formar la jerarquía.
  ///
  /// Devuelve la etiqueta con el identificador que le ha dado Isar, que es el
  /// que hace falta para relacionarla después con un contenido.
  @override
  Future<DataState<TagEntity>> saveTag(TagEntity tag, {TagEntity? parent}) async {
    try {
      final model = TagModel.fromEntity(tag);

      await _appDatabase.writeTxn(() async {
        model.id = await _appDatabase.tagModels.put(model);

        if (parent == null) return;

        final parentModel = await _appDatabase.tagModels.get(parent.id);
        if (parentModel == null) return;

        parentModel.children.add(model);
        await parentModel.children.save();
      });

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Guarda el creador, enlaces de redes sociales incluidos, y lo devuelve con
  /// el identificador que le ha dado Isar.
  @override
  Future<DataState<CreatorEntity>> saveCreator(CreatorEntity creator) async {
    try {
      final model = CreatorModel.fromEntity(creator);

      await _appDatabase.writeTxn(() async {
        model.id = await _appDatabase.creatorModels.put(model);
      });

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<TagEntity>>> getTags() async {
    try {
      final query = await _appDatabase.tagModels.where().findAll();
      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<CreatorEntity>>> getCreators() async {
    try {
      final query = await _appDatabase.creatorModels.where().findAll();
      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Las sugerencias de los buscadores salen de aquí: se busca por parecido
  /// sobre el nombre, sin distinguir mayúsculas, y se corta el resultado en
  /// [limit] para no traer de la base más de lo que se va a pintar.
  @override
  Future<DataState<List<TagEntity>>> searchTags(
    String query, {
    int limit = searchSuggestionsLimit,
  }) async {
    try {
      final term = query.trim();
      if (term.isEmpty) return const DataSuccess([]);

      final results = await _appDatabase.tagModels
          .filter()
          .nameContains(term, caseSensitive: false)
          .limit(limit)
          .findAll();

      return DataSuccess(results.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<CreatorEntity>>> searchCreators(
    String query, {
    int limit = searchSuggestionsLimit,
  }) async {
    try {
      final term = query.trim();
      if (term.isEmpty) return const DataSuccess([]);

      final results = await _appDatabase.creatorModels
          .filter()
          .nameContains(term, caseSensitive: false)
          .limit(limit)
          .findAll();

      return DataSuccess(results.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Sugerencias del buscador principal.
  ///
  /// Se pregunta a las tres colecciones y se van tomando resultados por turnos
  /// (contenido, etiqueta, creador) hasta llegar a [limit]: así un término que
  /// aparece en muchas descripciones no deja fuera a las etiquetas ni a los
  /// creadores que también encajan.
  @override
  Future<DataState<List<SearchSuggestionEntity>>> searchSuggestions(
    String query, {
    int limit = mediaSearchSuggestionsLimit,
  }) async {
    try {
      final term = query.trim();
      if (term.isEmpty) return const DataSuccess([]);

      final byType = [
        [
          for (final media in await _mediaByDescription(term, limit: limit))
            SearchSuggestionEntity(
              id: media.id!,
              type: SearchResultType.media,
              label: media.description!,
              imagePath: media.path,
            ),
        ],
        [
          for (final tag in await _tagsByName(term, limit: limit))
            SearchSuggestionEntity(
              id: tag.id,
              type: SearchResultType.tag,
              label: tag.name,
              imagePath: tag.picturePath,
            ),
        ],
        [
          for (final creator in await _creatorsByName(term, limit: limit))
            SearchSuggestionEntity(
              id: creator.id,
              type: SearchResultType.creator,
              label: creator.name,
              imagePath: creator.picturePath,
            ),
        ],
      ];

      final suggestions = <SearchSuggestionEntity>[];
      for (var round = 0; suggestions.length < limit; round++) {
        final available = byType.where((list) => round < list.length);
        if (available.isEmpty) break;

        for (final list in available) {
          suggestions.add(list[round]);
          if (suggestions.length == limit) break;
        }
      }

      return DataSuccess(suggestions);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Búsqueda de contenido para la rejilla, ya agrupada y en el orden en el que
  /// se pinta: primero las coincidencias por descripción, luego un grupo por
  /// cada etiqueta cuyo nombre encaje y por último uno por cada creador.
  ///
  /// Los grupos que se quedan sin contenido definitivo no se devuelven: una
  /// etiqueta puede existir sin que nadie la haya usado todavía.
  @override
  Future<DataState<List<MediaSearchSectionEntity>>> searchMedia(String query) async {
    try {
      final term = query.trim();
      if (term.isEmpty) return const DataSuccess([]);

      final sections = <MediaSearchSectionEntity>[];

      final byDescription = await _importedSummaries(await _mediaByDescription(term));
      if (byDescription.isNotEmpty) {
        sections.add(MediaSearchSectionEntity(
          type: SearchResultType.media,
          title: term,
          media: byDescription,
        ));
      }

      for (final tag in await _tagsByName(term)) {
        final section = await _tagSection(tag);
        if (section != null) sections.add(section);
      }

      for (final creator in await _creatorsByName(term)) {
        final section = await _creatorSection(creator);
        if (section != null) sections.add(section);
      }

      return DataSuccess(sections);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Contenido de una sola sugerencia.
  ///
  /// Se busca por el identificador de la entidad elegida, no por su nombre: al
  /// pulsar el creador "Pompeu" salen sus contenidos y nada más, aunque exista
  /// una etiqueta "Pompeu no boken" que también contenga la palabra.
  ///
  /// Un grupo vacío se devuelve igualmente como lista vacía de grupos, que es lo
  /// que la rejilla pinta como "aquí no hay nada".
  @override
  Future<DataState<List<MediaSearchSectionEntity>>> searchMediaBySuggestion(
    SearchSuggestionEntity suggestion,
  ) async {
    try {
      final section = switch (suggestion.type) {
        SearchResultType.tag =>
          await _tagSection(await _appDatabase.tagModels.get(suggestion.id)),
        SearchResultType.creator => await _creatorSection(
            await _appDatabase.creatorModels.get(suggestion.id),
          ),
        SearchResultType.media => await _mediaSection(suggestion),
      };

      return DataSuccess(section == null ? const [] : [section]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Grupo de una etiqueta: su contenido definitivo, o `null` si no tiene (o si
  /// la etiqueta ya no está en la base).
  Future<MediaSearchSectionEntity?> _tagSection(TagModel? tag) async {
    if (tag == null) return null;

    final media = await _importedSummaries(
      await _appDatabase.mediaModels
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .findAll(),
    );
    if (media.isEmpty) return null;

    return MediaSearchSectionEntity(
      type: SearchResultType.tag,
      title: tag.name,
      imagePath: tag.picturePath,
      media: media,
    );
  }

  Future<MediaSearchSectionEntity?> _creatorSection(CreatorModel? creator) async {
    if (creator == null) return null;

    final media = await _importedSummaries(
      await _appDatabase.mediaModels
          .filter()
          .creator((q) => q.idEqualTo(creator.id))
          .findAll(),
    );
    if (media.isEmpty) return null;

    return MediaSearchSectionEntity(
      type: SearchResultType.creator,
      title: creator.name,
      imagePath: creator.picturePath,
      media: media,
    );
  }

  /// Grupo de una sugerencia que ya es un contenido: sólo ese contenido, con su
  /// descripción como título.
  Future<MediaSearchSectionEntity?> _mediaSection(
    SearchSuggestionEntity suggestion,
  ) async {
    final summary = await _appDatabase.mediaSummaryModels.get(suggestion.id);
    if (summary == null || !summary.isImported) return null;

    return MediaSearchSectionEntity(
      type: SearchResultType.media,
      title: suggestion.label,
      imagePath: suggestion.imagePath,
      media: [summary.toEntity()],
    );
  }

  /// Contenidos con una descripción parecida a [term].
  ///
  /// El recorte a [limit] se hace sobre los que además son definitivos, no
  /// sobre la consulta: si no, el corte podría llevarse por delante justo los
  /// que se iban a mostrar.
  Future<List<MediaModel>> _mediaByDescription(String term, {int? limit}) async {
    final results = await _appDatabase.mediaModels
        .filter()
        .descriptionContains(term, caseSensitive: false)
        .findAll();

    if (limit == null) return results;

    final imported = <MediaModel>[];
    for (final media in results) {
      final summary = await _appDatabase.mediaSummaryModels.get(media.id!);
      if (summary == null || !summary.isImported) continue;

      imported.add(media);
      if (imported.length == limit) break;
    }
    return imported;
  }

  Future<List<TagModel>> _tagsByName(String term, {int? limit}) {
    final query =
        _appDatabase.tagModels.filter().nameContains(term, caseSensitive: false);

    return limit == null ? query.findAll() : query.limit(limit).findAll();
  }

  Future<List<CreatorModel>> _creatorsByName(String term, {int? limit}) {
    final query = _appDatabase.creatorModels
        .filter()
        .nameContains(term, caseSensitive: false);

    return limit == null ? query.findAll() : query.limit(limit).findAll();
  }

  /// Sumarios **definitivos** de los contenidos indicados, en el mismo orden.
  ///
  /// Lo pendiente de revisar vive en la pantalla de importación, así que no
  /// tiene nada que hacer en los resultados de búsqueda.
  Future<List<MediaSummaryEntity>> _importedSummaries(List<MediaModel> media) async {
    if (media.isEmpty) return const [];

    final summaries = await _appDatabase.mediaSummaryModels
        .getAll(media.map((e) => e.id!).toList());

    return summaries.nonNulls
        .where((summary) => summary.isImported)
        .map((summary) => summary.toEntity())
        .toList();
  }
}