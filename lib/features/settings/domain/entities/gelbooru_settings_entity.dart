import 'package:equatable/equatable.dart';

/// Lo que hace falta para entrar en la cuenta de Gelbooru del usuario.
///
/// Son dos datos que salen del mismo sitio (las opciones de la cuenta, en el
/// apartado de credenciales de la API): el identificador de la cuenta, que es
/// un número, y su clave. La contraseña no hace falta.
///
/// Se guardan en las preferencias del equipo, así que la pantalla enseña la
/// clave oculta.
class GelbooruSettingsEntity extends Equatable {
  final String userId;
  final String apiKey;

  const GelbooruSettingsEntity({this.userId = '', this.apiKey = ''});

  /// Están los dos y el identificador es un número: cualquier otra cosa no es
  /// un identificador de Gelbooru, y sin él no se sabe a quién pedirle los
  /// favoritos.
  bool get isComplete =>
      apiKey.trim().isNotEmpty &&
      RegExp(r'^\d+$').hasMatch(userId.trim());

  GelbooruSettingsEntity copyWith({String? userId, String? apiKey}) {
    return GelbooruSettingsEntity(
      userId: userId ?? this.userId,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object?> get props => [userId, apiKey];
}
