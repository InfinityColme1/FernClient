import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';

/// El mando a distancia del contenido que se reproduce.
///
/// Existe porque el reproductor lo crea y lo destruye `MediaViewer`, por dentro,
/// y hay cosas que hacen falta desde fuera: saber por dónde va, pararlo para
/// marcar una región sobre un fotograma quieto y avanzar de uno en uno.
///
/// Se comporta como cualquier controlador de Flutter: quien lo crea lo pasa al
/// widget, el widget se engancha mientras vive y quien lo creó lo suelta. Con
/// contenido que no se reproduce (una imagen) se queda quieto y contestando lo
/// que puede, así que quien lo usa no tiene que preguntar antes de nada.
class MediaPlaybackController extends ChangeNotifier {
  Player? _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  /// Si ya se ha soltado el mando. Un `ChangeNotifier` muerto que avisa lanza.
  bool _isDisposed = false;

  /// Los fotogramas del GIF, cuando lo que se conduce es un GIF.
  ///
  /// Un GIF no lo lleva un reproductor sino esta lista: se abre entero, se sabe
  /// cuándo empieza cada fotograma y moverse por él es cambiar de índice. Es lo
  /// que permite que la línea de tiempo funcione igual con las dos cosas.
  GifFrames? _frames;
  Timer? _ticker;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double? _fps;

  /// Por dónde va la reproducción.
  Duration get position => _position;

  /// Cuánto dura el contenido. Cero mientras no se sepa, y en lo que no se
  /// reproduce.
  Duration get duration => _duration;

  bool get isPlaying => _isPlaying;

  /// Si hay algo que reproducir. Con una imagen es `false` y la línea de tiempo
  /// no se enseña.
  bool get isPlayable =>
      (_player != null || _frames != null) && _duration > Duration.zero;

  /// Los fotogramas del GIF que se está conduciendo, si es un GIF.
  GifFrames? get frames => _frames;

  /// En qué fotograma cae [moment].
  ///
  /// Es lo que decide qué es «este fotograma» en todo lo demás. Comparar
  /// milisegundos con un margen deja fuera lo que el reproductor devuelve con
  /// unas micras de diferencia; comparar números de fotograma, no.
  int frameIndexOf(Duration moment) {
    final gif = _frames;
    if (gif != null) return gif.indexAt(moment);

    final step = frameStep;
    if (step <= Duration.zero) return 0;

    // Al fotograma más cercano y no al de debajo: el reproductor devuelve el
    // instante del fotograma con la precisión que le da la pista, y truncar
    // dejaría la mitad de las veces en el anterior.
    return (moment.inMicroseconds / step.inMicroseconds).round();
  }

  /// Qué fotograma toca pintar ahora mismo.
  int get frameIndex => frameIndexOf(_position);

  /// Cuándo empieza el fotograma [index].
  Duration frameStartOf(int index) {
    final gif = _frames;
    if (gif != null) return gif.starts[index.clamp(0, gif.length - 1)];

    return frameStep * (index < 0 ? 0 : index);
  }

  /// Cuándo empieza el fotograma que se está viendo.
  ///
  /// Es el instante con el que se apunta una región recién marcada: así todas
  /// las de un mismo fotograma caen en el mismo sitio, aunque la reproducción se
  /// hubiera quedado parada a media zancada.
  Duration get frameStart => frameStartOf(frameIndex);

  /// Si dos instantes apuntados son del mismo fotograma.
  bool isSameFrame(int aMs, int bMs) =>
      frameIndexOf(Duration(milliseconds: aMs)) ==
      frameIndexOf(Duration(milliseconds: bMs));

  /// Fotogramas por segundo del contenido, si el reproductor los sabe.
  double? get fps => _fps;

  /// Si al llegar al final vuelve a empezar.
  ///
  /// Un GIF se repite siempre, como haría en cualquier sitio; en un vídeo es
  /// algo que se pide, y el visor lo ofrece con un botón.
  bool get isLooping => _frames != null || _isLooping;
  bool _isLooping = false;

  /// Margen para dar por bueno que algo es «de este fotograma».
  ///
  /// Medio fotograma: lo justo para que la región marcada en un instante se
  /// reconozca al volver a él, y lo bastante estrecho para que la del fotograma
  /// de al lado no cuente. Con un margen ancho, marcar fotograma a fotograma
  /// sería imposible: se verían a la vez las de medio segundo alrededor.
  Duration get frameTolerance => frameStep ~/ 2;

  /// Los instantes de todos los fotogramas que hay entre [from] y [to], sin
  /// contar el de partida y contando el de llegada.
  ///
  /// Es lo que necesita arrastrar una región por todos los fotogramas
  /// intermedios. Se corta en [maxFrames] para no llenar la base de datos de
  /// golpe si alguien arrastra entre dos puntos muy lejanos.
  List<Duration> framesBetween(
    Duration from,
    Duration to, {
    int maxFrames = maxDraggedFrames,
  }) {
    if (!isPlayable || to <= from || frameStep <= Duration.zero) {
      return const [];
    }

    final first = frameIndexOf(from) + 1;
    final last = frameIndexOf(to);

    return [
      for (var index = first;
          index <= last && index - first < maxFrames;
          index++)
        frameStartOf(index),
    ];
  }

