// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navGallery => 'Galería';

  @override
  String get navTags => 'Etiquetas';

  @override
  String get navMedia => 'Contenido';

  @override
  String get navImport => 'Importar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navDeleted => 'Eliminados';

  @override
  String get navCreatorManager => 'Gestor de creadores';

  @override
  String get navTagManager => 'Gestor de etiquetas';

  @override
  String get navBrowser => 'Navegador';

  @override
  String get searchHint => 'Buscar';

  @override
  String get menuNewCreator => 'Nuevo creador';

  @override
  String get menuNewTag => 'Nueva etiqueta';

  @override
  String get menuNewCollection => 'Nueva colección';

  @override
  String get collectionsWip => 'Las colecciones todavía están en construcción';

  @override
  String get mobileLayoutWip => 'La versión móvil llegará pronto';

  @override
  String mediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
      zero: 'Sin contenido',
    );
    return '$_temp0';
  }

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos',
      one: '1 favorito',
      zero: 'Todavía no hay favoritos',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get filtersResultsFrom => 'Mostrar resultados de';

  @override
  String get filterMedia => 'Contenido';

  @override
  String get filterTags => 'Etiquetas';

  @override
  String get filterCreators => 'Creadores';

  @override
  String get emptyLibrary => 'Esto está un poco vacío';

  @override
  String mediaFetched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos encontrados',
      one: '1 archivo encontrado',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos marcados para borrar',
      one: '1 archivo marcado para borrar',
      zero: 'Nada marcado para borrar',
    );
    return '$_temp0';
  }

  @override
  String deletedRetentionNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Se borra definitivamente al cabo de $days días',
      one: 'Se borra definitivamente al cabo de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip =>
      'Borrar definitivamente de la base de datos';

  @override
  String remoteImportWarning(String source) {
    return 'Se va a importar contenido de $source';
  }

  @override
  String get remoteImportAmountAll =>
      'Se traerá todo lo que tengas guardado en tu cuenta.';

  @override
  String get remoteImportAmountSinceLast =>
      'Se traerá lo que tengas guardado desde la última importación.';

  @override
  String remoteImportAmountLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se traerán $count contenidos como mucho.',
      one: 'Se traerá 1 contenido como mucho.',
    );
    return '$_temp0';
  }

  @override
  String get favoriteSelectedTooltip => 'Marcar la selección como favorita';

  @override
  String get deleteSelectedTooltip =>
      'Mandar la selección a la pantalla de eliminados';

  @override
  String deleteTrashWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a borrar definitivamente $count archivos',
      one: 'Se va a borrar definitivamente 1 archivo',
    );
    return '$_temp0';
  }

  @override
  String deleteDiscardWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a descartar $count archivos',
      one: 'Se va a descartar 1 archivo',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesFromDisk => 'Borrar también los ficheros del disco';

  @override
  String get deleteFilesFromDiskDescription =>
      'Si la quitas, el contenido sale de la base de datos pero sus ficheros se quedan donde están, así que un escaneo posterior puede recogerlos otra vez.';

  @override
  String get actionStopImport => 'Detener la importación';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionSelectFolder => 'Elegir carpeta';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRestore => 'Restablecer';

  @override
  String get actionSave => 'Guardar';

  @override
  String get showPassword => 'Mostrar';

  @override
  String get hidePassword => 'Ocultar';

  @override
  String get actionUnassignTag => 'Quitar etiqueta';

  @override
  String get actionRemoveParentTag => 'Quitar padre';

  @override
  String get actionDeleteTag => 'Eliminar etiqueta';

  @override
  String get actionUnassignCreator => 'Quitar creador';

  @override
  String get actionDeleteCreator => 'Eliminar creador';

  @override
  String get sourceLocalComputer => 'Equipo local';

  @override
  String get sourceAll => 'Todas';

  @override
  String get sourceBrowser => 'Navegador';

  @override
  String get sourceBrowserNote => 'Ir al navegador';

  @override
  String get sourceBrowserHint =>
      'Este contenido no se pide desde aquí: se elige página a página en la pantalla del navegador.';

  @override
  String get sourceNotConfigured => 'Sin configurar';

  @override
  String sourceLogIn(String source) {
    return 'Inicia sesión en $source';
  }

  @override
  String sourceLogInHint(String source) {
    return 'Abre $source en el navegador de Fern. Cuando hayas entrado, pulsa allí el botón de la llave para guardar la sesión y vuelve aquí.';
  }

  @override
  String get selectItem => 'Seleccionar';

  @override
  String get deselectItem => 'Quitar selección';

  @override
  String get mediaInfoTitle => 'Información';

  @override
  String get descriptionHint => 'Añade una descripción';

  @override
  String get createdBy => 'Creado por:';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get noTagsYet => 'Todavía no hay etiquetas';

  @override
  String get creatorsTitle => 'Creadores';

  @override
  String get noCreatorsYet => 'Todavía no hay creadores';

  @override
  String get noSocialProfiles => 'Sin perfiles sociales';

  @override
  String get openProfileTooltip => 'Abrir el perfil en el navegador';

  @override
  String get editProfileTooltip => 'Editar el enlace';

  @override
  String get doneEditingProfileTooltip => 'Terminar de editar';

  @override
  String get removeProfileTooltip => 'Quitar el enlace';

  @override
  String get tagNameSearchLabel => 'Nombre de la etiqueta';

  @override
  String get tagSearchHint => 'Etiqueta';

  @override
  String get createTag => 'Crear etiqueta';

  @override
  String get searchCreatorLabel => 'Buscar creador';

  @override
  String get creatorSearchHint => 'Nombre';

  @override
  String get createCreator => 'Crear creador';

  @override
  String get newTagTitle => 'Nueva etiqueta';

  @override
  String get tagNameLabel => 'Nombre de la etiqueta';

  @override
  String get parentTagLabel => 'Etiqueta padre (opcional)';

  @override
  String get newCreatorTitle => 'Nuevo creador';

  @override
  String get creatorNameLabel => 'Nombre del creador';

  @override
  String get socialProfilesLabel => 'Perfiles sociales';

  @override
  String get enterNameHint => 'Escribe un nombre';

  @override
  String get searchEllipsisHint => 'Buscar...';

  @override
  String get profileLinkHint => 'Enlace al perfil';

  @override
  String get addProfile => 'Añadir perfil';

  @override
  String get resultTypeMedia => 'contenido';

  @override
  String get resultTypeTag => 'etiqueta';

  @override
  String get resultTypeCreator => 'creador';

  @override
  String get noFolderSelected => 'Ninguna carpeta seleccionada';

  @override
  String get chooseFolder => 'Elegir carpeta';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsFiles => 'Archivos';

  @override
  String get settingsRemoteSources => 'Fuentes remotas';

  @override
  String get languageSectionTitle => 'Idioma de la aplicación';

  @override
  String get languageSectionNote =>
      'Toda la aplicación cambia de idioma en cuanto eliges uno.';

  @override
  String get sidebarSectionTitle => 'Menú lateral';

  @override
  String get sidebarSectionNote =>
      'Cómo se pinta la lista de etiquetas del menú lateral.';

  @override
  String get showListAvatars => 'Mostrar avatares en lista';

  @override
  String get showListAvatarsDescription =>
      'Cada etiqueta se pinta con su propia imagen en vez del icono común, así se distinguen con el menú plegado. Las etiquetas sin imagen se quedan con el icono.';

  @override
  String get filesLocalTitle => 'Archivos locales';

  @override
  String get syncLocalFiles => 'Sincronizar archivos locales';

  @override
  String get syncLocalFilesDescription =>
      'Fern mueve a una carpeta propia el contenido con el que trabaja, tanto el que ya está importado como el que llegue después.';

  @override
  String get libraryFolder => 'Carpeta de la biblioteca';

  @override
  String get copyFiles => 'Copiar archivos';

  @override
  String get copyFilesDescription =>
      'Conserva el archivo original donde estaba y trabaja con una copia dentro de la carpeta de la biblioteca.';

  @override
  String get avatarsTitle => 'Avatares';

  @override
  String get avatarsDescription =>
      'Las imágenes de los avatares siempre se copian a una carpeta propia, esté o no activada la sincronización de archivos locales. Al cambiar de carpeta, los avatares que ya existan se llevan con ella.';

  @override
  String get avatarsFolder => 'Carpeta de avatares';

  @override
  String get organizationTitle => 'Ordenación';

  @override
  String get organizationDescription =>
      'Cómo se reparten los archivos dentro de la carpeta de la biblioteca. No afecta a las imágenes de los avatares.';

  @override
  String get organizationFlat => 'Todos los archivos juntos';

  @override
  String get organizationFlatDescription =>
      'Cada archivo queda directamente en la carpeta de la biblioteca';

  @override
  String get organizationByTag => 'Subcarpetas por etiqueta';

  @override
  String get organizationByTagDescription =>
      'Una carpeta por etiqueta, tomada de la primera etiqueta del contenido';

  @override
  String get organizationBySource => 'Subcarpetas por fuente';

  @override
  String get organizationBySourceDescription =>
      'Una carpeta por origen: local, Pixiv, Twitter...';

  @override
  String get organizationByCreator => 'Subcarpetas por creador';

  @override
  String get organizationByCreatorDescription => 'Una carpeta por creador';

  @override
  String get migrationTitle => 'Migración';

  @override
  String get migrationDescription =>
      'Ordena con los criterios de arriba todos los archivos que ya están en la biblioteca.';

  @override
  String get migrateFiles => 'Migrar archivos';

  @override
  String avatarsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avatares movidos a la carpeta nueva',
      one: '1 avatar movido a la carpeta nueva',
      zero: 'Los avatares ya estaban en esa carpeta',
    );
    return '$_temp0';
  }

  @override
  String get avatarsMoveFailed => 'No se han podido mover los avatares';

  @override
  String filesOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos movidos',
      one: '1 archivo movido',
      zero: 'Ya estaba todo en su sitio',
    );
    return '$_temp0';
  }

  @override
  String get filesOrganizeFailed => 'No se han podido ordenar los archivos';

  @override
  String get redditTitle => 'Reddit';

  @override
  String get redditDescription =>
      'Fern se descarga lo que tengas guardado en tu cuenta de Reddit. Registra una aplicación de tipo script en reddit.com/prefs/apps para conseguir las dos claves.';

  @override
  String get redditClientId => 'ID de cliente';

  @override
  String get redditClientIdHint =>
      'La clave que aparece bajo el nombre de tu aplicación';

  @override
  String get redditClientSecret => 'Secreto de cliente';

  @override
  String get redditClientSecretHint => 'El secreto de tu aplicación';

  @override
  String get redditUsername => 'Usuario';

  @override
  String get redditUsernameHint => 'Tu cuenta de Reddit, sin /u/';

  @override
  String get redditPassword => 'Contraseña';

  @override
  String get redditPasswordHint => 'La contraseña de esa cuenta';

  @override
  String get redditCredentialsNote =>
      'Las credenciales se quedan en este equipo y sólo se usan para hablar con Reddit.';

  @override
  String get settingsBrowser => 'Navegador';

  @override
  String get browserHome => 'Página de inicio';

  @override
  String get browserHomeTitle => 'Página de inicio';

  @override
  String get browserHomeDescription =>
      'Por dónde empieza el navegador de Fern al pulsar el botón de inicio. No decide por dónde se abre: al volver a la pantalla, el navegador se queda en la última página que visitaste.';

  @override
  String get browserHomeLabel => 'Dirección';

  @override
  String credentialsRejectedTitle(String source) {
    return '$source no ha aceptado tus credenciales';
  }

  @override
  String credentialsRejectedDescription(String source) {
    return 'No se ha podido importar nada: $source ha rechazado la cuenta o la clave que se le daban. Revísalas en Ajustes, en Fuentes remotas.';
  }

  @override
  String get actionOpenRemoteSettings => 'Abrir ajustes';

  @override
  String sessionExpiredTitle(String source) {
    return 'La sesión de $source ya no vale';
  }

  @override
  String sessionExpiredDescription(String source) {
    return 'No se ha podido importar nada: $source ha rechazado la sesión guardada. Vuelve a iniciar sesión en el navegador y pulsa allí el botón de la llave para guardar la nueva.';
  }

  @override
  String browserImportedInto(int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos listos para revisar en $source',
      one: '1 contenido listo para revisar en $source',
    );
    return '$_temp0';
  }

  @override
  String browserImportKnown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya estaban en la biblioteca',
      one: '1 ya estaba en la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String browserImportFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no se han podido descargar',
      one: '1 no se ha podido descargar',
    );
    return '$_temp0';
  }

  @override
  String get browserImportNothing => 'No se ha traído nada.';

  @override
  String get danbooruTitle => 'Danbooru';

  @override
  String get danbooruDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Danbooru. Su API es pública: sólo hacen falta el nombre de tu cuenta y una clave de API.';

  @override
  String get danbooruUsername => 'Nombre de la cuenta';

  @override
  String get danbooruUsernameHint => 'Tu nombre de usuario en Danbooru';

  @override
  String get danbooruApiKey => 'Clave de API';

  @override
  String get danbooruApiKeyHint => 'Una clave de tu perfil de Danbooru';

  @override
  String get danbooruApiKeyNote =>
      'En Danbooru, abre tu perfil, ve a API Key y crea una. No es tu contraseña: puedes revocarla cuando quieras sin tocar nada más. Se queda en este equipo y sólo se usa para hablar con Danbooru.';

  @override
  String get gelbooruTitle => 'Gelbooru';

  @override
  String get gelbooruDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Gelbooru. Su API de favoritos es más lenta que las demás: da referencias en lugar de publicaciones, así que hay que pedir cada una aparte.';

  @override
  String get gelbooruUserId => 'Identificador de la cuenta';

  @override
  String get gelbooruUserIdHint => 'El número de tu cuenta de Gelbooru';

  @override
  String get gelbooruApiKey => 'Clave de API';

  @override
  String get gelbooruApiKeyHint => 'La clave de esa cuenta';

  @override
  String get gelbooruApiKeyNote =>
      'En Gelbooru, entra en My Account, luego en Options, y busca API Access Credentials: ahí están el identificador y la clave. Se quedan en este equipo y sólo se usan para hablar con Gelbooru.';

  @override
  String get pinterestTitle => 'Pinterest';

  @override
  String get pinterestDescription =>
      'Fern se descarga lo que tengas guardado en Pinterest. Para lo que esté en tableros públicos no hace falta nada más que el nombre de tu cuenta.';

  @override
  String get pinterestUsername => 'Nombre de la cuenta';

  @override
  String get pinterestUsernameHint => 'Tu nombre de usuario en Pinterest';

  @override
  String get pinterestSecretBoardsNote =>
      'Para traerte también lo que guardas en tableros secretos, inicia sesión en Pinterest desde el navegador de Fern y pulsa allí el botón de la llave: la sesión se guarda junto al nombre.';

  @override
  String get pawchiveTitle => 'Pawchive';

  @override
  String get pawchiveDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Pawchive. Aquí no hay nada que rellenar: inicia sesión desde el navegador de Fern y pulsa allí el botón de la llave, y la sesión se guarda sola.';

  @override
  String linkChoiceTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta publicación trae $count enlaces',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceUntitledPost => 'Publicación sin título';

  @override
  String get linkChoiceApplyToAll => 'Aplicar al resto de la importación';

  @override
  String get linkChoiceApplyToAllDescription =>
      'Se usa la misma respuesta para todas las publicaciones que queden, y no se vuelve a preguntar.';

  @override
  String get linkChoiceIgnore => 'Ignorar publicación';

  @override
  String linkChoiceSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descargar $count',
      zero: 'Descargar selección',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceAll => 'Descargar todo';

  @override
  String get linkChoiceOpen => 'Ver en el navegador';

  @override
  String repositoryLinkTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta publicación lleva a $count repositorios de contenido',
      one: 'Esta publicación lleva a un repositorio de contenido',
    );
    return '$_temp0';
  }

  @override
  String get repositoryLinkDescription =>
      'Fern no puede traerse esto por su cuenta: son páginas con su propia espera y sus comprobaciones. Puedes abrirlas en el navegador de Fern y traerte desde ahí lo que quieras. Mientras tanto la importación sigue.';

  @override
  String get repositoryLinkOpen => 'Ver en el navegador';

  @override
  String get pawchiveByCreators => 'Importar por creadores favoritos';

  @override
  String get pawchiveByCreatorsDescription =>
      'En lugar de las publicaciones que hayas marcado, Fern recorre todo lo que publiquen los creadores que tengas en favoritos. Trae bastante más, y cada creador se sigue por su cuenta.';

  @override
  String get remoteImportHeavyWarning =>
      'Esto puede tardar bastante: sin tope, Fern recorre la cuenta entera y se trae todo, incluidos los ficheros que haya dentro de las publicaciones. Puedes pararlo cuando quieras desde la pantalla de importación, y lo que ya haya llegado se queda.';

  @override
  String emptySource(String source) {
    return 'No había nada que traer de $source.';
  }

  @override
  String get emptySourcePawchiveCreators =>
      'No tienes publicaciones marcadas en Pawchive, pero sí creadores favoritos. Activa «Importar por creadores favoritos» en Ajustes, dentro de Fuentes remotas, y Fern recorrerá todo lo que publiquen.';

  @override
  String get browserAddressHint => 'Dirección de un sitio';

  @override
  String get browserBack => 'Atrás';

  @override
  String get browserForward => 'Adelante';

  @override
  String get browserReload => 'Recargar';

  @override
  String get browserSaveSessionHint =>
      'Guardar la sesión de este sitio para poder importar de él';

  @override
  String get browserFindMediaHint => 'Buscar contenido en esta página';

  @override
  String browserImportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count',
      one: 'Importar 1',
    );
    return '$_temp0';
  }

  @override
  String get browserSelectAll => 'Marcar o desmarcar todo';

  @override
  String get browserClose => 'Cerrar';

  @override
  String get browserNoSession =>
      'De este sitio no se puede importar, así que aquí no hay ninguna sesión que guardar.';

  @override
  String browserSessionSaved(String source) {
    return 'Sesión de $source guardada.';
  }

  @override
  String browserSessionMissing(String source) {
    return 'Aquí todavía no hay ninguna sesión de $source: inicia sesión primero.';
  }

  @override
  String get browserNothingFound =>
      'No se ha encontrado contenido en esta página.';

  @override
  String browserFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos encontrados',
      one: '1 contenido encontrado',
    );
    return '$_temp0';
  }

  @override
  String browserImporting(int done, int total) {
    return 'Descargando $done de $total…';
  }

  @override
  String importFailed(String error) {
    return 'La importación no ha podido completarse: $error';
  }

  @override
  String get importLimitAll => 'Todos';

  @override
  String get importLimitSinceLast => 'Nuevos';

  @override
  String get importLimitSinceLastTooltip =>
      'Sólo lo que se ha guardado desde la última importación';

  @override
  String get importLimitTooltip => 'Máximo de elementos que trae un escaneo';

  @override
  String get lastImportNever => 'Nunca importado';

  @override
  String get sourceNotConfiguredHint =>
      'Configura esta fuente en los ajustes antes de importar de ella';

  @override
  String get lastImportHint =>
      'Cuándo se miró por última vez si esta fuente tenía contenido nuevo';

  @override
  String lastImportMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count min',
      one: 'Hace 1 min',
      zero: 'Ahora mismo',
    );
    return '$_temp0';
  }

  @override
  String lastImportHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count h',
      one: 'Hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String lastImportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get assignUrlsTitle => 'Direcciones vinculadas';

  @override
  String assignUrlsTo(String name) {
    return 'Direcciones vinculadas a $name';
  }

  @override
  String get assignUrlsDescription =>
      'Lo que se importe de estas direcciones se lleva esta etiqueta solo, sin preguntarle nada a la plataforma.';

  @override
  String get assignUrlsTooltip => 'Vincular direcciones con esta etiqueta';

  @override
  String get assignUrlsCreatorDescription =>
      'Lo que se importe de estas direcciones se lleva este creador solo, sin preguntarle nada a la plataforma.';

  @override
  String get assignUrlsCreatorTooltip =>
      'Vincular direcciones con este creador';

  @override
  String get sourceUrlsLabel => 'Direcciones';

  @override
  String get sourceUrlHint => 'reddit.com/r/ejemplo';

  @override
  String get addSourceUrl => 'Añadir dirección';

  @override
  String get filtersSource => 'Mostrar contenido de';

  @override
  String get sourceLocal => 'Este equipo';

  @override
  String get autoTagRemoteSource => 'Auto-etiquetar fuente remota';

  @override
  String get autoTagRemoteSourceDescription =>
      'Fern crea una etiqueta por plataforma (Reddit, y las que vengan) y se la pone a lo que importa de ella. Apagado, la fuente se sigue guardando y se filtra por ella desde el botón de filtros.';
}
