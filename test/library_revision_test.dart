// Por que version va la biblioteca.
//
// Sirve para una sola pregunta, la que se hace al abrir la biblioteca: «¿ha
// cambiado algo desde la ultima vez que la lei?». Con una biblioteca grande,
// releerla entera es de lo poco que se nota al cambiar de pantalla, y la
// mayoria de las veces no hace ninguna falta.
//
// **Se entera por Isar y no por quien escribe**, que es toda la gracia: un
// contador que hubiera que subir a mano en cada metodo se olvidaria un dia en
// uno, y ese dia la pantalla enseñaria una biblioteca vieja sin un solo error
// por medio.
//
// Y no todo lo que cambia la biblioteca pasa por la base: abrir o cerrar el
// bloqueo NSFW no escribe nada y cambia que se puede enseñar. Sin contarlo,
// volver a la biblioteca despues de cerrarlo devolvia la guardada, con el
// contenido escondido todavia dentro.

import 'dart:async';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/library_revision.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late LibraryRevision revision;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilacion de la aplicacion '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_revision');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    revision = LibraryRevision(database: isar);
  });

  tearDown(() async {
    await revision.dispose();
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  /// Isar avisa de los cambios en su propio turno, asi que hay que dejarle uno.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  Future<void> addMedia(int id) async {
    await isar.writeTxn(() async {
      await isar.mediaSummaryModels.put(MediaSummaryModel()
        ..id = id
        ..path = 'C:/media/$id.jpg'
        ..isImported = true);
    });
  }

  test('sin tocar nada no sube', () async {
    final before = revision.value;

    await settle();

    expect(revision.value, before);
  });

  test('dar de alta contenido lo sube', () async {
    final before = revision.value;

    await addMedia(1);
    await settle();

    expect(revision.value, greaterThan(before));
  });

  // Los detalles cuentan igual: de ahi salen el orden y las etiquetas, asi que
  // tocarlos cambia lo que la rejilla enseña.
  test('y tocar los detalles tambien', () async {
    await addMedia(1);
    await settle();

    final before = revision.value;

    await isar.writeTxn(() async {
      await isar.mediaModels.put(
        MediaModel(id: 1, path: 'C:/media/1.jpg')
          ..downloaded = DateTime(2026)
          ..isFavorite = true,
      );
    });
    await settle();

    expect(revision.value, greaterThan(before));
  });

  test('borrar tambien', () async {
    await addMedia(1);
    await settle();

    final before = revision.value;

    await isar.writeTxn(() async {
      await isar.mediaSummaryModels.delete(1);
    });
    await settle();

    expect(revision.value, greaterThan(before));
  });

  // Para lo que cambia fuera de la base y aun asi cambia lo que hay que
  // enseñar.
  test('y se puede dar por cambiada a mano', () async {
    final before = revision.value;

    revision.bump();

    expect(revision.value, greaterThan(before));
  });

  // Sin base no escucha nada: es como se monta en las pruebas que no la tienen.
  test('sin base de datos se queda quieto', () {
    final loose = LibraryRevision();

    expect(loose.value, 0);
  });

  // El bloqueo NSFW: cerrarlo y abrirlo no escribe una sola fila y cambia la
  // biblioteca entera.
  group('lo que cambia sin tocar la base', () {
    test('abrir o cerrar el bloqueo la da por cambiada', () async {
      final changes = StreamController<bool>.broadcast();
      addTearDown(changes.close);

      final watching = LibraryRevision(visibilityChanges: changes.stream);
      addTearDown(watching.dispose);

      final before = watching.value;

      changes.add(false);
      await settle();

      expect(watching.value, greaterThan(before));
    });

    test('y cada cambio cuenta', () async {
      final changes = StreamController<bool>.broadcast();
      addTearDown(changes.close);

      final watching = LibraryRevision(visibilityChanges: changes.stream);
      addTearDown(watching.dispose);

      changes..add(false)..add(true);
      await settle();

      expect(watching.value, 2);
    });
  });
}

/// La primera `isar.dll` que haya a mano: la de la aplicacion compilada o, si
/// todavia no se ha compilado, la que trae el paquete.
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
