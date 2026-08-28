import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Por dónde entran y salen las líneas del sidecar.
///
/// Se saca a una interfaz para poder probar el cliente sin lanzar ningún
/// proceso: en las pruebas se le enchufa un canal de mentira.
abstract class SidecarChannel {
  /// Las líneas que llegan del sidecar.
  Stream<String> get lines;

  /// Manda una línea. El salto de línea lo pone el canal.
  void send(String line);

  /// Se completa cuando el sidecar deja de estar vivo.
  Future<void> get exited;

  Future<void> kill();
}

/// El proceso hijo de verdad.
///
/// Es el primer sitio de la aplicación que lanza un proceso: hasta ahora todo lo
/// nativo se hacía con `dart:ffi` contra el propio Windows. Los argumentos se
/// pasan como lista y nunca concatenados, que es lo que hace que una ruta con
/// espacios (y la carpeta de datos del usuario los tiene a menudo) no rompa
/// nada.
class SidecarProcess implements SidecarChannel {
  final Process _process;
  final StreamController<String> _lines = StreamController<String>.broadcast();
  final Completer<void> _exited = Completer<void>();

  /// Las últimas líneas de la salida de errores. Es lo único que se tiene para
  /// contar por qué se ha muerto, así que se guarda siempre.
  final List<String> _errors = [];
  static const _maxErrorLines = 50;

  SidecarProcess._(this._process) {
    _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_lines.add, onDone: _lines.close);

    _process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_remember);

    _process.exitCode.then((_) {
      if (!_exited.isCompleted) _exited.complete();
    });
  }

  /// Lanza [executable] con [arguments].
  static Future<SidecarProcess> start(
    String executable,
    List<String> arguments, {
    Map<String, String>? environment,
    String? workingDirectory,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      environment: environment,
      workingDirectory: workingDirectory,
      // Sin heredar el entorno completo se perdería el PATH del sistema, que en
      // Windows hace falta para cargar las DLL de torch.
      includeParentEnvironment: true,
    );

    return SidecarProcess._(process);
  }

  void _remember(String line) {
    _errors.add(line);
    if (_errors.length > _maxErrorLines) _errors.removeAt(0);
  }

  /// Lo último que ha dicho el proceso por la salida de errores.
  String get errorOutput => _errors.join('\n');

  @override
  Stream<String> get lines => _lines.stream;

  @override
  void send(String line) {
    _process.stdin.writeln(line);
  }

  @override
  Future<void> get exited => _exited.future;

  @override
  Future<void> kill() async {
    // El Python de un entorno virtual de Windows arranca a su vez el intérprete
    // de base, así que matar sólo al hijo directo deja vivo al nieto — y con él,
    // los ficheros del entorno abiertos. `taskkill /T` se lleva la rama entera.
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/F', '/T', '/PID', '${_process.pid}']);
    } else {
      _process.kill();
    }

    // Con un tope: si el sistema no lo suelta, es peor quedarse esperando para
    // siempre que seguir adelante y fallar con un mensaje que se entienda.
    await _exited.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );
  }
}
