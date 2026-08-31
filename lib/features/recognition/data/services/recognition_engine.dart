import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/features/recognition/data/services/sidecar_client.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:Fern/features/recognition/data/services/sidecar_process.dart';
import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:Fern/features/recognition/data/services/uv_bootstrap.dart';
import 'package:Fern/features/settings/data/services/recognition_storage_service.dart';

/// El motor de reconocimiento visto desde la aplicación.
///
/// Esconde que por debajo hay un proceso de Python: quien lo usa pide entrenar o
/// predecir y no se entera de que el sidecar se arranca solo la primera vez, se
/// cierra si nadie lo usa y se vuelve a levantar cuando hace falta.
/// Cómo se lanza el sidecar.
///
/// Va por parámetro, igual que el provisionador, para poder probar lo que rodea
/// al proceso —el contador de inactividad, sobre todo— sin lanzar un Python de
/// verdad: en las pruebas se le enchufa un canal de mentira.
typedef SidecarLauncher = Future<SidecarChannel> Function(
  SidecarPaths paths,
  Map<String, String> environment,
);

class RecognitionEngine {
  final RecognitionStorageService _storage;
  final SidecarProvisioner Function(SidecarPaths paths) _provisionerFactory;
  final SidecarLauncher _launch;

  /// Cuánto se deja al sidecar sin nada que hacer antes de cerrarlo.
  final Duration _idleTimeout;

  SidecarPaths? _paths;
  SidecarProvisioner? _provisioner;
  SidecarClient? _client;
  Timer? _idleTimer;

  /// Cuántas peticiones hay sin contestar ahora mismo.
  ///
  /// El contador de inactividad **no puede correr mientras haya alguna**. Un
  /// entrenamiento es una sola petición que dura horas: contando desde que se
  /// mandó, el sidecar se cerraba a los diez minutos y el entrenamiento moría
  /// con un «se paró mientras se le hablaba», que es lo que pasaba de verdad.
  int _inFlight = 0;

  RecognitionEngine({
    required RecognitionStorageService storage,
    SidecarProvisioner Function(SidecarPaths paths)? provisionerFactory,
    SidecarLauncher? launch,
    Duration? idleTimeout,
  })  : _storage = storage,
        _provisionerFactory = provisionerFactory ?? _defaultProvisioner,
        _launch = launch ?? _startProcess,
        _idleTimeout = idleTimeout ?? sidecarIdleTimeout;

  static SidecarProvisioner _defaultProvisioner(SidecarPaths paths) =>
      SidecarProvisioner(
        paths: paths,
        bootstrap: UvBootstrap(paths: paths),
      );

  /// Los argumentos van como lista y nunca concatenados: es lo que hace que una
  /// ruta con espacios —y la carpeta de datos del usuario los tiene a menudo— no
  /// rompa nada.
  static Future<SidecarChannel> _startProcess(
    SidecarPaths paths,
    Map<String, String> environment,
  ) {
    return SidecarProcess.start(
      paths.venvPython,
      [paths.sidecarScript],
      environment: environment,
    );
  }

  /// Dónde vive el entorno ahora mismo.
  ///
  /// Se resuelve cada vez porque el usuario puede haber cambiado la carpeta de
  /// reconocimiento sin reiniciar; si cambia, lo que hubiera montado deja de
  /// valer y se vuelve a empezar.
  SidecarPaths? get paths {
    final runtime = _storage.runtimeDirectory;

    if (_paths?.runtimeDirectory != runtime) {
      _paths = SidecarPaths.forCurrentPlatform(runtime);
      _provisioner = null;
      unawaited(_stopSidecar());
    }

    return _paths;
  }

  /// El sistema no es de los tres que se soportan.
  bool get isPlatformSupported => paths != null;

  /// Quien instala el entorno, o `null` en un sistema no soportado.
  SidecarProvisioner? get provisioner {
    final paths = this.paths;
    if (paths == null) return null;

    return _provisioner ??= _provisionerFactory(paths);
  }

  bool get isReady => provisioner?.isReady ?? false;

  /// Monta el entorno desde cero.
  ///
  /// Antes se para el sidecar: un `python.exe` del entorno virtual tiene
  /// abiertos sus propios ficheros, y en Windows eso impide reemplazarlos. Es lo
  /// que hacía fallar la instalación con "Acceso denegado" en cuanto se había
  /// abierto la pantalla de ajustes una vez, porque abrirla arranca el sidecar
  /// para leer las versiones.
  Future<bool> install({bool? withCuda}) async {
    await stop();

    return await provisioner?.install(withCuda: withCuda) ?? false;
  }

  /// Cambia entre calcular por procesador o por tarjeta gráfica.
  ///
  /// No rehace el entorno: sólo reinstala torch con el otro índice de ruedas.
  Future<bool> switchAcceleration({required bool withCuda}) async {
    await stop();

    return await provisioner?.switchAcceleration(withCuda: withCuda) ?? false;
  }

  /// Borra el entorno para empezar de nuevo.
  Future<bool> reset() async {
    await stop();

    return await provisioner?.reset() ?? false;
  }

  /// Para el sidecar si estaba en marcha.
  ///
  /// Se espera de verdad a que el proceso muera: quien llama a esto suele ser
  /// porque va a tocar los ficheros del entorno.
  Future<void> stop() => _stopSidecar();

