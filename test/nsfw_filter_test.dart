// Que no se escape ni uno.
//
// Esta es la prueba que sostiene la fase entera. El bloqueo NSFW no es una
// función que funcione «casi siempre»: una sola fuga —una rejilla, un contador,
// una sugerencia de la barra de búsqueda— y no sirve de nada, porque lo que
// delata no es ver el contenido, es que aparezca donde no debería.
//
// Por eso se prueba contra una base de datos de verdad y **recorriendo todos**
// los métodos del repositorio que devuelven contenido o etiquetas, no los que a
// uno le parezcan importantes. Si mañana se añade uno que no pasa por el punto
// único, esto tiene que ponerse en rojo.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// Los identificadores de la biblioteca de prueba.
const visibleId = 1;
const blockedId = 2;
const blockedByBranchId = 3;
const scannedBlockedId = 4;
const deletedBlockedId = 5;

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;
  late NsfwIndex index;
  late NsfwModeService mode;

  /// Con el bloqueo abierto, sólo se enseña lo marcado.
  late bool showsOnlyMarked;

  /// Con el bloqueo cerrado, lo marcado se enseña tapado.
  late bool covers;

  /// Marcar una etiqueta arrastra a las que cuelgan de ella.
  late bool marksChildren;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilación de la aplicación '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_nsfw_test');
    final avatars = await Directory(p.join(directory.path, 'avatars')).create();

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        DuplicateGroupModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    final settings = _Settings(avatarsPath: avatars.path);
    final hierarchy = TagHierarchy(database: isar);

    showsOnlyMarked = false;
    covers = false;
    marksChildren = true;

    index = NsfwIndex(
      database: isar,
      hierarchy: hierarchy,
      marksChildren: () => marksChildren,
    );
    // Pocas vueltas al derivar: aquí no se prueba lo que cuesta una contraseña.
    mode = NsfwModeService(
      storage: _MemoryStorage(),
      passwords: PasswordService(iterations: 64),
    );

    repository = LocalMediaRepositoryImpl(
      appDatabase: isar,
      fileOrganizer: MediaFileOrganizer(settingsRepository: settings),
      avatarStorage: AvatarStorageService(settingsRepository: settings),
      registry: MediaRegistry(database: isar, tagHierarchy: hierarchy),
      tagHierarchy: hierarchy,
      visibility: NsfwVisibility(
        index: index,
        mode: mode,
        showsOnlyMarked: () => showsOnlyMarked,
        covers: () => covers,
      ),
      onNsfwChanged: index.rebuild,
    );

    await _seed(isar);
    await index.rebuild();

    // Con contraseña puesta y el modo cerrado, que es la situación que hay que
    // probar. Sin contraseña no se esconde nada a propósito —ver
    // `NsfwVisibility`—, y con eso el barrido de abajo pasaría sin comprobar
    // nada en absoluto.
    await mode.configure(password: 'la buena');
    mode.lock();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  List<T> ok<T>(DataState<List<T>> state) => (state as DataSuccess<List<T>>).data!;

  /// Todos los identificadores de contenido que devuelve cada método del
  /// repositorio que devuelve contenido, con el nombre por el que se le
  /// reconoce.
  ///
  /// La lista es la que hay que ampliar al añadir un método nuevo. Que esté
  /// aquí y no repartida en veinte pruebas es lo que hace que se note el hueco:
  /// añadir contenido nuevo a la aplicación y no tocar esto deja el método sin
  /// vigilar, pero al menos deja el sitio evidente.
  Future<Map<String, List<int>>> everythingReturned() async {
    final suggestion = const SearchSuggestionEntity(
      id: blockedId,
      type: SearchResultType.media,
      label: 'prohibida',
    );

    final tagSuggestion = const SearchSuggestionEntity(
      id: 2,
      type: SearchResultType.tag,
      label: 'prohibido',
    );

    return {
      'getMediaList': [
        for (final one in ok(await repository.getMediaList())) one.id,
      ],
      'getScannedMedia': [
        for (final one in ok(await repository.getScannedMedia())) one.id,
      ],
      'getDeletedMedia': [
        for (final one in ok(await repository.getDeletedMedia())) one.id,
      ],
      'getFavoriteMedia': [
        for (final one in ok(await repository.getFavoriteMedia())) one.id,
      ],
      'getMediaByTag(común)': [
        for (final one in ok(await repository.getMediaByTag(1))) one.id,
      ],
      'getMediaByTag(bloqueada)': [
        for (final one in ok(await repository.getMediaByTag(2))) one.id,
      ],
      'getMediaByCreator': [
        for (final one in ok(await repository.getMediaByCreator(1))) one.id,
      ],
      'getRecognizableMediaIds':
          ok(await repository.getRecognizableMediaIds(onlyUnrecognized: false)),
      'searchMedia': [
        for (final section in ok(await repository.searchMedia('a')))
          for (final one in section.media) one.id,
      ],
      'searchMediaBySuggestion': [
        for (final section
            in ok(await repository.searchMediaBySuggestion(suggestion)))
          for (final one in section.media) one.id,
      ],
      'searchMediaBySuggestion(etiqueta)': [
        for (final section
            in ok(await repository.searchMediaBySuggestion(tagSuggestion)))
          for (final one in section.media) one.id,
      ],
      'searchSuggestions': [
        for (final one in ok(await repository.searchSuggestions('a')))
          if (one.type == SearchResultType.media) one.id,
      ],
    };
  }

  /// Lo mismo con las etiquetas: sus nombres también delatan.
  Future<Map<String, List<int>>> everyTagReturned() async {
    List<int> flat(List<dynamic> tags) => [
          for (final tag in tags) ...[
            tag.id as int,
            ...flat(tag.children as List<dynamic>),
          ],
        ];

    return {
      'getTags': [for (final tag in ok(await repository.getTags())) tag.id],
      'getTagTree': flat(ok(await repository.getTagTree())),
      'searchTags': [
        for (final tag in ok(await repository.searchTags('o'))) tag.id,
      ],
    };
  }

  group('con el modo apagado', () {
    test('ningún método del repositorio devuelve contenido bloqueado', () async {
      final blocked = {blockedId, blockedByBranchId, scannedBlockedId, deletedBlockedId};

      for (final entry in (await everythingReturned()).entries) {
        expect(
          entry.value.toSet().intersection(blocked),
          isEmpty,
          reason: '${entry.key} ha colado contenido bloqueado',
        );
      }
    });

    test('lo que no está bloqueado sigue saliendo', () async {
      final returned = await everythingReturned();

      // La otra mitad de la prueba: un filtro que esconde la biblioteca entera
      // también pasaría la de arriba.
      expect(returned['getMediaList'], contains(visibleId));
      expect(returned['getFavoriteMedia'], contains(visibleId));
      expect(returned['getMediaByTag(común)'], contains(visibleId));
      expect(returned['getMediaByCreator'], contains(visibleId));
      expect(returned['searchMedia'], contains(visibleId));
    });

    test('ningún método devuelve etiquetas bloqueadas', () async {
      // La 2 está marcada y la 3 cuelga de ella.
      for (final entry in (await everyTagReturned()).entries) {
        expect(
          entry.value.toSet().intersection({2, 3}),
          isEmpty,
          reason: '${entry.key} ha colado una etiqueta bloqueada',
        );
      }
    });

    test('las etiquetas normales siguen estando', () async {
      for (final entry in (await everyTagReturned()).entries) {
        expect(entry.value, contains(1), reason: entry.key);
      }
    });

    // Los ancestros son la puerta de atrás más fácil de olvidar: se piden para
    // ponerle a un contenido la rama entera de lo que se le acaba de marcar, y
    // por ahí el nombre de la etiqueta bloqueada acaba en un diálogo.
    test('los ancestros bloqueados tampoco salen', () async {
      final branch = ok(await repository.getTagAncestors([
        const TagEntity(id: 3, name: 'prohibido de rama', children: []),
      ]));

      expect(branch, isEmpty);
    });

    test('los detalles de un contenido bloqueado no se sirven', () async {
      expect(
        await repository.getMediaDetails(blockedId),
        isA<DataException>(),
      );
    });

    test('una etiqueta bloqueada no se sirve por identificador', () async {
      final tag = await repository.getTag(2);

      expect((tag as DataSuccess).data, isNull);
    });
  });

  // La otra mitad de la función: marcar un contenido suelto, sin etiquetas de
  // por medio. Se pasa por el mismo barrido que lo marcado por etiqueta, porque
  // es la misma promesa y las fugas son las mismas.
  group('contenido marcado a mano', () {
    setUp(() async {
      // `visibleId` no lleva ninguna etiqueta marcada: lo único que lo esconde
      // es su propia marca.
      await repository.setMediaNsfw([visibleId], isNsfw: true);
    });

    test('no lo devuelve ningún método del repositorio', () async {
      for (final entry in (await everythingReturned()).entries) {
        expect(
          entry.value,
          isNot(contains(visibleId)),
          reason: '${entry.key} devuelve contenido marcado a mano',
        );
      }
    });

    test('sus detalles tampoco se sirven', () async {
      expect(
        await repository.getMediaDetails(visibleId),
        isNot(isA<DataSuccess>()),
      );
    });

    test('desmarcarlo lo devuelve a su sitio', () async {
      await repository.setMediaNsfw([visibleId], isNsfw: false);

      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      expect(ids, contains(visibleId));
    });

    test('se ve con el filtro quitado, como lo marcado por etiqueta', () async {
      await mode.unlock('la buena');

      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      expect(ids, contains(visibleId));
    });

    // Las dos marcas viven separadas: es lo que hace que desmarcar una etiqueta
    // no se lleve por delante lo que alguien escondió a mano.
    test('quitarle la marca no lo saca de una etiqueta marcada', () async {
      await repository.setMediaNsfw([blockedId], isNsfw: true);
      await repository.setMediaNsfw([blockedId], isNsfw: false);

      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      // Sigue escondido: lleva la etiqueta «prohibido».
      expect(ids, isNot(contains(blockedId)));
    });

    test('desmarcar la etiqueta no le quita la marca propia', () async {
      await repository.setMediaNsfw([blockedId], isNsfw: true);
      await repository.setTagNsfw(2, isNsfw: false);

      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      expect(ids, isNot(contains(blockedId)));
      // Y el que sólo estaba escondido por la etiqueta sí vuelve.
      expect(ids, contains(blockedByBranchId));
    });

    // El contenido que entra en una etiqueta ya marcada se esconde solo, sin
    // que nadie tenga que reescribir marcas.
    test('lo que no está marcado a mano sigue el criterio de su etiqueta',
        () async {
      expect(index.isMarkedByHand(blockedId), isFalse);
      expect(index.hasMedia(blockedId), isTrue);
    });

    test('marcar en tanda cuenta sólo lo que cambia', () async {
      // `visibleId` ya está marcado por el setUp.
      final result = await repository.setMediaNsfw(
        [visibleId, blockedByBranchId],
        isNsfw: true,
      );

      expect((result as DataSuccess<int>).data, 1);
    });
  });

  // Con el filtro quitado, las etiquetas marcadas vuelven a salir en el
  // buscador. Y entonces hay que poder reconocerlas: elegir una sin saber que
  // esconde contenido es filtrar por lo que no se quería.
  group('las sugerencias dicen qué etiqueta está marcada', () {
    setUp(() async => mode.unlock('la buena'));

    test('la marcada llega con su marca', () async {
      final suggestions = ok(await repository.searchSuggestions('prohibido'));
      final tags = suggestions
          .where((one) => one.type == SearchResultType.tag)
          .toList();

      expect(tags, isNotEmpty);
      expect(tags.every((one) => one.isNsfw), isTrue);
    });

    // La que cuelga de una marcada esconde contenido igual que su madre, y su
    // campo propio está en `false`: marcar sólo las propias dejaba a las hijas
    // escondiendo cosas sin avisar.
    test('la que hereda la marca también llega marcada', () async {
      final suggestions = ok(await repository.searchSuggestions('rama'));
      final branch = suggestions
          .where((one) => one.type == SearchResultType.tag)
          .toList();

      expect(branch, isNotEmpty);
      expect(branch.every((one) => one.isNsfw), isTrue);
    });

    test('y el árbol de etiquetas la trae también', () async {
      final tree = ok(await repository.getTagTree());

      List<TagEntity> flat(List<TagEntity> tags) => [
            for (final tag in tags) ...[tag, ...flat(tag.children)],
          ];

      final all = flat(tree);
      final marked = all.where((tag) => tag.isUnderNsfw).map((tag) => tag.id);

      // La marcada y la que cuelga de ella. El árbol se armaba a mano y se
      // dejaba la marca por el camino, así que el menú lateral no podía
      // distinguirlas.
      expect(marked, containsAll([2, 3]));
    });

    // El otro camino por el que salen etiquetas del repositorio: el buscador de
    // la ficha y el de asignar van por aquí, no por el árbol.
    test('las que devuelve el buscador de etiquetas también', () async {
      final found = ok(await repository.searchTags('prohibido'));

      expect(found, isNotEmpty);
      expect(found.every((tag) => tag.isUnderNsfw), isTrue);
    });

    test('y las que devuelve el listado', () async {
      final all = ok(await repository.getTags());
      final marked = all.where((tag) => tag.isUnderNsfw).map((tag) => tag.id);

      expect(marked, containsAll([2, 3]));
    });

    test('y la normal llega sin ella', () async {
      final suggestions = ok(await repository.searchSuggestions('común'));
      final tags = suggestions
          .where((one) => one.type == SearchResultType.tag)
          .toList();

      expect(tags, isNotEmpty);
      expect(tags.every((one) => one.isNsfw), isFalse);
    });
  });

  group('con el modo encendido', () {
    setUp(() async {
      expect(await mode.unlock('la buena'), UnlockOutcome.unlocked);
    });

    test('vuelve todo lo que estaba bloqueado', () async {
      final returned = await everythingReturned();

      expect(returned['getMediaList'], contains(blockedId));
      expect(returned['getMediaList'], contains(blockedByBranchId));
      expect(returned['getScannedMedia'], contains(scannedBlockedId));
      expect(returned['getDeletedMedia'], contains(deletedBlockedId));
    });

    test('y las etiquetas', () async {
      final returned = await everyTagReturned();

      expect(returned['getTags'], containsAll([2, 3]));
      expect(returned['getTagTree'], containsAll([2, 3]));
    });

    test('los detalles se sirven', () async {
      expect(await repository.getMediaDetails(blockedId), isA<DataSuccess>());
    });

    test('cerrarlo los vuelve a esconder sin tocar nada más', () async {
      mode.lock();

      final returned = await everythingReturned();

      expect(returned['getMediaList'], isNot(contains(blockedId)));
      expect(returned['getMediaList'], contains(visibleId));
    });
  });

  // Sin contraseña no hay forma de abrir el modo. Si marcar escondiera igual,
  // una etiqueta marcada por error dejaría contenido invisible y sin salida.
  group('sin contraseña puesta', () {
    setUp(() async {
      await mode.disable();
    });

    test('lo marcado se sigue viendo', () async {
      final returned = await everythingReturned();

      expect(returned['getMediaList'], containsAll([blockedId, blockedByBranchId]));
    });

    test('y sus etiquetas también', () async {
      expect((await everyTagReturned())['getTags'], containsAll([2, 3]));
    });
  });

  // Abrir el bloqueo puede querer decir «enséñamelo todo junto» o «ahora estoy
  // mirando sólo esto». Lo segundo convierte el modo en una biblioteca aparte.
  group('con el bloqueo abierto y sólo lo marcado', () {
    setUp(() async {
      showsOnlyMarked = true;
      expect(await mode.unlock('la buena'), UnlockOutcome.unlocked);
    });

    test('se ve lo marcado', () async {
      final returned = await everythingReturned();

      expect(
        returned['getMediaList'],
        containsAll([blockedId, blockedByBranchId]),
      );
    });

    test('y desaparece todo lo demás', () async {
      final returned = await everythingReturned();

      expect(returned['getMediaList'], isNot(contains(visibleId)));
      expect(returned['getFavoriteMedia'], isNot(contains(visibleId)));
      expect(returned['searchMedia'], isNot(contains(visibleId)));
    });

    // Un contenido marcado lleva puestas también etiquetas normales: esconder
    // sus nombres dejaría sin nombre a lo que se está viendo.
    test('las etiquetas se siguen viendo todas', () async {
      final returned = await everyTagReturned();

      expect(returned['getTags'], containsAll([1, 2, 3]));
    });

    test('cerrar el bloqueo devuelve la biblioteca de siempre', () async {
      mode.lock();

      final returned = await everythingReturned();

      expect(returned['getMediaList'], contains(visibleId));
      expect(returned['getMediaList'], isNot(contains(blockedId)));
    });
  });

  // Tapado en vez de escondido: la celda sigue en la rejilla, borrosa y con un
  // candado. Es más cómodo y deja ver que ahí hay algo, que es el precio.
  group('con el bloqueo cerrado y el contenido tapado', () {
    setUp(() => covers = true);

    test('lo marcado sigue apareciendo en las listas', () async {
      final returned = await everythingReturned();

      expect(
        returned['getMediaList'],
        containsAll([blockedId, blockedByBranchId]),
      );
    });

    test('la pantalla sabe que hay que taparlo', () {
      final visibility = NsfwVisibility(
        index: index,
        mode: mode,
        covers: () => covers,
      );

      expect(visibility.blursMedia(blockedId), isTrue);
      expect(visibility.blursMedia(visibleId), isFalse);
    });

    // Tapar es enseñar que existe, no dar permiso para verlo. Sin esto bastaría
    // abrir la celda de al lado y pasar a la siguiente con las flechas.
    test('abrirlo sigue estando prohibido', () async {
      expect(await repository.getMediaDetails(blockedId), isA<DataException>());
      expect(await repository.getMediaDetails(visibleId), isA<DataSuccess>());
    });

    // Un nombre no se puede tapar: o se lee o no está.
    test('las etiquetas marcadas siguen sin aparecer', () async {
      final returned = await everyTagReturned();

      expect(returned['getTags'], isNot(contains(2)));
      expect(returned['getTags'], contains(1));
    });

    test('sin contraseña puesta no se tapa nada', () async {
      await mode.disable();

      final visibility = NsfwVisibility(
        index: index,
        mode: mode,
        covers: () => covers,
      );

      expect(visibility.blursMedia(blockedId), isFalse);
    });
  });

  // Arrastrar a la rama es lo de fábrica, pero se puede apagar: hay jerarquías
  // donde la madre agrupa sin ser ella misma delicada.
  group('sin arrastrar a las hijas', () {
    setUp(() async {
      marksChildren = false;
      await index.rebuild();
    });

    test('la hija de una marcada deja de estarlo', () async {
      expect(index.hasTag(2), isTrue);
      expect(index.hasTag(3), isFalse);
    });

    test('y su contenido vuelve a verse', () async {
      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      expect(ids, contains(blockedByBranchId));
      // Lo de la etiqueta marcada sigue escondido: lo que cambia es hasta dónde
      // llega la marca, no si la hay.
      expect(ids, isNot(contains(blockedId)));
    });

    test('la hija se ve en las listas de etiquetas', () async {
      expect(ok(await repository.getTags()).map((tag) => tag.id), contains(3));
    });

    test('y no lleva el distintivo', () async {
      await mode.unlock('la buena');

      final tags = ok(await repository.getTags());
      final branch = tags.firstWhere((tag) => tag.id == 3);

      expect(branch.isUnderNsfw, isFalse);
    });

    // Volver a encenderlo lo deja como estaba: no se ha reescrito nada, así que
    // no hay nada que restaurar.
    test('volver a encenderlo la esconde otra vez', () async {
      marksChildren = true;
      await index.rebuild();

      expect(index.hasTag(3), isTrue);
      expect(index.hasMedia(blockedByBranchId), isTrue);
    });
  });

  // Desactivar el filtro tiene que dejar la biblioteca como si nunca hubiera
  // habido filtro. Lo que quede marcado no se nota mientras no hay contraseña
  // —sin ella no se esconde nada— y reaparece de golpe en cuanto alguien pone
  // otra, escondiendo contenido que nadie ha marcado esta vez.
  group('desactivar el filtro lo limpia todo', () {
    setUp(() async {
      await repository.setMediaNsfw([visibleId], isNsfw: true);
      await repository.clearNsfwMarks();
      await mode.disable();
    });

    test('no deja etiquetas marcadas', () async {
      final tags = await isar.tagModels.filter().isNsfwEqualTo(true).findAll();

      expect(tags, isEmpty);
    });

    test('ni contenido marcado a mano', () async {
      final marked = await isar.mediaSummaryModels
          .filter()
          .isNsfwEqualTo(true)
          .findAll();

      expect(marked, isEmpty);
    });

    test('y el índice se queda vacío', () {
      expect(index.isEmpty, isTrue);
    });

    // La prueba de verdad: poner contraseña otra vez no resucita nada.
    test('poner otra contraseña no esconde nada', () async {
      await mode.configure(password: 'la nueva');
      mode.lock();

      final ids = [
        for (final one in ok(await repository.getMediaList())) one.id,
      ];

      expect(ids, containsAll([visibleId, blockedId, blockedByBranchId]));
    });
  });

  group('la marca', () {
    test('bloquea también la rama de hijas', () async {
      // La 3 no está marcada: cuelga de la 2, que sí.
      expect(index.hasTag(3), isTrue);
      expect(index.hasMedia(blockedByBranchId), isTrue);
    });

    test('dice a cuántos contenidos afecta antes de que desaparezcan', () async {
      await repository.setTagNsfw(2, isNsfw: false);

      final affected = await repository.setTagNsfw(2, isNsfw: true);

      // Los cuatro que llevan la etiqueta o la de su rama, estén donde estén:
      // el pendiente de revisar desaparece de importación y el de la papelera
      // de la pantalla de eliminados, y quien marca quiere saber el total.
      expect((affected as DataSuccess<int>).data, 4);
    });

    test('quitarla devuelve el contenido a la vista', () async {
      await repository.setTagNsfw(2, isNsfw: false);

      final returned = await everythingReturned();

      expect(returned['getMediaList'], containsAll([blockedId, blockedByBranchId]));
    });

    // Mover una etiqueta de rama cambia el bloqueo de todo lo que cuelga sin
    // que nadie reescriba una sola marca. Es lo que la propagación en lectura
    // compra, y si el índice no se entera no vale de nada.
    test('mover una etiqueta bajo una marcada bloquea lo suyo', () async {
      final free = TagModel(id: 4, name: 'libre');
      await isar.writeTxn(() => isar.tagModels.put(free));

      final media = MediaModel(id: 6, path: 'C:/seis.jpg')
        ..downloaded = DateTime(2026)
        ..isFavorite = false;

      await isar.writeTxn(() async {
        await isar.mediaModels.put(media);
        await isar.mediaSummaryModels.put(
          MediaSummaryModel()
            ..id = 6
            ..path = 'C:/seis.jpg'
            ..isImported = true,
        );
        await media.tags.update(link: [free]);
      });

      await index.rebuild();
      expect(index.hasMedia(6), isFalse);

      final blockedTag = (await repository.getTags() as DataSuccess).data!;
      expect(blockedTag.map((tag) => tag.id), contains(4));

      // Y ahora cuelga de la marcada.
      await repository.updateTag(
        (await isar.tagModels.get(4))!.toEntity(),
        parent: (await isar.tagModels.get(2))!.toEntity(),
      );

      expect(index.hasMedia(6), isTrue);
    });
  });
}

