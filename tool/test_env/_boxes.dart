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

Future<void> main() async {
  final library = [
    r'build\windows\x64\runner\Debug\isar.dll',
  ].firstWhere((p) => File(p).existsSync());
  Isar.initializeIsarCore(libraries: {Abi.current(): library});
  final isar = await Isar.open([
    TagModelSchema, PersonaModelSchema, CreatorModelSchema,
    MediaSummaryModelSchema, MediaModelSchema,
    FernieModelSchema, FernieRegionModelSchema,
    RecognitionModelModelSchema, ModelFernieModelSchema,
    ModelTreeNodeModelSchema, ModelTreeEdgeModelSchema,
    RecognitionResultModelSchema,
  ], directory: r'C:\Users\Mauricio\Documents');

  final rows = await isar.recognitionResultModels.where().findAll();
  final conCaja = rows.where((r) => r.x != null && r.w != null).toList();
  stdout.writeln('resultados=${rows.length} conCaja=${conCaja.length}');
  for (final row in conCaja.take(4)) {
    stdout.writeln('  x=${row.x!.toStringAsFixed(3)} y=${row.y!.toStringAsFixed(3)} '
        'w=${row.w!.toStringAsFixed(3)} h=${row.h!.toStringAsFixed(3)}');
  }
  await isar.close();
}
