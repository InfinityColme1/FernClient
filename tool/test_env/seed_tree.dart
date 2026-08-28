// Monta el árbol de tres modelos con el que se comprueba el etiquetado entero.
//
// `seed.dart` deja un modelo suelto; esto deja **un árbol**, que es lo único con
// lo que se puede ver si cada modelo etiqueta lo suyo y si la poda funciona:
//
//     Figuras de prueba  ──[si ve un Rombo]──>  Variantes de rombo
//     Formas nuevas      (otra raíz, independiente)
//
// El hijo cuelga de una condición a propósito. Sin condición se ejecutaría ante
// cualquier detección del padre —un Cubo abriría la rama de los rombos—, y eso
// no se distingue de que la poda no funcione: los dos casos dan sugerencias.
//
// También **enlaza cada fernie con una etiqueta del mismo nombre**. Sin eso, el
// reconocimiento propone detecciones que no tienen nada que poner en el
// contenido: se ven en el panel, pero sólo se pueden rechazar, y no hay forma de
// comprobar que el etiquetado funciona.
//
// **La aplicación tiene que estar cerrada.** Isar no deja que dos procesos
// escriban a la vez.
//
//   dart run tool/test_env/seed_tree.dart --media <carpeta-arbol>
//   dart run tool/test_env/seed_tree.dart --media <carpeta-arbol> --clean
//
// La carpeta es la que dejó `generate_media.py --set arbol`. Lo que ya haya
// sembrado `seed.dart` no se toca: esto se suma.

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
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_presets.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// El modelo que ya existe y que hace de raíz. Lo crea `seed.dart`.
const rootModelName = 'Figuras de prueba';

/// El fernie del padre que abre la rama del hijo.
const conditionFernieName = 'Rombo';

/// Los dos modelos nuevos, con los fernies que lleva cada uno.
const newModels = {
  'Variantes de rombo': ['Rombo simple', 'Rombo doble'],
  'Formas nuevas': ['Estrella', 'Hexagono'],
};

Future<void> main(List<String> arguments) async {
  final options = _Options.parse(arguments);

  final manifest = File(p.join(options.media, 'labels.json'));
  if (!options.cleanOnly && !manifest.existsSync()) {
    _die('No hay labels.json en ${options.media}.\n'
        'Genera antes el material con:\n'
        '  generate_media.py --out <carpeta> --set arbol');
  }

  Isar.initializeIsarCore(libraries: {Abi.current(): options.isarLibrary});

  final isar = await Isar.open(
    [
      TagModelSchema, PersonaModelSchema, CreatorModelSchema,
      MediaSummaryModelSchema, MediaModelSchema,
      FernieModelSchema, FernieRegionModelSchema,
      RecognitionModelModelSchema, ModelFernieModelSchema,
      ModelTreeNodeModelSchema, ModelTreeEdgeModelSchema,
      RecognitionResultModelSchema,
    ],
    directory: options.database,
  );

  await _clean(isar, options.media);

  if (options.cleanOnly) {
    await isar.close();
    stdout.writeln('Limpiado lo de ${options.media}.');
    return;
  }

  final data = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;

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

    for (final region
        in (entry['regions'] as List).cast<Map<String, dynamic>>()) {
      final fernie = fernies[region['fernie']];
      if (fernie == null) continue;

      await _registerRegion(isar, mediaId: id, fernie: fernie, region: region);
      regions++;
    }
  }

  // Las etiquetas van para **todos** los fernies, no sólo para los nuevos: los
  // tres de `seed.dart` tampoco tenían ninguna, y sin ellas su modelo propone
  // detecciones que no se pueden aceptar.
  final tagged = await _linkAllFerniesToTags(isar);

  final models = <String, RecognitionModelModel>{};

  for (final entry in newModels.entries) {
    final assigned = [
      for (final name in entry.value)
        if (fernies[name] case final fernie?) fernie,
    ];

    if (assigned.length != entry.value.length) {
      _die('Faltan fernies para «${entry.key}». '
          '¿Generaste el material con --set arbol?');
    }

    models[entry.key] = await _model(isar, entry.key, assigned);
  }

  final tree = await _tree(isar, models);

  await isar.close();

  stdout.writeln('Sembrado el árbol en ${options.database}');
  stdout.writeln('  contenidos nuevos: $media');
  stdout.writeln('  regiones nuevas:   $regions');
  stdout.writeln('  fernies enlazados: $tagged');
  stdout.writeln('  modelos nuevos:    ${models.keys.join(', ')}');
  stdout.writeln('');
  stdout.writeln(tree);
  stdout.writeln('');
  stdout.writeln('Abre FeRN → Modelos y entrena los dos nuevos.');
}

