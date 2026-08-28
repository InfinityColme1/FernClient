// lib/features/media/presentation/widgets/media_item.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/services/media_size_store.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_unlock_dialog.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../domain/entities/media/media_summary_entity.dart';

/// Lo que se ve pegado al cursor al arrastrar contenido.
///
/// **Con varios se arrastra una pila, no una miniatura con un número.** El
/// número dice cuántos son, pero hay que leerlo; la pila dice que son varios de
/// un vistazo, que es lo que hace falta mientras se está apuntando a una
/// etiqueta al otro lado de la pantalla. Van las dos cosas: las siluetas por
/// detrás y el número encima.
///
/// Sin ellas, arrastrar una celda con treinta seleccionadas parecía que movía
/// una sola, y la sorpresa llegaba al soltar.
class _DragFeedback extends StatelessWidget {
  final String? path;
  final int count;

  const _DragFeedback({required this.path, required this.count});

  /// Una de las siluetas de detrás: el mismo recorte, sin contenido dentro.
  ///
  /// No lleva la imagen: son el borde de un montón, no copias de la miniatura.
  /// Repetir la foto tres veces se lee como tres fotos iguales, que es
  /// justamente lo que no pasa.
  Widget _silhouette(BuildContext context, int depth) {
    final scale = 1.0 - dragStackScaleStep * depth;

    return Transform.translate(
      offset: Offset(dragStackOffset * depth, -dragStackOffset * depth),
      child: Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: context.colors.outline,
              width: AppSizes.borderHairline,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMany = count > 1;

    return SizedBox(
      width: dragFeedbackSize,
      height: dragFeedbackSize,
      child: Stack(
        // Las siluetas se salen del cuadro por arriba y por la derecha: es lo
        // que hace que se vean asomar.
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          if (hasMany)
            for (var depth = dragStackDepth; depth >= 1; depth--)
              _silhouette(context, depth),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: path == null
                ? ColoredBox(color: context.colors.secondary)
                : Image.file(File(path!), fit: BoxFit.cover),
          ),
          if (hasMany)
            Positioned(
              left: -AppSpacing.xs,
              bottom: -AppSpacing.xs,
              child: FernBadge(count: count),
            ),
        ],
      ),
    );
  }
}

/// Celda de la rejilla multimedia.
///
/// Se encarga de tres cosas: pintar el contenido a máxima calidad (recortando
/// antes que escalar hacia arriba), dar respuesta visual al ratón y, en el caso
/// de los vídeos, reproducir una previsualización en bucle mientras el cursor
/// está encima.
class MediaItem extends StatefulWidget {
  final MediaSummaryEntity media;
  final VoidCallback? onTap;

  /// `true` si el elemento forma parte de la selección actual.
  final bool isSelected;

  /// `true` mientras este contenido sea uno de los del último aviso.
  ///
  /// Va aparte de la selección porque no es lo mismo: la selección la hace el
  /// usuario y dura hasta que la deshaga; esto lo pone la aplicación y se apaga
  /// en cuanto él da señales de haberlo visto. Pintarlos igual haría creer que
  /// hay veinte contenidos seleccionados.
  final bool isHighlighted;

  /// Se invoca la primera vez que el ratón pasa por encima estando señalado: es
  /// una de las tres formas de dar el aviso por visto.
  final VoidCallback? onHighlightSeen;

  /// Se invoca al pulsar el botón de selección que aparece al pasar el ratón.
  final VoidCallback? onSelectionToggled;

  /// Se invoca al pulsar con la tecla mayúsculas, tanto en el contenido como en
  /// el botón de selección: en vez de tocar sólo este elemento, la selección se
  /// extiende desde el último marcado hasta él.
  final VoidCallback? onRangeSelectionRequested;

  /// Se invoca, una sola vez por fichero, cuando el contenido no se ha podido
  /// cargar. Quien lo escuche decide qué hacer con el contenido.
  final VoidCallback? onLoadFailed;

  /// Si esta celda vuela al visor al abrirla.
  ///
  /// No siempre: en la vista por grupos el mismo contenido puede salir dos veces
  /// y dos vuelos con la misma etiqueta en una pantalla revientan.
  final bool fliesToViewer;

  /// Recorte que hay que enseñar en lugar del contenido entero.
  ///
  /// Con esto puesto la celda deja de ser el fichero y pasa a ser **una región
  /// suya**: toma la proporción de la región, no la del fichero, y pinta sólo
  /// ese trozo. Es lo que hace la rejilla de la pantalla de fernies, donde cada
  /// celda es una región marcada y no un contenido.
  ///
  /// Sin él, la celda se comporta exactamente como siempre.
  final RegionCrop? crop;

