// Lo mismo visto varias veces en un contenido.
//
// Un modelo puede ver **cuatro coches en una foto**: son cuatro detecciones de
// la clase «coche», cada una con su rectángulo, y las cuatro valen porque cada
// una es una región distinta que se puede marcar. Antes se guardaba sólo la
// mejor y las otras tres se perdían antes de llegar a la pantalla.
//
// En el panel son **una sola fila** —es la misma etiqueta, y ponerla cuatro
// veces no significa nada— con el porcentaje de la mejor y cuántas hay. Lo que
// se agrupa es por modelo **y** fernie: el mismo fernie visto por dos modelos
// son dos opiniones separadas, y juntarlas escondería que uno lo dice y el otro
// no.

import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/services/suggestion_groups.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSuggestionEntity _seen({
  required int id,
  int modelId = 1,
  int fernieId = 10,
  double confidence = 0.9,
  double? x = 0.1,
}) =>
    MediaSuggestionEntity(
      result: RecognitionResultEntity(
        id: id,
        mediaId: 7,
        modelId: modelId,
        fernieId: fernieId,
        confidence: confidence,
        x: x,
        y: x == null ? null : 0.2,
        w: x == null ? null : 0.1,
        h: x == null ? null : 0.1,
        createdAt: DateTime(2026),
      ),
      fernie: FernieEntity(id: fernieId, name: 'coche', linkedTagId: 42),
      tag: TagEntity(id: 42, name: 'coche', children: const []),
    );

void main() {
  group('lo que se junta', () {
    test('varias del mismo modelo y fernie son un grupo', () {
      final groups = groupSuggestions([
        _seen(id: 1, x: 0.1),
        _seen(id: 2, x: 0.4),
        _seen(id: 3, x: 0.7),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.count, 3);
      expect(groups.single.isMultiple, isTrue);
    });

    // Dos opiniones separadas: juntarlas escondería que uno de los dos modelos
    // lo dice y el otro no.
    test('pero el mismo fernie de dos modelos son dos', () {
      final groups = groupSuggestions([
        _seen(id: 1, modelId: 1),
        _seen(id: 2, modelId: 2),
      ]);

      expect(groups, hasLength(2));
    });

    test('y dos fernies del mismo modelo también', () {
      final groups = groupSuggestions([
        _seen(id: 1, fernieId: 10),
        _seen(id: 2, fernieId: 11),
      ]);

      expect(groups, hasLength(2));
    });

    test('una sola sigue siendo un grupo de una', () {
      final groups = groupSuggestions([_seen(id: 1)]);

      expect(groups.single.count, 1);
      expect(groups.single.isMultiple, isFalse);
    });

    test('sin nada, ningún grupo', () {
      expect(groupSuggestions(const []), isEmpty);
    });
  });

  group('dentro del grupo', () {
    // El porcentaje que se enseña es el de la mejor: es lo que ha significado
    // siempre, y una media haría que una detección mala arrastrara la fila.
    test('manda la más segura', () {
      final groups = groupSuggestions([
        _seen(id: 1, confidence: 0.5),
        _seen(id: 2, confidence: 0.9),
        _seen(id: 3, confidence: 0.7),
      ]);

      expect(groups.single.best.confidence, 0.9);
    });

    test('y van ordenadas de más a menos', () {
      final groups = groupSuggestions([
        _seen(id: 1, confidence: 0.5),
        _seen(id: 2, confidence: 0.9),
        _seen(id: 3, confidence: 0.7),
      ]);

      expect(
        [for (final one in groups.single.instances) one.confidence],
        [0.9, 0.7, 0.5],
      );
    });

    // Aceptar y rechazar van sobre el grupo entero: la etiqueta es la misma y
    // ponerla cuatro veces no significa nada, pero las cuatro detecciones tienen
    // que quedar contestadas o la fila seguiría ahí después de aceptarla.
    test('se contestan todas a la vez', () {
      final groups = groupSuggestions([
        _seen(id: 1),
        _seen(id: 2, x: 0.4),
        _seen(id: 3, x: 0.7),
      ]);

      expect(groups.single.ids, [1, 2, 3]);
    });
  });

  group('dónde está cada una', () {
    test('las que tienen caja se pueden señalar', () {
      final groups = groupSuggestions([
        _seen(id: 1, x: 0.1),
        _seen(id: 2, x: 0.4),
      ]);

      expect(groups.single.located, hasLength(2));
    });

    // Un modelo booleano dice que algo está pero no dónde: esas no se pueden
    // pintar sobre el contenido, pero siguen contando como detecciones.
    test('las que no, se quedan fuera del señalado', () {
      final groups = groupSuggestions([
        _seen(id: 1, x: 0.1),
        _seen(id: 2, x: null),
      ]);

      expect(groups.single.count, 2);
      expect(groups.single.located, hasLength(1));
    });
  });
}
