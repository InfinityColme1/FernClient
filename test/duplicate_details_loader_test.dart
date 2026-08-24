// Reunir lo que hace falta para comparar las copias de un grupo.
//
// Junta tres fuentes que fallan de maneras distintas: la base, que puede no
// tener ya el contenido; el decodificador, que puede no entender el fichero; y
// el disco, que puede no tenerlo. Lo que se comprueba es que cada fallo cuesta
// lo justo y no más, porque la pantalla que hay detrás tiene un botón que manda
// contenido a la papelera.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_details_loader.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:flutter_test/flutter_test.dart';

MediaEntity _media(int id) => MediaEntity(
      id: id,
      path: 'C:/$id.jpg',
      downloaded: DateTime(2026),
      creator: const CreatorEntity(id: 1, name: 'Unknown'),
    );

void main() {
  late Set<int> missing;
  late List<String> measured;

  setUp(() {
    missing = {};
    measured = [];
  });

  DuplicateDetailsLoader loader({
    PixelSizeReader? pixels,
    FileWeightReader? weight,
  }) {
    return DuplicateDetailsLoader(
      details: (id) async => missing.contains(id)
          ? DataException(Exception('no está'))
          : DataSuccess(_media(id)),
      pixels: pixels ??
          (path) async {
            measured.add(path);

            return (width: 100, height: 50);
          },
      weight: weight ?? (path) => 1234,
    );
  }

  group('lo normal', () {
    test('trae una copia por contenido, en el orden que se pide', () async {
      final copies = await loader().load([3, 1, 2]);

      expect(copies.map((one) => one.mediaId), [3, 1, 2]);
    });

    test('mide el fichero de cada una', () async {
      final copies = await loader().load([1, 2]);

      expect(measured, ['C:/1.jpg', 'C:/2.jpg']);
      expect(copies.first.width, 100);
      expect(copies.first.height, 50);
      expect(copies.first.sizeInBytes, 1234);
    });

    test('sin contenidos no hay copias', () async {
      expect(await loader().load(const []), isEmpty);
    });
  });

  group('lo que falta', () {
    test('lo que ya no está en la base se queda fuera', () async {
      missing = {2};

      final copies = await loader().load([1, 2, 3]);

      // Un grupo sobrevive a que una copia se haya borrado por otro camino;
      // enseñar una tarjeta vacía con un botón de conservar debajo, no.
      expect(copies.map((one) => one.mediaId), [1, 3]);
    });

    test('un fichero que no se puede medir sigue en la comparación', () async {
      final copies = await loader(pixels: (_) async => null).load([1]);

      // Que el decodificador no lo entienda no lo hace desaparecer: la fecha,
      // las etiquetas y el creador se siguen pudiendo comparar.
      expect(copies.single.hasSize, isFalse);
      expect(copies.single.mediaId, 1);
    });

    test('si medir revienta, la copia sigue viva sin tamaño', () async {
      final copies = await loader(
        pixels: (_) async => throw StateError('formato raro'),
      ).load([1]);

      expect(copies.single.hasSize, isFalse);
    });

    test('un fichero que ya no está no tiene peso pero sí ficha', () async {
      final copies = await loader(weight: (_) => null).load([1]);

      expect(copies.single.sizeInBytes, isNull);
      expect(copies.single.mediaId, 1);
    });
  });
}
