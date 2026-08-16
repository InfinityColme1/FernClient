// Los comprimidos que llegan de una fuente remota.
//
// Un zip descargado no es contenido: es una caja. Lo que importa es que de
// dentro salga lo que la aplicación sabe enseñar, que lo demás no se quede por
// ahí, y que un fichero que viene de internet no pueda decidir dónde se
// escribe.

import 'dart:io';

import 'package:Fern/features/media/data/services/archive_extractor.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Un zip con lo que se le diga, escrito en [directory].
String zipWith(String directory, String name, Map<String, List<int>> entries) {
  final archive = Archive();
  for (final entry in entries.entries) {
    archive.add(ArchiveFile.bytes(entry.key, entry.value));
  }

  final path = p.join(directory, name);
  File(path).writeAsBytesSync(ZipEncoder().encode(archive));

  return path;
}

/// Un PNG de mentira: lo que importa aquí es la extensión, no el contenido.
List<int> get imagen => List<int>.filled(32, 7);

void main() {
  late Directory directory;
  const extractor = ArchiveExtractor();

  setUp(() {
    directory = Directory.systemTemp.createTempSync('fern_zip');
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test('sabe cuáles puede abrir', () {
    expect(extractor.isExtractable('C:/x/entrega.zip'), isTrue);
    expect(extractor.isExtractable('C:/x/una.jpg'), isFalse);
    // Se reconocen para no darlos por contenido, pero no se abren.
    expect(extractor.isExtractable('C:/x/entrega.rar'), isFalse);
  });

  test('saca el contenido y tira lo demás, la caja incluida', () async {
    final zip = zipWith(directory.path, 'entrega.zip', {
      'una.jpg': imagen,
      'carpeta/dos.png': imagen,
      'leeme.txt': [1, 2, 3],
    });

    final files = await extractor.extract(zip);

    expect(files, hasLength(2));
    expect(
      files.map((path) => p.basename(path)).toList()..sort(),
      ['entrega_dos.png', 'entrega_una.jpg'],
    );
    // Ni el texto ni el propio zip se quedan.
    expect(File(zip).existsSync(), isFalse);
    expect(
      directory.listSync().map((entry) => p.basename(entry.path)).toList()
        ..sort(),
      ['entrega_dos.png', 'entrega_una.jpg'],
    );
  });

  test('un fichero de dentro no decide dónde se escribe', () async {
    // Una ruta que apunta fuera de la carpeta es un truco conocido de los
    // comprimidos que llegan de internet.
    final zip = zipWith(directory.path, 'entrega.zip', {
      '../../fuera.jpg': imagen,
    });

    final files = await extractor.extract(zip);

    expect(files, hasLength(1));
    expect(p.dirname(files.single), directory.path);
    expect(p.basename(files.single), 'entrega_fuera.jpg');
  });

  test('dos entregas con los mismos nombres dentro no se pisan', () async {
    final primera = zipWith(directory.path, 'una.zip', {'01.jpg': imagen});
    final segunda = zipWith(directory.path, 'otra.zip', {'01.jpg': imagen});

    final files = [
      ...await extractor.extract(primera),
      ...await extractor.extract(segunda),
    ];

    expect(files.toSet(), hasLength(2));
  });

  test('un comprimido sin contenido no deja nada, ni siquiera él', () async {
    final zip = zipWith(directory.path, 'entrega.zip', {
      'leeme.txt': [1, 2, 3],
    });

    expect(await extractor.extract(zip), isEmpty);
    expect(File(zip).existsSync(), isFalse);
  });

  test('un comprimido roto no rompe la importación', () async {
    final path = p.join(directory.path, 'roto.zip');
    File(path).writeAsBytesSync([1, 2, 3, 4, 5]);

    expect(await extractor.extract(path), isEmpty);
  });
}
