import 'dart:async';
import 'dart:convert';

import 'package:Fern/core/services/jobs/cancellation_token.dart';

import 'package:Fern/features/recognition/data/services/sidecar_process.dart';

/// Un fallo que el sidecar sabe nombrar.
///
/// El código importa tanto como el mensaje: es lo que deja a la interfaz decir
/// algo útil (bajar el tamaño del lote, instalar el entorno) en lugar de soltar
/// un traceback.
class SidecarException implements Exception {
  final String code;
  final String message;

  const SidecarException(this.code, this.message);

  /// El entorno no está instalado todavía.
  bool get isNotReady => code == 'SIDECAR_NOT_READY';

  /// No cabe en memoria: hay que bajar el lote o el tamaño de imagen.
  bool get isOutOfMemory => code == 'OUT_OF_MEMORY';

  bool get isCancelled => code == 'CANCELLED';

  @override
  String toString() => 'SidecarException($code): $message';
}

/// Una petición en marcha: quién espera la respuesta y quién escucha el avance.
class _PendingRequest {
  final Completer<Map<String, dynamic>> completer = Completer();
  final StreamController<Map<String, dynamic>> progress =
      StreamController<Map<String, dynamic>>.broadcast();

  void close() {
    if (!progress.isClosed) progress.close();
  }
}

/// Habla con el sidecar: una línea de JSON por mensaje.
///
/// Se eligió stdin/stdout y no HTTP para no abrir puertos: en Windows el
/// cortafuegos pregunta la primera vez que un programa abre uno, y eso es
/// fricción y soporte que no hace falta.
class SidecarClient {
  final SidecarChannel _channel;
  final Map<String, _PendingRequest> _pending = {};

  /// Cuánto se espera una respuesta antes de darla por perdida. Entrenar no
  /// entra aquí: eso va emitiendo progreso y se espera aparte.
  final Duration timeout;

  var _sequence = 0;
  var _isClosed = false;

  SidecarClient(
    this._channel, {
    this.timeout = const Duration(seconds: 60),
  }) {
    _channel.lines.listen(_onLine, onDone: _onChannelClosed);
    _channel.exited.then((_) => _onChannelClosed());
  }

  /// Manda [method] y espera la respuesta.
  ///
  /// [onProgress] recibe los avances que el sidecar vaya emitiendo por el
  /// camino: las épocas de un entrenamiento, los elementos de un lote.
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, dynamic> params = const {},
    void Function(Map<String, dynamic> data)? onProgress,
    Duration? timeout,
    CancellationToken? token,
  }) {
    if (_isClosed) {
      return Future.error(
        const SidecarException('SIDECAR_NOT_READY', 'The sidecar is not running'),
      );
    }

    final id = 'r${_sequence++}';
    final pending = _PendingRequest();
    _pending[id] = pending;

    if (onProgress != null) pending.progress.stream.listen(onProgress);

    _channel.send(jsonEncode({
      'id': id,
      'method': method,
      'params': params,
    }));

    // La señal de quien llama se traduce a una petición de parada en cuanto se
    // levanta. Hace falta aquí y no fuera porque el identificador de la petición
    // sólo se conoce aquí dentro, y sin él no hay a qué mandar el «para».
    if (token != null) {
      unawaited(token.whenCancelled.then((_) => cancel(id)));
    }

    final effective = timeout ?? this.timeout;

    // Sin límite quien espera se queda colgado si el sidecar se atasca; con
    // límite, al menos se puede reintentar.
    if (effective == Duration.zero) return pending.completer.future;

    return pending.completer.future.timeout(
      effective,
      onTimeout: () {
        _finish(id);

        throw SidecarException(
          'INTERNAL',
          'The sidecar did not answer to $method in ${effective.inSeconds}s',
        );
      },
    );
  }

  /// Pide parar lo que esté haciendo la petición [requestId].
  ///
  /// Va por su propia petición porque el sidecar está ocupado con la otra: lo
  /// que hace es levantar una bandera que el trabajo mira entre paso y paso.
  Future<void> cancel(String requestId) async {
    // Si ya contestó no hay nada que parar, y pedirlo dejaría la marca puesta en
    // el sidecar para siempre: la limpia al terminar la petición, no después.
    if (!_pending.containsKey(requestId)) return;

    try {
      await call('cancel', params: {'target': requestId});
    } on SidecarException {
      return;
    }
  }

  void _onLine(String line) {
    if (line.isEmpty) return;

    Map<String, dynamic> message;
    try {
      message = jsonDecode(line) as Map<String, dynamic>;
    } on FormatException {
      // Una línea que no es JSON es algo que ha escrito una librería por su
      // cuenta: no es para nosotros.
      return;
    }

    final id = message['id'] as String?;
    if (id == null) return;

    final pending = _pending[id];
    if (pending == null) return;

    if (message['event'] == 'progress') {
      final data = message['data'];
      if (data is Map<String, dynamic> && !pending.progress.isClosed) {
        pending.progress.add(data);
      }
      return;
    }

    if (message['ok'] == true) {
      final result = message['result'];
      pending.completer.complete(
        result is Map<String, dynamic> ? result : const {},
      );
    } else {
      final error = message['error'];
      pending.completer.completeError(SidecarException(
        error is Map ? (error['code'] as String? ?? 'INTERNAL') : 'INTERNAL',
        error is Map ? (error['message'] as String? ?? '') : line,
      ));
    }

    _finish(id);
  }

  void _finish(String id) {
    _pending.remove(id)?.close();
  }

  /// El sidecar se ha ido. Lo que estuviera esperando no va a llegar nunca, así
  /// que se corta aquí en vez de dejarlo colgado hasta el tiempo límite.
  void _onChannelClosed() {
    if (_isClosed) return;
    _isClosed = true;

    for (final entry in _pending.entries.toList()) {
      if (!entry.value.completer.isCompleted) {
        entry.value.completer.completeError(const SidecarException(
          'SIDECAR_NOT_READY',
          'The sidecar stopped while the request was in flight',
        ));
      }
      entry.value.close();
    }

    _pending.clear();
  }

  bool get isRunning => !_isClosed;

  /// Cierra por las buenas: se le pide que se vaya y, si no contesta, se le
  /// mata. Al salir de la aplicación no puede quedarse un Python huérfano.
  Future<void> shutdown() async {
    if (_isClosed) return;

    try {
      await call('shutdown', timeout: const Duration(seconds: 5));
    } on Object {
      // Da igual por qué no ha contestado: lo siguiente es matarlo.
    }

    await _channel.kill();
    _onChannelClosed();
  }
}
