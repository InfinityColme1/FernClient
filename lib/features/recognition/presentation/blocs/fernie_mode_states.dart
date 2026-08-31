import 'dart:ui';

import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:equatable/equatable.dart';

/// Los dos modos del visor.
enum ViewerMode {
  /// El de siempre: se mira el contenido y la barra lleva sus siete acciones.
  viewing,

  /// El de marcar: el cursor es una cruz, arrastrar recorta una región y la
  /// barra se queda con aceptar y cancelar.
  fernie,
}

/// Con qué se está trabajando dentro del modo fernie.
///
/// Son dos oficios distintos sobre el mismo lienzo y no caben a la vez: con la
/// de marcar, arrastrar dibuja una región nueva; con la de editar, arrastrar
/// mueve o estira la que esté elegida. Sin separarlas, cada arrastre sería una
/// adivinanza.
enum FernieTool {
  /// Dibujar regiones nuevas. Es la de siempre y la que viene puesta.
  mark,

  /// Elegir una región ya marcada para moverla, estirarla, reasignarla o
  /// borrarla.
  edit,
}

/// Una región marcada en esta sesión y todavía sin guardar.
/// Una región que **el modelo propone** y que todavía nadie ha aceptado.
///
/// Llega de una detección: el modelo dice que ahí hay algo y con cuánta
/// seguridad. Se dibuja sobre el contenido pero **no está marcada** — hay que
/// pulsarla para que cuente, o aceptarlas todas de una vez.
///
/// Ninguna puesta de entrada, a propósito: un modelo que ve cuatro coches puede
/// estar acertando en tres. Que entren solas obligaría a repasarlas para quitar
/// las malas, y salir sin mirar dejaría marcado lo que nadie ha confirmado.
class ProposedRegion extends Equatable {
  final Rect rect;
  final int fernieId;
  final int? frameMs;

  /// Lo seguro que estaba el modelo, de 0 a 1.
  ///
  /// Se enseña en la pestaña de cada una: con cuatro rectángulos delante, saber
  /// cuál es el del 94 % y cuál el del 51 % es lo que permite elegir bien.
  final double confidence;

  /// Cómo se llama lo que el modelo dice que hay ahí.
  final String label;

  const ProposedRegion({
    required this.rect,
    required this.fernieId,
    required this.confidence,
    required this.label,
    this.frameMs,
  });

  /// La misma, ya marcada.
  PendingRegion get accepted =>
      PendingRegion(rect: rect, fernieId: fernieId, frameMs: frameMs);

  @override
  List<Object?> get props => [rect, fernieId, frameMs, confidence, label];
}

class PendingRegion extends Equatable {
  final Rect rect;
  final int fernieId;

  /// Fotograma del que se marcó, en vídeo y GIF.
  final int? frameMs;

  const PendingRegion({
    required this.rect,
    required this.fernieId,
    this.frameMs,
  });

  PendingRegion copyWith({Rect? rect, int? fernieId}) {
    return PendingRegion(
      rect: rect ?? this.rect,
      fernieId: fernieId ?? this.fernieId,
      frameMs: frameMs,
    );
  }

  @override
  List<Object?> get props => [rect, fernieId, frameMs];
}

/// Una región tal y como hay que enseñarla ahora mismo, venga de donde venga.
///
/// Existe para que el visor no tenga que llevar dos listas en paralelo: la capa
/// de selección trabaja con índices, y necesita una única lista en la que estén
/// mezcladas las regiones guardadas y las de esta sesión, ya con los cambios
/// pendientes aplicados encima.
class RegionView extends Equatable {
  final Rect rect;
  final String label;
  final int fernieId;
  final int? frameMs;

  /// Identificador en la base de datos, o `null` si es de esta sesión y todavía
  /// no se ha guardado.
  final int? savedId;

  /// Posición dentro de las pendientes, o `null` si viene de la base de datos.
  final int? pendingIndex;

  const RegionView({
    required this.rect,
    required this.label,
    required this.fernieId,
    this.frameMs,
    this.savedId,
    this.pendingIndex,
  });

  @override
  List<Object?> get props =>
      [rect, label, fernieId, frameMs, savedId, pendingIndex];
}

/// El modo del visor y todo lo que se lleva marcado sin guardar.
class FernieModeState extends Equatable {
  final ViewerMode mode;

  /// La herramienta elegida dentro del modo.
  final FernieTool tool;

  /// Contenido sobre el que se está trabajando. Cambiar de contenido con el
  /// modo abierto no puede pasar: las flechas quedan desactivadas.
  final int? mediaId;

  /// Las regiones que ya están en la base de datos para este contenido.
  final List<FernieRegionEntity> saved;

