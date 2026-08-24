import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda secretos cifrados: las claves y contraseñas de las fuentes remotas.
///
/// Hasta ahora vivían en claro en el fichero de preferencias. No es un fichero
/// que nadie mire por casualidad, pero es texto plano con la contraseña de una
/// cuenta de verdad dentro, y basta con abrirlo.
///
/// Cifra con **DPAPI**, el servicio de protección de datos de Windows: la clave
/// la gestiona el sistema y va atada a la cuenta de usuario, así que otro
/// usuario del mismo equipo no puede descifrarlo y aquí no hay ninguna clave
/// maestra que pedirle a nadie ni que guardar en ningún sitio.
///
/// El doc de la fase proponía DPAPI para guardar una clave y AES-GCM para los
/// valores. Se hace **DPAPI directamente sobre cada valor**: son cadenas cortas
/// y pocas, el coste es el mismo, y ahorra traerse una implementación de AES y
/// —sobre todo— el trozo de código que más fácil es escribir mal, que es el que
/// gestiona la clave.
///
/// Fuera de Windows no cifra nada y lo dice: es preferible a guardar en claro
/// creyendo que está cifrado.
class SecretStorage {
  final SharedPreferences _preferences;

  /// Cómo se marca lo que está cifrado.
  ///
  /// Hace falta para poder convivir con lo de antes: lo que no lleve la marca es
  /// de cuando se guardaba en claro, se lee tal cual y se vuelve a guardar
  /// cifrado. Sin la marca habría que adivinar si una cadena es base64 o una
  /// contraseña que resulta parecerlo.
  static const marker = 'dpapi:';

  const SecretStorage(this._preferences);

  /// Si esta plataforma sabe cifrar.
  bool get isSupported => Platform.isWindows;

  /// Guarda [value] cifrado. Vacío borra la clave: una credencial que se quita
  /// no tiene por qué dejar rastro.
  Future<void> write(String key, String value) async {
    if (value.isEmpty) {
      await _preferences.remove(key);
      return;
    }

    final sealed = _protect(value);

    await _preferences.setString(
      key,
      sealed == null ? value : '$marker$sealed',
    );
  }

  /// Lo guardado, descifrado si hacía falta.
  ///
  /// Devuelve `null` cuando no hay nada **y también cuando no se puede
  /// descifrar**, que es lo que pasa al restaurar una copia de seguridad en otro
  /// equipo o con otra cuenta de Windows: DPAPI ata el secreto a la cuenta. Se
  /// devuelve como si no hubiera nada para que la aplicación lo pida otra vez
  /// en lugar de fallar de una forma que no se entienda.
  String? read(String key) {
    final stored = _preferences.getString(key);
    if (stored == null || stored.isEmpty) return null;

    if (!stored.startsWith(marker)) return stored;

    return _unprotect(stored.substring(marker.length));
  }

  /// Pasa a cifrado lo que quedara en claro, y dice cuántos ha migrado.
  ///
  /// Se llama al arrancar. Sólo toca lo que no lleva la marca: lo ya cifrado se
  /// queda como está, así que arrancar dos veces no vuelve a cifrar nada.
  Future<int> migrate(Iterable<String> keys) async {
    if (!isSupported) return 0;

    var migrated = 0;

    for (final key in keys) {
      final stored = _preferences.getString(key);
      if (stored == null || stored.isEmpty || stored.startsWith(marker)) {
        continue;
      }

      await write(key, stored);
      migrated++;
    }

    return migrated;
  }

  /// El valor cifrado en base64, o `null` si esta plataforma no sabe.
  String? _protect(String value) {
    if (!isSupported) return null;

    try {
      return base64Encode(_callDpapi(utf8.encode(value), protect: true));
    } on Object catch (error) {
      // Que el cifrado falle no puede costarle al usuario la credencial que
      // acaba de escribir: se guarda como se pueda y se sigue.
      debugPrint('SecretStorage: no se pudo cifrar: $error');

      return null;
    }
  }

  String? _unprotect(String sealed) {
    try {
      return utf8.decode(_callDpapi(base64Decode(sealed), protect: false));
    } on Object catch (error) {
      debugPrint('SecretStorage: no se pudo descifrar: $error');

      return null;
    }
  }

  /// La llamada a DPAPI, en los dos sentidos.
  ///
  /// Las dos funciones tienen la misma forma —un bloque de bytes entra, otro
  /// sale— y la misma ceremonia de reservar, copiar y liberar. Escribirla dos
  /// veces sería duplicar justo el código donde una liberación olvidada no da
  /// ningún error, sólo va comiendo memoria.
  Uint8List _callDpapi(List<int> bytes, {required bool protect}) {
    final input = calloc<_DataBlob>();
    final output = calloc<_DataBlob>();
    final buffer = calloc<Uint8>(bytes.length);

    try {
      buffer.asTypedList(bytes.length).setAll(0, bytes);

      input.ref.cbData = bytes.length;
      input.ref.pbData = buffer;

      final ok = protect
          ? _protectData(input, nullptr, nullptr, nullptr, nullptr, 0, output)
          : _unprotectData(input, nullptr, nullptr, nullptr, nullptr, 0, output);

      if (ok == 0) throw StateError('DPAPI ha devuelto un error');

      // Copiado antes de liberar: lo que devuelve DPAPI vive en memoria suya, y
      // la lista de `asTypedList` es una ventana a ella, no una copia.
      final result = Uint8List.fromList(
        output.ref.pbData.asTypedList(output.ref.cbData),
      );

      _localFree(output.ref.pbData);

      return result;
    } finally {
      calloc.free(buffer);
      calloc.free(input);
      calloc.free(output);
    }
  }
}

/// El `DATA_BLOB` de la API de Windows: cuántos bytes y dónde están.
final class _DataBlob extends Struct {
  @Uint32()
  external int cbData;

  external Pointer<Uint8> pbData;
}

typedef _CryptDataNative = Int32 Function(
  Pointer<_DataBlob> dataIn,
  Pointer<Utf16> description,
  Pointer<_DataBlob> entropy,
  Pointer<Void> reserved,
  Pointer<Void> prompt,
  Uint32 flags,
  Pointer<_DataBlob> dataOut,
);

typedef _CryptData = int Function(
  Pointer<_DataBlob> dataIn,
  Pointer<Utf16> description,
  Pointer<_DataBlob> entropy,
  Pointer<Void> reserved,
  Pointer<Void> prompt,
  int flags,
  Pointer<_DataBlob> dataOut,
);

/// Las bibliotecas se abren una sola vez y sólo en Windows: en cualquier otro
/// sistema, `DynamicLibrary.open` lanzaría al cargar este fichero.
final DynamicLibrary _crypt32 = DynamicLibrary.open('crypt32.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

final _protectData =
    _crypt32.lookupFunction<_CryptDataNative, _CryptData>('CryptProtectData');

final _unprotectData =
    _crypt32.lookupFunction<_CryptDataNative, _CryptData>('CryptUnprotectData');

final _localFree = _kernel32.lookupFunction<
    Pointer<Void> Function(Pointer<Uint8>),
    Pointer<Void> Function(Pointer<Uint8>)>('LocalFree');
