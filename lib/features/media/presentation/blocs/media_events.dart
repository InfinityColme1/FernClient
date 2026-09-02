import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';

/// Los eventos del bloc de contenido.
///
/// **No son `Equatable` a propósito.** `bloc` no descarta eventos repetidos, así
/// que compararlos no decide nada; cuatro de ellos llegaron a declarar un `props`
/// con `@override` que no sobreescribía nada y no lo leía nadie.
abstract class MediaEvents {
  const MediaEvents();
}

class LoadScannedMediaEvent extends MediaEvents {
  const LoadScannedMediaEvent();
}

/// Cambio de fuente en el desplegable de la pantalla de importación.
///
/// Cambia las dos cosas a la vez: la rejilla pasa a enseñar sólo lo que vino de
/// esa fuente y el siguiente escaneo se hace sobre ella.
class ImportSourceChangedEvent extends MediaEvents {
  final ImportSource source;

  const ImportSourceChangedEvent(this.source);
}

/// Se acaba de abrir una pantalla, y esta es la rejilla que le toca.
///
/// **Se manda al abrirse, no al cargar.** El bloc es uno solo y lo comparten
/// seis pantallas, asi que su lista sobrevive al cambio: sin esto, la
/// biblioteca se abria enseñando lo que hubiera dejado la importacion, con la
/// cabecera y los botones de la biblioteca. Contenido de otro sitio, y durante
/// toda la transicion.
///
/// Abriendo la misma que ya estaba no se toca nada: volver del visor a la
/// biblioteca no puede vaciarla.
class MediaScreenOpenedEvent extends MediaEvents {
  final MediaListing listing;

  const MediaScreenOpenedEvent(this.listing);

  @override
  List<Object?> get props => [listing];
}

/// Carga el contenido definitivo de la base de datos: el de la pantalla de
/// media, ya revisado y guardado.
///
/// Con [ifStale] sólo si hace falta: si la biblioteca que hay en el estado se
/// leyó con la base tal y como está ahora, no se vuelve a leer. Lo pide la
/// pantalla al abrirse, que es donde se notaba —ir a importar y volver releía
/// entera una biblioteca que no había cambiado— y **sólo ahí**: quien manda
/// releer a propósito (abrir el bloqueo, terminar un reconocimiento) tiene sus
/// motivos y no pregunta.
class LoadMediaLibraryEvent extends MediaEvents {
  final bool ifStale;

  const LoadMediaLibraryEvent({this.ifStale = false});

  @override
  List<Object?> get props => [ifStale];
}

/// Cambian las pastillas de la barra: se busca lo que las cumple **todas**.
///
/// Llega la lista entera y no lo que se ha añadido o quitado: la barra es dueña
/// de sus pastillas, y mandar el conjunto hace que poner una, quitarla o
/// reordenarlas sean el mismo camino en vez de tres.
class SearchCriteriaChangedEvent extends MediaEvents {
  final List<SearchCriterionEntity> criteria;

  const SearchCriteriaChangedEvent(this.criteria);
}

/// Busca [query] por todo (descripciones, nombres de fichero, etiquetas y
/// creadores) y deja el resultado agrupado para la rejilla.
///
/// Es una sola pastilla de texto libre, y se conserva porque hay cuatro sitios
/// que buscan sin saber nada de pastillas.
class SearchMediaEvent extends MediaEvents {
  final String query;

  const SearchMediaEvent(this.query);
}

/// Búsqueda de la sugerencia elegida en el buscador.
///
/// A diferencia de [SearchMediaEvent], no busca por texto: trae el contenido de
/// esa etiqueta, ese creador o ese contenido y nada más.
class SearchSuggestionSelectedEvent extends MediaEvents {
  final SearchSuggestionEntity suggestion;

  const SearchSuggestionSelectedEvent(this.suggestion);
}

/// Le quita una etiqueta al contenido que se está viendo, y **sólo a ése**.
///
/// Va aparte de [RemoveTagFromSelectedMediaEvent], que trabaja sobre lo marcado
/// en la rejilla: esto sale de la cruz de una etiqueta del panel de información,
/// donde no hay selección ninguna y lo que se toca es el contenido de delante.
class RemoveTagFromMediaEvent extends MediaEvents {
  final int mediaId;
  final int tagId;

  const RemoveTagFromMediaEvent({required this.mediaId, required this.tagId});
}

