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

/// Qué se ve con el modo NSFW **abierto**.
///
/// Abrirlo puede querer decir dos cosas distintas según para qué se use la
/// biblioteca: «enséñamelo todo junto» o «ahora estoy mirando sólo esto». La
/// segunda convierte el modo en una biblioteca aparte, y es lo que quiere quien
/// abre el bloqueo para una sesión concreta y no para trabajar.
enum NsfwUnlockedView {
  /// Lo marcado aparece mezclado con el resto, como si no lo estuviera.
  mixed(id: 'mixed'),

  /// Sólo lo marcado. El resto de la biblioteca desaparece mientras dure.
  onlyNsfw(id: 'only');

  const NsfwUnlockedView({required this.id});

  final String id;

  static NsfwUnlockedView fromId(String? id) {
    return NsfwUnlockedView.values.firstWhere(
      (view) => view.id == id,
      orElse: () => NsfwUnlockedView.mixed,
    );
  }
}

/// Qué se ve con el modo NSFW **cerrado**.
///
/// Esconderlo del todo es lo más discreto: nada delata que ahí falte algo. Pero
/// también hace que la biblioteca mienta sobre lo que tiene —los huecos no se
/// ven, los contadores no cuadran con lo que uno recuerda—, y quien la usa solo
/// en su equipo puede preferir ver que ahí hay algo y que está tapado.
enum NsfwLockedView {
  /// No aparece en ninguna parte. Como si no existiera.
  hidden(id: 'hidden'),

  /// Aparece tapado, y al tocarlo se pide la contraseña.
  blurred(id: 'blurred');

  const NsfwLockedView({required this.id});

  final String id;

  static NsfwLockedView fromId(String? id) {
    return NsfwLockedView.values.firstWhere(
      (view) => view.id == id,
      orElse: () => NsfwLockedView.hidden,
    );
  }
}

/// Cada cuánto busca la aplicación contenido repetido por su cuenta.
///
/// El mínimo es un mes (D17) y no es una cifra caprichosa: un escaneo completo
/// sólo tiene algo que hacer cuando ha entrado contenido nuevo, y hasta la
/// biblioteca más activa no cambia lo bastante en una semana como para que
/// merezca la pena volver a mirarlo todo.
enum DuplicateScanPeriod {
  monthly(id: 'monthly', days: 30),
  quarterly(id: 'quarterly', days: 90),
  biannual(id: 'biannual', days: 182),
  yearly(id: 'yearly', days: 365);

  const DuplicateScanPeriod({required this.id, required this.days});

  /// Con lo que se guarda. No cambiarlo: el periodo elegido se perdería.
  final String id;

  final int days;

  Duration get span => Duration(days: days);