  /// Lo que hay que saltar para pasar de un fotograma al siguiente.
  ///
  /// Sin fotogramas por segundo se usa un valor de partida: en un GIF de dos
  /// fotogramas o en un contenedor raro, mpv no siempre los sabe, y es mejor un
  /// salto aproximado que un botón que no hace nada.
  Duration get frameStep {
    // En un GIF cada fotograma dura lo suyo, así que el paso es lo que dura el
    // que se está viendo y no una media.
    final frames = _frames;
    if (frames != null && frames.length > 1) {
      final index = frameIndex;
      final next = index + 1 < frames.length ? frames.starts[index + 1] : _duration;

      return next - frames.starts[index];
    }

    final rate = _fps;
    if (rate == null || rate <= 0) return defaultFrameStep;

    return Duration(microseconds: (Duration.microsecondsPerSecond / rate).round());
  }

  // ---------------------------------------------------------------------------
  // Enganche con el reproductor
  // ---------------------------------------------------------------------------

  /// Lo llama `MediaViewer` cuando abre un contenido reproducible.
  void attach(Player player) {
    if (identical(_player, player)) return;

    detach();
    _player = player;

    _subscriptions.addAll([
      player.stream.position.listen((value) {
        if (_position == value) return;
        _position = value;
        _notify();
      }),
      player.stream.duration.listen((value) {
        if (_duration == value) return;
        _duration = value;
        _notify();
      }),
      player.stream.playing.listen((value) {
        if (_isPlaying == value) return;
        _isPlaying = value;
        _notify();
      }),
      // Los fotogramas por segundo llegan con la pista, más tarde que la
      // duración: hasta entonces el paso de fotograma es el aproximado.
      player.stream.track.listen((track) {
        final rate = track.video.fps;
        if (rate == null || _fps == rate) return;

        _fps = rate;
        _notify();
      }),
    ]);
  }

  /// Lo llama `MediaViewer` cuando abre un GIF que va a recorrerse fotograma a
  /// fotograma.
  void attachFrames(GifFrames frames) {
    if (identical(_frames, frames)) return;

    detach();
    _frames = frames;
    _duration = frames.total;

    _notify();
  }

  /// Llama a [action] en cuanto haya algo que reproducir, o ya mismo si lo hay.
  ///
  /// El reproductor tarda en abrir el fichero, así que quien llega antes que él
  /// (el visor, al abrirse sobre una región que hay que señalar) se encuentra el
  /// mando en reposo y no puede ni saltar ni parar. Esto es la espera: se atiende
  /// al primer aviso que diga que ya se puede y se deja de escuchar.
  void whenPlayable(VoidCallback action) {
    if (isPlayable) {
      action();
      return;
    }

    late final VoidCallback waiter;
    waiter = () {
      if (!isPlayable) return;

      removeListener(waiter);
      action();
    };

    addListener(waiter);
  }

  /// Suelta el contenido, pero **sólo si sigue siendo el que se le pasó**.
  ///
  /// Es lo que hay que llamar al deshacer un trozo del árbol. Cuando Flutter
  /// rehace una rama, monta la nueva antes de deshacer la vieja: primero se
  /// engancha el reproductor nuevo y **después** llega el `dispose` del que se
  /// va. Soltando sin mirar, ese `dispose` dejaba el mando vacío con el
  /// contenido ya abierto, y desde fuera se veía como que el vídeo perdía de
  /// golpe la línea de tiempo, el espacio y el clic.
  void detachSource(Object? source) {
    if (source == null) return;
    if (!identical(_player, source) && !identical(_frames, source)) return;

    detach();
  }

  /// Lo llama `MediaViewer` al cerrar el contenido. Deja el mando en reposo, no
  /// inservible: el mismo controlador vale para el contenido siguiente.
  void detach() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _ticker?.cancel();
    _ticker = null;

    _player = null;
    _frames = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    _isLooping = false;
    _fps = null;

