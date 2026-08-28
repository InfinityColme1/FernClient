import 'dart:async';
import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Para qué está la línea de tiempo.
///
/// Es la misma barra en los dos casos —la misma altura, el mismo recorrido, el
/// mismo reloj— y lo único que cambia son los botones de los lados, porque lo
/// que se hace con el contenido no es lo mismo: mirarlo se hace a saltos de
/// cinco segundos, marcarlo se hace de uno en uno.
enum MediaTimelineMode { viewing, marking }

/// Dónde empieza el recorrido dentro de la barra y cuánto mide.
typedef _Track = ({double inset, double width});

/// Un instante del contenido que ya tiene trabajo hecho, y quién está marcado
/// en él.
///
/// Marcar sobre algo que se mueve es dejar claves sueltas por el contenido. La
/// muesca dice **dónde** hay una; los fernies dicen **de quién** es, que es lo
/// que hace falta para volver a ella sin ir abriendo fotogramas a ciegas.
@immutable
class FernieMark {
  final Duration at;
  final List<FernieEntity> fernies;

  const FernieMark({required this.at, required this.fernies});

  @override
  bool operator ==(Object other) =>
      other is FernieMark &&
      other.at == at &&
      listEquals(other.fernies, fernies);

  @override
  int get hashCode => Object.hash(at, Object.hashAll(fernies));
}

/// Un tramo del recorrido con trabajo hecho, en fracción de la duración.
///
/// Las muescas seguidas se juntan en uno solo: un vídeo marcado fotograma a
/// fotograma son cientos de rayas de dos píxeles pegadas, y lo que dicen en
/// realidad es «de aquí a aquí hay trabajo».
@immutable
class MarkSpan {
  final double start;
  final double end;

  const MarkSpan(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      other is MarkSpan && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MarkSpan(, )';
}

/// Junta en tramos las muescas que caen en fotogramas seguidos.
///
/// Va aquí fuera y recibe [frameIndexOf] en vez de mirar el mando: qué es
/// «seguido» depende de a cuántos fotogramas por segundo vaya el contenido, y
/// así se puede comprobar sin montar un reproductor.
@visibleForTesting
List<MarkSpan> markSpans(
  List<FernieMark> marks, {
  required Duration total,
  required int Function(Duration) frameIndexOf,
}) {
  final span = total.inMilliseconds;
  if (span <= 0 || marks.isEmpty) return const [];

  final ordered = [...marks]..sort((a, b) => a.at.compareTo(b.at));
  final spans = <MarkSpan>[];

  var from = ordered.first.at.inMilliseconds;
  var to = from;
  var lastFrame = frameIndexOf(ordered.first.at);

  for (final mark in ordered.skip(1)) {
    final frame = frameIndexOf(mark.at);

    // Seguidos es literalmente el fotograma de al lado: si entre dos hay hueco,
    // son dos trabajos distintos y se cuentan como tales.
    if (frame - lastFrame <= 1) {
      to = mark.at.inMilliseconds;
    } else {
      spans.add(MarkSpan(from / span, to / span));
      from = mark.at.inMilliseconds;
      to = from;
    }

    lastFrame = frame;
  }

  spans.add(MarkSpan(from / span, to / span));
  return spans;
}

/// La barra de reproducción del visor, en la parte de abajo.
///
/// En el modo de mirar es la de siempre: reproducir, saltar cinco segundos y
/// repetir. En el modo fernie cambia de oficio y sirve para **marcar sobre
/// contenido que se mueve**: se elige el fotograma y se marca sobre él, quieto.
/// De ahí que los botones de los lados pasen a ir de uno en uno.
///
/// Y allí el botón de reproducir tampoco está para ver el contenido sino para
/// **comprobar el trabajo**: al reproducir, las regiones marcadas se recorren
/// solas y se ve si el recorrido acompaña a lo que hay debajo.
class MediaTimeline extends StatefulWidget {
  final MediaPlaybackController playback;
  final MediaTimelineMode mode;

