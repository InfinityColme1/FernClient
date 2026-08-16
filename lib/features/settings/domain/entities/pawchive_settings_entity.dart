import 'package:equatable/equatable.dart';

/// Lo que hace falta para entrar en la cuenta de Pawchive del usuario.
///
/// Es un solo dato, y no se escribe: la galleta de sesión que el navegador de
/// la aplicación recoge cuando el usuario entra en su cuenta. Lo que se importa
/// son sus favoritos, así que sin sesión no hay nada que pedir.
class PawchiveSettingsEntity extends Equatable {
  final String sessionId;

  /// Se importa lo de los creadores marcados en lugar de las publicaciones
  /// marcadas.
  ///
  /// Son dos formas distintas de entender "lo que me interesa": las
  /// publicaciones marcadas son lo que el usuario ha ido guardando una a una, y
  /// los creadores marcados son todo lo que publiquen unos autores. Lo segundo
  /// trae mucho más, así que lo elige el usuario.
  final bool byFavoriteCreators;

  const PawchiveSettingsEntity({
    this.sessionId = '',
    this.byFavoriteCreators = false,
  });

  bool get isComplete => sessionId.trim().isNotEmpty;

  PawchiveSettingsEntity copyWith({
    String? sessionId,
    bool? byFavoriteCreators,
  }) {
    return PawchiveSettingsEntity(
      sessionId: sessionId ?? this.sessionId,
      byFavoriteCreators: byFavoriteCreators ?? this.byFavoriteCreators,
    );
  }

  @override
  List<Object?> get props => [sessionId, byFavoriteCreators];
}
