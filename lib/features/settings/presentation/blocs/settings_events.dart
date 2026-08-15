import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
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

/// Migración a petición: ordena los ficheros que ya están en la biblioteca.
class MigrateLibraryRequestedEvent extends SettingsEvents {
  const MigrateLibraryRequestedEvent();
}
