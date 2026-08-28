// Deja la base de datos de FeRN lista para probar el entrenamiento sin marcar
// una sola región a mano.
//
// Lee el `labels.json` que dejó `generate_media.py` y escribe directamente en el
// mismo Isar que usa la aplicación: los contenidos, los tres fernies con sus
// regiones y un modelo con los tres asignados. Al abrir FeRN sólo queda pulsar
// «Entrenar modelo».
//
// **La aplicación tiene que estar cerrada.** Isar no deja que dos procesos
// escriban a la vez, y con FeRN abierto esto falla al abrir la base de datos.
//
//   dart run tool/test_env/seed.dart --media <carpeta>
//   dart run tool/test_env/seed.dart --media <carpeta> --clean
//
// Volver a sembrar **siempre limpia antes** lo de la vez anterior: los
// contenidos se reconocen por su ruta y se reemplazarían solos, pero las
// regiones no, y sin limpiar se irían acumulando copias de cada una. Lo que se
// limpia es sólo lo que cuelga de la carpeta indicada: la biblioteca de verdad
// no se toca.
//
// Con `--clean` se limpia y se sale, sin sembrar nada.

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_presets.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// Cómo se llama el modelo que se crea, para poder encontrarlo y rehacerlo.
const modelName = 'Figuras de prueba';

Future<void> main(List<String> arguments) async {
  final options = _Options.parse(arguments);

  final manifest = File(p.join(options.media, 'labels.json'));
  if (!manifest.existsSync()) {
    _die('No hay labels.json en ${options.media}.\n'
        'Genera antes el material con tool/test_env/generate_media.py.');
  }

  Isar.initializeIsarCore(libraries: {Abi.current(): options.isarLibrary});

  final isar = await Isar.open(
    [
      TagModelSchema, PersonaModelSchema, CreatorModelSchema,
      MediaSummaryModelSchema, MediaModelSchema,
      FernieModelSchema, FernieRegionModelSchema,
      RecognitionModelModelSchema, ModelFernieModelSchema,
    ],
    directory: options.database,
  );

  final data = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;

  await _clean(isar, options.media);

  if (options.cleanOnly) {
    await isar.close();
    return;
  }

  final creator = await _unknownCreator(isar);
  final fernies = await _fernies(isar, (data['fernies'] as List).cast<String>());

  var media = 0;
  var regions = 0;

  for (final entry in (data['media'] as List).cast<Map<String, dynamic>>()) {
    final path = entry['path'] as String;

    if (!File(path).existsSync()) {
      stderr.writeln('Falta el fichero, se salta: $path');
      continue;
    }

    final id = await _registerMedia(isar, path: path, creator: creator);
    media++;

    for (final region in (entry['regions'] as List).cast<Map<String, dynamic>>()) {
      final fernie = fernies[region['fernie']];
      if (fernie == null) continue;

      await _registerRegion(isar, mediaId: id, fernie: fernie, region: region);
      regions++;
    }
  }

  final model = await _model(isar, fernies.values.toList());

  await isar.close();

  stdout.writeln('Sembrado en ${options.database}');
  stdout.writeln('  contenidos: $media');
  stdout.writeln('  regiones:   $regions');
  stdout.writeln('  fernies:    ${fernies.keys.join(', ')}');
  stdout.writeln('  modelo:     «$modelName» (id $model)');
  stdout.writeln('');
  stdout.writeln('Abre FeRN, entra en Modelos y pulsa «Entrenar modelo».');
}

// -----------------------------------------------------------------------------
// Escritura
// -----------------------------------------------------------------------------

/// Da de alta un contenido igual que lo haría la importación.
///
/// El identificador sale del mismo hash de la ruta que usa `MediaRegistry`, para
/// que sembrar dos veces el mismo fichero lo reemplace en vez de duplicarlo.
Future<int> _registerMedia(
  Isar isar, {
  required String path,
  required CreatorModel creator,
}) async {
  final id = _idOf(path);

  final summary = MediaSummaryModel()
    ..id = id
    ..path = path
    ..isImported = true;

  final details = MediaModel(id: id, path: path)
    ..downloaded = DateTime.now()
    ..isFavorite = false;

  await isar.writeTxn(() async {
    await isar.mediaSummaryModels.put(summary);
    await isar.mediaModels.put(details);

    details.creator.value = creator;
    await details.creator.save();

    summary.details.value = details;
    await summary.details.save();
  });

  return id;
}

