import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/danbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pinterest_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvents extends Equatable {
  const SettingsEvents();

  @override
  List<Object?> get props => [];
}

/// Relee los ajustes guardados. La pantalla no lo necesita al abrirse (el bloc
/// nace ya con ellos), pero sí después de una migración lanzada desde fuera.
class LoadSettingsEvent extends SettingsEvents {
  const LoadSettingsEvent();
}

class LanguageChangedEvent extends SettingsEvents {
  final AppLanguage language;

  const LanguageChangedEvent(this.language);

  @override
  List<Object?> get props => [language];
}

class SyncLocalFilesToggledEvent extends SettingsEvents {
  final bool enabled;

  const SyncLocalFilesToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class CopyFilesToggledEvent extends SettingsEvents {
  final bool enabled;

  const CopyFilesToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class LibraryDirectoryChangedEvent extends SettingsEvents {
  final String path;

  const LibraryDirectoryChangedEvent(this.path);

  @override
  List<Object?> get props => [path];
}

/// Cambiar la carpeta de avatares arrastra las imágenes que ya hubiera: es
/// parte del propio cambio, no una acción aparte.
class AvatarsDirectoryChangedEvent extends SettingsEvents {
  final String path;

  const AvatarsDirectoryChangedEvent(this.path);

  @override
  List<Object?> get props => [path];
}

/// Cambiar la carpeta de reconocimiento se lleva consigo lo que ya hubiera
/// dentro: la aplicación carga los modelos de ahí, así que dejarlos atrás sería
/// quedarse sin ellos.
class RecognitionDirectoryChangedEvent extends SettingsEvents {
  final String path;

  const RecognitionDirectoryChangedEvent(this.path);

  @override
  List<Object?> get props => [path];
}

/// Cambia cómo avisa la aplicación: el interruptor general, el silencio, el
/// volumen, el corte o cualquiera de las vías de un aviso concreto.
class NotificationSettingsChangedEvent extends SettingsEvents {
  final NotificationSettingsEntity notifications;

  const NotificationSettingsChangedEvent(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class FileOrganizationChangedEvent extends SettingsEvents {
  final FileOrganizationCriteria criteria;

  const FileOrganizationChangedEvent(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

/// Enciende o apaga la etiqueta con el nombre de la plataforma en lo que se
/// importa de ella.
///
/// Vale para todas las fuentes remotas a la vez: es una forma de trabajar, no un
/// ajuste de una plataforma concreta. Sólo afecta a lo que se importe a partir de
/// ahora; lo que ya está en la biblioteca se queda como se guardó.
class AutoTagRemoteSourceToggledEvent extends SettingsEvents {
  final bool enabled;

  const AutoTagRemoteSourceToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Enciende o apaga que lo reconocido vuelva a la pantalla de importación.
class RecognizeOnImportToggledEvent extends SettingsEvents {
  final bool enabled;

  const RecognizeOnImportToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ReturnRecognizedToggledEvent extends SettingsEvents {
  final bool enabled;

  const ReturnRecognizedToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Enciende o apaga que coger la barra de un vídeo lo pare.
///
/// Sólo en el modo de mirar: marcando regiones se para siempre, porque una
/// región se marca sobre un fotograma quieto.
/// Al salir del visor, ¿la rejilla va a buscar lo que se acaba de mirar?
class ReturnToViewedMediaToggledEvent extends SettingsEvents {
  final bool enabled;

  const ReturnToViewedMediaToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class PauseWhenSeekingToggledEvent extends SettingsEvents {
  final bool enabled;

  const PauseWhenSeekingToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Enciende o apaga los avatares en la lista de etiquetas del menú lateral.
///
/// Sólo afecta a esa lista: las etiquetas de las demás pantallas ya se ven con
/// su avatar y no dependen de esto.
class ShowListAvatarsToggledEvent extends SettingsEvents {
  final bool enabled;

  const ShowListAvatarsToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Cambia el tema con el que se pinta la aplicación.
///
/// Se ve al instante y en toda la aplicación: el tema cuelga de la raíz, así que
/// al cambiarlo se repinta hasta la propia pantalla de ajustes desde la que se
/// ha elegido.
class ThemeModeChangedEvent extends SettingsEvents {
  final AppThemeMode mode;

  const ThemeModeChangedEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Cambia uno de los colores del tema a medida.
///
/// Con [color] a `null` ese color vuelve al del tema de fábrica, que es lo que
/// hace el botón de restablecer de su fila.
class CustomThemeColorChangedEvent extends SettingsEvents {
  final CustomThemeColor slot;
  final int? color;

  const CustomThemeColorChangedEvent(this.slot, this.color);

  @override
  List<Object?> get props => [slot, color];
}

/// Cambia lo que hace el visor al dar por definitivo un contenido importado.
class ViewerSaveBehaviorChangedEvent extends SettingsEvents {
  final ViewerSaveBehavior behavior;

  const ViewerSaveBehaviorChangedEvent(this.behavior);

  @override
  List<Object?> get props => [behavior];
}

/// Enciende o apaga la búsqueda automática de contenido repetido.
class AutomaticDuplicateScanToggledEvent extends SettingsEvents {
  final bool enabled;

  const AutomaticDuplicateScanToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Cambia qué se ve con el modo NSFW abierto.
/// Enciende o apaga que marcar una etiqueta arrastre a las que cuelgan de ella.
class NsfwChildTagsToggledEvent extends SettingsEvents {
  final bool marksChildren;

  const NsfwChildTagsToggledEvent(this.marksChildren);

  @override
  List<Object?> get props => [marksChildren];
}

class NsfwUnlockedViewChangedEvent extends SettingsEvents {
  final NsfwUnlockedView view;

  const NsfwUnlockedViewChangedEvent(this.view);

  @override
  List<Object?> get props => [view];
}

/// Cambia qué se ve con el modo NSFW cerrado.
class NsfwLockedViewChangedEvent extends SettingsEvents {
  final NsfwLockedView view;

  const NsfwLockedViewChangedEvent(this.view);

  @override
  List<Object?> get props => [view];
}

/// Enciende o apaga el mirar vídeos y GIF al buscar repetidos.
class DuplicateScanMovingToggledEvent extends SettingsEvents {
  final bool enabled;

  const DuplicateScanMovingToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Cambia cada cuánto se busca contenido repetido por cuenta propia.
class DuplicateScanPeriodChangedEvent extends SettingsEvents {
  final DuplicateScanPeriod period;

  const DuplicateScanPeriodChangedEvent(this.period);

  @override
  List<Object?> get props => [period];
}

/// Mueve el listón a partir del cual dos contenidos dejan de ser el mismo.
class DuplicateThresholdChangedEvent extends SettingsEvents {
  final int threshold;

  const DuplicateThresholdChangedEvent(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

/// Credenciales de Reddit tal y como han quedado tras tocar uno de sus campos.
///
/// Llegan las cuatro juntas porque se guardan juntas: la fuente sólo sirve
/// cuando están todas, así que no tiene sentido tratarlas por separado.
class RedditSettingsChangedEvent extends SettingsEvents {
  final RedditSettingsEntity reddit;

  const RedditSettingsChangedEvent(this.reddit);

  @override
  List<Object?> get props => [reddit];
}

/// Credenciales de Danbooru tal y como han quedado tras tocar uno de sus
/// campos. Llegan las dos juntas porque se guardan juntas: la fuente sólo sirve
/// cuando están las dos.
class DanbooruSettingsChangedEvent extends SettingsEvents {
  final DanbooruSettingsEntity danbooru;

  const DanbooruSettingsChangedEvent(this.danbooru);

  @override
  List<Object?> get props => [danbooru];
}

/// Credenciales de Gelbooru tal y como han quedado tras tocar uno de sus
/// campos.
class GelbooruSettingsChangedEvent extends SettingsEvents {
  final GelbooruSettingsEntity gelbooru;

  const GelbooruSettingsChangedEvent(this.gelbooru);

  @override
  List<Object?> get props => [gelbooru];
}

/// Credenciales de Pinterest tal y como han quedado tras tocar su campo. La
/// sesión no se escribe aquí: ésa la recoge el navegador.
class PinterestSettingsChangedEvent extends SettingsEvents {
  final PinterestSettingsEntity pinterest;

  const PinterestSettingsChangedEvent(this.pinterest);

  @override
  List<Object?> get props => [pinterest];
}

/// Ajustes de Pawchive tal y como han quedado. La sesión no se escribe aquí:
/// ésa la recoge el navegador.
class PawchiveSettingsChangedEvent extends SettingsEvents {
  final PawchiveSettingsEntity pawchive;

  const PawchiveSettingsChangedEvent(this.pawchive);

  @override
  List<Object?> get props => [pawchive];
}

/// Página de inicio del navegador de la aplicación, tal y como ha quedado tras
/// tocar su campo.
/// Cuándo hay que apartar el navegador mientras se importa.
class BrowserAsideChangedEvent extends SettingsEvents {
  final BrowserAsidePolicy policy;

  const BrowserAsideChangedEvent(this.policy);

  @override
  List<Object?> get props => [policy];
}

class BrowserHomeChangedEvent extends SettingsEvents {
  final String url;

  const BrowserHomeChangedEvent(this.url);

  @override
  List<Object?> get props => [url];
}

/// Los ajustes tal y como quedan al recoger del navegador de la aplicación la
/// sesión de una plataforma.
///
/// Llegan enteros y no el dato suelto porque quien los trae no sabe de qué
/// plataforma son: el navegador recoge la cookie que sea y la fuente sabe en
/// qué ajuste va. Es de la pantalla experimental del navegador; sin ella, este
/// evento no lo manda nadie.
class RemoteSessionCapturedEvent extends SettingsEvents {
  final AppSettingsEntity settings;

  const RemoteSessionCapturedEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Migración a petición: ordena los ficheros que ya están en la biblioteca.
class MigrateLibraryRequestedEvent extends SettingsEvents {
  const MigrateLibraryRequestedEvent();
}
