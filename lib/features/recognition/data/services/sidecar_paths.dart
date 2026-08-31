import 'dart:io';

import 'package:path/path.dart' as p;

/// En qué sistemas sabe instalarse el entorno de reconocimiento.
enum SidecarPlatform {
  windows(id: 'windows'),
  macos(id: 'macos'),
  linux(id: 'linux');

  const SidecarPlatform({required this.id});

  final String id;

  /// El sistema en el que se está ejecutando, o `null` si no es de los tres.
  ///
  /// La aplicación sólo se distribuye para Windows hoy, pero nada de lo del
  /// sidecar depende de eso: el día que haya compilación para macOS o Linux,
  /// esto ya funciona.
  static SidecarPlatform? current() => fromName(Platform.operatingSystem);

  static SidecarPlatform? fromName(String name) => switch (name) {
        'windows' => SidecarPlatform.windows,
        'macos' => SidecarPlatform.macos,
        'linux' => SidecarPlatform.linux,
        _ => null,
      };
}

/// Dónde vive cada pieza del entorno de reconocimiento y cómo se llama en cada
/// sistema.
///
/// **Es el único sitio de todo el sidecar que mira el sistema operativo.** El
/// resto trabaja con las rutas que salen de aquí, así que añadir un sistema es
/// tocar esta clase y nada más.
class SidecarPaths {
  /// La carpeta `runtime/` de la carpeta de reconocimiento.
  final String runtimeDirectory;

  final SidecarPlatform platform;

  /// La arquitectura del equipo (`x86_64`, `arm64`...). Se inyecta para poder
  /// probarla; en la aplicación sale de la versión del sistema.
  final String architecture;

  const SidecarPaths({
    required this.runtimeDirectory,
    required this.platform,
    required this.architecture,
  });

  /// Lo que hay en este equipo. Devuelve `null` en un sistema que no se soporta.
  static SidecarPaths? forCurrentPlatform(String runtimeDirectory) {
    final platform = SidecarPlatform.current();
    if (platform == null) return null;

    return SidecarPaths(
      runtimeDirectory: runtimeDirectory,
      platform: platform,
      architecture: _currentArchitecture(),
    );
  }

  /// Si el equipo es de los de ARM (Apple Silicon, y los Linux de ARM).
  ///
  /// Dart no expone la arquitectura, así que se saca de la cadena de versión del
  /// sistema, que en macOS y Linux la lleva. En Windows no hay build de uv para
  /// ARM, así que allí siempre se pide la de 64 bits de Intel.
  static String _currentArchitecture() {
    final version = Platform.version.toLowerCase();

    if (version.contains('arm64') || version.contains('aarch64')) {
      return 'arm64';
    }

    return 'x86_64';
  }

  bool get isWindows => platform == SidecarPlatform.windows;

  bool get isArm => architecture == 'arm64';

  /// El binario de `uv`, que es lo primero que se descarga y con lo que se monta
  /// todo lo demás.
  String get uvDirectory => p.join(runtimeDirectory, 'bin');

  String get uvExecutable =>
      p.join(uvDirectory, isWindows ? 'uv.exe' : 'uv');

  /// Dónde deja `uv` los Python que instala. Se le dice por variable de entorno
  /// para que no toque nada fuera de nuestra carpeta.
  String get pythonInstallDirectory => p.join(runtimeDirectory, 'python');

  /// El entorno virtual con torch y ultralytics dentro.
  String get venvDirectory => p.join(runtimeDirectory, 'venv');

  /// La caché de descargas de `uv`. Va dentro de nuestra carpeta para no dejar
  /// gigas en la carpeta personal del usuario, y se vacía al terminar.
  String get cacheDirectory => p.join(runtimeDirectory, 'cache');

  /// El Python del entorno virtual. Es lo único cuyo nombre cambia de verdad
  /// entre sistemas: Windows lo pone en `Scripts` y los demás en `bin`.
  String get venvPython => isWindows
      ? p.join(venvDirectory, 'Scripts', 'python.exe')
      : p.join(venvDirectory, 'bin', 'python');

  /// El script que se lanza como proceso hijo.
  String get sidecarScript => p.join(runtimeDirectory, 'fern_sidecar.py');

  /// Donde se deja la señal de que algo hay que pararlo: un fichero vacío por
  /// petición.
  ///
  /// **Un fichero y no un mensaje.** Mientras entrena o reconoce, el sidecar
  /// está dentro de ultralytics durante horas y no lee lo que se le manda; y
  /// leerlo desde otro hilo no vale, porque un hilo bloqueado en la entrada
  /// cuelga la carga de numpy y de torch en Windows. Un fichero se mira sin
  /// leer nada, entre imagen e imagen y entre época y época.
  String get cancelDirectory => p.join(runtimeDirectory, 'cancel');

  /// La versión del script que hay escrita en disco, para saber si la de la
  /// aplicación es más nueva y hay que reescribirlo.
  String get sidecarVersionFile => p.join(runtimeDirectory, 'sidecar.version');

  /// Cómo se llama en la release de `uv` el artefacto de este equipo.
  ///
  /// Son los nombres que publica el proyecto: si cambian, se cambia aquí.
  String get uvAssetName => switch (platform) {
        SidecarPlatform.windows => 'uv-x86_64-pc-windows-msvc.zip',
        SidecarPlatform.macos => isArm
            ? 'uv-aarch64-apple-darwin.tar.gz'
            : 'uv-x86_64-apple-darwin.tar.gz',
        SidecarPlatform.linux => isArm
            ? 'uv-aarch64-unknown-linux-gnu.tar.gz'
            : 'uv-x86_64-unknown-linux-gnu.tar.gz',
      };

  /// El artefacto de Windows viene en zip y el de los demás en tar comprimido.
  bool get uvAssetIsZip => uvAssetName.endsWith('.zip');
}