  /// Arranca el sidecar si no estaba en marcha y devuelve con quién hablar.
  Future<SidecarClient> _connect() async {
    final client = _client;
    if (client != null && client.isRunning) return client;

    final paths = this.paths;
    if (paths == null) {
      throw const SidecarException(
        'SIDECAR_NOT_READY',
        'Recognition is not available on this system',
      );
    }

    if (!isReady) {
      throw const SidecarException(
        'SIDECAR_NOT_READY',
        'The recognition environment is not installed yet',
      );
    }

    // El script se refresca al arrancar: una actualización de FeRN puede traer
    // uno nuevo sin que haya que reinstalar el entorno.
    await provisioner?.writeScript();

    final channel = await _launch(paths, {
      // Que ultralytics no escriba su configuración en la carpeta personal del
      // usuario: todo lo suyo se queda dentro de la de reconocimiento.
      'YOLO_CONFIG_DIR': _storage.runsDirectory,
      // Sin esto Python puede quedarse con la salida en el buffer y las
      // respuestas llegarían a trompicones o no llegarían.
      'PYTHONUNBUFFERED': '1',
    });

    final fresh = SidecarClient(channel);
    _client = fresh;

    return fresh;
  }

  /// Reinicia el contador de inactividad. El sidecar se cierra solo si nadie lo
  /// usa: mantener libmpv y torch cargados sin motivo se come la memoria.
  ///
  /// Con algo en marcha no se arma: inactividad es que no haya nada que hacer,
  /// no que lo que hay tarde.
  void _touch() {
    _idleTimer?.cancel();
    _idleTimer = null;

    if (_inFlight > 0) return;

    _idleTimer = Timer(_idleTimeout, () => unawaited(_stopSidecar()));
  }

  Future<T> _withClient<T>(Future<T> Function(SidecarClient client) action) async {
    final client = await _connect();

    _inFlight++;
    _touch();

    try {
      // Con `await` y no devolviendo la promesa a secas: hace falta enterarse
      // de cuándo termina para volver a contar la inactividad desde ahí.
      return await action(client);
    } finally {
      _inFlight--;
      _touch();
    }
  }

  /// Qué versiones hay instaladas y con qué se va a calcular.
  Future<Map<String, dynamic>> environmentInfo() =>
      _withClient((client) => client.call('env_info'));

  /// Comprueba que el sidecar responde.
  Future<bool> ping() async {
    try {
      final result = await _withClient(
        (client) => client.call('ping', timeout: const Duration(seconds: 20)),
      );

      return result['pong'] == true;
    } on Object {
      return false;
    }
  }

  /// Entrena un modelo. No tiene tiempo límite: puede durar horas.
  ///
  /// Con [token] se puede parar a media faena, igual que en [predict]. **Sin
  /// pasarlo, cancelar no llegaba al sidecar**: el botón dejaba el trabajo
  /// marcado como cancelado en la cola y el Python seguía entrenando hasta el
  /// final, comiéndose la tarjeta durante horas.
  Future<Map<String, dynamic>> train(
    Map<String, dynamic> params, {
    void Function(Map<String, dynamic> data)? onProgress,
    CancellationToken? token,
  }) {
    return _withClient((client) => client.call(
          'train',
          params: params,
          onProgress: onProgress,
          timeout: Duration.zero,
          token: token,
        ));
  }

  /// Qué clases sabe reconocer un fichero de pesos.
  ///
  /// Hace falta para los pesos traídos de fuera: sin saber qué trae dentro, no
  /// hay forma de decirle al usuario si ese `.pt` es el que creía. Tiene tiempo
  /// límite porque cargar unos pesos es cosa de segundos, no de horas: si no
  /// contesta, el fichero no vale.
  Future<List<String>> inspect(String weightsPath) async {
    final result = await _withClient((client) => client.call(
          'inspect',
          params: {'weights': weightsPath},
          timeout: const Duration(minutes: 2),
        ));

    final classes = result['classes'];
    if (classes is! List) return const [];

    return [for (final name in classes) '$name'];
  }

  /// Reconoce una lista de imágenes con un modelo.
  ///
  /// Con [token] se puede parar a media tanda: el sidecar mira la señal entre
  /// imagen e imagen, así que una petición de sesenta no obliga a esperar a las
  /// sesenta para que «parar» haga algo.
  Future<Map<String, dynamic>> predict(
    Map<String, dynamic> params, {
    void Function(Map<String, dynamic> data)? onProgress,
    CancellationToken? token,
  }) {
    return _withClient((client) => client.call(
          'predict',
          params: params,
          onProgress: onProgress,
          timeout: Duration.zero,
          token: token,
        ));
  }

  Future<void> _stopSidecar() async {
    _idleTimer?.cancel();
    _idleTimer = null;

    // Lo que estuviera esperando se va a caer con el cierre: que la cuenta no
    // se quede alta, o el sidecar no se cerraría nunca más por su cuenta.
    _inFlight = 0;

    final client = _client;
    _client = null;

    await client?.shutdown();
  }

  /// Cierra lo que haya en marcha. Se llama al salir de la aplicación: no puede
  /// quedarse un Python huérfano.
  Future<void> dispose() async {
    await _stopSidecar();
    await _provisioner?.dispose();
  }
}