    _notify();
  }

  // ---------------------------------------------------------------------------
  // Mandos
  // ---------------------------------------------------------------------------

  Future<void> play() async {
    if (_frames != null) {
      _startTicker();
      return;
    }

    await _player?.play();
  }

  Future<void> pause() async {
    if (_frames != null) {
      _stopTicker();
      return;
    }

    await _player?.pause();
  }

  /// El reloj del GIF.
  ///
  /// Un GIF no tiene quien lo mueva, así que la posición la lleva un reloj de
  /// aquí. Va **de fotograma en fotograma**, no a un ritmo fijo: cada uno dura
  /// lo suyo, y el siguiente aviso se pide para cuando toque el que viene.
  ///
  /// Es lo que mantiene el recorrido cuadrado con lo que se ve. Con un reloj de
  /// ritmo fijo, la posición avanza a un paso y la imagen a otro, y el GIF
  /// termina antes o después de que la barra llegue al final.
  void _startTicker() {
    if (_ticker != null) return;

    _isPlaying = true;
    _notify();

    _scheduleNextFrame();
  }

  void _scheduleNextFrame() {
    final frames = _frames;
    if (frames == null) return;

    _ticker = Timer(frameStep, () {
      _ticker = null;

      final gif = _frames;
      if (gif == null || !_isPlaying) return;

      // Al llegar al final vuelve a empezar, como haría cualquier GIF.
      final next = frameIndex + 1;
      _position = next >= gif.length ? Duration.zero : gif.starts[next];

      _notify();
      _scheduleNextFrame();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;

    if (!_isPlaying) return;
    _isPlaying = false;
    _notify();
  }

  Future<void> togglePlay() async =>
      _isPlaying ? await pause() : await play();

  /// Pone o quita la repetición.
  ///
  /// En un GIF no hace nada: su reloj vuelve al principio siempre, que es lo
  /// que hace un GIF en cualquier sitio.
  Future<void> setLooping(bool value) async {
    if (_frames != null || _isLooping == value) return;

    _isLooping = value;
    _notify();

    await _player?.setPlaylistMode(
      value ? PlaylistMode.single : PlaylistMode.none,
    );
  }

  Future<void> toggleLooping() async => setLooping(!_isLooping);

  /// Adelanta o retrasa [delta], sin salirse del contenido.
  ///
  /// Es el salto de la barra de siempre: cinco segundos para buscar por encima,
  /// nada que ver con el de fotograma, que es para pararse en uno.
  Future<void> seekBy(Duration delta) async => seekTo(_position + delta);

  /// Salta a un momento concreto, sin salirse del contenido.
  Future<void> seekTo(Duration target) async {
    final player = _player;
    if (player == null && _frames == null) return;

    final clamped = target < Duration.zero
        ? Duration.zero
        : (_duration > Duration.zero && target > _duration ? _duration : target);

    // La posición se adelanta a mano: el reproductor tarda en contestar y la
    // línea de tiempo tiene que moverse con el dedo, no detrás de él.
    _position = clamped;
    _notify();

    await player?.seek(clamped);
  }

  /// Avanza o retrocede [frames] fotogramas.
  ///
  /// Para el contenido antes de moverse: saltar de uno en uno sólo tiene sentido
  /// sobre algo quieto, y si siguiera corriendo el fotograma que se quería ver
  /// se habría ido para cuando llega el salto.
  Future<void> stepFrames(int frames) async {
    if (!isPlayable) return;

    await pause();
    await seekToFrame(frameIndex + frames);
  }

  /// Se planta en el fotograma [index].
  ///
  /// Al reproductor se le pide el **centro** del fotograma y no su principio.
  /// mpv enseña el fotograma que cubre el instante que se le pide, y el
  /// principio cae justo en el filo: con el redondeo a milisegundos que lleva el
  /// salto, el instante pedido se quedaba un pelo corto y volvía a caer en el
  /// fotograma de antes. De ahí que hubiera que pulsar el botón varias veces
  /// para avanzar uno solo.
  ///
  /// La posición se apunta en el principio del fotograma, que es donde va a
  /// quedarse en cuanto conteste el reproductor.
  Future<void> seekToFrame(int index) async {
    // En un GIF los fotogramas duran cada uno lo suyo, así que el principio del
    // que toca sale de la lista y no de multiplicar: sumar duraciones acabaría
    // dejando la posición a medio camino y el error se iría acumulando.
    final gif = _frames;
    if (gif != null) {
      await seekTo(gif.starts[index.clamp(0, gif.length - 1)]);
      return;
    }

    final step = frameStep;
    if (step <= Duration.zero) return;

    final count = _duration.inMicroseconds ~/ step.inMicroseconds;
    final target = index.clamp(0, count > 0 ? count - 1 : 0);

    _position = step * target;
    _notify();

    await _player?.seek(step * target + step ~/ 2);
  }

  /// Avisa a quien escuche, **esperando a que el árbol esté libre** si hace
  /// falta.
  ///
  /// Soltar el contenido pasa casi siempre desde el `dispose` de un widget, y
  /// Flutter deshace los widgets con el árbol bloqueado: avisar justo ahí hace
  /// que quien escuche pida reconstruirse en un momento en el que no se puede, y
  /// el marco lo rechaza con un error en mitad del fotograma. El aviso se deja
  /// para el final del fotograma, que es cuando ya se puede.
  ///
  /// Y después de soltar el mando no se avisa de nada: no queda nadie a quien.
  void _notify() {
    if (_isDisposed) return;

    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (!_isDisposed) notifyListeners();
      });
      return;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    // Antes de soltar nada: `detach` avisa, y a estas alturas ya no hay a quién.
    _isDisposed = true;

    detach();
    super.dispose();
  }
}
