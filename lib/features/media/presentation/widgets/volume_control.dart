import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:flutter/material.dart';

/// El mando del volumen: un botón que abre un deslizador vertical encima.
///
/// **Vertical y encima** porque la línea de tiempo vive pegada al borde de abajo
/// del visor: un deslizador tumbado no cabría en la fila sin quitarle sitio al
/// recorrido, y un panel por debajo se saldría de la pantalla.
///
/// Aquí sólo está el comportamiento —abrir, colocar y cerrar—; el aspecto del
/// botón lo pone quien lo usa, a través de [builder], para que sea exactamente
/// el mismo que el de los demás botones de la barra.
///
/// El panel se pinta en la capa de encima de todo y no dentro de la barra: la
/// barra tiene un alto fijo y las esquinas redondeadas, así que cualquier cosa
/// que asome por arriba saldría recortada.
class VolumeControl extends StatefulWidget {
  final MediaPlaybackController playback;

  /// El botón que lo abre. Recibe la función que abre y cierra.
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  /// Lo que se hace con el volumen elegido **al soltar**: guardarlo.
  ///
  /// Mientras se arrastra, el volumen ya está puesto —se oye al momento—; esto
  /// es sólo para el que se quede entre arranques, y por eso llega una vez y no
  /// en cada píxel.
  final ValueChanged<double>? onCommitted;

  /// Avisa de cuándo el panel está abierto.
  ///
  /// Hace falta porque los mandos del visor se desvanecen solos cuando el ratón
  /// lleva un rato quieto, y el panel vive fuera de ellos: sin este aviso, el
  /// deslizador se quedaría flotando sobre un botón que ya no está.
  final ValueChanged<bool>? onOpenChanged;

  const VolumeControl({
    super.key,
    required this.playback,
    required this.builder,
    this.onCommitted,
    this.onOpenChanged,
  });

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  bool _isOpen = false;

  @override
  void dispose() {
    // Si se cierra el visor con el panel abierto, quien tenía los mandos fijados
    // por nuestra culpa tiene que enterarse: si no, se quedan puestos para
    // siempre.
    if (_isOpen) widget.onOpenChanged?.call(false);
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    if (_isOpen) return;

    setState(() => _isOpen = true);
    _portal.show();
    widget.onOpenChanged?.call(true);
  }

  void _close() {
    if (!_isOpen) return;

    setState(() => _isOpen = false);
    _portal.hide();
    widget.onOpenChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _overlay,
        child: widget.builder(context, _toggle),
      ),
    );
  }

  Widget _overlay(BuildContext context) {
    return Stack(
      children: [
        // Pulsar fuera lo cierra. Ocupa la pantalla entera y va debajo del panel,
        // así que tocar el deslizador no cuenta como pulsar fuera.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            // Pegado por encima del botón y centrado con él. Sigue al botón,
            // así que si la barra se mueve el panel se mueve con ella en vez de
            // quedarse donde estaba.
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -volumePanelGap),
            child: _panel(context),
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext context) {
    final theme = Theme.of(context);

    // Entra creciendo desde el botón, no apareciendo de golpe: es un panel
    // pequeño que sale justo debajo del cursor, y un parpadeo ahí se nota.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(motionFast),
      curve: motionEnterCurve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.92 + 0.08 * t,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
      child: FernSurface.raised(
        width: volumePanelWidth,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.xs,
        ),
        child: AnimatedBuilder(
          animation: widget.playback,
          builder: (context, _) => FernSlider(
            value: widget.playback.volume,
            // En vivo y sin acotar: subir el volumen tiene que oírse mientras se
            // arrastra, y ponerlo no le cuesta nada al reproductor. Lo caro que
            // hacía falta acotar era colocar el vídeo, no esto.
            onPreview: widget.playback.setVolume,
            onCommitted: (value) {
              widget.playback.setVolume(value);
              widget.onCommitted?.call(value);
            },
            builder: (context, shown, slider) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // El número sale del tirador y no del reproductor, así que se
                  // mueve con el dedo.
                  '${(shown * 100).round()}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: context.colors.gray),
                ),
                const SizedBox(height: AppSpacing.s),
                // Tumbado un cuarto de vuelta a la izquierda: así arrastrar
                // hacia arriba sube, que es lo único que nadie tiene que
                // aprender.
                SizedBox(
                  height: volumeSliderLength,
                  child: RotatedBox(quarterTurns: 3, child: slider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
