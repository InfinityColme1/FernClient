import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';

abstract class MediaEvents {
  const MediaEvents();
}

class LoadScannedMediaEvent extends MediaEvents {
  const LoadScannedMediaEvent();
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

class ClearMediaSelectionEvent extends MediaEvents {
  const ClearMediaSelectionEvent();
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
