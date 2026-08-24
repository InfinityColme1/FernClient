// La contraseña del modo NSFW y su código de recuperación.
//
// Lo que se comprueba aquí es lo que se guarda y lo que abre: que la contraseña
// no quede escrita en ninguna parte, que dos contraseñas iguales no den el mismo
// hash, y que el código de un solo uso lo sea de verdad. Un código de
// recuperación que sigue abriendo después de usarse no es una función a medias:
// es la de siempre con otro nombre.

import 'dart:math';

import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Pocas vueltas: lo que se prueba es que cuadre, no lo que cuesta.
  PasswordService passwords({Random? random}) =>
      PasswordService(iterations: 64, random: random);

  group('lo que se guarda de un secreto', () {
    test('no es el secreto', () {
      final digest = passwords().digestOf('mi contraseña');

      expect(digest.hash, isNot(contains('mi contraseña')));
      expect(digest.salt, isNotEmpty);
    });

    test('la misma contraseña abre', () {
      final service = passwords();
      final digest = service.digestOf('mi contraseña');

      expect(service.matches('mi contraseña', digest), isTrue);
    });

    test('otra no', () {
      final service = passwords();
      final digest = service.digestOf('mi contraseña');

      expect(service.matches('mi contrasena', digest), isFalse);
      expect(service.matches('', digest), isFalse);
    });

    // Sin sal, dos personas con la misma contraseña tienen el mismo hash, y una
    // tabla hecha una vez sirve para todas.
    test('dos contraseñas iguales no dan lo mismo', () {
      final service = passwords();

      final one = service.digestOf('repetida');
      final other = service.digestOf('repetida');

      expect(one.hash, isNot(other.hash));
      expect(one.salt, isNot(other.salt));
    });

    test('las vueltas se guardan con el hash', () {
      // Es lo que permite subirlas más adelante sin dejar fuera a quien ya
      // tenga la contraseña puesta.
      final digest = passwords().digestOf('lo que sea');

      expect(digest.iterations, 64);
    });

    test('un guardado ilegible no abre nada', () {
      final service = passwords();

      expect(
        service.matches('lo que sea',
            const SecretDigest(hash: 'no-es-base64!!', salt: '@@@')),
        isFalse,
      );
      expect(
        service.matches(
          'lo que sea',
          SecretDigest(hash: service.digestOf('x').hash, salt: 'AAAA', iterations: 0),
        ),
        isFalse,
      );
    });
  });

  group('el código de recuperación', () {
    test('tiene la forma que se puede copiar de un papel', () {
      final code = passwords().newRecoveryCode();

      expect(code, matches(RegExp(r'^FERN(-[A-Z2-9]{4}){4}$')));
    });

    // Un cero y una o son el mismo carácter en un papel, y este código se
    // teclea justo cuando ya se ha perdido la contraseña.
    test('no lleva caracteres que se confunden', () {
      final random = Random(7);

      for (var i = 0; i < 50; i++) {
        final code = passwords(random: random).newRecoveryCode();

        expect(code.substring(5), isNot(contains('O')));
        expect(code.substring(5), isNot(contains('0')));
        expect(code.substring(5), isNot(contains('I')));
        expect(code.substring(5), isNot(contains('1')));
      }
    });

    test('se compara sin guiones ni mayúsculas', () {
      final service = passwords();

      expect(
        service.normalizeRecoveryCode('fern-4k2p 9xqm-7a3d'),
        'FERN4K2P9XQM7A3D',
      );
    });
  });

  group('el modo', () {
    late _MemoryStorage storage;

    NsfwModeService mode() => NsfwModeService(
          storage: storage,
          passwords: passwords(),
        );

    setUp(() => storage = _MemoryStorage());

    test('de fábrica no hay contraseña ni nada abierto', () {
      final subject = mode();

      expect(subject.isConfigured, isFalse);
      expect(subject.isUnlocked, isFalse);
    });

    test('sin contraseña puesta no se puede desbloquear', () async {
      expect(await mode().unlock('lo que sea'), UnlockOutcome.notConfigured);
    });

    test('ponerla deja el modo abierto y devuelve el código', () async {
      final subject = mode();
      final code = await subject.configure(password: 'buena', hint: 'la de siempre');

      expect(code, startsWith('FERN-'));
      expect(subject.isConfigured, isTrue);
      expect(subject.isUnlocked, isTrue);
      expect(subject.hint, 'la de siempre');
    });

    test('la contraseña buena abre y la mala no', () async {
      final subject = mode();
      await subject.configure(password: 'buena');
      subject.lock();

      expect(await subject.unlock('mala'), UnlockOutcome.wrong);
      expect(subject.isUnlocked, isFalse);

      expect(await subject.unlock('buena'), UnlockOutcome.unlocked);
      expect(subject.isUnlocked, isTrue);
    });

    test('cerrar no pregunta nada', () async {
      final subject = mode();
      await subject.configure(password: 'buena');

      subject.lock();

      expect(subject.isUnlocked, isFalse);
    });

    test('avisa a quien esté pintando contenido', () async {
      final subject = mode();
      final seen = <bool>[];
      subject.changes.listen(seen.add);

      await subject.configure(password: 'buena');
      subject.lock();
      await Future<void>.delayed(Duration.zero);

      expect(seen, [true, false]);
      await subject.dispose();
    });

    // Cada aviso recarga la rejilla entera. Repetir el que no cambia nada la
    // haría recargarse dos veces por cada vez que alguien pulsa dos veces.
    test('poner el filtro dos veces avisa una sola', () async {
      final subject = mode();
      await subject.configure(password: 'buena');

      final seen = <bool>[];
      subject.changes.listen(seen.add);

      subject.lock();
      subject.lock();
      await Future<void>.delayed(Duration.zero);

      expect(seen, [false]);
      await subject.dispose();
    });

    // Lo que se vio en pantalla: con el filtro puesto se desactivaba desde los
    // ajustes y el contenido tapado seguía tapado hasta pasarle el ratón por
    // encima. Quien repinta la rejilla escucha este aviso, y no llegaba: el
    // candado ya estaba cerrado, así que «no había cambiado nada» aunque lo que
    // hubiera cambiado fuera que ya no hay filtro.
    test('desactivarlo avisa aunque el filtro ya estuviera puesto', () async {
      final subject = mode();
      await subject.configure(password: 'buena');
      subject.lock();

      final seen = <bool>[];
      subject.changes.listen(seen.add);

      await subject.disable();
      await Future<void>.delayed(Duration.zero);

      expect(seen, isNotEmpty);
      expect(subject.isConfigured, isFalse);
      await subject.dispose();
    });

    test('y también con el filtro quitado', () async {
      final subject = mode();
      await subject.configure(password: 'buena');

      final seen = <bool>[];
      subject.changes.listen(seen.add);

      await subject.disable();
      await Future<void>.delayed(Duration.zero);

      // Una sola vez: avisar dos veces del mismo cambio hace que la rejilla se
      // recargue por duplicado cada vez que alguien desactiva el filtro.
      expect(seen, [false]);
      await subject.dispose();
    });

    test('la contraseña se cambia sabiendo la de ahora', () async {
      final subject = mode();
      await subject.configure(password: 'vieja');

      expect(await subject.changePassword(current: 'otra', next: 'nueva'), isFalse);
      expect(await subject.changePassword(current: 'vieja', next: 'nueva'), isTrue);

      subject.lock();
      expect(await subject.unlock('nueva'), UnlockOutcome.unlocked);
    });

    group('recuperar', () {
      test('el código fija una contraseña nueva', () async {
        final subject = mode();
        final code = await subject.configure(password: 'perdida');
        subject.lock();

        final next = await subject.recover(code: code, password: 'nueva');

        expect(next, isNotNull);
        expect(subject.isUnlocked, isTrue);
        subject.lock();
        expect(await subject.unlock('nueva'), UnlockOutcome.unlocked);
      });

      test('se teclea como se pueda', () async {
        final subject = mode();
        final code = await subject.configure(password: 'perdida');

        expect(
          await subject.recover(code: code.toLowerCase(), password: 'nueva'),
          isNotNull,
        );
      });

      // Un código de un solo uso que sigue valiendo es un código de siempre, y
      // el que se apuntó en un papel hace un año abriría la biblioteca para
      // siempre.
      test('el usado deja de valer', () async {
        final subject = mode();
        final first = await subject.configure(password: 'perdida');

        final second = await subject.recover(code: first, password: 'nueva');

        expect(second, isNot(first));
        expect(await subject.recover(code: first, password: 'otra'), isNull);
      });

      test('uno inventado no abre', () async {
        final subject = mode();
        await subject.configure(password: 'perdida');

        expect(
          await subject.recover(code: 'FERN-AAAA-BBBB-CCCC', password: 'x'),
          isNull,
        );
      });
    });

    group('entre arranques', () {
      test('de fábrica el modo se cierra', () async {
        await mode().configure(password: 'buena');

        final next = mode()..restore();

        expect(next.isUnlocked, isFalse);
      });

      test('si se pide, se recuerda', () async {
        final subject = mode();
        await subject.configure(password: 'buena');
        await subject.setRemembered(remembered: true);

        final next = mode()..restore();

        expect(next.isUnlocked, isTrue);
      });

      // Quien lo apaga está diciendo que no quiere esto abierto. Dejarlo abierto
      // hasta el cierre siguiente es hacer lo contrario de lo que ha pedido.
      test('dejar de recordarlo lo cierra ahora', () async {
        final subject = mode();
        await subject.configure(password: 'buena');
        await subject.setRemembered(remembered: true);

        await subject.setRemembered(remembered: false);

        expect(subject.isUnlocked, isFalse);
      });

      test('sin contraseña no se recuerda nada', () async {
        storage.values[NsfwKeys.remembered] = 'true';

        final subject = mode()..restore();

        expect(subject.isUnlocked, isFalse);
      });
    });

    test('quitar el bloqueo no deja nada guardado', () async {
      final subject = mode();
      await subject.configure(password: 'buena', hint: 'pista');

      await subject.disable();

      expect(subject.isConfigured, isFalse);
      expect(subject.isUnlocked, isFalse);
      expect(subject.hint, isNull);
      expect(storage.values, isEmpty);
    });
  });
}

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
