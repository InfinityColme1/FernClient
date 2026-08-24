import 'dart:async';

import 'package:Fern/features/nsfw/data/services/password_service.dart';

/// Dónde se guarda lo del modo NSFW.
///
/// Es una interfaz y no `SharedPreferences` directamente para poder probar todo
/// esto sin ficheros, que es lo que hay que poder hacer con la pieza que decide
/// si se enseña o no el contenido bloqueado.
abstract class NsfwStorage {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}

/// Las claves de lo que se guarda. Están juntas para que borrar el bloqueo
/// pueda barrerlas todas sin olvidarse ninguna.
class NsfwKeys {
  const NsfwKeys._();

  static const passwordHash = 'nsfw_password_hash';
  static const passwordSalt = 'nsfw_password_salt';
  static const passwordIterations = 'nsfw_password_iterations';
  static const recoveryHash = 'nsfw_recovery_hash';
  static const recoverySalt = 'nsfw_recovery_salt';
  static const recoveryIterations = 'nsfw_recovery_iterations';
  static const hint = 'nsfw_hint';
  static const remembered = 'nsfw_remembered';

  static const all = [
    passwordHash,
    passwordSalt,
    passwordIterations,
    recoveryHash,
    recoverySalt,
    recoveryIterations,
    hint,
    remembered,
  ];
}

/// En qué acaba un intento de desbloquear.
enum UnlockOutcome {
  /// Dentro.
  unlocked,

  /// La contraseña no es.
  wrong,

  /// No hay contraseña puesta todavía.
  notConfigured,
}

/// El estado del modo NSFW: si hay contraseña, si está abierto y cómo se abre.
///
/// **Lo que esto protege es la vista, no los ficheros.** El contenido bloqueado
/// sigue en su carpeta, con su nombre, y cualquiera que abra el explorador lo
/// ve. Prometer más sería engañoso, y la interfaz tiene que decirlo donde se
/// configura: quien crea que esto cifra algo tomará decisiones que no tomaría
/// sabiendo la verdad.
class NsfwModeService {
  final NsfwStorage _storage;
  final PasswordService _passwords;

  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool _isUnlocked = false;

  NsfwModeService({
    required NsfwStorage storage,
    PasswordService? passwords,
  })  : _storage = storage,
        _passwords = passwords ?? PasswordService();

  /// Cada vez que el modo se abre o se cierra.
  ///
  /// Lo escucha quien tenga contenido pintado: al cambiar hay que releer, o la
  /// rejilla se queda enseñando lo que acaba de bloquearse.
  Stream<bool> get changes => _changes.stream;

  /// Hay contraseña puesta.
  bool get isConfigured => _digestOf(NsfwKeys.passwordHash) != null;

  /// El modo está abierto ahora mismo.
  bool get isUnlocked => _isUnlocked;

  /// La frase clave, si se puso.
  ///
  /// Se guarda **en claro** a propósito: es una pista, no un secreto, y una
  /// pista que no se puede leer no ayuda a nadie. Quien la escriba tiene que
  /// saber que se lee, y por eso el diálogo lo dice.
  String? get hint => _storage.read(NsfwKeys.hint);

  /// Si el modo tiene que seguir abierto en el arranque siguiente.
  bool get isRemembered => _storage.read(NsfwKeys.remembered) == 'true';

  /// Deja el modo como toca al arrancar: cerrado, salvo que el usuario haya
  /// pedido que se recuerde.
  ///
  /// Cerrado de fábrica. Lo contrario convierte un despiste —cerrar la
  /// aplicación con el modo abierto— en que lo siguiente que se ve al abrirla
  /// sea justo lo que se quería esconder.
  void restore() {
    _setUnlocked(isConfigured && isRemembered);
  }

  /// Pone la contraseña por primera vez y devuelve el código de recuperación,
  /// que **sólo se enseña ahora**.
  ///
  /// Deja el modo abierto: quien acaba de ponerla está delante y acaba de
  /// demostrar que es suya. Pedírsela otra vez tres segundos después es
  /// ceremonia sin ninguna seguridad detrás.
  Future<String> configure({required String password, String? hint}) async {
    final code = _passwords.newRecoveryCode();

    await _storeDigest(
      _passwords.digestOf(password),
      hash: NsfwKeys.passwordHash,
      salt: NsfwKeys.passwordSalt,
      iterations: NsfwKeys.passwordIterations,
    );

    await _storeRecovery(code);

    if (hint != null && hint.isNotEmpty) {
      await _storage.write(NsfwKeys.hint, hint);
    } else {
      await _storage.remove(NsfwKeys.hint);
    }

    _setUnlocked(true);

    return code;
  }

  /// Abre el modo si la contraseña es la buena.
  Future<UnlockOutcome> unlock(String password) async {
    final digest = _digestOf(NsfwKeys.passwordHash);
    if (digest == null) return UnlockOutcome.notConfigured;

    if (!_passwords.matches(password, digest)) return UnlockOutcome.wrong;

    _setUnlocked(true);

    return UnlockOutcome.unlocked;
  }

  /// Cierra el modo. **Sin preguntar nada**: cerrar tiene que ser siempre lo
  /// más fácil que se pueda hacer aquí.
  void lock() => _setUnlocked(false);

  /// Si el modo sigue abierto al volver a arrancar.
  ///
  /// Apagarlo cierra el modo ahora mismo, y no en el arranque siguiente: quien
  /// lo apaga está diciendo que no quiere esto abierto, y dejarlo abierto hasta
  /// que cierre la aplicación es hacer lo contrario de lo que ha pedido.
  Future<void> setRemembered({required bool remembered}) async {
    await _storage.write(NsfwKeys.remembered, '$remembered');

    if (!remembered) lock();
  }

