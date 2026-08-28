// El filtro NSFW también tapa fernies y modelos.
//
// Es el agujero que tenía la fase 7: se quitaba el filtro, se recortaban unos
// fernies sobre el contenido marcado y, con el filtro puesto otra vez, la
// pantalla de fernies lo volvía a enseñar. Marcar etiquetas no servía de nada.
//
// Aquí se prueban las dos mitades del arreglo, y la segunda importa tanto como
// la primera:
//
// - **Lo que se ve.** Los casos de uso —que es por donde lee la interfaz— no
//   devuelven nada escondido.
// - **Lo que se hace.** Los repositorios —que es por donde lee el entrenamiento
//   y el reconocimiento— lo siguen devolviendo todo. Un fernie marcado tiene que
//   seguir entrenando y un modelo marcado tiene que seguir ejecutándose, o
//   esconder algo sería romperlo.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/repositories/fernie_repository_impl.dart';
import 'package:Fern/features/recognition/data/repositories/model_repository_impl.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_of_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_models_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/search_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_usecase.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// La biblioteca de prueba, con identificadores fijos para poder nombrarlos.
const visibleMediaId = 1;
const blockedMediaId = 2;

const blockedTagId = 1;

const plainFernieId = 1;
const markedFernieId = 2;
const linkedFernieId = 3;

const plainModelId = 1;
const markedModelId = 2;

