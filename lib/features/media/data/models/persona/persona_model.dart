import 'package:isar/isar.dart';

import '../tag_model.dart';

part 'persona_model.g.dart';

@collection
@Name("Personas")
class PersonaModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  final tags = IsarLinks<TagModel>();
}