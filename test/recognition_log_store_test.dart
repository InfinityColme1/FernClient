// El parte de lo que hizo cada reconocimiento, y lo que ocupa.
//
// Vive en memoria mientras la aplicación esté abierta, así que lo que importa
// tanto como guardarlo es **soltarlo**: sin topes, «reconocer la biblioteca»
// sobre diez mil contenidos deja diez mil partes ahí hasta que alguien cierre.

import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:flutter_test/flutter_test.dart';

MediaRecognitionLog _log(int mediaId) => MediaRecognitionLog(
      mediaId: mediaId,
      name: 'img-$mediaId.jpg',
      models: const [],
      at: DateTime(2026),
    );

void main() {
  group('lo que guarda', () {
    test('el parte de un trabajo, en orden', () {
      final store = RecognitionLogStore();

      store.add('trabajo', _log(1));
      store.add('trabajo', _log(2));

      expect([for (final one in store.of('trabajo')) one.mediaId], [1, 2]);
    });

    test('lo de un contenido concreto', () {
      final store = RecognitionLogStore()
        ..add('trabajo', _log(1))
        ..add('trabajo', _log(2));

      expect(store.forMedia('trabajo', 2)?.mediaId, 2);
      expect(store.forMedia('trabajo', 99), isNull);
    });

    test('cada trabajo por su cuenta', () {
      final store = RecognitionLogStore()
        ..add('uno', _log(1))
        ..add('otro', _log(2));

      expect(store.of('uno').single.mediaId, 1);
      expect(store.of('otro').single.mediaId, 2);
    });
  });

  group('lo que suelta', () {
    test('los trabajos viejos se caen', () {
      final store = RecognitionLogStore(limit: 2);

      store.add('uno', _log(1));
      store.add('dos', _log(2));
      store.add('tres', _log(3));

      // Guardar el parte de trabajos que ya no se pueden ni ver es memoria para
      // nada.
      expect(store.has('uno'), isFalse);
      expect(store.has('tres'), isTrue);
    });

    test('un trabajo enorme no crece sin fin', () {
      final store = RecognitionLogStore(perJobLimit: 3);

      for (var id = 1; id <= 10; id++) {
        store.add('trabajo', _log(id));
      }

      expect(store.of('trabajo').length, 3);
    });

    test('de un trabajo enorme se quedan los últimos', () {
      final store = RecognitionLogStore(perJobLimit: 3);

      for (var id = 1; id <= 10; id++) {
        store.add('trabajo', _log(id));
      }

      // Los últimos y no los primeros: son los que se estaban mirando cuando
      // terminó, y nadie abre un log de diez mil filas a buscar la suya.
      expect([for (final one in store.of('trabajo')) one.mediaId], [8, 9, 10]);
    });

    test('el tope de un trabajo no toca a los demás', () {
      final store = RecognitionLogStore(perJobLimit: 1);

      store.add('uno', _log(1));
      store.add('otro', _log(2));
      store.add('otro', _log(3));

      expect(store.of('uno').single.mediaId, 1);
      expect(store.of('otro').single.mediaId, 3);
    });

    test('vaciar lo deja todo limpio', () {
      final store = RecognitionLogStore()..add('trabajo', _log(1));

      store.clear();

      expect(store.has('trabajo'), isFalse);
    });
  });
}
