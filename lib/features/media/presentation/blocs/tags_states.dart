import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:equatable/equatable.dart';

/// Las etiquetas de la aplicación tal y como las pinta el menú lateral: sólo las
/// raíces, cada una con sus descendientes colgando.
class TagsState extends Equatable {
  final List<TagEntity> tags;

  /// Si ya se ha leído la base de datos. Sirve para no dar por hecho que no hay
  /// etiquetas mientras la primera lectura está en marcha.
  final bool isLoaded;

  const TagsState({
    this.tags = const [],
    this.isLoaded = false,
  });

  @override
  List<Object?> get props => [tags, isLoaded];
}
