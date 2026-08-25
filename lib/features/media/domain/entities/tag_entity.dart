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

  /// La etiqueta está marcada como NSFW.
  ///
  /// Es la marca **propia**, la que el usuario puso aquí: una etiqueta que queda
  /// escondida por colgar de otra marcada tiene esto en `false`. Es lo que
  /// enseña y cambia el interruptor de la ficha, porque es lo único que se puede
  /// quitar desde ella.
  final bool isNsfw;

  /// Lo suyo está bajo el filtro NSFW, sea por su marca o por la de su madre.
  ///
  /// Va aparte de [isNsfw] porque son dos preguntas distintas y se usan en
  /// sitios distintos: la ficha enseña la marca propia —la única que puede
  /// quitar—, y las listas y los buscadores enseñan **esto**, que es lo que le
  /// dice al usuario que esa etiqueta esconde contenido. Marcar sólo las propias
  /// dejaría a las hijas escondiendo cosas sin avisar.
  final bool isUnderNsfw;

  /// Etiquetas relacionadas que no son ni madres ni hijas.
  ///
  /// «Cuando pongas ésta, pon también éstas». Llegan planas —sin hijas ni
  /// hermanas suyas— porque lo único que hace falta de ellas es el nombre y el
  /// identificador: quien las mira las está listando para quitar una o añadir
  /// otra, no recorriendo un árbol.
  final List<TagEntity> siblings;

  const TagEntity({
    required this.id,
    required this.name,
    required this.children,
    this.picturePath,
    this.sourceUrls = const [],
    this.isNsfw = false,
    this.siblings = const [],
    bool? isUnderNsfw,
  }) : isUnderNsfw = isUnderNsfw ?? isNsfw;

  TagEntity copyWith({
    String? name,
    String? picturePath,
    List<TagEntity>? children,
    List<String>? sourceUrls,
    bool? isNsfw,
    bool? isUnderNsfw,
    List<TagEntity>? siblings,
  }) {
    return TagEntity(
      id: id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      children: children ?? this.children,
      sourceUrls: sourceUrls ?? this.sourceUrls,
      isNsfw: isNsfw ?? this.isNsfw,
      isUnderNsfw: isUnderNsfw ?? this.isUnderNsfw,
      siblings: siblings ?? this.siblings,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    children,
    picturePath,
    sourceUrls,
    isNsfw,
    isUnderNsfw,
    siblings,
  ];

}
