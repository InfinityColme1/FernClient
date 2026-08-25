// Vaciar la base de datos entera.
//
// Es lo único de la aplicación que destruye sin poder deshacerse, así que las
// dos cosas que hay que sostener son opuestas: que **no ocurra** mientras la
// frase no esté escrita exactamente, y que cuando ocurra **se lleve todo**, sin
// dejar una biblioteca a medias con etiquetas que ya no señalan a nada.
//
// Y una tercera que no es obvia: las marcas de importación se van con ella. Son
// preferencias, no base de datos, pero dicen «de aquí para atrás ya está
// traído», y con la base vacía eso es mentira: dejarlas puestas haría que la
// siguiente importación «desde la última vez» no trajera nada y pareciera que la
// fuente está rota.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/data/services/database_maintenance_service.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_phrase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('la frase de confirmación', () {
    const phrase = 'Eliminar Base de Datos';

    bool confirmed(String typed) =>
        isDatabaseWipeConfirmed(typed: typed, phrase: phrase);

    test('escrita tal cual, vale', () {
      expect(confirmed('Eliminar Base de Datos'), isTrue);
    });

    test('con espacios de más a los lados, también', () {
      // Copiar y pegar arrastra un espacio con una facilidad pasmosa, y eso no
      // es un accidente: es la frase entera escrita.
      expect(confirmed('  Eliminar Base de Datos '), isTrue);
    });

    group('y lo que no vale', () {
      test('otra cosa parecida', () {
        expect(confirmed('eliminar base de datos'), isFalse);
        expect(confirmed('Eliminar Base de Dato'), isFalse);
        expect(confirmed('Eliminar  Base de Datos'), isFalse);
      });

      test('nada', () {
        expect(confirmed(''), isFalse);
        expect(confirmed('   '), isFalse);
      });

      test('ni la frase suelta si no hay frase que pedir', () {
        // Si por lo que sea la frase llegara vacía, cualquier campo vacío la
        // cumpliría y el borrado saldría de no escribir nada.
        expect(isDatabaseWipeConfirmed(typed: '', phrase: ''), isFalse);
        expect(isDatabaseWipeConfirmed(typed: '  ', phrase: '  '), isFalse);
      });
    });
  });

  group('el borrado', () {
    late Directory directory;
    late Isar isar;
    late PreferencesService preferences;
    late DatabaseMaintenanceService maintenance;

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
      directory = await Directory.systemTemp.createTemp('fern_wipe_test');

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

      SharedPreferences.setMockInitialValues({});
      preferences =
          PreferencesService(await SharedPreferences.getInstance());

      maintenance = DatabaseMaintenanceService(
        database: isar,
        preferences: preferences,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });

    /// Deja la base de datos con algo de cada cosa.
    Future<void> fill() async {
      await isar.writeTxn(() async {
        await isar.tagModels.put(TagModel(id: 1, name: 'paisajes'));
        await isar.creatorModels.put(CreatorModel(id: 1, name: 'alguien'));
        await isar.mediaSummaryModels.put(
          MediaSummaryModel()
            ..id = 1
            ..path = 'C:/media/uno.jpg',
        );
        await isar.mediaModels.put(
          MediaModel(id: 1, path: 'C:/media/uno.jpg')
            ..downloaded = DateTime(2026)
            ..isFavorite = false,
        );
      });
    }

    /// Cuántas filas quedan en total.
    Future<int> rows() async =>
        await isar.tagModels.count() +
        await isar.creatorModels.count() +
        await isar.mediaSummaryModels.count() +
        await isar.mediaModels.count();

    test('se lleva todas las colecciones, no sólo los contenidos', () async {
      await fill();
      expect(await rows(), greaterThan(0));

      await maintenance.wipe();

      // A medias quedaría una biblioteca con etiquetas que no señalan a nada y
      // contenidos sin la ficha que los describe, que es peor que las dos
      // cosas.
      expect(await rows(), 0);
    });

    test('y la base sigue sirviendo después', () async {
      await fill();
      await maintenance.wipe();

      // Vaciarla no es cerrarla: se sigue usando la misma, sin reiniciar.
      await isar.writeTxn(
        () => isar.tagModels.put(TagModel(id: 2, name: 'nueva')),
      );

      expect(await isar.tagModels.count(), 1);
    });

    test('olvida por dónde iban las importaciones', () async {
      await preferences.setLastImport(ImportSource.reddit, DateTime(2026, 8));
      await preferences.setLastImportMarker(ImportSource.reddit, 'abc123');

      await maintenance.wipe();

      expect(preferences.getLastImport(ImportSource.reddit), isNull);
      expect(preferences.getLastImportMarker(ImportSource.reddit), isNull);
    });

    test('pero no se lleva por delante el resto de los ajustes', () async {
      await preferences.setRootPath('C:/biblioteca');
      await preferences.setLastImportSource(ImportSource.pixiv);

      await maintenance.wipe();

      // La carpeta de la biblioteca no es la base de datos: sin ella, después
      // de vaciar habría que volver a configurar la aplicación entera.
      expect(preferences.getRootPath(), 'C:/biblioteca');
      expect(preferences.getLastImportSource(), ImportSource.pixiv);
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
