import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:isar/isar.dart';

import 'media/media_model.dart';

part 'tag_model.g.dart';

@collection
@Name("Tags")
class TagModel {

  Id id = Isar.autoIncrement;

  late String name;

  String ? picturePath;

  /// Direcciones de las que sale contenido que lleva esta etiqueta, ya
  /// normalizadas. Es lo que mira el etiquetado automático al importar.
  List<String> sourceUrls = const [];

  /// Contenido no apto: lo que lleve esta etiqueta no se ve con el modo NSFW
  /// apagado.
  ///
  /// La marca se guarda **sólo donde el usuario la puso**, y se propaga a la
  /// rama de hijas al leerla (ver `NsfwIndex`). Guardarla propagada obligaría a
  /// reescribir media biblioteca cada vez que se mueve una etiqueta de sitio, y
  /// a acertar siempre: una rama que se mueve y se queda con la marca vieja es
  /// contenido bloqueado que nadie sabe por qué lo está.
  bool isNsfw = false;

  final children = IsarLinks<TagModel>();

  /// Etiquetas relacionadas que no son ni madres ni hijas.
  ///
  /// «Cuando pongas ésta, pon también éstas». Sirve para lo que va junto sin
  /// colgar de nada: un personaje y su serie, un juego y su estudio.
  ///
  /// **Simétrico**: si A tiene a B, B tiene a A. Lo fuerza el repositorio al
  /// guardar, no la pantalla, porque una relación a medias no se ve —la
  /// etiqueta que no sabe que es hermana de la otra sencillamente no la pone— y
  /// nadie la encontraría hasta preguntarse por qué a veces sí y a veces no.
  ///
  /// **Un solo salto** al aplicarlas: si A es hermana de B y B de C, poner A no
  /// pone C. Encadenarlas convertiría una etiqueta en media biblioteca.
  final siblings = IsarLinks<TagModel>();
  
  @Backlink(to: 'tags')
  final personas = IsarLinks<PersonaModel>();

  @Backlink(to: 'tags')
  final media = IsarLinks<MediaModel>();

  
  TagModel({
    required this.id,
    required this.name,
    this.picturePath,
    this.sourceUrls = const [],
    this.isNsfw = false,
  });

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      sourceUrls: sourceUrls,
      isNsfw: isNsfw,
      children: children.map((tag) {return tag.toEntity();}).toList(),
      // Planas: sin sus hijas ni sus propias hermanas. Lo que hace falta de una
      // hermana es su nombre, y recorrer sus ramas aquí acabaría cargando media
      // base de datos por pintar una lista de tres nombres.
      siblings: [
        for (final sibling in siblings)
          TagEntity(
            id: sibling.id,
            name: sibling.name,
            picturePath: sibling.picturePath,
            isNsfw: sibling.isNsfw,
            children: const [],
          ),
      ],
    );
  }

  /// Una etiqueta recién creada llega con [unsavedId]; en ese caso se deja que
  /// Isar le asigne el identificador, o todas se escribirían sobre la misma
  /// fila.
  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id == unsavedId ? Isar.autoIncrement : entity.id,
      picturePath: entity.picturePath,
      name: entity.name,
      sourceUrls: entity.sourceUrls,
      isNsfw: entity.isNsfw,
    );
  }
}