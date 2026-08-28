import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/sidecar_failure.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:Fern/features/recognition/data/services/uv_bootstrap.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Por dónde va la instalación del entorno de reconocimiento.
enum SidecarSetupStage {
  /// Todavía no se ha instalado nada.
  notInstalled,
  downloadingUv,
  installingPython,
  creatingVenv,
  detectingHardware,
  installingTorch,
  installingUltralytics,
  cleaning,
  verifying,

  /// Listo para entrenar y reconocer.
  ready,

  /// Algo ha fallado. [SidecarSetupState.failure] dice qué y cómo se arregla.
  error;

  bool get isWorking =>
      this != SidecarSetupStage.notInstalled &&
      this != SidecarSetupStage.ready &&
      this != SidecarSetupStage.error;

  /// Por dónde va la instalación entera, de 0 a 1, al empezar y al acabar esta
  /// etapa.
  ///
  /// Es una estimación a ojo, repartida según lo que tarda cada paso: bajarse
  /// torch es la mitad de la espera y limpiar no es nada. Sirve para que la
  /// barra avance de verdad en lugar de quedarse quieta durante minutos, que es
  /// lo que hace pensar que se ha colgado.
  (double, double) get span => switch (this) {
        SidecarSetupStage.notInstalled => (0.0, 0.0),
        SidecarSetupStage.downloadingUv => (0.0, 0.08),
        SidecarSetupStage.installingPython => (0.08, 0.20),
        SidecarSetupStage.creatingVenv => (0.20, 0.25),
        SidecarSetupStage.detectingHardware => (0.25, 0.27),
        SidecarSetupStage.installingTorch => (0.27, 0.75),
        SidecarSetupStage.installingUltralytics => (0.75, 0.92),
        SidecarSetupStage.cleaning => (0.92, 0.96),
        SidecarSetupStage.verifying => (0.96, 1.0),
        SidecarSetupStage.ready => (1.0, 1.0),
        SidecarSetupStage.error => (0.0, 0.0),
      };
}

/// El estado de la instalación tal y como lo enseña la pantalla de ajustes.
class SidecarSetupState {
  final SidecarSetupStage stage;

  /// Qué ha fallado, cuando [stage] es [SidecarSetupStage.error].
  final SidecarFailure? failure;

  /// Bytes descargados y totales de lo que se esté bajando, si se sabe.
  final int received;
  final int? total;

  /// Las últimas líneas de lo que va diciendo `uv`. Es lo que se enseña en el
  /// registro plegable y lo que hace falta para poder contar un fallo.
  final List<String> log;

  const SidecarSetupState({
    this.stage = SidecarSetupStage.notInstalled,
    this.failure,
    this.received = 0,
    this.total,
    this.log = const [],
  });

  /// Cuánto lleva descargado de lo que se esté bajando ahora mismo, si se sabe.
  double? get downloadProgress {
    final total = this.total;
    if (total == null || total <= 0) return null;

    return (received / total).clamp(0.0, 1.0);
  }

  /// Por dónde va la instalación entera, de 0 a 1.
  ///
  /// Dentro de una etapa se avanza con lo que lleve descargado, y donde no hay
  /// número (instalar paquetes no lo da) se queda en el principio de su tramo.
  /// Es aproximado a propósito: lo que tiene que hacer es no parecer parado.
  double get overallProgress {
    final (start, end) = stage.span;
    final within = downloadProgress ?? 0;

    return (start + (end - start) * within).clamp(0.0, 1.0);
  }
}

/// Monta el entorno de Python con el que FeRN entrena y reconoce.
///
/// El usuario no tiene que instalar nada ni abrir una consola: se descarga `uv`,
/// y con él un Python propio y un entorno virtual dentro de la carpeta de
/// reconocimiento. Nada de esto toca el sistema.
///
/// Se instala **siempre la rueda de CPU de torch**, que pesa una décima parte
/// que la de CUDA. La aceleración por tarjeta gráfica es una descarga aparte que
/// el usuario pide si quiere, y en los Mac con Apple Silicon ni siquiera hace
/// falta: viene en la rueda normal.
///
/// **Nada de aquí puede correr con el sidecar en marcha.** Un `python.exe` del
/// entorno virtual tiene abiertos sus propios ficheros, y en Windows eso impide
/// borrarlos o reemplazarlos: quien llama tiene que haberlo parado antes (de eso
/// se encarga `RecognitionEngine`).
class SidecarProvisioner {
  final SidecarPaths paths;
  final UvBootstrap bootstrap;

  final StreamController<SidecarSetupState> _controller =
      StreamController<SidecarSetupState>.broadcast();

  SidecarSetupState _state = const SidecarSetupState();
  final List<String> _log = [];

  SidecarProvisioner({required this.paths, required this.bootstrap});

  SidecarSetupState get state => _state;

  Stream<SidecarSetupState> get changes => _controller.stream;

