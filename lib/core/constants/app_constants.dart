import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

const appName = "FeRN";
const appLogo = 'assets/images/Fern_logo.png';

// Routes
/// La pantalla de bienvenida, que es por donde entra la aplicación. Va en la
/// raíz porque no se navega a ella: se sale de ella y no se vuelve.
const splashRoute = '/';

const mediaRoute = '/media';
const importRoute = '/import';
const favoritesRoute = '/favorites';
const deletedRoute = '/deleted';
const creatorManagerRoute = '/creator-manager';
const tagManagerRoute = '/tag-manager';

// Reconocimiento. Las pantallas llegan en fases posteriores; las rutas se
// declaran ya porque los avisos necesitan saber a dónde llevan.
const fernieManagerRoute = '/fernies';

/// Parámetro de consulta de la pantalla de fernies: cuál llega ya elegido.
///
/// Es lo que hace que pulsar el avatar de un fernie en el panel del visor
/// aterrice en **ese** fernie y no en el primero de la lista.
const fernieQueryParam = 'fernie';

String fernieManagerRouteWithFernie(int fernieId) =>
    '$fernieManagerRoute?$fernieQueryParam=$fernieId';
const repeatedMediaRoute = '/repeated-media';
const modelsRoute = '/models';

/// El árbol que decide en qué orden se ejecutan los modelos.
///
/// Se llega desde el botón de la pantalla de modelos y no desde el menú lateral:
/// es una vista **de** los modelos, no un sitio aparte de la aplicación.
const modelTreeRoute = 'tree';

String modelTreePath() => '$modelsRoute/$modelTreeRoute';

/// El detalle de un modelo. Cuelga de la rejilla, así que la flecha de volver
/// lleva a ella sin tener que decírselo.
const modelDetailRoute = 'detail/:id';

String modelDetailPath(int id) => '$modelsRoute/detail/$id';

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

/// Parámetro de consulta del visor: qué región hay que resaltar al abrirlo.
///
/// Es lo que hace que, al pulsar una celda de la rejilla de fernies (que enseña
/// sólo el recorte), el contenido se abra entero y el ojo sepa dónde mirar.
const viewerHighlightQueryParam = 'highlight';

String viewerRouteWithHighlight(int regionId) =>
    '$viewerRoute?$viewerHighlightQueryParam=$regionId';

/// Cuántas opciones enseña un desplegable antes de desplazarse, y el relleno
/// que el propio desplegable pone por arriba y por abajo. Con los dos sale el
/// alto exacto de esas opciones.
const dropdownMaxVisibleItems = 5;
const dropdownMenuPadding = 16.0;

// Images
const fernEmptyImage = 'assets/images/fern_empty.png';

// Icons
const icRight = 'assets/icons/ic_right.png';
const icLeft = 'assets/icons/ic_left.png';

/// El icono de los fernies. Es una imagen y no un glifo del juego de iconos
/// porque no hay ninguno que valga: un fernie no es una cara, ni una
/// etiqueta, ni un recorte.
const icFernie = 'assets/icons/ic_fernie.png';

const icInfo = 'assets/icons/ic_info.png';
const icShare = 'assets/icons/ic_share.png';
const icDelete = 'assets/icons/ic_delete.png';
const icHeart = 'assets/icons/ic_heart.png';

// Unknown creator
final unknownCreator = CreatorEntity(id: 0, name: "Unknown");

// Unknown tag
final unknownTag = TagEntity(id: 0, name: "Unknown", children: []);

// Esquema de la base de datos
/// Por qué versión va el esquema de la base de datos.
///
/// La 1 es todo lo anterior a FeRN 2.0, cuando no se llevaba la cuenta: no hay
/// preferencia guardada y se asume esa. Subir este número obliga a mirar si el
/// cambio necesita una migración en `schemaMigrations` o si es de los que Isar
/// resuelve sola.
const firstSchemaVersion = 1;

/// La 3 añade las colecciones de fernies y de sus regiones; la 4, las de los
/// modelos de reconocimiento y sus fernies asignados. Son colecciones nuevas,
/// así que Isar las crea sola y no hay ninguna migración que escribir: el número
/// sube igual para dejar constancia de que el esquema no es el mismo.
const currentSchemaVersion = 6;

// Preferences keys
/// Hasta qué versión se ha puesto al día la base de datos de este equipo.
const schemaVersionPreferenceKey = 'schema_version';

const rootPathPreferenceKey = 'user_media_root_path';
const languagePreferenceKey = 'app_language';
const syncLocalFilesPreferenceKey = 'sync_local_files';
const copyFilesPreferenceKey = 'copy_files';
const libraryPathPreferenceKey = 'library_path';
const avatarsPathPreferenceKey = 'avatars_path';

/// Dónde vive todo lo del reconocimiento. Como la de avatares, nunca está
/// vacía: si el usuario no ha elegido ninguna, se usa la que cuelga del
/// directorio de datos de la aplicación.
const recognitionPathPreferenceKey = 'recognition_path';

// Avisos
/// Los avisos, en general: si se dan y si suenan.
const notificationsEnabledPreferenceKey = 'notifications_enabled';
const notificationsMutedPreferenceKey = 'notifications_muted';
const notificationsVolumePreferenceKey = 'notifications_volume';
const notificationsMaxSecondsPreferenceKey = 'notifications_max_seconds';

/// Prefijos de lo que se guarda por cada clase de aviso. Se completan con el
/// identificador de [NotificationKind]: `notification_badge_training`, y así.
const notificationBadgePreferenceKeyPrefix = 'notification_badge_';
const notificationSoundPreferenceKeyPrefix = 'notification_sound_';
const notificationSoundPathPreferenceKeyPrefix = 'notification_sound_path_';

/// Cuántos avisos hay sin mirar de cada clase. Se completa igual que los
/// anteriores.
const notificationCountPreferenceKeyPrefix = 'notification_count_';

/// A partir de aquí el contador deja de decir el número exacto: lo que importa
/// es que hay mucho, y un número de tres cifras no cabe en el botón.
const notificationBadgeMaxCount = 99;

/// Carpeta donde se copian los sonidos que elige el usuario, para que borrar o
/// mover el original no deje el aviso mudo.
const notificationSoundsFolderName = 'sounds';

/// Sonidos de fábrica. Son un punto de partida: la idea es que el usuario
/// ponga los suyos.
const defaultNotificationSound = 'assets/sounds/fern_notification.wav';
const successNotificationSound = 'assets/sounds/fern_success.wav';
const alertNotificationSound = 'assets/sounds/fern_alert.wav';

/// Cuánto se deja sonar un aviso, de fábrica y como mucho.
///
/// Un aviso es un toque corto: si el usuario elige una canción, se corta al
/// llegar aquí en lugar de rechazarla o de tocar su fichero.
const defaultNotificationSeconds = 5;
const minNotificationSeconds = 1;
const maxNotificationSeconds = 15;
const defaultNotificationVolume = 70;
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
const pauseWhenSeekingPreferenceKey = 'pause_when_seeking';

/// Con qué colores se pinta la aplicación: el claro, el oscuro, el del sistema
/// o el del usuario. De fábrica, el del sistema.
const themeModePreferenceKey = 'theme_mode';

