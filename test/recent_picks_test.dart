// Las últimas etiquetas y creadores usados.
//
// Se ofrecen nada más pulsar el campo, antes de escribir nada: etiquetar una
// tanda es poner las mismas tres una y otra vez.
//
// Lo que se guarda son **identificadores** y se resuelven al leerlos. De ahí
// salen las dos propiedades que hay que sostener: renombrar una etiqueta no deja
// un reciente que ya no lleva a ninguna parte, y una borrada —o escondida por el
// filtro NSFW— desaparece sola de la lista sin que nadie vaya a limpiarla.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/services/recent_picks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService preferences;
  late _FakeRepository repository;
  late RecentPicks recents;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    preferences = PreferencesService(await SharedPreferences.getInstance());
    repository = _FakeRepository();
    recents = RecentPicks(preferences: preferences, repository: repository);
  });

  group('las etiquetas', () {
    test('sin nada usado todavía, ninguna', () async {
      expect(await recents.tags(), isEmpty);
    });

    test('la última usada va la primera', () async {
      repository.tags = {1: 'uno', 2: 'dos'};

      await recents.pushTag(1);
      await recents.pushTag(2);

      expect((await recents.tags()).map((tag) => tag.name), ['dos', 'uno']);
    });

    // Lo que interesa es el orden de uso, no el de la primera vez que se usó.
    test('volver a usar una la sube', () async {
      repository.tags = {1: 'uno', 2: 'dos', 3: 'tres'};

      await recents.pushTag(1);
      await recents.pushTag(2);
      await recents.pushTag(3);
      await recents.pushTag(1);

      expect(
        (await recents.tags()).map((tag) => tag.name),
        ['uno', 'tres', 'dos'],
      );
    });

    test('no se repite', () async {
      repository.tags = {1: 'uno'};

      await recents.pushTag(1);
      await recents.pushTag(1);

      expect(await recents.tags(), hasLength(1));
    });

    // La pila entera: el desplegable enseña tres y el resto se desplaza.
    test('se ofrece la pila entera, de la última a la primera', () async {
      repository.tags = {for (var i = 1; i <= 6; i++) i: 'tag $i'};

      for (var i = 1; i <= 6; i++) {
        await recents.pushTag(i);
      }

      final tags = await recents.tags();
      expect(tags, hasLength(6));
      expect(tags.first.id, 6);
    });

    // Se guardan más de los que se enseñan a propósito: sin colchón, borrar dos
    // dejaría la lista en uno.
    test('una borrada se cae de la lista y la siguiente ocupa su sitio',
        () async {
      repository.tags = {for (var i = 1; i <= 5; i++) i: 'tag $i'};

      for (var i = 1; i <= 5; i++) {
        await recents.pushTag(i);
      }

      // Se borran las dos más recientes.
      repository.tags.remove(5);
      repository.tags.remove(4);

      expect(
        (await recents.tags()).map((tag) => tag.name),
        ['tag 3', 'tag 2', 'tag 1'],
      );
    });

    // Las que ya lleva el contenido no se ofrecen, y su sitio lo ocupa la
    // siguiente de la pila: al asignar una de las tres siguen saliendo tres.
    test('sin las ya puestas, y con los huecos llenos', () async {
      repository.tags = {for (var i = 1; i <= 6; i++) i: 'tag $i'};

      for (var i = 1; i <= 6; i++) {
        await recents.pushTag(i);
      }

      expect(
        (await recents.tags(excluding: {6, 4})).map((tag) => tag.name),
        ['tag 5', 'tag 3', 'tag 2', 'tag 1'],
      );
    });

    // La pila llega a veinticinco: poner muchas seguidas no la vacía.
    test('se guardan veinticinco', () async {
      repository.tags = {for (var i = 1; i <= 30; i++) i: 'tag $i'};

      for (var i = 1; i <= 30; i++) {
        await recents.pushTag(i);
      }

      expect(preferences.recentTagIds(), hasLength(25));
      expect(
        (await recents.tags(excluding: {for (var i = 8; i <= 30; i++) i}))
            .map((tag) => tag.name),
        ['tag 7', 'tag 6'],
      );
    });

    test('con todas borradas, la lista queda vacía', () async {
      repository.tags = {1: 'uno'};
      await recents.pushTag(1);

      repository.tags.clear();

      expect(await recents.tags(), isEmpty);
    });

    // Se guarda el identificador y no el nombre: si no, renombrarla dejaría un
    // reciente que no lleva a ninguna parte.
    test('renombrarla no la pierde', () async {
      repository.tags = {1: 'como se llamaba'};
      await recents.pushTag(1);

      repository.tags[1] = 'como se llama ahora';

      expect((await recents.tags()).single.name, 'como se llama ahora');
    });
  });

  // Los fernies llevan su propia lista y no se resuelven aquí: el menú que los
  // usa ya tiene la lista delante y sólo la recoloca, así que lo que hace falta
  // guardar y leer son los identificadores.
  group('los fernies', () {
    test('van por su cuenta', () async {
      await preferences.pushRecentFernie(7);
      await preferences.pushRecentFernie(9);

      expect(preferences.recentFernieIds(), [9, 7]);
      expect(preferences.recentTagIds(), isEmpty);
    });

    test('volver a usar uno lo sube', () async {
      await preferences.pushRecentFernie(7);
      await preferences.pushRecentFernie(9);
      await preferences.pushRecentFernie(7);

      expect(preferences.recentFernieIds(), [7, 9]);
    });
  });

  group('los creadores', () {
    test('van por su cuenta, en su propia lista', () async {
      repository.tags = {1: 'una etiqueta'};
      repository.creators = {10: 'un creador'};

      await recents.pushTag(1);
      await recents.pushCreator(10);

      expect((await recents.tags()).single.name, 'una etiqueta');
      expect((await recents.creators()).single.name, 'un creador');
    });

    test('y siguen la misma regla', () async {
      repository.creators = {10: 'uno', 11: 'dos'};

      await recents.pushCreator(10);
      await recents.pushCreator(11);

      expect(
        (await recents.creators()).map((each) => each.name),
        ['dos', 'uno'],
      );
    });
  });
}

/// Devuelve lo que tenga, y `null` para lo que no: es lo que hace el repositorio
/// de verdad con lo borrado **y con lo que esconde el filtro NSFW**.
class _FakeRepository implements LocalMediaRepository {
  Map<int, String> tags = {};
  Map<int, String> creators = {};

  @override
  Future<DataState<TagEntity?>> getTag(int id) async {
    final name = tags[id];

    return DataSuccess(
      name == null ? null : TagEntity(id: id, name: name, children: const []),
    );
  }

  @override
  Future<DataState<CreatorEntity?>> getCreator(int id) async {
    final name = creators[id];

    return DataSuccess(
      name == null ? null : CreatorEntity(id: id, name: name),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
