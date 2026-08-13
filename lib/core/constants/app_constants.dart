import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

const appName = "Fern";
const appLogo = 'assets/images/Fern_logo.png';

// Routes
const mediaRoute = '/media';
const importRoute = '/import';
const favoritesRoute = '/favorites';
const deletedRoute = '/deleted';
const tagManagerRoute = '/tag-manager';

const viewerRoute = '/viewer';

/// Parámetro de consulta del visor: `true` abre el panel de información al
/// entrar (es lo que hace la pantalla de importación).
const viewerInfoQueryParam = 'info';

String viewerRouteWithInfo(bool showInfo) =>
    '$viewerRoute?$viewerInfoQueryParam=$showInfo';

// Images
const fernEmptyImage = 'assets/images/fern_empty.png';

// Icons
const icRight = 'assets/icons/ic_right.png';
const icLeft = 'assets/icons/ic_left.png';

const icInfo = 'assets/icons/ic_info.png';
const icShare = 'assets/icons/ic_share.png';
const icDelete = 'assets/icons/ic_delete.png';
const icHeart = 'assets/icons/ic_heart.png';

// Unknown creator
final unknownCreator = CreatorEntity(id: 0, name: "Unknown");

// Unknown tag
final unknownTag = TagEntity(id: 0, name: "Unknown", children: []);

// Preferences keys
const rootPathPreferenceKey = 'user_media_root_path';
const languagePreferenceKey = 'app_language';
const syncLocalFilesPreferenceKey = 'sync_local_files';
const copyFilesPreferenceKey = 'copy_files';
const libraryPathPreferenceKey = 'library_path';
const avatarsPathPreferenceKey = 'avatars_path';
const fileOrganizationPreferenceKey = 'file_organization';
/// Prefijo de la preferencia que guarda cuándo se importó por última vez de una
/// fuente. Se completa con el identificador de la fuente.
const lastImportPreferenceKeyPrefix = 'last_import_';

const redditClientIdPreferenceKey = 'reddit_client_id';
const redditClientSecretPreferenceKey = 'reddit_client_secret';
const redditUsernamePreferenceKey = 'reddit_username';
const redditPasswordPreferenceKey = 'reddit_password';

// Gestión de ficheros
/// Carpeta de la biblioteca donde se guardan los avatares mientras el usuario
/// no elija otra, colgando del directorio de datos de la aplicación.
const avatarsFolderName = 'avatars';

/// Carpeta a la que se descarga lo que viene de una fuente remota, con una
/// subcarpeta por fuente. Es el equivalente a la carpeta que se escanea en el
/// equipo: de aquí lo recoge la gestión de ficheros cuando el contenido pasa a
/// ser definitivo.
const remoteDownloadsFolderName = 'downloads';

// Importación
/// Hasta dónde llega un escaneo.
///
/// [unlimitedImportLimit] es "todo lo que haya", que es como se importa mientras
/// no se diga otra cosa. [untilLastImportLimit] es "lo guardado desde la última
/// vez": no es una cuenta, es un punto de parada, y quien sabe dónde está es
/// cada fuente. El resto son cortes por número, para traerse una muestra en
/// lugar de la cuenta entera.
const unlimitedImportLimit = 0;
const untilLastImportLimit = -1;
const importLimitOptions = [
  unlimitedImportLimit,
  untilLastImportLimit,
  10,
  25,
  50,
  100,
  250,
];

/// Prefijo de la preferencia que recuerda por dónde se quedó la última
/// importación de una fuente: el identificador de lo más nuevo que había en ella
/// en ese momento. Se completa con el identificador de la fuente.
const lastImportMarkerPreferenceKeyPrefix = 'last_import_marker_';

// Fuentes remotas
/// Con lo que la aplicación se identifica ante las API remotas. Reddit exige
/// uno propio de la aplicación y rechaza las peticiones que no lo llevan.
const remoteUserAgent = 'FernClient/1.0 (by /u/%s)';

