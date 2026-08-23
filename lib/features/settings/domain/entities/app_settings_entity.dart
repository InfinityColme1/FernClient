import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pixiv_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:equatable/equatable.dart';

/// Idiomas en los que se puede usar la aplicación.
///
/// [code] es el código ISO con el que se guardará la preferencia y con el que
/// más adelante se resolverán las traducciones; la localización en sí queda
/// fuera de esta pantalla, que sólo elige y recuerda el idioma.
enum AppLanguage {
  english(code: 'en', label: 'English'),
  french(code: 'fr', label: 'Français'),
  spanish(code: 'es', label: 'Castellano'),
  catalan(code: 'ca', label: 'Català');

  const AppLanguage({required this.code, required this.label});

  final String code;
  final String label;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Cómo se reparten los ficheros dentro de la carpeta de la biblioteca.
///
/// Los criterios son excluyentes: o los ficheros quedan sueltos en la raíz, o
/// se agrupan por uno de los tres criterios en subcarpetas de un solo nivel.
/// No afecta a las imágenes de los avatares, que viven en su propia carpeta.
/// Sólo lleva el identificador con el que se guarda: cómo se nombra cada
/// criterio es cosa de la pantalla, que lo traduce.
enum FileOrganizationCriteria {
  flat(id: 'flat'),
  byTag(id: 'tag'),
  bySource(id: 'source'),
  byCreator(id: 'creator');

  const FileOrganizationCriteria({required this.id});

  final String id;

  static FileOrganizationCriteria fromId(String? id) {
    return FileOrganizationCriteria.values.firstWhere(
      (criteria) => criteria.id == id,
      orElse: () => FileOrganizationCriteria.flat,
    );
  }
}

/// Qué hace el visor cuando se da por definitivo un contenido importado.
///
/// El contenido que se acaba de guardar deja de estar en la lista de la pantalla
/// de importación, así que el visor no puede quedarse donde estaba: o se cierra
/// y se vuelve a la rejilla, o pasa al siguiente y se sigue revisando sin salir.
///
/// Lo segundo es lo de fábrica: importar es revisar unos cuantos contenidos
/// seguidos, y cerrar el visor en cada uno obliga a volver a entrar.
enum ViewerSaveBehavior {
  goToNext(id: 'next'),
  closeViewer(id: 'close');

  const ViewerSaveBehavior({required this.id});

  final String id;

  static ViewerSaveBehavior fromId(String? id) {
    return ViewerSaveBehavior.values.firstWhere(
      (behavior) => behavior.id == id,
      orElse: () => ViewerSaveBehavior.goToNext,
    );
  }
}

/// Ajustes de la aplicación tal y como los ve la interfaz.
///
/// [avatarsPath] nunca es nulo: aunque no se haya elegido carpeta, la
/// aplicación siempre copia los avatares a algún sitio (el directorio por
/// defecto que resuelve el repositorio al arrancar).
class AppSettingsEntity extends Equatable {
  final AppLanguage language;

  /// La aplicación ordena físicamente los ficheros de contenido.
  final bool syncLocalFiles;

  /// Con [syncLocalFiles] activo: copiar en vez de mover, conservando el
  /// fichero original donde estuviera.
  final bool copyFiles;

  /// Carpeta que la aplicación gestiona. Sin ella no se mueve nada, aunque
  /// [syncLocalFiles] esté activo.
  final String? libraryPath;

  final String avatarsPath;

  /// Dónde vive todo lo del reconocimiento: el entorno de entrenamiento, los
  /// modelos ya entrenados y los conjuntos de datos que se preparan para
  /// entrenarlos.
  ///
  /// Nunca es nulo, por lo mismo que [avatarsPath]: aunque el usuario no elija
  /// carpeta, la aplicación necesita saber dónde escribir.
  final String recognitionPath;

  /// Cuántos fotogramas se miran de un vídeo al reconocer.
  ///
  /// Es el ajuste que más afecta al tiempo de reconocer una biblioteca: el coste
  /// es una predicción por fotograma. Cinco basta casi siempre; subirlo encuentra
  /// personajes que salen poco, a cambio de tardar proporcionalmente más.
  final int frameSamples;

