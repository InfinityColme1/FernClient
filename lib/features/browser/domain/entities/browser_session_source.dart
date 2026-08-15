import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';

/// Una fuente remota cuya sesión se puede recoger del navegador de la
/// aplicación en lugar de pedírsela al usuario.
///
/// Hay plataformas en las que no se puede entrar con usuario y contraseña desde
/// fuera: tienen captcha, verificación por correo o comprobaciones del
/// navegador, y lo único que se puede hacer es que el usuario entre él mismo y
/// quedarse con la sesión que quede abierta. Eso es lo que describe esto: en qué
/// sitio hay que mirar, qué cookie es la sesión y a qué ajuste va.
///
/// Es una tabla y no código repartido a propósito: añadir una plataforma es
/// añadir una línea aquí, y quitar el navegador entero no deja nada suelto.
class BrowserSessionSource {
  /// La fuente de importación a la que pertenece la sesión, que es lo que se
  /// enseña al usuario.
  final ImportSource source;

  /// El sitio con el que se piden las cookies.
  final String siteUrl;

  /// La página en la que se entra en la plataforma. Es a donde se lleva al
  /// usuario cuando quiere importar de ella y todavía no hay sesión.
  final String loginUrl;

  /// La etiqueta de origen con la que nace lo que se traiga de esta plataforma,
  /// para que salga bajo su nombre y no bajo el del navegador.
  final String tagName;

  /// Lo que haga falta mandar para poder descargar sus ficheros. Hay servidores
  /// de contenidos que sólo los dan a quien dice venir de su web.
  final Map<String, String> downloadHeaders;

  /// El dominio con el que se reconoce que el navegador está en esta
  /// plataforma. Vale él y lo que cuelgue de él.
  final String host;

  /// El nombre de la cookie que es la sesión.
  final String cookieName;

  /// Sin sesión no se puede importar de esta plataforma.
  ///
  /// Lo normal es que sí (es lo único que la identifica), pero hay alguna de la
  /// que se puede traer lo público sin entrar, y ahí la sesión es un extra. La
  /// diferencia importa en la pantalla de importación: a una fuente a la que
  /// sólo le falta la sesión se la manda a iniciarla, y a la que le falta otra
  /// cosa, no.
  final bool isSessionRequired;

  /// Dónde va lo recogido dentro de los ajustes de la aplicación.
  final AppSettingsEntity Function(AppSettingsEntity settings, String value)
      apply;

  const BrowserSessionSource({
    required this.source,
    required this.siteUrl,
    required this.loginUrl,
    required this.host,
    required this.cookieName,
    required this.tagName,
    required this.apply,
    this.isSessionRequired = true,
    this.downloadHeaders = const {},
  });

  /// Si [url] es de esta plataforma.
  ///
  /// La comparación es por punto para que un dominio que acabe igual (algo
  /// como `nopixiv.net`) no pase por el bueno.
  bool matches(Uri? url) {
    final name = url?.host.toLowerCase();
    if (name == null || name.isEmpty) return false;

    return name == host || name.endsWith('.$host');
  }
}

/// La cookie de sesión de Pixiv es lo único que necesita su fuente, así que
/// entra tal cual en sus ajustes.
AppSettingsEntity _withPixivSession(AppSettingsEntity settings, String value) {
  return settings.copyWith(pixiv: settings.pixiv.copyWith(sessionId: value));
}

/// La de Pinterest se guarda junto al nombre de la cuenta, que es lo que se
/// escribe a mano: la sesión sólo añade los tableros secretos.
AppSettingsEntity _withPinterestSession(
  AppSettingsEntity settings,
  String value,
) {
  return settings.copyWith(
    pinterest: settings.pinterest.copyWith(sessionId: value),
  );
}

/// Las plataformas de las que el navegador sabe recoger la sesión.
const browserSessionSources = <BrowserSessionSource>[
  BrowserSessionSource(
    source: ImportSource.pixiv,
    siteUrl: pixivSiteUrl,
    loginUrl: pixivLoginUrl,
    host: pixivApiHost,
    cookieName: pixivSessionCookieName,
    tagName: pixivSourceTagName,
    apply: _withPixivSession,
    // Su servidor de contenidos sólo da la imagen a quien dice venir de su web.
    downloadHeaders: PixivApiClient.imageHeaders,
  ),
  BrowserSessionSource(
    source: ImportSource.pinterest,
    siteUrl: pinterestSiteUrl,
    loginUrl: pinterestLoginUrl,
    host: pinterestApiHost,
    cookieName: pinterestSessionCookieName,
    tagName: pinterestSourceTagName,
    apply: _withPinterestSession,
    // Lo guardado en tableros públicos se trae sólo con el nombre de la cuenta.
    isSessionRequired: false,
  ),
];

/// La plataforma de [source], si es una de las que el navegador sabe manejar.
///
/// Es por donde entra la pantalla de importación: sirve para saber si de una
/// fuente sin configurar se puede ir a iniciar sesión, y por dónde.
BrowserSessionSource? browserSessionFor(ImportSource source) {
  for (final each in browserSessionSources) {
    if (each.source == source) return each;
  }

  return null;
}
