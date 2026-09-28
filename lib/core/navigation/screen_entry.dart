import 'package:flutter/widgets.dart';

/// Lo que una pantalla hace al llegar a ella: leer lo suyo.
///
/// **En paralelo con la transición, no después.** Antes se esperaba a que la
/// animación terminara para empezar a leer: la animación corría sobre una
/// rejilla vacía y el contenido llegaba de golpe al acabar, que es lo que se
/// veía como un parpadeo. Ahora la lectura sale en el fotograma siguiente al de
/// montar la pantalla, la animación corre con los huecos de carga puestos, y
/// cada celda sustituye a su hueco en cuanto está lista (`ProgressiveCell`),
/// con la transición todavía en marcha si hace falta.
///
/// En el fotograma siguiente y no en el acto: durante la construcción no se
/// puede tocar el estado de nadie, y así el primer fotograma de la animación
/// sale limpio.
mixin ScreenEntryTask<T extends StatefulWidget> on State<T> {
  bool _armed = false;

  /// Lo que hay que hacer al llegar. Se llama **una sola vez**.
  void onScreenEntered();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Una sola vez: esto se vuelve a llamar cada vez que cambia algo de lo que
    // la pantalla depende, y volver a cargar por eso sería peor que no esperar.
    if (_armed) return;
    _armed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onScreenEntered();
    });
  }
}
