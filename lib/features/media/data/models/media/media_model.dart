import 'package:isar/isar.dart';

import '../persona/creator_model.dart';
import '../tag_model.dart';

part 'media_model.g.dart';

@collection
@Name("Media")
class MediaModel {

  Id id = Isar.autoIncrement;

  late String path;

  late DateTime downloaded;

  late bool isFavorite;

  final creator = IsarLink<CreatorModel>();

  final tags = IsarLinks<TagModel>();

  final source = IsarLink<TagModel>();
}