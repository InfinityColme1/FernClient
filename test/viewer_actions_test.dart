// Lo que pasa después de las dos acciones del visor que quitan contenido de en
// medio: guardar y descartar.
//
// Las dos comparten la misma regla y por el mismo motivo: **revisando una
// importación se sigue con el siguiente**. Repasar una tanda es abrir, decidir y
// pasar; salir del visor en cada decisión obliga a volver a entrar por el que
// venía detrás, y con cincuenta piezas eso son cincuenta viajes.
//
// Fuera de una revisión, el visor se cierra: allí no se está despachando una
// cola, se está mirando algo concreto.

import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:flutter_test/flutter_test.dart';

MediaEntity _media({bool isImported = false}) => MediaEntity(
      id: 1,
      path: 'C:/media/uno.jpg',
      isImported: isImported,
      downloaded: DateTime(2026),
      creator: const CreatorEntity(id: 1, name: 'alguien'),
    );

void main() {
  group('descartar desde el visor', () {
    // Lo de siempre: fuera de una revisión, el visor se cierra al quitar lo que
    // se estaba viendo.
    test('de fábrica no pide seguir', () {
      expect(DeleteMediaEvent(_media()).goToNext, isFalse);
    });

    test('revisando sí', () {
      expect(DeleteMediaEvent(_media(), goToNext: true).goToNext, isTrue);
    });

    // Las dos decisiones viajan juntas y son independientes: se puede descartar
    // llevándose el fichero y seguir con el siguiente igual.
    test('y eso no cambia lo que se hace con el fichero', () {
      final event = DeleteMediaEvent(
        _media(),
        deleteFiles: true,
        goToNext: true,
      );

      expect(event.deleteFiles, isTrue);
      expect(event.goToNext, isTrue);
    });
  });
}
