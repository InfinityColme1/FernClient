import 'package:equatable/equatable.dart';

/// Lo que hace falta para entrar en la cuenta de Reddit del usuario.
///
/// Son las cuatro credenciales del acceso por contraseña de su API: las dos de
/// la aplicación que el usuario ha registrado en Reddit ([clientId] y
/// [clientSecret]) y las dos de su cuenta. Las cuatro se guardan en las
/// preferencias del equipo, así que la pantalla enseña las sensibles ocultas.
class RedditSettingsEntity extends Equatable {
  final String clientId;
  final String clientSecret;
  final String username;
  final String password;

  const RedditSettingsEntity({
    this.clientId = '',
    this.clientSecret = '',
    this.username = '',
    this.password = '',
  });

  /// Están las cuatro: sin alguna de ellas no se puede ni pedir el permiso de
  /// acceso, así que ni se intenta.
  bool get isComplete =>
      clientId.trim().isNotEmpty &&
      clientSecret.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.isNotEmpty;

  RedditSettingsEntity copyWith({
    String? clientId,
    String? clientSecret,
    String? username,
    String? password,
  }) {
    return RedditSettingsEntity(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [clientId, clientSecret, username, password];
}
