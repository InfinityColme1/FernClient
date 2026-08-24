import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Cuántas vueltas da el derivador de claves.
///
/// Alto a propósito. Lo que protege una contraseña corta no es el algoritmo,
/// es lo que cuesta probar la siguiente: con doscientas mil vueltas, cada
/// intento cuesta una fracción de segundo aquí y meses de máquina a quien se
/// lleve el fichero y quiera probar un diccionario entero.
///
/// El precio lo paga el usuario **una vez**, al desbloquear el modo, y no hay
/// sesión que renovar: se paga cuando se pide, no cada vez que se pinta algo.
const passwordIterations = 200000;

/// Bytes de sal. Dieciséis es lo habitual y de sobra: su trabajo es que dos
/// contraseñas iguales no den el mismo hash, no ser secreta.
const passwordSaltBytes = 16;

/// Cuántos caracteres tiene cada grupo del código de recuperación.
const recoveryGroupLength = 4;

/// Cuántos grupos lleva. Cuatro de cuatro son dieciséis caracteres de un
/// alfabeto de treinta y dos: suficientes para que no se adivine y pocos para
/// poder copiarlo a mano de un papel.
const recoveryGroups = 4;

/// El alfabeto del código de recuperación.
///
/// Sin `I`, `O`, `0` ni `1`: el código se apunta en un papel y se vuelve a
/// teclear meses después, y ahí un cero y una o son el mismo carácter. Quitarlos
/// cuesta un bit de entropía y ahorra el peor momento posible —el de haber
/// perdido la contraseña y no saber si lo que hay escrito es una letra o un
/// número—.
const recoveryAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Lo que se guarda de un secreto: nunca el secreto.
class SecretDigest {
  /// El hash, en base64.
  final String hash;

  /// La sal con la que se hizo, en base64.
  final String salt;

  /// Cuántas vueltas se dieron.
  ///
  /// Se guarda con el hash, y no como constante del código, para poder subirla
  /// más adelante sin dejar fuera a quien tenga la contraseña puesta: lo suyo
  /// se sigue comprobando con las vueltas de entonces.
  final int iterations;

  const SecretDigest({
    required this.hash,
    required this.salt,
    this.iterations = passwordIterations,
  });
}

/// Deriva y comprueba los secretos del modo NSFW.
///
/// No guarda nada: eso es de quien lo llame. Aquí sólo se convierte una
/// contraseña en algo que se puede guardar sin peligro, y se comprueba si otra
/// contraseña da lo mismo.
class PasswordService {
  final Random _random;

  /// Cuántas vueltas se dan al derivar. En la aplicación, [passwordIterations].
  ///
  /// Se puede bajar, y hay un sitio donde tiene sentido: las pruebas. Doscientas
  /// mil vueltas por cada una de veinte pruebas son medio minuto de espera por
  /// cada `flutter test`, y lo que esas pruebas comprueban no es el coste sino
  /// que lo derivado cuadre. Bajarlo en producción sería otra cosa muy distinta,
  /// y por eso el valor de fábrica es el alto.
  final int iterations;

  /// [random] llega por parámetro para poder fijar el azar en las pruebas. En
  /// la aplicación es [Random.secure], que es el único que vale para esto: el
  /// `Random()` normal se puede predecir sabiendo la hora a la que se generó el
  /// código.
  PasswordService({Random? random, this.iterations = passwordIterations})
      : _random = random ?? Random.secure();

  /// Convierte un secreto en lo que se guarda de él.
  SecretDigest digestOf(String secret) {
    final salt = _randomBytes(passwordSaltBytes);

    return SecretDigest(
      hash: base64Encode(_derive(secret, salt, iterations)),
      salt: base64Encode(salt),
      iterations: iterations,
    );
  }

  /// Si [secret] es el que dio [digest].
  ///
  /// Un guardado ilegible —sal que no es base64, cero vueltas— no desbloquea
  /// nada: devolver `true` cuando no se entiende lo guardado sería abrir el
  /// modo a cualquiera que estropee un fichero de preferencias.
  bool matches(String secret, SecretDigest digest) {
    try {
      if (digest.iterations <= 0) return false;

      final salt = base64Decode(digest.salt);
      final expected = base64Decode(digest.hash);
      final actual = _derive(secret, salt, digest.iterations);

      return _sameBytes(actual, expected);
    } on Object {
      return false;
    }
  }

  /// Un código de recuperación nuevo, con el formato `FERN-4K2P-9XQM-7A3D`.
  String newRecoveryCode() {
    final groups = [
      for (var group = 0; group < recoveryGroups; group++)
        [
          for (var i = 0; i < recoveryGroupLength; i++)
            recoveryAlphabet[_random.nextInt(recoveryAlphabet.length)],
        ].join(),
    ];

    return 'FERN-${groups.join('-')}';
  }

  /// El código tal y como se compara: sin guiones, sin espacios y en
  /// mayúsculas.
  ///
  /// Quien lo teclea lo hace desde un papel, meses después y de mal humor: que
  /// falle por una minúscula o por un guion de menos sería ensañarse.
  String normalizeRecoveryCode(String code) =>
      code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  Uint8List _randomBytes(int count) => Uint8List.fromList(
        [for (var i = 0; i < count; i++) _random.nextInt(256)],
      );

  /// PBKDF2-HMAC-SHA256.
  ///
  /// Escrito aquí porque `package:crypto` da el HMAC pero no el derivador, y
  /// PBKDF2 sobre él son quince líneas: encadenar el resultado de una vuelta
  /// con la siguiente y ir sumando con XOR. Traerse una dependencia entera para
  /// esto sería peor negocio.
  Uint8List _derive(String secret, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(secret));

    // Un solo bloque: SHA-256 da treinta y dos bytes y con eso basta para lo
    // que se guarda. Con más bloques habría que repetir todo esto por cada uno.
    var block = Uint8List.fromList(hmac.convert([...salt, 0, 0, 0, 1]).bytes);
    final result = Uint8List.fromList(block);

    for (var round = 1; round < iterations; round++) {
      block = Uint8List.fromList(hmac.convert(block).bytes);

      for (var i = 0; i < result.length; i++) {
        result[i] ^= block[i];
      }
    }

    return result;
  }

  /// Comparación en **tiempo constante**.
  ///
  /// La de siempre —salir en cuanto dos bytes no coinciden— tarda más cuanto
  /// más acertado va el principio, y eso se puede medir. Aquí no es la amenaza
  /// más realista, pero escribir la comparación insegura teniendo la buena al
  /// lado sólo se justifica si nadie va a copiar este fichero nunca.
  bool _sameBytes(List<int> one, List<int> other) {
    if (one.length != other.length) return false;

    var difference = 0;
    for (var i = 0; i < one.length; i++) {
      difference |= one[i] ^ other[i];
    }

    return difference == 0;
  }
}