/// Enciende o apaga [type] en el filtro de la cabecera de la pantalla de media.
///
/// No repite la búsqueda: los grupos que ha encontrado el buscador siguen en el
/// estado y lo único que cambia es cuáles de ellos se pintan, así que volver a
/// encender un tipo lo devuelve a la rejilla tal cual estaba.
class ToggleSearchFilterEvent extends MediaEvents {
  final SearchResultType type;

  const ToggleSearchFilterEvent(this.type);
}

/// Enciende o apaga una fuente en el filtro de la cabecera de la pantalla de
/// media.
///
/// Es lo que sustituye a tener una etiqueta por plataforma: de dónde llegó cada
/// contenido se guarda con él, así que la rejilla puede enseñar sólo lo de una
/// fuente sin que nadie haya tenido que etiquetarlo.
class ToggleSourceFilterEvent extends MediaEvents {
  final ImportSource source;

  const ToggleSourceFilterEvent(this.source);
}

/// Deshace la búsqueda: la rejilla vuelve a mostrar la biblioteca completa.
class ClearMediaSearchEvent extends MediaEvents {
  const ClearMediaSearchEvent();
}

/// Busca contenido nuevo en la fuente elegida: recorre la carpeta del equipo,
/// se descarga lo guardado en una plataforma remota o las dos cosas.
///
/// [limit] es el tope de contenidos nuevos que se traen, el de la píldora de la
/// cabecera; con [unlimitedImportLimit] se trae todo lo que haya.
class ScanSourceEvent extends MediaEvents {
  final int limit;

  /// Si lo que entre queda marcado como no apto.
  ///
  /// Se marca **al terminar** y de una vez, no pieza a pieza: durante la
  /// importación lo que llega se ve llegar, que es lo que dice que va bien.
  final bool asNsfw;

  const ScanSourceEvent({
    this.limit = unlimitedImportLimit,
    this.asNsfw = false,
  });
}

/// Para la importación que esté en marcha.
///
/// Lo que ya se ha traído se queda en la pantalla: parar es dejar de buscar
/// más, no deshacer lo hecho.
class StopImportEvent extends MediaEvents {
  const StopImportEvent();
}

/// Elige otra carpeta del equipo y la escanea. Sólo tiene sentido con la fuente
/// local: de una plataforma remota no hay carpeta que elegir.
///
/// [limit] es el mismo tope que en [ScanSourceEvent]: lo que diga la cabecera
/// vale para cualquier escaneo.
class SelectAndScanDirectoryEvent extends MediaEvents {
  final int limit;

  const SelectAndScanDirectoryEvent({this.limit = unlimitedImportLimit});
}

class MediaClickedEvent extends MediaEvents {
  final MediaSummaryEntity media;

  const MediaClickedEvent({required this.media});
}

class ToggleMediaSelectionEvent extends MediaEvents {
  final MediaSummaryEntity media;

  const ToggleMediaSelectionEvent({required this.media});
}

/// Selección de todo lo que hay entre el último elemento marcado y [media],
/// ambos incluidos. Es lo que hace mayúsculas + clic en la rejilla.
///
/// [orderedIds] es el contenido de la rejilla en el orden exacto en el que se
/// está pintando: sólo ella lo conoce, porque una búsqueda lo reparte en grupos
/// y ese orden ya no es el de la lista del estado.
class SelectMediaRangeEvent extends MediaEvents {
  final MediaSummaryEntity media;
  final List<int> orderedIds;

  const SelectMediaRangeEvent({
    required this.media,
    required this.orderedIds,
  });
}

class ClearMediaSelectionEvent extends MediaEvents {
  const ClearMediaSelectionEvent();
}

/// Carga el contenido marcado para borrar: el de la pantalla de eliminados.
class LoadDeletedMediaEvent extends MediaEvents {
  const LoadDeletedMediaEvent();
}

/// Pone una etiqueta a unos cuantos contenidos de una vez.
///
/// Los identificadores llegan de fuera y no se sacan de la selección: quien
/// arrastra una celda sin nada marcado está pidiendo etiquetar **esa**, y quien
/// la arrastra con veinte marcadas está pidiendo etiquetar las veinte. Esa regla
/// la aplica quien lo dispara, que es el único que sabe cuál de los dos casos es.
class AddTagToMediaEvent extends MediaEvents {
  final int tagId;
  final List<int> mediaIds;

