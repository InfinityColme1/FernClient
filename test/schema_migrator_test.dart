// Poner la base de datos al día.
//
// Lo que hay que sostener es que se ejecute lo que falta y sólo lo que falta,
// en orden, y que un fallo no deje la versión adelantada: si se sellara la
// versión de una migración que ha reventado, el arranque siguiente daría por
// convertido algo que se quedó a medias y nadie volvería a mirarlo.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:Fern/core/services/schema_migrator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La base de datos no hace falta para probar el recorrido: las migraciones de
/// prueba no la tocan, sólo dejan constancia de que las han llamado.
class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<SharedPreferences> preferencesAt(int? version) async {
  SharedPreferences.setMockInitialValues(
    version == null ? {} : {schemaVersionPreferenceKey: version},
  );

  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final database = _FakeIsar();

  test('sin preferencia guardada se parte de la primera versión', () async {
    final preferences = await preferencesAt(null);

    final migrator = SchemaMigrator(preferences: preferences);

    expect(migrator.currentVersion, firstSchemaVersion);
  });

  test('ejecuta en orden sólo las migraciones que faltan', () async {
    final preferences = await preferencesAt(2);
    final called = <int>[];

    final migrator = SchemaMigrator(
      preferences: preferences,
      targetVersion: 4,
      migrations: {
        2: (_) async => called.add(2),
        3: (_) async => called.add(3),
        4: (_) async => called.add(4),
      },
    );

    await migrator.run(database);

    // La 2 ya estaba hecha: se salta.
    expect(called, [3, 4]);
    expect(migrator.currentVersion, 4);
  });

  test('estar al día no ejecuta nada', () async {
    final preferences = await preferencesAt(3);
    var called = false;

    final migrator = SchemaMigrator(
      preferences: preferences,
      targetVersion: 3,
      migrations: {3: (_) async => called = true},
    );

    await migrator.run(database);

    expect(called, isFalse);
    expect(migrator.currentVersion, 3);
  });

  test('los escalones sin migración sólo suben la versión', () async {
    final preferences = await preferencesAt(1);

    final migrator = SchemaMigrator(
      preferences: preferences,
      targetVersion: 2,
      migrations: const {},
    );

    await migrator.run(database);

    expect(migrator.currentVersion, 2);
  });

  test('un fallo aborta y deja la versión en el último escalón bueno', () async {
    final preferences = await preferencesAt(1);
    final called = <int>[];

    final migrator = SchemaMigrator(
      preferences: preferences,
      targetVersion: 4,
      migrations: {
        2: (_) async => called.add(2),
        3: (_) async => throw const FormatException('rota'),
        4: (_) async => called.add(4),
      },
    );

    await expectLater(
      migrator.run(database),
      throwsA(isA<SchemaMigrationException>()),
    );

    // La 4 no llega a ejecutarse y la versión se queda en la 2, que es la
    // última que sí terminó.
    expect(called, [2]);
    expect(migrator.currentVersion, 2);
  });

  test('reintentar después de un fallo no repite lo ya hecho', () async {
    final preferences = await preferencesAt(1);
    final called = <int>[];
    var shouldFail = true;

    Map<int, Migration> migrations() => {
          2: (_) async => called.add(2),
          3: (_) async {
            if (shouldFail) throw const FormatException('rota');
            called.add(3);
          },
        };

    final first = SchemaMigrator(
      preferences: preferences,
      targetVersion: 3,
      migrations: migrations(),
    );

    await expectLater(
      first.run(database),
      throwsA(isA<SchemaMigrationException>()),
    );

    shouldFail = false;

    final second = SchemaMigrator(
      preferences: preferences,
      targetVersion: 3,
      migrations: migrations(),
    );

    await second.run(database);

    // La 2 se ejecutó una sola vez, en el primer intento.
    expect(called, [2, 3]);
    expect(second.currentVersion, 3);
  });
}
