import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media/media_model.dart';
import '../models/media/media_summary_model.dart';
import '../models/persona/creator_model.dart';
import '../models/persona/persona_model.dart';
import '../models/tag_model.dart';


class AppDatabase {

  AppDatabase();

  Future<Isar> getIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
        [
          TagModelSchema, PersonaModelSchema, CreatorModelSchema,
          MediaSummaryModelSchema, MediaModelSchema,
          // Reconocimiento: son colecciones nuevas, así que no hace falta
          // migrar nada. Basta con que estén aquí para que Isar las cree.
          FernieModelSchema, FernieRegionModelSchema
        ],
        directory: dir.path
    );

    return isar;
  }

}