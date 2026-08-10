import 'dart:async';

/// Retrasa una acción y cancela la anterior si llega otra antes de tiempo.
///
/// Se usa en los buscadores: así una búsqueda en la base de datos no sale con
/// cada pulsación, sino cuando se deja de escribir.
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer(this.duration);

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}
