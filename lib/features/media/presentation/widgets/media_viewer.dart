import 'dart:async';
import 'dart:io';

import 'package:Fern/core/ui/display/fern_broken_media.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaViewer extends StatefulWidget {
  final String path;

  /// Se invoca, una sola vez por fichero, cuando el contenido no se ha podido
  /// abrir. Quien lo escuche decide qué hacer con el contenido.
  final VoidCallback? onLoadFailed;

  /// El zoom y el desplazamiento, si alguien de fuera necesita conocerlos o
  /// tocarlos. Sin esto el visor se hace el suyo y funciona como siempre.
  ///
  /// Hace falta desde que se marcan regiones: para llevar un rectángulo de la
  /// pantalla a coordenadas de la imagen hay que saber con qué transformación se
  /// está pintando, y antes no había forma de preguntarlo.
  final TransformationController? controller;

  /// Si el visor atiende a los gestos de zoom y desplazamiento.
  ///
  /// Se apaga en el modo fernie: allí los gestos los reparte la capa de
  /// selección, que es quien sabe distinguir un arrastre que recorta de uno que
  /// desplaza. La transformación se sigue aplicando igual.
  final bool interactive;

  /// El mando de la reproducción, para quien necesite pararla, moverla o saber
  /// por dónde va. Sólo se engancha con lo que se reproduce.
  ///
  /// Es lo que necesita el modo fernie: se marca sobre un fotograma quieto, y
  /// para elegir cuál hay que poder recorrer el contenido de uno en uno.
  final MediaPlaybackController? playback;

  /// Con `true` la reproducción arranca parada y no se pone en marcha sola.
  ///
  /// Es lo que hace el modo fernie: se entra a marcar sobre lo que se estaba
  /// viendo, no sobre lo que siga corriendo.
  final bool paused;

  /// Con `true` el contenido se recorre fotograma a fotograma.
  ///
  /// Sólo lo pide el modo fernie. Cambia lo que se hace con un GIF: fuera del
  /// modo se anima solo, como cualquier GIF y sin mando ninguno; dentro se abre
  /// entero para poder pararlo en el fotograma que se quiera marcar.
  final bool stepped;

  const MediaViewer({
    super.key,
    required this.path,
    this.onLoadFailed,
    this.controller,
    this.interactive = true,
    this.playback,
    this.paused = false,
    this.stepped = false,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<String>? _errorSubscription;

  /// El de fuera si lo hay, y si no uno propio: así el visor sigue funcionando
  /// suelto, sin que nadie le pase nada.
  late final TransformationController _transformation =
      widget.controller ?? TransformationController();

  /// Evita repetir el aviso de fallo mientras se esté enseñando el mismo
  /// fichero: reproducir un vídeo roto puede dar varios errores seguidos.
  bool _loadFailureReported = false;

  bool get _isVideo => widget.path.isVideoPath;

  bool get _isGif => widget.path.isGifPath;

  /// Si el GIF hay que abrirlo entero para poder pararlo en un fotograma.
  ///
  /// Sólo en el modo de marcar. Fuera de él, un GIF es un GIF: se anima solo con
  /// `Image.file` y no tiene mandos, que es lo que se espera de él y lo que la
  /// aplicación ha hecho siempre.
  bool get _isSteppedGif => _isGif && widget.stepped;

  /// Los fotogramas del GIF, cuando toca recorrerlo.
  GifFrames? _frames;
  bool _isLoadingFrames = false;

  @override
  void initState() {
    super.initState();

    if (_isVideo) _initVideo();
    if (_isSteppedGif) _loadFrames();
  }

  @override
  void didUpdateWidget(covariant MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Parar y seguir no rehace nada: es el mismo fichero y el mismo
    // reproductor, sólo que quieto.
    if (oldWidget.paused != widget.paused) _applyPaused();

    // Entrar o salir del modo de marcar sí cambia cómo se pinta un GIF.
    if (oldWidget.stepped != widget.stepped && _isGif) {
      if (_isSteppedGif) {
        _loadFrames();
      } else {
        widget.playback?.detachSource(_frames);
        setState(() => _frames = null);
      }
    }

    if (oldWidget.path == widget.path) return;

    _disposeVideo();
    _loadFailureReported = false;

    if (_isVideo) _initVideo();
    if (_isSteppedGif) _loadFrames();

    setState(() {});
  }

  @override
  void dispose() {
    _disposeVideo();
    // El controlador de fuera es de quien lo pasó: aquí sólo se suelta el
    // propio.
    if (widget.controller == null) _transformation.dispose();
    super.dispose();
  }

  /// Para el contenido cuando se lo piden. **Nunca lo arranca.**
  ///
  /// Al modo de marcar se entra parando lo que se estaba viendo, pero al salir
  /// no se reanuda nada: el trabajo se queda donde se dejó y quien quiera seguir
  /// viéndolo le da a reproducir. Arrancarlo solo era peor de lo que parece —se
  /// entraba a marcar desde un vídeo ya parado y al salir se ponía a correr.
  void _applyPaused() {
    if (!widget.paused) return;

    _player?.pause();
  }

  /// Abre el GIF entero para poder recorrerlo.
  ///
  /// Tarda lo que tarde: hasta que llegue se sigue viendo el GIF animándose
  /// solo, que es mejor que un hueco en blanco.
  Future<void> _loadFrames() async {
    if (_isLoadingFrames) return;
    _isLoadingFrames = true;

    final frames = await GifFrames.load(widget.path);

    _isLoadingFrames = false;
    if (!mounted || !_isSteppedGif) return;

    // Un GIF de un solo fotograma no tiene nada que recorrer: se queda como
    // estaba y la línea de tiempo no aparece.
    if (frames == null) return;

    widget.playback?.attachFrames(frames);

    // Se entra a marcar sobre un fotograma quieto: el GIF no puede empezar a
    // correr solo en cuanto termina de abrirse.
    widget.playback?.pause();

    setState(() => _frames = frames);
  }

  void _initVideo() {
    final player = Player();
    _player = player;
    _controller = VideoController(player);

    widget.playback?.attach(player);

    // libmpv no lanza al abrir un fichero que no está: el aviso llega por el
    // flujo de errores del reproductor.
    _errorSubscription = player.stream.error.listen((error) {
      debugPrint('MediaViewer: error al reproducir el vídeo: $error');
      _reportLoadFailure();
    });

    player
        .open(Media(widget.path), play: !widget.paused)
        .catchError((Object e) {
      debugPrint('MediaViewer: no se pudo abrir el vídeo: $e');
      _reportLoadFailure();
    });
  }

  void _disposeVideo() {
    _errorSubscription?.cancel();
    _errorSubscription = null;

    final player = _player;
    _player = null;
    _controller = null;

    // Sólo el suyo: si el árbol se ha rehecho, quien manda en el mando es el
    // visor nuevo, que ya se enganchó antes de que llegara esto.
    widget.playback?.detachSource(player);
    player?.dispose();
  }

  /// Avisa de que este contenido no se ha podido abrir.
  ///
  /// No se juzga aquí el motivo: sólo se cuenta lo que ha pasado y quien
  /// escucha comprueba si el fichero sigue estando.
  void _reportLoadFailure() {
    if (_loadFailureReported) return;
    _loadFailureReported = true;
    widget.onLoadFailed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) return _buildVideoPlayer();
    if (_frames != null) return _buildFrameViewer();

    return _buildImageViewer();
  }

  /// El GIF pintado fotograma a fotograma, siguiendo al mando.
  ///
  /// Se pinta con `Image.memory` y sin `gaplessPlayback`: cada fotograma tiene
  /// que sustituir al anterior en el acto, que es de lo que va recorrer un GIF.
  Widget _buildFrameViewer() {
    final frames = _frames!;
    final playback = widget.playback;

    return _buildInteractive(
      playback == null
          ? _frameAt(frames, 0)
          : AnimatedBuilder(
              animation: playback,
              builder: (context, _) => _frameAt(frames, playback.frameIndex),
            ),
    );
  }

  Widget _frameAt(GifFrames frames, int index) {
    final safe = index.clamp(0, frames.length - 1);

    return Image.memory(
      frames.frames[safe],
      key: ValueKey(safe),
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  /// El zoom y el desplazamiento, alrededor de lo que se esté viendo.
  ///
  /// Va sin `Center` a propósito: la capa que dibuja las regiones encima mide el
  /// mismo hueco que el visor, y sus cuentas dan por hecho que el contenido está
  /// encajado con `BoxFit.contain` dentro de ese hueco. Con el `Center` de antes
  /// el visor se encogía a la imagen y las dos medidas dejaban de coincidir.
  Widget _buildInteractive(Widget child) {
    return InteractiveViewer(
      transformationController: _transformation,
      panEnabled: widget.interactive,
      scaleEnabled: widget.interactive,
      minScale: viewerMinZoomScale,
      maxScale: fernieMaxZoomScale,
      child: SizedBox.expand(child: child),
    );
  }

  Widget _buildImageViewer() {
    return _buildInteractive(
      // El otro extremo del vuelo desde la rejilla: la miniatura crece hasta
      // aquí en vez de aparecer de golpe, que es el gesto más repetido de la
      // aplicación y era un corte seco.
      //
      // Sólo las imágenes. Un vídeo llega aquí como reproductor y allí es una
      // miniatura, así que lo que volaría no es lo mismo que aterriza; y un GIF
      // se pinta fotograma a fotograma desde memoria. Sin pareja al otro lado
      // simplemente no hay vuelo, que es la forma de no volar sin romper nada.
      Hero(
        tag: mediaHeroTag(widget.path),
        child: Image.file(
          File(widget.path),
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) {
            _reportLoadFailure();
            return const FernBrokenMedia();
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // El vídeo también se puede acercar: marcar una región pequeña de un
    // fotograma pide lo mismo que marcarla sobre una imagen.
    return _buildInteractive(
      Video(
        controller: controller,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        // Los mandos son los del visor, no los que trae el reproductor: la
        // línea de tiempo de abajo es la misma que la del modo fernie y ya
        // lleva reproducir, saltar y repetir. Dos juegos de mandos encima del
        // mismo vídeo se pisan.
        controls: NoVideoControls,
      ),
    );
  }
}
