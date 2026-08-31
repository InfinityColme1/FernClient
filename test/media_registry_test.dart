// El alta de contenido, y a quién avisa.
//
// `MediaRegistry.register()` es el único sitio por el que pasan todos los
// contenidos: el escaneo del equipo, las plataformas remotas y el navegador
// acaban los tres ahí. Por eso es donde se engancha lo que tenga que ocurrirles
// a todos —hoy, mandarlos a reconocer— y por eso el aviso tiene que ser exacto:
// uno por contenido nuevo, ninguno por lo que ya se conocía.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late List<int> announced;
  late MediaRegistry registry;

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
    directory = await Directory.systemTemp.createTemp('fern_registry_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        MediaTagLogModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    announced = [];
    registry = MediaRegistry(
      database: isar,
      tagHierarchy: TagHierarchy(database: isar),
      onRegistered: announced.add,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<void> register(String path) => registry.register(
        path: path,
        source: ImportSource.local,
      );

  group('el aviso', () {
    test('un contenido nuevo avisa una vez, con su identificador', () async {
      await register('C:/media/uno.jpg');

      expect(announced, [registry.idOf('C:/media/uno.jpg')]);
    });

    test('cada contenido avisa por su cuenta', () async {
      await register('C:/media/uno.jpg');
      await register('C:/media/dos.jpg');

      expect(announced.length, 2);
      expect(announced.toSet().length, 2);
    });

    test('lo que ya se conocía no avisa', () async {
      await register('C:/media/uno.jpg');
      announced.clear();

      await register('C:/media/uno.jpg');

      // Volver a escanear la misma carpeta es lo normal, y avisar otra vez
      // mandaría a reconocer lo que ya se reconoció.
      expect(announced, isEmpty);
    });

    test('avisa con el contenido ya guardado', () async {
      final seen = <int, bool>{};

      final registry = MediaRegistry(
        database: isar,
        tagHierarchy: TagHierarchy(database: isar),
        // Quien escuche va a querer leerlo: avisar antes de guardar le daría un
        // identificador que todavía no existe en la base.
        onRegistered: (id) =>
            seen[id] = isar.mediaSummaryModels.getSync(id) != null,
      );

      await registry.register(
        path: 'C:/media/tres.jpg',
        source: ImportSource.local,
      );

      expect(seen.values, [true]);
    });
  });

  group('sin nadie escuchando', () {
    test('el alta funciona igual', () async {
      final registry = MediaRegistry(
        database: isar,
        tagHierarchy: TagHierarchy(database: isar),
      );

      final summary = await registry.register(
        path: 'C:/media/cuatro.jpg',
        source: ImportSource.local,
      );

      expect(summary, isNotNull);
      expect(summary!.isImported, isFalse);
    });
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
