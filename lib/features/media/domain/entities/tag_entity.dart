import 'package:equatable/equatable.dart';


class TagEntity extends Equatable{

  final int id;
  final String name;

  final String ? picturePath;

  final List<TagEntity> children;

  /// Direcciones de las que sale contenido que lleva esta etiqueta.
  ///
  /// Es lo que hace que el etiquetado automático funcione sin saber nada de la
  /// plataforma: lo que se importe de debajo de alguna de ellas nace ya con esta
  /// etiqueta puesta. Se guardan normalizadas (`normalizedSourceUrl`), que es la
  /// forma en la que se comparan.
  final List<String> sourceUrls;

  const TagEntity({
    required this.id,
    required this.name,
    required this.children,
    this.picturePath,
    this.sourceUrls = const [],
  });

  TagEntity copyWith({
    String? name,
    String? picturePath,
    List<TagEntity>? children,
    List<String>? sourceUrls,
  }) {
    return TagEntity(
      id: id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      children: children ?? this.children,
      sourceUrls: sourceUrls ?? this.sourceUrls,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    children,
    picturePath,
    sourceUrls
  ];

}
