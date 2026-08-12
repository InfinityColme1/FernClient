import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';

abstract class MediaEvents {
  const MediaEvents();
}

class LoadScannedMediaEvent extends MediaEvents {
  const LoadScannedMediaEvent();
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

/// Deshace la búsqueda: la rejilla vuelve a mostrar la biblioteca completa.
class ClearMediaSearchEvent extends MediaEvents {
  const ClearMediaSearchEvent();
}

class ScanDirectoryEvent extends MediaEvents {
  const ScanDirectoryEvent();
}

class SelectAndScanDirectoryEvent extends MediaEvents {
  const SelectAndScanDirectoryEvent();
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

/// Pone o quita la marca de favorito del contenido que se está viendo en el
/// visor, que es lo que hace su corazón.
class ToggleFavoriteEvent extends MediaEvents {
  const ToggleFavoriteEvent();
}

/// Marca para borrar todo lo que esté seleccionado en la rejilla.
///
/// No borra nada de la base de datos: el contenido sale de la pantalla en la que
/// esté y aparece en la de eliminados.
class DeleteSelectedMediaEvent extends MediaEvents {
  const DeleteSelectedMediaEvent();
}

/// Quita la marca de borrado de la selección de la rejilla, que vuelve a la
/// pantalla que le toque (contenido o importación).
class RestoreSelectedMediaEvent extends MediaEvents {
  const RestoreSelectedMediaEvent();
}

/// Borrado definitivo de **todo** lo marcado, el que se fuerza desde la
/// pantalla de eliminados. Los ficheros del disco no se tocan, así que se
/// pueden volver a escanear.
class PurgeDeletedMediaEvent extends MediaEvents {
  const PurgeDeletedMediaEvent();
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
class DeleteMediaEvent extends MediaEvents {
  final MediaEntity media;
  const DeleteMediaEvent(this.media);
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