  const AddTagToMediaEvent({required this.tagId, required this.mediaIds});
}

/// Enciende o apaga una clase de contenido en el filtro de la cabecera.
/// Trae lo de unos creadores concretos de la fuente que se esté mirando.
///
/// Va aparte de [ScanSourceEvent] porque no es lo mismo: aquél recorre la fuente
/// entera y éste sólo lo de quien se haya elegido en las tarjetas.
class ScanCreatorsEvent extends MediaEvents {
  final int limit;
  final Set<String> creators;

  const ScanCreatorsEvent({required this.limit, required this.creators});
}

class ToggleTypeFilterEvent extends MediaEvents {
  final MediaKind kind;

  const ToggleTypeFilterEvent(this.kind);
}

/// Cambia en qué orden se pinta la biblioteca.
class MediaSortOrderChangedEvent extends MediaEvents {
  final MediaSortOrder order;

  const MediaSortOrderChangedEvent(this.order);
}

/// Marca de golpe todo lo que hay a la vista.
///
/// Llegan los identificadores desde la rejilla y no se calculan aquí: lo que se
/// marca es **lo que se está viendo**, y quién sabe eso es quien lo está
/// pintando —con sus filtros aplicados y sus grupos de búsqueda—.
class SelectAllMediaEvent extends MediaEvents {
  final List<int> ids;

  const SelectAllMediaEvent(this.ids);
}

/// Vuelve a pedir el listado que se esté enseñando, sea el que sea.
///
/// Lo dispara lo que cambia **qué se puede ver** sin cambiar el contenido: hoy,
/// abrir y cerrar el modo NSFW. Sin esto, la rejilla ya pintada se queda
/// enseñando lo que acaba de bloquearse hasta que el usuario cambie de pantalla,
/// que es la peor forma posible de que falle un bloqueo.
class ReloadCurrentMediaEvent extends MediaEvents {
  const ReloadCurrentMediaEvent();
}

/// Vuelve a leer **sólo las etiquetas** del contenido que se está viendo.
///
/// Hace falta cuando algo se las cambia por detrás sin pasar por el panel: al
/// salir del modo fernie, lo que los fernies marcados enlazan se le pone al
/// contenido, y el panel seguía enseñando las de antes. Había que salir del
/// visor y volver a entrar para verlo, y eso hacía dudar de si se había puesto.
///
/// **Sólo las etiquetas, a propósito.** Releer el contenido entero se llevaría
/// por delante lo que el panel tenga sin guardar —una descripción a medio
/// escribir—, y recargar el listado (que es lo que hace
/// [ReloadCurrentMediaEvent]) es mucho más de lo que hace falta.
///
/// Y **se suma**, no se sustituye: lo que el panel lleve sin guardar no está en
/// la base, así que sustituir con lo de la base lo borraba.
class RefreshCurrentMediaTagsEvent extends MediaEvents {
  const RefreshCurrentMediaTagsEvent();
}

/// Le pone un creador al contenido que se esta mirando, con lo que el creador
/// trae consigo.
///
/// **No lleva el contenido dentro, y ese es todo el motivo de que exista.** El
/// dialogo mandaba el contenido entero tal y como estaba al abrirlo, asi que
/// confirmar devolvia esa foto al panel y se llevaba por delante cualquier cosa
/// que se hubiera tocado mientras. Aqui solo viaja lo que hay que sumar, y el
/// bloc lo suma sobre lo que el panel tenga **en ese momento**.
///
/// [brings] son las etiquetas del creador con lo que ellas arrastran. Se suman:
/// ponerle un creador a un contenido no le quita nada de lo que ya llevaba.
class MediaCreatorAssignedEvent extends MediaEvents {
  final CreatorEntity creator;
  final List<TagEntity> brings;

  const MediaCreatorAssignedEvent(this.creator, {this.brings = const []});

  @override
  List<Object?> get props => [creator, brings];
}

/// Le pone el mismo creador a toda la seleccion de la rejilla.
///
/// Es el trabajo que hacia imposible revisar una tanda: cien imagenes del mismo
/// artista se abrian de una en una para escribir cien veces el mismo nombre.
///
/// **Pisa el que hubiera.** Quien marca cien contenidos y elige un creador esta
/// diciendo de quien son; lo automatico, que si respeta lo que ya hay, va por
/// otro camino.
class SetSelectedMediaCreatorEvent extends MediaEvents {
  final int creatorId;

