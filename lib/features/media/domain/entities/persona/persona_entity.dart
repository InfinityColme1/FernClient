import 'package:equatable/equatable.dart';
import '../tag_entity.dart';


class PersonaEntity extends Equatable {

  final int id;
  final String name;
  final String ? picturePath;
  final List<TagEntity> ? tags;

  const PersonaEntity({
    required this.id,
    required this.name,
    this.picturePath,
    this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    picturePath,
    tags
  ];

}