  /// Los demás fotogramas del tramo, con [crop] delante y en el orden en el que
  /// se reproducen.
  ///
  /// Con más de uno la celda se mueve sola, en bucle, como un GIF: varios
  /// fotogramas seguidos del mismo fernie son **una escena**, y verla moverse
  /// dice mucho más que cinco celdas casi idénticas puestas en fila.
  final List<RegionCrop> frames;

  /// Aviso que se pinta en la esquina de la celda, con su explicación al pasar
  /// el ratón. `null` cuando no hay nada que advertir.
  final String? warning;

  /// Se invoca al pulsar con el botón derecho, con dónde se ha pulsado.
  ///
  /// La celda no monta el menú: sólo dice que se lo han pedido y dónde. Quien
  /// lo pinta es la rejilla, que es la que tiene el `Stack` en el que cabe y la
  /// que sabe a qué contenidos se va a aplicar.
  final void Function(Offset globalPosition)? onContextMenu;

  /// Los contenidos que viajan si se arrastra esta celda.
  ///
  /// Los decide quien monta la rejilla y no la celda: la regla es «si hay
  /// selección, la selección; si no, ésta», y quién está seleccionado lo sabe la
  /// rejilla. Vacío o nulo, la celda no se arrastra.
  final List<int>? dragIds;

  const MediaItem({
    super.key,
    required this.media,
    this.onTap,
    this.isSelected = false,
    this.isHighlighted = false,
    this.onHighlightSeen,
    this.onSelectionToggled,
    this.onRangeSelectionRequested,
    this.onLoadFailed,
    this.fliesToViewer = false,
    this.crop,
    this.frames = const [],
    this.warning,
    this.dragIds,
    this.onContextMenu,
  });

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  /// Una previsualización por fotograma de la celda. Con una imagen o con un
  /// recorte suelto hay una sola.
  List<MediaPreview?> _previews = const [];

  /// Qué fotograma del tramo toca pintar.
  int _frameIndex = 0;

  /// Quién decide si esta celda va tapada.
  ///
  /// Si no hay nadie registrado —una prueba que pinta una celda suelta, sin la
  /// aplicación montada detrás— vale la neutral, que no tapa nada. Lo que de
  /// verdad esconde el contenido bloqueado es el filtro del repositorio; esto
  /// es cómo se pinta lo que ya ha pasado por él.
  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

  /// Esta celda se enseña tapada: es contenido marcado como no apto, el
  /// bloqueo está cerrado y el usuario ha pedido verlo tapado en lugar de que
  /// desaparezca.
  ///
  /// Se pregunta en cada pintado y no se guarda: abrir el bloqueo tiene que
  /// destaparlo sin que nadie tenga que acordarse de avisar a cada celda.
  bool get _isCovered => _visibility.blursMedia(widget.media.id);

  /// El pase de fotogramas de un tramo de vídeo.
  Timer? _flipbook;

  bool _isHovered = false;

  Player? _player;
  VideoController? _videoController;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isPreviewReady = false;

  /// La espera entre que el ratón llega y que el vídeo empieza.
  Timer? _hoverDelay;

  /// La celda que está reproduciendo ahora mismo, en toda la aplicación.
  ///
  /// Una y sólo una. Cada reproductor de `media_kit` reserva memoria nativa que
  /// no se recupera hasta que se cierra, y aunque cada celda cierre el suyo al
  /// salir el ratón, con el desplazamiento rápido se solapan: la celda se
  /// desmonta antes de que el `onExit` llegue. Con esta referencia, abrir uno
  /// cierra el anterior pase lo que pase.
  static _MediaItemState? _playing;

  /// Evita repetir el aviso de fallo de carga: la celda se reconstruye muchas
  /// veces (scroll, hover, selección) y el fichero sigue siendo el mismo.
  bool _loadFailureReported = false;

  bool get _isVideo => widget.media.path.isVideoPath;

  /// Los recortes que enseña la celda, en el orden en el que se pasan. Vacío
  /// cuando la celda es el fichero entero.
  List<RegionCrop> get _crops {
    if (widget.frames.isNotEmpty) return widget.frames;

    final crop = widget.crop;
    return crop == null ? const [] : [crop];
  }