Future<void> _registerRegion(
  Isar isar, {
  required int mediaId,
  required FernieModel fernie,
  required Map<String, dynamic> region,
}) async {
  final model = FernieRegionModel()
    ..mediaId = mediaId
    ..x = (region['x'] as num).toDouble()
    ..y = (region['y'] as num).toDouble()
    ..w = (region['w'] as num).toDouble()
    ..h = (region['h'] as num).toDouble()
    ..frameMs = (region['frameMs'] as num?)?.toInt();

  await isar.writeTxn(() async {
    await isar.fernieRegionModels.put(model);

    // El enlace es una escritura: tiene que ir dentro de la misma transacción.
    model.fernie.value = fernie;
    await model.fernie.save();
  });
}

/// Los tres fernies, reaprovechando los que ya existan con ese nombre.
Future<Map<String, FernieModel>> _fernies(Isar isar, List<String> names) async {
  final fernies = <String, FernieModel>{};

  for (final name in names) {
    final existing =
        await isar.fernieModels.filter().nameEqualTo(name).findFirst();

    if (existing != null) {
      fernies[name] = existing;
      continue;
    }

    final fernie = FernieModel()..name = name;
    await isar.writeTxn(() => isar.fernieModels.put(fernie));

    fernies[name] = fernie;
  }

  return fernies;
}

/// El modelo con los tres dentro, rehecho si ya estaba.
Future<int> _model(Isar isar, List<FernieModel> fernies) async {
  final existing =
      await isar.recognitionModelModels.filter().nameEqualTo(modelName).findFirst();

  final model = existing ?? (RecognitionModelModel()..name = modelName);

  // Clasificatorio porque son tres: es lo que hace que el modelo tenga que
  // distinguirlos y no sólo decir «hay algo».
  model.function = ModelFunction.classification;

  // Y con los mandos que corresponden a su preset, no con los de fábrica: lo
  // que se guarda son las cifras, y el preset es la etiqueta de cómo se llegó a
  // ellas. Dejando las de fábrica, la pantalla dice «Personalizado» nada más
  // abrirla, que es verdad pero desconcierta.
  final settings = settingsFor(
    preset: model.preset,
    function: ModelFunction.classification,
  );

  model
    ..backbone = settings.backbone
    ..epochs = settings.epochs
    ..imgsz = settings.imgsz
    ..batch = settings.batch;

  await isar.writeTxn(() async {
    await isar.recognitionModelModels.put(model);

    if (existing != null) {
      await model.fernies.load();
      await isar.modelFernieModels
          .deleteAll(model.fernies.map((link) => link.id).toList());
    }

    for (var index = 0; index < fernies.length; index++) {
      final assignment = ModelFernieModel()..classIndex = index;

      await isar.modelFernieModels.put(assignment);

      assignment.model.value = model;
      assignment.fernie.value = fernies[index];
      await assignment.model.save();
      await assignment.fernie.save();
    }
  });

  return model.id;
}

/// El creador «Unknown», que es con el que nace todo lo recién dado de alta.
Future<CreatorModel> _unknownCreator(Isar isar) async {
  final existing =
      await isar.creatorModels.filter().nameEqualTo('Unknown').findFirst();

  if (existing != null) return existing;

  final creator = CreatorModel(id: Isar.autoIncrement, name: 'Unknown');
  await isar.writeTxn(() => isar.creatorModels.put(creator));

  return creator;
}