  const SetSelectedMediaCreatorEvent(this.creatorId);

  @override
  List<Object?> get props => [creatorId];
}

/// Carga el contenido marcado como favorito: el de la pantalla de favoritos.
class LoadFavoriteMediaEvent extends MediaEvents {
  const LoadFavoriteMediaEvent();
}

/// Carga el contenido que tiene la etiqueta [tagId]: el de la rejilla de la
/// pantalla de gestión de etiquetas.
class LoadMediaByTagEvent extends MediaEvents {
  final int tagId;

  const LoadMediaByTagEvent(this.tagId);
}

/// Quita la etiqueta [tagId] de todo lo que esté seleccionado en la rejilla.
///
/// No borra nada: los contenidos dejan de tener esa etiqueta, así que salen de la
/// rejilla de la pantalla de gestión de etiquetas y siguen en la biblioteca.
class RemoveTagFromSelectedMediaEvent extends MediaEvents {
  final int tagId;

  const RemoveTagFromSelectedMediaEvent(this.tagId);
}

/// Carga el contenido del creador [creatorId]: el de la rejilla de la pantalla
/// de gestión de creadores.
class LoadMediaByCreatorEvent extends MediaEvents {
  final int creatorId;

  const LoadMediaByCreatorEvent(this.creatorId);
}

/// Quita el creador [creatorId] de todo lo que esté seleccionado en la rejilla.
///
/// No borra nada: los contenidos pasan al creador desconocido (siempre tienen
/// uno), así que salen de la rejilla de la pantalla de gestión de creadores y
/// siguen en la biblioteca.
class RemoveCreatorFromSelectedMediaEvent extends MediaEvents {
  final int creatorId;

  const RemoveCreatorFromSelectedMediaEvent(this.creatorId);
}

/// Pone o quita la marca de favorito del contenido que se está viendo en el
/// visor, que es lo que hace su corazón.
class ToggleFavoriteEvent extends MediaEvents {
  const ToggleFavoriteEvent();
}

/// Marca para borrar todo lo que esté seleccionado en la rejilla.
///
/// Lo definitivo no sale de la base de datos: cambia de pantalla y aparece en la
/// de eliminados. Lo que está pendiente de revisar sí se borra, y [deleteFiles]
/// dice si sus ficheros se van con él; es lo que se ha respondido en el aviso.
class DeleteSelectedMediaEvent extends MediaEvents {
  final bool deleteFiles;

  const DeleteSelectedMediaEvent({this.deleteFiles = false});
}

/// Marca como favorito todo lo que esté seleccionado en la rejilla.
///
/// Es una acción, no un interruptor: lo que ya lo era se queda como está. Para
/// quitarlo está el corazón del visor, que sí sabe cómo está cada contenido.
class FavoriteSelectedMediaEvent extends MediaEvents {
  const FavoriteSelectedMediaEvent();
}

/// Marca o desmarca como NSFW todo lo que esté seleccionado en la rejilla.
///
/// Interruptor y no acción, al revés que el de favoritos: aquí las dos
/// direcciones se piden desde el mismo sitio —la barra de selección— y esconder
/// doscientas fotos sin poder deshacerlo desde donde se hizo sería una trampa.
class SetSelectedMediaNsfwEvent extends MediaEvents {
  final bool isNsfw;

  const SetSelectedMediaNsfwEvent({required this.isNsfw});
}

/// Marca o desmarca como NSFW un contenido suelto, el que se está mirando.
class SetMediaNsfwEvent extends MediaEvents {
  final int mediaId;
  final bool isNsfw;

  const SetMediaNsfwEvent({required this.mediaId, required this.isNsfw});
}

/// Quita la marca de borrado de la selección de la rejilla, que vuelve a la
/// pantalla que le toque (contenido o importación).
class RestoreSelectedMediaEvent extends MediaEvents {
  const RestoreSelectedMediaEvent();
}

/// Borrado definitivo de **todo** lo marcado, el que se fuerza desde la
/// pantalla de eliminados.
///
/// [deleteFiles] dice si los ficheros del disco se van con las filas; sin él se
/// quedan y un escaneo posterior los recoge otra vez.
class PurgeDeletedMediaEvent extends MediaEvents {
  final bool deleteFiles;

  const PurgeDeletedMediaEvent({this.deleteFiles = false});
}