  /// Los fernies de los que se sabe algo en esta sesión: los que ya tenían
  /// regiones aquí al entrar, más los que se hayan elegido al marcar.
  ///
  /// Es un **catálogo**, no la lista de los que están marcados ahora: de aquí se
  /// sacan el nombre y el avatar, y quien quiera saber cuáles siguen atados al
  /// contenido tiene que mirar [ferniesInMedia]. Un fernie no se quita de aquí
  /// al borrar su región, porque puede volver a elegirse en el mismo gesto.
  ///
  /// Se guardan enteros y no sólo sus nombres porque hacen falta las dos cosas:
  /// el nombre para la etiqueta que va encima de cada rectángulo y el avatar
  /// para la sección de fernies del panel de información.
  final List<FernieEntity> fernies;

  final List<PendingRegion> pending;

  /// Regiones guardadas que se han movido o redimensionado, por identificador.
  final Map<int, Rect> edited;

  /// Regiones guardadas que se han pasado a otro fernie, por identificador.
  final Map<int, int> reassigned;

  /// Regiones guardadas que se han borrado en esta sesión, por identificador.
  ///
  /// El borrado no baja a la base de datos hasta aceptar: así cancelar también
  /// deshace los borrados, que es lo que espera cualquiera que se arrepienta.
  final Set<int> deleted;

  /// La región elegida con la herramienta de editar, por su posición en
  /// [views]. `null` cuando no hay ninguna.
  final int? selectedIndex;

  /// Cómo va quedando la región elegida mientras se la mueve o se la estira.
  ///
  /// Va aparte de [edited] a propósito: esto es un borrador que se confirma o se
  /// tira con los botones de su pestaña, y hasta entonces no cuenta como cambio
  /// de la sesión.
  final Rect? draftRect;

  /// El fernie al que se ha pedido pasar la región elegida, sin confirmar.
  final FernieEntity? draftFernie;

  /// Si el panel de información estaba abierto al entrar al modo, para dejarlo
  /// como estaba al salir.
  final bool infoWasOpen;

  final bool isBusy;

  const FernieModeState({
    this.mode = ViewerMode.viewing,
    this.tool = FernieTool.mark,
    this.mediaId,
    this.saved = const [],
    this.fernies = const [],
    this.pending = const [],
    this.edited = const {},
    this.reassigned = const {},
    this.deleted = const {},
    this.selectedIndex,
    this.draftRect,
    this.draftFernie,
    this.infoWasOpen = false,
    this.isBusy = false,
    this.proposed = const [],
    this.appliedLinks = 0,
  });

  bool get isFernieMode => mode == ViewerMode.fernie;

  bool get isEditing => isFernieMode && tool == FernieTool.edit;

  /// Cómo se llama el fernie [id], o cadena vacía si no se sabe todavía.
  String nameOf(int id) {
    for (final fernie in fernies) {
      if (fernie.id == id) return fernie.name;
    }
    return '';
  }

  /// Los fernies que de verdad tienen alguna región en este contenido ahora
  /// mismo.
  ///
  /// Se calcula, no se arrastra: borrar la última región de un fernie tiene que
  /// desatarlo del contenido en el acto, y una lista guardada aparte se quedaría
  /// enseñándolo. Cuenta con lo que hay a la vista, así que los borrados y las
  /// reasignaciones de esta sesión ya están descontados aunque todavía no hayan
  /// bajado a la base de datos.
  List<FernieEntity> get ferniesInMedia {
    final marked = {for (final view in views) view.fernieId};

    return [
      for (final fernie in fernies)
        if (marked.contains(fernie.id)) fernie,
    ];
  }

  /// Si hay trabajo sin guardar. Es lo que decide si cancelar tiene que avisar:
  /// preguntar cuando no hay nada que perder sólo molesta.
  bool get hasChanges =>
      pending.isNotEmpty ||
      edited.isNotEmpty ||
      reassigned.isNotEmpty ||
      deleted.isNotEmpty;

  /// La región elegida, si la hay y sigue existiendo.
  RegionView? get selectedRegion {
    final index = selectedIndex;
    if (index == null) return null;

    final all = views;
    if (index < 0 || index >= all.length) return null;

    return all[index];
  }

  /// Si la región elegida tiene cambios a medias.
  ///
  /// Es lo que hace saltar el aviso al cambiar de región, al soltarla o al
  /// cambiar de herramienta: lo que está en el borrador se perdería.
  bool get hasDraftEdits {
    final region = selectedRegion;
    if (region == null) return false;

    if (draftRect != null && draftRect != region.rect) return true;
    if (draftFernie != null && draftFernie!.id != region.fernieId) return true;

    return false;
  }

