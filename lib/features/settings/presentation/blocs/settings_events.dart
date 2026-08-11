import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
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

/// Migración a petición: ordena los ficheros que ya están en la biblioteca.
class MigrateLibraryRequestedEvent extends SettingsEvents {
  const MigrateLibraryRequestedEvent();
}
