// Aceptar la sugerencia de un fernie que no enlaza ninguna etiqueta.
//
// Antes esas filas sólo se podían rechazar: el modelo acertaba, se veía que
// acertaba —«Patas 49 %»— y lo único que se podía hacer era decirle que no. No
// había botón de aceptar porque no había nada que poner.
//
// Ahora se le da la etiqueta que se llama como él. Dos cosas hay que sostener:
// que **no se duplica** —si ya existe una que se llama así, es ésa— y que el
// fernie **se queda enlazado**, que es lo que evita repetir esto una vez por
// contenido para siempre.

import 'package:Fern/features/media/domain/entities/duplicate_tag_name.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/adopt_fernie_tag_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

FernieEntity _fernie(String name, {int? linkedTagId}) =>
    FernieEntity(id: 7, name: name, linkedTagId: linkedTagId);

void main() {
  late _FakeMedia media;
  late _FakeFernies fernies;
  late AdoptFernieTagUseCase adopt;

  setUp(() {
    media = _FakeMedia();
    fernies = _FakeFernies();
    adopt = AdoptFernieTagUseCase(
      media: media,
      fernies: fernies,
      saveTag: SaveTagUseCase(media),
    );
  });

  group('sin etiqueta que se llame como él', () {
    test('se crea', () async {
      final result = await adopt(params: _fernie('Patas'));

      expect(result, isA<DataSuccess>());
      expect(result.data!.name, 'Patas');
      expect(media.tags.values, contains('Patas'));
    });

    test('y el fernie se queda enlazado con ella', () async {
      final result = await adopt(params: _fernie('Patas'));

      // Sin esto, la siguiente detección de «Patas» volvería a llegar sin
      // proponer nada y habría que repetirlo en cada contenido.
      expect(fernies.updated.single.linkedTagId, result.data!.id);
      expect(fernies.updated.single.linkedName, 'Patas');
    });
  });

  group('con una que ya se llama así', () {
    test('se usa la que hay, no se crea otra', () async {
      media.tags[3] = 'Patas';

      final result = await adopt(params: _fernie('Patas'));

      expect(result.data!.id, 3);
      expect(media.saved, isEmpty);
    });

    // Los nombres no se repiten, así que crear una segunda ni siquiera se
    // podría; y si se pudiera, partiría en dos lo que el usuario ve como una.
    test('da igual cómo esté escrita', () async {
      media.tags[3] = 'Patas';

      final result = await adopt(params: _fernie('  patas '));

      expect(result.data!.id, 3);
      expect(media.saved, isEmpty);
    });

    test('y el fernie se enlaza con ella igual', () async {
      media.tags[3] = 'Patas';

      await adopt(params: _fernie('Patas'));

      expect(fernies.updated.single.linkedTagId, 3);
    });
  });

  group('cuando ya estaba enlazado', () {
    test('no se toca nada', () async {
      media.tags[3] = 'Patas';

      final result = await adopt(params: _fernie('Patas', linkedTagId: 3));

      expect(result.data!.id, 3);
      expect(media.saved, isEmpty);
      expect(fernies.updated, isEmpty);
    });

    // Es lo que pasa al aceptar dos sugerencias del mismo fernie: la segunda
    // tiene que encontrárselo hecho.
    test('aceptar dos veces seguidas no crea dos etiquetas', () async {
      final first = await adopt(params: _fernie('Patas'));

      final again = await adopt(
        params: _fernie('Patas', linkedTagId: first.data!.id),
      );

      expect(again.data!.id, first.data!.id);
      expect(media.saved, hasLength(1));
    });
  });

  // Un fernie cuya etiqueta alguien borró llega igual de vacío que uno que nunca
  // la tuvo, y se trata igual: se recrea por el nombre. Distinguirlos obligaría
  // a guardar qué enlace tuvo antes, y el botón haría cosas distintas en dos
  // filas que se ven idénticas.
  test('si la etiqueta que enlazaba ya no está, se recrea por el nombre',
      () async {
    final result = await adopt(params: _fernie('Patas', linkedTagId: 99));

    expect(result.data!.name, 'Patas');
    expect(result.data!.id, isNot(99));
    expect(fernies.updated.single.linkedTagId, result.data!.id);
  });

  group('lo que no se hace', () {
    test('un fernie sin nombre no adopta nada', () async {
      final result = await adopt(params: _fernie('   '));

      expect(result, isA<DataException>());
      expect(media.saved, isEmpty);
      expect(fernies.updated, isEmpty);
    });

    // El enlace es lo que ahorra repetirlo, pero la etiqueta ya existe y
    // ponerla en el contenido sigue siendo correcto.
    test('si el enlace falla, la etiqueta se devuelve igual', () async {
      fernies.fails = true;

      final result = await adopt(params: _fernie('Patas'));

      expect(result, isA<DataSuccess>());
      expect(result.data!.name, 'Patas');
    });

    // Buscarla por su nombre no mira el modo NSFW, al revés que pedirla por su
    // identificador: aquí se pregunta si el nombre ya es de alguien, y una
    // escondida lo es. Filtrándola se llegaría al peor sitio posible —no se
    // encuentra, y crearla se rechaza porque el nombre está cogido—, que es una
    // operación que no se puede hacer y no dice por qué.
    test('una escondida por el filtro sigue siendo la dueña del nombre',
        () async {
      media.tags[3] = 'Patas';
      media.hidden.add(3);

      final result = await adopt(params: _fernie('Patas'));

      expect(result.data!.id, 3);
      expect(media.saved, isEmpty);
    });

    // El enlace sigue estando, pero pedirla por identificador no la devuelve.
    // Sin la búsqueda por nombre detrás se crearía una segunda «Patas», o mejor
    // dicho: se intentaría, y no se podría.
    test('y un fernie enlazado a una escondida no se duplica', () async {
      media.tags[3] = 'Patas';
      media.hidden.add(3);

      final result = await adopt(params: _fernie('Patas', linkedTagId: 3));

      expect(result.data!.id, 3);
      expect(media.saved, isEmpty);
    });
  });
}