  /// De qué instante sale la miniatura de cada uno: el de la región cuando la
  /// celda es una región de un vídeo, y el de siempre en todo lo demás.
  List<Duration?> get _frames {
    final crops = _crops;
    if (crops.isEmpty) return const [null];

    return [
      for (final crop in crops)
        if (crop.frameMs case final frameMs?)
          Duration(milliseconds: frameMs)
        else
          null,
    ];
  }

  /// El recorte que toca pintar ahora mismo.
  RegionCrop? get _crop {
    final crops = _crops;
    if (crops.isEmpty) return null;

    return crops[_frameIndex.clamp(0, crops.length - 1)];
  }

  /// La previsualización del fotograma que toca, o la primera que haya llegado.
  ///
  /// La de reserva importa para las proporciones: la celda tiene que saber lo
  /// que mide el fichero antes de tener todos los fotogramas, o daría un salto
  /// de forma al llegar el primero.
  /// Si esta celda puede colocarse sin abrir el fichero.
  ///
  /// Una imagen cuyo tamaño ya está guardado no necesita nada más: se pinta con
  /// `Image.file` y ya. Lo que obligaba a leer el fichero era saber cuánto medía
  /// para darle su sitio en la rejilla, y eso ahora se sabe de antemano.
  ///
  /// Un vídeo no cuenta: de él hace falta además el fotograma, que sólo se puede
  /// sacar abriéndolo.
  bool get _sizeIsKnown => !_isVideo && widget.media.hasSize;