  /// Los instantes que ya tienen alguna región marcada. Sólo en el modo de
  /// marcar: mirando el contenido no pintan nada.
  final List<FernieMark> marks;

  /// Si está puesto el papel cebolla, y cómo se quita y se pone.
  ///
  /// Es lo que deja ver, apagado, lo marcado en el fotograma anterior: sin eso,
  /// marcar el mismo objeto fotograma a fotograma es hacerlo a ojo.
  final bool isOnionSkinOn;
  final VoidCallback? onToggleOnionSkin;

  /// Si al copiar del papel cebolla se deja también copia en cada fotograma de
  /// en medio, y cómo se quita y se pone.
  ///
  /// Es lo mismo que poner dos claves con el mismo valor: lo que hay entre ellas
  /// se queda igual. Sirve para lo que no se mueve durante un rato.
  final bool isDraggingRegions;
  final VoidCallback? onToggleDragRegions;

  /// Si coger el recorrido para el contenido.
  ///
  /// Sólo mirando, y lo elige el usuario en los ajustes. Marcando se para
  /// siempre y esto no se mira: se está buscando un fotograma concreto para
  /// marcar sobre él, y buscarlo con la reproducción en marcha es perseguirlo.
  final bool pauseOnSeek;

  const MediaTimeline({
    super.key,
    required this.playback,
    this.mode = MediaTimelineMode.viewing,
    this.marks = const [],
    this.isOnionSkinOn = false,
    this.onToggleOnionSkin,
    this.isDraggingRegions = false,
    this.onToggleDragRegions,
    this.pauseOnSeek = false,
  });

  @override
  State<MediaTimeline> createState() => _MediaTimelineState();
}

class _MediaTimelineState extends State<MediaTimeline> {
  /// La nube se cuelga del recorrido, no de la ventana: así sigue a la línea de
  /// tiempo si el visor cambia de tamaño mientras está abierta.
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  /// La muesca que hay bajo el cursor, si hay alguna.
  int? _hovered;

  /// Si el cursor está dentro de la nube. Es lo que la mantiene abierta mientras
  /// se leen los nombres, o se desplazan los que no caben.
  bool _isOnBubble = false;

  Timer? _closeTimer;

  /// El respiro entre salir de la muesca y cerrar.
  ///
  /// Del recorrido a la nube el cursor pasa por fuera de las dos. Sin este
  /// respiro la nube se cerraría justo cuando se va a entrar en ella.
  static const _closeDelay = Duration(milliseconds: 150);

  /// Cuántas veces ha cambiado el valor en el gesto que se está haciendo.
  ///
  /// Es lo que distingue pulsar de arrastrar. No sirve comparar el principio con
  /// el final: la barra avisa del principio con el valor **de antes** del gesto
  /// («so that if we have a tap, it consists of a call to onChangeStart with the
  /// previous value»), así que al pulsar los dos son distintos aunque el dedo no
  /// se haya movido. Arrastrando, en cambio, el valor cambia muchas veces.
  int _valueChanges = 0;

