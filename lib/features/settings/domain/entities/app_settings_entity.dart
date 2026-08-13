import 'package:Fern/features/settings/domain/entities/reddit_settings_entity.dart';
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

  final FileOrganizationCriteria organization;

  /// Credenciales de la fuente remota de Reddit. Vienen vacías mientras el
  /// usuario no las haya rellenado, que es como la aplicación sabe que esa
  /// fuente todavía no se puede usar.
  final RedditSettingsEntity reddit;

  const AppSettingsEntity({
    this.language = AppLanguage.english,
    this.syncLocalFiles = false,
    this.copyFiles = false,
    this.libraryPath,
    required this.avatarsPath,
    this.organization = FileOrganizationCriteria.flat,
    this.reddit = const RedditSettingsEntity(),
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
    FileOrganizationCriteria? organization,
    RedditSettingsEntity? reddit,
  }) {
    return AppSettingsEntity(
      language: language ?? this.language,
      syncLocalFiles: syncLocalFiles ?? this.syncLocalFiles,
      copyFiles: copyFiles ?? this.copyFiles,
      libraryPath: libraryPath ?? this.libraryPath,
      avatarsPath: avatarsPath ?? this.avatarsPath,
      organization: organization ?? this.organization,
      reddit: reddit ?? this.reddit,
    );
  }

  @override
  List<Object?> get props => [
        language,
        syncLocalFiles,
        copyFiles,
        libraryPath,
        avatarsPath,
        organization,
        reddit,
      ];
}