void main() {
  late Directory directory;
  late Isar isar;
  late NsfwIndex index;
  late NsfwModeService mode;
  late NsfwVisibility visibility;
  late FernieRepositoryImpl fernies;
  late ModelRepositoryImpl models;

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
    directory = await Directory.systemTemp.createTemp('fern_nsfw_recog_test');
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
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    index = NsfwIndex(database: isar, hierarchy: TagHierarchy(database: isar));

    // Pocas vueltas al derivar: aquí no se prueba lo que cuesta una contraseña.
    mode = NsfwModeService(
      storage: _MemoryStorage(),
      passwords: PasswordService(iterations: 64),
    );

    visibility = NsfwVisibility(index: index, mode: mode);

    fernies = FernieRepositoryImpl(
      database: isar,
      avatarStorage:
          AvatarStorageService(settingsRepository: _Settings(avatars.path)),
      onNsfwChanged: index.rebuild,
    );

    models = ModelRepositoryImpl(database: isar, onNsfwChanged: index.rebuild);

    await _seed(isar);
    await index.rebuild();

    // Con contraseña puesta y el filtro cerrado, que es la situación que hay que
    // probar: sin contraseña no se esconde nada a propósito.
    await mode.configure(password: 'la buena');
    mode.lock();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  List<T> ok<T>(DataState<List<T>> state) => (state as DataSuccess<List<T>>).data!;

  List<int> idsOf(List<FernieEntity> list) => [for (final one in list) one.id];

  // ---------------------------------------------------------------------------
  // Fernies
  // ---------------------------------------------------------------------------

  group('un fernie marcado', () {
    test('no sale por ninguna de las lecturas de la interfaz', () async {
      final all = GetFerniesUseCase(fernies, visibility: visibility);
      final search = SearchFerniesUseCase(fernies, visibility: visibility);
      final ofMedia = GetFerniesOfMediaUseCase(fernies, visibility: visibility);
      final one = GetFernieUseCase(fernies, visibility: visibility);

      expect(idsOf(ok(await all())), isNot(contains(markedFernieId)));
      expect(
        idsOf(ok(await search(params: 'marcado'))),
        isNot(contains(markedFernieId)),
      );
      expect(
        idsOf(ok(await ofMedia(params: visibleMediaId))),
        isNot(contains(markedFernieId)),
      );
      expect(await one(params: markedFernieId), isA<DataException>());
    });

    test('sigue estando entero para quien entrena', () async {
      // La otra mitad del arreglo: por el repositorio se ve todo. Si esto se
      // pusiera en rojo, marcar un fernie dejaría a sus modelos entrenando con
      // una clase menos y sin decírselo a nadie.
      expect(idsOf(ok(await fernies.getFernies())), contains(markedFernieId));

      final assignments = ok(await models.getFerniesOfModel(plainModelId));
      expect(
        [for (final one in assignments) one.fernie.id],
        contains(markedFernieId),
      );
    });

    test('no se lista entre los del modelo, pero sigue asignado', () async {
      final ofModel = GetFerniesOfModelUseCase(models, visibility: visibility);

      final shown = ok(await ofModel(params: plainModelId));
      expect(
        [for (final one in shown) one.fernie.id],
        isNot(contains(markedFernieId)),
      );

      // Y su número de clase no se ha tocado: los pesos entrenados lo conocen
      // por ese número.
      final stored = ok(await models.getFerniesOfModel(plainModelId));
      final marked = stored.firstWhere((one) => one.fernie.id == markedFernieId);
      expect(marked.classIndex, isNotNull);
    });

    test('vuelve en cuanto se quita el filtro', () async {
      await mode.unlock('la buena');

      final all = GetFerniesUseCase(fernies, visibility: visibility);
      expect(idsOf(ok(await all())), contains(markedFernieId));
    });

    test('sus regiones no se pintan sobre el contenido', () async {
      final regions = GetRegionsOfMediaUseCase(fernies, visibility: visibility);

      final shown = ok(await regions(params: visibleMediaId));
      expect(
        [for (final one in shown) one.fernieId],
        isNot(contains(markedFernieId)),
      );
    });
  });

  group('un fernie enlazado a una etiqueta marcada', () {
    test('se esconde sin haberlo marcado', () async {
      // Es la trampa más fácil: la etiqueta está marcada, así que el fernie que
      // la propone dice lo mismo con otro nombre.
      final all = GetFerniesUseCase(fernies, visibility: visibility);

      expect(idsOf(ok(await all())), isNot(contains(linkedFernieId)));
    });

    test('y vuelve solo al desmarcar la etiqueta', () async {
      await isar.writeTxn(() async {
        final tag = await isar.tagModels.get(blockedTagId);
        tag!.isNsfw = false;
        await isar.tagModels.put(tag);
      });

      await index.rebuild();

      final all = GetFerniesUseCase(fernies, visibility: visibility);
      expect(idsOf(ok(await all())), contains(linkedFernieId));
    });
  });

  test('enlazar con una etiqueta marcada deja el fernie marcado', () async {
    // Y marcado de verdad, no sólo escondido: es lo que enciende el interruptor
    // de la ficha y saca el distintivo en la lista, así que el usuario ve lo que
    // acaba de pasar en vez de que su fernie desaparezca sin explicación.
    final update = UpdateFernieUseCase(fernies, visibility: visibility);

    final before = (await fernies.getFernie(plainFernieId) as DataSuccess).data!;
    expect(before.isNsfw, isFalse);

    final saved = await update(
      params: before.copyWith(linkedTagId: blockedTagId),
    );

    expect((saved as DataSuccess).data!.isNsfw, isTrue);

    // Y se esconde en el acto: el índice se rehace desde el repositorio, sin que
    // la pantalla tenga que pedirlo.
    final all = GetFerniesUseCase(fernies, visibility: visibility);
    expect(idsOf(ok(await all())), isNot(contains(plainFernieId)));
  });

  test('enlazar con una etiqueta normal no marca nada', () async {
    final update = UpdateFernieUseCase(fernies, visibility: visibility);

    final plainTag = TagModel(id: 99, name: 'normal');
    await isar.writeTxn(() => isar.tagModels.put(plainTag));

    final before = (await fernies.getFernie(plainFernieId) as DataSuccess).data!;
    final saved = await update(params: before.copyWith(linkedTagId: 99));

    expect((saved as DataSuccess).data!.isNsfw, isFalse);
  });

  test('la rejilla de un fernie no enseña contenido escondido', () async {
    // El fernie está a la vista —nadie lo ha marcado— y aun así sus recortes
    // sobre contenido marcado no se pintan: la celda **es** un trozo del
    // fichero.
    final ofFernie = GetMediaOfFernieUseCase(fernies, visibility: visibility);

    final shown = ok(await ofFernie(params: plainFernieId));
    expect(
      [for (final one in shown) one.media.id],
      isNot(contains(blockedMediaId)),
    );
    expect([for (final one in shown) one.media.id], contains(visibleMediaId));

    // Y por el repositorio siguen estando las dos: el conjunto de datos se
    // arma con todo.
    final stored = ok(await fernies.getMediaOfFernie(plainFernieId));
    expect(
      [for (final one in stored) one.media.id],
      containsAll([visibleMediaId, blockedMediaId]),
    );
  });

  // ---------------------------------------------------------------------------
  // Modelos
  // ---------------------------------------------------------------------------

  group('un modelo con todas sus clases marcadas', () {
    test('se esconde sin haberlo marcado', () async {
      // El modelo normal aprende un fernie marcado y uno que no, así que se ve.
      final all = GetModelsUseCase(models, visibility: visibility);
      expect(
        [for (final model in ok(await all())) model.id],
        contains(plainModelId),
      );

      // Se marca también el otro: ahora el modelo no habla más que de lo
      // escondido —su nombre, su cara y sus recuentos son los de esas clases— y
      // deja de verse.
      await fernies.setFernieNsfw(plainFernieId, isNsfw: true);

      expect(
        [for (final model in ok(await all())) model.id],
        isNot(contains(plainModelId)),
      );
    });

    test('vuelve en cuanto recupera una clase normal', () async {
      await fernies.setFernieNsfw(plainFernieId, isNsfw: true);
      await fernies.setFernieNsfw(plainFernieId, isNsfw: false);

      final all = GetModelsUseCase(models, visibility: visibility);
      expect(
        [for (final model in ok(await all())) model.id],
        contains(plainModelId),
      );
    });

    test('y también al meterle una clase normal nueva', () async {
      await fernies.setFernieNsfw(plainFernieId, isNsfw: true);

      final all = GetModelsUseCase(models, visibility: visibility);
      expect(
        [for (final model in ok(await all())) model.id],
        isNot(contains(plainModelId)),
      );

      // Sin tocar ninguna marca: lo que cambia es de qué habla el modelo, y el
      // repositorio rehace el índice al asignar.
      await fernies.saveFernie(FernieEntity(id: unsavedId, name: 'nuevo'));
      final fresh = ok(await fernies.getFernies())
          .firstWhere((one) => one.name == 'nuevo');

      await models.assignFernie(modelId: plainModelId, fernieId: fresh.id);

      expect(
        [for (final model in ok(await all())) model.id],
        contains(plainModelId),
      );
    });

    test('un modelo sin clases no se esconde por su cuenta', () async {
      // No habla de nada todavía: esconderlo sería esconder una ficha vacía.
      await isar.writeTxn(() async {
        await isar.recognitionModelModels.put(
          RecognitionModelModel()
            ..id = 3
            ..name = 'vacío',
        );
      });

      await index.rebuild();

      final all = GetModelsUseCase(models, visibility: visibility);
      expect([for (final model in ok(await all())) model.id], contains(3));
    });

    test('y sigue entrenando con todo lo que tiene', () async {
      await fernies.setFernieNsfw(plainFernieId, isNsfw: true);

      // Escondido de la vista, entero para el entrenamiento: sus dos clases
      // siguen ahí con su número.
      final assignments = ok(await models.getFerniesOfModel(plainModelId));
      expect(assignments, hasLength(2));
    });
  });

  group('un modelo marcado', () {
    test('no sale en la rejilla ni se puede abrir', () async {
      final all = GetModelsUseCase(models, visibility: visibility);
      final one = GetModelUseCase(models, visibility: visibility);

      final shown = ok(await all());
      expect(
        [for (final model in shown) model.id],
        isNot(contains(markedModelId)),
      );
      expect(await one(params: markedModelId), isA<DataException>());
    });

    test('sigue existiendo entero para el reconocimiento', () async {
      final stored = ok(await models.getModels());

      expect([for (final model in stored) model.id], contains(markedModelId));

      final marked =
          stored.firstWhere((model) => model.id == markedModelId);
      expect(marked.weightsPath, isNotNull);
      expect(marked.isNsfw, isTrue);
    });

    test('vuelve en cuanto se quita el filtro', () async {
      await mode.unlock('la buena');

      final all = GetModelsUseCase(models, visibility: visibility);
      expect(
        [for (final model in ok(await all())) model.id],
        contains(markedModelId),
      );
    });
  });

  test('marcar y desmarcar rehace el índice sin que nadie lo pida', () async {
    final all = GetModelsUseCase(models, visibility: visibility);

    expect(
      [for (final model in ok(await all())) model.id],
      contains(plainModelId),
    );

    await models.setModelNsfw(plainModelId, isNsfw: true);
    expect(
      [for (final model in ok(await all())) model.id],
      isNot(contains(plainModelId)),
    );

    await models.setModelNsfw(plainModelId, isNsfw: false);
    expect(
      [for (final model in ok(await all())) model.id],
      contains(plainModelId),
    );
  });

  test('sin contraseña puesta no se esconde nada', () async {
    // La salvaguarda de siempre: marcar sin contraseña no puede dejar cosas
    // escondidas sin forma de sacarlas.
    await mode.disable();

    final all = GetFerniesUseCase(fernies, visibility: visibility);
    final everyModel = GetModelsUseCase(models, visibility: visibility);

    expect(idsOf(ok(await all())), contains(markedFernieId));
    expect(
      [for (final model in ok(await everyModel())) model.id],
      contains(markedModelId),
    );
  });
}