/// Extensiones que la aplicación reconoce como contenido, tanto al escanear el
/// equipo como al decidir qué se descarga de una fuente remota.
const mediaExtensions = {
  '.jpg', '.jpeg', '.webp', '.gif', '.png', '.mp4', '.mov', '.avi',
};

// Enlaces externos
/// Sitios cuyos enlaces la aplicación se atreve a abrir para buscar el fichero
/// que hay detrás.
///
/// Es una lista cerrada a propósito: lo guardado en una plataforma puede llevar
/// a cualquier parte de internet, y sólo se visitan sitios conocidos que alojan
/// contenido multimedia. Cualquier otro enlace se descarta sin llegar a pedirlo.
/// Vale el dominio y también sus subdominios.
const externalMediaHosts = {
  'redgifs.com',
  'imgur.com',
  'gfycat.com',
  'streamable.com',
  'giphy.com',
  'tenor.com',
  'ibb.co',
  'postimg.cc',
};

/// Lo que se llega a leer de una página al buscar sus etiquetas de contenido.
/// Con la cabecera basta; el resto no se descarga.
const maxExternalPageBytes = 512 * 1024;

/// Tope de lo que se descarga de un solo contenido. Lo que pese más se descarta:
/// una descarga sin fin no es contenido, es un problema.
const maxRemoteDownloadBytes = 512 * 1024 * 1024;

/// Tipos de contenido que se aceptan al descargar. Lo que llegue diciendo ser
/// otra cosa no se guarda, aunque su dirección acabara en `.jpg`.
const remoteMediaContentTypes = ['image/', 'video/'];

// Redgifs
/// Sus páginas se arman en el navegador, así que las etiquetas de la página no
/// sirven: el fichero se pide a su API, que da un permiso temporal a cualquiera.
const redgifsTokenUrl = 'https://api.redgifs.com/v2/auth/temporary';
const redgifsGifUrl = 'https://api.redgifs.com/v2/gifs/';

// Reddit
const redditTokenUrl = 'https://www.reddit.com/api/v1/access_token';
const redditApiHost = 'oauth.reddit.com';

/// Cuántos elementos se piden por página del listado de guardados. Es el máximo
/// que admite la API.
const redditPageSize = 100;

/// Tope de páginas que se recorren de una vez. Con el tamaño de página son
/// hasta mil elementos, que es también donde Reddit corta el histórico.
const redditMaxPages = 10;

/// Nombre de la etiqueta de origen con la que nace el contenido de Reddit, para
/// que la ordenación de ficheros por origen sepa dónde ponerlo.
const redditSourceTagName = 'Reddit';

/// Lo que se espera a que respondan las llamadas a la API antes de darlas por
/// perdidas.
const remoteRequestTimeout = Duration(seconds: 30);

/// Subcarpeta a la que van los contenidos que no tienen el dato por el que se
/// está ordenando (sin etiqueta, sin origen o sin creador).
const fallbackFolderName = 'Unsorted';

/// Atenuado de las opciones de ajustes que están desactivadas.
const disabledOptionOpacity = 0.4;

// Papelera
/// Cuánto aguanta el contenido marcado para borrar antes de salir solo de la
/// base de datos. Se cuenta desde el momento en que se marcó, y restablecerlo
/// vuelve a poner el contador a cero (deja de estar marcado).
const deletedRetention = Duration(days: 7);

// Animations
const hoverAnimationDuration = Duration(milliseconds: 150);
const drawerAnimationDuration = Duration(milliseconds: 300);
const viewerTransitionDuration = Duration(milliseconds: 250);
const infoPanelAnimationDuration = Duration(milliseconds: 300);

/// Lo que tarda el cambio de pantalla: la que sale se desvanece mientras la que
/// entra aparece. Corto a propósito, que es un cambio de pantalla y no una
/// animación que haya que mirar.
const pageTransitionDuration = Duration(milliseconds: 220);

/// Tamaño con el que arranca la pantalla que entra, antes de asentarse en el
/// suyo. Es un efecto de pintado, no de maquetación: nada se recoloca por él, así
/// que no puede provocar desbordes mientras la transición está en marcha.
const pageTransitionScale = 0.98;

