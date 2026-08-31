// La migración que devuelve la simetría a las hermandades a medias.
//
// `TagModel.siblings` no tiene backlink: la simetría la fuerza el repositorio
// escribiendo las dos direcciones. Pero el árbol de etiquetas se leía **sin** las
// hermanas, así que la ficha de la pantalla de gestión partía siempre de una
// lista vacía y guardar desde ahí desenlazaba por un lado lo que seguía enlazado
// por el otro. Quedaron etiquetas que saben que son hermanas de otra sin que la
// otra lo sepa.
//
// Lo que hay que sostener: que las recupere, que **sólo añada** (ante una
// relación coja no hay forma de saber si se creó a medias o se quitó a medias, y
// recuperar de más se deshace a mano mientras que borrar de más no se deshace de
// ninguna manera), y que pasarla dos veces no cambie nada.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/services/schema_migrator.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;

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
    directory = await Directory.systemTemp.createTemp('fern_siblings_repair');

    isar = await Isar.open(
      // Las colecciones con las que `Tags` está enlazada tienen que estar,
      // aunque esto sólo toque etiquetas: Isar no abre una colección sin las
      // que dependen de ella.
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

    await isar.writeTxn(() async {
      await isar.tagModels.putAll([
        TagModel(id: 1, name: 'ladybug'),
        TagModel(id: 2, name: 'serie'),
        TagModel(id: 3, name: 'akumatizados'),
      ]);
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<Set<int>> siblingsOf(int id) async {
    final tag = await isar.tagModels.get(id);
    await tag!.siblings.load();

    return {for (final sibling in tag.siblings) sibling.id};
  }

  /// Deja una relación coja: [from] tiene a [to] y [to] no tiene a [from]. Es
  /// justo lo que dejaba el fallo de lectura.
  Future<void> lopsided(int from, int to) async {
    await isar.writeTxn(() async {
      final tag = await isar.tagModels.get(from);
      final other = await isar.tagModels.get(to);

      await tag!.siblings.update(link: [other!]);
    });
  }

  test('una relación coja se completa', () async {
    await lopsided(1, 2);

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), {2});
    expect(await siblingsOf(2), {1});
  });

  test('varias cojas a la vez, todas', () async {
    await lopsided(1, 2);
    await lopsided(3, 1);

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), {2, 3});
    expect(await siblingsOf(2), {1});
    expect(await siblingsOf(3), {1});
  });

  test('lo que ya estaba bien se queda como estaba', () async {
    await lopsided(1, 2);
    await lopsided(2, 1);

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), {2});
    expect(await siblingsOf(2), {1});
    expect(await siblingsOf(3), isEmpty);
  });

  // Nunca desenlaza: ante una relación coja se elige recuperarla, no borrarla.
  test('no quita ninguna relación', () async {
    await lopsided(1, 2);
    await lopsided(1, 3);

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), {2, 3});
  });

  test('pasarla dos veces no cambia nada', () async {
    await lopsided(1, 2);

    await repairTagSiblingSymmetry(isar);
    final after = await siblingsOf(1);

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), after);
    expect(await siblingsOf(2), {1});
  });

  test('sin ninguna relación no hace nada', () async {
    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), isEmpty);
    expect(await siblingsOf(2), isEmpty);
    expect(await siblingsOf(3), isEmpty);
  });

  // Una etiqueta enlazada con otra que ya no existe: el enlace no lleva a
  // ninguna parte y no hay nada que reparar al otro lado. Lo que no puede es
  // reventar el arranque, que es lo que hace `SchemaMigrator` si una migración
  // lanza.
  test('una hermana borrada no la hace fallar', () async {
    await lopsided(1, 2);

    await isar.writeTxn(() async {
      await isar.tagModels.delete(2);
    });

    await repairTagSiblingSymmetry(isar);

    expect(await siblingsOf(1), isEmpty);
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
