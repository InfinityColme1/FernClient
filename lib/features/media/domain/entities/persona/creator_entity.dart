import 'package:Fern/features/media/domain/entities/persona/persona_entity.dart';


class CreatorEntity extends PersonaEntity {

  final List<String> ? socialProfiles;

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

  const CreatorEntity({
    required super.id,
    required super.name,
    super.picturePath,
    this.socialProfiles,
    this.sourceUrls = const [],
  });

  CreatorEntity copyWith({
    String? name,
    String? picturePath,
    List<String>? socialProfiles,
    List<String>? sourceUrls,
  }) {
    return CreatorEntity(
      id: id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      socialProfiles: socialProfiles ?? this.socialProfiles,
      sourceUrls: sourceUrls ?? this.sourceUrls,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    picturePath,
    socialProfiles,
    sourceUrls
  ];

}
