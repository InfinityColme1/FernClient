// Importar marcando lo que entra como no apto.
//
// Vaciar una fuente entera de contenido adulto son varias tandas, y marcar
// después cincuenta cosas a mano es el trabajo que esto ahorra.
//
// Lo que hay que sostener, por orden de lo que más duele si falla:
//
// - **Se recuerda entre sesiones.** Volver a encenderlo cada vez es justo el
//   olvido que deja media importación sin marcar.
// - **Apagado de fábrica.** Marcar es la excepción; lo que se repite sin pensar
//   tiene que ser lo que no esconde nada.
// - **Sólo se ofrece con el bloqueo abierto.** Con el filtro puesto, lo que
//   entrara marcado desaparecería de la rejilla al momento: se importarían
//   cincuenta cosas y no se vería ninguna.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PreferencesService> _preferences() async =>
    PreferencesService(await SharedPreferences.getInstance());

/// Lo que decide la pantalla: el interruptor manda **sólo si de verdad se está
/// ofreciendo**. Escondido bajo el filtro no puede marcar por su cuenta.
bool marksArrivals({required bool toggle, required bool canOffer}) =>
    toggle && canOffer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('lo que se recuerda', () {
    test('de fábrica está apagado', () async {
      expect((await _preferences()).getImportsAsNsfw(), isFalse);
    });

    test('encenderlo se recuerda', () async {
      await (await _preferences()).setImportsAsNsfw(true);

      expect((await _preferences()).getImportsAsNsfw(), isTrue);
    });

    test('y apagarlo también', () async {
      final preferences = await _preferences();

      await preferences.setImportsAsNsfw(true);
      await preferences.setImportsAsNsfw(false);

      expect((await _preferences()).getImportsAsNsfw(), isFalse);
    });

    // Es su propia clave: encender esto no puede tocar el tope de importación,
    // que vive al lado en la misma cabecera.
    test('no se pisa con el tope de importación', () async {
      final preferences = await _preferences();

      await preferences.setImportLimit(100);
      await preferences.setImportsAsNsfw(true);

      expect(preferences.getImportLimit(), 100);
      expect(preferences.getImportsAsNsfw(), isTrue);
    });
  });

  group('cuándo marca de verdad', () {
    test('encendido y ofreciéndose, marca', () {
      expect(marksArrivals(toggle: true, canOffer: true), isTrue);
    });

    // El caso que protege: el interruptor se recuerda encendido, luego se cierra
    // el bloqueo y la opción desaparece de la cabecera. Si siguiera mandando,
    // marcaría a escondidas y la importación entera se volvería invisible.
    test('encendido pero escondido, no marca', () {
      expect(marksArrivals(toggle: true, canOffer: false), isFalse);
    });

    test('apagado no marca aunque se ofrezca', () {
      expect(marksArrivals(toggle: false, canOffer: true), isFalse);
    });
  });

  group('el evento que lo lleva', () {
    test('de fábrica no marca nada', () {
      expect(const ScanSourceEvent().asNsfw, isFalse);
    });

    test('y lleva el tope por su cuenta', () {
      const event = ScanSourceEvent(limit: 10, asNsfw: true);

      expect(event.limit, 10);
      expect(event.asNsfw, isTrue);
    });

    test('el tope sigue siendo el de siempre sin decir nada', () {
      expect(const ScanSourceEvent().limit, unlimitedImportLimit);
    });
  });
}
