import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/duplicates/data/models/duplicate_group_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media/media_model.dart';
import '../models/media/media_summary_model.dart';
import '../models/persona/creator_model.dart';
import '../models/persona/persona_model.dart';
import '../models/blocked_import_model.dart';
import '../models/tag_model.dart';


class AppDatabase {

  AppDatabase();

  Future<Isar> getIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
        [
          BlockedImportModelSchema,
          // Por qué un contenido acabó con cada etiqueta puesta. Colección
          // nueva: aditiva, y lo que ya hay en la base no se toca.
          MediaTagLogModelSchema,
      TagModelSchema, PersonaModelSchema, CreatorModelSchema,
          MediaSummaryModelSchema, MediaModelSchema,
          // Reconocimiento: son colecciones nuevas, así que no hace falta
          // migrar nada. Basta con que estén aquí para que Isar las cree.
          FernieModelSchema, FernieRegionModelSchema,
          RecognitionModelModelSchema, ModelFernieModelSchema,
          // El árbol que decide en qué orden se ejecutan los modelos. Van
          // aparte de los modelos porque un modelo existe sin estar en el árbol
          // —y entonces no se ejecuta nunca al reconocer.
          ModelTreeNodeModelSchema, ModelTreeEdgeModelSchema,
          DuplicateGroupModelSchema,
          // Lo que los modelos proponen sobre un contenido, que no es lo mismo
          // que lo que el contenido tiene: hasta que el usuario acepta, una
          // sugerencia no toca nada suyo.
          RecognitionResultModelSchema
        ],
        directory: dir.path
    );

    return isar;
  }

}