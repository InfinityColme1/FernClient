// Las colecciones grandes del estado se comparan por identidad.
//
// Un bloc mira si el estado nuevo es igual al anterior antes de emitirlo, y
// Equatable compara las listas elemento a elemento. Con veinte mil contenidos
// eso era recorrer veinte mil entidades —con sus doce campos cada una— en cada
// cambio de estado: marcar una celda, pasar el raton, abrir el panel. Ahi se
// iban los fotogramas.
//
// Es correcto porque ninguna de esas colecciones se toca por dentro: cada
// cambio construye una nueva, y `copyWith` conserva la instancia de lo que no
// cambia. El error posible es benigno —una emision de mas, o sea un repintado—
// y nunca una de menos, que es la que se notaria.

import 'package:Fern/core/utils/same_instance.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _media(int id) =>
    MediaSummaryEntity(id: id, path: 'C:/media/$id.jpg');

void main() {
  group('la envoltura', () {
    test('la misma instancia es la misma', () {
      final list = [_media(1)];

      expect(SameInstance(list), SameInstance(list));
    });

    test('y una copia con lo mismo dentro, no', () {
      expect(SameInstance([_media(1)]), isNot(SameInstance([_media(1)])));
    });

    // Dos nulos son el mismo nulo: un estado sin lista no cambia por no
    // tenerla.
    test('dos nulos son iguales', () {
      expect(const SameInstance(null), const SameInstance(null));
    });

    test('y sirve como clave, que es lo que hace Equatable con el hash', () {
      final list = [_media(1)];

      expect(SameInstance(list).hashCode, SameInstance(list).hashCode);
    });
  });

  group('el estado', () {
    // Lo que se hace en cada seleccion: la misma lista, otra seleccion. Tiene
    // que salir distinto para que la rejilla se repinte.
    test('cambiar la seleccion lo hace distinto', () {
      final list = [_media(1), _media(2)];
      final before = MediaLoading(mediaList: list);

      expect(before.copyWith(selectedIds: {1}), isNot(before));
    });

    // Y sin tocar nada tiene que salir igual, o el bloc emitiria en cada
    // llamada y la pantalla se repintaria sola.
    test('y no tocar nada lo deja igual', () {
      final list = [_media(1), _media(2)];
      final before = MediaLoading(mediaList: list);

      expect(before.copyWith(), before);
    });

    test('sustituir la lista lo hace distinto', () {
      final before = MediaLoading(mediaList: [_media(1)]);

      expect(before.copyWith(mediaList: [_media(1), _media(2)]), isNot(before));
    });
  });
}