/// Prefijo de las preferencias que guardan los colores del tema a medida. Se
/// completa con el identificador del color (`custom_color_primary`, y así con
/// los demás). Los que el usuario no haya tocado no tienen preferencia: es lo
/// que los distingue de los que sí, y lo que hace que se hereden del tema de
/// fábrica.
const customColorPreferenceKeyPrefix = 'custom_color_';

/// Qué hace el visor al dar por definitivo un contenido importado: cerrarse o
/// pasar al siguiente. De fábrica, pasar al siguiente.
const viewerSaveBehaviorPreferenceKey = 'viewer_save_behavior';

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

// Reconocimiento
/// Carpeta donde vive todo lo que hace falta para reconocer contenido.
///
/// Va aparte de la biblioteca y de los avatares porque no es contenido del
/// usuario sino maquinaria: el entorno con el que se entrena, los modelos y los
/// conjuntos de datos que se preparan para entrenarlos. Puede ocupar varios
/// gigas, así que el usuario puede llevársela a otro disco.
const recognitionFolderName = 'recognition';

/// Las cuatro subcarpetas de la carpeta de reconocimiento.
///
/// [recognitionDatasetsFolderName] es material de usar y tirar: se genera al
/// entrenar a partir de las regiones guardadas en la base de datos y se puede
/// borrar sin perder nada. [recognitionWeightsFolderName] son los modelos ya
/// entrenados, que es lo único que de verdad duele perder.
/// [recognitionRunsFolderName] es lo que escribe el entrenador (registros,
/// curvas, matrices de confusión) y [recognitionRuntimeFolderName] el entorno
/// de Python, que siempre se puede volver a instalar.
const recognitionDatasetsFolderName = 'datasets';
const recognitionWeightsFolderName = 'weights';
const recognitionRunsFolderName = 'runs';
const recognitionRuntimeFolderName = 'runtime';

const recognitionSubfolderNames = [
  recognitionDatasetsFolderName,
  recognitionWeightsFolderName,
  recognitionRunsFolderName,
  recognitionRuntimeFolderName,
];

// El entorno de Python
/// De dónde se baja `uv`, el binario con el que se monta todo lo demás.
///
/// La versión va fijada porque es la que se ha probado; si esa etiqueta ya no
/// existe se cae a la última publicada, que es preferible a dejar al usuario sin
/// reconocimiento por un 404. Subirla es un cambio consciente.
const uvReleaseBaseUrl = 'https://github.com/astral-sh/uv/releases';
const uvPinnedVersion = '0.5.11';

/// Qué Python instala `uv` para el entorno. Ultralytics y torch publican ruedas
/// para esta versión en los tres sistemas.
const sidecarPythonVersion = '3.12';

/// Los paquetes del entorno, con la versión de ultralytics fijada: una versión
/// mayor podría cambiar la forma de sus resultados, que es justo lo que el
/// script del sidecar da por supuesto.
const sidecarUltralyticsPackage = 'ultralytics>=8.3.0,<8.4.0';

/// Índices de ruedas de PyTorch. El de CPU es el de fábrica y pesa una décima
/// parte que el de CUDA; el de GPU sólo se instala si el usuario lo pide.
const torchCpuIndexUrl = 'https://download.pytorch.org/whl/cpu';
const torchCudaIndexUrl = 'https://download.pytorch.org/whl/cu124';

/// El script del sidecar.
///
/// Al arrancar se compara la **huella** del que trae la aplicación con la que
/// haya escrita en disco y se reescribe si no coinciden. Antes esto era un
/// número a mano, y pasó lo que tenía que pasar: se añadió un método nuevo al
/// script sin acordarse de subirlo, y todas las instalaciones existentes se
/// quedaron con el script viejo para siempre. Con la huella no hay nada que
/// acordarse de hacer.
const sidecarScriptAsset = 'assets/python/fern_sidecar.py';

/// Cuánto se deja al sidecar sin peticiones antes de cerrarlo. Cargar un modelo
/// cuesta segundos, así que tampoco conviene cerrarlo en cuanto se calla.
const sidecarIdleTimeout = Duration(minutes: 10);

/// Cuánto se tiñe de rojo el aviso de que la instalación ha fallado. Es un
/// fondo, no una alarma: lo que tiene que leerse es el texto de encima.
const sidecarFailureTint = 0.12;

/// Cada cuánto cambia el texto que dice que la instalación sigue trabajando, y
/// cuánto tarda en dar paso al siguiente.
///
/// El fundido es largo a propósito y dentro de él las dos frases no se cruzan:
/// primero se va la anterior y luego entra la nueva. Rotar deprisa marea, y es
/// un texto que sólo está ahí para decir que se sigue trabajando.
const sidecarActivityRotation = Duration(seconds: 10);
const sidecarActivityFade = Duration(milliseconds: 900);

/// Lo que baja el texto nuevo mientras aparece, en fracción de su propio alto.
/// Poco: es un acompañamiento del fundido, no un movimiento en sí.
const sidecarActivitySlide = 0.25;

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

/// Con cuánto se llega a la pantalla de importación la primera vez.
///
/// Diez, y no «todo». Traerse una cuenta entera es una descarga de horas y
/// gigas, y era lo que pasaba con sólo pulsar el botón sin haber mirado el
/// desplegable. Diez es una muestra: se ve qué llega de esa fuente y se decide
/// con eso delante.
const defaultImportLimit = 10;

/// Dónde se recuerda el último tope elegido.
///
/// Se recuerda porque quien importa de una fuente suele querer lo mismo cada
/// vez, y tener que cambiarlo en cada visita convierte el valor de fábrica en
/// una molestia diaria en vez de en una red de seguridad.
const importLimitPreferenceKey = 'import_limit';

/// En qué orden se pinta la biblioteca.
const mediaSortOrderPreferenceKey = 'media_sort_order';