  /// Todas las regiones que hay que pintar, en el orden en el que se pintan.
  ///
  /// Primero las guardadas (sin las borradas y con las editadas ya movidas) y
  /// detrás las de esta sesión, que son las últimas en marcarse y las que tienen
  /// que quedar encima.
  List<RegionView> get views {
    return [
      for (final region in saved)
        if (!deleted.contains(region.id))
          RegionView(
            rect: edited[region.id] ??
                Rect.fromLTWH(region.x, region.y, region.w, region.h),
            fernieId: reassigned[region.id] ?? region.fernieId,
            label: nameOf(reassigned[region.id] ?? region.fernieId),
            frameMs: region.frameMs,
            savedId: region.id,
          ),
      for (var index = 0; index < pending.length; index++)
        RegionView(
          rect: pending[index].rect,
          fernieId: pending[index].fernieId,
          label: nameOf(pending[index].fernieId),
          frameMs: pending[index].frameMs,
          pendingIndex: index,
        ),
    ];
  }

  /// Los rectángulos que hay que pintar, con el borrador de la elegida ya
  /// puesto encima.
  List<RegionView> get visibleViews {
    final index = selectedIndex;
    final draft = draftRect;
    final all = views;

    if (index == null || draft == null || index >= all.length) return all;

    return [
      for (var i = 0; i < all.length; i++)
        if (i == index)
          RegionView(
            rect: draft,
            label: draftFernie?.name ?? all[i].label,
            fernieId: draftFernie?.id ?? all[i].fernieId,
            frameMs: all[i].frameMs,
            savedId: all[i].savedId,
            pendingIndex: all[i].pendingIndex,
          )
        else
          all[i],
    ];
  }

  /// Lo que el modelo propone y nadie ha aceptado todavía.
  ///
  /// Se dibuja sobre el contenido sin estar marcado: pulsar una la marca, y hay
  /// un botón para aceptarlas todas. Lo que quede aquí al salir **no se
  /// guarda** — proponer no es marcar.
  final List<ProposedRegion> proposed;

  /// Cuántas veces se le ha puesto al contenido lo que los fernies enlazan.
  ///
  /// Un contador y no un interruptor: el visor lo escucha para volver a leer las
  /// etiquetas, y con un booleano la segunda vez seguida no habría cambio que
  /// escuchar. Lo que importa no es el número sino que **haya cambiado**.
  final int appliedLinks;

  FernieModeState copyWith({
    ViewerMode? mode,
    FernieTool? tool,
    int? mediaId,
    List<FernieRegionEntity>? saved,
    List<FernieEntity>? fernies,
    List<PendingRegion>? pending,
    Map<int, Rect>? edited,
    Map<int, int>? reassigned,
    Set<int>? deleted,
    bool? infoWasOpen,
    bool? isBusy,
    List<ProposedRegion>? proposed,
    int? appliedLinks,
  }) {
    return FernieModeState(
      mode: mode ?? this.mode,
      tool: tool ?? this.tool,
      mediaId: mediaId ?? this.mediaId,
      saved: saved ?? this.saved,
      fernies: fernies ?? this.fernies,
      pending: pending ?? this.pending,
      edited: edited ?? this.edited,
      reassigned: reassigned ?? this.reassigned,
      deleted: deleted ?? this.deleted,
      // La selección y su borrador no se arrastran con `??`: quitarlos es tan
      // normal como ponerlos, y con el operador de siempre no habría manera de
      // dejarlos en nada. Quien los quiera conservar usa [withSelection].
      infoWasOpen: infoWasOpen ?? this.infoWasOpen,
      isBusy: isBusy ?? this.isBusy,
      proposed: proposed ?? this.proposed,
      appliedLinks: appliedLinks ?? this.appliedLinks,
    );
  }

  /// El mismo estado con otra región elegida y otro borrador.
  FernieModeState withSelection({
    int? selectedIndex,
    Rect? draftRect,
    FernieEntity? draftFernie,
  }) {
    return FernieModeState(
      mode: mode,
      tool: tool,
      mediaId: mediaId,
      saved: saved,
      fernies: fernies,
      pending: pending,
      edited: edited,
      reassigned: reassigned,
      deleted: deleted,
      selectedIndex: selectedIndex,
      draftRect: draftRect,
      draftFernie: draftFernie,
      infoWasOpen: infoWasOpen,
      isBusy: isBusy,
      proposed: proposed,
      appliedLinks: appliedLinks,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        tool,
        mediaId,
        saved,
        fernies,
        pending,
        edited,
        reassigned,
        deleted,
        selectedIndex,
        draftRect,
        draftFernie,
        infoWasOpen,
        isBusy,
        proposed,
        appliedLinks,
      ];
}