  /// Si el contenido ya definitivo vuelve a la pantalla de importación cuando se
  /// le encuentra algo que revisar.
  ///
  /// Activado de fábrica, y es el comportamiento que pide la decisión D16: una
  /// sugerencia sin validar es contenido a medias, y dejarlo en la biblioteca
  /// como si nada esconde el trabajo pendiente hasta que alguien se acuerde de
  /// mirarlo.
  ///
  /// Apagarlo no esconde nada: las sugerencias se siguen viendo en el panel del
  /// visor y se aceptan desde ahí. Lo que cambia es que el contenido no se mueve
  /// de sitio.
  final bool returnRecognizedToImport;

  /// Lo que acaba de importarse se manda a reconocer solo.
  ///
  /// Activado de fábrica, que es lo que pide la decisión D15. No cuesta nada
  /// a quien no tiene modelos entrenados: sin ninguno con pesos no se encola
  /// trabajo alguno.
  ///
  /// Apagarlo no quita nada: reconocer sigue estando en la barra de la
  /// pantalla de importación y en los otros tres sitios de la D16. Lo que
  /// cambia es quién decide cuándo se pone el equipo a trabajar.
  final bool recognizeOnImport;

  final FileOrganizationCriteria organization;

  /// Al contenido que llega de una plataforma se le pone además una etiqueta con
  /// el nombre de ésta.
  ///
  /// Apagado de fábrica: de dónde vino el contenido ya se guarda con él
  /// (`MediaSummaryEntity.importSource`) y se filtra por ello desde el botón de
  /// filtros, así que crear una etiqueta por plataforma es una decisión del
  /// usuario y no algo que la aplicación haga por su cuenta.
  final bool autoTagRemoteSource;

  /// La lista de etiquetas del menú lateral enseña el avatar de cada una en vez
  /// del icono de siempre.
  ///
  /// Encendido de fábrica: con el menú plegado el icono es igual para todas y no
  /// dice cuál es cuál, que es justo cuando el avatar hace falta. Las etiquetas
  /// sin avatar se quedan con su icono.
  final bool showListAvatars;

  /// Con qué colores se pinta la aplicación. De fábrica, los que diga el
  /// sistema: la aplicación se pone de noche cuando lo hace el escritorio.
  final AppThemeMode themeMode;

  /// Los colores del tema a medida. Sólo se usan con [AppThemeMode.custom], pero
  /// se guardan siempre: cambiar de tema para mirar otro y volver no puede
  /// perder lo que el usuario había elegido.
  final CustomThemeEntity customTheme;

  /// Qué hace el visor al dar por definitivo un contenido importado.
  final ViewerSaveBehavior viewerSaveBehavior;

  /// Coger la barra de un vídeo lo para.
  ///
  /// Apagado de fábrica: recorrer un vídeo es normalmente buscar un momento
  /// **viéndolo**, y pararlo en cada toque obliga a darle a reproducir otra vez.
  /// El modo de marcar no lo mira: allí siempre para, porque una región se marca
  /// sobre un fotograma quieto y si el contenido siguiera corriendo acabaría
  /// puesta sobre un instante que ya ha pasado.
  final bool pauseWhenSeeking;

  /// Credenciales de la fuente remota de Reddit. Vienen vacías mientras el
  /// usuario no las haya rellenado, que es como la aplicación sabe que esa
  /// fuente todavía no se puede usar.
  final RedditSettingsEntity reddit;

  /// Credenciales de la fuente remota de Danbooru. Viene vacía mientras el
  /// usuario no la haya rellenado, que es como la aplicación sabe que esa
  /// fuente todavía no se puede usar.
  final DanbooruSettingsEntity danbooru;

  /// Credenciales de la fuente remota de Gelbooru. Viene vacía mientras el
  /// usuario no la haya rellenado, que es como la aplicación sabe que esa
  /// fuente todavía no se puede usar.
  final GelbooruSettingsEntity gelbooru;

  /// Lo que hace falta para traerse lo guardado en Pinterest: sólo el nombre de
  /// la cuenta, y la sesión si el usuario la ha recogido.
  final PinterestSettingsEntity pinterest;

  /// La sesión de Pawchive, que se recoge del navegador y no se escribe.
  final PawchiveSettingsEntity pawchive;

  /// La página por la que arranca el navegador de la aplicación cuando se le
  /// pide volver a empezar. Es lo que el usuario entiende por su página de
  /// inicio, y por eso la elige él.
  final String browserHome;

  /// Credenciales de la fuente remota de Pixiv. Viene vacía mientras el usuario
  /// no la haya rellenado, que es como la aplicación sabe que esa fuente
  /// todavía no se puede usar.
  final PixivSettingsEntity pixiv;

  /// Cómo avisa la aplicación de lo que tarda: entrenar, reconocer, buscar
  /// repetidos e importar.
  final NotificationSettingsEntity notifications;

