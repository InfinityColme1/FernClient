import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

const appName = "FeRN";
const appLogo = 'assets/images/Fern_logo.png';

// Routes
const mediaRoute = '/media';
const importRoute = '/import';
const favoritesRoute = '/favorites';
const deletedRoute = '/deleted';
const creatorManagerRoute = '/creator-manager';
const tagManagerRoute = '/tag-manager';

/// El navegador de dentro de la aplicación. Es una prueba: si no convence, se
/// quita esta ruta, su botón del menú y la carpeta `features/browser`, y la
/// aplicación se queda como estaba.
const browserRoute = '/browser';

/// Parámetro de consulta del navegador: con qué dirección se abre. Sin él
/// arranca por donde arranca siempre.
const browserUrlQueryParam = 'url';

/// El navegador abierto por una dirección concreta. Es lo que permite mandar al
/// usuario a iniciar sesión en una plataforma desde donde le hacía falta.
String browserRouteWithUrl(String url) =>
    '$browserRoute?$browserUrlQueryParam=${Uri.encodeComponent(url)}';

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

/// Si al importar de una plataforma se le pone además una etiqueta con su
/// nombre. Apagado por defecto: la fuente ya queda anotada en el sumario, y
/// filtrar por ella es cosa del botón de filtros, no de una etiqueta.
const autoTagRemoteSourcePreferenceKey = 'auto_tag_remote_source';

/// Si la lista de etiquetas del menú lateral enseña los avatares. Encendido de
/// fábrica: es lo que permite reconocerlas con el menú plegado.
const showListAvatarsPreferenceKey = 'show_list_avatars';

/// Cómo quedó la casilla del aviso de borrado la última vez, una por cada
/// borrado que la enseña.
///
/// Se recuerda para no obligar a marcarla en cada operación, y son dos claves
/// porque los dos borrados no significan lo mismo: vaciar la papelera es
/// definitivo y se lleva los ficheros de fábrica, mientras que descartar al
/// importar los deja donde están mientras nadie diga lo contrario.
const deleteTrashFilesPreferenceKey = 'delete_trash_files';
const deleteDiscardedFilesPreferenceKey = 'delete_discarded_files';

const redditClientIdPreferenceKey = 'reddit_client_id';
const redditClientSecretPreferenceKey = 'reddit_client_secret';
const redditUsernamePreferenceKey = 'reddit_username';
const redditPasswordPreferenceKey = 'reddit_password';

/// La cookie de sesión con la que se entra en la cuenta de Pixiv. Es lo único
/// que hace falta: lleva dentro el identificador del usuario.
const pixivSessionIdPreferenceKey = 'pixiv_session_id';

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
/// La dirección con la que se nombra lo que hay en Reddit (una comunidad, un
/// autor, una publicación). No es por donde se habla con su API: es lo que el
/// usuario ve en la barra del navegador, y por tanto lo que escribiría al
/// vincular una dirección con una etiqueta.
const redditSiteUrl = 'https://www.reddit.com';

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

// Pixiv
/// La dirección con la que se nombra lo que hay en Pixiv (una obra, un autor).
/// Es también por donde se habla con su API: Pixiv no tiene una pública, así
/// que se usa la misma que su web, la que responde bajo `/ajax`.
const pixivSiteUrl = 'https://www.pixiv.net';
const pixivApiHost = 'www.pixiv.net';

/// Con lo que la aplicación se identifica ante Pixiv.
///
/// A diferencia de Reddit, que exige uno propio de cada aplicación, Pixiv sólo
/// atiende a lo que parece un navegador: su `/ajax` es el de su web y responde
/// a lo que no lo parece con una página de error.
const pixivUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

/// La cookie con la que Pixiv reconoce a quien pide. Es la que el navegador de
/// la aplicación recoge cuando el usuario ha entrado en su cuenta.
const pixivSessionCookieName = 'PHPSESSID';

/// La página en la que se entra en Pixiv, que es a donde se manda al usuario
/// cuando quiere importar de ahí y todavía no hay sesión.
const pixivLoginUrl = 'https://accounts.pixiv.net/login';

/// Cuántos marcadores se piden por página. Es el tamaño que usa su propia web.
const pixivPageSize = 48;