  /// Si el entorno está montado y se puede usar.
  ///
  /// Se mira el Python del entorno virtual y el script: con los dos en su sitio
  /// hay algo que lanzar, y si estuviera roto se verá al primer `ping`.
  bool get isReady =>
      File(paths.venvPython).existsSync() &&
      File(paths.sidecarScript).existsSync();

  void _emit(
    SidecarSetupStage stage, {
    SidecarFailure? failure,
    int received = 0,
    int? total,
  }) {
    _state = SidecarSetupState(
      stage: stage,
      failure: failure,
      received: received,
      total: total,
      log: List.unmodifiable(_log),
    );

    if (!_controller.isClosed) _controller.add(_state);
  }

  void _note(String line) {
    if (line.trim().isEmpty) return;

    _log.add(line.trim());
    if (_log.length > 200) _log.removeAt(0);
  }

  /// Monta el entorno de principio a fin.
  ///
  /// Con [withCuda] se instala directamente la rueda de la tarjeta gráfica, sin
  /// pasar por la de procesador: quien ya sabe que quiere GPU no tiene por qué
  /// descargarse las dos.
  Future<bool> install({bool withCuda = false}) async {
    try {
      await Directory(paths.runtimeDirectory).create(recursive: true);

      _emit(SidecarSetupStage.downloadingUv);
      await bootstrap.install(
        onProgress: (received, total) => _emit(
          SidecarSetupStage.downloadingUv,
          received: received,
          total: total,
        ),
      );
      _note('uv ${await bootstrap.version() ?? ''}');

      _emit(SidecarSetupStage.installingPython);
      await _run(['python', 'install', sidecarPythonVersion]);

      _emit(SidecarSetupStage.creatingVenv);
      await _createVenv();

      _emit(SidecarSetupStage.detectingHardware);
      // Si se pidió GPU pero no hay tarjeta, se sigue con la de procesador en
      // lugar de fallar: el entorno queda usable, que es lo que importa.
      final useCuda = withCuda && await detectCuda();

      _emit(SidecarSetupStage.installingTorch);
      await _installTorch(withCuda: useCuda);

      _emit(SidecarSetupStage.installingUltralytics);
      await _run([
        'pip',
        'install',
        '--python',
        paths.venvPython,
        sidecarUltralyticsPackage,
      ]);
      await _slimOpenCv();

      _emit(SidecarSetupStage.cleaning);
      await _run(['cache', 'clean']);

      _emit(SidecarSetupStage.verifying);
      await writeScript();

      if (!isReady) {
        _emit(
          SidecarSetupStage.error,
          failure: const SidecarFailure(
            SidecarFailureKind.missingPiece,
            'The environment was installed but the venv python is missing',
          ),
        );

        return false;
      }

      _emit(SidecarSetupStage.ready);

      return true;
    } on Object catch (error) {
      _emit(SidecarSetupStage.error, failure: SidecarFailure.from(error));

      return false;
    }
  }

  /// Cambia sólo el motor de cálculo, sin rehacer el entorno.
  ///
  /// Pasar de procesador a tarjeta gráfica es reinstalar torch con otro índice
  /// de ruedas y nada más. Antes esto rehacía la instalación entera, y como el
  /// primer paso de eso es recrear el entorno virtual, fallaba siempre que el
  /// entorno estuviera en uso: se pedía borrar la carpeta desde la que se está
  /// ejecutando Python.
  Future<bool> switchAcceleration({required bool withCuda}) async {
    if (!isReady) return install();

    try {
      _emit(SidecarSetupStage.detectingHardware);

      if (withCuda && !await detectCuda()) {
        _emit(
          SidecarSetupStage.error,
          failure: const SidecarFailure(
            SidecarFailureKind.missingPiece,
            'No NVIDIA GPU was found on this computer',
          ),
        );

        return false;
      }

      _emit(SidecarSetupStage.installingTorch);
      await _installTorch(withCuda: withCuda);

      _emit(SidecarSetupStage.cleaning);
      await _run(['cache', 'clean']);

      _emit(SidecarSetupStage.ready);

      return true;
    } on Object catch (error) {
      _emit(SidecarSetupStage.error, failure: SidecarFailure.from(error));

      return false;
    }
  }

  /// Crea el entorno virtual sin destruir el que hubiera.
  ///
  /// `--allow-existing` es lo que evita que `uv` intente borrar la carpeta antes
  /// de crearla: reinstalar sobre un entorno que ya está no tiene por qué
  /// empezar por borrarlo, y borrarlo es justo lo que Windows no deja si algo lo
  /// tiene abierto.
  Future<void> _createVenv() async {
    await _run([
      'venv',
      paths.venvDirectory,
      '--python',
      sidecarPythonVersion,
      '--allow-existing',
    ]);
  }

  Future<void> _installTorch({required bool withCuda}) async {
    await _run([
      'pip',
      'install',
      '--python',
      paths.venvPython,
      '--index-url',
      withCuda ? torchCudaIndexUrl : torchCpuIndexUrl,
      // Sin esto, `uv` da por buena la versión que ya hay instalada y no cambia
      // de rueda: el usuario pulsaría el botón y no pasaría nada.
      '--reinstall-package',
      'torch',
      '--reinstall-package',
      'torchvision',
      'torch',
      'torchvision',
    ]);
  }