  const AppSettingsEntity({
    this.language = AppLanguage.english,
    this.syncLocalFiles = false,
    this.copyFiles = false,
    this.libraryPath,
    required this.avatarsPath,
    required this.recognitionPath,
    this.frameSamples = defaultFrameSamples,
    this.returnRecognizedToImport = true,
    this.recognizeOnImport = true,
    this.organization = FileOrganizationCriteria.flat,
    this.autoTagRemoteSource = false,
    this.showListAvatars = true,
    this.themeMode = AppThemeMode.system,
    this.customTheme = const CustomThemeEntity(),
    this.viewerSaveBehavior = ViewerSaveBehavior.goToNext,
    this.pauseWhenSeeking = false,
    this.browserHome = browserHomeUrl,
    this.reddit = const RedditSettingsEntity(),
    this.pixiv = const PixivSettingsEntity(),
    this.danbooru = const DanbooruSettingsEntity(),
    this.gelbooru = const GelbooruSettingsEntity(),
    this.pinterest = const PinterestSettingsEntity(),
    this.pawchive = const PawchiveSettingsEntity(),
    this.notifications = const NotificationSettingsEntity(),
  });

  /// Los ficheros sólo se reordenan si el usuario lo ha pedido y ha dicho
  /// dónde.
  bool get managesFiles => syncLocalFiles && (libraryPath?.isNotEmpty ?? false);

  AppSettingsEntity copyWith({
    AppLanguage? language,
    bool? syncLocalFiles,
    bool? copyFiles,
    String? libraryPath,
    String? avatarsPath,
    String? recognitionPath,
    int? frameSamples,
    bool? returnRecognizedToImport,
    bool? recognizeOnImport,
    FileOrganizationCriteria? organization,
    bool? autoTagRemoteSource,
    bool? showListAvatars,
    AppThemeMode? themeMode,
    CustomThemeEntity? customTheme,
    ViewerSaveBehavior? viewerSaveBehavior,
    bool? pauseWhenSeeking,
    String? browserHome,
    RedditSettingsEntity? reddit,
    PixivSettingsEntity? pixiv,
    DanbooruSettingsEntity? danbooru,
    GelbooruSettingsEntity? gelbooru,
    PinterestSettingsEntity? pinterest,
    PawchiveSettingsEntity? pawchive,
    NotificationSettingsEntity? notifications,
  }) {
    return AppSettingsEntity(
      language: language ?? this.language,
      syncLocalFiles: syncLocalFiles ?? this.syncLocalFiles,
      copyFiles: copyFiles ?? this.copyFiles,
      libraryPath: libraryPath ?? this.libraryPath,
      avatarsPath: avatarsPath ?? this.avatarsPath,
      recognitionPath: recognitionPath ?? this.recognitionPath,
      frameSamples: frameSamples ?? this.frameSamples,
      returnRecognizedToImport:
          returnRecognizedToImport ?? this.returnRecognizedToImport,
      recognizeOnImport: recognizeOnImport ?? this.recognizeOnImport,
      organization: organization ?? this.organization,
      autoTagRemoteSource: autoTagRemoteSource ?? this.autoTagRemoteSource,
      showListAvatars: showListAvatars ?? this.showListAvatars,
      themeMode: themeMode ?? this.themeMode,
      customTheme: customTheme ?? this.customTheme,
      viewerSaveBehavior: viewerSaveBehavior ?? this.viewerSaveBehavior,
      pauseWhenSeeking: pauseWhenSeeking ?? this.pauseWhenSeeking,
      browserHome: browserHome ?? this.browserHome,
      reddit: reddit ?? this.reddit,
      pixiv: pixiv ?? this.pixiv,
      danbooru: danbooru ?? this.danbooru,
      gelbooru: gelbooru ?? this.gelbooru,
      pinterest: pinterest ?? this.pinterest,
      pawchive: pawchive ?? this.pawchive,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [
        language,
        syncLocalFiles,
        copyFiles,
        libraryPath,
        avatarsPath,
        recognitionPath,
        frameSamples,
        returnRecognizedToImport,
        recognizeOnImport,
        organization,
        autoTagRemoteSource,
        showListAvatars,
        themeMode,
        customTheme,
        viewerSaveBehavior,
        pauseWhenSeeking,
        browserHome,
        reddit,
        pixiv,
        danbooru,
        gelbooru,
        pinterest,
        pawchive,
        notifications,
      ];
}
