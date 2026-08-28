import 'dart:async';

/// Se ha parado un trabajo a petición del usuario.
///
/// No es un fallo: quien lo recibe no tiene que enseñar ningún error, sólo dejar
/// las cosas como estén y salir.
class JobCancelledException implements Exception {
  const JobCancelledException();

  @override
  String toString() => 'JobCancelledException';
}

/// La señal con la que se para **un** trabajo.
///
/// Es la diferencia con [ImportCancellation], que es una señal global y para lo
/// que haya en marcha sea lo que sea: aquí cada trabajo lleva la suya, así que
/// cancelar un entrenamiento no toca el escaneo de repetidos que corre al lado.
///
/// Se mira entre unidades de trabajo, no en mitad de una: no hay forma de cortar
/// por la mitad una época de entrenamiento ni la lectura de un fichero, ni falta.
class CancellationToken {
  bool _isCancelled = false;
  final Completer<void> _cancelled = Completer<void>();

  /// El usuario ha pedido parar.
  bool get isCancelled => _isCancelled;

  /// Se completa cuando se cancela. Sirve para cortar una espera larga con un
  /// `Future.any` en lugar de tener que consultar [isCancelled] a mano.
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (_isCancelled) return;

    _isCancelled = true;
    _cancelled.complete();
  }

  /// Corta aquí mismo si ya se ha pedido parar. Es la forma corta de mirar la
  /// señal entre unidad y unidad de trabajo.
  void throwIfCancelled() {
    if (_isCancelled) throw const JobCancelledException();
  }
}
