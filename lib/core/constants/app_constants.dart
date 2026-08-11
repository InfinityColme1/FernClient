import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

const appName = "Fern";
const appLogo = 'assets/images/Fern_logo.png';

// Routes
const mediaRoute = '/media';
const importRoute = '/import';
const favoritesRoute = '/favorites';
const deletedRoute = '/deleted';

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

// Animations
const hoverAnimationDuration = Duration(milliseconds: 150);
const drawerAnimationDuration = Duration(milliseconds: 300);
const viewerTransitionDuration = Duration(milliseconds: 250);
const infoPanelAnimationDuration = Duration(milliseconds: 300);

// Sidebar
const sidebarSelectedOpacity = 0.3;

/// Velo oscuro que se pone sobre el botón del menú al pasar el ratón.
const sidebarHoverOverlayOpacity = 0.08;

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

// Media grid
const mediaHoverScale = 1.04;
const mediaShadeHeightFactor = 0.35;
const mediaShadeOpacity = 0.55;
const mediaBadgeOpacity = 0.55;
const mediaSelectionShadowOpacity = 0.5;
const mediaFallbackAspectRatio = 1.0;
const mediaVideoPreviewLength = Duration(seconds: 10);
const mediaEmptyDurationLabel = '--:--';

// Video preview extraction
const videoThumbnailFolder = 'fern_video_thumbnails';
const videoThumbnailSeek = Duration(seconds: 1);
const videoProbeTimeout = Duration(seconds: 12);
const videoScreenshotAttempts = 10;
const videoScreenshotRetryDelay = Duration(milliseconds: 120);
const maxConcurrentVideoJobs = 2;
