// Lo que se ha dicho que no se vuelva a importar.
//
// La fuente guarda lo que el usuario tiene marcado, así que cada importación
// vuelve a ofrecer lo mismo. Eso es correcto: lo que faltaba era poder decir de
// una pieza concreta «ésta no».
//
// Se identifica por **su dirección en la fuente**, que se conoce antes de
// descargar, así que el fichero ni se baja. Dos consecuencias que hay que
// sostener: la pregunta es síncrona —se hace una vez por pieza de cada
// importación, y una consulta por pieza convertiría importar mil cosas en mil
// consultas para no hacer nada— y bloquear dos veces lo mismo no deja dos filas.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/features/media/data/models/blocked_import_model.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late BlockedImports blocked;

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
    directory = await Directory.systemTemp.createTemp('fern_blocked_imports');

    isar = await Isar.open(
      [BlockedImportModelSchema],
      directory: directory.path,
      inspector: false,
    );

    blocked = BlockedImports(database: isar);
    await blocked.rebuild();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  group('bloquear', () {
    test('lo bloqueado se salta', () async {
      await blocked.block(source: 'reddit', remoteId: 'abc');

      expect(blocked.blocks('reddit', 'abc'), isTrue);
    });

    test('y lo demás no', () async {
      await blocked.block(source: 'reddit', remoteId: 'abc');

      expect(blocked.blocks('reddit', 'otro'), isFalse);
    });

    // Cada fuente tiene sus identificadores: dos piezas distintas pueden
    // llamarse igual en plataformas distintas.
    test('el mismo identificador en otra fuente no está bloqueado', () async {
      await blocked.block(source: 'reddit', remoteId: 'abc');

      expect(blocked.blocks('pixiv', 'abc'), isFalse);
    });

    test('dos veces lo mismo no deja dos filas', () async {
      await blocked.block(source: 'reddit', remoteId: 'abc');
      await blocked.block(source: 'reddit', remoteId: 'abc');

      expect(await blocked.all(), hasLength(1));
    });

    // Sin identificador no hay nada que bloquear, y guardar una fila vacía
    // bloquearía cualquier pieza que tampoco lo tuviera.
    test('sin identificador no se guarda nada', () async {
      await blocked.block(source: 'reddit', remoteId: '');

      expect(await blocked.all(), isEmpty);
    });

    test('se guarda de dónde era y qué era, para poder enseñarlo', () async {
      await blocked.block(
        source: 'reddit',
        remoteId: 'abc',
        description: 'abc.png',
      );

      final row = (await blocked.all()).single;

      expect(row.source, 'reddit');
      expect(row.remoteId, 'abc');
      expect(row.description, 'abc.png');
    });
  });

  group('deshacer', () {
    test('desbloquear lo vuelve a ofrecer', () async {
      await blocked.block(source: 'reddit', remoteId: 'abc');
      final row = (await blocked.all()).single;

      await blocked.unblock(row.id);

      expect(blocked.blocks('reddit', 'abc'), isFalse);
      expect(await blocked.all(), isEmpty);
    });

    test('desbloquear uno no toca a los demás', () async {
      await blocked.block(source: 'reddit', remoteId: 'uno');
      await blocked.block(source: 'reddit', remoteId: 'dos');

      await blocked.unblock(BlockedImportModel.idOf('reddit', 'uno'));

      expect(blocked.blocks('reddit', 'uno'), isFalse);
      expect(blocked.blocks('reddit', 'dos'), isTrue);
    });

    test('vaciarlo los suelta todos', () async {
      await blocked.block(source: 'reddit', remoteId: 'uno');
      await blocked.block(source: 'pixiv', remoteId: 'dos');

      await blocked.clear();

      expect(blocked.isEmpty, isTrue);
      expect(await blocked.all(), isEmpty);
    });
  });

  // La memoria es la que contesta durante una importación, así que tiene que
  // estar al día también después de reabrir la aplicación.
  test('lo bloqueado sobrevive a reabrir', () async {
    await blocked.block(source: 'reddit', remoteId: 'abc');

    final other = BlockedImports(database: isar);
    expect(other.blocks('reddit', 'abc'), isFalse, reason: 'sin leer todavía');

    await other.rebuild();

    expect(other.blocks('reddit', 'abc'), isTrue);
  });

  group('el recuento de lo saltado', () {
    test('empieza a cero', () {
      expect(blocked.skipped, 0);
    });

    test('cuenta lo que se salta', () {
      blocked.noteSkipped();
      blocked.noteSkipped();

      expect(blocked.skipped, 2);
    });

    // Es el de **esta** importación: sin ponerlo a cero, el aviso del final iría
    // sumando el de todas las anteriores.
    test('se pone a cero al empezar otra', () {
      blocked.noteSkipped();
      blocked.resetSkipped();

      expect(blocked.skipped, 0);
    });
  });

  group('sin base de datos', () {
    test('no bloquea nada y no revienta', () async {
      final none = BlockedImports();

      await none.rebuild();

      expect(none.blocks('reddit', 'abc'), isFalse);
      expect(await none.all(), isEmpty);
      expect(none.isEmpty, isTrue);
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
