import 'package:Fern/features/media/domain/entities/persona/persona_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';


class CreatorEntity extends PersonaEntity {

  final List<String> ? socialProfiles;

  /// Cuáles de [socialProfiles] están marcados como no aptos. Con el bloqueo
  /// cerrado no se enseñan.
  final List<String> nsfwSocialProfiles;

  /// Direcciones de las que sale contenido de este creador.
  ///
  /// Es lo mismo que las de una etiqueta: lo que se importe de debajo de alguna
  /// de ellas nace ya con este creador puesto, sin preguntarle nada a la
  /// plataforma. Se guardan normalizadas (`normalizedSourceUrl`), que es la
  /// forma en la que se comparan.
  ///
  /// No son los [socialProfiles]: aquéllos se enseñan para poder abrirlos en el
  /// navegador y éstas sólo trabajan al importar.
  final List<String> sourceUrls;

  /// Cuáles de [sourceUrls] están marcadas como no aptas.
  ///
  /// Con el bloqueo cerrado no se enseñan, pero siguen asignando el creador al
  /// importar: esconder no es apagar.
  final List<String> nsfwSourceUrls;

  /// El creador está marcado como contenido no apto.
  ///
  /// Con el bloqueo puesto no se ve ni él ni lo suyo: su nombre delata tanto
  /// como el de una etiqueta marcada, y su galería es exactamente lo que la
  /// marca esconde.
  final bool isNsfw;

  /// Las etiquetas que trae consigo.
  ///
  /// Ponerle este creador a un contenido se las pone tambien, con lo que ellas
  /// arrastran: es lo mismo que hacen las direcciones vinculadas al importar,
  /// dicho desde el creador.
  ///
  /// Llega **vacia** salvo que quien lo lea las haya pedido: cargarlas es una
  /// consulta por creador, y la lista de la pantalla de gestion no las enseña.
  final List<TagEntity> tags;

  const CreatorEntity({
    required super.id,
    required super.name,
    super.picturePath,
    this.socialProfiles,
    this.nsfwSocialProfiles = const [],
    this.sourceUrls = const [],
    this.nsfwSourceUrls = const [],
    this.isNsfw = false,
    this.tags = const [],
  });

  CreatorEntity copyWith({
    String? name,
    String? picturePath,
    List<String>? socialProfiles,
    List<String>? nsfwSocialProfiles,
    List<String>? sourceUrls,
    List<String>? nsfwSourceUrls,
    bool? isNsfw,
    List<TagEntity>? tags,
  }) {
    return CreatorEntity(
      id: id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      socialProfiles: socialProfiles ?? this.socialProfiles,
      nsfwSocialProfiles: nsfwSocialProfiles ?? this.nsfwSocialProfiles,
      sourceUrls: sourceUrls ?? this.sourceUrls,
      nsfwSourceUrls: nsfwSourceUrls ?? this.nsfwSourceUrls,
      isNsfw: isNsfw ?? this.isNsfw,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    picturePath,
    socialProfiles,
    nsfwSocialProfiles,
    sourceUrls,
    nsfwSourceUrls,
    isNsfw,
    tags,
  ];

}
