// Enseña qué ha propuesto cada modelo sobre cada contenido.
//
// Es una herramienta de comprobación, no de la aplicación: mirar el panel del
// visor uno a uno no deja ver **la forma del resultado**, que es lo que hay que
// comprobar cuando el árbol tiene ramas. Aquí se ve de un vistazo si el hijo se
// ejecutó donde tenía que ejecutarse y, sobre todo, si **no** se ejecutó donde
// no tocaba, que es lo que prueba que la poda funciona.
//
// **La aplicación tiene que estar cerrada.**
//
//   dart run tool/test_env/show_suggestions.dart
//   dart run tool/test_env/show_suggestions.dart --filter var-

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
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final filter = _valueOf(arguments, '--filter');

  Isar.initializeIsarCore(libraries: {
    Abi.current(): p.join(
      Directory.current.path,
      'build/windows/x64/runner/Debug/isar.dll',
    ),
  });

  final home = Platform.environment['USERPROFILE'] ?? '';

  final isar = await Isar.open(
    [
      TagModelSchema, PersonaModelSchema, CreatorModelSchema,
      MediaSummaryModelSchema, MediaModelSchema,
      FernieModelSchema, FernieRegionModelSchema,
      RecognitionModelModelSchema, ModelFernieModelSchema,
      ModelTreeNodeModelSchema, ModelTreeEdgeModelSchema,
      RecognitionResultModelSchema,
    ],
    directory: p.join(home, 'Documents'),
  );

  final fernies = {
    for (final fernie in await isar.fernieModels.where().findAll())
      fernie.id: fernie,
  };
  final models = {
    for (final model in await isar.recognitionModelModels.where().findAll())
      model.id: model.name,
  };
  final tags = {
    for (final tag in await isar.tagModels.where().findAll()) tag.id: tag.name,
  };

  final results = await isar.recognitionResultModels.where().findAll();

  // Por contenido, que es como se mira: lo que importa es qué modelos han
  // opinado sobre **la misma imagen**.
  final byMedia = <int, List<RecognitionResultModel>>{};
  for (final result in results) {
    byMedia.putIfAbsent(result.mediaId, () => []).add(result);
  }

  final summaries = {
    for (final summary in await isar.mediaSummaryModels.where().findAll())
      summary.id: summary,
  };

  var shown = 0;
  var recognized = 0;

  for (final summary in summaries.values) {
    if (summary.recognizedAt == null) continue;
    recognized++;

    final name = p.basename(summary.path);
    if (filter != null && !name.contains(filter)) continue;

    shown++;

    final mine = [...?byMedia[summary.id]];
    mine.sort((a, b) => b.confidence.compareTo(a.confidence));

    stdout.writeln('$name');

    if (mine.isEmpty) {
      stdout.writeln('  (nada)');
      continue;
    }

    for (final one in mine) {
      final fernie = fernies[one.fernieId];
      final tag = fernie?.linkedTagId;

      stdout.writeln(
        '  ${(one.confidence * 100).round().toString().padLeft(3)}%  '
        '${(models[one.modelId] ?? '?').padRight(20)} '
        '→ ${(fernie?.name ?? '?').padRight(14)} '
        '${tag == null ? '(sin etiqueta)' : 'etiqueta «${tags[tag]}»'}',
      );
    }
  }

  stdout.writeln('');
  stdout.writeln('Reconocidos: $recognized de ${summaries.length}');
  stdout.writeln('Enseñados:   $shown');

  await isar.close();
}

String? _valueOf(List<String> arguments, String name) {
  final index = arguments.indexOf(name);

  return index < 0 || index + 1 >= arguments.length
      ? null
      : arguments[index + 1];
}
