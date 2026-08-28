import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Un deslizador que **se mueve mientras lo mueves**.
///
/// **Por qué hacía falta.** Los deslizadores de la aplicación tomaban su
/// posición del sitio donde vive el valor de verdad: los ajustes, del bloc que
/// los guarda en disco; el de un vídeo, del reproductor. Y avisaban en cada
/// píxel arrastrado. Así que cada píxel era escribir un ajuste, esperar a que el
/// bloc lo devolviera y repintar la pantalla entera de ajustes — o pedirle al
/// reproductor que se colocara en otro fotograma. El tirador no se movía con el
/// ratón: iba dando saltos, siempre por detrás.
///
/// Aquí el tirador es **suyo mientras se arrastra**. Lo de fuera se entera al
/// soltar, que es cuando de verdad se ha elegido un valor. Entre medias, quien
/// quiera ir enterándose puede pedir [onPreview], y si lo que hace es caro
/// —colocar un vídeo— puede pedirlo **acotado** con [previewThrottle] en vez de
/// en cada fotograma.
///
/// Y no vuelve a su sitio de golpe al soltar: se queda con lo elegido hasta que
/// lo de fuera lo alcanza. Sin eso hay un fotograma en el que el tirador salta
/// hacia atrás, justo después de haberlo puesto donde se quería.
class FernSlider extends StatefulWidget {
  /// El valor de verdad, el que vive fuera.
  final double value;

  final double min;
  final double max;
  final int? divisions;

  /// Lo que se hace al soltar. Es el único aviso que llega siempre.
  final ValueChanged<double> onCommitted;

  /// Lo que se hace mientras se arrastra, si es que hay que hacer algo caro.
  final ValueChanged<double>? onPreview;

  /// Se llama en **cada** movimiento, sin acotar.
  ///
  /// Es para lo que no cuesta nada y tiene que enterarse de todos: saber si esto
  /// ha sido un arrastre o sólo un clic, por ejemplo. Contarlo con [onPreview]
  /// no vale: ése llega acotado, así que un arrastre corto parecería un clic.
  final ValueChanged<double>? onDrag;

  /// Cada cuánto se avisa como mucho a [onPreview]. Sin decir nada, en cada
  /// fotograma.
  final Duration previewThrottle;

  /// Lo que se está a punto de hacer, antes del primer arrastre.
  final ValueChanged<double>? onStart;

  /// Cómo se pinta. Recibe el valor que se está viendo —que mientras se arrastra
  /// no es el de fuera— y el deslizador ya montado.
  final Widget Function(BuildContext context, double shown, Widget slider)?
      builder;

  /// Con `null` en [onCommitted] no se deja tocar.
  final bool isEnabled;

  const FernSlider({
    super.key,
    required this.value,
    required this.onCommitted,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onPreview,
    this.onDrag,
    this.previewThrottle = Duration.zero,
    this.onStart,
    this.builder,
    this.isEnabled = true,
  });

  @override
  State<FernSlider> createState() => _FernSliderState();
}

class _FernSliderState extends State<FernSlider> {
  /// Dónde está el tirador mientras se arrastra.
  double? _dragging;

  /// Lo último que se mandó fuera, hasta que lo de fuera lo devuelva.
  double? _committed;

  /// Cuándo se avisó por última vez a quien mira el arrastre.
  DateTime? _lastPreview;

  double get _shown =>
      (_dragging ?? _committed ?? widget.value).clamp(widget.min, widget.max);

  @override
  void didUpdateWidget(FernSlider old) {
    super.didUpdateWidget(old);

    // Lo de fuera se ha movido: ya se puede soltar lo que se guardaba. Puede ser
    // porque haya llegado lo que se mandó, o porque lo haya cambiado otra cosa —
    // en los dos casos manda lo de fuera.
    if (widget.value != old.value) _committed = null;
  }

  void _onChanged(double value) {
    setState(() => _dragging = value);
    widget.onDrag?.call(value);

    final preview = widget.onPreview;
    if (preview == null) return;

    // Acotado, si se ha pedido: colocar un vídeo en cada fotograma del arrastre
    // es pedirle al descodificador más de lo que puede dar, y el resultado es un
    // tirador que va a trompicones.
    final now = DateTime.now();
    final last = _lastPreview;
    if (last != null && now.difference(last) < widget.previewThrottle) return;

    _lastPreview = now;
    preview(value);
  }

  void _onEnd(double value) {
    setState(() {
      _dragging = null;
      _committed = value;
      _lastPreview = null;
    });

    widget.onCommitted(value);
  }

  @override
  Widget build(BuildContext context) {
    final slider = Slider(
      value: _shown,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      onChangeStart: widget.isEnabled ? widget.onStart : null,
      onChanged: widget.isEnabled ? _onChanged : null,
      onChangeEnd: widget.isEnabled ? _onEnd : null,
    );

    return widget.builder?.call(context, _shown, slider) ?? slider;
  }
}

/// Una fila de ajuste con deslizador: el rótulo a la izquierda, el deslizador en
/// medio y el valor a la derecha.
///
/// El valor de la derecha sale del tirador y no del ajuste guardado, así que
/// **cambia mientras se arrastra**. Leyéndolo del ajuste se quedaba parado hasta
/// soltar, que es justo cuando ya no hace falta mirarlo.
class FernSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;

  /// Cómo se escribe el valor de la derecha.
  final String Function(double value) valueLabel;

  final ValueChanged<double> onCommitted;
  final bool isEnabled;

  const FernSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.onCommitted,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FernSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      isEnabled: isEnabled,
      onCommitted: onCommitted,
      builder: (context, shown, slider) => Row(
        children: [
          SizedBox(
            width: AppSizes.settingsLabelWidth,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(child: slider),
          SizedBox(
            width: AppSizes.settingsValueWidth,
            child: Text(
              valueLabel(shown),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
          ),
        ],
      ),
    );
  }
}