/// Y en qué orden se pinta lo pendiente de revisar, que es otro ajuste.
const importSortOrderPreferenceKey = 'import_sort_order';
/// Los topes que se ofrecen al importar.
///
/// Empieza en uno a propósito: probar una fuente recién configurada, o mirar qué
/// pinta tiene lo que va a llegar, es lo primero que se hace y para eso diez ya
/// son muchos. Los tres primeros son para asomarse; los demás, para traerse de
/// verdad.
const importLimitOptions = [
  unlimitedImportLimit,
  untilLastImportLimit,
  1,
  2,
  5,
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

/// Cuántos ficheros se descargan a la vez.
///
/// Bajar de uno en uno desperdicia casi todo el tiempo esperando a la red, y
/// bajar sin tope castiga a la conexión y al sitio del que se descarga.
const maxParallelDownloads = 4;

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

/// Su sitio, y el servidor del que salen los ficheros.
const redgifsSiteUrl = 'https://www.redgifs.com';
const redgifsMediaHost = 'media.redgifs.com';

/// Lo que hay que mandar para bajarse un fichero suyo.
///
/// Su servidor de contenidos mira de dónde dice venir la petición, igual que el
/// de Pixiv. Sin esto puede contestar con algo que no es lo que se pidió — y es
/// uno de los sospechosos de que los vídeos llegaran sin sonido.
const Map<String, String> redgifsDownloadHeaders = {
  'Referer': '$redgifsSiteUrl/',
  'Origin': redgifsSiteUrl,
};

// Reddit
/// Donde se registran las aplicaciones de Reddit.
///
/// Registrarla es cosa de Reddit y no hay forma de saltárselo desde aquí; lo que
/// sí se puede es llevar al usuario directo al sitio, y con su sesión ya puesta
/// porque el navegador es el de la propia aplicación.
/// Cuánto se deja a la vista del navegador destruirse antes de montar otra.
///
/// Suficiente para que el motor de debajo se cierre del todo. Montar la nueva
/// en el mismo fotograma la hace nacer sobre uno a medio morir.
const browserResetPause = Duration(milliseconds: 400);

/// Dónde se recuerda cuándo hay que apartar el navegador.
const browserAsidePreferenceKey = 'browser_aside_policy';

/// A partir de cuántos contenidos una importación se considera grande.
///
/// El número sale de lo que se ha visto romper el navegador: traerse diez no lo
/// rompe nunca y traerse mil sí. Cincuenta es donde una importación deja de ser
/// asomarse y pasa a tener a la máquina descargando y descodificando un buen
/// rato seguido.
const browserAsideLargeImport = 50;

/// Cuánto puede tardar una página antes de que se dé por atascada.
///
/// Generoso a propósito: hay sitios lentos y conexiones peores. Lo que se busca
/// no es cortar nada, es que una carga que no va a terminar nunca lo diga en vez
/// de dejar la barra dando vueltas para siempre.
const browserBlankTimeout = Duration(seconds: 15);

const redditAppsUrl = 'https://www.reddit.com/prefs/apps';

/// La dirección de redirección que pide el formulario de Reddit.
///
/// Es obligatoria y **no se usa para nada** en una aplicación de tipo script:
/// nadie va a volver a ella. Se fija una y se ofrece copiada porque equivocarse
/// ahí deja la aplicación creada y sin funcionar, y el error no se ve por
/// ninguna parte.
const redditRedirectUri = 'http://localhost:8080';

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

/// La ficha de usuario, que es donde vive la clave de API.
const danbooruAccountUrl = 'https://danbooru.donmai.us/profile';
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

/// Las opciones de la cuenta, donde está el enlace de las credenciales de API.
const gelbooruOptionsUrl = 'https://gelbooru.com/index.php?page=account&s=options';
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

// Pinterest
/// La dirección con la que se nombra lo que hay en Pinterest, y por donde
/// responde la API con la que se pinta su web.
const pinterestSiteUrl = 'https://www.pinterest.com';
const pinterestApiHost = 'www.pinterest.com';
const pinterestResourcePath = '/resource/UserPinsResource/get/';

/// La página en la que se entra en Pinterest. Sólo hace falta para los tableros
/// secretos: lo público se pide sin cuenta.
const pinterestLoginUrl = 'https://www.pinterest.com/login/';

/// Con lo que su web se identifica ante su propia API. Sin estas dos, la
/// petición se rechaza aunque el resto esté bien: dicen qué pantalla suya se
/// supone que está pidiendo.
const pinterestAppVersion = 'a89153f';
const pinterestPwsHandler = 'www/[username].js';

/// Lo que se manda a la vez en la galleta y en la cabecera para su protección
/// contra peticiones de terceros. Sólo se comprueba que coincidan.
const pinterestCsrfToken = 'FernClientFernClientFernClient00';

/// La galleta con la que Pinterest reconoce una sesión. Es la que recoge el
/// navegador de la aplicación.
const pinterestSessionCookieName = '_pinterest_sess';

/// Tope de páginas que se recorren de una vez. Pinterest da unos veinte pines
/// por página, así que son unos dos mil.
const pinterestMaxPages = 100;

/// Lo que Pinterest devuelve como marca de página cuando ya no queda nada.
const pinterestEndBookmark = '-end-';

/// Nombre de la etiqueta de origen con la que nace el contenido de Pinterest,
/// para que la ordenación de ficheros por origen sepa dónde ponerlo.
const pinterestSourceTagName = 'Pinterest';

/// Las credenciales de Pinterest: el nombre de la cuenta y, si el usuario la ha
/// recogido, su sesión.
const pinterestUsernamePreferenceKey = 'pinterest_username';
const pinterestSessionIdPreferenceKey = 'pinterest_session_id';

// Pawchive
/// La dirección con la que se nombra lo que hay en Pawchive, y por donde
/// responde su API. Es un sitio hecho sobre Kemono, así que habla como él: todo
/// cuelga de `/api/v1`.
const pawchiveSiteUrl = 'https://pawchive.pw';
const pawchiveApiHost = 'pawchive.pw';
const pawchiveFavoritesPath = '/api/v1/account/favorites';

/// Los ficheros no los sirve el sitio sino un servidor propio, y no piden nada
/// especial para darlos.
const pawchiveFileUrl = 'https://file.pawchive.pw/data';

/// La página en la que se entra en Pawchive. Sin cuenta no hay favoritos que
/// pedir, así que aquí la sesión no es un extra.
const pawchiveLoginUrl = 'https://pawchive.pw/account/login';

/// La galleta con la que reconoce una sesión, la que recoge el navegador de la
/// aplicación.
const pawchiveSessionCookieName = 'session';

/// Nombre de la etiqueta de origen con la que nace el contenido de Pawchive,
/// para que la ordenación de ficheros por origen sepa dónde ponerlo.
const pawchiveSourceTagName = 'Pawchive';

/// Cuántas publicaciones devuelve el listado de un creador por página, y tope
/// de páginas que se recorren de una vez por autor.
const pawchivePageSize = 50;
const pawchiveMaxPages = 40;

/// Con qué se identifica el recorrido de un creador para llevar su marca
/// aparte: cada autor se recorre por su cuenta, así que dónde se quedó uno no
/// dice nada de los demás.
String pawchiveCreatorCollection({
  required String service,
  required String id,
}) =>
    '$service-$id';

/// El campo con el que cada favorito dice qué número le tocó al marcarlo. Es lo
/// único que dice en qué orden se marcaron.
const pawchiveFavoriteSequence = 'faved_seq';

/// El avatar de un creador de Pawchive.
///
/// Se arma con la dirección y no se pide a la API porque la API no lo da: es una
/// ruta fija del sitio. Si no hay avatar, la petición falla y la tarjeta enseña
/// la inicial, que es lo que hace la aplicación con todo lo demás.
String pawchiveCreatorAvatar({required String service, required String id}) =>
    '$pawchiveSiteUrl/icons/$service/$id';

/// Cuántos creadores se miran a la vez al contar sus publicaciones nuevas.
///
/// Contar obliga a una petición por creador, y con cincuenta marcados hacerlas
/// todas de golpe es pedirle al sitio que corte. De cuatro en cuatro la lista se
/// va llenando en unos segundos sin que nadie se queje.
const remoteCreatorCountConcurrency = 4;

/// Lo que mide una tarjeta de creador, y su proporción.
///
/// Por ancho máximo y no por número de columnas: son tarjetas pequeñas y lo que
/// importa es que quepan las que quepan, no que sean siempre cuatro como en la
/// rejilla de contenido.
const remoteCreatorCardWidth = 200.0;

/// Y lo que mide de alto.
///
/// Fijo y no una proporción: lo que ocupa una tarjeta lo deciden su avatar y sus
/// tres líneas de texto, no lo ancha que sea la ventana. Con una proporción, una
/// columna estrecha dejaba la tarjeta más baja que su contenido y éste se salía
/// por abajo.
/// El número sale de sumar lo que hay dentro con todo puesto: el avatar, el
/// nombre, la plataforma, la cuenta de publicaciones nuevas y la marca de «ya lo
/// tienes». La prueba de la tarjeta lo sostiene: si alguien le añade una línea,
/// se entera ahí y no en una captura del usuario.
const remoteCreatorCardHeight = 215.0;

/// Si de Pawchive se importa lo de los creadores marcados en lugar de las
/// publicaciones marcadas.
const pawchiveByCreatorsPreferenceKey = 'pawchive_by_creators';

/// La sesión de Pawchive, recogida del navegador.
const pawchiveSessionIdPreferenceKey = 'pawchive_session_id';

// Enlaces dentro de las publicaciones
/// Sitios que guardan ficheros para que cualquiera se los baje.
///
/// De aquí no se descarga solo: son páginas que hay que abrir (tienen su propia
/// espera, su captcha o su desplegable de ficheros), así que lo que se hace es
/// avisar al usuario y ofrecerle ir con el navegador.
const fileRepositoryHosts = {
  'mega.nz',
  'mega.io',
  'pixeldrain.com',
  'gofile.io',
  'mediafire.com',
  'drive.google.com',
  'dropbox.com',
  'workupload.com',
  'sendspace.com',
  'anonfiles.com',
  'bunkr.si',
  'bunkrr.su',
  'catbox.moe',
  'krakenfiles.com',
  'saint2.su',
  'cyberdrop.me',
};

/// Extensiones de fichero comprimido que la aplicación sabe abrir.
///
/// Sólo la primera: las demás se reconocen para no darlas por contenido, pero
/// no se descomprimen (harían falta más librerías, y son mucho menos comunes).
/// Cuántas publicaciones con enlaces pendientes se recuerdan de una importación.
///
/// El resumen del final es para mirarlo: una lista de mil no la lee nadie, y
/// arrastrarla en memoria durante una importación de horas no aporta nada.
const pendingLinkPostsLimit = 100;

/// Dónde se guardan las preguntas de enlaces que quedan sin contestar.
///
/// Se guardan porque aparcar una es decir «esto lo miro otro día», y otro día
/// suele ser después de cerrar la aplicación. Perderlas al cerrar convertiría
/// aparcar en tirar.
const pendingLinkReviewsPreferenceKey = 'pending_link_reviews';

const archiveExtensions = {'.zip', '.rar', '.7z'};
const extractableArchiveExtensions = {'.zip'};

/// Tope de lo que se saca de un comprimido. Un fichero que dice pesar poco y al
/// abrirlo llena el disco es un problema conocido, y esto lo corta.
const maxArchiveContentBytes = 2 * 1024 * 1024 * 1024;

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

/// Cuánto se guarda un rechazo antes de tirarlo.
///
/// Noventa días. Bastante más que la papelera porque no estorba a nadie —no se
/// ve en ninguna pantalla— y porque lo que mide tarda en cambiar: el acierto de
/// un modelo se juzga sobre meses de uso, no sobre una tarde. Y bastante menos
/// que para siempre, porque un rechazo de hace tres meses es de un modelo que se
/// ha entrenado dos veces desde entonces y ya no habla de él.
const rejectionRetention = Duration(days: 90);

/// A partir de qué distancia dos contenidos dejan de ser el mismo.
///
/// De 0 a 64 bits distintos. Cero es idéntico; de uno a cinco es casi seguro la
/// misma imagen recomprimida o con una marca de agua pequeña; hasta diez son
/// recortes leves o cambios de color. Ocho es el punto donde todavía se agrupa lo
/// que de verdad sobra sin empezar a juntar cosas que no.
///
/// Es un listón deliberadamente prudente: agrupar de más manda a la papelera
/// contenido que no sobra, y eso es peor que dejar un duplicado sin encontrar.
const defaultDuplicateThreshold = 8;

/// Hasta dónde se puede mover ese listón desde los ajustes.
const maxDuplicateThreshold = 16;

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

// Pantalla de bienvenida
/// Lo que dura la animación del logo.
///
/// Con la transición de salida que la sigue, la pantalla entera se queda por
/// debajo de los dos segundos: es una presentación, no una espera, y pasado ese
/// punto lo único que hace es retrasar la entrada a la biblioteca.
const splashDuration = Duration(milliseconds: 1600);

/// Ancho al que se pinta el logo.
const splashLogoWidth = 260.0;

/// Tamaño con el que aparece el logo, antes de asentarse en el suyo. Entra
/// creciendo, que es lo que le da el rebote del final.
const splashLogoInitialScale = 0.72;

/// El círculo que se abre por detrás del logo: su tamaño, hasta dónde crece y
/// con cuánto empieza. Se va apagando mientras se abre, así que no llega a
/// taparlo en ningún momento.
const splashHaloSize = 240.0;
const splashHaloMinScale = 0.4;
const splashHaloMaxScale = 2.2;
const splashHaloOpacity = 0.55;

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

/// Lo que mide un botón del menú desplegado y plegado, y el hueco entre su
/// icono y su título, que desaparece al plegarse.
///
/// Estaban sueltos dentro del propio botón; se suben aquí porque el contador de
/// avisos tiene que caber en las dos anchuras.
const sidebarTileExpandedWidth = 200.0;
const sidebarTileCollapsedWidth = 70.0;
const sidebarTileGap = 10.0;

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

/// Lo que se encoge el botón de añadir mientras se pulsa. Poco: es un acuse de
/// recibo, no un rebote.
const addButtonPressedScale = 0.92;

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

// Gestión de fernies
/// La rejilla de fernies reparte el hueco igual que las de etiquetas y
/// creadores, así que lleva las mismas columnas.
const fernieManagerGridColumns = tagManagerGridColumns;

/// Umbrales con los que se avisa de que un fernie da poco de sí para entrenar.
///
/// YOLO necesita muchas más muestras de las que uno intuye, y un fernie con
/// cuatro regiones no va a reconocer nada. Sin decirlo en la propia ficha, la
/// conclusión al entrenar sería que la función no funciona, cuando lo que pasa
/// es que no hay con qué. Los tres números son de partida y se pueden mover con
/// lo que se vea al entrenar de verdad (fase 3).
const fernieMinRegions = 20;
const fernieRecommendedRegions = 50;
const fernieMinDistinctMedia = 5;

/// Área mínima, en tanto por uno del contenido, para que un arrastre cuente como
/// región.
///
/// Es lo que evita que un clic suelto o un temblor de la mano abran el menú de
/// asignación. Medio por ciento de lado en cada eje: lo bastante pequeño para
/// marcar una cara al fondo de una foto, y lo bastante grande para que un clic
/// no cuele.
const fernieMinRegionFraction = 0.0025;

/// Por debajo de esta parte del contenido se avisa de que la región es muy
/// pequeña. No impide guardarla: el aviso es informativo.
const fernieTinyRegionFraction = 0.02;

/// Radio en el que un tirador de región responde al ratón.
///
/// Algo más grande que el tirador que se pinta: agarrar una esquina no puede
/// exigir puntería de cirujano.
const regionHandleReach = 12.0;

/// La pestaña de acciones que sale de la región elegida.
const regionTabWidth = 132.0;
const regionTabHeight = 36.0;

/// Cuánto se aclara la región elegida respecto a las demás. Es lo que la
/// distingue de un vistazo sin cambiarle el color.
const regionSelectedTint = 0.55;

/// Cuánto se puede alejar el visor. Es el que ya tenía, sacado de donde estaba
/// escrito a mano.
const viewerMinZoomScale = 0.5;

/// Cuánto se puede acercar el visor en modo fernie.
///
/// Se sube por encima del zoom de siempre porque marcar una región pequeña con
/// precisión pide acercarse más de lo que hace falta sólo para mirar.
const fernieMaxZoomScale = 8.0;

/// El resaltado con el que el visor señala una región al llegar desde la
/// pantalla de fernies: se oscurece todo menos la región, se queda así un
/// momento y se vuelve a la normalidad.
///
/// Va de una sola pasada y sin parpadeos a propósito. Encender y apagar varias
/// veces una imagen a pantalla completa marea y, en vez de llevar el ojo a la
/// región, lo obliga a perseguirla.
const fernieHighlightFadeDuration = Duration(milliseconds: 600);
const fernieHighlightHoldDuration = Duration(milliseconds: 1500);

/// Lo que tardan las regiones en aparecer y en irse al entrar y salir del modo
/// fernie.
///
/// Fuera del modo no se ven: el visor es para mirar el contenido, no para
/// mirarlo lleno de rectángulos. Aparecer de golpe se leería como un fallo de
/// pintado, así que entran y salen con un desvanecido corto.
const fernieRegionsFadeDuration = Duration(milliseconds: 220);

/// Alto máximo del menú contextual con el que se asigna una región: lo justo
/// para el buscador y unos cuantos resultados sin comerse la pantalla.
const contextMenuMaxHeight = 320.0;

/// La sombra que separa el menú contextual del contenido que tiene debajo.
///
/// Es más marcada que la de un panel de cabecera porque aquí lo de detrás es una
/// imagen a pantalla completa, no el fondo liso de la aplicación.
const contextMenuElevation = 8.0;

/// Salto de fotograma cuando el reproductor no sabe a cuántos va el contenido.
///
/// Treinta por segundo es lo más común y, sobre todo, es mejor que un botón que
/// no hace nada: en un GIF de dos fotogramas o en un contenedor raro mpv no
/// siempre los declara.
const defaultFrameStep = Duration(microseconds: 33333);

/// Cuántas copias como mucho deja poner el arrastre de una región por los
/// fotogramas de en medio.
///
/// Arrastrar entre dos puntos muy separados de un vídeo largo son miles de
/// regiones de una tacada, y eso no es lo que nadie quiere: se corta aquí y se
/// vuelve a arrastrar si de verdad hacían falta más.
const maxDraggedFrames = 300;

/// La línea de tiempo del modo fernie: lo que ocupa y cuánto se separa del borde
/// de abajo del visor.
const fernieTimelineHeight = 56.0;

/// Lo alto que es la barra de reproducción del visor.
///
/// Más gruesa que la de fábrica: dentro se pintan los tramos que ya tienen
/// regiones marcadas, y en una barra fina no se distinguirían de la propia
/// barra.
const trackHeight = 6.0;

/// El salto de los botones de adelantar y retrasar del modo de mirar.
///
/// Cinco segundos es lo que lleva cualquier reproductor y sirve para buscar por
/// encima. Nada que ver con el salto de fotograma del modo fernie, que es para
/// pararse en uno.
const viewerSkipStep = Duration(seconds: 5);

/// El mando de la barra de reproducción y el halo que se le enciende debajo.
///
/// Se fijan en vez de dejar los de fábrica porque de su tamaño sale el hueco que
/// el recorrido deja a los lados, y de ese hueco dependen tres cosas que
/// **tienen que coincidir**: dónde se pintan los tramos ya marcados, dónde se
/// busca la muesca que hay bajo el cursor y a qué instante lleva pulsarla. Con
/// los de fábrica el tamaño lo pone el tema por dentro y desde fuera no se sabe.
const trackThumbRadius = 8.0;
const trackOverlayRadius = 16.0;

/// Lo que mide la nube que sale al pasar el cursor por una muesca de la línea
/// de tiempo.
///
/// Va fijo y no lo pone su contenido: la nube se abre y se cierra siguiendo al
/// cursor, y una que cambiara de ancho con el nombre más largo de cada muesca
/// daría un salto en cada una.
const fernieMarkBubbleWidth = 220.0;

/// Hasta dónde se dan por seguidos dos fotogramas marcados de un mismo vídeo.
///
/// Es lo que decide qué se junta en una sola celda de la pantalla de fernies.
/// La rejilla no sabe a cuántos fotogramas por segundo va cada contenido, así
/// que el corte va en tiempo: por debajo de una décima de segundo lo que hay
/// seguido se lee como una sola escena, y por encima, como dos momentos.
const fernieRegionGroupGap = Duration(milliseconds: 100);

/// Cuántos fotogramas como mucho se pasan en una de esas celdas.
///
/// Sacar un fotograma de un vídeo abre un reproductor entero, así que un tramo
/// de trescientos fotogramas sería inaguantable. De un tramo más largo se cogen
/// repartidos: lo que hace falta es que se vea el movimiento, no tenerlos todos.
const fernieRegionGroupMaxFrames = 12;

/// Lo que dura cada fotograma en el pase de una de esas celdas.
///
/// No es la velocidad del vídeo: de un tramo largo se cogen fotogramas
/// repartidos, así que pasarlos a la velocidad original sería un parpadeo. A
/// diez por segundo se lee el movimiento.
const fernieRegionFlipbookStep = Duration(milliseconds: 100);

/// Cuántos fernies enseña esa nube a la vez. El resto se desplazan.
///
/// El corte es a propósito: una nube que crece con veinte nombres tapa el
/// contenido, que es justo lo que se está mirando.
const fernieMarkMaxNames = 3;

/// Tolerancia de partida para dar por bueno que una región es de este
/// fotograma, cuando todavía no se sabe a cuántos va el contenido.
///
/// Lo normal es que la ponga el propio mando
/// (`MediaPlaybackController.frameTolerance`, medio fotograma): esto es sólo el
/// respaldo de mientras.
const fernieFrameTolerance = Duration(milliseconds: 20);

/// La barra con la que se reparte lo marcado de un fernie entre entrenar,
/// validar y probar.
const splitBarHeight = 10.0;

/// Cuándo avisar de que un fernie no da para entrenar.
///
/// Por debajo de [minRegionsPerClass] no hay con qué: el entrenamiento arranca y
/// no aprende nada. Por debajo de [lowRegionsPerClass] aprende poco. Y con menos
/// de [minMediaPerClass] contenidos distintos aprende **el fondo** en vez del
/// objeto, que es el aviso más importante de los tres porque no se ve en las
/// métricas: salen bien y luego falla con todo lo demás.
const minRegionsPerClass = 10;

/// Los límites de los mandos de dentro del entrenamiento.
///
/// No son caprichos: por debajo de diez épocas no aprende nada y por encima de
/// mil se está tirando el tiempo; el tamaño de imagen va de treinta y dos en
/// treinta y dos porque es con lo que trabaja YOLO, y un número cualquiera lo
/// redondearía por su cuenta.
const minTrainingEpochs = 10;
const maxTrainingEpochs = 1000;
const minTrainingImageSize = 320;
const maxTrainingImageSize = 1280;
const maxTrainingBatch = 64;

/// A partir de cuántas veces se da por desequilibrado un modelo.
///
/// Con diez a uno entre el fernie que más tiene y el que menos, el modelo
/// aprende a contestar siempre el mayoritario: acierta el noventa por ciento de
/// las veces sin haber aprendido nada, y las métricas le dan la razón.
const maxClassImbalance = 10;

const lowRegionsPerClass = 50;
const minMediaPerClass = 5;

/// Por debajo de qué acierto se avisa de que una clase ha salido mal.
///
/// No es un aprobado: es el punto a partir del cual el fernie va a fallar tanto
/// que se nota usándolo, aunque la media del modelo sea buena.
const weakClassThreshold = 0.5;

/// Lo oscuro que va el disco de detrás de las flechas a pantalla completa.
///
/// Sobre una imagen clara, un icono blanco sin nada detrás no se ve; y a
/// pantalla completa no hay margen gris que haga de fondo, como sí lo hay en la
/// ventana. Lo justo para separarlo de la foto sin taparla.
const fullscreenArrowScrimOpacity = 0.35;

/// Lo transparente que va lo que se arrastra, y el hueco que deja atrás.
///
/// El hueco atenuado y no invisible: se ve de dónde salió, y si se suelta en un
/// sitio que no lo acepta, el ojo ya sabe a dónde vuelve.
const draggingFeedbackOpacity = 0.9;
const draggingGhostOpacity = 0.35;

/// Hasta dónde se puede acercar y alejar el lienzo del árbol, y de cuánto en
/// cuánto.
///
/// El mismo reparto de gestos que el modo fernie: rueda para el zoom, arrastre
/// para desplazar. Dos convenciones distintas en la misma aplicación es lo que
/// hace que ninguna se recuerde.
const treeMinZoom = 0.3;
const treeMaxZoom = 2.0;
const treeZoomStep = 1.25;

/// Por debajo de qué zoom las tarjetas dejan el detalle y se quedan con el
/// nombre. A ese tamaño lo demás no se lee y sólo emborrona.
const treeSimplifyBelow = 0.5;

/// El grosor de las aristas del árbol de modelos, y el tamaño de su punta.
///
/// La punta no es adorno: dos nodos unidos por una línea a secas no dicen en qué
/// orden se ejecutan, y el orden es lo único que el árbol decide.
const treeEdgeWidth = 2.0;
const treeArrowSize = 10.0;

/// Con qué clave se guarda si lo reconocido vuelve a importación.
const returnRecognizedPreferenceKey = 'recognition_return_to_import';

/// Si al salir del visor la rejilla se coloca donde está lo que se ha mirado.
const returnToViewedMediaPreferenceKey = 'viewer_return_to_media';
const recognizeOnImportPreferenceKey = 'recognition_on_import';
const duplicateThresholdPreferenceKey = 'duplicates_threshold';

/// Con qué clave se guarda si la aplicación busca repetidos por su cuenta.
const automaticDuplicateScanPreferenceKey = 'duplicates_auto_scan';

/// Con qué clave se guarda cada cuánto lo hace.
const duplicateScanPeriodPreferenceKey = 'duplicates_scan_period';

/// Qué se ve con el modo NSFW abierto.
const nsfwUnlockedViewPreferenceKey = 'nsfw_unlocked_view';

/// Qué se ve con el modo NSFW cerrado.
const nsfwLockedViewPreferenceKey = 'nsfw_locked_view';

/// Si marcar una etiqueta arrastra a las que cuelgan de ella.
const nsfwChildTagsPreferenceKey = 'nsfw_marks_child_tags';

/// Con qué clave se guarda de qué fuente se estuvo importando la última vez.
const lastImportSourcePreferenceKey = 'import_last_source';

/// Si el escaneo mira también vídeos y GIF.
const duplicateScanMovingPreferenceKey = 'duplicates_scan_moving';

/// Con qué clave se guarda cuándo terminó el último escaneo, en ISO 8601.
///
/// La escribe el escaneo al acabar bien, venga de donde venga: si el usuario
/// acaba de buscar repetidos a mano, que la aplicación lo repita sola al día
/// siguiente es trabajo tirado.
const lastDuplicateScanPreferenceKey = 'duplicates_last_scan_at';

/// Cuánto se espera desde el último contenido importado antes de mandarlo
/// todo a reconocer de una vez.
///
/// Una importación va soltando ficheros de uno en uno durante minutos.
/// Encolar un trabajo por cada uno llenaría la lista de tareas con
/// trescientas entradas de un segundo; esperar a que la importación se calme
/// deja **un** trabajo con todo dentro, que es lo que el usuario entiende
/// como «reconocer lo que acaba de llegar».
const recognitionImportDebounce = Duration(seconds: 3);

/// Cuántos contenidos se dejan acumular antes de mandarlos sin esperar más.
///
/// Sin tope, una importación de miles de ficheros que dure media hora no
/// reconocería nada hasta el final. Con él, el trabajo va saliendo por
/// tandas y se puede ir revisando mientras lo demás sigue llegando.
const recognitionImportBatchMax = 200;

/// Con qué clave se guarda cuántos fotogramas se miran de un vídeo.
const frameSamplesPreferenceKey = 'recognition_frame_samples';

/// Cuántos fotogramas se miran de un contenido que se mueve, al reconocer.
///
/// Cinco de fábrica: mirarlo entero es pagar una predicción por fotograma
/// —treinta por segundo— para responder algo que casi siempre se decide con
/// cinco. Es el ajuste que más afecta al tiempo total de reconocer una
/// biblioteca.
const defaultFrameSamples = 5;
const minFrameSamples = 1;
const maxFrameSamples = 20;

/// En qué punto del trazo va la etiqueta de una arista, de padre a hijo.
///
/// Cerca del hijo: en mitad del trazo, todas las aristas de un mismo padre caen
/// casi encima unas de otras, y con cinco hijos no hay forma de pulsar la que se
/// quiere. Junto al hijo se separan solas.
const treeEdgeLabelAt = 0.78;

/// Lo ancha que puede ser la etiqueta de una arista antes de cortarse.
///
/// Es el nombre de un fernie: más allá de esto tapa la tarjeta de al lado, y lo
/// que hace falta saber es cuál, no leerlo entero.
const treeEdgeLabelMaxWidth = 140.0;

/// A partir de qué ancho las filas de fernie de un modelo van de dos en dos.
///
/// Una fila es alta —nombre, recuentos, aviso y barra de reparto—, así que en
/// una ventana ancha a una sola columna sobra la mitad del papel. Por debajo de
/// esta cifra la barra de reparto se queda sin sitio para arrastrarla.
const fernieRowsTwoColumnsWidth = 900.0;

/// Lo que ocupa una tarjeta de la rejilla de modelos.
///
/// La rejilla se reparte por ancho máximo y no por número de columnas: la
/// ventana cambia de tamaño, y con un número fijo las tarjetas salen enormes en
/// pantalla ancha y espachurradas en estrecha. El alto va fijo porque todas
/// llevan lo mismo: cara, nombre, función, recuentos y estado.
const modelCardWidth = 220.0;
const modelCardHeight = 280.0;

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

// Avisos breves
/// Lo que se queda a la vista un aviso breve, y lo que tarda en aparecer y en
/// irse. Lo justo para leer una línea sin que estorbe.
const toastDuration = Duration(seconds: 3);

/// Cuánto dura el aviso que **lleva a algún sitio**.
///
/// Más que los otros porque hay que leerlo y además decidir si se pulsa, y tres
/// segundos no dan para las dos cosas. Pero se va igual: antes se quedaba hasta
/// que alguien lo pulsara, y como no tenía forma de cerrarse, quien no quería ir
/// se lo encontraba clavado en la pantalla para siempre.
const toastActionDuration = Duration(seconds: 12);
const toastFadeDuration = Duration(milliseconds: 200);

/// Desde dónde entra, en alturas suyas, y cuánto tapa lo que hay detrás.
const toastSlideOffset = 0.4;
const toastOpacity = 0.85;

// Visor
/// Tiempo sin mover el ratón tras el que la barra de acciones del visor se
/// esconde. Con el panel de información abierto no cuenta: ahí la barra se
/// queda.
const viewerControlsHideDelay = Duration(seconds: 3);

/// Lo que tarda la barra del visor en aparecer y en esconderse.
const viewerControlsFadeDuration = Duration(milliseconds: 200);

/// Lo que tarda el pase de un contenido al siguiente, el deslizamiento de
/// carrusel. Algo más largo que el desvanecido de la barra: aquí sí hay un
/// recorrido que seguir, y es lo que dice hacia qué lado se está yendo.
const viewerSlideDuration = Duration(milliseconds: 300);

/// Grosor del trazo de los iconos de la barra del visor.
///
/// Van más finos que el de fábrica (400) porque se pintan grandes y sobre el
/// contenido: a ese tamaño el trazo normal pesa más de lo que hace falta. El
/// sombreado es lo que los hace legibles, no el grosor.
const viewerIconWeight = 200.0;

/// Sombreado que se pone bajo la barra de acciones del visor para que sus
/// botones se lean también sobre un contenido claro. Es el mismo oscurecido que
/// llevan las celdas de la rejilla; lo que cambia es que aquí se mide en alto
/// fijo y no en parte de la celda, porque debajo hay una pantalla entera.
const viewerShadeHeight = 140.0;
const viewerShadeOpacity = mediaShadeOpacity;

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

/// Cuánto tiene que quedarse el ratón encima de un vídeo antes de que empiece a
/// reproducirse.
///
/// Sacar la previsualización cuesta abrir un reproductor de verdad, con su
/// memoria nativa. Sin esta espera, cruzar la rejilla de lado a lado abría uno
/// por cada celda que tocaba el cursor —decenas en un segundo— y ésa es la
/// causa principal del atasco al desplazarse deprisa.
///
/// Tres décimas: lo bastante para que pasar de largo no cuente y lo bastante
/// poco para que pararse encima se sienta inmediato.
const mediaVideoPreviewDelay = Duration(milliseconds: 300);

/// Cuántas previsualizaciones de fichero se recuerdan en memoria.
///
/// Son objetos pequeños —cuatro campos— pero una biblioteca de decenas de miles
/// los acumula todos, y el fotograma de cada vídeo sigue en el disco de todas
/// formas: volver a pedir uno olvidado es leer una entrada de caché, no abrir
/// el vídeo otra vez.
const mediaPreviewCacheLimit = 2000;

/// Techo de la caché de imágenes decodificadas de Flutter.
///
/// De fábrica son 100 MB, que con imágenes de veinte megapíxeles se agotan en
/// una pantalla de rejilla. Lo que pasa al agotarse no es un error: es que la
/// aplicación empieza a decodificar y tirar sin parar, y ahí se va el
/// rendimiento del desplazamiento.
const imageCacheMaxBytes = 200 << 20;

/// Cuánto se construye por delante y por detrás de lo que se ve en la rejilla.
///
/// Un poco más de una pantalla: bastante para que desplazarse no vaya a
/// tirones, y no tanto como para tener cientos de celdas montadas fuera de la
/// vista pidiendo cada una su miniatura.
const mediaGridCacheExtent = 600.0;

/// A partir de qué velocidad se considera que la rejilla va lanzada.
///
/// En píxeles por segundo. El número sale de separar dos cosas que hay que
/// distinguir bien: una rueda de ratón usada con ganas se queda en torno a mil o
/// mil quinientos, y un lanzamiento con el dedo o un tirón de la barra empieza
/// por encima de tres mil. El listón está donde no molesta a lo primero y coge
/// lo segundo.
const fastScrollVelocity = 3500.0;

/// Sobre cuánto tiempo se mide esa velocidad.
///
/// Por ventanas y no entre dos avisos seguidos: la rueda del ratón salta de
/// golpe y sin animación, así que entre dos avisos suyos la velocidad sale
/// enorme aunque se esté yendo despacio.
const fastScrollWindow = Duration(milliseconds: 90);

/// Cuánto se espera sin noticias antes de dar el desplazamiento por terminado.
///
/// Es un seguro: lo normal es que avise de que ha parado. Si ese aviso no
/// llegara, sin esto la rejilla se quedaría sin cargar nada para siempre.
const fastScrollIdleTimeout = Duration(milliseconds: 250);

/// De cuántos en cuántos se guardan los tamaños que la rejilla va descubriendo.
///
/// Al desplazarse se descubren decenas por segundo: una transacción por cada uno
/// sería peor que el problema que resuelve.
const mediaSizeBatchSize = 60;

/// Cuánto se espera antes de guardar una tanda a medias.
///
/// Lo justo para que una rejilla que se queda quieta acabe guardando lo suyo sin
/// que nadie note la escritura.
const mediaSizeBatchDelay = Duration(seconds: 2);

/// Cuántas columnas tiene la rejilla de contenido.
///
/// Una sola cuenta para las cinco rejillas que hay (biblioteca, importación,
/// favoritos, papelera y los resultados de una búsqueda): estaba repetida en
/// cada pantalla, y con el número suelto en cinco sitios cualquier cambio se
/// deja alguno por el camino y las pantallas dejan de parecerse entre sí.
const mediaGridColumns = 4;

/// Lo que mide la miniatura que va pegada al cursor al arrastrar contenido.
///
/// Pequeña a propósito: lo que hace falta es reconocer qué se está arrastrando
/// y ver cuántos van, no mirar la imagen.
const dragFeedbackSize = 96.0;

/// Cuánto se enciende una fila del menú cuando hay algo a punto de soltarse
/// encima. Lo justo para que se vea cuál es sin taparla.
const dropTargetHighlight = 0.35;
const mediaEmptyDurationLabel = '--:--';

// Video preview extraction
const videoThumbnailFolder = 'fern_video_thumbnails';
const videoThumbnailSeek = Duration(seconds: 1);
const videoProbeTimeout = Duration(seconds: 12);
const videoScreenshotAttempts = 10;
const videoScreenshotRetryDelay = Duration(milliseconds: 120);
const maxConcurrentVideoJobs = 2;

/// Cuántas cabeceras de imagen se leen a la vez.
///
/// Averiguar lo que mide una imagen obliga a **cargar el fichero entero en
/// memoria** (`ImmutableBuffer.fromFilePath`), aunque después sólo se lea su
/// cabecera. Sin tope, desplazarse deprisa por una biblioteca grande lanzaba una
/// lectura por celda construida —cientos en unos segundos, cada una con su
/// fichero entero dentro—, y con imágenes de veinte o treinta megas eso son
/// gigabytes a la vez. Es la causa más probable de que la aplicación se cayera
/// al bajar de golpe.
///
/// Seis, y no dos como los vídeos: leer una cabecera son milisegundos y abrir un
/// vídeo son segundos.
const maxConcurrentImageJobs = 6;

/// Cuánto se lee de una imagen para saber lo que mide.
///
/// El tamaño vive en los primeros cien bytes de todos los formatos que se
/// entienden; el margen es para el JPEG, que puede llevar delante metadatos y
/// hasta una miniatura entera antes de decir cuánto mide. Con esto no hace falta
/// leer el fichero entero, que era lo que encarecía tanto la importación como la
/// primera vuelta por la biblioteca.
const imageHeaderProbeBytes = 128 * 1024;

/// Cuánto se espera a que un salto dentro de un vídeo ya abierto llegue a su
/// sitio.
///
/// Mucho más corto que [videoProbeTimeout], que es lo que cuesta **abrir** un
/// fichero: con el vídeo abierto y decodificando, un salto es cuestión de
/// décimas. Con el mismo listón de doce segundos, cinco saltos que fallen
/// convierten un vídeo en un minuto de espera.
const videoSeekTimeout = Duration(seconds: 3);

/// Margen para que el fotograma del salto acabe de pintarse.
///
/// La posición llega antes que la imagen; sin esta pausa la captura sale con el
/// fotograma de antes del salto, y lo que se reconoce no es lo que se dice
/// haber mirado.
const videoSeekSettle = Duration(milliseconds: 150);

/// A partir de qué confianza una sugerencia se pinta como buena.
///
/// Es el mismo listón que el de la aceptación masiva: lo que se enseña de una
/// forma tiene que ser lo mismo que «aceptar todo lo que esté por encima»
/// aceptaría, o el color estaría prometiendo algo distinto de lo que el botón
/// hace.
const suggestionHighConfidence = 0.8;

/// Lo desvaído que va el porcentaje de una sugerencia poco fiable.
///
/// El tercer tramo se distingue con opacidad y no con otro color porque la
/// paleta no da para tres: la elige el usuario, y en la clara el gris de los
/// textos secundarios y el de lo apagado son exactamente el mismo. Además
/// «cuanto menos seguro, más tenue» se entiende sin que nadie lo explique.
const suggestionLowOpacity = 0.55;

/// Por debajo de esto una sugerencia se pinta como poco fiable.
///
/// No se esconde: media docena de aciertos raros al año salen de aquí, y lo que
/// hace falta es que se note de un vistazo cuáles hay que mirar con calma.
const suggestionLowConfidence = 0.5;

/// Con qué confianza mínima se le pregunta al motor al reconocer.
///
/// Muy por debajo del listón de cualquier modelo, y a propósito: lo que queda
/// entre esta cifra y el listón del modelo **no se propone**, pero se apunta.
/// Es lo que permite contestar «lo vio al 27 %, y tu listón está en el 35 %» en
/// vez de «no ha detectado nada», que es lo mismo dicho de una forma que no deja
/// arreglar nada.
///
/// Por debajo de esto sí se tira: son cajas al azar sobre el fondo.
const recognitionFloor = 0.05;

/// Cuántas imágenes se le mandan al motor en una sola petición.
///
/// Reconocer una biblioteca con un árbol de tres modelos eran tres peticiones
/// por contenido; en lote son tres por nivel, y el motor deja de ir y volver
/// entre unos pesos y otros. El tope existe porque una petición sin límite es
/// una petición que no se puede parar hasta que acabe: con este corte, parar
/// tarda como mucho lo que tarden estas imágenes.
///
/// Sesenta y cuatro salen de lo que hay: veinte fotogramas por vídeo, así que
/// cabe algo más de tres vídeos por petición, y con imágenes sueltas son
/// sesenta y cuatro de golpe.
const recognitionImagesPerCall = 64;

/// Cuántos contenidos recorren el árbol juntos, como mucho.
///
/// El recorrido en lote poda por contenido, pero el lote entero baja de nivel a
/// la vez: lo que se puede contar es cuántos han terminado, no por dónde va el
/// que se está mirando. De ahí el tope, y de ahí que el tamaño de verdad lo
/// decida [recognitionProgressSteps].
const recognitionMediaPerBatch = 25;

/// En cuántos tramos se quiere que avance la barra, como mínimo.
///
/// Es lo que ata el tamaño del lote a lo que el usuario ve: reconocer cuatro
/// contenidos los mira de uno en uno y la barra los cuenta uno a uno —que es
/// donde se nota—, y reconocer la biblioteca entera los agrupa, porque ahí una
/// barra de doce tramos se entiende igual de bien y el motor deja de ir y volver
/// entre unos pesos y otros.
const recognitionProgressSteps = 12;

/// Lo grueso del marco con el que se señala un contenido del último aviso.
///
/// Un marco y no un tinte por encima: el tinte cambiaría los colores del propio
/// contenido, que es justo lo que el usuario ha venido a mirar.
const mediaHighlightBorderWidth = 3.0;

/// Lo que miden las marcas del scroll que señalan lo del último aviso.
///
/// Estrechas y cortas a propósito: son una pista de hacia dónde desplazarse, no
/// un elemento con el que se interactúe. Anchas competirían con la propia barra.
const highlightMarkWidth = 4.0;
const highlightMarkHeight = 10.0;

/// A partir de cuántos contenidos se avisa de que van a salir de la biblioteca.
///
/// Con uno o dos el efecto se ve y se deshace en un momento; con veinte, quien
/// lo lanzó vuelve a la rejilla y se encuentra media biblioteca vacía sin saber
/// por qué. El aviso es para eso, no para pedir permiso en cada pulsación.
const recognitionReturnWarningCount = 5;
