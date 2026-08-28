// Qué pesos lleva puestos cada modelo, y con qué mandos predice.
//
// Es la primera pregunta cuando un modelo «no detecta nada»: unos pesos que no
// son los suyos —los de fábrica de ultralytics, por ejemplo— detectan personas y
// coches, y sus números de clase se traducen a los fernies de uno, que es ruido
// con nombres creíbles.

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

Future<void> main() async {
  Isar.initializeIsarCore(libraries: {
    Abi.current(): p.join(
      Directory.current.path,
      'build/windows/x64/runner/Debug/isar.dll',
    ),
  });

  final isar = await Isar.open(
    [
      TagModelSchema, PersonaModelSchema, CreatorModelSchema,
      MediaSummaryModelSchema, MediaModelSchema,
      FernieModelSchema, FernieRegionModelSchema,
      RecognitionModelModelSchema, ModelFernieModelSchema,
      ModelTreeNodeModelSchema, ModelTreeEdgeModelSchema,
      RecognitionResultModelSchema,
    ],
    directory: p.join(Platform.environment['USERPROFILE'] ?? '', 'Documents'),
  );

  for (final model in await isar.recognitionModelModels.where().findAll()) {
    stdout.writeln('${model.id}  «${model.name}»');
    stdout.writeln('   pesos:      ${model.weightsPath}');
    stdout.writeln('   importados: ${model.isImportedWeights}');
    stdout.writeln('   imgsz: ${model.imgsz}  conf: ${model.confidenceThreshold}'
        '  backbone: ${model.backbone}  epocas: ${model.epochs}');

    final assignments = await isar.modelFernieModels.where().findAll();
    for (final one in assignments) {
      await one.model.load();
      if (one.model.value?.id != model.id) continue;

      await one.fernie.load();
      stdout.writeln('   clase ${one.classIndex} → ${one.fernie.value?.name}');
    }
  }

  await isar.close();
}
