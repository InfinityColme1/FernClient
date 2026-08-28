// Lo que el contenido repetido guarda y lo que respeta.
//
// Contra una base de datos de verdad porque lo que importa es lo que sobrevive
// entre escaneos: que guardar lo que acaba de encontrarse **no resucite** lo que
// el usuario ya contestó. Sin eso, el mismo falso positivo vuelve a aparecer cada
// mes y el aviso del menú deja de significar nada.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:Fern/features/duplicates/data/repositories/duplicate_repository_impl.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late DuplicateRepositoryImpl repository;
  late Map<String, DateTime?> modified;

  /// Lo que el filtro esconde ahora mismo.
  late Set<int> hidden;

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
    directory = await Directory.systemTemp.createTemp('fern_duplicates_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        DuplicateGroupModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    modified = {};
    hidden = {};
    repository = DuplicateRepositoryImpl(
      database: isar,
      modifiedAt: (path) => modified[path],
      visibility: _Hiding(() => hidden),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<int> addMedia(
    int id, {
    bool isDeleted = false,
    int? dHash,
    int? pHash,
    DateTime? hashedAt,
  }) async {
    final summary = MediaSummaryModel()
      ..id = id
      ..path = 'C:/media/$id.jpg'
      ..isDeleted = isDeleted
      ..perceptualHash = dHash
      ..dctHash = pHash
      ..hashedAt = hashedAt;

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));

    return id;
  }

  /// Manda una copia a la papelera, que es lo que hace resolver un grupo.
  Future<void> trash(int id) async {
    final summary = await isar.mediaSummaryModels.get(id);
    summary!.isDeleted = true;

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));
  }

  ReconciledGroup found(List<int> ids, {int distance = 0}) => ReconciledGroup(
        group: DuplicateGroup(mediaIds: ids, maxDistance: distance),
        outcome: GroupOutcome.fresh,
      );

  /// Un grupo de contenidos que existen y están vivos.
  ///
  /// Crearlos hace falta: un grupo cuyas copias ya no están no se propone, que es
  /// justo lo que evita ofrecer «conservar» una copia que está en la papelera.
  Future<ReconciledGroup> liveGroup(List<int> ids, {int distance = 0}) async {
    for (final id in ids) {
      if (await isar.mediaSummaryModels.get(id) == null) await addMedia(id);
    }

    return found(ids, distance: distance);
  }

  group('a quién hay que mirar', () {
    test('a los contenidos vivos', () async {
      await addMedia(1);
      await addMedia(2);

      final result = await repository.getHashable();

      expect(result.data, hasLength(2));
    });

    test('no a lo que está en la papelera', () async {
      await addMedia(1);
      await addMedia(2, isDeleted: true);

      // Lo que ya se ha tirado no puede ser el duplicado de nada, y decodificarlo
      // sería trabajo para nada.
      expect(result(await repository.getHashable()).single.mediaId, 1);
    });

    test('llega con la fecha del fichero', () async {
      await addMedia(1);
      modified['C:/media/1.jpg'] = DateTime(2026, 8, 23);

      expect(
        result(await repository.getHashable()).single.fileModifiedAt,
        DateTime(2026, 8, 23),
      );
    });
  });

  group('guardar los hashes', () {
    test('los deja puestos y apunta cuándo', () async {
      await addMedia(1);

      await repository.saveHashes(
        1,
        const PerceptualHashes(dHash: 111, pHash: 222),
      );

      final summary = await isar.mediaSummaryModels.get(1);

      expect(summary!.perceptualHash, 111);
      expect(summary.dctHash, 222);
      expect(summary.hashedAt, isNotNull);
    });

    test('un contenido que no existe se dice', () async {
      expect(
        await repository.saveHashes(
          999,
          const PerceptualHashes(dHash: 1, pHash: 2),
        ),
        isA<DataException>(),
      );
    });
  });

  group('empezar de cero', () {
    test('quita las huellas de todo lo que las tenía', () async {
      await addMedia(1, dHash: 10, pHash: 20, hashedAt: DateTime(2026));
      await addMedia(2, dHash: 30, pHash: 40, hashedAt: DateTime(2026));

      expect(cleared(await repository.clearHashes()), 2);

      final summary = await isar.mediaSummaryModels.get(1);
      expect(summary!.perceptualHash, isNull);
      expect(summary.dctHash, isNull);
      expect(summary.hashedAt, isNull);
    });

    test('lo que nunca las tuvo no se cuenta', () async {
      await addMedia(1, dHash: 10, pHash: 20, hashedAt: DateTime(2026));
      await addMedia(2);

      expect(cleared(await repository.clearHashes()), 1);
    });

    test('sin nada hasheado no falla', () async {
      await addMedia(1);

      expect(cleared(await repository.clearHashes()), 0);
    });

    // Los grupos que el usuario ya contestó son decisión suya. Borrarlos aquí
    // haría reaparecer en el escaneo siguiente todo lo que ya había descartado.
    test('los grupos ya contestados se quedan como estaban', () async {
      await addMedia(1, dHash: 10, pHash: 20, hashedAt: DateTime(2026));
      await addMedia(2, dHash: 10, pHash: 20, hashedAt: DateTime(2026));
      await repository.saveGroups([found([1, 2])]);

      final groups = result(await repository.getKnownGroups());
      await repository.clearHashes();

      expect(result(await repository.getKnownGroups()), hasLength(groups.length));
    });

    test('después no queda nadie a quien comparar', () async {
      await addMedia(1, dHash: 10, pHash: 20, hashedAt: DateTime(2026));

      await repository.clearHashes();

      expect(result(await repository.getHashed()), isEmpty);
    });
  });

  group('a quién comparar', () {
    test('sólo a lo que ya tiene hash', () async {
      await addMedia(1, dHash: 10, pHash: 20);
      await addMedia(2);

      expect(result(await repository.getHashed()).single.mediaId, 1);
    });

    test('tampoco lo de la papelera', () async {
      await addMedia(1, dHash: 10, pHash: 20, isDeleted: true);

      expect(result(await repository.getHashed()), isEmpty);
    });
  });

  group('guardar lo encontrado', () {
    test('un grupo nuevo se guarda y se cuenta', () async {
      final saved = await repository.saveGroups([await liveGroup([1, 2])]);

      expect(saved.data, 1);
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    test('el mismo grupo otra vez no se duplica', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final second = await repository.saveGroups([await liveGroup([1, 2])]);

      expect(second.data, 0);
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    test('lo descartado no vuelve', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;

      await repository.markDismissed(group.id);
      await repository.saveGroups([await liveGroup([1, 2])]);

      // Es lo único que evita que el mismo falso positivo vuelva cada mes, y con
      // él el aviso que nadie mira ya.
      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    test('lo resuelto tampoco', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;

      // Como se resuelve de verdad: una se queda y la otra se va a la
      // papelera. Mientras eso siga así, no hay nada que volver a preguntar.
      await repository.markResolved(group.id);
      await trash(2);

      await repository.saveGroups([found([1, 2])]);

      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    // El caso que dejaba dos copias iguales dentro para siempre: el
    // identificador de un contenido es el hash de su ruta, así que borrarlo de
    // la biblioteca y volver a importarlo lo devuelve con el mismo. El grupo
    // volvía a coincidir letra por letra con uno ya resuelto y se tragaba el
    // hallazgo sin decir nada.
    test('borrar las copias y volver a importarlas se vuelve a preguntar',
        () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;

      await repository.markResolved(group.id);
      await trash(2);
      expect(result(await repository.getGroupsToReview()), isEmpty);

      // Fuera las dos de la base de datos, y otra vez dentro: mismas rutas,
      // mismos identificadores, contenido recién llegado.
      await isar.writeTxn(() => isar.mediaSummaryModels.deleteAll([1, 2]));
      await addMedia(1);
      await addMedia(2);

      final saved = await repository.saveGroups([found([1, 2])]);

      // Y se cuenta como hallazgo, que es lo que dispara el aviso: quien
      // reimportó no está mirando la pantalla de repetidos.
      expect(saved.data, 1);
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    test('sacar una copia de la papelera reabre la decisión', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;

      await repository.markResolved(group.id);
      await trash(2);

      final restored = await isar.mediaSummaryModels.get(2);
      restored!.isDeleted = false;
      await isar.writeTxn(() => isar.mediaSummaryModels.put(restored));

      await repository.saveGroups([found([1, 2])]);

      // Vuelve a haber dos iguales: la respuesta de entonces ya no describe lo
      // que hay.
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    // «No son duplicados» no es una decisión sobre estas copias, es un juicio
    // sobre las imágenes. Reabrirlo al reimportar devolvería el mismo falso
    // positivo cada vez, que es lo que toda esta parte existe para evitar.
    test('lo descartado no se reabre aunque vuelvan las dos copias', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;

      await repository.markDismissed(group.id);

      await isar.writeTxn(() => isar.mediaSummaryModels.deleteAll([1, 2]));
      await addMedia(1);
      await addMedia(2);

      final saved = await repository.saveGroups([found([1, 2])]);

      expect(saved.data, 0);
      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    test('con tres copias, una viva no reabre nada', () async {
      await repository.saveGroups([await liveGroup([1, 2, 3])]);
      final group = result(await repository.getGroupsToReview()).single;

      await repository.markResolved(group.id);
      await trash(2);
      await trash(3);

      final saved = await repository.saveGroups([found([1, 2, 3])]);

      expect(saved.data, 0);
      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    test('la distancia sí se pone al día', () async {
      await repository.saveGroups([await liveGroup([1, 2], distance: 6)]);
      await repository.saveGroups([await liveGroup([1, 2], distance: 2)]);

      // Los hashes se pueden recalcular: el grupo es el mismo, pero lo lejos que
      // están es lo que se acaba de medir.
      expect(result(await repository.getGroupsToReview()).single.maxDistance, 2);
    });
  });

  group('lo que ya no se puede decidir', () {
    // El caso que perdía contenido: el grupo seguía proponiéndose con la copia
    // borrada dentro, y conservar ésa mandaba a la papelera la única que
    // quedaba viva.
    test('un grupo con una copia en la papelera no se propone', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      final trashed = await isar.mediaSummaryModels.get(2);
      trashed!.isDeleted = true;
      await isar.writeTxn(() => isar.mediaSummaryModels.put(trashed));

      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    test('un grupo con una copia que ya no existe tampoco', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      await isar.writeTxn(() => isar.mediaSummaryModels.delete(2));

      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    // Se esconde, no se borra: de la papelera se vuelve durante siete días, y
    // con la copia tiene que volver la decisión.
    test('vuelve si la copia sale de la papelera', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      final one = await isar.mediaSummaryModels.get(2);
      one!.isDeleted = true;
      await isar.writeTxn(() => isar.mediaSummaryModels.put(one));
      expect(result(await repository.getGroupsToReview()), isEmpty);

      one.isDeleted = false;
      await isar.writeTxn(() => isar.mediaSummaryModels.put(one));

      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    test('con tres copias y una tirada, la decisión sigue en pie', () async {
      await repository.saveGroups([await liveGroup([1, 2, 3])]);

      final one = await isar.mediaSummaryModels.get(3);
      one!.isDeleted = true;
      await isar.writeTxn(() => isar.mediaSummaryModels.put(one));

      // Quedan dos vivas: todavía hay algo que elegir.
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });
  });

  // Comparar dos copias es abrirlas, así que un grupo cuyo contenido esconde el
  // filtro NSFW no es una decisión que se pueda tomar. Y enseñarlo cuenta que
  // ese contenido existe, que es justo lo que el filtro evita.
  group('lo que el filtro esconde', () {
    test('un grupo con el contenido escondido no se propone', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      hidden = {2};

      expect(result(await repository.getGroupsToReview()), isEmpty);
    });

    test('vuelve al quitar el filtro', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      hidden = {2};
      expect(result(await repository.getGroupsToReview()), isEmpty);

      hidden = {};
      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    test('con tres copias y una escondida, la decisión sigue en pie', () async {
      await repository.saveGroups([await liveGroup([1, 2, 3])]);

      hidden = {3};

      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    // El caso que separa «vivas» de «comparables»: un grupo resuelto vuelve a
    // abrirse cuando sus copias siguen vivas —alguien las sacó de la papelera—
    // y eso no puede depender de si el filtro las esconde ahora mismo. Con el
    // filtro puesto no se propondrá igualmente, pero al quitarlo tiene que estar
    // ahí, no haberse perdido.
    test('un grupo resuelto se reabre aunque el filtro lo esconda', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;
      await repository.markResolved(group.id);

      hidden = {2};
      await repository.saveGroups([await liveGroup([1, 2])]);

      hidden = {};

      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });

    // Guardar lo encontrado no mira el filtro, sólo si las copias siguen vivas.
    // Si lo mirara, poner o quitar el filtro cambiaría lo que un escaneo decide
    // sobre grupos que el usuario ya contestó.
    test('guardar un escaneo no depende del filtro', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;
      await repository.markDismissed(group.id);

      hidden = {2};
      await repository.saveGroups([await liveGroup([1, 2])]);

      hidden = {};

      // Sigue descartado: el filtro no lo ha resucitado.
      expect(result(await repository.getGroupsToReview()), isEmpty);
    });
  });

  group('retirar lo que ya no se encuentra', () {
    // Sin esto la lista sólo crecía: al aparecer una copia más, el grupo pasa a
    // ser otro y el anterior se quedaba enseñando lo mismo por segunda vez.
    test('al aparecer una copia más, el grupo viejo se va', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);

      await repository.saveGroups(
        [await liveGroup([1, 2, 3])],
        retireUnseen: true,
      );

      final groups = result(await repository.getGroupsToReview());

      expect(groups, hasLength(1));
      expect(groups.single.mediaIds, [1, 2, 3]);
    });

    // Es lo que hace que bajar el listón sirva de algo: lo que ya no lo cumple
    // desaparece de la lista en vez de quedarse para siempre.
    test('lo que un escaneo más estricto ya no ve se retira', () async {
      await repository.saveGroups([
        await liveGroup([1, 2], distance: 7),
        await liveGroup([3, 4], distance: 2),
      ]);

      await repository.saveGroups(
        [await liveGroup([3, 4], distance: 2)],
        retireUnseen: true,
      );

      expect(
        result(await repository.getGroupsToReview()).single.mediaIds,
        [3, 4],
      );
    });

    test('sin pedirlo no se retira nada', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      await repository.saveGroups([await liveGroup([3, 4])]);

      expect(result(await repository.getGroupsToReview()), hasLength(2));
    });

    // Lo contestado se guarda justamente para que no vuelva a proponerse.
    // Borrarlo aquí resucitaría el mismo falso positivo en el escaneo siguiente.
    test('lo descartado no se retira, aunque no se vuelva a encontrar', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;
      await repository.markDismissed(group.id);

      await repository.saveGroups(
        [await liveGroup([3, 4])],
        retireUnseen: true,
      );

      // Sigue guardado: se comprueba porque al volver a encontrarlo no revive.
      await repository.saveGroups([await liveGroup([1, 2])]);

      expect(
        result(await repository.getGroupsToReview()).single.mediaIds,
        [3, 4],
      );
    });

    test('lo resuelto tampoco se retira', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;
      await repository.markResolved(group.id);
      await trash(2);

      await repository.saveGroups(const [], retireUnseen: true);

      final known = result(await repository.getKnownGroups()).single;
      expect(known.mediaIds, [1, 2]);
      expect(known.isResolved, isTrue);

      // Y volver a encontrarlo no lo cuenta como hallazgo: si se hubiera
      // retirado, entraría de nuevo como si nadie lo hubiera contestado.
      final saved = await repository.saveGroups([found([1, 2])]);
      expect(saved.data, 0);
    });
  });

  group('qué se enseña', () {
    test('lo idéntico primero', () async {
      await repository.saveGroups([
        await liveGroup([1, 2], distance: 7),
        await liveGroup([3, 4]),
        await liveGroup([5, 6], distance: 3),
      ]);

      expect(
        [for (final one in result(await repository.getGroupsToReview())) one.maxDistance],
        [0, 3, 7],
      );
    });

    test('lo ya contestado no está', () async {
      await repository.saveGroups([await liveGroup([1, 2]), await liveGroup([3, 4])]);

      final groups = result(await repository.getGroupsToReview());
      await repository.markDismissed(groups.first.id);

      expect(result(await repository.getGroupsToReview()), hasLength(1));
    });
  });

  group('lo que ya se sabía', () {
    test('vuelve con su estado', () async {
      await repository.saveGroups([await liveGroup([1, 2])]);
      final group = result(await repository.getGroupsToReview()).single;
      await repository.markDismissed(group.id);

      final known = result(await repository.getKnownGroups()).single;

      expect(known.mediaIds, [1, 2]);
      expect(known.isDismissed, isTrue);
    });

    test('un grupo que no existe no se puede marcar', () async {
      expect(await repository.markResolved(999), isA<DataException>());
    });
  });
}

/// Cuántas huellas se han borrado, dando por hecho que salió bien.
int cleared(DataState<int> state) {
  expect(state, isA<DataSuccess<int>>());

  return state.data!;
}

/// Los datos de un resultado, dando por hecho que salió bien.
List<T> result<T>(DataState<List<T>> state) {
  expect(state, isA<DataSuccess<List<T>>>());

  return state.data!;
}

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

/// Un filtro que esconde lo que se le diga en cada momento.
class _Hiding extends ContentVisibility {
  final Set<int> Function() _hidden;

  const _Hiding(this._hidden);

  @override
  bool hidesDetails(int mediaId) => _hidden().contains(mediaId);
}
