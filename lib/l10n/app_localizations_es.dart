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
  String get navTagManager => 'Gestor de etiquetas';

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
      other:
          'El contenido marcado se borra definitivamente al cabo de $days días',
      one: 'El contenido marcado se borra definitivamente al cabo de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip =>
      'Borrar definitivamente de la base de datos';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRestore => 'Restablecer';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionUnassignTag => 'Quitar etiqueta';

  @override
  String get actionRemoveParentTag => 'Quitar padre';

  @override
  String get actionDeleteTag => 'Eliminar etiqueta';

  @override
  String get sourceLocalComputer => 'Equipo local';

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
  String get settingsFiles => 'Archivos';

  @override
  String get languageSectionTitle => 'Idioma de la aplicación';

  @override
  String get languageSectionNote =>
      'Toda la aplicación cambia de idioma en cuanto eliges uno.';

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
}
