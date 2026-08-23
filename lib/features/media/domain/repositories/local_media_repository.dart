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

  /// Los identificadores del contenido que se puede mandar a reconocer.
  ///
  /// Sólo identificadores y no los contenidos enteros: reconocer la biblioteca
  /// son decenas de miles de filas, y traerlas con sus etiquetas y su creador
  /// para quedarse con el número es llenar la memoria de lo que nadie va a
  /// mirar.
  ///
  /// Con [onlyUnrecognized] se deja fuera lo que ya se miró alguna vez. Es lo
  /// que hace usable «reconocer toda la biblioteca» la segunda vez: sin ello,
  /// cada pulsación vuelve a pagar por todo lo que ya está hecho.
  ///
  /// Lo que está en la papelera nunca sale: reconocerlo sería gastar horas en
  /// contenido que se va a borrar solo en una semana.
  /// Le añade estas etiquetas a un contenido, sin tocar nada más.
  ///
  /// Existe aparte de [saveMedia] porque aquél **da el contenido por
  /// definitivo**, y eso es una decisión del usuario, no un efecto de aceptar
  /// una sugerencia: en la pantalla de importación hay un botón de confirmar
  /// justo al lado, y aceptar etiquetas en masa no puede hacer su trabajo por
  /// él.
  ///
  /// Las que ya tenga se quedan: esto suma, no reemplaza.
  Future<DataState<int>> addTagsToMedia(int mediaId, List<int> tagIds);

  /// Le pone este creador a un contenido, sin tocar nada más.
  ///
  /// Por lo mismo que lo anterior: poner un creador no es dar el contenido por
  /// revisado.
  Future<DataState<bool>> setMediaCreator(int mediaId, int creatorId);

  Future<DataState<List<int>>> getRecognizableMediaIds({
    bool onlyUnrecognized = true,
  });

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

  /// Pone o quita la marca de favorito de varios contenidos a la vez, que es lo
  /// que hace el corazón de la rejilla sobre lo que esté seleccionado.
  Future<DataState> setMediaListFavorite(
    List<int> ids, {
    required bool isFavorite,
  });

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
  /// al importar no es guardarlo en la papelera, es no quererlo. Sin
  /// [deleteFiles] su fichero sigue en el disco, así que el siguiente escaneo lo
  /// recoge otra vez; con él, el fichero se borra y no vuelve.
  Future<DataState> deleteMediaList(List<int> ids, {bool deleteFiles});

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
  /// Con [deleteFiles] se llevan también sus ficheros del disco.
  Future<DataState<int>> purgeExpiredDeletedMedia({bool deleteFiles});

  /// Borra de la base de datos **todo** lo que esté marcado para borrar y
  /// devuelve cuántos contenidos se han borrado.
  ///
  /// Es el borrado definitivo de la pantalla de eliminados. Sin [deleteFiles]
  /// los ficheros del disco no se tocan, así que el siguiente escaneo puede
  /// recogerlos otra vez; con él desaparecen con sus filas.
  Future<DataState<int>> purgeDeletedMedia({bool deleteFiles});

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

  /// Deja en la etiqueta [tagId] las direcciones de las que sale su contenido.
  ///
  /// Manda lo que llega: las que había antes y no vengan en [urls] se pierden,
  /// que es cómo se quita una desde el diálogo. Las direcciones se normalizan
  /// aquí, así que da igual cómo las haya escrito el usuario.
  Future<DataState<TagEntity>> saveTagSourceUrls(int tagId, List<String> urls);

  /// Las etiquetas que están por encima de [tags] en la jerarquía, a cualquier
  /// profundidad y sin [tags] mismas.
  ///
  /// Etiquetar con una es etiquetar con toda su rama, cosa que el guardado ya
  /// hace por su cuenta; esto es para que la pantalla pueda enseñar las que se
  /// van a poner **antes** de guardar, en vez de que aparezcan de la nada al
  /// recargar.
  Future<DataState<List<TagEntity>>> getTagAncestors(List<TagEntity> tags);

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

  /// Cambia el nombre, el avatar y los enlaces de un creador que ya está en la
  /// base de datos.
  ///
  /// El identificador no se toca, así que los contenidos que lo tienen lo
  /// siguen teniendo: sólo cambian sus datos.
  Future<DataState<CreatorEntity>> updateCreator(CreatorEntity creator);

  /// Deja en el creador [creatorId] las direcciones de las que sale su
  /// contenido.
  ///
  /// Manda lo que llega: las que había antes y no vengan en [urls] se pierden,
  /// que es cómo se quita una desde el diálogo. Las direcciones se normalizan
  /// aquí, así que da igual cómo las haya escrito el usuario.
  Future<DataState<CreatorEntity>> saveCreatorSourceUrls(
    int creatorId,
    List<String> urls,
  );

  /// Borra el creador [creatorId] de la base de datos.
  ///
  /// Los contenidos que lo tenían **no se borran**: pasan al creador
  /// desconocido, porque un contenido siempre tiene creador.
  Future<DataState> deleteCreator(int creatorId);

  /// Contenido definitivo del creador [creatorId].
  ///
  /// Es lo que enseña la rejilla de la pantalla de gestión de creadores. Como en
  /// las búsquedas, lo pendiente de revisar y lo marcado para borrar se quedan
  /// fuera: cada uno tiene su pantalla.
  Future<DataState<List<MediaSummaryEntity>>> getMediaByCreator(int creatorId);

  /// Quita el creador [creatorId] de los contenidos indicados, que pasan al
  /// creador desconocido.
  ///
  /// Ni el creador ni los contenidos desaparecen: lo único que se deshace es la
  /// relación entre ellos.
  Future<DataState> removeCreatorFromMedia(int creatorId, List<int> mediaIds);

  Future<DataState<List<TagEntity>>> getTags();

  /// Una etiqueta por su identificador, o `null` si ya no existe.
  ///
  /// Que no exista no es un fallo: los enlaces que guardan otras cosas —los de
  /// los fernies, sin ir más lejos— apuntan por identificador y sobreviven a que
  /// alguien borre la etiqueta. Quien pregunta necesita poder distinguir «no
  /// está» de «no se ha podido leer».
  Future<DataState<TagEntity?>> getTag(int id);

  /// Un creador por su identificador, o `null` si ya no existe.
  Future<DataState<CreatorEntity?>> getCreator(int id);

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