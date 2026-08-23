import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/core/utils/source_url.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;


class LocalMediaRepositoryImpl implements LocalMediaRepository {

  final Isar _appDatabase;
  final MediaFileOrganizer _fileOrganizer;
  final AvatarStorageService _avatarStorage;
  final MediaRegistry _registry;
  final TagHierarchy _tagHierarchy;

  LocalMediaRepositoryImpl({
    required Isar appDatabase,
    required MediaFileOrganizer fileOrganizer,
    required AvatarStorageService avatarStorage,
    required MediaRegistry registry,
    required TagHierarchy tagHierarchy,
  })  : _appDatabase = appDatabase,
        _fileOrganizer = fileOrganizer,
        _avatarStorage = avatarStorage,
        _registry = registry,
        _tagHierarchy = tagHierarchy;


  Future<void> _saveBatch(List<MediaModel> models) async {
    await _appDatabase.writeTxn(() async {
      await _appDatabase.mediaModels.putAll(models);
    });
  }


  @override
  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath) {
    return scanDirectory(rootPath);
  }


  /// Recorre la carpeta y da de alta lo que encuentra y todavía no está.
  ///
  /// El alta es la misma que la de cualquier otra fuente (la hace el registro),
  /// así que lo que se escanea del equipo nace igual que lo que se descarga de
  /// una plataforma: pendiente de revisar y con el creador desconocido.
  @override
  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath) async* {
    try {
      final dir = Directory(rootPath);
      if (!await dir.exists()) {
        yield DataException(Exception("Directory does not exist: $rootPath"));
        return;
      }

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;

        final path = entity.path;
        final extension = p.extension(path).toLowerCase();
        if (!mediaExtensions.contains(extension)) continue;

        final summary = await _registry.register(
          path: path,
          source: ImportSource.local,
        );
        if (summary != null) yield DataSuccess(summary);
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

  /// Contenido pendiente de revisar, el de la pantalla de importación.
  ///
  /// [source] es la fuente elegida en su desplegable: con [ImportSource.all] se
  /// devuelve lo de todas, y con cualquier otra sólo lo que vino de ella.
  @override
  Future<DataState<List<MediaSummaryEntity>>> getScannedMedia({
    ImportSource source = ImportSource.all,
  }) async {
    try {
      // Devolvemos solo el contenido ESCANEADO pendiente de importar.
      //
      // Lo pendiente no se llega a marcar nunca (se descarta de la base de datos
      // directamente), pero el filtro se queda: si alguna fila quedara marcada,
      // esta pantalla no es su sitio.
      final filter = _appDatabase.mediaSummaryModels
          .filter()
          .isImportedEqualTo(false)
          .isDeletedEqualTo(false);

      final query = await (source == ImportSource.all
              ? filter
              : filter.importSourceEqualTo(source.id))
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

  /// Marca de favorito de varios contenidos, en una sola transacción.
  ///
  /// Los que ya estuvieran como se pide se dejan en paz: reescribirlos no
  /// cambiaría nada y son los más, porque marcar una selección entera casi
  /// siempre alcanza a alguno que ya lo era.
  @override
  Future<DataState> setMediaListFavorite(
    List<int> ids, {
    required bool isFavorite,
  }) async {
    try {
      if (ids.isEmpty) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        final models = await _appDatabase.mediaModels.getAll(ids);
        final pending = models.nonNulls
            .where((model) => model.isFavorite != isFavorite)
            .toList();
        if (pending.isEmpty) return;

        for (final model in pending) {
          model.isFavorite = isFavorite;
        }
        await _appDatabase.mediaModels.putAll(pending);
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

    return model.toEntity(
      isImported: summary?.isImported ?? false,
      // De dónde llegó el contenido: lo mira el organizador de ficheros para
      // saber en qué carpeta va cuando se ordena por origen y la etiqueta de
      // plataforma no está puesta.
      importSource: ImportSource.fromId(summary?.importSource),
    );
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
          ?? await _registry.unknownCreatorModel();

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

        // Las etiquetas que llegan son las que tiene que tener, sin añadir
        // ninguna por su cuenta: las de encima en la jerarquía se proponen al
        // elegirlas, y quitar la madre dejando la hija es una decisión del
        // usuario que aquí se respeta. `reset` quita las de antes en la base de
        // datos, que es algo que `clear()` no hace (sólo vacía lo que Isar tiene
        // en memoria).
        await model.tags.update(link: tagModels, reset: true);

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

      await _purgeRows([id]);

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borrado real de varios contenidos, en una sola transacción. Es lo que se
  /// hace al descartar contenido pendiente de revisar desde importación.
  ///
  /// Sin [deleteFiles] el fichero del disco no se toca: al desaparecer su fila,
  /// la ruta vuelve a estar disponible y el siguiente escaneo la recoge otra
  /// vez. Con él, el fichero se va con la fila y no vuelve.
  @override
  Future<DataState> deleteMediaList(
    List<int> ids, {
    bool deleteFiles = false,
  }) async {
    try {
      if (ids.isEmpty) return DataSuccess(null);

      if (deleteFiles) await _deleteFilesOf(ids);

      await _purgeRows(ids);

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Saca de la base de datos las filas de [ids], con todo lo que cuelga de
  /// ellas.
  ///
  /// Es el **único** sitio por el que un contenido desaparece de verdad, y por
  /// eso es también donde se limpia lo que le acompaña: las regiones de fernie
  /// marcadas sobre él. Si cada sitio que borra hiciera su propia limpieza,
  /// tarde o temprano uno se olvidaría y quedarían regiones apuntando a un
  /// contenido que ya no está.
  ///
  /// Ojo con quién llama a esto: mandar a la papelera **no** pasa por aquí. De
  /// la papelera se vuelve, y perder el trabajo de marcado al restablecer sería
  /// perderlo sin haberlo pedido.
  Future<void> _purgeRows(List<int> ids) async {
    if (ids.isEmpty) return;

    final regionIds = <int>[];
    for (final mediaId in ids) {
      regionIds.addAll(
        await _appDatabase.fernieRegionModels
            .filter()
            .mediaIdEqualTo(mediaId)
            .idProperty()
            .findAll(),
      );
    }

    await _appDatabase.writeTxn(() async {
      await _appDatabase.mediaSummaryModels.deleteAll(ids);
      await _appDatabase.mediaModels.deleteAll(ids);
      await _appDatabase.fernieRegionModels.deleteAll(regionIds);
    });
  }

  /// Borra del disco los ficheros de [ids].
  ///
  /// Va antes de la baja porque la ruta está en la fila, y lo que no se pueda
  /// borrar (ya no está, lo tiene abierto otro programa) no detiene nada: el
  /// contenido sale de la aplicación igual.
  Future<void> _deleteFilesOf(List<int> ids) async {
    final summaries = await _appDatabase.mediaSummaryModels.getAll(ids);

    for (final summary in summaries.nonNulls) {
      await deleteFileAt(summary.path);
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
  /// Con [deleteFiles] se llevan también sus ficheros. Aquí no hay nadie a quien
  /// preguntar (la caducidad se pasa sola), así que manda lo último que el
  /// usuario eligiera al vaciar la papelera a mano.
  ///
  /// Lo marcado **sin fecha** se queda: no se puede saber cuándo caduca algo que
  /// no dice cuándo se marcó, y borrarlo por si acaso sería justo el error que
  /// esta pantalla existe para evitar.
  @override
  Future<DataState<int>> purgeExpiredDeletedMedia({
    bool deleteFiles = false,
  }) async {
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

      if (deleteFiles) await _deleteFilesOf(ids);

      await _purgeRows(ids);

      return DataSuccess(ids.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borrado definitivo de todo lo que estuviera marcado, en una sola
  /// transacción.
  ///
  /// Sin [deleteFiles] los ficheros del disco no se tocan: al desaparecer sus
  /// filas, sus rutas vuelven a estar libres y el siguiente escaneo las recoge
  /// otra vez. Con él, este borrado es definitivo también en el disco.
  @override
  Future<DataState<int>> purgeDeletedMedia({bool deleteFiles = false}) async {
    try {
      final ids = await _appDatabase.mediaSummaryModels
          .filter()
          .isDeletedEqualTo(true)
          .idProperty()
          .findAll();

      if (ids.isEmpty) return const DataSuccess(0);

      if (deleteFiles) await _deleteFilesOf(ids);

      await _purgeRows(ids);

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
      final model = TagModel.fromEntity(tag)
        ..sourceUrls = normalizedSourceUrls(tag.sourceUrls);

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

  /// Cambia los datos de una etiqueta que ya existe: su nombre, su avatar y de
  /// quién cuelga.
  ///
  /// El identificador no se toca, así que los contenidos que la tienen la siguen
  /// teniendo. [parent] manda siempre: se suelta de cualquier otra etiqueta que
  /// la tuviera entre sus hijas y, si llega `null`, se queda como etiqueta raíz.
  ///
  /// Un padre que cerraría el círculo se descarta: la etiqueta se queda con el
  /// que ya tenía, y el resto de sus datos se guarda igual.
  @override
  Future<DataState<TagEntity>> updateTag(TagEntity tag, {TagEntity? parent}) async {
    try {
      final model = await _appDatabase.tagModels.get(tag.id);
      if (model == null) return DataException(Exception("Tag not found"));

      final newParent = await _allowedParent(model, parent);

      await _appDatabase.writeTxn(() async {
        model.name = tag.name;
        model.picturePath = tag.picturePath;
        model.sourceUrls = normalizedSourceUrls(tag.sourceUrls);
        await _appDatabase.tagModels.put(model);

        // Quien la tuviera entre sus hijas la suelta, menos el padre nuevo si ya
        // era el que la tenía.
        final currentParents = await _appDatabase.tagModels
            .filter()
            .children((q) => q.idEqualTo(tag.id))
            .findAll();

        for (final currentParent in currentParents) {
          if (currentParent.id == newParent?.id) continue;

          // Se desenlaza pidiéndolo, no dejando fuera de la lista a la que se va:
          // `clear()` sólo vacía lo que Isar tiene en memoria, y al guardar
          // manda las altas pero ninguna baja, así que el enlace seguiría ahí.
          await currentParent.children.update(unlink: [model]);
        }

        if (newParent == null) return;

        final parentModel = await _appDatabase.tagModels.get(newParent.id);
        if (parentModel == null) return;

        parentModel.children.add(model);
        await parentModel.children.save();
      });

      await model.children.load();

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// El padre que se le puede dar a [model] cuando se pide [parent].
  ///
  /// Una etiqueta no puede colgar de sí misma ni de nada que cuelgue de ella (su
  /// hija, la hija de su hija...): sería un círculo, y el árbol de etiquetas se
  /// quedaría sin raíz por la que empezar a pintarlo, así que las dos etiquetas
  /// desaparecerían del menú lateral y de la lista.
  ///
  /// Lo que no se puede se descarta dejando el sitio que ya ocupa en la
  /// jerarquía: pedir un imposible no la mueve, y desde luego no la suelta de un
  /// padre que sí valía. Quedarse sin padre, en cambio, siempre vale: es lo que
  /// se pide al vaciar el campo o al quitarle el padre.
  Future<TagEntity?> _allowedParent(TagModel model, TagEntity? parent) async {
    if (parent == null) return null;

    final closesCircle =
        parent.id == model.id || await _descends(parent.id, from: model);

    return closesCircle ? await _currentParent(model) : parent;
  }

  /// La etiqueta que tiene a [model] entre sus hijas, si hay alguna.
  ///
  /// Sólo se usa para volver a dejarla donde estaba, así que llega sin sus hijas:
  /// de ella lo único que hace falta es el identificador.
  Future<TagEntity?> _currentParent(TagModel model) async {
    final parents = await _appDatabase.tagModels
        .filter()
        .children((q) => q.idEqualTo(model.id))
        .findAll();

    if (parents.isEmpty) return null;

    final parent = parents.first;
    return TagEntity(
      id: parent.id,
      name: parent.name,
      picturePath: parent.picturePath,
      children: const [],
    );
  }

  /// Si [tagId] cuelga de [from], a cualquier profundidad.
  Future<bool> _descends(int tagId, {required TagModel from}) async {
    final pending = <TagModel>[from];
    // Una jerarquía mal formada no deja la búsqueda dando vueltas: cada
    // etiqueta se mira una sola vez.
    final visited = <int>{from.id};

    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      await current.children.load();

      for (final child in current.children) {
        if (child.id == tagId) return true;
        if (visited.add(child.id)) pending.add(child);
      }
    }

    return false;
  }

  /// Deja en la etiqueta las direcciones de las que sale su contenido.
  ///
  /// Es lo único que se toca: el nombre, el avatar y la jerarquía se quedan como
  /// estaban, porque esto se guarda desde su propio diálogo y no desde el
  /// formulario de la etiqueta. Las direcciones llegan tal y como las escribió el
  /// usuario y se guardan normalizadas, que es la forma en la que se comparan al
  /// importar.
  @override
  Future<DataState<TagEntity>> saveTagSourceUrls(
    int tagId,
    List<String> urls,
  ) async {
    try {
      final model = await _appDatabase.tagModels.get(tagId);
      if (model == null) return DataException(Exception("Tag not found"));

      await _appDatabase.writeTxn(() async {
        model.sourceUrls = normalizedSourceUrls(urls);
        await _appDatabase.tagModels.put(model);
      });

      await model.children.load();

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Las etiquetas por encima de las indicadas.
  ///
  /// Llegan sin sus hijas: quien las pide es para ponerlas en un contenido, y
  /// para eso lo único que hace falta es el identificador y cómo se pintan.
  @override
  Future<DataState<List<TagEntity>>> getTagAncestors(List<TagEntity> tags) async {
    try {
      final ancestors =
          await _tagHierarchy.ancestorsOf(tags.map((tag) => tag.id));

      return DataSuccess([
        for (final model in ancestors)
          TagEntity(
            id: model.id,
            name: model.name,
            picturePath: model.picturePath,
            sourceUrls: model.sourceUrls,
            children: const [],
          ),
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borra una etiqueta y la quita de los contenidos que la tenían.
  ///
  /// Los contenidos se quedan donde están, con sus demás etiquetas: borrar una
  /// etiqueta es dejar de clasificar por ella, no perder lo clasificado. Las
  /// etiquetas que colgaban de ella pasan a ser raíces, porque el árbol se arma
  /// por descarte (raíz es la que no es hija de ninguna) y ya no hay quien las
  /// tenga.
  ///
  /// Su avatar sí desaparece del disco: es una copia que hizo la aplicación al
  /// ponerlo y no la usa nadie más, así que dejarlo sería ir llenando la carpeta
  /// de avatares de imágenes de etiquetas que ya no existen.
  @override
  Future<DataState> deleteTag(int tagId) async {
    try {
      final model = await _appDatabase.tagModels.get(tagId);
      if (model == null) return DataSuccess(null);

      final picturePath = model.picturePath;

      await _appDatabase.writeTxn(() async {
        // El enlace de vuelta da justo los contenidos que la tienen.
        await model.media.load();

        // Se desenlaza pidiéndolo: `clear()` sólo vacía lo que Isar tiene en
        // memoria y al guardar no manda ninguna baja.
        for (final media in model.media.toList()) {
          await media.tags.update(unlink: [model]);
        }

        await _appDatabase.tagModels.delete(tagId);
      });

      // Después de la baja: si el disco falla, la etiqueta ya no está y lo peor
      // que queda es una imagen suelta.
      await _avatarStorage.remove(picturePath);

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Contenido definitivo de una etiqueta, el de la rejilla de la pantalla de
  /// gestión de etiquetas.
  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaByTag(int tagId) async {
    try {
      final media = await _appDatabase.mediaModels
          .filter()
          .tags((q) => q.idEqualTo(tagId))
          .findAll();

      return DataSuccess(await _importedSummaries(media));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Deshace la relación entre una etiqueta y unos contenidos, en una sola
  /// transacción.
  ///
  /// Sólo se toca el enlace: la etiqueta sigue existiendo (con el resto de sus
  /// contenidos) y los contenidos siguen donde estaban, con sus demás etiquetas.
  @override
  Future<DataState> removeTagFromMedia(int tagId, List<int> mediaIds) async {
    try {
      if (mediaIds.isEmpty) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        final tagModel = await _appDatabase.tagModels.get(tagId);
        if (tagModel == null) return;

        final models = await _appDatabase.mediaModels.getAll(mediaIds);

        // Se desenlaza pidiéndolo: `clear()` sólo vacía lo que Isar tiene en
        // memoria y al guardar no manda ninguna baja. Los que no la tuvieran no
        // hace falta descartarlos: quitar un enlace que no está no hace nada.
        for (final model in models.nonNulls) {
          await model.tags.update(unlink: [tagModel]);
        }
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Guarda el creador, enlaces de redes sociales incluidos, y lo devuelve con
  /// el identificador que le ha dado Isar.
  ///
  /// El nombre tiene que estar libre: dos creadores que se llamen igual no se
  /// distinguirían ni en la lista ni en el buscador, así que si ya hay uno se
  /// devuelve [DuplicateCreatorNameException] y no se escribe nada.
  @override
  Future<DataState<CreatorEntity>> saveCreator(CreatorEntity creator) async {
    try {
      final name = creator.name.trim();

      final model = CreatorModel.fromEntity(creator)
        ..name = name
        ..sourceUrls = normalizedSourceUrls(creator.sourceUrls);

      // La comprobación va dentro de la misma transacción que el alta: fuera de
      // ella, dos altas seguidas del mismo nombre podrían pasar las dos.
      var isTaken = false;

      await _appDatabase.writeTxn(() async {
        isTaken = await _isCreatorNameTaken(name);
        if (isTaken) return;

        model.id = await _appDatabase.creatorModels.put(model);
      });

      if (isTaken) return DataException(DuplicateCreatorNameException(name));

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Hay ya un creador que se llama [name], sin contar el de [exceptId].
  ///
  /// Se compara sin distinguir mayúsculas: "Alguien" y "alguien" son el mismo
  /// creador escrito de dos maneras, y tenerlos por separado es justo lo que se
  /// quiere evitar. El identificador que se excluye es el del propio creador al
  /// renombrarlo: dejarle su nombre tal cual no puede ser un choque consigo
  /// mismo.
  Future<bool> _isCreatorNameTaken(String name, {int? exceptId}) async {
    final existing = await _appDatabase.creatorModels
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    return existing != null && existing.id != exceptId;
  }

  /// Cambia los datos de un creador que ya existe: su nombre, su avatar y sus
  /// enlaces de redes sociales.
  ///
  /// El identificador no se toca, así que los contenidos que lo tienen lo siguen
  /// teniendo. Las direcciones vinculadas no se tocan aquí: se guardan desde su
  /// propio diálogo ([saveCreatorSourceUrls]), no desde el formulario del
  /// creador.
  ///
  /// El nombre nuevo tiene que seguir estando libre, como al crearlo: si es el
  /// de otro creador se devuelve [DuplicateCreatorNameException] y el creador se
  /// queda como estaba.
  @override
  Future<DataState<CreatorEntity>> updateCreator(CreatorEntity creator) async {
    try {
      final model = await _appDatabase.creatorModels.get(creator.id);
      if (model == null) return DataException(Exception("Creator not found"));

      final name = creator.name.trim();

      var isTaken = false;

      await _appDatabase.writeTxn(() async {
        isTaken = await _isCreatorNameTaken(name, exceptId: creator.id);
        if (isTaken) return;

        model.name = name;
        model.picturePath = creator.picturePath;
        model.socialProfiles = creator.socialProfiles;
        await _appDatabase.creatorModels.put(model);
      });

      if (isTaken) return DataException(DuplicateCreatorNameException(name));

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Deja en el creador las direcciones de las que sale su contenido.
  ///
  /// Es lo único que se toca: el nombre, el avatar y los enlaces se quedan como
  /// estaban, porque esto se guarda desde su propio diálogo y no desde el
  /// formulario del creador. Las direcciones llegan tal y como las escribió el
  /// usuario y se guardan normalizadas, que es la forma en la que se comparan al
  /// importar.
  @override
  Future<DataState<CreatorEntity>> saveCreatorSourceUrls(
    int creatorId,
    List<String> urls,
  ) async {
    try {
      final model = await _appDatabase.creatorModels.get(creatorId);
      if (model == null) return DataException(Exception("Creator not found"));

      await _appDatabase.writeTxn(() async {
        model.sourceUrls = normalizedSourceUrls(urls);
        await _appDatabase.creatorModels.put(model);
      });

      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Borra un creador y deja sus contenidos con el creador desconocido.
  ///
  /// Los contenidos se quedan donde están: borrar un creador es dejar de
  /// distinguirlo, no perder lo suyo. Y no pueden quedarse sin ninguno, que un
  /// contenido siempre tiene creador; el desconocido es justo el respaldo para
  /// eso.
  ///
  /// Su avatar sí desaparece del disco: es una copia que hizo la aplicación al
  /// ponerlo y no la usa nadie más, así que dejarlo sería ir llenando la carpeta
  /// de avatares de imágenes de creadores que ya no existen.
  @override
  Future<DataState> deleteCreator(int creatorId) async {
    try {
      final model = await _appDatabase.creatorModels.get(creatorId);
      if (model == null) return DataSuccess(null);

      final picturePath = model.picturePath;

      // El creador desconocido se resuelve (creándolo si hiciera falta) antes de
      // la transacción: darlo de alta abre la suya propia.
      final unknown = await _registry.unknownCreatorModel();
      if (unknown.id == creatorId) {
        return DataException(Exception("The unknown creator cannot be deleted"));
      }

      await _appDatabase.writeTxn(() async {
        final media = await _appDatabase.mediaModels
            .filter()
            .creator((q) => q.idEqualTo(creatorId))
            .findAll();

        for (final item in media) {
          item.creator.value = unknown;
          await item.creator.save();
        }

        await _appDatabase.creatorModels.delete(creatorId);
      });

      // Después de la baja: si el disco falla, el creador ya no está y lo peor
      // que queda es una imagen suelta.
      await _avatarStorage.remove(picturePath);

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Contenido definitivo de un creador, el de la rejilla de la pantalla de
  /// gestión de creadores.
  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaByCreator(
    int creatorId,
  ) async {
    try {
      final media = await _appDatabase.mediaModels
          .filter()
          .creator((q) => q.idEqualTo(creatorId))
          .findAll();

      return DataSuccess(await _importedSummaries(media));
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  /// Deshace la relación entre un creador y unos contenidos, en una sola
  /// transacción.
  ///
  /// Los contenidos pasan al creador desconocido: no se quedan sin ninguno,
  /// porque un contenido siempre tiene creador. El creador sigue existiendo, con
  /// el resto de sus contenidos.
  @override
  Future<DataState> removeCreatorFromMedia(
    int creatorId,
    List<int> mediaIds,
  ) async {
    try {
      if (mediaIds.isEmpty) return DataSuccess(null);

      // Igual que al borrar: darlo de alta abre su propia transacción, así que
      // se resuelve antes.
      final unknown = await _registry.unknownCreatorModel();
      if (unknown.id == creatorId) return DataSuccess(null);

      await _appDatabase.writeTxn(() async {
        final models = await _appDatabase.mediaModels.getAll(mediaIds);

        for (final model in models.nonNulls) {
          // Los que no fueran suyos no hace falta descartarlos: al cargar el
          // enlace se ve de quién son y sólo se cambian los que toca.
          await model.creator.load();
          if (model.creator.value?.id != creatorId) continue;

          model.creator.value = unknown;
          await model.creator.save();
        }
      });

      return DataSuccess(null);
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
  Future<DataState<int>> addTagsToMedia(int mediaId, List<int> tagIds) async {
    try {
      final media = await _appDatabase.mediaModels.get(mediaId);
      if (media == null) {
        return DataException(Exception('El contenido $mediaId no existe'));
      }

      final asked = (await _appDatabase.tagModels.getAll(tagIds)).nonNulls
          .toList(growable: false);

      if (asked.isEmpty) return const DataSuccess(0);

      // Con las etiquetas van las que están por encima de ellas, igual que al
      // ponerlas a mano desde el diálogo. Sin esto, aceptar «Rombo simple» no
      // pone «Rombo» y el contenido no aparece al buscar por la etiqueta padre:
      // la misma acción daría dos resultados distintos según por dónde se haga.
      final withAncestors = await _tagHierarchy.withAncestors(asked);
      final tags = withAncestors.isEmpty ? asked : withAncestors;

      await _appDatabase.writeTxn(() async {
        // Sin `reset`: esto suma a lo que el contenido ya tuviera. Con `reset`
        // aceptar una sugerencia borraría las etiquetas puestas a mano.
        await media.tags.update(link: tags);
      });

      return DataSuccess(tags.length);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<bool>> setMediaCreator(int mediaId, int creatorId) async {
    try {
      final media = await _appDatabase.mediaModels.get(mediaId);
      final creator = await _appDatabase.creatorModels.get(creatorId);

      if (media == null || creator == null) return const DataSuccess(false);

      await _appDatabase.writeTxn(() async {
        media.creator.value = creator;
        await media.creator.save();
      });

      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<int>>> getRecognizableMediaIds({
    bool onlyUnrecognized = true,
  }) async {
    try {
      final summaries = await _appDatabase.mediaSummaryModels.where().findAll();

      return DataSuccess([
        for (final summary in summaries)
          // Lo marcado para borrar se queda fuera: reconocerlo sería gastar
          // horas en contenido que sale solo de la base de datos en una semana.
          if (!summary.isDeleted &&
              !(onlyUnrecognized && summary.recognizedAt != null))
            summary.id,
      ]);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<TagEntity?>> getTag(int id) async {
    try {
      final model = await _appDatabase.tagModels.get(id);

      return DataSuccess(model?.toEntity());
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<CreatorEntity?>> getCreator(int id) async {
    try {
      final model = await _appDatabase.creatorModels.get(id);

      return DataSuccess(model?.toEntity());
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
      // Ordenados por nombre, como las etiquetas: el orden en el que los lee
      // Isar es el de creación, que en un listado no dice nada.
      final query = await _appDatabase.creatorModels.where().findAll()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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