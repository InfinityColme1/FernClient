import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:flutter/widgets.dart';

/// Lo que una pantalla hace **al terminar de entrar**, no al empezar.
///
/// Abrir una pantalla es leer de la base de datos, y con una biblioteca grande
/// eso es trabajo de sobra para comerse varios fotogramas. Haciéndolo en
/// `initState` ese trabajo cae justo encima de la transición: la animación no
/// llega a verse y la ventana parece haberse quedado colgada un instante. Lo que
/// más se nota no es la espera —que es la misma— sino que el cambio de pantalla
/// no se ve.
///
/// Esperando a que la transición termine, la pantalla entra con lo que ya
/// hubiera (el estado no se vacía) y la lectura empieza después, con la
/// animación ya guardada. La espera total no cambia; lo que cambia es que se ve
/// lo que está pasando.
///
/// Sin transición —el navegador, o una prueba sin `ScreenTransitionScope`— se
/// ejecuta en el acto: no hay nada a lo que dejar sitio.
mixin ScreenEntryTask<T extends StatefulWidget> on State<T> {
  bool _armed = false;
  bool _ran = false;
  Animation<double>? _entering;
  Timer? _fallback;

  /// Lo que hay que hacer al llegar. Se llama **una sola vez**.
  void onScreenEntered();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Una sola vez: esto se vuelve a llamar cada vez que cambia algo de lo que
    // la pantalla depende, y volver a cargar por eso sería peor que no esperar.
    if (_armed) return;
    _armed = true;

    final entering = ScreenTransitionScope.maybeOf(context)?.entering;

    if (entering == null || entering.status == AnimationStatus.completed) {
      _run();
      return;
    }

    _entering = entering..addStatusListener(_onStatus);

    // Y una red por si la transición no llega a terminar nunca —la interrumpe
    // otra navegación, la animación se queda a medias—: una pantalla que se
    // quedara sin cargar para siempre sería mucho peor que cargar antes de
    // tiempo. El plazo es holgado a propósito: en el camino normal no llega a
    // saltar.
    _fallback = Timer(screenEntryTaskFallback, _run);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    _run();
  }

  void _run() {
    if (_ran) return;
    _ran = true;

    _release();

    if (mounted) onScreenEntered();
  }

  void _release() {
    _entering?.removeStatusListener(_onStatus);
    _entering = null;
    _fallback?.cancel();
    _fallback = null;
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }
}
