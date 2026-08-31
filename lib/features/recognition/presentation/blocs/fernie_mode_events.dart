import 'dart:ui';

import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_states.dart';

abstract class FernieModeEvents {
  const FernieModeEvents();
}

/// Lee las regiones que ya tiene este contenido.
///
/// Se pide al abrir el visor y al pasar de un contenido a otro, aunque no se
/// entre al modo: hace falta para saber si hay que resaltar alguna y para que la
/// sección de fernies del panel sepa qué enseñar.
class LoadMediaRegionsEvent extends FernieModeEvents {
  final int mediaId;

  const LoadMediaRegionsEvent(this.mediaId);
}

/// Entra al modo de marcar.
///
/// [infoWasOpen] es lo que hay que restaurar al salir: el modo cierra el panel
/// de información, y quien lo tenía abierto espera encontrárselo abierto al
/// volver.
class EnterFernieModeEvent extends FernieModeEvents {
  final bool infoWasOpen;

  const EnterFernieModeEvent({required this.infoWasOpen});
}

/// Sale del modo. Con [save] se escribe todo lo marcado; sin él se descarta.
class ExitFernieModeEvent extends FernieModeEvents {
  final bool save;

  const ExitFernieModeEvent({required this.save});
}

/// Una región recién arrastrada, ya asignada a un fernie.
///
/// El rectángulo se marca antes de saber a qué fernie va, pero no llega aquí
/// hasta que el menú contextual lo resuelve: una región sin fernie no es nada
/// que guardar.
class RegionAssignedEvent extends FernieModeEvents {
  final Rect rect;

  /// El fernie elegido, entero.
  ///
  /// Viene con el evento y no se busca después porque un fernie recién creado
  /// todavía no tiene ninguna región en este contenido: sin esto no habría de
  /// dónde sacar su nombre para la etiqueta ni su avatar para el panel.
  final FernieEntity fernie;

  final int? frameMs;

  const RegionAssignedEvent({
    required this.rect,
    required this.fernie,
    this.frameMs,
  });
}

/// Entra al modo con lo que un modelo ha detectado, **sin marcar**.
///
/// Es lo que hace el botón de «guardar como región» de una sugerencia: en vez de
/// guardar a ciegas lo que el modelo vio, abre el modo con sus rectángulos
/// dibujados para poder quedarse sólo con los que estén bien. Un modelo que ve
/// cuatro coches puede estar acertando en tres.
class ProposedRegionsOfferedEvent extends FernieModeEvents {
  final List<ProposedRegion> regions;

  /// De qué sugerencias salen.
  ///
  /// Al aceptar sus regiones, esas sugerencias quedan contestadas: ir a las
  /// regiones de una sugerencia, darlas por buenas y tener que volver a aceptar
  /// la sugerencia es decir dos veces lo mismo — más aún ahora que marcar la
  /// región ya le pone la etiqueta al contenido.
  final List<int> suggestionIds;

  /// Como en [EnterFernieModeEvent]: lo que hay que restaurar al salir.
  final bool infoWasOpen;

  const ProposedRegionsOfferedEvent({
    required this.regions,
    required this.infoWasOpen,
    this.suggestionIds = const [],
  });
}

/// Da por buena una de las propuestas: pasa a estar marcada.
class ProposedRegionAcceptedEvent extends FernieModeEvents {
  final int index;

  const ProposedRegionAcceptedEvent(this.index);
}

/// Da por buenas todas las que queden.
///
/// El botón de «todas» existe porque el caso normal es que el modelo acierte:
/// con doce coches bien detectados, pulsarlos de uno en uno es el trabajo que
/// esto venía a ahorrar.
class AllProposedRegionsAcceptedEvent extends FernieModeEvents {
  const AllProposedRegionsAcceptedEvent();
}

/// Cambia la herramienta del modo.
///
/// Suelta lo que hubiera elegido: las dos herramientas trabajan sobre cosas
/// distintas y arrastrar una selección de una a otra no significaría nada.
class FernieToolChangedEvent extends FernieModeEvents {
  final FernieTool tool;

  const FernieToolChangedEvent(this.tool);
}

/// Elige una región para editarla, por su posición en la lista que se pinta.
///
/// Con `null` se suelta la que hubiera. Quien lo manda ya se ha asegurado de que
/// no se pierde nada: si el borrador tenía cambios, el aviso salta antes.
class RegionSelectedEvent extends FernieModeEvents {
  final int? index;

  const RegionSelectedEvent(this.index);
}

/// El rectángulo nuevo de la región elegida, mientras se la mueve o se la
/// estira. No baja a ninguna parte hasta que se confirme.
class RegionDraftResizedEvent extends FernieModeEvents {
  final Rect rect;

  const RegionDraftResizedEvent(this.rect);
}

/// El fernie al que se ha pedido pasar la región elegida, sin confirmar.
class RegionDraftReassignedEvent extends FernieModeEvents {
  final FernieEntity fernie;

  const RegionDraftReassignedEvent(this.fernie);
}

/// Da por buenos los cambios de la región elegida y la suelta.
class RegionEditsConfirmedEvent extends FernieModeEvents {
  const RegionEditsConfirmedEvent();
}

/// Tira los cambios de la región elegida y la suelta.
class RegionEditsDiscardedEvent extends FernieModeEvents {
  const RegionEditsDiscardedEvent();
}

/// Borra una región por su posición en la lista que se está pintando.
///
/// Si es de esta sesión desaparece sin más; si venía de la base de datos se
/// anota como borrada y no se escribe hasta aceptar.
class RegionDeletedEvent extends FernieModeEvents {
  final int index;

  const RegionDeletedEvent(this.index);
}

/// Deshace la última región marcada en esta sesión.
class UndoLastRegionEvent extends FernieModeEvents {
  const UndoLastRegionEvent();
}
