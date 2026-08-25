// El filtro por clase de contenido.
//
// Va con el de fuentes y no con el de tipos de resultado: de qué clase es un
// fichero es un dato suyo, no de un resultado de búsqueda, así que recorta la
// rejilla haya búsqueda o no.

import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:flutter_test/flutter_test.dart';

const _image = MediaSummaryEntity(id: 1, path: 'C:/una.jpg');
const _gif = MediaSummaryEntity(id: 2, path: 'C:/otra.gif');
const _video = MediaSummaryEntity(id: 3, path: 'C:/otro.mp4');

MediaStates _stateWith(Set<MediaKind> kinds) => MediaLoading(typeFilters: kinds);

void main() {
  group('de qué clase es cada fichero', () {
    test('se decide por la extensión, en un solo sitio', () {
      expect(MediaKind.of('C:/una.JPG'), MediaKind.image);
      expect(MediaKind.of('C:/otra.GIF'), MediaKind.gif);
      expect(MediaKind.of('C:/otro.MKV'), MediaKind.video);
    });

    // Lo que no se reconoce se trata como imagen: es lo que la aplicación
    // intenta pintar, y esconderlo por no saber qué es sería peor.
    test('lo desconocido cuenta como imagen', () {
      expect(MediaKind.of('C:/sin_extension'), MediaKind.image);
    });
  });

  group('el filtro', () {
    test('de partida deja ver las tres', () {
      const state = MediaLoading();

      expect(state.showsType(_image), isTrue);
      expect(state.showsType(_gif), isTrue);
      expect(state.showsType(_video), isTrue);
    });

    test('deja pasar sólo lo encendido', () {
      final state = _stateWith({MediaKind.video});

      expect(state.showsType(_video), isTrue);
      expect(state.showsType(_image), isFalse);
      expect(state.showsType(_gif), isFalse);
    });

    test('sin ninguna encendida no se ve nada', () {
      final state = _stateWith(const {});

      expect(state.showsType(_image), isFalse);
      expect(state.showsType(_video), isFalse);
    });

    // Los dos filtros son la misma pregunta —«¿esto se pinta?»— y separarlos es
    // la forma de que alguien aplique uno y se olvide del otro.
    test('se combina con el de fuentes', () {
      final state = MediaLoading(
        typeFilters: const {MediaKind.image},
        sourceFilters: const {},
      );

      expect(state.showsType(_image), isTrue);
      expect(state.shows(_image), isFalse);
    });
  });
}