// Indicador de progreso
/// Lo que tarda el velo de ocupado en aparecer y en irse. Bastante más corto que
/// la transición de pantalla: lo que se quiere es que no parpadee, no que se note.
const busyOverlayFadeDuration = Duration(milliseconds: 150);

/// Cuánto tapa el velo lo que hay debajo mientras se espera. Deja ver el
/// contenido anterior para que se entienda que sigue ahí, sólo que en espera.
const busyOverlayOpacity = 0.55;

/// Grosor del trazo del indicador de progreso, en su tamaño normal y en el
/// pequeño (el que va dentro de un botón o de un campo).
const progressStrokeWidth = 3.0;
const progressSmallStrokeWidth = 2.0;

// Sidebar
const sidebarSelectedOpacity = 0.3;

/// Velo oscuro que se pone sobre el botón del menú al pasar el ratón.
const sidebarHoverOverlayOpacity = 0.08;

/// Sangría que se le añade a un botón del menú por cada nivel de jerarquía: una
/// etiqueta hija entra más que su padre.
const sidebarDepthIndent = 20.0;

/// Hasta qué nivel crece la sangría. Se cuenta desde 0 (las etiquetas raíz), así
/// que con 2 la última que entra es la nieta; de ahí para abajo se pinta el
/// indicador de jerarquía en lugar de seguir estrechando el botón.
const sidebarMaxIndentDepth = 2;

// Media info
const mediaDescriptionMaxLines = 10;

// Search suggestions
const searchSuggestionsLimit = 3;
const searchDebounceDuration = Duration(milliseconds: 250);

/// Sugerencias del buscador principal: hasta cinco entre contenidos, etiquetas
/// y creadores.
const mediaSearchSuggestionsLimit = 5;

/// Tiempo sin escribir tras el que el buscador principal actualiza la rejilla
/// por su cuenta, sin necesidad de pulsar enter ni elegir una sugerencia.
const mediaSearchDelay = Duration(seconds: 3);

/// Alto máximo del desplegable de sugerencias del buscador principal.
const mediaSearchSuggestionsMaxHeight = 320.0;

/// Identificador de las entidades que todavía no están en la base de datos.
/// Al guardarlas, Isar les asigna uno de verdad.
const unsavedId = 0;

/// Atenuado de los botones de píldora cuando están desactivados.
const pillButtonDisabledOpacity = 0.35;

// Create dialog
const createDialogSocialFieldsMaxHeight = 160.0;

// Gestión de etiquetas
/// Sangría que se le añade a una fila de la lista de etiquetas por cada nivel de
/// jerarquía, igual que en el menú lateral pero con su propio listado.
const tagListDepthIndent = 16.0;

/// Columnas de la rejilla de la pantalla de gestión de etiquetas. Son más que en
/// las demás pantallas: los elementos salen algo más pequeños, y así caben más a
/// la vista en el hueco que la rejilla comparte con la ficha y con la lista.
const tagManagerGridColumns = 5;

// Media grid
const mediaHoverScale = 1.04;
const mediaShadeHeightFactor = 0.35;
const mediaShadeOpacity = 0.55;
const mediaBadgeOpacity = 0.55;
const mediaSelectionShadowOpacity = 0.5;
const mediaFallbackAspectRatio = 1.0;

/// Salto del ancho al que se descodifican las imágenes de la rejilla, en
/// píxeles físicos. Cuanto más grande, menos veces hay que volver al disco al
/// reescalar la ventana, y más resolución de sobra se guarda de más.
const mediaDecodeWidthStep = 64;
const mediaVideoPreviewLength = Duration(seconds: 10);
const mediaEmptyDurationLabel = '--:--';

// Video preview extraction
const videoThumbnailFolder = 'fern_video_thumbnails';
const videoThumbnailSeek = Duration(seconds: 1);
const videoProbeTimeout = Duration(seconds: 12);
const videoScreenshotAttempts = 10;
const videoScreenshotRetryDelay = Duration(milliseconds: 120);
const maxConcurrentVideoJobs = 2;