  static DuplicateScanPeriod fromId(String? id) {
    return DuplicateScanPeriod.values.firstWhere(
      (period) => period.id == id,
      orElse: () => DuplicateScanPeriod.quarterly,
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

  /// A partir de qué distancia dos contenidos dejan de ser el mismo.
  ///
  /// De 0 a 16 bits distintos. Subirlo agrupa más y empieza a juntar cosas que
  /// sólo se parecen; bajarlo deja duplicados sin encontrar. Ocho es el punto
  /// donde todavía se agrupa lo que de verdad sobra.
  final int duplicateThreshold;

  /// La aplicación busca repetidos por su cuenta cada cierto tiempo.
  ///
  /// Encendido de fábrica: el contenido repetido no molesta el día que entra,
  /// molesta seis meses después cuando ya hay cuarenta copias y nadie se acuerda
  /// de mirarlo. Corre en segundo plano y con la prioridad más baja, así que a
  /// quien no le interese sólo le cuesta un rato de disco cada tantos meses.
  ///
  /// Apagarlo no quita nada: buscar repetidos sigue estando en su pantalla.
  final bool automaticDuplicateScan;

  /// Qué se ve con el modo NSFW abierto: todo junto o sólo lo marcado.
  /// Marcar una etiqueta arrastra a las que cuelgan de ella.
  ///
  /// Encendido de fábrica, que es lo que se espera de una jerarquía: quien marca
  /// una etiqueta madre está pensando en todo lo que hay debajo, y tener que
  /// repetir la marca rama por rama es donde se olvida una y se queda contenido
  /// a la vista.
  ///
  /// Apagarlo hace que cada etiqueta responda sólo por lo suyo. Sirve para una
  /// madre que agrupa sin ser en sí misma delicada —«personajes», con una rama
  /// que sí lo es— aunque para ese caso suele ser más simple marcar la hija.
  ///
  /// No reescribe nada al cambiar: la rama se resuelve al leerla, así que
  /// encenderlo y apagarlo es reversible y no toca una sola etiqueta.
  final bool nsfwMarksChildTags;

  final NsfwUnlockedView nsfwUnlockedView;

  /// Qué se ve con el modo NSFW cerrado: nada o el contenido tapado.
  ///
  /// De fábrica, nada. Es lo único que cumple lo que promete la función: un
  /// contenido tapado sigue diciendo que existe, cuántos hay y de qué forma
  /// son, y quien pone un bloqueo casi siempre quiere lo otro. Tapar es una
  /// elección, y por eso hay que hacerla.
  final NsfwLockedView nsfwLockedView;

  /// Cada cuánto lo hace, cuando [automaticDuplicateScan] está encendido.
  final DuplicateScanPeriod duplicateScanPeriod;

  /// El escaneo mira también lo que se mueve: vídeos y GIF.
  ///
  /// Encendido de fábrica: una biblioteca con vídeos repetidos los tiene
  /// repetidos igual, y son los ficheros que más ocupan de todos. Se puede
  /// apagar porque el precio no es el mismo: un GIF se lee como cualquier
  /// imagen, pero de cada vídeo hay que abrir el fichero, saltar al 10 % de su
  /// duración y capturar el fotograma, y eso convierte una biblioteca con miles
  /// de vídeos en un escaneo de horas.
  ///
  /// Apagarlo no borra lo ya calculado: lo que tenga huella se sigue
  /// comparando. Para tirarlo está «Recalcular todas las huellas».
  final bool duplicateScanIncludesMoving;

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

  /// Al salir del visor, la rejilla se coloca donde está lo que se acaba de
  /// mirar.
  ///
  /// Activado de fábrica: con unos cientos de miniaturas, volver y encontrarse
  /// la rejilla donde se dejó es perder el sitio. Se puede apagar porque el
  /// salto también desconcierta a quien iba mirando de arriba abajo y quiere
  /// seguir por donde estaba.
  final bool returnToViewedMedia;

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
    this.duplicateThreshold = defaultDuplicateThreshold,
    this.automaticDuplicateScan = true,
    this.duplicateScanPeriod = DuplicateScanPeriod.quarterly,
    this.duplicateScanIncludesMoving = true,
    this.nsfwMarksChildTags = true,
    this.nsfwUnlockedView = NsfwUnlockedView.mixed,
    this.nsfwLockedView = NsfwLockedView.hidden,
    this.organization = FileOrganizationCriteria.flat,
    this.autoTagRemoteSource = false,
    this.showListAvatars = true,
    this.themeMode = AppThemeMode.system,
    this.customTheme = const CustomThemeEntity(),
    this.viewerSaveBehavior = ViewerSaveBehavior.goToNext,
    this.pauseWhenSeeking = false,
    this.returnToViewedMedia = true,
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
    int? duplicateThreshold,
    bool? automaticDuplicateScan,
    DuplicateScanPeriod? duplicateScanPeriod,
    bool? duplicateScanIncludesMoving,
    bool? nsfwMarksChildTags,
    NsfwUnlockedView? nsfwUnlockedView,
    NsfwLockedView? nsfwLockedView,
    FileOrganizationCriteria? organization,
    bool? autoTagRemoteSource,
    bool? showListAvatars,
    AppThemeMode? themeMode,
    CustomThemeEntity? customTheme,
    ViewerSaveBehavior? viewerSaveBehavior,
    bool? pauseWhenSeeking,
    bool? returnToViewedMedia,
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
      duplicateThreshold: duplicateThreshold ?? this.duplicateThreshold,
      automaticDuplicateScan:
          automaticDuplicateScan ?? this.automaticDuplicateScan,
      duplicateScanPeriod: duplicateScanPeriod ?? this.duplicateScanPeriod,
      duplicateScanIncludesMoving:
          duplicateScanIncludesMoving ?? this.duplicateScanIncludesMoving,
      nsfwMarksChildTags: nsfwMarksChildTags ?? this.nsfwMarksChildTags,
      nsfwUnlockedView: nsfwUnlockedView ?? this.nsfwUnlockedView,
      nsfwLockedView: nsfwLockedView ?? this.nsfwLockedView,
      organization: organization ?? this.organization,
      autoTagRemoteSource: autoTagRemoteSource ?? this.autoTagRemoteSource,
      showListAvatars: showListAvatars ?? this.showListAvatars,
      themeMode: themeMode ?? this.themeMode,
      customTheme: customTheme ?? this.customTheme,
      viewerSaveBehavior: viewerSaveBehavior ?? this.viewerSaveBehavior,
      pauseWhenSeeking: pauseWhenSeeking ?? this.pauseWhenSeeking,
      returnToViewedMedia: returnToViewedMedia ?? this.returnToViewedMedia,
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
        duplicateThreshold,
        automaticDuplicateScan,
        duplicateScanPeriod,
        duplicateScanIncludesMoving,
        nsfwMarksChildTags,
        nsfwUnlockedView,
        nsfwLockedView,
        organization,
        autoTagRemoteSource,
        showListAvatars,
        themeMode,
        customTheme,
        viewerSaveBehavior,
        pauseWhenSeeking,
        returnToViewedMedia,
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