/// El contenido [id] no se ha podido cargar para pintarlo.
///
/// Si el motivo es que su fichero ya no está (borrado o movido por fuera de la
/// aplicación), su fila deja de tener sentido y se quita de la base de datos.
class MediaLoadFailedEvent extends MediaEvents {
  final int id;

  const MediaLoadFailedEvent(this.id);
}

/// Marca como definitivo todo lo que esté seleccionado en la rejilla, con los
/// datos que tenga en ese momento.
class ConfirmSelectedMediaEvent extends MediaEvents {
  const ConfirmSelectedMediaEvent();
}

class ViewerNextEvent extends MediaEvents {
  final bool next;

  const ViewerNextEvent({required this.next});
}

class ToggleInfoEvent extends MediaEvents {
  const ToggleInfoEvent();
}

/// Fija la visibilidad del panel de información, sin alternarla.
///
/// Lo usa el visor al abrirse: el contenido que llega desde la pantalla de
/// importación muestra la información desde el primer momento.
class SetInfoVisibilityEvent extends MediaEvents {
  final bool visible;

  const SetInfoVisibilityEvent(this.visible);
}

class SaveMediaEvent extends MediaEvents {
  final MediaEntity media;

  /// Si al guardar hay que seguir con el contenido siguiente en lugar de
  /// quedarse en el que se acaba de dar por definitivo.
  ///
  /// Es lo que el usuario haya elegido en los ajustes, y sólo tiene sentido con
  /// contenido pendiente de revisar: al guardarlo deja la lista de la pantalla
  /// de importación, así que el visor no puede quedarse donde estaba. Si no
  /// queda nada más que revisar, el visor se cierra igual que si se hubiera
  /// pedido cerrarlo.
  final bool goToNext;

  const SaveMediaEvent(this.media, {this.goToNext = false});
}

/// Marca para borrar el contenido que se está viendo en el visor.
///
/// Si todavía está pendiente de revisar no se marca, se descarta, y entonces
/// [deleteFiles] dice si su fichero se va con él.
class DeleteMediaEvent extends MediaEvents {
  final MediaEntity media;
  final bool deleteFiles;

  /// Con `true`, el visor se queda enseñando el siguiente en vez de cerrarse.
  ///
  /// Es lo que se quiere revisando una importación: descartar es parte de
  /// repasar la tanda, y salir del visor en cada descarte obliga a volver a
  /// entrar por el siguiente. Fuera de ahí se cierra, como siempre.
  final bool goToNext;

  const DeleteMediaEvent(
    this.media, {
    this.deleteFiles = false,
    this.goToNext = false,
  });
}

/// Borrado definitivo del contenido que se está viendo en el visor.
///
/// Es lo que hace el botón de borrar cuando lo que se está viendo ya estaba
/// marcado: desde la papelera, borrar es borrar del todo. [deleteFiles] dice si
/// su fichero se va con él, que es lo que se ha respondido en el aviso.
class PurgeMediaEvent extends MediaEvents {
  final MediaEntity media;
  final bool deleteFiles;

  const PurgeMediaEvent(this.media, {this.deleteFiles = false});
}

/// Quita la marca de borrado del contenido que se está viendo en el visor, que
/// vuelve a la pantalla que le toque y sale de la de eliminados.
class RestoreMediaEvent extends MediaEvents {
  final MediaEntity media;

  const RestoreMediaEvent(this.media);
}

/// Guarda en el estado los datos editados del contenido actual, pendientes de
/// escribirse en la base de datos hasta que se pulse "Save".
class UpdateMediaInfoEvent extends MediaEvents {
  final MediaEntity media;
  const UpdateMediaInfoEvent(this.media);
}

class UpdateMediaDescriptionEvent extends MediaEvents {
  final String description;
  const UpdateMediaDescriptionEvent(this.description);
}

/// Deja en la rejilla una lista de contenidos ya resuelta, sin consultar nada.
///
/// Lo usan las pantallas que sacan su contenido de otro sitio y no de una
/// consulta del repositorio de contenido: la de fernies lo saca de las regiones
/// de un fernie. Sin esto, abrir el visor desde ahí no tendría lista por la que
/// pasar con las flechas, y `onMediaClicked` no tendría dónde buscar el índice.
class SetMediaListEvent extends MediaEvents {
  final List<MediaSummaryEntity> media;

  const SetMediaListEvent(this.media);
}