  MediaPreview? get _preview {
    if (_previews.isEmpty) return null;

    final current = _previews[_frameIndex.clamp(0, _previews.length - 1)];
    if (current != null) return current;

    for (final preview in _previews) {
      if (preview != null) return preview;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _resetPreviews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final flinging = FastScrollScope.of(context);
    if (flinging == _isFlinging) return;

    _isFlinging = flinging;

    // Al parar, lo que se dejó para luego es justo lo que ha quedado delante:
    // es el momento de cargarlo, y ahora sin nadie compitiendo.
    if (!flinging && _deferred) {
      _deferred = false;
      _resetPreviews();
    }
  }

  @override
  void didUpdateWidget(covariant MediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El recorte también identifica lo que hay que enseñar: dos celdas del
    // mismo fichero con regiones distintas no pintan lo mismo.
    if (oldWidget.media.path == widget.media.path &&
        oldWidget.crop == widget.crop &&
        listEquals(oldWidget.frames, widget.frames)) {
      return;
    }

    _stopPreview();
    _stopFlipbook();
    _loadFailureReported = false;
    _retriedAfterDrop = false;
    _painted = null;
    _resetPreviews();
  }

  @override
  void dispose() {
    _cancelHoverDelay();
    _stopPreview();
    _stopFlipbook();
    _releaseHeld();
    super.dispose();
  }

  /// Lo que esta celda tiene pedido al servicio de previsualizaciones.
  ///
  /// Se apunta para poder **soltarlo** al desmontarse o al pasar a ser de otro
  /// contenido. Sin eso, desplazarse deprisa dejaba miles de peticiones vivas de
  /// celdas que ya no existen, cada una abriendo su vídeo o cargando su fichero
  /// entero en memoria cuando le llegaba el turno.
  ({String path, List<Duration?> frames})? _held;

  void _hold(String path, List<Duration?> frames) {
    _releaseHeld();

    for (final frame in frames) {
      MediaPreviewService.instance.hold(path, frame: frame);
    }

    _held = (path: path, frames: frames);
  }

  void _releaseHeld() {
    final held = _held;
    if (held == null) return;

    _held = null;

    for (final frame in held.frames) {
      MediaPreviewService.instance.release(held.path, frame: frame);
    }
  }

  /// Deja la celda esperando los fotogramas que le tocan, con los que ya
  /// estuvieran resueltos puestos de salida.
  void _resetPreviews() {
    final frames = _frames;

    _frameIndex = 0;
    _previews = [
      for (final frame in frames)
        MediaPreviewService.instance.peek(widget.media.path, frame: frame),
    ];

    // Una imagen de la que ya se sabe lo que mide no necesita que se le abra el
    // fichero: se pinta y ya. Es lo que convierte mil trescientas lecturas
    // completas de disco en ninguna.
    if (_sizeIsKnown && _crops.isEmpty) {
      _releaseHeld();
      return;
    }

    if (_previews.any((preview) => preview == null)) {
      // Con la rejilla lanzada no se pide: se apunta para cuando pare.
      if (_isFlinging) {
        _deferred = true;
        _releaseHeld();

        return;
      }

      _hold(widget.media.path, frames);
      _loadPreviews(frames);
      return;
    }

    _releaseHeld();
    _startFlipbook();
  }

  /// Resuelve los fotogramas que falten, de uno en uno.
  ///
  /// De uno en uno y no todos a la vez: sacar un fotograma de un vídeo abre un
  /// reproductor, y el servicio sólo deja dos a la vez. Pidiéndolos en fila, el
  /// primero llega enseguida y la celda ya enseña algo mientras vienen los
  /// demás.
  Future<void> _loadPreviews(List<Duration?> frames) async {
    final path = widget.media.path;

    for (var index = 0; index < frames.length; index++) {
      if (_previews[index] != null) continue;

      final preview = await MediaPreviewService.instance.load(
        path,
        frame: frames[index],
        // Prescindible: si al llegar su turno esta celda ya es de otro
        // contenido, no hay nada que enseñar y no merece abrir el fichero.
        droppable: true,
      );

      // La celda se reaprovecha al desplazar la rejilla: si mientras se pedía el
      // fotograma ha pasado a ser de otro contenido, esto ya no le sirve.
      //
      // El fichero se compara **además** de los instantes, y no basta con
      // aquéllos: en una celda que no es un recorte el instante es siempre
      // `null`, así que cualquier celda reaprovechada pasaba el filtro y se
      // quedaba con la miniatura del contenido anterior.
      if (!mounted || widget.media.path != path) return;
      if (!listEquals(_frames, frames)) return;

      if (preview == null) {
        // Puede ser que el fichero no valga, o que el trabajo se dejara pasar
        // por no quedar nadie esperándolo. Lo segundo no es un fallo, y esta
        // celda sigue montada, así que se vuelve a pedir en vez de darlo por
        // roto: dar por roto un vídeo bueno lo saca de la rejilla.
        if (_held != null && !_retriedAfterDrop) {
          _retriedAfterDrop = true;
          _hold(path, frames);
          unawaited(_loadPreviews(frames));

          return;
        }

        _releaseHeld();
        _reportLoadFailure();

        return;
      }

      _remember(preview);

      setState(() => _previews[index] = preview);
    }

    _releaseHeld();
    _startFlipbook();
  }

  /// Apunta lo que mide el fichero, para no volver a averiguarlo.
  ///
  /// Sólo lo que se ha tenido que descubrir: el contenido que se da de alta hoy
  /// ya nace con su tamaño puesto, y esto es para el que entró antes de que eso
  /// existiera. Se escribe en tandas, no una transacción por celda.
  void _remember(MediaPreview preview) {
    if (widget.media.hasSize) return;

    final width = preview.width;
    final height = preview.height;
    if (width == null || height == null) return;

    MediaSizeStore.instance.remember(
      widget.media.id,
      width: width,
      height: height,
    );
  }

  /// La rejilla va lanzada ahora mismo.
  ///
  /// Mientras lo esté, esta celda no empieza a cargar nada ni descodifica
  /// ninguna imagen nueva: es trabajo para medio fotograma que se lo quita a las
  /// celdas que van a quedarse delante cuando pare.
  bool _isFlinging = false;

  /// Había algo que cargar y se dejó para cuando pare.
  bool _deferred = false;

  /// El fichero que esta celda ya tiene pintado.
  ///
  /// Lo que ya está a la vista se sigue enseñando aunque la rejilla vaya
  /// lanzada: volver a pintarlo no cuesta nada —está descodificado— y quitarlo
  /// sería apagar media pantalla por gusto. Lo que se aparta es **empezar** algo
  /// nuevo.
  String? _painted;

  /// Si ya se ha vuelto a pedir una vez lo que se dejó pasar.
  ///
  /// Una sola: con dos celdas peleando por el mismo fichero, reintentar sin tope
  /// sería un bucle.
  bool _retriedAfterDrop = false;

  /// Arranca el pase de fotogramas de un tramo.
  ///
  /// Espera a tenerlos todos: empezar a medias dejaría la celda parada en los
  /// que faltan, y un pase que se atasca se lee peor que un fotograma quieto.
  void _startFlipbook() {
    if (_flipbook != null || _crops.length < 2) return;
    if (_previews.any((preview) => preview == null)) return;

    _flipbook = Timer.periodic(fernieRegionFlipbookStep, (_) {
      if (!mounted) return;
      setState(() => _frameIndex = (_frameIndex + 1) % _crops.length);
    });
  }

  void _stopFlipbook() {
    _flipbook?.cancel();
    _flipbook = null;
  }

  /// Avisa de que este contenido no se ha podido cargar.
  ///
  /// No se juzga aquí el motivo: sólo se cuenta lo que ha pasado y quien
  /// escucha comprueba si el fichero sigue estando.
  void _reportLoadFailure() {
    if (_loadFailureReported) return;
    _loadFailureReported = true;
    widget.onLoadFailed?.call();
  }

  /// Extiende la selección si se está pulsando mayúsculas. Devuelve `true`
  /// cuando lo ha hecho, para que el clic no siga su camino normal.
  bool _extendSelection() {
    final extend = widget.onRangeSelectionRequested;
    if (extend == null || !HardwareKeyboard.instance.isShiftPressed) {
      return false;
    }
    extend();
    return true;
  }

  /// Clic sobre el contenido: abre el visor, salvo que se esté pulsando
  /// mayúsculas para estirar la selección.
  void _onTap() {
    if (_extendSelection()) return;

    // Tapado, tocarlo no abre nada: pide la contraseña. Si se acierta, el modo
    // queda abierto y la rejilla entera se destapa sola; el contenido se abre
    // con el toque siguiente, que es lo que espera quien acaba de encontrarse
    // un candado.
    if (_isCovered) {
      unawaited(_askForPassword());
      return;
    }

    widget.onTap?.call();
  }

  Future<void> _askForPassword() async {
    await showFernDialog<bool, Never>(
      context: context,
      builder: (_) => const NsfwUnlockDialog(),
    );

    if (mounted) setState(() {});
  }

  void _onSelectionPressed() {
    if (_extendSelection()) return;
    widget.onSelectionToggled?.call();
  }

  void _onHoverChanged(bool isHovered) {
    // Pasar el ratón por encima es haberlo visto. Se avisa aunque el estado de
    // hover no cambie de valor, porque lo que importa es el gesto.
    if (isHovered && widget.isHighlighted) widget.onHighlightSeen?.call();

    if (_isHovered == isHovered) return;
    setState(() => _isHovered = isHovered);

    // Una celda que es un recorte no reproduce nada al pasar por encima: lo que
    // se reproduciría es el vídeo entero, y aquí lo que se está enseñando es un
    // trozo de un fotograma suyo. Y una tapada, menos: sería reproducir un
    // vídeo detrás de una tapa que existe justamente para no verlo.
    if (!_isVideo || _crops.isNotEmpty || _isCovered) return;
    if (!isHovered) {
      _cancelHoverDelay();
      _stopPreview();

      return;
    }

    // No se abre nada todavía: se espera a ver si el ratón se queda.
    _hoverDelay?.cancel();
    _hoverDelay = Timer(mediaVideoPreviewDelay, () {
      if (mounted && _isHovered) _startPreview();
    });
  }

  void _cancelHoverDelay() {
    _hoverDelay?.cancel();
    _hoverDelay = null;
  }

  Future<void> _startPreview() async {
    if (_player != null) return;

    // Fuera el de antes, sea de la celda que sea.
    _playing?._stopPreview();
    _playing = this;

    final player = Player(
      configuration: const PlayerConfiguration(
        muted: true,
        logLevel: MPVLogLevel.error,
      ),
    );
    final controller = VideoController(player);
    _player = player;
    _videoController = controller;

    // Los vídeos más largos que la previsualización vuelven al principio al
    // llegar al límite; los más cortos se repiten solos con el modo bucle.
    _positionSubscription = player.stream.position.listen((position) {
      if (position >= mediaVideoPreviewLength) player.seek(Duration.zero);
    });

    try {
      await player.setPlaylistMode(PlaylistMode.loop);
      await player.setVolume(0);
      await player.open(Media(widget.media.path));

      if (!mounted || !_isHovered) {
        _stopPreview();
        return;
      }
      setState(() => _isPreviewReady = true);
    } catch (e) {
      debugPrint('MediaItem: no se pudo previsualizar el vídeo: $e');
      _reportLoadFailure();
      _stopPreview();
    }
  }

  void _stopPreview() {
    if (_playing == this) _playing = null;

    _positionSubscription?.cancel();
    _positionSubscription = null;

    final player = _player;
    _player = null;
    _videoController = null;
    player?.dispose();

    if (!_isPreviewReady) return;
    _isPreviewReady = false;
    if (mounted) setState(() {});
  }

  /// Proporción de la celda: la del fichero, o la de la región cuando la celda
  /// es un recorte.
  ///
  /// Sin esto la región saldría deformada: se pintaría el trozo que toca dentro
  /// de una celda con la forma del fichero entero.
  /// El ancho del fichero: lo guardado si lo hay, y si no lo que dijo la
  /// previsualización.
  int? get _intrinsicWidth => widget.media.width ?? _preview?.width;
  int? get _intrinsicHeight => widget.media.height ?? _preview?.height;

  double get _aspectRatio {
    final width = _intrinsicWidth;
    final height = _intrinsicHeight;

    if (width == null || height == null || width <= 0 || height <= 0) {
      return mediaFallbackAspectRatio;
    }

    // Siempre la del primer fotograma, aunque el tramo se esté moviendo: si
    // cada fotograma pusiera la suya, la celda cambiaría de forma en cada paso
    // y arrastraría con ella a toda la fila de la rejilla.
    final crop = _crops.isEmpty ? null : _crops.first;
    if (crop == null) return width / height;

    return crop.aspectRatio(Size(width.toDouble(), height.toDouble()));
  }

  /// Un marco alrededor de lo que está señalado por el último aviso.
  ///
  /// Un marco y no un tinte encima: el tinte cambiaría los colores del propio
  /// contenido, que es justo lo que el usuario ha venido a mirar.
  Widget _highlighted(BuildContext context, Widget child) {
    if (!widget.isHighlighted) return child;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: context.colors.terciary,
          width: mediaHighlightBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(mediaHighlightBorderWidth),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _aspectRatio;

    final dragIds = widget.dragIds;

    return _highlighted(
      context,
      FernDraggableCard<List<int>>(
        // Tapado no se arrastra: sería mover contenido que no se está viendo, y
        // soltarlo sobre una etiqueta lo etiquetaría a ciegas.
        isEnabled: dragIds != null && dragIds.isNotEmpty && !_isCovered,
        data: dragIds ?? const [],
        feedback: _DragFeedback(
          path: _isVideo ? _preview?.thumbnailPath : widget.media.path,
          count: dragIds?.length ?? 0,
        ),
        child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTap: _onTap,
        // Tapada no ofrece nada: lo que hay debajo no se está viendo, y todo lo
        // que el menú hace es sobre contenido que se supone mirado.
        onSecondaryTapDown: widget.onContextMenu == null || _isCovered
            ? null
            : (details) => widget.onContextMenu!(details.globalPosition),
        child: AnimatedScale(
          scale: _isHovered ? mediaHoverScale : 1.0,
          duration: hoverAnimationDuration,
          curve: Curves.easeOut,
          child: _flying(ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildContent(),
                  _buildTopShade(),
                  _buildTopLeftBadges(),
                  _buildSelectionButton(),
                  // La última de la pila: lo que tapa tiene que quedar por
                  // encima de todo lo demás, insignias incluidas.
                  if (_isCovered) _buildCover(context),
                ],
              ),
            ),
          )),
        ),
      ),
      ),
      ),
    );
  }

  /// La celda, envuelta en su vuelo al visor si le toca.
  ///
  /// Tapada no vuela: lo que se veria durante el vuelo es el contenido que el
  /// filtro esconde, justo lo que no se puede enseñar.
  Widget _flying(Widget child) {
    if (!widget.fliesToViewer || _isCovered) return child;

    return Hero(
      tag: mediaHeroTag(widget.media.path),
      // Durante el vuelo no se arrastra ni se pulsa: lo que se ve es una copia.
      child: child,
    );
  }

  /// La tapa del contenido marcado: desenfoque, un velo y el candado.
  ///
  /// Desenfoque **y** velo, no sólo desenfoque: un desenfoque fuerte todavía
  /// deja ver la forma y los colores, y con eso basta para reconocer lo que hay
  /// debajo en una miniatura. Y el texto, porque una celda borrosa sin
  /// explicación parece contenido roto.
  Widget _buildCover(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.lock, color: Colors.white),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  texts.nsfwCoveredLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isPreviewReady && _videoController != null) {
      return Video(
        controller: _videoController!,
        controls: NoVideoControls,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      );
    }

    final path = _isVideo ? _preview?.thumbnailPath : widget.media.path;
    if (path == null) return _buildPlaceholder();

    // Mientras la rejilla va lanzada sólo se sigue pintando lo que ya estaba
    // pintado. Descodificar una imagen nueva para enseñarla medio fotograma es
    // el trabajo que hacía que desplazarse deprisa fuera lento y desigual.
    if (_isFlinging && _painted != path) return _buildPlaceholder();

    // Se apunta en el pintado a propósito y sin `setState`: no cambia nada de lo
    // que se ve, sólo recuerda que esta celda ya tiene esto delante.
    _painted = path;

    if (_crop case final crop?) return _buildCroppedContent(path, crop);

    return LayoutBuilder(
      builder: (context, constraints) => Image.file(
        File(path),
        // El fichero identifica a la imagen: cambiar de contenido (la celda se
        // reaprovecha al desplazar la rejilla) tiene que empezar de cero, y no
        // dejar a la vista la imagen anterior como hace `gaplessPlayback`.
        key: ValueKey(path),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        // Cambiar de resolución no deja la celda en blanco: se sigue viendo lo
        // que ya estaba descodificado hasta que la nueva está lista. Sin esto,
        // reescalar la ventana apaga y enciende todas las imágenes de la
        // rejilla en cada fotograma.
        gaplessPlayback: true,
        // Se decodifica a la resolución en la que se va a pintar (nunca por
        // debajo), que es lo que evita el efecto borroso.
        cacheWidth: _decodeWidth(context, constraints.maxWidth),
        errorBuilder: (_, _, _) {
          _reportLoadFailure();
          return _buildPlaceholder(isBroken: true);
        },
      ),
    );
  }

  /// Pinta sólo el trozo de [path] que marca [crop], a tamaño de celda.
  ///
  /// La imagen se pinta entera al tamaño que haga falta para que la región llene
  /// la celda, y se recorta lo que sobra. Se decodifica pensando en la región y
  /// no en la celda: si se decodificara al ancho de la celda, ampliar después un
  /// trozo pequeño daría una mancha borrosa. El límite lo sigue poniendo el
  /// ancho real del fichero, que es donde deja de haber resolución que ganar.
  Widget _buildCroppedContent(String path, RegionCrop crop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Una región degenerada dejaría la imagen a tamaño infinito.
        if (!width.isFinite || crop.w <= 0 || crop.h <= 0) {
          return _buildPlaceholder(isBroken: true);
        }

        final fullWidth = width / crop.w;
        final fullHeight = height / crop.h;

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: fullWidth,
            maxWidth: fullWidth,
            minHeight: fullHeight,
            maxHeight: fullHeight,
            child: Transform.translate(
              offset: Offset(-crop.x * fullWidth, -crop.y * fullHeight),
              child: Image.file(
                File(path),
                key: ValueKey('$path|${crop.hashCode}'),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                cacheWidth: _decodeWidth(context, fullWidth),
                errorBuilder: (_, _, _) {
                  _reportLoadFailure();
                  return _buildPlaceholder();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Ancho de decodificación en píxeles físicos, limitado por el ancho real del
  /// fichero para no gastar memoria escalando hacia arriba.
  ///
  /// Va a saltos de [mediaDecodeWidthStep]: es la clave con la que se guarda la
  /// imagen descodificada, así que si siguiera al ancho exacto de la celda, un
  /// reescalado de la ventana la haría descodificar de nuevo desde el disco en
  /// cada fotograma. Redondea hacia arriba para no perder resolución.
  int? _decodeWidth(BuildContext context, double layoutWidth) {
    if (!layoutWidth.isFinite || layoutWidth <= 0) return null;

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final target = (layoutWidth * devicePixelRatio * mediaHoverScale).ceil();
    final stepped =
        (target / mediaDecodeWidthStep).ceil() * mediaDecodeWidthStep;
    final intrinsic = _intrinsicWidth;

    if (intrinsic == null || intrinsic <= 0) return stepped;
    return math.min(stepped, intrinsic);
  }

  /// El hueco de una celda: **esperando** o **rota**, que no es lo mismo.
  ///
  /// Antes eran lo mismo: un cuadrado gris con un icono de imagen rota, tanto
  /// mientras la miniatura estaba de camino como cuando el fichero ya no estaba.
  /// Decir «esto se ha roto» a algo que sólo está tardando es mentir, y encima
  /// es lo que más se ve: al desplazarse deprisa la rejilla entera se llena de
  /// estos huecos durante un segundo.
  ///
  /// Esperando se pinta el hueco que late, el mismo de la carga; roto se dice
  /// con el icono y el color de lo que va mal.
  Widget _buildPlaceholder({bool isBroken = false}) {
    if (!isBroken) {
      return FernSkeleton(
        radius: AppSizes.radiusLarge,
        // Lanzada, quieto. La rejilla se llena de huecos justo mientras se
        // desplaza deprisa, y decenas de latidos a la vez son lo contrario de lo
        // que hace falta ahí — además de que nadie los mira al pasar de largo.
        isPulsing: !_isFlinging,
      );
    }

    // Sin texto: en una miniatura no cabe, y lo que hace falta a ese tamaño es
    // distinguir de un vistazo la celda rota de las demás.
    return ColoredBox(
      color: context.colors.secondary,
      child: FernBrokenMedia.compact(isVideo: _isVideo),
    );
  }

  /// Sombreado interior en la parte superior, sólo visible bajo el cursor.
  Widget _buildTopShade() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: hoverAnimationDuration,
        child: FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: mediaShadeHeightFactor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.scrim.withValues(alpha: mediaShadeOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Lo que se cuenta de la celda sin tener que abrirla: el aviso, si lo hay, y
  /// la duración cuando es un vídeo.
  ///
  /// Van juntos en la misma esquina y en la misma fila para que no se pisen: una
  /// región marcada sobre un vídeo pendiente de revisar lleva los dos.
  Widget _buildTopLeftBadges() {
    final warning = widget.warning;
    final hasSuggestions = widget.media.hasPendingSuggestions;

    if (warning == null && !_isVideo && !hasSuggestions) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: AppSpacing.s,
      left: AppSpacing.s,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (warning != null) ...[
            _buildWarningBadge(warning),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (hasSuggestions) ...[
            _buildSuggestionsBadge(),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (_isVideo) _buildVideoBadge(),
        ],
      ),
    );
  }

  /// Aquí hay algo propuesto que nadie ha contestado.
  ///
  /// Sin esto, una rejilla de trescientas miniaturas no dice cuáles llevan
  /// trabajo pendiente, y revisar es abrirlas una a una para descubrir que la
  /// mayoría no tenía nada.
  ///
  /// El mismo icono con el que se pide reconocer: lo que marca es de dónde
  /// viene, y usar otro obligaría a aprenderse dos.
  Widget _buildSuggestionsBadge() {
    return Tooltip(
      message: AppLocalizations.of(context).suggestionsPendingBadge,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.colors.scrim.withValues(alpha: mediaBadgeOpacity),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.auto_awesome,
          color: context.colors.terciary,
          size: AppSizes.iconSmall,
        ),
      ),
    );
  }

  /// El aviso, con su explicación al pasar el ratón.
  ///
  /// No lleva `IgnorePointer` como el resto de distintivos: si no atendiera al
  /// ratón no habría forma de leer por qué está ahí.
  Widget _buildWarningBadge(String warning) {
    return Tooltip(
      message: warning,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.colors.scrim.withValues(alpha: mediaBadgeOpacity),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.warning_amber,
          color: context.colors.terciary,
          size: AppSizes.iconSmall,
        ),
      ),
    );
  }

  Widget _buildVideoBadge() {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.colors.scrim.withValues(alpha: mediaBadgeOpacity),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.play_arrow,
              color: Colors.white,
              size: AppSizes.iconSmall,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatDuration(_preview?.duration),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton() {
    final isVisible = _isHovered || widget.isSelected;

    return Positioned(
      top: AppSpacing.xs,
      right: AppSpacing.xs,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: hoverAnimationDuration,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: IconButton(
            onPressed: _onSelectionPressed,
            tooltip: widget.isSelected
                ? AppLocalizations.of(context).deselectItem
                : AppLocalizations.of(context).selectItem,
            visualDensity: VisualDensity.compact,
            iconSize: AppSizes.iconMedium,
            icon: Icon(
              widget.isSelected
                  ? Symbols.check_circle
                  : Symbols.radio_button_unchecked,
              color: widget.isSelected ? context.colors.terciary : Colors.white,
              shadows: [
                Shadow(
                  color: context.colors.scrim
                      .withValues(alpha: mediaSelectionShadowOpacity),
                  blurRadius: AppSpacing.xs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return mediaEmptyDurationLabel;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours == 0) return '$minutes:$seconds';
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
}
