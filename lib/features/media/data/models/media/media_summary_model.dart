import 'package:isar/isar.dart';

import 'media_model.dart';

part 'media_summary_model.g.dart';

@collection
@Name("MediaSummaries")
class MediaSummaryModel {

  Id id = Isar.autoIncrement;

  late String path;

  final details = IsarLink<MediaModel>();
}