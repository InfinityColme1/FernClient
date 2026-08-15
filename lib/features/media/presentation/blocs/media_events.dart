import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';

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

/// Carga el contenido definitivo de la base de datos: el de la pantalla de
/// media, ya revisado y guardado.
class LoadMediaLibraryEvent extends MediaEvents {
  const LoadMediaLibraryEvent();
}

/// Busca [query] por todo (descripciones, etiquetas y creadores) y deja el
/// resultado agrupado para la rejilla de la pantalla de media.
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

  const ScanSourceEvent({this.limit = unlimitedImportLimit});
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
  const SaveMediaEvent(this.media);
}

/// Marca para borrar el contenido que se está viendo en el visor.
///
/// Si todavía está pendiente de revisar no se marca, se descarta, y entonces
/// [deleteFiles] dice si su fichero se va con él.
class DeleteMediaEvent extends MediaEvents {
  final MediaEntity media;
  final bool deleteFiles;

  const DeleteMediaEvent(this.media, {this.deleteFiles = false});
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
