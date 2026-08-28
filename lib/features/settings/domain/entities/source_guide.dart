import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/l10n/app_localizations.dart';

/// Un paso de la guía de una fuente.
class SourceGuideStep {
  final String text;

  /// Un valor que hay que poner tal cual en la otra web y que se ofrece copiado.
  ///
  /// Se escriben mal y el error no se ve por ninguna parte: la web acepta lo que
  /// sea y luego no funciona nada, sin decir por qué.
  final String? copyable;

  /// El paso que se falla.
  ///
  /// Hay uno en casi todas, y siempre es el mismo tipo de paso: uno que la web
  /// deja pasar sin quejarse y que rompe todo lo demás en silencio.
  final bool isCritical;

  const SourceGuideStep(this.text, {this.copyable, this.isCritical = false});
}

/// Cómo se conecta Fern con una fuente remota, paso a paso.
///
/// Cada plataforma pide una cosa distinta y ninguna se puede evitar: unas
/// quieren que registres una aplicación, otras una clave de su ficha de usuario
/// y otras que entres tú porque tienen captcha. Lo que sí se puede es que no
/// haya que ir a buscar cómo se hace a ninguna otra parte, que es lo que
/// desanima antes de empezar.
///
/// Es una tabla y no un diálogo por plataforma a propósito: añadir una fuente es
/// añadir una entrada aquí.
class SourceGuide {
  final String title;
  final String intro;
  final List<SourceGuideStep> steps;

  /// Lo que conviene saber y no es un paso: qué pasa cuando caduca, qué no hay
  /// que hacer, dónde se guarda lo que se pega.
  final List<String> notes;

  /// A dónde lleva el botón, y cómo se llama.
  ///
  /// Siempre al navegador de la propia aplicación: así la sesión ya está puesta
  /// y no hay que entrar dos veces.
  final String openLabel;
  final String openUrl;

  const SourceGuide({
    required this.title,
    required this.intro,
    required this.steps,
    required this.openLabel,
    required this.openUrl,
    this.notes = const [],
  });
}

/// La guía de [source], o `null` si esa fuente no necesita ninguna.
SourceGuide? sourceGuideFor(ImportSource source, AppLocalizations texts) {
  return switch (source) {
    ImportSource.reddit => _reddit(texts),
    ImportSource.danbooru => _danbooru(texts),
    ImportSource.gelbooru => _gelbooru(texts),
    ImportSource.pixiv => _pixiv(texts),
    ImportSource.pinterest => _pinterest(texts),
    ImportSource.pawchive => _pawchive(texts),
    _ => null,
  };
}

/// Reddit: hay que registrar una aplicación de tipo *script*.
SourceGuide _reddit(AppLocalizations texts) => SourceGuide(
      title: texts.redditGuideTitle,
      intro: texts.redditGuideIntro,
      openLabel: texts.redditGuideOpen,
      openUrl: redditAppsUrl,
      steps: [
        SourceGuideStep(texts.redditGuideStep1),
        SourceGuideStep(texts.redditGuideStep2),
        // Con cualquier otro tipo Reddit crea la aplicación igual y luego
        // rechaza cada petición sin decir por qué.
        SourceGuideStep(texts.redditGuideStep3, isCritical: true),
        SourceGuideStep(texts.redditGuideStep4, copyable: redditRedirectUri),
        SourceGuideStep(texts.redditGuideStep5),
        SourceGuideStep(texts.redditGuideStep6),
        SourceGuideStep(texts.redditGuideStep7),
      ],
      notes: [texts.redditGuideTwoFactor, texts.redditGuidePrivacy],
    );

/// Danbooru: una clave de API que se saca de la ficha de usuario.
SourceGuide _danbooru(AppLocalizations texts) => SourceGuide(
      title: texts.danbooruGuideTitle,
      intro: texts.danbooruGuideIntro,
      openLabel: texts.sourceGuideOpenSite,
      openUrl: danbooruAccountUrl,
      steps: [
        SourceGuideStep(texts.danbooruGuideStep1),
        SourceGuideStep(texts.danbooruGuideStep2),
        SourceGuideStep(texts.danbooruGuideStep3),
        SourceGuideStep(texts.danbooruGuideStep4),
        // Se pega la contraseña en vez de la clave: Danbooru la acepta y
        // sencillamente no devuelve nada, sin decir que el problema es ése.
        SourceGuideStep(texts.danbooruGuideStep5, isCritical: true),
      ],
      notes: [texts.danbooruGuideNote, texts.sourceGuidePrivacy],
    );

/// Gelbooru: las dos mitades de la misma línea, que es donde se falla.
SourceGuide _gelbooru(AppLocalizations texts) => SourceGuide(
      title: texts.gelbooruGuideTitle,
      intro: texts.gelbooruGuideIntro,
      openLabel: texts.sourceGuideOpenSite,
      openUrl: gelbooruOptionsUrl,
      steps: [
        SourceGuideStep(texts.gelbooruGuideStep1),
        SourceGuideStep(texts.gelbooruGuideStep2),
        SourceGuideStep(texts.gelbooruGuideStep3),
        // Es una sola línea con los dos valores dentro, y se pega entera en un
        // campo: entonces no funciona ninguno de los dos.
        SourceGuideStep(texts.gelbooruGuideStep4, isCritical: true),
        SourceGuideStep(texts.gelbooruGuideStep5),
      ],
      notes: [texts.sourceGuidePrivacy],
    );

/// Pixiv: no hay claves. Se entra y se guarda la sesión.
SourceGuide _pixiv(AppLocalizations texts) => SourceGuide(
      title: texts.pixivGuideTitle,
      intro: texts.pixivGuideIntro,
      openLabel: texts.sourceGuideOpenLogin,
      openUrl: pixivLoginUrl,
      steps: [
        SourceGuideStep(texts.sessionGuideStep1),
        SourceGuideStep(texts.sessionGuideStep2),
        SourceGuideStep(texts.sessionGuideStep3, isCritical: true),
        SourceGuideStep(texts.pixivGuideStep4),
      ],
      notes: [texts.sessionGuideExpires],
    );

/// Pinterest: el nombre basta para lo público; la sesión añade lo secreto.
SourceGuide _pinterest(AppLocalizations texts) => SourceGuide(
      title: texts.pinterestGuideTitle,
      intro: texts.pinterestGuideIntro,
      openLabel: texts.sourceGuideOpenLogin,
      openUrl: pinterestLoginUrl,
      steps: [
        SourceGuideStep(texts.pinterestGuideStep1),
        SourceGuideStep(texts.pinterestGuideStep2),
        SourceGuideStep(texts.sessionGuideStep2),
        SourceGuideStep(texts.sessionGuideStep3, isCritical: true),
      ],
      notes: [texts.sessionGuideExpires],
    );

/// Pawchive: igual que Pixiv, y con la decisión de qué se trae.
SourceGuide _pawchive(AppLocalizations texts) => SourceGuide(
      title: texts.pawchiveGuideTitle,
      intro: texts.pawchiveGuideIntro,
      openLabel: texts.sourceGuideOpenLogin,
      openUrl: pawchiveLoginUrl,
      steps: [
        SourceGuideStep(texts.sessionGuideStep1),
        SourceGuideStep(texts.sessionGuideStep2),
        SourceGuideStep(texts.sessionGuideStep3, isCritical: true),
        SourceGuideStep(texts.pawchiveGuideStep4),
      ],
      notes: [texts.sessionGuideExpires, texts.pawchiveGuideLinks],
    );
