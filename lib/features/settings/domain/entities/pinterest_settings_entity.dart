import 'package:equatable/equatable.dart';

/// Lo que hace falta para traerse lo que el usuario tiene guardado en Pinterest.
///
/// Basta el nombre de la cuenta: lo guardado en tableros públicos se puede pedir
/// sin entrar en ninguna parte, que es el caso normal. La sesión es un extra
/// para quien tenga tableros secretos, y se recoge del navegador de la
/// aplicación en lugar de escribirse.
class PinterestSettingsEntity extends Equatable {
  final String username;

  /// La galleta de sesión, si el usuario la ha recogido. Vacía en lo normal.
  final String sessionId;

  const PinterestSettingsEntity({this.username = '', this.sessionId = ''});

  /// Con el nombre de la cuenta ya se puede importar; lo demás es opcional.
  bool get isComplete => username.trim().isNotEmpty;

  /// Hay sesión, así que se puede pedir también lo que no se ve desde fuera.
  bool get hasSession => sessionId.trim().isNotEmpty;

  PinterestSettingsEntity copyWith({String? username, String? sessionId}) {
    return PinterestSettingsEntity(
      username: username ?? this.username,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [username, sessionId];
}
