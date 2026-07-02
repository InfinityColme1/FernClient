import 'package:Fern/features/media/domain/entities/persona/persona_entity.dart';


class CreatorEntity extends PersonaEntity {

  final List<String> ? socialProfiles;

  const CreatorEntity({
    required super.id,
    required super.name,
    this.socialProfiles,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    socialProfiles
  ];

}