import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:equatable/equatable.dart';

/// Los creadores de la aplicación, ordenados por nombre.
///
/// Es el equivalente de `TagsState` sin jerarquía: un creador no cuelga de otro,
/// así que la lista es plana.
class CreatorsState extends Equatable {
  final List<CreatorEntity> creators;

  /// Si ya se ha leído la base de datos. Sirve para no dar por hecho que no hay
  /// creadores mientras la primera lectura está en marcha.
  final bool isLoaded;

  /// Hay una lectura de los creadores en marcha, sea la primera o una posterior
  /// (crear, editar o borrar uno los vuelve a leer). Es lo que enseña el
  /// indicador de espera de la pantalla de gestión de creadores.
  final bool isBusy;

  const CreatorsState({
    this.creators = const [],
    this.isLoaded = false,
    this.isBusy = false,
  });

  CreatorsState copyWith({
    List<CreatorEntity>? creators,
    bool? isLoaded,
    bool? isBusy,
  }) {
    return CreatorsState(
      creators: creators ?? this.creators,
      isLoaded: isLoaded ?? this.isLoaded,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [creators, isLoaded, isBusy];
}
