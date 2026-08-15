import 'package:equatable/equatable.dart';

/// Lo que hace falta para entrar en la cuenta de Pixiv del usuario.
///
/// Es un solo dato: la cookie de sesión (`PHPSESSID`) que el usuario copia de
/// su navegador. Pixiv no tiene una API pública ni un permiso que se pueda
/// pedir con usuario y contraseña, así que se habla con la misma API que usa su
/// web y se entra igual que entra ella.
///
/// La cookie lleva dentro el identificador de la cuenta: es `1234567_` seguido
/// de una tirada de caracteres, y ese número es el usuario. Por eso no hay que
/// preguntarlo aparte, y por eso una cookie sin esa forma no sirve.
///
/// Se guarda en las preferencias del equipo, así que la pantalla la enseña
/// oculta.
class PixivSettingsEntity extends Equatable {
  final String sessionId;

  const PixivSettingsEntity({this.sessionId = ''});

  /// El identificador de la cuenta que va dentro de la cookie, o `null` si lo
  /// que hay escrito no tiene esa forma.
  String? get userId {
    final value = sessionId.trim();
    final separator = value.indexOf('_');
    if (separator <= 0) return null;

    final id = value.substring(0, separator);
    // Sólo dígitos: cualquier otra cosa antes del guión es que lo pegado no es
    // una cookie de sesión de Pixiv.
    if (!RegExp(r'^\d+$').hasMatch(id)) return null;

    return id;
  }

  /// Hay una cookie y de ella se puede sacar la cuenta: sin eso no se sabe ni a
  /// quién pedirle los marcadores, así que ni se intenta.
  bool get isComplete => userId != null;

  PixivSettingsEntity copyWith({String? sessionId}) {
    return PixivSettingsEntity(sessionId: sessionId ?? this.sessionId);
  }

  @override
  List<Object?> get props => [sessionId];
}
