// Cuando se importo por ultima vez de cada creador.
//
// Es lo que la tarjeta de un creador remoto ensena mientras no se sabe cuanto ha
// publicado: contar eso cuesta una peticion por creador y con cincuenta marcados
// casi nunca llega a tiempo, asi que hace falta algo que salga de esta maquina y
// este desde el primer momento.

import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PreferencesService> _preferences() async {
  SharedPreferences.setMockInitialValues({});

  return PreferencesService(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cada listado se queda con la suya', () async {
    final preferences = await _preferences();

    await preferences.setLastImport(
      ImportSource.pawchive,
      DateTime(2026, 8, 12),
      collection: 'algo-1',
    );
    await preferences.setLastImport(
      ImportSource.pawchive,
      DateTime(2026, 8, 20),
      collection: 'algo-2',
    );

    expect(preferences.importDates(ImportSource.pawchive), {
      'algo-1': DateTime(2026, 8, 12),
      'algo-2': DateTime(2026, 8, 20),
    });
  });

  test('la de la fuente entera no se cuela entre las de los listados', () async {
    // La clave de la fuente es el prefijo de las de sus listados, asi que sin
    // cuidado saldria como un listado mas y con un nombre vacio.
    final preferences = await _preferences();

    await preferences.setLastImport(ImportSource.pawchive, DateTime(2026, 8, 1));

    expect(preferences.importDates(ImportSource.pawchive), isEmpty);
    expect(
      preferences.getLastImport(ImportSource.pawchive),
      DateTime(2026, 8, 1),
    );
  });

  test('las de otra fuente no se mezclan', () async {
    final preferences = await _preferences();

    await preferences.setLastImport(
      ImportSource.reddit,
      DateTime(2026, 8, 12),
      collection: 'algo-1',
    );

    expect(preferences.importDates(ImportSource.pawchive), isEmpty);
  });

  test('sin nada importado no hay ninguna', () async {
    final preferences = await _preferences();

    expect(preferences.importDates(ImportSource.pawchive), isEmpty);
  });

  test('vaciar la base de datos tambien las olvida', () async {
    // Dicen «de aqui para atras ya esta traido», y con la base de datos vacia
    // eso es mentira.
    final preferences = await _preferences();

    await preferences.setLastImport(
      ImportSource.pawchive,
      DateTime(2026, 8, 12),
      collection: 'algo-1',
    );

    await preferences.forgetImportProgress();

    expect(preferences.importDates(ImportSource.pawchive), isEmpty);
  });
}
