import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:isar/isar.dart';

import 'media/media_model.dart';

part 'tag_model.g.dart';

@collection
@Name("Tags")
class TagModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  final children = IsarLinks<TagModel>();
  
  @Backlink(to: 'tags')
  final personas = IsarLinks<PersonaModel>();

  @Backlink(to: 'tags')
  final media = IsarLinks<MediaModel>();
}