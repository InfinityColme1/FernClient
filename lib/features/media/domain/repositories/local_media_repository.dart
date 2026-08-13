import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import '../../../../core/resources/data_state.dart';


abstract class LocalMediaRepository {

  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath);

  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath);

  Future<DataState> saveScannedMedia(List<MediaEntity> mediaList);
  
  /// Guarda el contenido y lo marca como definitivo.
  ///
  /// Devuelve la ruta nueva del fichero si los ajustes de archivos han hecho
  /// que cambie de carpeta, y `null` si se ha quedado donde estaba.
  Future<DataState> saveMedia(MediaEntity media);

  Future<DataState<List<MediaSummaryEntity>>> getMediaList();

  /// Contenido pendiente de revisar, el de la pantalla de importación.
  ///
  /// [source] filtra por la fuente de la que llegó; con [ImportSource.all] se
  /// devuelve el de todas.
  Future<DataState<List<MediaSummaryEntity>>> getScannedMedia({
    ImportSource source,
  });

  /// Contenido marcado para borrar, el de la pantalla de eliminados.
  Future<DataState<List<MediaSummaryEntity>>> getDeletedMedia();

  /// Contenido definitivo marcado como favorito, el de la pantalla de
  /// favoritos.
  Future<DataState<List<MediaSummaryEntity>>> getFavoriteMedia();

  /// Marca o desmarca como favorito el contenido [id].
  ///
  /// Se escribe en el momento, sin pasar por el "Save" del panel de
  /// información: el corazón del visor es un interruptor, no una edición
  /// pendiente de guardar.
  Future<DataState> setMediaFavorite(int id, {required bool isFavorite});

  Future<DataState<MediaEntity>> getMediaDetails(int id);

  /// Borra el contenido [id] **sólo** si su fichero ya no está en la ruta
  /// guardada, que es lo que ocurre cuando se ha borrado o movido por fuera de
  /// la aplicación.
  ///
  /// Devuelve `true` si se ha llegado a borrar la fila y `false` si el fichero
  /// sigue estando donde debía.
  Future<DataState<bool>> deleteMissingMedia(int id);

  /// Borra de la base de datos los contenidos indicados, sumario y detalles.
  ///
  /// Es lo que se hace con lo que todavía está pendiente de revisar: descartarlo
  /// al importar no es guardarlo en la papelera, es no quererlo. Su fichero
  /// sigue en el disco, así que el siguiente escaneo lo recoge otra vez.
  Future<DataState> deleteMediaList(List<int> ids);

  /// Marca los contenidos indicados para borrar: siguen en la base de datos,
  /// pero salen de contenido y de las búsquedas para pasar a la pantalla de
  /// eliminados.
  Future<DataState> markMediaListAsDeleted(List<int> ids);

  /// Quita la marca de borrado de los contenidos indicados, que vuelven a la
  /// pantalla de la que salieron.
  Future<DataState> restoreMediaList(List<int> ids);

  /// Borra de la base de datos lo que lleve marcado más de una semana
  /// (`deletedRetention`) y devuelve cuántos contenidos se han borrado.
  ///
  /// Es el vaciado automático de la papelera. Lo marcado sin fecha no se toca.
  Future<DataState<int>> purgeExpiredDeletedMedia();

  /// Borra de la base de datos **todo** lo que esté marcado para borrar y
  /// devuelve cuántos contenidos se han borrado.
  ///
  /// Es el borrado definitivo de la pantalla de eliminados: los ficheros del
  /// disco no se tocan, así que el siguiente escaneo puede recogerlos otra vez.
  Future<DataState<int>> purgeDeletedMedia();

  /// Marca como definitivos los contenidos indicados dejando sus detalles tal
  /// y como están (los del escaneo si nadie los ha revisado).
  Future<DataState> confirmMediaList(List<int> ids);

  /// Reordena en disco los ficheros de todo el contenido definitivo según los
  /// ajustes de archivos y devuelve cuántos han cambiado de sitio.
  Future<DataState<int>> organizeLibraryFiles();

  /// Lleva las imágenes de los avatares (creadores y etiquetas) a
  /// [targetDirectory] y actualiza sus rutas. Las que vinieran de
  /// [previousDirectory] se mueven; las demás se copian, para no tocar los
  /// ficheros originales del usuario. Devuelve cuántas se han reubicado.
  Future<DataState<int>> migrateAvatars({
    required String targetDirectory,
    String? previousDirectory,
  });

  /// Guarda la etiqueta y, si se indica [parent], la cuelga de ella.
  Future<DataState<TagEntity>> saveTag(TagEntity tag, {TagEntity? parent});

  /// Cambia el nombre, el avatar y el sitio en la jerarquía de una etiqueta que
  /// ya está en la base de datos.
  ///
  /// A diferencia de [saveTag], [parent] manda siempre: con una etiqueta la
  /// cuelga de ella (soltándola de la que la tuviera) y con `null` la deja como
  /// etiqueta raíz. Es lo que hace la pantalla de gestión de etiquetas, donde el
  /// campo de la etiqueta padre se puede vaciar.
  ///
  /// Los contenidos que ya tienen la etiqueta la conservan: sólo cambian sus
  /// datos.
  Future<DataState<TagEntity>> updateTag(TagEntity tag, {TagEntity? parent});

  /// Borra la etiqueta [tagId] de la base de datos.
  ///
  /// Los contenidos que la tenían **no se borran**: lo que se les quita es la
  /// etiqueta, y siguen con las demás. Las etiquetas que colgaban de ella se
  /// quedan como raíces.
  Future<DataState> deleteTag(int tagId);

  /// Contenido definitivo que tiene la etiqueta [tagId].
  ///
  /// Es lo que enseña la rejilla de la pantalla de gestión de etiquetas. Como en
  /// las búsquedas, lo pendiente de revisar y lo marcado para borrar se quedan
  /// fuera: cada uno tiene su pantalla.
  Future<DataState<List<MediaSummaryEntity>>> getMediaByTag(int tagId);

  /// Quita la etiqueta [tagId] de los contenidos indicados.
  ///
  /// Ni la etiqueta ni los contenidos desaparecen: lo único que se deshace es la
  /// relación entre ellos.
  Future<DataState> removeTagFromMedia(int tagId, List<int> mediaIds);

  Future<DataState<CreatorEntity>> saveCreator(CreatorEntity creator);
  
  Future<DataState<List<TagEntity>>> getTags();

  /// Las etiquetas en forma de árbol: sólo las que no cuelgan de ninguna otra,
  /// cada una con sus descendientes ya cargados.
  ///
  /// Es lo que necesita la sección de etiquetas del menú lateral, que las pinta
  /// con la jerarquía a la vista. [getTags] devuelve la lista plana y sin
  /// resolver los enlaces, que no sirve para eso.
  Future<DataState<List<TagEntity>>> getTagTree();

  Future<DataState<List<CreatorEntity>>> getCreators();

  /// Etiquetas cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<TagEntity>>> searchTags(String query, {int limit});

  /// Creadores cuyo nombre se parece a [query], como mucho [limit].
  Future<DataState<List<CreatorEntity>>> searchCreators(String query, {int limit});

  /// Sugerencias del buscador principal: contenidos (por su descripción),
  /// etiquetas y creadores que se parecen a [query], como mucho [limit] en
  /// total.
  Future<DataState<List<SearchSuggestionEntity>>> searchSuggestions(
    String query, {
    int limit,
  });

  /// Contenido definitivo que responde a [query], agrupado para la rejilla:
  /// primero las coincidencias por descripción, luego un grupo por cada
  /// etiqueta que encaje y por último uno por cada creador.
  Future<DataState<List<MediaSearchSectionEntity>>> searchMedia(String query);

  /// Contenido de **una** sugerencia concreta: sólo el de esa etiqueta, ese
  /// creador o ese contenido, sin arrastrar lo que se parezca a su nombre.
  Future<DataState<List<MediaSearchSectionEntity>>> searchMediaBySuggestion(
    SearchSuggestionEntity suggestion,
  );
}