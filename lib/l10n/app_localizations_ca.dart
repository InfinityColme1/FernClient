// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get sidebarCollapse => 'Plegar el menú';

  @override
  String get sidebarExpand => 'Desplegar el menú';

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
  String get navBrowser => 'Navegador';

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
  String get actionStopImport => 'Atura la importació';

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
  String get sourceBrowser => 'Navegador';

  @override
  String get sourceBrowserNote => 'Ves al navegador';

  @override
  String get sourceBrowserHint =>
      'Aquest contingut no es demana des d\'aquí: es tria pàgina a pàgina a la pantalla del navegador.';

  @override
  String get sourceNotConfigured => 'Sense configurar';

  @override
  String sourceLogIn(String source) {
    return 'Inicia la sessió a $source';
  }

  @override
  String sourceLogInHint(String source) {
    return 'Obre $source al navegador del Fern. Quan hi hagis entrat, prem allà el botó de la clau per desar la sessió i torna aquí.';
  }

  @override
  String get selectItem => 'Selecciona';

  @override
  String get deselectItem => 'Treu la selecció';

  @override
  String get viewerBack => 'Torna';

  @override
  String get viewerShare => 'Copia al porta-retalls';

  @override
  String get viewerFullscreen => 'Pantalla completa';

  @override
  String get viewerExitFullscreen => 'Surt de la pantalla completa';

  @override
  String get viewerSkipBack => 'Retrocedir cinc segons';

  @override
  String get viewerSkipForward => 'Avançar cinc segons';

  @override
  String get viewerLoop => 'Reproduir en bucle';

  @override
  String get viewerPlaybackSectionTitle => 'Reproducció de vídeo';

  @override
  String get viewerPlaybackSectionNote =>
      'Què li fa el visor a un vídeo mentre se’n recorre la línia de temps.';

  @override
  String get viewerPauseWhenSeeking => 'Aturar en agafar la barra';

  @override
  String get viewerPauseWhenSeekingDescription =>
      'El vídeo s’atura tan bon punt s’agafa la barra i es queda on es deixi. Apagat, continua reproduint-se des d’on es deixi. Marcar regions atura sempre, digui el que digui això: una regió es marca sobre un fotograma quiet.';

  @override
  String get fernieUndo => 'Desfer l’última regió marcada';

  @override
  String get viewerFavorite => 'Marca com a preferit';

  @override
  String get viewerUnfavorite => 'Treu dels preferits';

  @override
  String get viewerCopied => 'Copiat al porta-retalls';

  @override
  String get viewerCopyFailed => 'No s\'ha pogut copiar el contingut';

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
  String get creatorNameTaken => 'Ja hi ha un creador amb aquest nom';

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
  String get settingsViewer => 'Visor';

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
  String get viewerSaveSectionTitle => 'En desar contingut importat';

  @override
  String get viewerSaveSectionNote =>
      'Què fa el visor quan dones per definitiu un contingut importat. Sigui com sigui deixa de ser a la graella d\'importació, així que el visor no es pot quedar on era.';

  @override
  String get viewerSaveNext => 'Anar al contingut següent';

  @override
  String get viewerSaveNextDescription =>
      'El visor passa al contingut següent, igual que si haguessis premut la fletxa. Si no queda res per revisar, es tanca.';

  @override
  String get viewerSaveClose => 'Tancar la visualització';

  @override
  String get viewerSaveCloseDescription =>
      'El visor es tanca i tornes a la graella d\'importació, ja sense aquest contingut.';

  @override
  String get themeSectionTitle => 'Tema';

  @override
  String get themeSectionNote =>
      'Els colors amb què es pinta tota l\'aplicació.';

  @override
  String get themeSystem => 'Seguir el sistema';

  @override
  String get themeSystemDescription =>
      'Clar o fosc, el que estigui fent servir el teu escriptori.';

  @override
  String get themeLight => 'Clar';

  @override
  String get themeLightDescription => 'Els colors de sempre de Fern.';

  @override
  String get themeDark => 'Fosc';

  @override
  String get themeDarkDescription =>
      'La mateixa aplicació, per a un escriptori fosc.';

  @override
  String get themeCustom => 'A mida';

  @override
  String get themeCustomDescription =>
      'Els teus colors, els que triïs aquí sota.';

  @override
  String get customColorsTitle => 'Els teus colors';

  @override
  String get customColorsNote =>
      'Només es poden tocar amb el tema a mida. El que no canviïs es pren del tema clar o del fosc, el que vagi bé al fons que hagis triat.';

  @override
  String get customColorPrimary => 'Primari';

  @override
  String get customColorSecondary => 'Secundari';

  @override
  String get customColorTerciary => 'Accent';

  @override
  String get customColorError => 'Error';

  @override
  String get customColorBackground => 'Fons';

  @override
  String get customColorSurface => 'Superfície';

  @override
  String get customColorForeground => 'Text';

  @override
  String get customColorPick => 'Triar color';

  @override
  String get customColorReset => 'Tornar al color de fàbrica';

  @override
  String get colorPickerTitle => 'Tria un color';

  @override
  String get colorPickerHex => 'Codi hexadecimal';

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
  String get settingsBrowser => 'Navegador';

  @override
  String get browserHome => 'Pàgina d\'inici';

  @override
  String get browserHomeTitle => 'Pàgina d\'inici';

  @override
  String get browserHomeDescription =>
      'Per on comença el navegador del Fern en prémer el botó d\'inici. No decideix per on s\'obre: en tornar a la pantalla, el navegador es queda a l\'última pàgina que vas visitar.';

  @override
  String get browserHomeLabel => 'Adreça';

  @override
  String credentialsRejectedTitle(String source) {
    return '$source no ha acceptat les teves credencials';
  }

  @override
  String credentialsRejectedDescription(String source) {
    return 'No s\'ha pogut importar res: $source ha rebutjat el compte o la clau que se li donaven. Revisa\'ls a Configuració, a Fonts remotes.';
  }

  @override
  String get actionOpenRemoteSettings => 'Obre la configuració';

  @override
  String sessionExpiredTitle(String source) {
    return 'La sessió de $source ja no val';
  }

  @override
  String sessionExpiredDescription(String source) {
    return 'No s\'ha pogut importar res: $source ha rebutjat la sessió desada. Torna a iniciar la sessió al navegador i prem allà el botó de la clau per desar-ne una de nova.';
  }

  @override
  String browserImportedInto(int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts a punt per revisar a $source',
      one: '1 contingut a punt per revisar a $source',
    );
    return '$_temp0';
  }

  @override
  String browserImportKnown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ja eren a la biblioteca',
      one: '1 ja era a la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String browserImportFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no s\'han pogut descarregar',
      one: '1 no s\'ha pogut descarregar',
    );
    return '$_temp0';
  }

  @override
  String get browserImportNothing => 'No s\'ha portat res.';

  @override
  String get danbooruTitle => 'Danbooru';

  @override
  String get danbooruDescription =>
      'El Fern es descarrega les publicacions que tinguis als preferits de Danbooru. La seva API és pública: només calen el nom del teu compte i una clau d\'API.';

  @override
  String get danbooruUsername => 'Nom del compte';

  @override
  String get danbooruUsernameHint => 'El teu nom d\'usuari a Danbooru';

  @override
  String get danbooruApiKey => 'Clau d\'API';

  @override
  String get danbooruApiKeyHint => 'Una clau del teu perfil de Danbooru';

  @override
  String get danbooruApiKeyNote =>
      'A Danbooru, obre el teu perfil, ves a API Key i crea\'n una. No és la teva contrasenya: pots revocar-la quan vulguis sense tocar res més. Es queda en aquest equip i només s\'usa per parlar amb Danbooru.';

  @override
  String get gelbooruTitle => 'Gelbooru';

  @override
  String get gelbooruDescription =>
      'El Fern es descarrega les publicacions que tinguis als preferits de Gelbooru. La seva API de preferits és més lenta que les altres: dona referències en lloc de publicacions, així que cal demanar cadascuna a part.';

  @override
  String get gelbooruUserId => 'Identificador del compte';

  @override
  String get gelbooruUserIdHint => 'El número del teu compte de Gelbooru';

  @override
  String get gelbooruApiKey => 'Clau d\'API';

  @override
  String get gelbooruApiKeyHint => 'La clau d\'aquest compte';

  @override
  String get gelbooruApiKeyNote =>
      'A Gelbooru, entra a My Account, després a Options, i busca API Access Credentials: allà hi ha l\'identificador i la clau. Es queden en aquest equip i només s\'usen per parlar amb Gelbooru.';

  @override
  String get pinterestTitle => 'Pinterest';

  @override
  String get pinterestDescription =>
      'El Fern es descarrega el que tinguis desat a Pinterest. Per al que sigui en taulers públics no cal res més que el nom del teu compte.';

  @override
  String get pinterestUsername => 'Nom del compte';

  @override
  String get pinterestUsernameHint => 'El teu nom d\'usuari a Pinterest';

  @override
  String get pinterestSecretBoardsNote =>
      'Per portar-te també el que deses en taulers secrets, inicia la sessió a Pinterest des del navegador del Fern i prem allà el botó de la clau: la sessió es desa al costat del nom.';

  @override
  String get pawchiveTitle => 'Pawchive';

  @override
  String get pawchiveDescription =>
      'El Fern es descarrega les publicacions que tinguis als preferits de Pawchive. Aquí no hi ha res a omplir: inicia la sessió des del navegador del Fern i prem allà el botó de la clau, i la sessió es desa sola.';

  @override
  String linkChoiceTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aquesta publicació porta $count enllaços',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceUntitledPost => 'Publicació sense títol';

  @override
  String get linkChoiceApplyToAll => 'Aplica-ho a la resta de la importació';

  @override
  String get linkChoiceApplyToAllDescription =>
      'S\'usa la mateixa resposta per a totes les publicacions que quedin, i no es torna a preguntar.';

  @override
  String get linkChoiceIgnore => 'Ignora la publicació';

  @override
  String linkChoiceSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descarrega $count',
      zero: 'Descarrega la selecció',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceAll => 'Descarrega-ho tot';

  @override
  String get linkChoiceOpen => 'Mostra al navegador';

  @override
  String repositoryLinkTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aquesta publicació porta a $count repositoris de contingut',
      one: 'Aquesta publicació porta a un repositori de contingut',
    );
    return '$_temp0';
  }

  @override
  String get repositoryLinkDescription =>
      'El Fern no pot portar-s\'ho tot sol: són pàgines amb la seva pròpia espera i comprovacions. Les pots obrir al navegador del Fern i endur-te\'n el que vulguis. Mentrestant la importació continua.';

  @override
  String get repositoryLinkOpen => 'Mostra al navegador';

  @override
  String get pawchiveByCreators => 'Importa per creadors preferits';

  @override
  String get pawchiveByCreatorsDescription =>
      'En comptes de les publicacions que hagis marcat, el Fern recorre tot el que publiquin els creadors que tinguis als preferits. Porta força més, i cada creador se segueix pel seu compte.';

  @override
  String get remoteImportHeavyWarning =>
      'Això pot trigar força: sense límit, el Fern recorre el compte sencer i s\'ho porta tot, inclosos els fitxers que hi hagi dins de les publicacions. El pots aturar quan vulguis des de la pantalla d\'importació, i el que ja hagi arribat es queda.';

  @override
  String emptySource(String source) {
    return 'No hi havia res a portar de $source.';
  }

  @override
  String get emptySourcePawchiveCreators =>
      'No tens publicacions marcades a Pawchive, però sí creadors preferits. Activa «Importa per creadors preferits» a Configuració, dins de Fonts remotes, i el Fern recorrerà tot el que publiquin.';

  @override
  String get browserAddressHint => 'Adreça d\'un lloc';

  @override
  String get browserBack => 'Enrere';

  @override
  String get browserForward => 'Endavant';

  @override
  String get browserReload => 'Torna a carregar';

  @override
  String get browserSaveSessionHint =>
      'Desa la sessió d\'aquest lloc per poder-ne importar';

  @override
  String get browserFindMediaHint => 'Cerca contingut en aquesta pàgina';

  @override
  String browserImportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importa $count',
      one: 'Importa 1',
    );
    return '$_temp0';
  }

  @override
  String get browserSelectAll => 'Marca o desmarca-ho tot';

  @override
  String get browserClose => 'Tanca';

  @override
  String get browserNoSession =>
      'D\'aquest lloc no se\'n pot importar, així que aquí no hi ha cap sessió per desar.';

  @override
  String browserSessionSaved(String source) {
    return 'Sessió de $source desada.';
  }

  @override
  String browserSessionMissing(String source) {
    return 'Aquí encara no hi ha cap sessió de $source: inicia-la primer.';
  }

  @override
  String get browserNothingFound =>
      'No s\'ha trobat contingut en aquesta pàgina.';

  @override
  String browserFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts trobats',
      one: '1 contingut trobat',
    );
    return '$_temp0';
  }

  @override
  String browserImporting(int done, int total) {
    return 'Descarregant $done de $total…';
  }

  @override
  String importFailed(String error) {
    return 'La importació no s\'ha pogut completar: $error';
  }

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

  @override
  String get startupFailedTitle => 'Fern no ha pogut arrencar';

  @override
  String get startupFailedDatabase =>
      'No s\'ha pogut posar la base de dades al dia amb el que necessita aquesta versió.';

  @override
  String get startupFailedHint =>
      'No s\'ha perdut res: el teu contingut segueix on era. Tanca el Fern i torna\'l a obrir, i si continua passant, el detall de sota diu què ha fallat.';

  @override
  String get settingsRecognition => 'Reconeixement';

  @override
  String get recognitionFolderTitle => 'Dades de reconeixement';

  @override
  String get recognitionFolderDescription =>
      'On el Fern desa tot el que necessita per reconèixer el teu contingut: l\'entorn amb què entrena, els models ja entrenats i els conjunts de dades que prepara per entrenar-los. Pot ocupar uns quants gigues, així que potser el prefereixes en un altre disc.';

  @override
  String get recognitionFolder => 'Carpeta de reconeixement';

  @override
  String recognitionFolderMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers moguts a la carpeta nova',
      one: '1 fitxer mogut a la carpeta nova',
      zero: 'La carpeta ja hi era',
    );
    return '$_temp0';
  }

  @override
  String get recognitionFolderMoveFailed =>
      'No s\'han pogut moure les dades de reconeixement';

  @override
  String get jobsTooltip => 'Tasques en marxa';

  @override
  String get jobsTitle => 'Tasques en segon pla';

  @override
  String get jobsEmpty => 'Ara mateix no hi ha res en marxa';

  @override
  String get jobCancelTooltip => 'Cancel·la aquesta tasca';

  @override
  String jobProgress(int done, int total) {
    return '$done de $total';
  }

  @override
  String get jobQueued => 'Esperant';

  @override
  String get jobFailed => 'Ha fallat';

  @override
  String get jobTraining => 'Entrenant el model';

  @override
  String get jobRecognition => 'Reconeixent contingut';

  @override
  String get jobDuplicateScan => 'Cercant contingut repetit';

  @override
  String get jobHashing => 'Llegint contingut';

  @override
  String get settingsNotifications => 'Avisos';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get notificationsDescription =>
      'Entrenar un model, reconèixer un lot o cercar contingut repetit pot trigar una bona estona. El Fern t\'avisa quan acaba perquè no hagis d\'estar mirant.';

  @override
  String get notificationsEnabled => 'Avisa\'m';

  @override
  String get notificationsEnabledDescription =>
      'Apagat no es compta res ni sona res. El que ja hi hagués pendent continua anotat i es torna a veure en encendre-ho.';

  @override
  String get notificationsMuted => 'Silenci';

  @override
  String get notificationsMutedDescription =>
      'Els comptadors es queden, els sons no.';

  @override
  String get notificationsSoundTitle => 'So';

  @override
  String get notificationsVolume => 'Volum';

  @override
  String get notificationsMaxSeconds => 'Sonar com a màxim';

  @override
  String notificationsSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segons',
      one: '1 segon',
    );
    return '$_temp0';
  }

  @override
  String get notificationsMaxSecondsDescription =>
      'Un avís és un toc curt. Si l\'àudio que tries dura més, el Fern el talla aquí en lloc de reproduir-lo sencer. El teu fitxer no es toca.';

  @override
  String get notificationsEventsTitle => 'De què avisar';

  @override
  String get notificationsEventsDescription =>
      'De cadascun, si posa comptador al menú lateral i si sona.';

  @override
  String get notificationsBadge => 'Comptador';

  @override
  String get notificationsSound => 'So';

  @override
  String get notificationsDefaultSound => 'So del Fern';

  @override
  String get notificationsPreview => 'Escoltar';

  @override
  String get notificationsChooseSound => 'Triar un àudio';

  @override
  String get notificationsResetSound => 'Tornar al so del Fern';

  @override
  String get notifyDuplicates => 'Contingut repetit trobat';

  @override
  String get notifyTraining => 'Model acabat d\'entrenar';

  @override
  String get notifyRecognition => 'Reconeixement en lot acabat';

  @override
  String get notifyRemoteImport => 'Importació remota acabada';

  @override
  String get sidecarTitle => 'Motor de reconeixement';

  @override
  String get sidecarDescription =>
      'Per entrenar i reconèixer, el Fern instal·la el seu propi entorn de Python dins la carpeta de reconeixement. No toca el teu sistema i no cal que tinguis Python instal·lat abans: es porta el seu. Ocupa uns 1,2 GB al disc i només es descarrega quan tu ho demanes.';

  @override
  String get sidecarUnsupportedPlatform =>
      'El reconeixement encara no està disponible en aquest sistema.';

  @override
  String get sidecarNotInstalled => 'Sense instal·lar';

  @override
  String get sidecarDownloadingUv => 'Descarregant l\'instal·lador';

  @override
  String get sidecarInstallingPython => 'Instal·lant Python';

  @override
  String get sidecarCreatingVenv => 'Preparant l\'entorn';

  @override
  String get sidecarDetectingHardware => 'Mirant el teu equip';

  @override
  String get sidecarInstallingTorch => 'Descarregant el motor';

  @override
  String get sidecarInstallingUltralytics => 'Instal·lant YOLO';

  @override
  String get sidecarCleaning => 'Netejant';

  @override
  String get sidecarVerifying => 'Comprovant que tot funciona';

  @override
  String get sidecarReady => 'A punt per entrenar i reconèixer';

  @override
  String get sidecarError => 'Alguna cosa ha anat malament';

  @override
  String sidecarDownloaded(String received, String total) {
    return '$received MB de $total MB';
  }

  @override
  String get sidecarInstall => 'Instal·la';

  @override
  String get sidecarReinstall => 'Reinstal·la';

  @override
  String get sidecarEnableGpu => 'Fer servir la targeta gràfica';

  @override
  String get sidecarUninstall => 'Desinstal·la';

  @override
  String get sidecarShowLog => 'Veure detalls';

  @override
  String get sidecarHideLog => 'Amagar detalls';

  @override
  String get sidecarFailureInUse =>
      'Els fitxers del motor s\'estan fent servir ara mateix';

  @override
  String get sidecarFailureInUseHint =>
      'Alguna cosa els té oberts i no es poden reemplaçar. Tanca el Fern del tot, torna\'l a obrir i prem Instal·la. Si continua passant, reinicia l\'equip: això sempre els allibera.';

  @override
  String get sidecarFailureSpace => 'No queda espai al disc';

  @override
  String get sidecarFailureSpaceHint =>
      'El motor necessita uns 1,5 GB lliures, comptant el que ocupa mentre s\'instal·la. Allibera espai, o porta la carpeta de reconeixement a un altre disc des del camp de dalt.';

  @override
  String get sidecarFailureNetwork => 'No s\'ha pogut acabar la descàrrega';

  @override
  String get sidecarFailureNetworkHint =>
      'Revisa la connexió a internet i torna a prémer Instal·la. El que ja s\'havia descarregat es conserva, així que continua per on anava.';

  @override
  String get sidecarFailureBlocked =>
      'El sistema no ha deixat que el Fern executi l\'instal·lador';

  @override
  String get sidecarFailureBlockedHint =>
      'Sol ser l\'antivirus, que frena els programes acabats de descarregar. Permet el Fern al teu antivirus, o tria una carpeta de reconeixement dins la teva carpeta d\'usuari, i torna-ho a provar.';

  @override
  String get sidecarFailureMissing =>
      'Falta alguna cosa que el motor necessita';

  @override
  String get sidecarFailureMissingHint =>
      'La instal·lació s\'ha quedat a mitges. Prem Desinstal·la per netejar-la i després Instal·la un altre cop.';

  @override
  String get sidecarFailureUnknown => 'No s\'ha pogut instal·lar el motor';

  @override
  String get sidecarFailureUnknownHint =>
      'Prem Instal·la per tornar-ho a provar. Si continua fallant, obre els detalls de sota: allà es veu exactament en quin pas ha fallat.';

  @override
  String get sidecarInstallCpu => 'Instal·la per al processador';

  @override
  String get sidecarInstallGpu => 'Instal·la per a la targeta gràfica';

  @override
  String get sidecarEnableCpu => 'Tornar al processador';

  @override
  String sidecarPercent(int percent) {
    return '$percent %';
  }

  @override
  String get sidecarBusyDownloading => 'Descarregant paquets...';

  @override
  String get sidecarBusyUnpacking => 'Descomprimint el que va arribant...';

  @override
  String get sidecarBusyPatience => 'Aquest pas triga uns minuts.';

  @override
  String get sidecarBusySettling => 'Col·locant-ho tot al seu lloc...';

  @override
  String get sidecarBusyKeepUsing =>
      'Pots continuar fent servir el Fern mentrestant.';

  @override
  String get gpuDialogTitle => 'Vols instal·lar la versió de targeta gràfica?';

  @override
  String get gpuDialogBenefit =>
      'Entrenar va molt més ràpid: el que al processador són hores, a la targeta gràfica poden ser minuts.';

  @override
  String get gpuDialogTime =>
      'La descàrrega són uns 2,5 GB, així que amb una connexió normal pot trigar una bona estona.';

  @override
  String get gpuDialogSize =>
      'Ocupa uns 5 GB al disc, en lloc dels 1,2 GB de la versió de processador.';

  @override
  String get gpuDialogReversible =>
      'Pots tornar a la versió de processador quan vulguis, sense reinstal·lar-ho tot.';

  @override
  String get gpuDialogConfirm => 'Instal·la-la';

  @override
  String get navRecognition => 'Reconeixement';

  @override
  String get navFernies => 'Fernies';

  @override
  String get navRepeatedMedia => 'Contingut repetit';

  @override
  String get navModels => 'Models';

  @override
  String get menuNewFernie => 'Nou fernie';

  @override
  String get newFernieTitle => 'Nou fernie';

  @override
  String get fernieNameLabel => 'Nom del fernie';

  @override
  String get ferniesTitle => 'Fernies';

  @override
  String get addFernie => 'Afegir fernie';

  @override
  String get noFerniesYet => 'Encara no hi ha cap fernie';

  @override
  String get fernieNoRegions => 'Aquest fernie encara no té regions';

  @override
  String get fernieNoneHere => 'Encara no hi ha fernies marcats aquí';

  @override
  String get fernieLinkLabel => 'Proposa';

  @override
  String get fernieLinkNone => 'Res';

  @override
  String get fernieLinkTag => 'Una etiqueta';

  @override
  String get fernieLinkCreator => 'Un creador';

  @override
  String get fernieLinkNoneHint => 'Només entrena: tot sol no etiqueta res';

  @override
  String get fernieLinkMissing => 'Allò que tenia enllaçat ja no existeix';

  @override
  String get fernieFewRegions => 'Poques regions per entrenar de manera fiable';

  @override
  String get fernieLowVariety =>
      'Poca varietat: el model aprendrà el fons, no l’objecte';

  @override
  String get fernieRegionPending =>
      'Contingut pendent de revisar: aquesta regió no s’usarà per entrenar fins que es desi';

  @override
  String get fernieRegionTiny =>
      'Regió molt petita: pot no aportar res a l’entrenament';

  @override
  String get actionDeleteFernie => 'Eliminar fernie';

  @override
  String get actionRemoveLink => 'Treure l’enllaç';

  @override
  String get actionDeleteRegions => 'Eliminar regions';

  @override
  String get fernieToolSelect => 'Marcar regions';

  @override
  String get fernieToolEdit => 'Editar regions';

  @override
  String get fernieRegionConfirm => 'Desar els canvis d’aquesta regió';

  @override
  String get fernieRegionCancel => 'Descartar els canvis d’aquesta regió';

  @override
  String get fernieRegionDelete => 'Eliminar aquesta regió';

  @override
  String get fernieRegionDeleteTitle => 'Vols eliminar aquesta regió?';

  @override
  String get fernieRegionDeleteMessage =>
      'La regió surt del seu fernie. Si era l’única d’aquest fernie en aquest contingut, el fernie deixa d’estar-hi marcat.';

  @override
  String get fernieRegionDiscardTitle =>
      'Vols descartar els canvis de la regió?';

  @override
  String get fernieRegionDiscardMessage =>
      'El que has canviat a la regió seleccionada no es desarà.';

  @override
  String get fernieTimelinePlay =>
      'Reproduir per comprovar les regions marcades';

  @override
  String get fernieTimelinePause => 'Aturar';

  @override
  String get fernieFramePrevious => 'Fotograma anterior';

  @override
  String get fernieFrameNext => 'Fotograma següent';

  @override
  String get fernieOnionSkin =>
      'Paper ceba: veure el fotograma marcat anterior';

  @override
  String get fernieDragRegions =>
      'Arrossegar la regió per tots els fotogrames del mig';

  @override
  String get fernieModeTooltip => 'Marcar regions';

  @override
  String get fernieModeAccept => 'Desar les regions';

  @override
  String get fernieModeCancel => 'Descartar les regions';

  @override
  String get fernieModeHint =>
      'Arrossega sobre el contingut per marcar una regió. Mantén l’espai o el botó central per desplaçar.';

  @override
  String get fernieDiscardTitle => 'Vols descartar el que has marcat?';

  @override
  String get fernieDiscardMessage =>
      'Es perdran les regions marcades en aquesta sessió.';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get assignRegionTitle => 'Assignar la regió';

  @override
  String get searchFernieHint => 'Cercar fernie...';

  @override
  String get createFernie => 'Crear fernie';

  @override
  String fernieRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regions',
      one: '1 regió',
      zero: 'Sense regions',
    );
    return '$_temp0';
  }

  @override
  String fernieMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count continguts',
      one: 'en 1 contingut',
      zero: 'en cap contingut',
    );
    return '$_temp0';
  }

  @override
  String fernieRecommendedRegions(int count) {
    return 'Es recomanen com a mínim $count regions';
  }
}
