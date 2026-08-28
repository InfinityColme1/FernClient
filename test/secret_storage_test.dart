// Las credenciales de las fuentes remotas, cifradas.
//
// Contra el DPAPI de verdad, no contra un doble: lo que hay que comprobar es
// justamente que lo guardado deje de ser legible y que se pueda recuperar
// después, y un cifrado de mentira pasaría las dos cosas sin cifrar nada.

import 'dart:io';

import 'package:Fern/core/services/secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late SecretStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    storage = SecretStorage(preferences);
  });

  test('esta plataforma sabe cifrar', () {
    expect(storage.isSupported, Platform.isWindows);
  });

  test('lo guardado no se puede leer, y vuelve entero', () async {
    await storage.write('reddit_client_secret', 'la contraseña de verdad');

    final stored = preferences.getString('reddit_client_secret');

    expect(stored, isNotNull);
    expect(stored, isNot(contains('la contraseña de verdad')));
    expect(stored, startsWith(SecretStorage.marker));

    expect(storage.read('reddit_client_secret'), 'la contraseña de verdad');
  });

  test('dos secretos iguales no se guardan igual', () async {
    await storage.write('uno', 'repetida');
    await storage.write('otro', 'repetida');

    expect(preferences.getString('uno'), isNot(preferences.getString('otro')));
  });

  test('los acentos y los emoji vuelven como se fueron', () async {
    await storage.write('rara', 'ñandú 🦕 «cerrada»');

    expect(storage.read('rara'), 'ñandú 🦕 «cerrada»');
  });

  // Quitar una credencial no tiene por qué dejar rastro.
  test('vacío borra la clave', () async {
    await storage.write('uno', 'algo');
    await storage.write('uno', '');

    expect(preferences.getString('uno'), isNull);
    expect(storage.read('uno'), isNull);
  });

  test('lo que no hay es nulo', () {
    expect(storage.read('no_existe'), isNull);
  });

  // Es lo que pasa al restaurar una copia de seguridad en otro equipo o con
  // otra cuenta de Windows: DPAPI ata el secreto a la cuenta. Se devuelve como
  // si no hubiera nada para que la aplicación lo vuelva a pedir en vez de
  // fallar de una forma que no se entienda.
  test('lo que no se puede descifrar se lee como si no hubiera nada', () async {
    await preferences.setString('roto', '${SecretStorage.marker}QUJDRA==');

    expect(storage.read('roto'), isNull);
  });

  group('la migración de lo que estaba en claro', () {
    test('lo cifra y lo deja legible por la aplicación', () async {
      await preferences.setString('danbooru_api_key', 'en claro');

      final migrated = await storage.migrate(['danbooru_api_key']);

      expect(migrated, 1);
      expect(
        preferences.getString('danbooru_api_key'),
        isNot(contains('en claro')),
      );
      expect(storage.read('danbooru_api_key'), 'en claro');
    });

    // Arrancar dos veces no puede volver a cifrar lo ya cifrado: sería cifrar
    // el base64 del cifrado anterior, y a la tercera vuelta nadie recupera
    // nada.
    test('lo ya cifrado no se toca', () async {
      await storage.write('uno', 'algo');
      final sealed = preferences.getString('uno');

      expect(await storage.migrate(['uno']), 0);
      expect(preferences.getString('uno'), sealed);
    });

    test('las claves vacías no cuentan', () async {
      await preferences.setString('uno', '');

      expect(await storage.migrate(['uno', 'no_existe']), 0);
    });
  });
}