/// La biblioteca de prueba: una etiqueta normal, una marcada y una que cuelga de
/// la marcada, con contenido en cada estado por el que puede pasar.
Future<void> _seed(Isar isar) async {
  final common = TagModel(id: 1, name: 'común');
  final blocked = TagModel(id: 2, name: 'prohibido', isNsfw: true);
  final branch = TagModel(id: 3, name: 'prohibido de rama');

  final creator = CreatorModel(id: 1, name: 'alguien');

  await isar.writeTxn(() async {
    await isar.tagModels.putAll([common, blocked, branch]);
    await isar.creatorModels.put(creator);

    blocked.children.add(branch);
    await blocked.children.save();
  });

  Future<void> media(
    int id, {
    required List<TagModel> tags,
    bool isImported = true,
    bool isDeleted = false,
  }) async {
    final details = MediaModel(id: id, path: 'C:/$id.jpg')
      ..downloaded = DateTime(2026)
      ..isFavorite = true
      ..description = 'archivo $id';

    await isar.writeTxn(() async {
      await isar.mediaModels.put(details);
      await isar.mediaSummaryModels.put(
        MediaSummaryModel()
          ..id = id
          ..path = 'C:/$id.jpg'
          ..isImported = isImported
          ..isDeleted = isDeleted
          ..deletedAt = isDeleted ? DateTime(2026) : null,
      );

      details.creator.value = creator;
      await details.creator.save();
      await details.tags.update(link: tags);
    });
  }

  await media(visibleId, tags: [common]);
  await media(blockedId, tags: [common, blocked]);
  await media(blockedByBranchId, tags: [branch]);
  await media(scannedBlockedId, tags: [blocked], isImported: false);
  await media(deletedBlockedId, tags: [blocked], isDeleted: true);
}

/// Lo del modo NSFW, en memoria.
class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: 'reconocimiento',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// La primera `isar.dll` que haya a mano: la de la aplicación compilada o, si
/// todavía no se ha compilado, la que trae el paquete.
String? _isarLibrary() {
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';

  final candidates = [
    r'build\windows\x64\runner\Debug\isar.dll',
    r'build\windows\x64\runner\Release\isar.dll',
    '$pubCache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }
  return null;
}