/// Tope de páginas que se recorren de una vez por cada listado de marcadores.
/// Con el tamaño de página son casi dos mil obras, que es de sobra para una
/// importación completa.
const pixivMaxPages = 40;

/// Los dos listados de marcadores de una cuenta: los que se ven desde fuera y
/// los que sólo ve su dueño. Es el valor del parámetro `rest` de su API, y
/// también con lo que se distingue por dónde se quedó la última importación de
/// cada uno.
const pixivPublicBookmarks = 'show';
const pixivPrivateBookmarks = 'hide';
const pixivBookmarkCollections = [pixivPublicBookmarks, pixivPrivateBookmarks];

/// El tipo de obra que Pixiv llama *ugoira*: una animación que no se sirve como
/// vídeo sino como un zip de fotogramas. No hay ahí ningún fichero que la
/// aplicación pueda reproducir, así que se monta uno al descargarla.
const pixivUgoiraIllustType = 2;

/// Nombre de la etiqueta de origen con la que nace el contenido de Pixiv, para
/// que la ordenación de ficheros por origen sepa dónde ponerlo.
const pixivSourceTagName = 'Pixiv';

// Danbooru
/// La dirección con la que se nombra lo que hay en Danbooru, y también por
/// donde responde su API: es pública y se pide a las mismas direcciones que se
/// ven en el navegador, añadiéndoles `.json`.
const danbooruSiteUrl = 'https://danbooru.donmai.us';
const danbooruApiHost = 'danbooru.donmai.us';

/// Cuántas publicaciones se piden por página. Es el máximo que admite su
/// listado de publicaciones; otros listados admiten más, pero éste no.
const danbooruPageSize = 200;

/// Tope de páginas que se recorren de una vez. Con el tamaño de página son
/// veinte mil publicaciones, de sobra para una importación completa.
const danbooruMaxPages = 100;

/// Lo que se espera entre página y página.
///
/// Danbooru pide no pasar de una petición por segundo en una sesión larga, y
/// una importación lo es. No hace falta esperar entre las descargas de los
/// ficheros: eso no va contra su API.
const danbooruPageDelay = Duration(seconds: 1);

/// Nombre de la etiqueta de origen con la que nace el contenido de Danbooru,
/// para que la ordenación de ficheros por origen sepa dónde ponerlo.
const danbooruSourceTagName = 'Danbooru';

/// Las credenciales de la API de Danbooru: el nombre de la cuenta y la clave
/// que se saca del perfil del usuario.
const danbooruUsernamePreferenceKey = 'danbooru_username';
const danbooruApiKeyPreferenceKey = 'danbooru_api_key';

// Gelbooru
/// La dirección con la que se nombra lo que hay en Gelbooru, y por donde
/// responde su API: todo cuelga de la misma página, distinguida por parámetros.
const gelbooruSiteUrl = 'https://gelbooru.com';
const gelbooruApiHost = 'gelbooru.com';
const gelbooruApiPath = '/index.php';

/// Cuántos favoritos se piden por página.
const gelbooruPageSize = 100;

/// Tope de páginas del listado de favoritos que se recorren de una vez. Con el
/// tamaño de página son diez mil favoritos.
const gelbooruMaxPages = 100;

/// Cuántas publicaciones seguidas puede dejar de dar Gelbooru antes de dar la
/// importación por rota.
///
/// Que una publicación marcada ya no exista es normal; que no llegue ninguna de
/// las primeras es que algo no va, y es mejor decirlo que devolver una
/// importación vacía como si la cuenta no tuviera favoritos.
const gelbooruMinAskedToGiveUp = 5;

/// Nombre de la etiqueta de origen con la que nace el contenido de Gelbooru,
/// para que la ordenación de ficheros por origen sepa dónde ponerlo.
const gelbooruSourceTagName = 'Gelbooru';

/// Las credenciales de la API de Gelbooru: el identificador de la cuenta (un
/// número) y su clave. Los dos salen de las opciones de la cuenta.
const gelbooruUserIdPreferenceKey = 'gelbooru_user_id';
const gelbooruApiKeyPreferenceKey = 'gelbooru_api_key';

