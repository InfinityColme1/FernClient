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
          MediaSummaryModelSchema, MediaModelSchema
        ],
        directory: dir.path
    );

    return isar;
  }

}