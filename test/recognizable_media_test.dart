// Qué contenido entra cuando se pide reconocer la biblioteca.
//
// Se prueba contra una base de datos de verdad y llamando al repositorio, no a
// una copia de la consulta: lo que se comprueba es el filtro, y un filtro mal
// puesto no falla, devuelve de más o de menos en silencio. De más significa
// horas de trabajo sobre contenido que nadie quería mirar.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:isar/isar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late LocalMediaRepositoryImpl repository;

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
    directory = await Directory.systemTemp.createTemp('fern_recognizable');

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
        ModelTreeNodeModelSchema,
        ModelTreeEdgeModelSchema,
        RecognitionResultModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    // Lo demás no lo toca esta consulta: mira el sumario y nada más. Ponerlo a
    // `null` sería mentirle al constructor, así que se le dan dobles vacíos.
    repository = LocalMediaRepositoryImpl(
      appDatabase: isar,
      fileOrganizer: _Explodes(),
      avatarStorage: _Explodes(),
      registry: _Explodes(),
      tagHierarchy: _Explodes(),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Da de alta un contenido con el estado que se le diga.
  Future<void> addMedia(
    int id, {
    DateTime? recognizedAt,
    bool isDeleted = false,
    bool isImported = true,
  }) async {
    final summary = MediaSummaryModel()
      ..id = id
      ..path = 'C:/media/$id.jpg'
      ..isImported = isImported
      ..isDeleted = isDeleted
      ..recognizedAt = recognizedAt;

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));
  }

  Future<List<int>> recognizable({bool onlyUnrecognized = true}) async {
    final found = await repository.getRecognizableMediaIds(
      onlyUnrecognized: onlyUnrecognized,
    );

    expect(found, isA<DataSuccess<List<int>>>());

    return found.data!..sort();
  }

  test('sin reconocer nada, entra todo', () async {
    await addMedia(1);
    await addMedia(2);

    expect(await recognizable(), [1, 2]);
  });

  test('lo ya reconocido se queda fuera de partida', () async {
    await addMedia(1);
    await addMedia(2, recognizedAt: DateTime(2026));

    // Es lo que hace usable «reconocer toda la biblioteca» la segunda vez: sin
    // ello, cada pulsación vuelve a pagar por todo lo que ya está hecho.
    expect(await recognizable(), [1]);
  });

  test('pidiéndolo todo, lo ya reconocido vuelve a entrar', () async {
    await addMedia(1);
    await addMedia(2, recognizedAt: DateTime(2026));

    // Quien acaba de entrenar un modelo mejor quiere justo esto.
    expect(await recognizable(onlyUnrecognized: false), [1, 2]);
  });

  test('la papelera nunca entra', () async {
    await addMedia(1);
    await addMedia(2, isDeleted: true);

    // Reconocerlo sería gastar horas en contenido que sale solo de la base de
    // datos en una semana.
    expect(await recognizable(), [1]);
    expect(await recognizable(onlyUnrecognized: false), [1]);
  });

  test('lo pendiente de revisar entra igual', () async {
    await addMedia(1, isImported: false);

    // Reconocer contenido recién importado es justo para lo que existe el
    // enganche automático del paso 9: dejarlo fuera aquí sería incoherente.
    expect(await recognizable(), [1]);
  });

  test('con la biblioteca vacía no da nada', () async {
    expect(await recognizable(), isEmpty);
  });

  test('lo reconocido y borrado no aparece por ninguna de las dos', () async {
    await addMedia(1, isDeleted: true, recognizedAt: DateTime(2026));

    expect(await recognizable(), isEmpty);
    expect(await recognizable(onlyUnrecognized: false), isEmpty);
  });
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

/// Un doble que revienta si alguien lo usa.
///
/// Esta consulta mira el sumario y nada más: ni ficheros, ni avatares, ni
/// etiquetas. Si algún día empieza a tocarlos, esto lo dice a gritos en vez de
/// dejar pasar una escritura de verdad en una prueba.
class _Explodes
    implements
        MediaFileOrganizer,
        AvatarStorageService,
        MediaRegistry,
        TagHierarchy {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'Esta consulta no debería llamar a ${invocation.memberName}',
      );
}