  /// Si el equipo tiene una tarjeta NVIDIA que se pueda usar.
  ///
  /// Se pregunta a `nvidia-smi`, que es lo que hay instalado con el controlador:
  /// si no está, no hay CUDA que valga.
  Future<bool> detectCuda() async {
    try {
      final result = await Process.run('nvidia-smi', ['-L']);
      final output = result.stdout.toString();

      if (result.exitCode == 0 && output.contains('GPU')) {
        _note(output.trim());

        return true;
      }
    } on ProcessException {
      return false;
    }

    return false;
  }

  /// Deja en disco el script del sidecar.
  ///
  /// Se reescribe cuando el que trae la aplicación no es el que hay guardado:
  /// así una actualización de FeRN actualiza también el script sin tener que
  /// reinstalar el entorno entero.
  ///
  /// Lo que se compara es la **huella del contenido** y no un número puesto a
  /// mano. Con el número había que acordarse de subirlo en cada cambio del
  /// script, y no acordarse no daba ningún error: la aplicación arrancaba tan
  /// contenta y el sidecar seguía siendo el viejo, así que un método nuevo
  /// respondía «Unknown method» en todas las instalaciones que ya existían.
  /// Pasó de verdad con `inspect`, que es el que mira unos pesos traídos de
  /// fuera. Con la huella no hay nada que recordar.
  Future<void> writeScript({bool force = false}) async {
    final script = await rootBundle.loadString(sidecarScriptAsset);
    final version = sha1.convert(utf8.encode(script)).toString();

    final versionFile = File(paths.sidecarVersionFile);
    final current =
        versionFile.existsSync() ? await versionFile.readAsString() : null;

    if (!force &&
        current?.trim() == version &&
        File(paths.sidecarScript).existsSync()) {
      return;
    }

    await File(paths.sidecarScript).writeAsString(script);
    await versionFile.writeAsString(version);
  }

  /// Cambia opencv por su variante sin interfaz gráfica, que ocupa la tercera
  /// parte y no arrastra las librerías de ventanas.
  ///
  /// Se hace desinstalando y reinstalando, y no con el mecanismo de
  /// sustituciones de `uv`: ése cambia la **versión** de un paquete, no lo
  /// reemplaza por otro con otro nombre, así que no servía para esto (y por eso
  /// se colaban 113 MB de opencv completo). Las dos variantes traen el mismo
  /// módulo `cv2`, así que ultralytics no nota la diferencia.
  ///
  /// Si algo de esto falla no se aborta la instalación: lo único que pasa es
  /// que ocupa más.
  Future<void> _slimOpenCv() async {
    try {
      await _run(['pip', 'uninstall', '--python', paths.venvPython, 'opencv-python']);
      await _run([
        'pip',
        'install',
        '--python',
        paths.venvPython,
        'opencv-python-headless',
      ]);
    } on Object catch (error) {
      _note('opencv-headless: $error');
    }
  }

  /// Lanza `uv` con [arguments] y va anotando lo que dice.
  ///
  /// Los argumentos se pasan como lista, nunca concatenados: la carpeta de
  /// datos del usuario lleva espacios más veces que no.
  Future<void> _run(List<String> arguments) async {
    final result = await Process.run(
      paths.uvExecutable,
      arguments,
      environment: {
        // Todo lo que instale se queda dentro de nuestra carpeta.
        'UV_PYTHON_INSTALL_DIR': paths.pythonInstallDirectory,
        'UV_CACHE_DIR': paths.cacheDirectory,
      },
    );

    _note(result.stdout.toString());
    _note(result.stderr.toString());

    if (result.exitCode != 0) {
      throw UvBootstrapException(
        'uv ${arguments.first} failed (${result.exitCode}): ${result.stderr}',
      );
    }
  }

  /// Borra el entorno para volver a empezar.
  ///
  /// Se reintenta unas cuantas veces porque Windows suelta los ficheros de un
  /// proceso que acaba de morir con algo de retraso: el primer intento puede
  /// fallar aunque ya no quede nadie usándolos.
  Future<bool> reset() async {
    try {
      await _deleteWithRetries(Directory(paths.runtimeDirectory));

      _log.clear();
      _emit(SidecarSetupStage.notInstalled);

      return true;
    } on Object catch (error) {
      _emit(SidecarSetupStage.error, failure: SidecarFailure.from(error));

      return false;
    }
  }

  Future<void> _deleteWithRetries(Directory directory) async {
    if (!await directory.exists()) return;

    Object? lastError;

    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        await directory.delete(recursive: true);

        return;
      } on FileSystemException catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }

    throw lastError ?? const SidecarFailure(SidecarFailureKind.unknown, '');
  }

  Future<void> dispose() => _controller.close();
}