/// La biblioteca de prueba: dos contenidos (uno marcado), tres fernies (uno
/// marcado, uno enlazado a la etiqueta marcada) y dos modelos (uno marcado).
Future<void> _seed(Isar isar) async {
  final blockedTag = TagModel(id: blockedTagId, name: 'prohibido', isNsfw: true);

  await isar.writeTxn(() async {
    await isar.tagModels.put(blockedTag);

    for (final id in [visibleMediaId, blockedMediaId]) {
      await isar.mediaModels.put(
        MediaModel(id: id, path: 'C:/$id.jpg')
          ..downloaded = DateTime(2026)
          ..isFavorite = false,
      );
      await isar.mediaSummaryModels.put(
        MediaSummaryModel()
          ..id = id
          ..path = 'C:/$id.jpg'
          ..isImported = true,
      );
    }

    final blocked = await isar.mediaModels.get(blockedMediaId);
    await blocked!.tags.update(link: [blockedTag]);
  });

  await isar.writeTxn(() async {
    await isar.fernieModels.putAll([
      FernieModel()
        ..id = plainFernieId
        ..name = 'normal',
      FernieModel()
        ..id = markedFernieId
        ..name = 'marcado'
        ..isNsfw = true,
      FernieModel()
        ..id = linkedFernieId
        ..name = 'enlazado'
        ..linkedTagId = blockedTagId,
    ]);
  });

  // El fernie normal tiene una región sobre cada contenido: es lo que deja
  // probar que la rejilla se queda sólo con el que se puede enseñar.
  await _region(isar, id: 1, fernieId: plainFernieId, mediaId: visibleMediaId);
  await _region(isar, id: 2, fernieId: plainFernieId, mediaId: blockedMediaId);

  // Y el marcado, una sobre el contenido a la vista: si se colara, el nombre
  // del fernie aparecería encima de un contenido que no esconde nada.
  await _region(isar, id: 3, fernieId: markedFernieId, mediaId: visibleMediaId);

  await isar.writeTxn(() async {
    await isar.recognitionModelModels.putAll([
      RecognitionModelModel()
        ..id = plainModelId
        ..name = 'normal'
        ..weightsPath = 'C:/pesos-normal.pt',
      RecognitionModelModel()
        ..id = markedModelId
        ..name = 'marcado'
        ..isNsfw = true
        ..weightsPath = 'C:/pesos-marcado.pt',
    ]);
  });

  // El modelo normal aprende los dos fernies, el marcado incluido: es lo que
  // hace falta para probar que esconderlo no lo saca del modelo.
  await _assign(
    isar,
    modelId: plainModelId,
    fernieId: plainFernieId,
    classIndex: 0,
  );
  await _assign(
    isar,
    modelId: plainModelId,
    fernieId: markedFernieId,
    classIndex: 1,
  );
}

Future<void> _region(
  Isar isar, {
  required int id,
  required int fernieId,
  required int mediaId,
}) async {
  await isar.writeTxn(() async {
    final region = FernieRegionModel()
      ..id = id
      ..mediaId = mediaId
      ..x = 0.1
      ..y = 0.1
      ..w = 0.2
      ..h = 0.2;

    await isar.fernieRegionModels.put(region);

    region.fernie.value = await isar.fernieModels.get(fernieId);
    await region.fernie.save();
  });
}

/// Mete un fernie en un modelo con su número de clase, sin pasar por el
/// repositorio: aquí interesa el dato, no la regla de asignación.
Future<void> _assign(
  Isar isar, {
  required int modelId,
  required int fernieId,
  required int classIndex,
}) async {
  await isar.writeTxn(() async {
    final assignment = ModelFernieModel()..classIndex = classIndex;

    await isar.modelFernieModels.put(assignment);

    assignment.model.value = await isar.recognitionModelModels.get(modelId);
    assignment.fernie.value = await isar.fernieModels.get(fernieId);

    await assignment.model.save();
    await assignment.fernie.save();
  });
}

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> _values = {};

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);
}

class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings(this.avatarsPath);

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: avatarsPath,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