// -----------------------------------------------------------------------------
// El árbol
// -----------------------------------------------------------------------------

/// Deja los tres modelos colocados y la rama del hijo condicionada.
Future<String> _tree(
  Isar isar,
  Map<String, RecognitionModelModel> models,
) async {
  final root = await isar.recognitionModelModels
      .filter()
      .nameEqualTo(rootModelName)
      .findFirst();

  if (root == null) {
    _die('No existe «$rootModelName». Siembra antes con seed.dart.');
  }

  final child = models['Variantes de rombo']!;
  final sibling = models['Formas nuevas']!;

  final rootNode = await _node(isar, root, row: 0, column: 0);
  final childNode = await _node(isar, child, row: 1, column: 0);
  final siblingNode = await _node(isar, sibling, row: 0, column: 1);

  // La condición: el hijo sólo se ejecuta si el padre ha visto un Rombo. Sin
  // ella, un Cubo abriría la rama de los rombos y no habría forma de distinguir
  // eso de que la poda no funcione.
  final condition = await isar.fernieModels
      .filter()
      .nameEqualTo(conditionFernieName)
      .findFirst();

  if (condition == null) {
    _die('No existe el fernie «$conditionFernieName». Siembra antes con '
        'seed.dart.');
  }

  await _edge(
    isar,
    parentNodeId: rootNode,
    childNodeId: childNode,
    conditionFernieId: condition.id,
  );

  return 'Árbol:\n'
      '  $rootModelName (raíz)\n'
      '    └─[si ve «$conditionFernieName»]→ ${child.name}\n'
      '  ${sibling.name} (raíz, hermano)\n'
      '  nodos: $rootNode, $childNode, $siblingNode';
}

/// Mete un modelo en el árbol, o lo deja donde está si ya estaba.
Future<int> _node(
  Isar isar,
  RecognitionModelModel model, {
  required int row,
  required int column,
}) async {
  final existing = await isar.modelTreeNodeModels
      .filter()
      .modelIdEqualTo(model.id)
      .findFirst();

  if (existing != null) return existing.id;

  final node = ModelTreeNodeModel()
    ..modelId = model.id
    ..row = row
    ..column = column;

  await isar.writeTxn(() async {
    node.id = await isar.modelTreeNodeModels.put(node);

    node.model.value = model;
    await node.model.save();
  });

  return node.id;
}

/// La arista de padre a hijo, rehecha si ya estaba.
Future<void> _edge(
  Isar isar, {
  required int parentNodeId,
  required int childNodeId,
  required int conditionFernieId,
}) async {
  final existing = await isar.modelTreeEdgeModels
      .filter()
      .parentNodeIdEqualTo(parentNodeId)
      .childNodeIdEqualTo(childNodeId)
      .findFirst();

  final edge = existing ?? ModelTreeEdgeModel()
    ..parentNodeId = parentNodeId
    ..childNodeId = childNodeId
    ..conditionFernieId = conditionFernieId;

  await isar.writeTxn(() => isar.modelTreeEdgeModels.put(edge));
}

// -----------------------------------------------------------------------------
// Etiquetas
// -----------------------------------------------------------------------------

/// Le da a cada fernie una etiqueta con su nombre y se la enlaza.
///
/// Es lo que convierte una detección en una propuesta de etiquetado: sin enlace,
/// el panel enseña la detección pero no hay nada que aceptar.
///
/// Devuelve cuántos han quedado enlazados.
Future<int> _linkAllFerniesToTags(Isar isar) async {
  final fernies = await isar.fernieModels.where().findAll();
  var linked = 0;

  for (final fernie in fernies) {
    // Los que ya apunten a algo se dejan como están: puede haberlos enlazado el
    // usuario a mano, y rehacerlo le desharía el trabajo.
    if (fernie.linkedTagId != null || fernie.linkedCreatorId != null) continue;

    final tag = await _tag(isar, fernie.name);

    fernie.linkedTagId = tag.id;
    await isar.writeTxn(() => isar.fernieModels.put(fernie));

    linked++;
  }

  return linked;
}

Future<TagModel> _tag(Isar isar, String name) async {
  final existing =
      await isar.tagModels.filter().nameEqualTo(name).findFirst();

  if (existing != null) return existing;

  final tag = TagModel(id: Isar.autoIncrement, name: name);
  await isar.writeTxn(() => isar.tagModels.put(tag));

  return tag;
}