class _FakeMedia implements LocalMediaRepository {
  final Map<int, String> tags = {};
  final Set<int> hidden = {};
  final saved = <String>[];

  var _next = 100;

  @override
  Future<DataState<TagEntity?>> findTagNamed(String name) async {
    final clean = name.trim().toLowerCase();

    for (final entry in tags.entries) {
      if (entry.value.toLowerCase() != clean) continue;

      return DataSuccess(
        TagEntity(id: entry.key, name: entry.value, children: const []),
      );
    }

    return const DataSuccess(null);
  }

  /// Como el de verdad: lo escondido por el filtro no vuelve al pedirlo por su
  /// identificador.
  @override
  Future<DataState<TagEntity?>> getTag(int id) async {
    final name = hidden.contains(id) ? null : tags[id];

    return DataSuccess(
      name == null ? null : TagEntity(id: id, name: name, children: const []),
    );
  }

  /// Rechaza el nombre repetido, como el de verdad: si no, la prueba de «no se
  /// crea otra» pasaría aunque el caso de uso creara una.
  @override
  Future<DataState<TagEntity>> saveTag(TagEntity tag, {TagEntity? parent}) async {
    final clean = tag.name.trim();

    if (tags.values.any((each) => each.toLowerCase() == clean.toLowerCase())) {
      return DataException(DuplicateTagNameException(clean));
    }

    final id = _next++;
    tags[id] = clean;
    saved.add(clean);

    return DataSuccess(TagEntity(id: id, name: clean, children: const []));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeFernies implements FernieRepository {
  final updated = <FernieEntity>[];

  /// Escribir el enlace falla: pasa si alguien borra el fernie mientras tanto.
  bool fails = false;

  @override
  Future<DataState<FernieEntity>> updateFernie(FernieEntity fernie) async {
    if (fails) return DataException(Exception('no se pudo'));

    updated.add(fernie);

    return DataSuccess(fernie);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