// Navegador de la aplicación (experimental)
/// Por dónde empieza el navegador mientras el usuario no diga otra cosa: un
/// buscador, que es de donde se sale a cualquier sitio.
const browserHomeUrl = 'https://www.google.com';

/// La página de inicio que haya elegido el usuario para el navegador.
const browserHomePreferenceKey = 'browser_home_url';

/// La última página en la que se dejó el navegador. No es un ajuste: es dónde
/// se estaba, y por eso se guarda solo y no se enseña en ninguna pantalla.
const browserLastUrlPreferenceKey = 'browser_last_url';

/// A qué tamaño se enseñan las páginas dentro de la aplicación.
///
/// Algo más pequeñas que en un navegador de verdad: la ventana ya está
/// compartida con el menú lateral y la cabecera, y una página a tamaño completo
/// obliga a desplazarse para ver lo que hay.
const browserZoom = 0.75;

/// Nombre de la etiqueta de origen del contenido que se prepara desde el
/// navegador, para que la ordenación de ficheros por origen sepa dónde ponerlo.
const browserSourceTagName = 'Web';

/// Con lo que se identifica la aplicación al descargar lo que se ha encontrado
/// navegando.
///
/// Aquí no vale el de la aplicación: lo que se pide son los ficheros de una
/// página que el usuario está viendo en un navegador, y hay servidores de
/// contenidos que a cualquier otra cosa le responden que no. Se pide como lo
/// pediría el navegador que los está enseñando.
const browserUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

/// El color con el que se señala en la página el contenido de la lista.
///
/// Va aquí y no en la paleta de la aplicación porque no se pinta en la
/// aplicación sino dentro de una página cualquiera de internet: tiene que verse
/// sobre lo que sea que haya debajo.
const browserHighlightColor = '#FF87B3';

// Animaciones por fotogramas
/// Lo que dura un fotograma cuando la plataforma no dice cuánto, en
/// milisegundos. Diez por segundo, que es el paso al que suelen ir estas
/// animaciones.
const defaultAnimationFrameDelay = 100;

/// Ancho máximo de los fotogramas de una animación montada por la aplicación.
/// Lo que venga más grande se reduce: un GIF de decenas de fotogramas a tamaño
/// original ocupa más que el vídeo que nunca fue y tarda una eternidad en
/// escribirse.
const maxAnimationFrameWidth = 1000;

/// Tope de lo que se descarga de un paquete de fotogramas. Es mucho menor que
/// el de un fichero suelto porque este sí entra entero en memoria: hay que
/// abrirlo para poder montarlo.
const maxAnimationSourceBytes = 64 * 1024 * 1024;

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

// Gestión de creadores
/// Columnas de la rejilla de la pantalla de gestión de creadores. Las mismas que
/// en la de etiquetas: las dos pantallas reparten el hueco igual (ficha arriba,
/// rejilla debajo y lista al lado).
const creatorManagerGridColumns = tagManagerGridColumns;

/// Alto de la ficha de la pantalla de gestión de creadores.
///
/// Va fijo y no lo pone su contenido: así la ficha mide lo mismo tenga el
/// creador los enlaces que tenga, y cambiar de uno a otro (o añadirle un enlace)
/// no mueve de sitio la rejilla que hay debajo. El bloque de enlaces se queda con
/// el hueco que sobra y desplaza lo que no quepa.
const creatorCardHeight = 360.0;

/// Hasta dónde puede encogerse esa ficha.
///
/// Es lo que miden su avatar y su formulario, así que por debajo de aquí lo que
/// lleva dentro ya no cabe: en una ventana más baja que eso lo que se queda sin
/// sitio es la rejilla.
const creatorCardMinHeight = 330.0;

/// Lo que se le deja como mínimo a la rejilla de esa pantalla.
///
/// La ficha es lo primero que cede: en una ventana baja se queda con lo que haya
/// hasta aquí en vez de empujar la rejilla fuera de la pantalla.
const creatorGridMinHeight = 220.0;

/// Alto de una fila de enlace de la ficha del creador, y de los botones que la
/// acompañan.
///
/// Más apretado que el de un `IconButton` suelto (48): son varias filas dentro
/// de una ficha que comparte el alto de la pantalla con la rejilla, y con el
/// hueco de por defecto sólo cabría una.
const creatorProfileRowHeight = 32.0;

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
