import 'package:equatable/equatable.dart';


class TagEntity extends Equatable{

  final int id;
  final String name;

  final String ? picturePath;

  final List<TagEntity> children;

  const TagEntity({
    required this.id,
    required this.name,
    required this.children,
    this.picturePath
  });

  @override
  List<Object?> get props => [
    id,
    name,
    children,
    picturePath
  ];

}