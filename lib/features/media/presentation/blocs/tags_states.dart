import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:equatable/equatable.dart';

/// Las etiquetas de la aplicación tal y como las pinta el menú lateral: sólo las
/// raíces, cada una con sus descendientes colgando.
class TagsState extends Equatable {
  final List<TagEntity> tags;

  /// Si ya se ha leído la base de datos. Sirve para no dar por hecho que no hay
  /// etiquetas mientras la primera lectura está en marcha.
  final bool isLoaded;

  /// Hay una lectura de las etiquetas en marcha, sea la primera o una posterior
  /// (crear, editar o borrar una etiqueta las vuelve a leer). Es lo que enseña el
  /// indicador de espera de la pantalla de gestión de etiquetas.
  final bool isBusy;

  const TagsState({
    this.tags = const [],
    this.isLoaded = false,
    this.isBusy = false,
  });

  TagsState copyWith({
    List<TagEntity>? tags,
    bool? isLoaded,
    bool? isBusy,
  }) {
    return TagsState(
      tags: tags ?? this.tags,
      isLoaded: isLoaded ?? this.isLoaded,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [tags, isLoaded, isBusy];
}