// -----------------------------------------------------------------------------
// Lo mismo que hace seed.dart
// -----------------------------------------------------------------------------

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

    model.fernie.value = fernie;
    await model.fernie.save();
  });
}

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

/// Un modelo con sus fernies dentro, rehecho si ya estaba.
Future<RecognitionModelModel> _model(
  Isar isar,
  String name,
  List<FernieModel> fernies,
) async {
  final existing =
      await isar.recognitionModelModels.filter().nameEqualTo(name).findFirst();

  final model = existing ?? (RecognitionModelModel()..name = name);

  model.function = ModelFunction.classification;

  // Del preset rápido, y con menos épocas todavía.
  //
  // Estos dos modelos existen para comprobar **el recorrido del árbol y el
  // etiquetado**, no para ser buenos: son cuatro figuras planas de colores
  // distintos, que un modelo separa en unas pocas épocas. Y aquí se entrena por
  // procesador —hay tarjeta gráfica, pero el torch instalado es la rueda de
  // CPU—, así que cada época que sobra son minutos de espera para no aprender
  // nada nuevo.
  //
  // El panel dirá «Personalizado», que es la verdad: las épocas no son las de
  // ningún preset.
  final settings = settingsFor(
    preset: TrainingPreset.fast,
    function: ModelFunction.classification,
  );

  model
    ..preset = TrainingPreset.custom
    ..backbone = settings.backbone
    ..epochs = 20
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

  return model;
}

Future<CreatorModel> _unknownCreator(Isar isar) async {
  final existing =
      await isar.creatorModels.filter().nameEqualTo('Unknown').findFirst();

  if (existing != null) return existing;

  final creator = CreatorModel(id: Isar.autoIncrement, name: 'Unknown');
  await isar.writeTxn(() => isar.creatorModels.put(creator));

  return creator;
}

/// Borra lo que se sembró antes desde esta carpeta, y sólo eso.
Future<void> _clean(Isar isar, String media) async {
  final prefix = _folderPrefix(media);

  final summaries = await isar.mediaSummaryModels.where().findAll();
  final mine = [
    for (final summary in summaries)
      if (_canonical(summary.path).startsWith(prefix)) summary.id,
  ];

  if (mine.isEmpty) return;

  final regions = await isar.fernieRegionModels
      .filter()
      .anyOf(mine, (q, id) => q.mediaIdEqualTo(id))
      .findAll();

  await isar.writeTxn(() async {
    await isar.fernieRegionModels
        .deleteAll([for (final region in regions) region.id]);
    await isar.mediaModels.deleteAll(mine);
    await isar.mediaSummaryModels.deleteAll(mine);
  });
}

// -----------------------------------------------------------------------------
// Opciones
// -----------------------------------------------------------------------------

/// El mismo hash de la ruta que usa `MediaRegistry`.
int _idOf(String path) {
  var hash = 0;

  for (final unit in _canonical(path).codeUnits) {
    hash = (hash * 31 + unit) & 0x1FFFFFFFFFFFFF;
  }

  return hash;
}

/// La carpeta, en la forma con la que se compara: siempre terminada en barra.
///
/// La barra no es un detalle: sin ella, «pruebas» es prefijo de «pruebas-arbol»
/// y limpiar la primera carpeta se llevaría por delante el contenido de la
/// segunda, que no tiene nada que ver.
String _folderPrefix(String path) {
  final canonical = _canonical(path);

  return canonical.endsWith('/') ? canonical : '$canonical/';
}

String _canonical(String path) => path.replaceAll('\\', '/').toLowerCase();

Never _die(String message) {
  stderr.writeln(message);
  exit(1);
}

class _Options {
  final String media;
  final String database;
  final String isarLibrary;
  final bool cleanOnly;

  const _Options({
    required this.media,
    required this.database,
    required this.isarLibrary,
    required this.cleanOnly,
  });

  static _Options parse(List<String> arguments) {
    String? media;
    String? database;
    String? library;
    var cleanOnly = false;

    for (var index = 0; index < arguments.length; index++) {
      switch (arguments[index]) {
        case '--media':
          media = arguments[++index];
        case '--database':
          database = arguments[++index];
        case '--isar':
          library = arguments[++index];
        case '--clean':
          cleanOnly = true;
      }
    }

    if (media == null) _die('Falta --media <carpeta>.');

    final documents = p.join(
      Platform.environment['USERPROFILE'] ?? '',
      'Documents',
    );

    return _Options(
      media: media,
      database: database ?? documents,
      isarLibrary: library ??
          p.join(
            Directory.current.path,
            'build/windows/x64/runner/Debug/isar.dll',
          ),
      cleanOnly: cleanOnly,
    );
  }
}
