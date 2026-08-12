import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
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
  final MediaFileOrganizer _fileOrganizer;
  final AvatarStorageService _avatarStorage;

  LocalMediaRepositoryImpl({
    required Isar appDatabase,
    required MediaFileOrganizer fileOrganizer,
    required AvatarStorageService avatarStorage,
  })  : _appDatabase = appDatabase,
        _fileOrganizer = fileOrganizer,
        _avatarStorage = avatarStorage;


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
              //
              // Se mira por identificador y también por ruta: el
              // identificador es el hash de la ruta con la que se escaneó, así
              // que un contenido que la aplicación haya movido a la carpeta de
              // la biblioteca ya no coincide por hash y volvería a entrar como
              // si fuera nuevo.
              final existing = await _appDatabase.mediaSummaryModels.get(id) ??
                  await _appDatabase.mediaSummaryModels
                      .filter()
                      .pathEqualTo(path)
                      .findFirst();

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
      // Devolvemos solo el contenido DEFINITIVO que no esté marcado para borrar
      final query = await _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(true)
          .isDeletedEqualTo(false)
          .findAll();

      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<MediaSummaryEntity>>> getScannedMedia() async {
    try {
      // Devolvemos solo el contenido ESCANEADO pendiente de importar.
      //
      // Lo pendiente no se llega a marcar nunca (se descarta de la base de datos
      // directamente), pero el filtro se queda: si alguna fila quedara marcada,
      // esta pantalla no es su sitio.
      final query = await _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(false)
          .isDeletedEqualTo(false)
          .findAll();

      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Contenido marcado para borrar, venga de donde venga: en la pantalla de
  /// eliminados conviven lo definitivo y lo que estaba pendiente de revisar.
  @override
  Future<DataState<List<MediaSummaryEntity>>> getDeletedMedia() async {
    try {
      final query = await _appDatabase.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(true)
          .findAll();

      return DataSuccess(query.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Contenido favorito, el de la pantalla de favoritos.
  ///
  /// La marca vive en los detalles, así que se pregunta por ellos y se
  /// devuelven sus sumarios: los mismos que pinta la rejilla de contenido. Lo
  /// pendiente de revisar y lo marcado para borrar se quedan fuera, como en las
  /// búsquedas: cada uno tiene su pantalla.
  @override
  Future<DataState<List<MediaSummaryEntity>>> getFavoriteMedia() async {
    try {
      final media = await _appDatabase.mediaModels
          .filter()
          .isFavoriteEqualTo(true)
          .findAll();

      return DataSuccess(await _importedSummaries(media));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Pone o quita la marca de favorito de un contenido.
  ///
  /// Sólo se toca ese campo: los enlaces (creador, etiquetas y origen) se
  /// guardan aparte en Isar, así que reescribir la fila no los pierde.
  @override
  Future<DataState> setMediaFavorite(int id, {required bool isFavorite}) async {
    try {
      final model = await _appDatabase.mediaModels.get(id);
      if (model == null) return DataException(Exception("Media not found"));
      if (model.isFavorite == isFavorite) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        model.isFavorite = isFavorite;
        await _appDatabase.mediaModels.put(model);
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<MediaEntity>> getMediaDetails(int id) async {
    try {
      final media = await _loadedDetails(id);
      if (media == null) {
        return DataException(Exception("Media not found"));
      }

      return DataSuccess(media);
    } on Exception catch (e) {
      return DataException(e);
    }
  }


  /// Detalles de un contenido con sus enlaces ya cargados.
  ///
  /// Los enlaces de Isar son perezosos: sin cargarlos, el creador, las
  /// etiquetas y el origen llegarían vacíos tanto a la pantalla de información
  /// como al organizador de ficheros, que es justo lo que usa para decidir la
  /// subcarpeta.
  Future<MediaEntity?> _loadedDetails(int id) async {
    final model = await _appDatabase.mediaModels.get(id);
    if (model == null) return null;

    await model.creator.load();
    await model.tags.load();
    await model.source.load();

    final summary = await _appDatabase.mediaSummaryModels.get(id);

    return model.toEntity(isImported: summary?.isImported ?? false);
  }


  /// Coloca el fichero de [media] donde digan los ajustes de archivos y, si ha
  /// cambiado de sitio, actualiza la ruta en el sumario y en los detalles.
  ///
  /// El identificador no cambia: es el hash de la ruta con la que se escaneó y
  /// mantenerlo es lo que hace que el contenido siga siendo el mismo después de
  /// moverlo.
  /// Devuelve la ruta nueva, o `null` si el fichero se ha quedado donde
  /// estaba.
  Future<String?> _relocatedPath(MediaEntity media) async {
    final newPath = await _fileOrganizer.organize(media);
    if (newPath == null) return null;

    await _appDatabase.writeTxn(() async {
      final summary = await _appDatabase.mediaSummaryModels.get(media.id);
      if (summary != null) {
        summary.path = newPath;
        await _appDatabase.mediaSummaryModels.put(summary);
      }

      final details = await _appDatabase.mediaModels.get(media.id);
      if (details != null) {
        details.path = newPath;
        await _appDatabase.mediaModels.put(details);
      }
    });

    return newPath;
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

      // El contenido acaba de pasar a definitivo: si la aplicación gestiona los
      // ficheros, este es el momento de llevarlo a su carpeta. La ruta nueva se
      // devuelve porque quien ha guardado sigue enseñando el contenido y su
      // ruta ya no es la de antes.
      final newPath = await _relocatedPath(media.copyWith(isImported: true));

      return DataSuccess<String?>(newPath);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borra el contenido [id] sólo si su fichero ya no existe.
  ///
  /// La comprobación se hace contra la ruta guardada en la base de datos, que
  /// es la única que la aplicación reconoce: si el fichero se ha movido a otro
  /// sitio, ahí ya no está y la fila deja de servir para nada.
  ///
  /// Que el fichero siga estando y aun así no se haya podido pintar (formato no
  /// soportado, fichero corrupto, sin permisos) **no** borra nada: esos datos
  /// se han revisado a mano y no se pierden por un fallo pasajero.
  @override
  Future<DataState<bool>> deleteMissingMedia(int id) async {
    try {
      final summary = await _appDatabase.mediaSummaryModels.get(id);
      if (summary == null) return const DataSuccess(false);
      if (await File(summary.path).exists()) return const DataSuccess(false);

      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaSummaryModels.delete(id);
        await _appDatabase.mediaModels.delete(id);
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borrado real de varios contenidos, en una sola transacción.
  ///
  /// El fichero del disco **no se toca**: al desaparecer su fila, la ruta vuelve
  /// a estar disponible y el siguiente escaneo la recoge otra vez. Es lo que se
  /// hace al descartar contenido pendiente de revisar desde importación.
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

  /// Marcado para borrar, en una sola transacción.
  ///
  /// Nada sale de la base de datos: el contenido deja de verse en su pantalla y
  /// aparece en la de eliminados, desde donde se puede restablecer o borrar de
  /// verdad.
  @override
  Future<DataState> markMediaListAsDeleted(List<int> ids) =>
      _setDeletedFlag(ids, isDeleted: true);

  /// Deshace el marcado: el contenido vuelve a la pantalla que le toque según
  /// siga pendiente de revisar o ya sea definitivo.
  @override
  Future<DataState> restoreMediaList(List<int> ids) =>
      _setDeletedFlag(ids, isDeleted: false);

  Future<DataState> _setDeletedFlag(
    List<int> ids, {
    required bool isDeleted,
  }) async {
    try {
      if (ids.isEmpty) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        final summaries = await _appDatabase.mediaSummaryModels.getAll(ids);
        final pending = summaries.nonNulls
            .where((summary) => summary.isDeleted != isDeleted)
            .toList();
        if (pending.isEmpty) return;

        // La fecha se sella al marcar y se borra al restablecer: la semana de
        // gracia se cuenta desde este momento, así que restablecer y volver a
        // marcar la empieza de nuevo.
        final now = DateTime.now();

        for (final summary in pending) {
          summary.isDeleted = isDeleted;
          summary.deletedAt = isDeleted ? now : null;
        }
        await _appDatabase.mediaSummaryModels.putAll(pending);
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Vacía la papelera de lo que ya ha cumplido su semana y devuelve cuántos
  /// contenidos han salido de la base de datos.
  ///
  /// Como en el resto de borrados, los ficheros del disco no se tocan: lo que
  /// caduca vuelve a estar disponible para el siguiente escaneo.
  ///
  /// Lo marcado **sin fecha** se queda: no se puede saber cuándo caduca algo que
  /// no dice cuándo se marcó, y borrarlo por si acaso sería justo el error que
  /// esta pantalla existe para evitar.
  @override
  Future<DataState<int>> purgeExpiredDeletedMedia() async {
    try {
      final cutoff = DateTime.now().subtract(deletedRetention);

      // El nulo es el valor más pequeño en Isar, así que entraría en el
      // `lessThan` si no se descartara antes.
      final ids = await _appDatabase.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(true)
          .deletedAtIsNotNull()
          .deletedAtLessThan(cutoff)
          .idProperty()
          .findAll();

      if (ids.isEmpty) return const DataSuccess(0);

      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaSummaryModels.deleteAll(ids);
        await _appDatabase.mediaModels.deleteAll(ids);
      });

      return DataSuccess(ids.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borrado definitivo de todo lo que estuviera marcado, en una sola
  /// transacción.
  ///
  /// Los ficheros del disco **no se tocan**: al desaparecer sus filas, sus rutas
  /// vuelven a estar libres y el siguiente escaneo las recoge otra vez.
  @override
  Future<DataState<int>> purgeDeletedMedia() async {
    try {
      final ids = await _appDatabase.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(true)
          .idProperty()
          .findAll();

      if (ids.isEmpty) return const DataSuccess(0);

      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaSummaryModels.deleteAll(ids);
        await _appDatabase.mediaModels.deleteAll(ids);
      });

      return DataSuccess(ids.length);
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

      final confirmed = <int>[];

      await _appDatabase.writeTxn(() async {
        final summaries = await _appDatabase.mediaSummaryModels.getAll(ids);
        final pending = summaries.nonNulls.where((s) => !s.isImported).toList();
        if (pending.isEmpty) return;

        for (final summary in pending) {
          summary.isImported = true;
          confirmed.add(summary.id);
        }
        await _appDatabase.mediaSummaryModels.putAll(pending);
      });

      // Mismo trato que al guardar de uno en uno: lo que pasa a definitivo se
      // coloca en su carpeta.
      for (final id in confirmed) {
        final media = await _loadedDetails(id);
        if (media != null) await _relocatedPath(media);
      }

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }


  /// Reordena los ficheros de todo el contenido definitivo.
  ///
  /// Es la migración que se dispara desde los ajustes: recorre la biblioteca y
  /// aplica a cada contenido el mismo criterio que se aplica al importar, así
  /// que sirve tanto para colocar lo que ya estaba como para reorganizarlo todo
  /// después de cambiar de criterio.
  @override
  Future<DataState<int>> organizeLibraryFiles() async {
    try {
      final summaries = await _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(true)
          .isDeletedEqualTo(false)
          .findAll();

      var relocated = 0;
      for (final summary in summaries) {
        final media = await _loadedDetails(summary.id);
        if (media == null) continue;

        if (await _relocatedPath(media) != null) relocated++;
      }

      // Los criterios son excluyentes: lo que quede del anterior se vacía al
      // recolocar, y esas carpetas ya no dicen nada.
      await _fileOrganizer.removeEmptyFolders();

      return DataSuccess(relocated);
    } on Exception catch (e) {
      return DataException(e);
    }
  }


  /// Lleva los avatares de creadores y etiquetas a [targetDirectory].
  @override
  Future<DataState<int>> migrateAvatars({
    required String targetDirectory,
    String? previousDirectory,
  }) async {
    try {
      var relocated = 0;

      for (final creator in await _appDatabase.creatorModels.where().findAll()) {
        final path = creator.picturePath;
        if (path == null) continue;

        final newPath = await _avatarStorage.relocate(
          path,
          targetDirectory: targetDirectory,
          previousDirectory: previousDirectory,
        );
        if (newPath == null) continue;

        creator.picturePath = newPath;
        await _appDatabase.writeTxn(() async {
          await _appDatabase.creatorModels.put(creator);
        });
        relocated++;
      }

      for (final tag in await _appDatabase.tagModels.where().findAll()) {
        final path = tag.picturePath;
        if (path == null) continue;

        final newPath = await _avatarStorage.relocate(
          path,
          targetDirectory: targetDirectory,
          previousDirectory: previousDirectory,
        );
        if (newPath == null) continue;

        tag.picturePath = newPath;
        await _appDatabase.writeTxn(() async {
          await _appDatabase.tagModels.put(tag);
        });
        relocated++;
      }

      return DataSuccess(relocated);
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

  /// Las etiquetas en forma de árbol, para la sección de etiquetas del menú
  /// lateral.
  ///
  /// Isar no distingue raíces de hijas, así que las raíces se sacan por
  /// descarte: son las que no aparecen entre las hijas de ninguna otra.
  @override
  Future<DataState<List<TagEntity>>> getTagTree() async {
    try {
      final models = await _appDatabase.tagModels.where().findAll();

      final childIds = <int>{};
      for (final model in models) {
        await model.children.load();
        childIds.addAll(model.children.map((child) => child.id));
      }

      final roots = models.where((model) => !childIds.contains(model.id));

      // Un mismo identificador no se pinta dos veces: cuelgue de donde cuelgue,
      // una etiqueta aparece una sola vez, y así una jerarquía mal formada (con
      // un ciclo) no deja la lectura dando vueltas.
      final visited = <int>{};
      final tags = <TagEntity>[];
      for (final root in _byName(roots)) {
        if (!visited.add(root.id)) continue;
        tags.add(await _tagWithChildren(root, visited));
      }

      return DataSuccess(tags);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// La etiqueta con toda su descendencia, cargando los enlaces nivel a nivel:
  /// Isar los deja vacíos hasta que se piden.
  Future<TagEntity> _tagWithChildren(TagModel model, Set<int> visited) async {
    await model.children.load();

    final children = <TagEntity>[];
    for (final child in _byName(model.children)) {
      if (!visited.add(child.id)) continue;
      children.add(await _tagWithChildren(child, visited));
    }

    return TagEntity(
      id: model.id,
      name: model.name,
      picturePath: model.picturePath,
      children: children,
    );
  }

  /// Etiquetas ordenadas por nombre: el orden en el que las lee Isar es el de
  /// creación, que en un listado no dice nada.
  List<TagModel> _byName(Iterable<TagModel> tags) {
    return tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
    if (summary == null || !summary.isImported || summary.isDeleted) return null;

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
      if (summary == null || !summary.isImported || summary.isDeleted) continue;

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
  /// Lo pendiente de revisar vive en la pantalla de importación y lo marcado
  /// para borrar en la de eliminados, así que ninguno de los dos tiene nada que
  /// hacer en los resultados de búsqueda.
  Future<List<MediaSummaryEntity>> _importedSummaries(List<MediaModel> media) async {
    if (media.isEmpty) return const [];

    final summaries = await _appDatabase.mediaSummaryModels
        .getAll(media.map((e) => e.id!).toList());

    return summaries.nonNulls
        .where((summary) => summary.isImported && !summary.isDeleted)
        .map((summary) => summary.toEntity())
        .toList();
  }
}