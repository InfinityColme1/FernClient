import 'package:isar/isar.dart';

part 'creator_model.g.dart';

@collection
@Name("Creators")
class CreatorModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  List<String> ? socialProfiles;
}