  bool get _isMarking => widget.mode == MediaTimelineMode.marking;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.playback,
      builder: (context, _) {
        if (!widget.playback.isPlayable) return const SizedBox.shrink();

        return Material(
          color: context.colors.scrim.withValues(alpha: viewerShadeOpacity),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: SizedBox(
            height: fernieTimelineHeight,
            child: Row(
              children: [
                _leadingButton(context),
                _playButton(context),
                Expanded(child: _slider(context)),
                _timeLabel(context),
                ..._modeButtons(context),
                _trailingButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Los botones, que son lo único que cambia entre los dos modos
  // ---------------------------------------------------------------------------

  Widget _leadingButton(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return _isMarking
        ? _button(
            context,
            tooltip: texts.fernieFramePrevious,
            icon: Symbols.skip_previous,
            onPressed: () => widget.playback.stepFrames(-1),
          )
        : _button(
            context,
            tooltip: texts.viewerSkipBack,
            icon: Symbols.replay_5,
            onPressed: () => widget.playback.seekBy(-viewerSkipStep),
          );
  }

  Widget _trailingButton(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return _isMarking
        ? _button(
            context,
            tooltip: texts.fernieFrameNext,
            icon: Symbols.skip_next,
            onPressed: () => widget.playback.stepFrames(1),
          )
        : _button(
            context,
            tooltip: texts.viewerSkipForward,
            icon: Symbols.forward_5,
            onPressed: () => widget.playback.seekBy(viewerSkipStep),
          );
  }

  Widget _playButton(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return _button(
      context,
      tooltip: widget.playback.isPlaying
          ? texts.fernieTimelinePause
          : texts.fernieTimelinePlay,
      icon: widget.playback.isPlaying ? Symbols.pause : Symbols.play_arrow,
      onPressed: widget.playback.togglePlay,
    );
  }

  /// Lo que va entre el reloj y el botón del final: la repetición mirando, y el
  /// papel cebolla con su arrastre marcando.
  List<Widget> _modeButtons(BuildContext context) {
    final texts = AppLocalizations.of(context);

    if (!_isMarking) {
      return [
        _button(
          context,
          tooltip: texts.viewerLoop,
          icon: Symbols.repeat,
          isOn: widget.playback.isLooping,
          onPressed: widget.playback.toggleLooping,
        ),
      ];
    }

    return [
      _button(
        context,
        tooltip: texts.fernieOnionSkin,
        icon: Symbols.layers,
        isOn: widget.isOnionSkinOn,
        onPressed: widget.onToggleOnionSkin,
      ),
      _button(
        context,
        tooltip: texts.fernieDragRegions,
        icon: Symbols.linear_scale,
        isOn: widget.isDraggingRegions,
        // Sin papel cebolla no hay nada que arrastrar: es el gesto de copiar de
        // un fotograma al siguiente el que esto modifica.
        onPressed: widget.isOnionSkinOn ? widget.onToggleDragRegions : null,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // El recorrido
  // ---------------------------------------------------------------------------

  /// El recorrido del contenido.
  ///
  /// Arrastrarlo para el contenido: se está buscando un momento concreto, y
  /// buscarlo con la reproducción en marcha es perseguirlo.
  Widget _slider(BuildContext context) {
    final total = widget.playback.duration.inMilliseconds.toDouble();
    final current = widget.playback.position.inMilliseconds
        .clamp(0, total.round())
        .toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = SliderTheme.of(context).copyWith(
          activeTrackColor: context.colors.terciary,
          inactiveTrackColor: Colors.white24,
          thumbColor: context.colors.terciary,
          overlayColor: context.colors.terciary.withValues(alpha: 0.2),
          trackHeight: trackHeight,
          thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: trackThumbRadius),
          overlayShape:
              const RoundSliderOverlayShape(overlayRadius: trackOverlayRadius),
          // Lo ya marcado se pinta **dentro** del recorrido y no encima: una
          // banda por encima tapaba la bola que dice por dónde va la
          // reproducción, y lo marcado no es un adorno sobre la barra, es parte
          // de lo que la barra cuenta.
          trackShape: _MarkedTrackShape(
            spans: markSpans(
              widget.marks,
              total: widget.playback.duration,
              frameIndexOf: widget.playback.frameIndexOf,
            ),
          ),
        );

        final inset = trackInset(theme);
        final track = (inset: inset, width: constraints.maxWidth - inset * 2);

        return SliderTheme(
          data: theme,
          child: CompositedTransformTarget(
            link: _link,
            child: MouseRegion(
              onHover: (event) => _onHover(event.localPosition.dx, track),
              onExit: (_) => _scheduleClose(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // El tirador va con el raton y el video se coloca **de
                  // cuando en cuando**, no en cada pixel arrastrado: pedirle al
                  // descodificador un fotograma por cada movimiento del raton es
                  // pedirle mas de lo que puede dar, y lo que se veia era un
                  // tirador a trompicones que ademas iba por detras.
                  //
                  // Al soltar se coloca en el sitio exacto, que es el unico
                  // fotograma que de verdad importa.
                  FernSlider(
                    value: current,
                    max: total <= 0 ? 1 : total,
                    previewThrottle: scrubSeekInterval,
                    onStart: (_) {
                      if (_isMarking || widget.pauseOnSeek) {
                        widget.playback.pause();
                      }
                      _valueChanges = 0;
                    },
                    // Contar los movimientos va aparte de colocar el vídeo: lo
                    // que distingue un arrastre de un clic son **todos** los
                    // movimientos, y colocar el vídeo va acotado. Contándolo con
                    // lo acotado, un arrastre corto pasaría por clic y la barra
                    // tiraría hacia la muesca más cercana al soltar.
                    onDrag: (_) => _valueChanges++,
                    onPreview: (value) => widget.playback
                        .seekTo(Duration(milliseconds: value.round())),
                    onCommitted: (value) => _snapToMark(value, track),
                  ),
                  OverlayPortal(
                    controller: _portal,
                    overlayChildBuilder: (context) =>
                        _buildBubble(context, track),
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Al pulsar una muesca se cae **en su fotograma**, no cerca.
  ///
  /// Pulsar una muesca es decir «llévame a esa región», y en un vídeo largo cada
  /// píxel del recorrido son decenas de fotogramas: sin esto se llega al que
  /// caiga bajo el píxel pulsado, que no es el de la región y no la enseña.
  ///
  /// Sólo al pulsar. Arrastrando se está buscando a mano, y una barra que tira
  /// hacia las muescas al soltar se sentiría trabada.
  void _snapToMark(double value, _Track track) {
    final changes = _valueChanges;
    _valueChanges = 0;

    final total = widget.playback.duration.inMilliseconds;
    if (total <= 0 || changes > 1) return;

    // Se busca con la misma cuenta que el cursor: así la muesca a la que se va
    // es exactamente la que se estaba señalando.
    final index = _markIndexAt(
      track.inset + track.width * (value / total),
      track,
    );
    if (index == null) return;

    final at = widget.marks[index].at;
    widget.playback.seekToFrame(widget.playback.frameIndexOf(at));
  }

  // ---------------------------------------------------------------------------
  // La nube de una muesca
  // ---------------------------------------------------------------------------

  /// La muesca que hay bajo [dx], si el cursor está lo bastante cerca de alguna.
  ///
  /// Se mira sólo la horizontal a propósito: subir hacia la nube saca el cursor
  /// de la altura de la muesca mucho antes de llegar a ella, y con la vertical
  /// contando, el viaje se cortaría a medio camino.
  int? _markIndexAt(double dx, _Track track) {
    final position = dx - track.inset;
    var best = -1;
    var bestDistance = AppSpacing.s;

    for (var index = 0; index < widget.marks.length; index++) {
      final offset = markOffset(
        widget.marks[index].at,
        widget.playback.duration,
        track.width,
      );
      if (offset == null) continue;

      final distance = (offset - position).abs();
      if (distance > bestDistance) continue;

      best = index;
      bestDistance = distance;
    }

    return best < 0 ? null : best;
  }

  void _onHover(double dx, _Track track) {
    final index = _markIndexAt(dx, track);

    if (index == null) {
      _scheduleClose();
      return;
    }

    _closeTimer?.cancel();
    _closeTimer = null;

    if (_hovered != index) setState(() => _hovered = index);
    if (!_portal.isShowing) _portal.show();
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay, () {
      // Si para entonces el cursor está dentro de la nube, no se cierra: se
      // está leyendo, o desplazando los nombres que no caben.
      if (!mounted || _isOnBubble) return;

      _portal.hide();
      setState(() => _hovered = null);
    });
  }

  void _setOnBubble(bool value) {
    _isOnBubble = value;

    if (value) {
      _closeTimer?.cancel();
      _closeTimer = null;
      return;
    }

    _scheduleClose();
  }

  Widget _buildBubble(BuildContext context, _Track track) {
    final index = _hovered;
    if (index == null || index >= widget.marks.length) {
      return const SizedBox.shrink();
    }

    final mark = widget.marks[index];
    final offset = markOffset(mark.at, widget.playback.duration, track.width);
    if (offset == null) return const SizedBox.shrink();

    // La nube se centra en la muesca, pero sin salirse del recorrido: cerca de
    // los bordes se queda dentro y lo que se corre es la flecha, que es la que
    // tiene que seguir señalando la muesca.
    final centre = track.inset + offset;
    final available = track.width + track.inset * 2;
    final left = available >= fernieMarkBubbleWidth
        ? (centre - fernieMarkBubbleWidth / 2)
            .clamp(0.0, available - fernieMarkBubbleWidth)
        : 0.0;

    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.bottomLeft,
        offset: Offset(left, 0),
        child: MouseRegion(
          onEnter: (_) => _setOnBubble(true),
          onExit: (_) => _setOnBubble(false),
          child: _MarkBubble(fernies: mark.fernies, arrowAt: centre - left),
        ),
      ),
    );
  }

  /// Por dónde va, en minutos y segundos con centésimas.
  ///
  /// Las centésimas hacen falta: a treinta fotogramas por segundo, dos
  /// fotogramas seguidos no se distinguen si sólo se enseña el segundo.
  Widget _timeLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      child: Text(
        _format(widget.playback.position),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.white, fontFeatures: const [
          // Cifras de ancho fijo: sin esto la etiqueta baila al pasar de un
          // fotograma al siguiente.
          FontFeature.tabularFigures(),
        ]),
      ),
    );
  }

  static String _format(Duration position) {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths =
        (position.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return '$minutes:$seconds.$hundredths';
  }

  Widget _button(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isOn = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        // Lo que está puesto se pinta con el acento, igual que la herramienta
        // elegida en el panel de la izquierda.
        color: onPressed == null
            ? Colors.white.withValues(alpha: pillButtonDisabledOpacity)
            : (isOn ? context.colors.terciary : Colors.white),
        size: AppSizes.iconLarge,
        weight: viewerIconWeight,
        fill: isOn ? 1 : 0,
      ),
    );
  }
}

/// Lo que el recorrido deja libre a cada lado.
///
/// Es la misma cuenta que hace la barra para colocarlo: el mando y su halo
/// necesitan sitio en los bordes, y el recorrido empieza donde acaban. Se calcula
/// y no se supone, porque de esto dependen tres cosas que **tienen que
/// coincidir** —dónde se pintan los tramos marcados, dónde se busca la muesca
/// que hay bajo el cursor y a qué instante lleva pulsarla— y un número a ojo las
/// descuadra entre sí.
@visibleForTesting
double trackInset(SliderThemeData theme) {
  if (theme.padding != null) return 0;

  final thumb = theme.thumbShape?.getPreferredSize(true, false).width ?? 0;
  final overlay = theme.overlayShape?.getPreferredSize(true, false).width ?? 0;

  return math.max(thumb, overlay) / 2;
}

/// Dónde cae la muesca de [at] dentro de [width], contada desde el principio del
/// recorrido.
///
/// La usan el recorrido y el cursor, y por eso está aquí fuera: si cada uno
/// hiciera su cuenta, la nube acabaría abriéndose a un lado de la muesca que se
/// ve.
@visibleForTesting
double? markOffset(Duration at, Duration total, double width) {
  final span = total.inMilliseconds;
  if (span <= 0 || width <= 0) return null;

  return width * (at.inMilliseconds / span).clamp(0.0, 1.0);
}

/// El recorrido, con lo ya marcado pintado dentro.
///
/// Es una forma de la propia barra y no un dibujo encima a propósito: encima
/// tapaba la bola que dice por dónde va la reproducción, y lo marcado no es un
/// adorno sobre la barra sino parte de lo que la barra cuenta. Pintándolo aquí,
/// la bola se dibuja después y pasa por encima, como sobre cualquier otro tramo.
class _MarkedTrackShape extends RoundedRectSliderTrackShape {
  final List<MarkSpan> spans;

  const _MarkedTrackShape({required this.spans});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    if (spans.isEmpty) return;

    final track = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    if (track.width <= 0 || track.height <= 0) return;

    // En blanco: la banda tiene que verse igual sobre la parte ya recorrida,
    // que va con el acento, y sobre la que queda, que va apagada.
    final paint = Paint()..color = Colors.white;
    final radius = Radius.circular(track.height / 2);

    for (final span in spans) {
      final left = track.left + track.width * span.start;
      // Un solo fotograma no tiene ancho ninguno: se le da el mínimo para que
      // se vea, que es lo alto que es la propia barra.
      final width = math.max(track.width * (span.end - span.start), track.height);

      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            math.min(left, track.right - width),
            track.top,
            width,
            track.height,
          ),
          radius,
        ),
        paint,
      );
    }
  }
}

/// La nube de una muesca: quién está marcado en ese instante.
///
/// Enseña [fernieMarkMaxNames] a la vez y el resto se desplazan.
class _MarkBubble extends StatefulWidget {
  final List<FernieEntity> fernies;

  /// Dónde va la flecha, contada desde el borde izquierdo de la nube. No es
  /// siempre el centro: cerca de los bordes del recorrido la nube se queda
  /// dentro y es la flecha la que se corre para seguir señalando la muesca.
  final double arrowAt;

  const _MarkBubble({required this.fernies, required this.arrowAt});

  @override
  State<_MarkBubble> createState() => _MarkBubbleState();
}

class _MarkBubbleState extends State<_MarkBubble> {
  final _scroll = ScrollController();

  /// Alto de una fila: la cara y el aire de arriba y abajo.
  static const _rowHeight = AppSizes.avatarSmall * 2 + AppSpacing.xs * 2;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = widget.fernies.length > fernieMarkMaxNames;

    return SizedBox(
      width: fernieMarkBubbleWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: context.colors.white,
            elevation: contextMenuElevation,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: _rowHeight * fernieMarkMaxNames,
                ),
                child: Scrollbar(
                  controller: _scroll,
                  thumbVisibility: hasMore,
                  child: ListView.builder(
                    controller: _scroll,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.fernies.length,
                    itemExtent: _rowHeight,
                    itemBuilder: (context, index) =>
                        _row(context, widget.fernies[index]),
                  ),
                ),
              ),
            ),
          ),
          // La flecha va pegada por debajo y apuntando a la muesca: es lo que
          // ata la nube a un instante concreto y no al recorrido entero.
          SizedBox(
            width: fernieMarkBubbleWidth,
            height: AppSpacing.s,
            child: CustomPaint(
              painter: _ArrowPainter(
                at: widget.arrowAt,
                color: context.colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, FernieEntity fernie) {
    return Row(
      children: [
        FernAvatar(
          imagePath: fernie.picturePath,
          fallbackIcon: Symbols.face_retouching_natural,
          radius: AppSizes.avatarSmall,
          iconSize: AppSizes.iconSmall,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            fernie.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.black),
          ),
        ),
      ],
    );
  }
}

/// El pico de la nube.
class _ArrowPainter extends CustomPainter {
  final double at;
  final Color color;

  const _ArrowPainter({required this.at, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Se queda dentro de la nube aunque la muesca caiga fuera: un pico colgando
    // en el aire se lee como un fallo de pintado.
    final centre = at.clamp(AppSpacing.m, size.width - AppSpacing.m);

    final path = Path()
      ..moveTo(centre - AppSpacing.s, 0)
      ..lineTo(centre + AppSpacing.s, 0)
      ..lineTo(centre, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.at != at || oldDelegate.color != color;
}
