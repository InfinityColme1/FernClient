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

// Import sources
//
// Son identificadores, no textos de pantalla: Pixiv y Twitter se llaman igual
// en todos los idiomas y el equipo local se traduce al pintarlo.
const localComputerSource = "Local computer";
const importSources = [localComputerSource, "Pixiv", "Twitter"];

// Preferences keys
const rootPathPreferenceKey = 'user_media_root_path';
const languagePreferenceKey = 'app_language';
const syncLocalFilesPreferenceKey = 'sync_local_files';
const copyFilesPreferenceKey = 'copy_files';
const libraryPathPreferenceKey = 'library_path';
const avatarsPathPreferenceKey = 'avatars_path';
const fileOrganizationPreferenceKey = 'file_organization';

// Gestión de ficheros
/// Carpeta de la biblioteca donde se guardan los avatares mientras el usuario
/// no elija otra, colgando del directorio de datos de la aplicación.
const avatarsFolderName = 'avatars';

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
