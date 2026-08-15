import 'package:Fern/features/browser/domain/entities/browser_session_source.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Recoge del navegador de la aplicación la sesión que el usuario acaba de
/// abrir en una plataforma.
///
/// La cookie de sesión no se puede leer desde la propia página (viene marcada
/// como `HttpOnly`, que es justo para eso), así que se le pide al almacén de
/// cookies del navegador, que es de donde salen las que el usuario copiaba a
/// mano de su navegador de siempre.
class BrowserSessionService {
  const BrowserSessionService();

  /// La plataforma a la que pertenece la página que se está viendo, o `null` si
  /// no es ninguna de las que la aplicación sabe importar.
  BrowserSessionSource? sourceOf(Uri? url) {
    for (final source in browserSessionSources) {
      if (source.matches(url)) return source;
    }

    return null;
  }

  /// La sesión que el navegador tenga abierta en [source], o `null` si ahí
  /// todavía no hay ninguna.
  ///
  /// Que no la haya es lo normal antes de entrar, así que no es un fallo: es
  /// que al usuario le queda iniciar sesión.
  Future<String?> sessionOf(BrowserSessionSource source) async {
    final cookie = await CookieManager.instance().getCookie(
      url: WebUri(source.siteUrl),
      name: source.cookieName,
    );

    final value = cookie?.value?.toString().trim();

    return value == null || value.isEmpty ? null : value;
  }
}