/// Borra lo que se sembró antes, y sólo eso.
///
/// Se reconoce por la ruta: lo que cuelga de la carpeta de material de prueba.
/// La biblioteca de verdad no se toca, que sería un estropicio difícil de
/// deshacer.
Future<void> _clean(Isar isar, String media) async {
  final prefix = _folderPrefix(media);

  final summaries = await isar.mediaSummaryModels.where().findAll();
  final ids = summaries
      .where((summary) => _canonical(summary.path).startsWith(prefix))
      .map((summary) => summary.id)
      .toList();

  final regions = await isar.fernieRegionModels
      .filter()
      .anyOf(ids, (query, id) => query.mediaIdEqualTo(id))
      .findAll();

  if (ids.isEmpty) return;

  await isar.writeTxn(() async {
    await isar.fernieRegionModels
        .deleteAll(regions.map((region) => region.id).toList());
    await isar.mediaSummaryModels.deleteAll(ids);
    await isar.mediaModels.deleteAll(ids);
  });

  stdout.writeln('Limpiados ${ids.length} contenidos y '
      '${regions.length} regiones de una siembra anterior.');
}

/// Una ruta comparable con otra.
///
/// El manifiesto lo escribe Python con barras invertidas y los argumentos llegan
/// con barras normales: sin igualarlas, la limpieza no encontraba nada y se
/// callaba, que es la peor forma de fallar.
/// La carpeta, en la forma con la que se compara: siempre terminada en barra.
///
/// La barra no es un detalle: sin ella, «pruebas» es prefijo de «pruebas-arbol»
/// y limpiar la primera carpeta se llevaría por delante el contenido de la
/// segunda, que no tiene nada que ver.
String _folderPrefix(String path) {
  final canonical = _canonical(path);

  return canonical.endsWith('/') ? canonical : '$canonical/';
}

String _canonical(String path) =>
    p.normalize(path).replaceAll(r'\', '/').toLowerCase();

// -----------------------------------------------------------------------------
// Argumentos
// -----------------------------------------------------------------------------

class _Options {
  final String media;
  final String database;
  final String isarLibrary;

  /// Sólo limpiar lo de la vez anterior, sin sembrar.
  final bool cleanOnly;

  const _Options({
    required this.media,
    required this.database,
    required this.isarLibrary,
    required this.cleanOnly,
  });

  static _Options parse(List<String> arguments) {
    String? value(String name) {
      final index = arguments.indexOf('--$name');

      return index >= 0 && index + 1 < arguments.length
          ? arguments[index + 1]
          : null;
    }

    final media = value('media') ??
        _die('Falta --media <carpeta con labels.json>.');

    return _Options(
      media: p.absolute(media),
      database: value('db') ?? _documents(),
      isarLibrary: value('isar') ?? _findIsarLibrary(),
      cleanOnly: arguments.contains('--clean'),
    );
  }
}

/// Donde la aplicación abre su base de datos.
String _documents() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      _die('No se sabe cuál es la carpeta del usuario.');

  return p.join(home, 'Documents');
}

/// La biblioteca nativa de Isar, que sale de lo ya compilado.
///
/// Un `dart run` no arranca Flutter, así que el complemento que la carga en la
/// aplicación no está: hay que decirle a Isar dónde encontrarla. Se busca en lo
/// que haya compilado el proyecto para no obligar a descargar nada.
String _findIsarLibrary() {
  const candidates = [
    'build/windows/x64/runner/Debug/isar.dll',
    'build/windows/x64/runner/Release/isar.dll',
    'build/linux/x64/debug/bundle/lib/libisar.so',
    'build/macos/Build/Products/Debug/libisar.dylib',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return p.absolute(candidate);
  }

  _die('No se encuentra la biblioteca de Isar.\n'
      'Compila una vez (flutter build windows --debug) o pásala con --isar.');
}

/// El mismo hash de la ruta que usa `MediaRegistry` para dar identificadores.
///
/// Copiado y no importado a propósito: es privado allí, y lo que importa aquí es
/// que **dé el mismo número**, para que sembrar dos veces el mismo fichero lo
/// reemplace en vez de duplicarlo.
int _idOf(String path) {
  var hash = 0xcbf29ce484222325;
  var i = 0;

  while (i < path.length) {
    final codeUnit = path.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xff;
    hash *= 0x100000001b3;
  }

  return hash;
}

Never _die(String message) {
  stderr.writeln(message);
  exit(1);
}
