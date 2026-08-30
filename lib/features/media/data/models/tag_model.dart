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

  /// Cuáles de [sourceUrls] están marcadas como no aptas.
  ///
  /// Un subconjunto de la otra lista y no una lista de objetos con su marca: así
  /// el campo es aditivo y las direcciones que ya hay guardadas siguen siendo
  /// exactamente lo que eran. Se guardan normalizadas, igual que [sourceUrls],
  /// que es como se comparan las dos listas entre sí.
  List<String> nsfwSourceUrls = const [];

  /// La etiqueta identifica a una persona o a un personaje.
  ///
  /// Es lo único que la separa de las demás, y la separación es sobre todo
  /// conceptual: se gestiona en su propia pantalla en vez de mezclada con los
  /// conceptos y las cosas. Fuera de ahí sigue siendo una etiqueta y se comporta
  /// como tal al asignar, al buscar y al colgar de otra.
  ///
  /// De fábrica `false`: lo que ya hay en la base sigue siendo una etiqueta
  /// normal, que es lo correcto. Separarlas es cosa del usuario, una a una.
  bool isPerson = false;

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
    this.nsfwSourceUrls = const [],
    this.isNsfw = false,
    this.isPerson = false,
  });

  TagEntity toEntity() =>
      toEntityWithChildren(children.map((tag) => tag.toEntity()).toList());

  /// La etiqueta con las hijas que se le digan, en vez de con las suyas.
  ///
  /// **Es el único sitio donde se mapean los campos de una etiqueta**, y existe
  /// para que siga siendo el único: quien arma el árbol necesita poner sus
  /// propias hijas (ordenadas, con el corte de ciclos y con la marca heredada),
  /// y si para eso tuviera que construir la `TagEntity` a mano acabaría
  /// dejándose campos por el camino. Es lo que pasó: el árbol se armaba sin las
  /// direcciones ni las hermanas, y guardar el nombre de una etiqueta le borraba
  /// las direcciones.
  ///
  /// Recorrer la descendencia con `toEntity()` por cada nodo del árbol sería
  /// además cuadrático, así que quien ya la tiene armada la pasa por aquí.
  TagEntity toEntityWithChildren(List<TagEntity> children) {
    return TagEntity(
      id: id,
      name: name,
      picturePath: picturePath,
      sourceUrls: sourceUrls,
      nsfwSourceUrls: nsfwSourceUrls,
      isNsfw: isNsfw,
      isPerson: isPerson,
      children: children,
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
      nsfwSourceUrls: entity.nsfwSourceUrls,
      isNsfw: entity.isNsfw,
      isPerson: entity.isPerson,
    );
  }
}