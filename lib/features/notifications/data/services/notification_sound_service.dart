import 'dart:async';
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/file_utils.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

/// Reproduce los sonidos de los avisos.
///
/// Se apoya en `media_kit`, que ya está en el proyecto para el vídeo y que trae
/// libmpv: reproducir audio sale gratis y no hace falta un paquete más sólo para
/// esto.
///
/// El fichero que elige el usuario **no se toca**: si dura más de la cuenta, lo
/// que se hace es dejar de reproducirlo al llegar al límite. Así se puede poner
/// cualquier audio y seguir sonando como un aviso.
class NotificationSoundService {
  /// Carpeta donde se copian los sonidos elegidos, para que borrar o mover el
  /// original no deje el aviso mudo.
  final String soundsPath;

  /// Un único reproductor para todos los avisos: crearlo cuesta, y dos avisos a
  /// la vez sonarían mal de todas formas.
  Player? _player;
  Timer? _stopTimer;

  NotificationSoundService({required this.soundsPath});

  /// El sonido de fábrica de cada clase de aviso.
  ///
  /// Un entrenamiento que acaba bien y un montón de repetidos encontrados no
  /// piden el mismo toque.
  static String defaultSoundOf(NotificationKind kind) => switch (kind) {
        NotificationKind.trainingFinished => successNotificationSound,
        NotificationKind.duplicatesFound => alertNotificationSound,
        NotificationKind.recognitionFinished => defaultNotificationSound,
        NotificationKind.importFinished => defaultNotificationSound,
        // Es una pregunta, no un final: el mismo toque que avisa de algo que
        // hay que mirar.
        NotificationKind.linkReview => alertNotificationSound,
      };

  /// Lo que suena para [kind]: lo que haya elegido el usuario o, si no, el de
  /// fábrica.
  ///
  /// Un fichero elegido que ya no está se trata como si no lo hubiera: mejor
  /// que suene el de fábrica a que no suene nada.
  String resolveSound(NotificationKind kind, NotificationSettingsEntity settings) {
    final chosen = settings.channel(kind).soundPath;

    if (chosen != null && chosen.isNotEmpty && File(chosen).existsSync()) {
      return chosen;
    }

    return defaultSoundOf(kind);
  }

  /// Reproduce el aviso de [kind], cortándolo al límite configurado.
  Future<void> play(
    NotificationKind kind, {
    required NotificationSettingsEntity settings,
  }) {
    return preview(
      resolveSound(kind, settings),
      volume: settings.volume,
      maxSeconds: settings.maxSeconds,
    );
  }

  /// Reproduce [path] tal y como sonaría como aviso, ya cortado.
  ///
  /// Es lo que hace el botón de escuchar de los ajustes: sin él, el usuario
  /// elegiría a ciegas.
  Future<void> preview(
    String path, {
    required int volume,
    required int maxSeconds,
  }) async {
    try {
      await stop();

      final player = _player ??= Player();

      await player.setVolume(volume.toDouble());
      await player.open(Media(_toMediaUri(path)));

      // El corte: se deja sonar lo que se haya dicho y se para. El fichero se
      // queda como estaba, que es lo que permite elegir cualquier audio.
      _stopTimer = Timer(Duration(seconds: maxSeconds), () {
        unawaited(_player?.stop());
      });
    } on Object {
      // Un aviso que no suena no puede tumbar lo que estuviera haciendo la
      // aplicación: se pierde el sonido y ya.
      return;
    }
  }

  Future<void> stop() async {
    _stopTimer?.cancel();
    _stopTimer = null;

    try {
      await _player?.stop();
    } on Object {
      return;
    }
  }

  /// Cuánto dura el audio de [path], o `null` si no se puede saber.
  ///
  /// Hace falta para poder decirle al usuario lo que ha elegido y avisarle de
  /// que se va a cortar.
  Future<Duration?> durationOf(String path) async {
    Player? probe;

    try {
      probe = Player();
      await probe.setVolume(0);
      await probe.open(Media(_toMediaUri(path)), play: false);

      return await probe.stream.duration
          .firstWhere((duration) => duration > Duration.zero)
          .timeout(const Duration(seconds: 5));
    } on Object {
      return null;
    } finally {
      unawaited(probe?.dispose());
    }
  }

  /// Copia [sourcePath] a la carpeta de sonidos y devuelve la ruta de la copia.
  ///
  /// Mismo criterio que con los avatares: la aplicación guarda su copia para que
  /// mover o borrar el original no rompa nada. Si algo falla se devuelve la ruta
  /// original, que sonará igual mientras el fichero siga ahí.
  Future<String> store(String sourcePath) async {
    try {
      if (p.equals(p.dirname(sourcePath), soundsPath)) return sourcePath;

      final source = File(sourcePath);
      if (!await source.exists()) return sourcePath;

      final target = uniqueFilePath(
        p.join(soundsPath, p.basename(sourcePath)),
      );
      await placeFile(source, target, copy: true);

      return target;
    } on FileSystemException {
      return sourcePath;
    }
  }

  /// Borra la copia de [path] si es una de las nuestras.
  ///
  /// Se comprueba que esté en la carpeta de sonidos porque no todas lo están:
  /// cuando [store] no puede copiar se guarda la ruta original, que apunta a un
  /// fichero del usuario. Ése no se toca: la aplicación borra sus copias, no los
  /// originales de nadie.
  ///
  /// Se llama al volver al sonido de fábrica y al cambiar de sonido: si no, cada
  /// audio que se probara dejaría su copia en la carpeta para siempre.
  Future<void> remove(String? path) async {
    if (path == null || path.isEmpty) return;
    if (!p.equals(p.dirname(path), soundsPath)) return;

    // Lo que esté sonando ahora mismo tiene el fichero abierto, y en Windows eso
    // impide borrarlo.
    await stop();

    await deleteFileAt(path);
  }

  /// Los sonidos de fábrica viven en los recursos de la aplicación y no en el
  /// disco, y se piden con su propio esquema.
  String _toMediaUri(String path) =>
      path.startsWith('assets/') ? 'asset:///$path' : path;

  Future<void> dispose() async {
    _stopTimer?.cancel();
    await _player?.dispose();
    _player = null;
  }
}