  /// Cambia la contraseña, comprobando la de ahora.
  ///
  /// El código de recuperación **no** se toca: sigue valiendo el que hubiera.
  /// Regenerarlo aquí obligaría a apuntar uno nuevo cada vez que se cambia la
  /// contraseña, y el que estuviera guardado en un papel dejaría de servir sin
  /// que nadie lo hubiera pedido.
  Future<bool> changePassword({
    required String current,
    required String next,
  }) async {
    final digest = _digestOf(NsfwKeys.passwordHash);
    if (digest == null || !_passwords.matches(current, digest)) return false;

    await _storeDigest(
      _passwords.digestOf(next),
      hash: NsfwKeys.passwordHash,
      salt: NsfwKeys.passwordSalt,
      iterations: NsfwKeys.passwordIterations,
    );

    return true;
  }

  /// Fija una contraseña nueva con el código de recuperación, y devuelve el
  /// código siguiente.
  ///
  /// El código usado deja de valer en el mismo momento: un código de un solo
  /// uso que sigue abriendo después de usarse es un código de siempre, y el que
  /// se apuntó en un papel hace un año se quedaría abriendo la biblioteca para
  /// siempre.
  ///
  /// Devuelve `null` si el código no es.
  Future<String?> recover({
    required String code,
    required String password,
  }) async {
    final digest = _digestOf(NsfwKeys.recoveryHash);
    if (digest == null) return null;

    final given = _passwords.normalizeRecoveryCode(code);
    if (!_passwords.matches(given, digest)) return null;

    await _storeDigest(
      _passwords.digestOf(password),
      hash: NsfwKeys.passwordHash,
      salt: NsfwKeys.passwordSalt,
      iterations: NsfwKeys.passwordIterations,
    );

    final next = _passwords.newRecoveryCode();
    await _storeRecovery(next);

    _setUnlocked(true);

    return next;
  }

  /// Si este texto es la contraseña **o** el código de recuperación.
  ///
  /// Lo pide quitar el bloqueo: quien ha perdido la contraseña pero conserva el
  /// papel tiene que poder salir sin fijar antes una contraseña nueva que va a
  /// borrar tres segundos después.
  bool isOwner(String secret) {
    final password = _digestOf(NsfwKeys.passwordHash);
    if (password != null && _passwords.matches(secret, password)) return true;

    final recovery = _digestOf(NsfwKeys.recoveryHash);
    if (recovery == null) return false;

    return _passwords.matches(
      _passwords.normalizeRecoveryCode(secret),
      recovery,
    );
  }

  /// Quita la contraseña y todo lo que la acompaña.
  ///
  /// Es la salida de quien ha perdido las dos cosas. **No borra contenido**: lo
  /// que estaba marcado se marcó, no se cifró, y sigue entero. Lo que se pierde
  /// es el marcado de las etiquetas, y eso lo hace quien llame a esto —aquí no
  /// hay base de datos—, porque dejar la contraseña quitada con las etiquetas
  /// marcadas dejaría contenido escondido sin forma de volver a verlo.
  Future<void> disable() async {
    for (final key in NsfwKeys.all) {
      await _storage.remove(key);
    }

    // Se avisa siempre, se moviera el candado o no. Lo que cambia aquí es que
    // **ya no hay filtro**, y con él puesto `_isUnlocked` ya era `false`: el
    // aviso normal se callaba, nadie repintaba, y el contenido tapado seguía
    // tapado en la rejilla hasta que algo la reconstruía por otro motivo.
    _isUnlocked = false;
    _announce();
  }

  void _setUnlocked(bool value) {
    if (_isUnlocked == value) return;

    _isUnlocked = value;
    _announce();
  }

  /// Avisa a quien esté pintando contenido de que lo que se puede enseñar ha
  /// cambiado.
  void _announce() => _changes.add(_isUnlocked);

  Future<void> _storeRecovery(String code) => _storeDigest(
        _passwords.digestOf(_passwords.normalizeRecoveryCode(code)),
        hash: NsfwKeys.recoveryHash,
        salt: NsfwKeys.recoverySalt,
        iterations: NsfwKeys.recoveryIterations,
      );

  Future<void> _storeDigest(
    SecretDigest digest, {
    required String hash,
    required String salt,
    required String iterations,
  }) async {
    await _storage.write(hash, digest.hash);
    await _storage.write(salt, digest.salt);
    await _storage.write(iterations, '${digest.iterations}');
  }

  /// Lo guardado bajo esa clave, o `null` si falta algo.
  ///
  /// Falta algo = no hay contraseña. Un guardado a medias —hash sin sal— no
  /// puede comprobarse, y tratarlo como «configurado» dejaría el modo cerrado
  /// para siempre sin forma de abrirlo ni de recuperarlo.
  SecretDigest? _digestOf(String hashKey) {
    final isRecovery = hashKey == NsfwKeys.recoveryHash;

    final hash = _storage.read(hashKey);
    final salt = _storage
        .read(isRecovery ? NsfwKeys.recoverySalt : NsfwKeys.passwordSalt);
    final rounds = _storage.read(
      isRecovery ? NsfwKeys.recoveryIterations : NsfwKeys.passwordIterations,
    );

    if (hash == null || salt == null) return null;

    return SecretDigest(
      hash: hash,
      salt: salt,
      iterations: int.tryParse(rounds ?? '') ?? passwordIterations,
    );
  }

  Future<void> dispose() => _changes.close();
}
