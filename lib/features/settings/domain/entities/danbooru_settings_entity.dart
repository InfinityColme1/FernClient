import 'package:equatable/equatable.dart';

/// Lo que hace falta para entrar en la cuenta de Danbooru del usuario.
///
/// Son dos datos: el nombre de la cuenta y una clave de API, que el usuario
/// saca de su perfil y puede revocar cuando quiera sin tocar su contraseña. Con
/// eso basta para pedir lo que tiene en favoritos, así que no hay ninguna razón
/// para guardarle la contraseña.
///
/// Se guardan en las preferencias del equipo, así que la pantalla enseña la
/// clave oculta.
class DanbooruSettingsEntity extends Equatable {
  final String username;
  final String apiKey;

  const DanbooruSettingsEntity({this.username = '', this.apiKey = ''});

  /// Están los dos: sin alguno de ellos no se puede pedir nada, así que ni se
  /// intenta.
  bool get isComplete =>
      username.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  DanbooruSettingsEntity copyWith({String? username, String? apiKey}) {
    return DanbooruSettingsEntity(
      username: username ?? this.username,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object?> get props => [username, apiKey];
}
