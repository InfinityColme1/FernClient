import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Dice si la rejilla que hay debajo va lanzada ahora mismo.
///
/// **Para qué.** Cargar una miniatura cuesta abrir el fichero y descodificarlo.
/// Haciéndolo conforme se baja, un desplazamiento rápido pide cientos que no le
/// va a dar tiempo a enseñar: se descodifican, se pintan medio fotograma y se
/// tiran, y el trabajo se lo quitan a las que sí se van a quedar delante. De ahí
/// que fuera lento **y** desigual: la que acaba a la vista compite con
/// doscientas que ya no importan.
///
/// Con esto, mientras va lanzada no se empieza nada nuevo; cuando para, se carga
/// lo que ha quedado delante, que es lo único que alguien va a mirar.
///
/// Lo pone [FastScrollDetector] y lo leen las celdas.
class FastScrollScope extends InheritedWidget {
  final bool isFast;

  const FastScrollScope({
    super.key,
    required this.isFast,
    required super.child,
  });

  /// Si la rejilla de la que cuelga [context] va lanzada.
  ///
  /// Fuera de una rejilla contesta que no: quien no está en una lista no se
  /// desplaza, y nada de esto le afecta.
  static bool of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FastScrollScope>();

    return scope?.isFast ?? false;
  }

  @override
  bool updateShouldNotify(FastScrollScope old) => old.isFast != isFast;
}

/// Mira lo que se desplaza lo de dentro y lo cuenta por [FastScrollScope].
///
/// La velocidad se mide **por ventanas** y no entre dos avisos seguidos, y es la
/// diferencia entre que esto funcione o estorbe: la rueda del ratón salta de
/// golpe y sin animación, así que entre dos avisos suyos la velocidad sale
/// enorme aunque se esté yendo despacio. Sobre una ventana de
/// [fastScrollWindow], una rueda normal se queda muy por debajo del listón y un
/// lanzamiento lo pasa de largo.
///
/// Y una vez que va lanzada, lo sigue estando **hasta que para del todo**: un
/// lanzamiento frena poco a poco, y los últimos fotogramas son lentos. Empezar a
/// cargar ahí sería empezar donde todavía no se va a quedar.
///
/// Hay un caso que ni siquiera se mide: **arrastrar la barra**. En escritorio no
/// se arrastra el contenido, así que un desplazamiento que viene de un arrastre
/// es la barra, y ahí la respuesta es la misma vaya deprisa o despacio — no se
/// carga nada hasta soltarla, porque hasta entonces no se sabe dónde se va a
/// quedar.
class FastScrollDetector extends StatefulWidget {
  final Widget child;

  const FastScrollDetector({super.key, required this.child});

  @override
  State<FastScrollDetector> createState() => _FastScrollDetectorState();
}

class _FastScrollDetectorState extends State<FastScrollDetector> {
  bool _isFast = false;

  /// Cuándo empezó la ventana que se está midiendo, y cuánto se ha recorrido en
  /// ella.
  Duration? _windowStart;
  double _travelled = 0;

  /// El reloj: el del fotograma que se está pintando.
  ///
  /// Y no uno de pared a propósito. El desplazamiento avanza dentro de los
  /// fotogramas, así que el del fotograma es el que mide lo que de verdad pasa;
  /// además es el único que se puede adelantar en una prueba, y sin eso esto no
  /// se podría comprobar. Fuera de un fotograma no hay ninguno, y entonces la
  /// ventana simplemente no avanza.
  Duration? get _now {
    try {
      return SchedulerBinding.instance.currentFrameTimeStamp;
    } on Object {
      return null;
    }
  }

  /// Por si el desplazamiento no avisa de que ha terminado.
  ///
  /// Sin esto, un aviso de final que no llegara dejaría la rejilla sin cargar
  /// nada para siempre, que es mucho peor que el problema que se está
  /// arreglando.
  Timer? _idle;

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  void _settle() {
    _idle?.cancel();
    _idle = null;

    _windowStart = null;
    _travelled = 0;

    if (_isFast && mounted) setState(() => _isFast = false);
  }

  void _onUpdate(double delta) {
    _idle?.cancel();
    _idle = Timer(fastScrollIdleTimeout, _settle);

    _travelled += delta.abs();

    final now = _now;
    if (now == null) return;

    final start = _windowStart ??= now;

    final elapsed = now - start;
    if (elapsed < fastScrollWindow) return;

    final speed = _travelled / (elapsed.inMicroseconds / 1000000);

    _travelled = 0;
    _windowStart = now;

    if (speed >= fastScrollVelocity && !_isFast) {
      setState(() => _isFast = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        switch (notification) {
          case ScrollStartNotification(:final dragDetails):
            _windowStart = _now;
            _travelled = 0;

            // Un desplazamiento que viene de un arrastre **es la barra**: en
            // escritorio no se arrastra el contenido, se arrastra la barra. Y
            // ahí no hace falta medir nada — mientras se tenga cogida no se
            // carga, y se carga al soltarla, que es donde el usuario se va a
            // quedar. Lo que pasa por la rueda no trae arrastre y no entra por
            // aquí.
            if (dragDetails != null && !_isFast) {
              setState(() => _isFast = true);
            }
          case ScrollUpdateNotification(:final scrollDelta?):
            _onUpdate(scrollDelta);
          case ScrollEndNotification():
            _settle();
          default:
            break;
        }

        // Sin quedarse con el aviso: quien lo esperara más arriba tiene que
        // seguir recibiéndolo.
        return false;
      },
      child: FastScrollScope(isFast: _isFast, child: widget.child),
    );
  }
}
