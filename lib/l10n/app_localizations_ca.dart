// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get navGallery => 'Galeria';

  @override
  String get navTags => 'Etiquetes';

  @override
  String get navMedia => 'Contingut';

  @override
  String get navImport => 'Importa';

  @override
  String get navFavorites => 'Preferits';

  @override
  String get navDeleted => 'Eliminats';

  @override
  String get navCreatorManager => 'Gestor de creadors';

  @override
  String get navTagManager => 'Gestor d\'etiquetes';

  @override
  String get searchHint => 'Cerca';

  @override
  String get menuNewCreator => 'Nou creador';

  @override
  String get menuNewTag => 'Nova etiqueta';

  @override
  String get menuNewCollection => 'Nova col·lecció';

  @override
  String get collectionsWip => 'Les col·leccions encara estan en construcció';

  @override
  String get mobileLayoutWip => 'La versió mòbil arribarà aviat';

  @override
  String mediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers',
      one: '1 fitxer',
      zero: 'Sense contingut',
    );
    return '$_temp0';
  }

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preferits',
      one: '1 preferit',
      zero: 'Encara no hi ha preferits',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get filtersResultsFrom => 'Mostra resultats de';

  @override
  String get filterMedia => 'Contingut';

  @override
  String get filterTags => 'Etiquetes';

  @override
  String get filterCreators => 'Creadors';

  @override
  String get emptyLibrary => 'Aquí hi ha ben poca cosa';

  @override
  String mediaFetched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers trobats',
      one: '1 fitxer trobat',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count seleccionats';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers marcats per esborrar',
      one: '1 fitxer marcat per esborrar',
      zero: 'Res marcat per esborrar',
    );
    return '$_temp0';
  }

  @override
  String deletedRetentionNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'S\'esborra definitivament al cap de $days dies',
      one: 'S\'esborra definitivament al cap d\'1 dia',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip =>
      'Esborra definitivament de la base de dades';

  @override
  String remoteImportWarning(String source) {
    return 'S\'importarà contingut de $source';
  }

  @override
  String get remoteImportAmountAll =>
      'Es descarregarà tot el que tinguis desat al teu compte.';

  @override
  String get remoteImportAmountSinceLast =>
      'Es descarregarà el que tinguis desat des de la darrera importació.';

  @override
  String remoteImportAmountLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Es descarregaran $count continguts com a màxim.',
      one: 'Es descarregarà 1 contingut com a màxim.',
    );
    return '$_temp0';
  }

  @override
  String get favoriteSelectedTooltip => 'Marca la selecció com a preferida';

  @override
  String get deleteSelectedTooltip =>
      'Envia la selecció a la pantalla d\'eliminats';

  @override
  String deleteTrashWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'esborraran definitivament $count arxius',
      one: 'S\'esborrarà definitivament 1 arxiu',
    );
    return '$_temp0';
  }

  @override
  String deleteDiscardWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Es descartaran $count arxius',
      one: 'Es descartarà 1 arxiu',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesFromDisk => 'Esborra també els fitxers del disc';

  @override
  String get deleteFilesFromDiskDescription =>
      'Si la treus, el contingut surt de la base de dades però els seus fitxers es queden on són, de manera que un escaneig posterior els pot tornar a recollir.';

  @override
  String get actionImport => 'Importa';

  @override
  String get actionRefresh => 'Actualitza';

  @override
  String get actionSelectFolder => 'Tria una carpeta';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionConfirm => 'Confirma';

  @override
  String get actionRestore => 'Restableix';

  @override
  String get actionSave => 'Desa';

  @override
  String get showPassword => 'Mostra';

  @override
  String get hidePassword => 'Amaga';

  @override
  String get actionUnassignTag => 'Treu l\'etiqueta';

  @override
  String get actionRemoveParentTag => 'Treu el pare';

  @override
  String get actionDeleteTag => 'Elimina l\'etiqueta';

  @override
  String get actionUnassignCreator => 'Treu el creador';

  @override
  String get actionDeleteCreator => 'Elimina el creador';

  @override
  String get sourceLocalComputer => 'Equip local';

  @override
  String get sourceAll => 'Totes';

  @override
  String get sourceNotConfigured => 'Sense configurar';

  @override
  String get selectItem => 'Selecciona';

  @override
  String get deselectItem => 'Treu la selecció';

  @override
  String get mediaInfoTitle => 'Informació';

  @override
  String get descriptionHint => 'Afegeix una descripció';

  @override
  String get createdBy => 'Creat per:';

  @override
  String get tagsTitle => 'Etiquetes';

  @override
  String get addTag => 'Afegeix una etiqueta';

  @override
  String get noTagsYet => 'Encara no hi ha etiquetes';

  @override
  String get creatorsTitle => 'Creadors';

  @override
  String get noCreatorsYet => 'Encara no hi ha creadors';

  @override
  String get noSocialProfiles => 'Sense perfils socials';

  @override
  String get openProfileTooltip => 'Obre el perfil al navegador';

  @override
  String get editProfileTooltip => 'Edita l\'enllaç';

  @override
  String get doneEditingProfileTooltip => 'Acaba d\'editar';

  @override
  String get removeProfileTooltip => 'Treu l\'enllaç';

  @override
  String get tagNameSearchLabel => 'Nom de l\'etiqueta';

  @override
  String get tagSearchHint => 'Etiqueta';

  @override
  String get createTag => 'Crea una etiqueta';

  @override
  String get searchCreatorLabel => 'Cerca un creador';

  @override
  String get creatorSearchHint => 'Nom';

  @override
  String get createCreator => 'Crea un creador';

  @override
  String get newTagTitle => 'Nova etiqueta';

  @override
  String get tagNameLabel => 'Nom de l\'etiqueta';

  @override
  String get parentTagLabel => 'Etiqueta pare (opcional)';

  @override
  String get newCreatorTitle => 'Nou creador';

  @override
  String get creatorNameLabel => 'Nom del creador';

  @override
  String get socialProfilesLabel => 'Perfils socials';

  @override
  String get enterNameHint => 'Escriu un nom';

  @override
  String get searchEllipsisHint => 'Cerca...';

  @override
  String get profileLinkHint => 'Enllaç al perfil';

  @override
  String get addProfile => 'Afegeix un perfil';

  @override
  String get resultTypeMedia => 'contingut';

  @override
  String get resultTypeTag => 'etiqueta';

  @override
  String get resultTypeCreator => 'creador';

  @override
  String get noFolderSelected => 'Cap carpeta seleccionada';

  @override
  String get chooseFolder => 'Tria una carpeta';

  @override
  String get settingsTitle => 'Configuració';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAppearance => 'Aparença';

  @override
  String get settingsFiles => 'Fitxers';

  @override
  String get settingsRemoteSources => 'Fonts remotes';

  @override
  String get languageSectionTitle => 'Idioma de l\'aplicació';

  @override
  String get languageSectionNote =>
      'Tota l\'aplicació canvia d\'idioma tan bon punt en tries un.';

  @override
  String get sidebarSectionTitle => 'Menú lateral';

  @override
  String get sidebarSectionNote =>
      'Com es pinta la llista d\'etiquetes del menú lateral.';

  @override
  String get showListAvatars => 'Mostra avatars a la llista';

  @override
  String get showListAvatarsDescription =>
      'Cada etiqueta es pinta amb la seva pròpia imatge en comptes de la icona comuna, així es distingeixen amb el menú plegat. Les etiquetes sense imatge es queden amb la icona.';

  @override
  String get filesLocalTitle => 'Fitxers locals';

  @override
  String get syncLocalFiles => 'Sincronitza els fitxers locals';

  @override
  String get syncLocalFilesDescription =>
      'El Fern mou a una carpeta pròpia el contingut amb què treballa, tant el que ja està importat com el que arribi després.';

  @override
  String get libraryFolder => 'Carpeta de la biblioteca';

  @override
  String get copyFiles => 'Copia els fitxers';

  @override
  String get copyFilesDescription =>
      'Conserva el fitxer original on era i treballa amb una còpia dins la carpeta de la biblioteca.';

  @override
  String get avatarsTitle => 'Avatars';

  @override
  String get avatarsDescription =>
      'Les imatges dels avatars sempre es copien a una carpeta pròpia, tant si la sincronització de fitxers locals està activada com si no. En canviar de carpeta, els avatars que ja existeixin s\'hi enduen.';

  @override
  String get avatarsFolder => 'Carpeta d\'avatars';

  @override
  String get organizationTitle => 'Ordenació';

  @override
  String get organizationDescription =>
      'Com es reparteixen els fitxers dins la carpeta de la biblioteca. No afecta les imatges dels avatars.';

  @override
  String get organizationFlat => 'Tots els fitxers junts';

  @override
  String get organizationFlatDescription =>
      'Cada fitxer queda directament a la carpeta de la biblioteca';

  @override
  String get organizationByTag => 'Subcarpetes per etiqueta';

  @override
  String get organizationByTagDescription =>
      'Una carpeta per etiqueta, presa de la primera etiqueta del contingut';

  @override
  String get organizationBySource => 'Subcarpetes per font';

  @override
  String get organizationBySourceDescription =>
      'Una carpeta per origen: local, Pixiv, Twitter...';

  @override
  String get organizationByCreator => 'Subcarpetes per creador';

  @override
  String get organizationByCreatorDescription => 'Una carpeta per creador';

  @override
  String get migrationTitle => 'Migració';

  @override
  String get migrationDescription =>
      'Ordena amb els criteris de dalt tots els fitxers que ja són a la biblioteca.';

  @override
  String get migrateFiles => 'Migra els fitxers';

  @override
  String avatarsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avatars moguts a la carpeta nova',
      one: '1 avatar mogut a la carpeta nova',
      zero: 'Els avatars ja eren en aquesta carpeta',
    );
    return '$_temp0';
  }

  @override
  String get avatarsMoveFailed => 'No s\'han pogut moure els avatars';

  @override
  String filesOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers moguts',
      one: '1 fitxer mogut',
      zero: 'Ja era tot al seu lloc',
    );
    return '$_temp0';
  }

  @override
  String get filesOrganizeFailed => 'No s\'han pogut ordenar els fitxers';

  @override
  String get redditTitle => 'Reddit';

  @override
  String get redditDescription =>
      'Fern es descarrega el que tinguis desat al teu compte de Reddit. Registra una aplicació de tipus script a reddit.com/prefs/apps per aconseguir les dues claus.';

  @override
  String get redditClientId => 'ID de client';

  @override
  String get redditClientIdHint =>
      'La clau que apareix sota el nom de la teva aplicació';

  @override
  String get redditClientSecret => 'Secret de client';

  @override
  String get redditClientSecretHint => 'El secret de la teva aplicació';

  @override
  String get redditUsername => 'Usuari';

  @override
  String get redditUsernameHint => 'El teu compte de Reddit, sense /u/';

  @override
  String get redditPassword => 'Contrasenya';

  @override
  String get redditPasswordHint => 'La contrasenya d\'aquest compte';

  @override
  String get redditCredentialsNote =>
      'Les credencials es queden en aquest equip i només s\'usen per parlar amb Reddit.';

  @override
  String get importLimitAll => 'Tots';

  @override
  String get importLimitSinceLast => 'Nous';

  @override
  String get importLimitSinceLastTooltip =>
      'Només el que s\'ha desat des de la darrera importació';

  @override
  String get importLimitTooltip => 'Màxim d\'elements que porta una exploració';

  @override
  String get lastImportNever => 'Mai importat';

  @override
  String get sourceNotConfiguredHint =>
      'Configura aquesta font als ajustaments abans d\'importar-ne';

  @override
  String get lastImportHint =>
      'Quan es va mirar per darrera vegada si hi havia contingut nou';

  @override
  String lastImportMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fa $count min',
      one: 'Fa 1 min',
      zero: 'Ara mateix',
    );
    return '$_temp0';
  }

  @override
  String lastImportHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fa $count h',
      one: 'Fa 1 h',
    );
    return '$_temp0';
  }

  @override
  String lastImportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fa $count dies',
      one: 'Fa 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get assignUrlsTitle => 'Adreces vinculades';

  @override
  String assignUrlsTo(String name) {
    return 'Adreces vinculades a $name';
  }

  @override
  String get assignUrlsDescription =>
      'El que s\'importi d\'aquestes adreces s\'endú aquesta etiqueta tot sol, sense preguntar res a la plataforma.';

  @override
  String get assignUrlsTooltip => 'Vincular adreces amb aquesta etiqueta';

  @override
  String get assignUrlsCreatorDescription =>
      'El que s\'importi d\'aquestes adreces s\'endú aquest creador tot sol, sense preguntar res a la plataforma.';

  @override
  String get assignUrlsCreatorTooltip => 'Vincular adreces amb aquest creador';

  @override
  String get sourceUrlsLabel => 'Adreces';

  @override
  String get sourceUrlHint => 'reddit.com/r/exemple';

  @override
  String get addSourceUrl => 'Afegir adreça';

  @override
  String get filtersSource => 'Mostrar contingut de';

  @override
  String get sourceLocal => 'Aquest equip';

  @override
  String get autoTagRemoteSource => 'Autoetiquetar font remota';

  @override
  String get autoTagRemoteSourceDescription =>
      'Fern crea una etiqueta per plataforma (Reddit, i les que vinguin) i la posa al que n\'importa. Apagat, la font es continua desant i s\'hi filtra des del botó de filtres.';
}
