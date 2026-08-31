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
  String selectedOfCount(int selected, int total) {
    return '$selected de $total seleccionats';
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
  String get actionClose => 'Tancar';

  @override
  String get actionClearSearch => 'Buidar la cerca';

  @override
  String get actionDecrease => 'Baixar';

  @override
  String get actionIncrease => 'Pujar';

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
  String get viewerReturnToMedia => 'Tornar on estaves mirant';

  @override
  String get viewerReturnToMediaDescription =>
      'En sortir del visor, la graella es col·loca on és el contingut que acabes de veure en comptes de quedar-se on la vas deixar.';

  @override
  String get viewerPauseWhenSeeking => 'Aturar en agafar la barra';

  @override
  String get viewerPauseWhenSeekingDescription =>
      'El vídeo s’atura tan bon punt s’agafa la barra i es queda on es deixi. Apagat, continua reproduint-se des d’on es deixi. Marcar regions atura sempre, digui el que digui això: una regió es marca sobre un fotograma quiet.';

  @override
  String get fernieUndo => 'Desfer l’última regió marcada';

  @override
  String get createTooltip => 'Crear';

  @override
  String get menuNewModel => 'Nou model';

  @override
  String get newModelTitle => 'Nou model';

  @override
  String get modelNameLabel => 'Nom del model';

  @override
  String get modelFunctionLabel => 'Què respon';

  @override
  String get modelFunctionBoolean => 'Hi és?';

  @override
  String get modelFunctionBooleanDescription =>
      'Diu si cadascun dels seus fernies és al contingut. Amb uns quants, contesta per cadascun per separat.';

  @override
  String get modelFunctionClassification => 'Quin és?';

  @override
  String get modelFunctionClassificationDescription =>
      'Distingeix entre els seus fernies i diu quin ha trobat, i on. En necessita almenys dos: amb un no hi ha entre què triar.';

  @override
  String get modelsTitle => 'Models';

  @override
  String get modelsEmpty => 'Encara no hi ha models';

  @override
  String get modelStatusUntrained => 'Sense entrenar';

  @override
  String get modelStatusTraining => 'Entrenant';

  @override
  String get modelStatusReady => 'Llest';

  @override
  String get modelStatusFailed => 'L’entrenament ha fallat';

  @override
  String get modelDegradedNotice =>
      'Amb un sol fernie no hi ha entre què triar, així que respon si hi és o no. Afegeix-ne un altre perquè els distingeixi.';

  @override
  String modelRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regions',
      one: '1 regió',
      zero: 'sense regions',
    );
    return '$_temp0';
  }

  @override
  String modelFernieCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fernies',
      one: '1 fernie',
      zero: 'sense fernies',
    );
    return '$_temp0';
  }

  @override
  String get modelDeleteTitle => 'Voleu esborrar aquest model?';

  @override
  String get modelDeleteMessage =>
      'Els seus fernies es queden on són: són teus, no del model. El que es perd és el que havia après: els pesos, els gràfics de l’entrenament i tot el que va deixar al disc.';

  @override
  String get splitTrain => 'Entrenar';

  @override
  String get splitValidation => 'Validar';

  @override
  String get splitTest => 'Provar';

  @override
  String get modelRemoveFernie => 'Treure d’aquest model';

  @override
  String modelMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts',
      one: '1 contingut',
      zero: 'sense continguts',
    );
    return '$_temp0';
  }

  @override
  String modelTooFewRegions(int count) {
    return 'Menys de $count regions: no dona per entrenar';
  }

  @override
  String modelFewRegions(int count) {
    return 'Menys de $count regions: aprendrà poc';
  }

  @override
  String get modelTooFewMedia => 'Pocs continguts diferents: aprendrà el fons';

  @override
  String get modelAssignedFernies => 'Fernies assignats';

  @override
  String get modelAddFernie => 'Afegir fernie';

  @override
  String get modelNoFernies =>
      'Un model sense fernies no té res a aprendre. Afegeix-ne almenys un.';

  @override
  String get modelApplySplitToAll => 'Aplicar aquest repartiment a tots';

  @override
  String get modelRetrainNotice =>
      'Canviar els fernies d’un model entrenat obliga a tornar-lo a entrenar: els seus pesos ja no signifiquen el mateix.';

  @override
  String get modelSaved => 'Desat';

  @override
  String get trainingTitle => 'Entrenament';

  @override
  String get presetFast => 'Ràpid';

  @override
  String get presetFastDescription =>
      'Per veure si la idea funciona abans de deixar l’equip tota la nit. També el raonable sense targeta gràfica.';

  @override
  String get presetBalanced => 'Equilibrat';

  @override
  String get presetBalancedDescription =>
      'El que es vol gairebé sempre: dona per fer servir el model de debò.';

  @override
  String get presetAccurate => 'Acurat';

  @override
  String get presetAccurateDescription =>
      'Quan ja hi ha moltes regions i el model importa. Triga una bona estona.';

  @override
  String get presetCustom => 'Personalitzat';

  @override
  String get presetCustomDescription =>
      'Els comandaments no coincideixen amb cap dels de dalt, així que manen els teus.';

  @override
  String get trainingAdvanced => 'Avançat';

  @override
  String get trainingEpochsLabel => 'Èpoques';

  @override
  String get trainingImageSizeLabel => 'Mida d’imatge';

  @override
  String get trainingBatchLabel => 'Lot';

  @override
  String get trainingBatchAuto => '-1 deixa que ho decideixi ell';

  @override
  String trainingBackboneIs(String backbone) {
    return 'Xarxa: $backbone';
  }

  @override
  String get trainingStart => 'Entrenar model';

  @override
  String get trainingRetrain => 'Tornar a entrenar';

  @override
  String get trainingPreparing => 'Preparant el material...';

  @override
  String get trainingCancelling => 'Aturant-se en acabar aquesta època…';

  @override
  String trainingEpoch(int done, int total) {
    return 'Època $done de $total';
  }

  @override
  String trainingRemaining(int minutes) {
    return 'Queden uns $minutes min';
  }

  @override
  String get trainingEngineNotReady =>
      'El motor de reconeixement encara no està instal·lat. Es prepara des dels ajustos.';

  @override
  String get trainingNoValidation =>
      'no deixa res per validar, així que l’entrenament no sabrà quan aturar-se';

  @override
  String trainingImbalanced(int count) {
    return 'Un fernie té més de $count vegades les regions d’un altre: el model aprendrà a contestar sempre el majoritari';
  }

  @override
  String get metricsLastTraining => 'Últim entrenament';

  @override
  String get metricMap50 => 'mAP50';

  @override
  String get metricMap50to95 => 'mAP50-95';

  @override
  String get metricPrecision => 'Precisió';

  @override
  String get metricRecall => 'Recall';

  @override
  String get metricsPerClass => 'Per fernie';

  @override
  String get metricsConfusionMatrix => 'Matriu de confusió';

  @override
  String get metricsCurves => 'Corbes';

  @override
  String get metricsOpenRunFolder => 'Obrir carpeta de la run';

  @override
  String get metricsRunFolderMissing => 'Aquesta carpeta ja no hi és.';

  @override
  String get metricsRunImagesMissing =>
      'Aquestes imatges ja no són a la carpeta de la run. Esborrar-la no trenca el model: els pesos són l’únic que cal per reconèixer.';

  @override
  String get metricsNotTrainedYet => 'Encara sense entrenar.';

  @override
  String get metricsImportedWeights =>
      'Els pesos vénen de fora, així que no hi ha mètriques d’entrenament.';

  @override
  String get metricsRetry => 'Tornar-ho a provar';

  @override
  String get metricsRealPerformance => 'Rendiment real';

  @override
  String get metricsRealPerformanceEmpty =>
      'Encara sense dades. Compta quants suggeriments d’aquest model acceptes i quants rebutges en importar, que és l’única mesura honesta de si serveix.';

  @override
  String get modelImportWeightsHint =>
      'Un fitxer .pt entrenat en un altre lloc. Es copia a la carpeta de reconeixement perquè no desaparegui per sota del model.';

  @override
  String get modelForgetTrainingHint => 'Oblidar el que s\'ha entrenat';

  @override
  String modelForgetTrainingTitle(String model) {
    return 'Vols oblidar el que va aprendre $model?';
  }

  @override
  String get modelForgetTrainingLoses =>
      'Se\'n van els pesos, les mètriques i la data de l\'entrenament, fitxers inclosos. Tornar a entrenar-lo costa el que va costar el primer cop.';

  @override
  String get modelForgetTrainingKeeps =>
      'Els hiperparàmetres, els fernies i el repartiment es queden com són. El model torna a estar sense entrenar i segueix on era a l\'arbre.';

  @override
  String get modelForgetTrainingAction => 'Oblidar-ho';

  @override
  String get modelForgetTrainingDone =>
      'D\'aquell entrenament no en queda res.';

  @override
  String modelImportWeightsInvalid(String error) {
    return 'No s’han pogut llegir aquests pesos: $error';
  }

  @override
  String modelImportWeightsDone(String classes) {
    return 'Pesos importats: $classes';
  }

  @override
  String get modelImportedBadge => 'Pesos importats';

  @override
  String get trainingFailedEngineStopped =>
      'El motor de reconeixement es va aturar a mitja feina. Torna-ho a provar; si es repeteix, el més probable és que l’equip s’estigui quedant sense memòria: abaixa la mida d’imatge o el lot a «Avançat».';

  @override
  String get trainingFailedOutOfMemory =>
      'Es va quedar sense memòria. Abaixa el lot o la mida d’imatge a «Avançat» i torna-ho a provar.';

  @override
  String get trainingFailedDataset =>
      'No s’ha pogut preparar el material. Pot ser que algun contingut s’hagi mogut o esborrat des que es van marcar les regions.';

  @override
  String get trainingFailedWeights =>
      'Falten els pesos de partida i no s’han pogut descarregar. Comprova la connexió, o importa uns pesos teus.';

  @override
  String get trainingFailedNoSpace =>
      'No hi cap al disc. Un conjunt de vídeo són milers de fotogrames, així que calen uns quants gigues lliures.';

  @override
  String get trainingFailedUnknown => 'L’entrenament ha fallat.';

  @override
  String jobTrainingModel(String model) {
    return 'Entrenant «$model»';
  }

  @override
  String get jobsNone => 'No hi ha tasques';

  @override
  String get treeTitle => 'Arbre de models';

  @override
  String get treeOpen => 'Arbre';

  @override
  String get treeEmpty =>
      'Encara no hi ha res a l’arbre. Un model que no hi sigui no s’executa mai en reconèixer: posa-n’hi un des del plafó de la dreta.';

  @override
  String get treeSearchModel => 'Cercar model';

  @override
  String get treeAvailableModels => 'Models';

  @override
  String get treeAllInTree => 'Ja hi són tots, a l’arbre.';

  @override
  String get treeNoModels => 'Encara no hi ha models.';

  @override
  String get treeRemoveNode => 'Treure de l’arbre';

  @override
  String get treeNodeNotTrained => 'Sense entrenar';

  @override
  String treeSelectedHint(String name) {
    return '«$name» està triat: el que hi posis des del plafó en penjarà.';
  }

  @override
  String get treeClearSelection => 'Deixar';

  @override
  String get treeEdgeAnyDetection => 'qualsevol cosa';

  @override
  String get treeEdgeConditionTitle => 'Quan s’executa?';

  @override
  String treeEdgeConditionMessage(String child, String parent) {
    return '«$child» només s’executa quan «$parent» detecta això. Sense fernie s’executa davant qualsevol detecció, que és tenir els especialitzats corrent tota l’estona: funciona, però és el que cal afinar.';
  }

  @override
  String get treeEdgeDisconnect => 'Despenjar';

  @override
  String get treeFitToView => 'Ajustar a la vista';

  @override
  String get treeZoomIn => 'Apropar';

  @override
  String get treeZoomOut => 'Allunyar';

  @override
  String get treeCannotConnect =>
      'Això no es pot penjar: l’arbre es mossegaria la cua.';

  @override
  String treeOutsideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models fora de l’arbre',
      one: '1 model fora de l’arbre',
    );
    return '$_temp0';
  }

  @override
  String get viewerFavorite => 'Marca com a preferit';

  @override
  String get viewerUnfavorite => 'Treu dels preferits';

  @override
  String get viewerCopied => 'Copiat al porta-retalls';

  @override
  String get viewerCopyFailed => 'No s\'ha pogut copiar el contingut';

  @override
  String get actionRevealInExplorer => 'Veure el fitxer a l’explorador';

  @override
  String get revealInExplorerFailed => 'El fitxer ja no és on era.';

  @override
  String get mediaInfoTitle => 'Informació';

  @override
  String get descriptionHint => 'Afegeix una descripció';

  @override
  String get createdBy => 'Creat per:';

  @override
  String tagDropped(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts etiquetats amb $tag',
      one: 'Etiquetat amb $tag',
    );
    return '$_temp0';
  }

  @override
  String contextMenuTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sobre els $count seleccionats',
      one: 'Sobre aquest contingut',
    );
    return '$_temp0';
  }

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
  String get tagRelationsTitle => 'On és aquesta etiqueta';

  @override
  String get tagRelationsNote =>
      'A dalt, l\'etiqueta de la qual penja. Als costats, amb les quals va. Són dues coses diferents: una etiqueta que penja d\'una altra hereta el seu contingut a les cerques, i les que van juntes només estan relacionades.';

  @override
  String get tagRelationsAddParent => 'Posar etiqueta mare';

  @override
  String get tagRelationsChangeParent => 'Canviar la mare';

  @override
  String get tagRelationsAddSibling => 'Afegir relacionada';

  @override
  String get tagCollapseBranch => 'Plega el que penja d’aquesta';

  @override
  String get tagExpandBranch => 'Desplega el que penja d’aquesta';

  @override
  String get siblingDirectionBoth => 'Cadascuna posa l’altra';

  @override
  String siblingDirectionOneWay(String from, String to) {
    return '«$from» posa «$to»';
  }

  @override
  String get siblingDirectionNone => 'Cap posa l’altra';

  @override
  String get siblingDirectionNote =>
      'Estar relacionades diu que van juntes. La direcció diu què passa en posar-ne una.';

  @override
  String get tagRelationsCreate => 'Crear una etiqueta nova';

  @override
  String get tagRelationsTooltip => 'Etiqueta mare i relacionades';

  @override
  String get tagRelationsNoParent => 'Etiqueta arrel';

  @override
  String tagRelationsParentIs(String name) {
    return 'Penja de $name';
  }

  @override
  String tagRelationsSiblingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relacionades',
      one: '1 relacionada',
    );
    return '$_temp0';
  }

  @override
  String get addSiblingTag => 'Afegir relacionada';

  @override
  String get actionRemove => 'Treure';

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
  String get keepsSelectionOnDrop =>
      'Mantenir la selecció en deixar-la anar sobre una etiqueta';

  @override
  String get keepsSelectionOnDropDescription =>
      'Apagat, deixar anar contingut sobre una etiqueta el desmarca, que és donar la feina per acabada. Encès es queda marcat, per poder posar-li una altra etiqueta seguida sense tornar a assenyalar-ho tot.';

  @override
  String get useCurrentImageAsAvatar => 'Usar la imatge que estàs veient';

  @override
  String get avatarCropTitle => 'Tria l\'avatar';

  @override
  String get avatarCropHint =>
      'Arrossega un quadrat sobre la imatge. Amb la roda t\'hi apropes.';

  @override
  String get avatarCropWholeImage => 'Usar la imatge sencera';

  @override
  String get avatarSourceTitle => 'D\'on surt la imatge?';

  @override
  String get avatarSourceLibrary => 'De la biblioteca de Fern';

  @override
  String get avatarSourceDevice => 'D\'un fitxer de l\'equip';

  @override
  String get avatarLibraryEmpty => 'Aquí no hi ha res que hi encaixi';

  @override
  String get tagLogTitle => 'D\'on surt això';

  @override
  String get tagLogNote => 'El que s\'ha posat a aquest contingut, i per què.';

  @override
  String get tagLogGuessNote =>
      'Part d\'això no es va apuntar: es dedueix de com són les dades ara, no del que va passar. Aquestes línies van marcades.';

  @override
  String get tagLogGuessed => 'deduït';

  @override
  String get tagLogLoading => 'Llegint el registre…';

  @override
  String get tagLogEmpty => 'A aquest contingut no se li ha posat res.';

  @override
  String get tagLogManual => 'La vas posar tu';

  @override
  String get tagLogSourceUrl => 'Va coincidir una adreça vinculada';

  @override
  String get tagLogPlatform => 'La plataforma d\'on es va baixar';

  @override
  String get tagLogAncestor => 'Heretada de la branca';

  @override
  String tagLogAncestorOf(String tag) {
    return 'És per damunt de $tag';
  }

  @override
  String get tagLogSibling => 'Va amb una altra etiqueta';

  @override
  String tagLogSiblingOf(String tag) {
    return 'Va amb $tag';
  }

  @override
  String get tagLogRecognition => 'Vas acceptar el que va proposar un model';

  @override
  String get tagLogFernie => 'El que enllaça un fernie marcat';

  @override
  String tagLogFernieOf(String fernie) {
    return 'Vas marcar aquí en/na $fernie';
  }

  @override
  String get tagLogUnknown => 'No hi consta';

  @override
  String get actionTagLog => 'D\'on surt això';

  @override
  String get viewerSaveSectionTitle => 'En desar contingut importat';

  @override
  String get viewerSaveSectionNote =>
      'Què fa el visor quan dones per definitiu un contingut importat. Sigui com sigui deixa de ser a la graella d\'importació, així que el visor no es pot quedar on era.';

  @override
  String get viewerPrevious => 'Anterior';

  @override
  String get viewerNext => 'Següent';

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
  String get settingsDatabase => 'Base de dades';

  @override
  String get databaseSectionTitle => 'Base de dades';

  @override
  String get databaseSectionNote =>
      'Tot el que Fern sap de la teva biblioteca viu en una base de dades d\'aquest equip: les fitxes dels continguts, les etiquetes, els creadors, els fernies, els models i les regions marcades.';

  @override
  String get databaseWipeTitle => 'Eliminar la base de dades';

  @override
  String get databaseWipeSectionNote =>
      'Deixa Fern com acabat d\'instal·lar. No es pot desfer i no hi ha cap còpia de seguretat.';

  @override
  String get databaseWipeWarning =>
      'Això no es pot desfer. Fern no guarda cap còpia de la base de dades.';

  @override
  String get databaseWipeLoses =>
      'Es perden: totes les fitxes de contingut amb la seva descripció i els seus preferits, totes les etiquetes i creadors, els fernies i totes les regions marcades, els models entrenats i el seu arbre, els suggeriments del reconeixement i els grups de repetits.';

  @override
  String get databaseWipeKeeps =>
      'Els teus fitxers es queden on són: no s\'esborra res del disc, i escanejar la carpeta de la biblioteca els torna a donar d\'alta. Els ajustos, les contrasenyes i les credencials de les fonts també es queden.';

  @override
  String get databaseWipeScopeAll => 'Tot';

  @override
  String get databaseWipeScopeAllNote =>
      'Etiquetes, creadors, fernies, models: tot. L\'aplicació comença de zero.';

  @override
  String get databaseWipeScopeNsfw => 'Només el marcat com a NSFW';

  @override
  String get databaseWipeScopeNsfwNote =>
      'El contingut marcat i el que hereta d\'etiquetes i creadors marcats. Les etiquetes, els creadors, els fernies i els models es queden.';

  @override
  String get databaseWipeFiles => 'Esborrar també els fitxers del disc';

  @override
  String get databaseWipeFilesNote =>
      'Sense això els fitxers es queden on són i un escaneig els torna a portar. Amb això se\'n van: és la part que no té volta.';

  @override
  String get databaseWipeConfirmFiles =>
      'Els fitxers se\'n van també del disc. S\'esborren en segon pla i es pot seguir a la llista de tasques.';

  @override
  String get databaseWipeConfirmNsfw =>
      'Se\'n va només el marcat com a NSFW. Tota la resta es queda com és.';

  @override
  String get databaseWipeContinue => 'Ho entenc, continuar';

  @override
  String get databaseWipeConfirmTitle => 'Escriu la frase per confirmar';

  @override
  String get databaseWipeConfirmNote =>
      'Per assegurar que no és un accident, escriu la frase següent tal com és:';

  @override
  String get databaseWipePhrase => 'Eliminar Base de Dades';

  @override
  String get databaseWipeFieldLabel => 'Frase de confirmació';

  @override
  String get databaseWipeAction => 'Eliminar base de dades';

  @override
  String get databaseWipeFailed => 'No s\'ha pogut eliminar la base de dades.';

  @override
  String get databaseWipeDone => 'La base de dades és buida.';

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
  String get redditGuideAction => 'Com aconsegueixo això?';

  @override
  String get redditGuideTitle => 'Connectar Fern amb Reddit';

  @override
  String get redditGuideIntro =>
      'Reddit no deixa que ningú llegeixi els teus desats fins que registris una aplicació al teu compte. Són un parell de minuts i es fa una sola vegada.';

  @override
  String get redditGuideStep1 =>
      'Obre reddit.com/prefs/apps amb el botó de sota. S\'obre dins del Fern, així que ja ets dins del teu compte.';

  @override
  String get redditGuideStep2 =>
      'Baixa fins al final de la pàgina i prem «create another app...» (o «are you a developer? create an app...»).';

  @override
  String get redditGuideStep3 =>
      'Tria el tipus «script». És el pas que es falla: amb qualsevol altre tipus Reddit crea l\'aplicació igualment, i després rebutja cada petició sense dir per què.';

  @override
  String get redditGuideStep4 =>
      'Posa-li el nom que vulguis, deixa la descripció buida i enganxa això a «redirect uri»:';

  @override
  String get redditGuideStep5 =>
      'Prem «create app». Reddit t\'ensenya la fitxa de l\'aplicació que acabes de crear.';

  @override
  String get redditGuideStep6 =>
      'El client ID és la cadena curta que hi ha just sota «personal use script», a dalt a l\'esquerra de la fitxa. El secret és el camp que posa «secret».';

  @override
  String get redditGuideStep7 =>
      'Torna aquí i enganxa els dos, més el teu usuari i la teva contrasenya de Reddit.';

  @override
  String get redditGuideTwoFactor =>
      'Amb la verificació en dos passos activada, la contrasenya s\'escriu com a contrasenya:codi — Reddit espera les dues coses al mateix camp.';

  @override
  String get redditGuidePrivacy =>
      'Les quatre dades es queden en aquest equip, xifrades, i només s\'envien a Reddit.';

  @override
  String get redditGuideOpen => 'Obre Reddit';

  @override
  String get redditGuideCopy => 'Copia l\'adreça de redirecció';

  @override
  String get redditGuideCopied => 'Adreça de redirecció copiada';

  @override
  String get emptyLibraryHint =>
      'El que portis d’una plataforma o d’una carpeta apareix aquí així que ho hagis revisat.';

  @override
  String get noTagsYetHint =>
      'Les etiquetes són amb què tornes a trobar les coses. Crea’n una des del + de la barra de dalt.';

  @override
  String get noCreatorsYetHint =>
      'Un creador agrupa tot el que ha fet la mateixa persona. Crea’n un des del + de la barra de dalt.';

  @override
  String get noFerniesYetHint =>
      'Un fernie és algú que un model aprèn a reconèixer. Crea’n un des del + de la barra de dalt i marca’l en el teu contingut.';

  @override
  String get modelsEmptyHint =>
      'Un model aprèn a reconèixer els teus fernies. Crea’n un des del + de la barra de dalt.';

  @override
  String get duplicatesNeverScannedHint =>
      'Prem «Cerca ara» i el Fern repassa tota la biblioteca. El primer cop pot trigar una estona.';

  @override
  String get duplicatesNoneHint =>
      'Torna a cercar després d\'importar, o baixa el llistó de semblança a Configuració.';

  @override
  String get viewerInfoTooltip => 'Veure la informació';

  @override
  String get settingsOpenTooltip => 'Obrir els ajustos';

  @override
  String get mediaFileMissing => 'El fitxer ja no és on era';

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
  String get sourceGuideOpenSite => 'Obre el lloc';

  @override
  String get sourceGuideOpenLogin => 'Obre la pantalla d\'entrada';

  @override
  String get sourceGuidePrivacy =>
      'El que enganxis es queda en aquest equip, xifrat, i només s\'envia a aquell lloc.';

  @override
  String get sessionGuideStep1 =>
      'Prem el botó de sota. El Fern obre el lloc al seu propi navegador i et porta a la pantalla d\'entrar.';

  @override
  String get sessionGuideStep2 =>
      'Entra igual que ho faries a qualsevol altre lloc: captcha, codi per correu i tot. És justament per això que això no es pot fer des de fora.';

  @override
  String get sessionGuideStep3 =>
      'Quan hi siguis a dins, prem la clau de la barra del navegador per desar la sessió. Sense aquest pas no es desa res i la importació seguirà dient que no està configurada.';

  @override
  String get sessionGuideExpires =>
      'Les sessions caduquen soles al cap d\'un temps. Quan passi, el Fern t\'avisa i n\'hi ha prou amb repetir aquests passos.';

  @override
  String get danbooruGuideTitle => 'Connectar el Fern amb Danbooru';

  @override
  String get danbooruGuideIntro =>
      'Danbooru dóna a cada compte una clau d\'API perquè els programes puguin llegir en nom seu. Es treu de la teva fitxa, i la teva contrasenya no hi entra.';

  @override
  String get danbooruGuideStep1 =>
      'Obre la teva fitxa amb el botó de sota i assegura\'t que has entrat amb el teu compte.';

  @override
  String get danbooruGuideStep2 =>
      'Busca la fila «API Key» de la teva fitxa i prem «view». Danbooru et demana la contrasenya per ensenyar-te-la.';

  @override
  String get danbooruGuideStep3 =>
      'Si encara no n\'hi ha cap, prem «Add» i posa-li el nom que vulguis. Al Fern li\'n basta una.';

  @override
  String get danbooruGuideStep4 => 'Copia la cadena llarga que t\'ensenya.';

  @override
  String get danbooruGuideStep5 =>
      'Torna aquí: l\'usuari és el mateix amb què entres, i al segon camp hi va la clau, no la teva contrasenya. Danbooru l\'accepta i senzillament no retorna res.';

  @override
  String get danbooruGuideNote =>
      'Revocar la clau des d\'aquella mateixa pàgina li talla el pas al Fern a l\'instant, sense tocar la teva contrasenya.';

  @override
  String get gelbooruGuideTitle => 'Connectar el Fern amb Gelbooru';

  @override
  String get gelbooruGuideIntro =>
      'Gelbooru et dóna els dos valors de cop, escrits en una sola línia. Partir aquesta línia en dos és tota la feina.';

  @override
  String get gelbooruGuideStep1 =>
      'Obre les opcions del teu compte amb el botó de sota i assegura\'t que has entrat.';

  @override
  String get gelbooruGuideStep2 =>
      'Baixa fins a «API Access Credentials» i obre l\'enllaç que ofereix.';

  @override
  String get gelbooruGuideStep3 =>
      'Gelbooru t\'ensenya una línia amb aquesta pinta: &api_key=abc123&user_id=456.';

  @override
  String get gelbooruGuideStep4 =>
      'Aquella línia porta dos valors diferents a dins. No l\'enganxis sencera en un camp: Gelbooru l\'accepta i després no funciona res, sense dir per què.';

  @override
  String get gelbooruGuideStep5 =>
      'Posa el que ve després de user_id= al primer camp, i el que ve després de api_key= al segon.';

  @override
  String get pixivGuideTitle => 'Connectar el Fern amb Pixiv';

  @override
  String get pixivGuideIntro =>
      'Pixiv no té claus per copiar. Aquí no hi ha res a escriure: entres dins del Fern i la sessió és el que t\'identifica.';

  @override
  String get pixivGuideStep4 =>
      'Ja està. Aquí no hi ha res a enganxar: vés a la pantalla d\'importació i tria Pixiv.';

  @override
  String get pinterestGuideTitle => 'Connectar el Fern amb Pinterest';

  @override
  String get pinterestGuideIntro =>
      'Amb el teu nom d\'usuari n\'hi ha prou per als taulers públics. La sessió només cal per als secrets.';

  @override
  String get pinterestGuideStep1 =>
      'Escriu el teu nom d\'usuari de Pinterest al camp de dalt. Amb això els taulers públics ja funcionen.';

  @override
  String get pinterestGuideStep2 =>
      'Només si a més vols els taulers secrets, prem el botó de sota i entra amb el teu compte.';

  @override
  String get pawchiveGuideTitle => 'Connectar el Fern amb Pawchive';

  @override
  String get pawchiveGuideIntro =>
      'Aquí tampoc hi ha claus: entres dins del Fern i la sessió és el que t\'identifica.';

  @override
  String get pawchiveGuideStep4 =>
      'De tornada aquí, tria a sota si vols els teus desats o tot el dels creadors que segueixes.';

  @override
  String get pawchiveGuideLinks =>
      'Les publicacions solen enllaçar a llocs de descàrregues (Mega, Drive, Pixeldrain). El Fern es porta el que pot pel seu compte i et llista la resta en acabar la importació.';

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
  String pendingLinksToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicacions porten a llocs de descàrregues',
      one: '1 publicació porta a un lloc de descàrregues',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicacions et necessiten',
      one: '1 publicació et necessita',
    );
    return '$_temp0';
  }

  @override
  String get pendingLinksDescription =>
      'Porten a llocs de descàrregues que no es poden recórrer sols: tenen la seva pròpia espera, el seu captcha o el seu llistat de fitxers. Obre els que t\'interessin i porta\'ls des del navegador.';

  @override
  String get pendingLinksFolder => 'carpeta';

  @override
  String get pendingLinksFile => 'fitxer';

  @override
  String get pawchiveByCreators => 'Importa per creadors preferits';

  @override
  String get pawchiveByCreatorsDescription =>
      'En comptes de les publicacions que hagis marcat, el Fern recorre tot el que publiquin els creadors que tinguis als preferits. Porta força més, i cada creador se segueix pel seu compte.';

  @override
  String get remoteImportAllWarning =>
      'Sense límit, el Fern recorre el compte sencer. Amb un compte gran són hores de descàrrega i uns quants gigues de disc. Pots aturar-ho quan vulguis des de la pantalla d’importació, i el que ja hagi arribat es queda.';

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
  String browserLoadFailed(String reason) {
    return 'No s\'ha pogut carregar la pàgina ($reason)';
  }

  @override
  String browserLoadFailedHome(String reason) {
    return 'No s\'ha pogut carregar la pàgina ($reason); es torna a la d\'inici';
  }

  @override
  String get browserReset => 'Comença de zero';

  @override
  String get browserResetDone => 'El navegador s\'ha reiniciat';

  @override
  String get browserResetting => 'S\'està tancant el motor del navegador…';

  @override
  String get browserSlow => 'Aquesta pàgina està trigant més del normal';

  @override
  String get browserEngineStuck =>
      'La pàgina ha carregat però no s\'està pintant res. El motor del navegador ha deixat de respondre: tanca el Fern del tot i torna a obrir-lo.';

  @override
  String get browserAsideImporting =>
      'El navegador està apartat mentre s\'importa';

  @override
  String get browserAsideImportingWhy =>
      'Portar molt contingut de cop esprem la màquina, i això és el que deixa el navegador carregant pàgines que després no pinta. El que no està en marxa no es pot trencar.';

  @override
  String get browserAsideAnyway => 'Torna\'l igualment';

  @override
  String get browserAsideOnce =>
      'Només per a aquesta visita: en sortir i tornar s\'aparta un altre cop.';

  @override
  String get browserAsideTitle => 'El navegador durant les importacions';

  @override
  String get browserAsideNote =>
      'Portar molt contingut de cop esprem la màquina, i això és el que deixa el navegador carregant pàgines que després no pinta. Apartar-lo ho evita.';

  @override
  String get browserAsideAlways => 'Aparta\'l sempre';

  @override
  String get browserAsideAlwaysDescription =>
      'Mentre hi hagi qualsevol importació en marxa. És el que s\'ha vist funcionar.';

  @override
  String get browserAsideLarge => 'Només en importacions grans';

  @override
  String get browserAsideLargeDescription =>
      'Només quan la importació es porta tot, tot el nou, o 50 o més.';

  @override
  String get browserAsideNever => 'Mai';

  @override
  String get browserAsideNeverDescription =>
      'El navegador es queda. Si es posa en blanc, «Comença de zero» és a la seva barra.';

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
  String get importAsNsfwTooltip => 'Marca com a NSFW tot el que s’importi';

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
  String get sourceUrlsNote =>
      'Val qualsevol plataforma: es recull tot el que pengi de l’adreça. A les que identifiquen la galeria amb el que va darrere del «?» —Danbooru, Gelbooru— cal copiar l’adreça sencera, paràmetres inclosos.';

  @override
  String get sourceUrlsLabel => 'Adreces';

  @override
  String get sourceUrlHint => 'reddit.com/r/exemple, pixiv.net/users/123…';

  @override
  String get addSourceUrl => 'Afegir adreça';

  @override
  String get noSourceUrls => 'Sense adreces vinculades';

  @override
  String get databaseCleanupTitle => 'Neteja fitxers solts';

  @override
  String get databaseCleanupNote =>
      'Els avatars són còpies que fa el Fern. En canviar-ne un, la còpia anterior deixa de fer-la servir ningú i es queda al disc. Això s’emporta tot el que ja no assenyala ningú.';

  @override
  String get databaseCleanupAction => 'Neteja';

  @override
  String databaseCleanupFound(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers solts, $size',
      one: '1 fitxer solt, $size',
    );
    return '$_temp0';
  }

  @override
  String get databaseCleanupAvatars => 'Avatars sense amo';

  @override
  String get databaseCleanupDownloads => 'Baixades que ja no són a la base';

  @override
  String get databaseCleanupWeights => 'Pesos que cap model no assenyala';

  @override
  String get databaseCleanupKeeps =>
      'No es toquen l’entorn de Python, els conjunts d’entrenament ni les memòries cau.';

  @override
  String get databaseCleanupFailed => 'La neteja no ha pogut acabar';

  @override
  String databaseCleanupDone(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitxers esborrats, $size alliberats',
      one: '1 fitxer esborrat, $size alliberats',
      zero: 'No hi havia res solt',
    );
    return '$_temp0';
  }

  @override
  String get blockedImportsTitle => 'Que no es torni a importar';

  @override
  String get blockedImportsNote =>
      'El que vas demanar que no se t’ofereixi més. Se salta sense arribar a baixar-se.';

  @override
  String get blockedImportsNone => 'No hi ha res blocat.';

  @override
  String get blockedImportsUnblock => 'Torna a importar això';

  @override
  String get blockedImportsOpen => 'Obre la pàgina d’on va sortir';

  @override
  String get blockedImportsClear => 'Oblida’ls tots';

  @override
  String get blockImportAgain => 'No tornis a importar això';

  @override
  String get blockImportAgainDescription =>
      'La font continua oferint el que hi tens desat. Marcat, això se salta sense arribar a baixar-se. Es desfà a Configuració, a Base de dades.';

  @override
  String importSkippedBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltats: vas demanar no tornar a veure\'ls.',
      one: '1 saltat: vas demanar no tornar a veure\'l.',
    );
    return '$_temp0';
  }

  @override
  String creatorNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Amaga $count continguts.',
      one: 'Amaga 1 contingut.',
      zero: 'Ara mateix aquest creador no té contingut.',
    );
    return '$_temp0';
  }

  @override
  String get creatorNsfwOnTooltip =>
      'Marcat com a NSFW · prem per desmarcar-lo';

  @override
  String get creatorNsfwOffTooltip => 'Marca com a NSFW';

  @override
  String get searchChipDescription => 'Descripció';

  @override
  String get showsTagBranchOnFilter =>
      'Mostra la branca sencera en filtrar etiquetes';

  @override
  String get showsTagBranchOnFilterDescription =>
      'En filtrar la llista d\'etiquetes, cada coincidència arriba amb el que en penja, per veure la branca i no només el nom.';

  @override
  String get peopleTitle => 'Persones';

  @override
  String get navPersonaManager => 'Persones';

  @override
  String get tagIsPerson => 'Aquesta etiqueta és una persona';

  @override
  String get tagIsPersonDescription =>
      'Les persones i els personatges es gestionen a la seva pantalla. Continua sent una etiqueta: en assignar i en cercar es comporta igual.';

  @override
  String get openPeopleTooltip => 'Vés a les persones';

  @override
  String get openTagsTooltip => 'Vés a les etiquetes';

  @override
  String get noPeopleYet => 'Encara no hi ha persones';

  @override
  String get noPeopleYetHint =>
      'Marca una etiqueta com a persona des de la seva fitxa, o crea\'n una des d\'aquí.';

  @override
  String get markLinkNsfwTooltip => 'Marca l\'adreça com a no apta';

  @override
  String get unmarkLinkNsfwTooltip => 'L\'adreça està marcada com a no apta';

  @override
  String get openSourceUrlTooltip => 'Obre l\'adreça al navegador';

  @override
  String get editSourceUrlTooltip => 'Edita l\'adreça';

  @override
  String get doneEditingSourceUrlTooltip => 'Acaba d\'editar';

  @override
  String get removeSourceUrlTooltip => 'Treu l\'adreça';

  @override
  String get filtersType => 'Tipus de contingut';

  @override
  String get filterImages => 'Imatges';

  @override
  String get filterGifs => 'GIF';

  @override
  String get filterVideos => 'Vídeos';

  @override
  String get selectAllTooltip => 'Seleccionar tot el que es veu';

  @override
  String get selectNoneTooltip => 'Treure la selecció';

  @override
  String get sortNewestFirst => 'L’últim que va arribar';

  @override
  String get sortOldestFirst => 'El primer que va arribar';

  @override
  String get sortFileName => 'Per nom de fitxer';

  @override
  String get sortDescription => 'Per descripció';

  @override
  String get sortKind => 'Per tipus';

  @override
  String get sortRandom => 'A l’atzar';

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
  String get jobsTooltip => 'Tasques';

  @override
  String get jobsTitle => 'Tasques';

  @override
  String get jobRunning => 'En marxa…';

  @override
  String get jobCancelled => 'Aturada';

  @override
  String get jobDismissTooltip => 'Treure de la llista';

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
  String get jobLinkReview => 'Enllaços per revisar';

  @override
  String get jobLinkImport => 'Portant enllaços';

  @override
  String get jobImport => 'Important';

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
  String get notifyImport => 'Importació acabada';

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
  String get jobTagRegions => 'Marcant el contingut d’una etiqueta';

  @override
  String get jobFileCleanup => 'Esborrant fitxers';

  @override
  String get fernieImportTagTitle => 'Marca una etiqueta sencera';

  @override
  String get fernieImportTagNote =>
      'Tot el que porti aquesta etiqueta rep una regió amb el fotograma sencer, per a aquest fernie. És el que faríes a mà, un per un.';

  @override
  String get fernieImportTagAction => 'Marca’ls';

  @override
  String get fernieImportTagTooltip =>
      'Marca una etiqueta sencera com a regions';

  @override
  String get fernieImportTagFrames => 'Fotogrames per vídeo';

  @override
  String get fernieImportTagFramesNote =>
      'L’entrenament treu una imatge per regió, de manera que un vídeo sencer serien milers de retalls gairebé idèntics.';

  @override
  String fernieImportTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts',
      one: '1 contingut',
      zero: 'Res no porta aquesta etiqueta',
    );
    return '$_temp0';
  }

  @override
  String get fernieImportTagStarted =>
      'El marcatge ha començat; el pots seguir a la llista de tasques';

  @override
  String get fernieToolWholeFrame => 'Marca el fotograma sencer';

  @override
  String fernieAcceptAllProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accepta les $count regions detectades',
      one: 'Accepta la regió detectada',
    );
    return '$_temp0';
  }

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
  String get fernieModeTooltip => 'Marcar fernies en aquest contingut';

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

  @override
  String ferniePendingRegions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count regions són sobre contingut sense confirmar, així que no entrenen',
      one: '1 regió és sobre contingut sense confirmar, així que no entrena',
    );
    return '$_temp0';
  }

  @override
  String get viewerRecognize => 'Reconeix amb els models';

  @override
  String get viewerRecognizing => 'S\'està reconeixent…';

  @override
  String suggestionConfidence(int percent) {
    return '$percent%';
  }

  @override
  String suggestionInstances(int count) {
    return '×$count';
  }

  @override
  String get suggestionFromModel =>
      'Ho proposa un model, encara sense confirmar';

  @override
  String get suggestionCreatorTitle => 'Creador proposat';

  @override
  String get actionAccept => 'Accepta';

  @override
  String get actionReject => 'Rebutja';

  @override
  String get suggestionAcceptAll => 'Accepta-les totes';

  @override
  String get suggestionRejectAll => 'Rebutja-les totes';

  @override
  String get recognizeNoModelsInTree =>
      'Encara no hi ha cap model a l\'arbre. Afegeix-ne un des de la pantalla de l\'arbre de models.';

  @override
  String get recognizeNoTrainedModels =>
      'Cap model de l\'arbre no està entrenat. Entrena\'n un, o importa\'n els pesos des de la pantalla del model.';

  @override
  String get recognizeUnavailable =>
      'No s\'ha pogut llegir l\'arbre de models.';

  @override
  String get recognizeFoundNothing => 'Els models no han trobat res aquí';

  @override
  String get recognizeNothingToDo => 'Aquí no queda res per reconèixer';

  @override
  String get recognizeSelectedTooltip => 'Reconeix la selecció';

  @override
  String get recognizeTagTooltip => 'Reconeix tot el d\'aquesta etiqueta';

  @override
  String get recognizeCreatorTooltip => 'Reconeix tot el d\'aquest creador';

  @override
  String get recognizeLibrary => 'Reconeix la biblioteca';

  @override
  String get recognizeLibraryTitle => 'Reconeix tota la biblioteca';

  @override
  String get recognizeLibraryQuestion =>
      'Reconèixer costa una predicció per imatge, i unes quantes per vídeo. Tria quant se n\'ha de mirar.';

  @override
  String get recognizeLibraryOnlyNew => 'Només el que no s\'ha mirat mai';

  @override
  String get recognizeLibraryAll => 'Tot, una altra vegada';

  @override
  String get recognizeLibraryAllHint =>
      'Útil després d\'entrenar un model millor.';

  @override
  String get recognizeJobLibrary => 'Biblioteca sencera';

  @override
  String get recognizeJobSelection => 'Selecció';

  @override
  String recognizeQueuedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts a la cua per reconèixer',
      one: '1 contingut a la cua per reconèixer',
      zero: 'No s\'ha encuat res',
    );
    return '$_temp0';
  }

  @override
  String recognizeCountable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts',
      one: '1 contingut',
    );
    return '$_temp0';
  }

  @override
  String get recognitionLogTitle => 'Què han fet els models';

  @override
  String get recognitionLogNearMiss => 'vist, sota el llistó';

  @override
  String get recognitionLogNothing => 'res';

  @override
  String get recognitionLogVerdictProposed => 'ho proposa';

  @override
  String recognitionLogVerdictBelow(int percent) {
    return 'ho va veure, però per sota del $percent %';
  }

  @override
  String get recognitionLogVerdictNothing => 'no va veure res';

  @override
  String get recognitionLogVerdictNotReached =>
      'no va córrer: la seva branca no es va obrir';

  @override
  String get recognitionLogVerdictUntrained => 'no va córrer: no té pesos';

  @override
  String get jobReviewTooltip => 'Decideix sobre aquests enllaços';

  @override
  String get notifyLinkReview => 'Enllaços esperant-te';

  @override
  String get jobDetailTooltip => 'Mira què han fet els models';

  @override
  String get jobsClearFinished => 'Dona per vistes les acabades';

  @override
  String recognitionLogSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count continguts',
      one: 'Un contingut',
    );
    return '$_temp0';
  }

  @override
  String recognitionLogProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggeriments',
      one: '1 suggeriment',
    );
    return '$_temp0';
  }

  @override
  String get jobDone => 'Acabada';

  @override
  String recognizeFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggeriments. Prem per veure com',
      one: '1 suggeriment. Prem per veure com',
    );
    return '$_temp0';
  }

  @override
  String get recognitionPanelTitle => 'En reconèixer';

  @override
  String get recognitionThresholdLabel => 'Confiança mínima per proposar';

  @override
  String get recognitionThresholdDescription =>
      'Per sota d\'això, el que vegi no es proposa.';

  @override
  String get recognitionThresholdEverything =>
      'Es proposa tot el que vegi, per poc segur que estigui.';

  @override
  String get recognitionThresholdAll => 'Tot';

  @override
  String get recognitionThresholdLower => 'Abaixa el llistó';

  @override
  String get recognitionThresholdRaise => 'Apuja el llistó';

  @override
  String get recognitionThresholdApplies =>
      'Val per al pròxim reconeixement. El que ja s\'ha proposat no canvia.';

  @override
  String get recognizeReturnTitle => 'Sortiran de la biblioteca una estona';

  @override
  String get recognizeReturnHint =>
      'Només els que rebin algun suggeriment. Es pot apagar a Configuració, a Reconeixement.';

  @override
  String get recognizeReturnConfirm => 'Reconeix igualment';

  @override
  String get returnRecognizedLabel =>
      'Retorna a importació el contingut reconegut';

  @override
  String get maxDetectionsLabel => 'Quantes vegades es desa el mateix';

  @override
  String get maxDetectionsDescription =>
      'Un model pot veure quatre cotxes en una foto. Cadascun és una regió diferent que es pot marcar, així que es desen tots — fins a aquest nombre. Un aparcament en podria donar cinquanta.';

  @override
  String get returnRecognizedDescription =>
      'El que rebi un suggeriment deixa de ser definitiu fins que el validis. Apagat, els suggeriments es continuen veient al panell del visor i no es mou res de lloc.';

  @override
  String recognizeReturnWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count continguts tornaran a la pantalla d\'importació fins que en validis les etiquetes.',
      one:
          'Un contingut tornarà a la pantalla d\'importació fins que en validis les etiquetes.',
    );
    return '$_temp0';
  }

  @override
  String get suggestionsPendingBadge => 'Té suggeriments sense mirar';

  @override
  String get suggestionFilterAll => 'Tot';

  @override
  String get suggestionFilterWith => 'Amb suggeriments';

  @override
  String get suggestionFilterNever => 'Sense mirar mai';

  @override
  String acceptAboveTooltip(int percent) {
    return 'Accepta el que els models veuen amb més d\'un $percent % de seguretat, a la selecció. No dona res per definitiu.';
  }

  @override
  String acceptAboveDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggeriments acceptats',
      one: '1 suggeriment acceptat',
      zero: 'Res no arribava amb prou seguretat',
    );
    return '$_temp0';
  }

  @override
  String get actionClearSelection => 'Deixa de seleccionar';

  @override
  String acceptAboveLabel(int percent) {
    return 'Accepta més del $percent %';
  }

  @override
  String get remoteCreatorsMode => 'Creadors';

  @override
  String get remoteContentMode => 'Contingut';

  @override
  String remoteCreatorNewPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicacions noves',
      one: '1 publicació nova',
      zero: 'res de nou',
    );
    return '$_temp0';
  }

  @override
  String remoteCreatorImporting(String name) {
    return 'Portant el de $name…';
  }

  @override
  String remoteCreatorLastImport(String date) {
    return 'darrera vegada, el $date';
  }

  @override
  String remoteCreatorNewsSince(String date) {
    return 'novetats des del $date';
  }

  @override
  String get remoteCreatorNeverImported => 'mai importat';

  @override
  String get remoteCreatorKnown => 'ja el tens';

  @override
  String get remoteCreatorsEmpty => 'No hi ha creadors en aquesta font';

  @override
  String remoteCreatorsImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Porta $count creadors',
      one: 'Porta 1 creador',
    );
    return '$_temp0';
  }

  @override
  String get importReviewLabel => 'Revisa';

  @override
  String get importSortLabel => 'Ordena';

  @override
  String get importCreatorsLabel => 'Mostra';

  @override
  String get importShowLabel => 'Veure';

  @override
  String get importFetchLabel => 'Portar';

  @override
  String get recognizeJobImported => 'Acabat d\'importar';

  @override
  String get recognizeOnImportLabel => 'Reconeix el que s\'acaba d\'importar';

  @override
  String get recognizeOnImportDescription =>
      'El contingut nou passa pels models sol, quan la importació es calma. No costa res si no hi ha cap model entrenat.';

  @override
  String get suggestionMarkRegion => 'Desa com a regió d\'aquest fernie';

  @override
  String get suggestionRegionSaved =>
      'Regió desada. Compta per al proper entrenament.';

  @override
  String get suggestionRegionFailed => 'No s\'ha pogut desar la regió';

  @override
  String get duplicatesScanNow => 'Cerca ara';

  @override
  String get duplicatesScanning => 'Cercant repetits';

  @override
  String get duplicatesQueued =>
      'Cercant contingut repetit. El primer cop pot trigar una estona.';

  @override
  String get duplicatesNone => 'No hi ha contingut repetit';

  @override
  String get duplicatesNeverScanned => 'Encara no s\'ha cercat';

  @override
  String duplicatesScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cerca acabada: $count grups nous',
      one: 'Cerca acabada: 1 grup nou',
    );
    return '$_temp0';
  }

  @override
  String duplicatesScanNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cerca acabada: res de nou. Queden $count grups per revisar.',
      one: 'Cerca acabada: res de nou. Queda 1 grup per revisar.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesScanClean =>
      'Cerca acabada: no hi ha contingut repetit.';

  @override
  String get duplicatesScanStopped =>
      'Cerca aturada. Les empremtes ja calculades es queden fetes.';

  @override
  String get duplicatesScanFailed =>
      'La cerca no ha pogut acabar. Torna-ho a provar.';

  @override
  String duplicatesGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grups',
      one: '1 grup',
    );
    return '$_temp0';
  }

  @override
  String duplicatesDistance(int distance) {
    return 'distància $distance';
  }

  @override
  String get duplicatesIdentical => 'idèntic';

  @override
  String duplicatesCopyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count còpies',
      one: '1 còpia',
    );
    return '$_temp0';
  }

  @override
  String duplicatesGroupPosition(int position, int total) {
    return 'Grup $position de $total';
  }

  @override
  String get duplicatesKeepThis => 'Conserva aquesta';

  @override
  String get duplicatesMergeMetadata =>
      'Fusiona les metadades a la còpia conservada';

  @override
  String get duplicatesMergeMetadataHint =>
      'Etiquetes, creador, preferit i descripció de les còpies descartades.';

  @override
  String get duplicatesNotDuplicates => 'No són duplicats';

  @override
  String get duplicatesApplyAndNext => 'Aplica i següent';

  @override
  String duplicatesTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etiquetes',
      one: '1 etiqueta',
      zero: 'Sense etiquetes',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesFavorite => 'Preferit';

  @override
  String get duplicatesNoCreator => 'Sense creador';

  @override
  String get duplicatesUnknownSize => 'Mida desconeguda';

  @override
  String get duplicatesPickGroup => 'Tria un grup per comparar-ne les còpies';

  @override
  String get settingsDuplicates => 'Contingut repetit';

  @override
  String get settingsNsfw => 'Contingut NSFW';

  @override
  String get nsfwCoveredLabel => 'Contingut NSFW';

  @override
  String get nsfwViewsTitle => 'Com es comporta';

  @override
  String get nsfwViewsNote =>
      'Què es veu amb el filtre posat i què es veu sense ell. Tots dos s’apliquen al següent que es pinti, sense reiniciar res.';

  @override
  String get nsfwUnlockedViewLabel => 'Sense filtre NSFW';

  @override
  String get nsfwUnlockedViewMixed => 'Tot junt';

  @override
  String get nsfwUnlockedViewOnly => 'Només el marcat';

  @override
  String get nsfwUnlockedViewNote =>
      '«Només el marcat» ho converteix en una biblioteca a part: mentre el filtre estigui tret, la resta del teu contingut no apareix.';

  @override
  String get nsfwLockedViewLabel => 'Amb filtre NSFW';

  @override
  String get nsfwLockedViewHidden => 'No apareix';

  @override
  String get nsfwLockedViewBlurred => 'Apareix tapat';

  @override
  String get nsfwChildTagsLabel =>
      'Marcar una etiqueta marca també les que en pengen';

  @override
  String get nsfwChildTagsDescription =>
      'Una etiqueta que penja d\'una de marcada amaga també el seu contingut, sense haver de marcar-la a part. Apagat, cada etiqueta respon només pel que és seu. No es reescriu res en cap cas: encén-ho i apaga-ho les vegades que vulguis.';

  @override
  String get nsfwLockedViewNote =>
      'Tapat, el contingut marcat continua ocupant el seu lloc a la graella, borrós i amb un cadenat; en tocar-lo es demana la contrasenya. És més còmode, però deixa veure que allà hi ha alguna cosa: quanta n’hi ha i de quina forma és.';

  @override
  String get nsfwSectionTitle => 'Filtre de contingut NSFW';

  @override
  String get nsfwSectionNote =>
      'El que marquis com a NSFW s’amaga: amb el filtre posat no apareix enlloc, ni a la paperera ni a les cerques.';

  @override
  String get nsfwSectionWarning =>
      'Això amaga, no xifra: els fitxers continuen a la seva carpeta amb el seu nom, i qualsevol que obri l’explorador els veu.';

  @override
  String get nsfwNotConfiguredNote =>
      'Encara no hi ha contrasenya. Sense ella no es pot marcar res, i el que hi ha ara es veu com sempre.';

  @override
  String get nsfwConfigureAction => 'Posar una contrasenya';

  @override
  String get nsfwStateLocked =>
      'Amb filtre NSFW: el contingut marcat no es veu';

  @override
  String get nsfwStateUnlocked => 'Sense filtre NSFW: es veu tot';

  @override
  String get nsfwOpenAction => 'Treure el filtre NSFW';

  @override
  String get nsfwCloseAction => 'Tornar a posar el filtre';

  @override
  String get nsfwRememberLabel =>
      'Continuar sense filtre en tornar a obrir Fern';

  @override
  String get nsfwRememberDescription =>
      'Apagat, tancar Fern torna a posar el filtre. Encès es queda com ho vas deixar, i el primer que veuràs en obrir-la és el que hagis marcat.';

  @override
  String get nsfwChangePasswordAction => 'Canviar la contrasenya';

  @override
  String get nsfwChangeDone =>
      'Contrasenya canviada. El codi de recuperació continua sent el mateix.';

  @override
  String get nsfwDisableNote =>
      'Desactivar el filtre desmarca tot el que haguessis marcat —etiquetes, contingut, fernies i models— i deixa d’amagar res. No s’esborra res: estava marcat, no xifrat.';

  @override
  String get nsfwDisableAction => 'Desactivar el filtre';

  @override
  String nsfwDisableDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtre desactivat i $count etiquetes desmarcades.',
      one: 'Filtre desactivat i 1 etiqueta desmarcada.',
      zero: 'Filtre desactivat. No hi havia cap etiqueta marcada.',
    );
    return '$_temp0';
  }

  @override
  String get nsfwSetupTitle => 'Posar la contrasenya';

  @override
  String get nsfwPasswordLabel => 'Contrasenya';

  @override
  String get nsfwPasswordRepeatLabel => 'Repeteix-la';

  @override
  String get nsfwHintLabel => 'Frase clau (opcional)';

  @override
  String get nsfwHintNote =>
      'Se t’ensenya després de tres intents fallits, així que es pot llegir sense saber la contrasenya: que sigui una pista per a tu i no la contrasenya escrita d’una altra manera.';

  @override
  String get nsfwSetupAction => 'Desar';

  @override
  String get nsfwPasswordEmpty => 'Escriu una contrasenya.';

  @override
  String get nsfwPasswordMismatch => 'Les dues contrasenyes no són la mateixa.';

  @override
  String get nsfwCodeTitle => 'El teu codi de recuperació';

  @override
  String get nsfwCodeIntro =>
      'És l’única cosa que treu el filtre si perds la contrasenya, i només s’ensenya ara: Fern no el guarda, guarda una empremta seva. Copia’l o desa’l en un fitxer abans de tancar.';

  @override
  String get nsfwCodeCopy => 'Copiar';

  @override
  String get nsfwCodeCopied => 'Copiat al porta-retalls.';

  @override
  String get nsfwCodeSave => 'Desar en un fitxer';

  @override
  String nsfwCodeSaved(String path) {
    return 'Desat a $path';
  }

  @override
  String get nsfwCodeSaveFailed =>
      'No s’ha pogut desar el fitxer. Copia’l abans de tancar.';

  @override
  String get nsfwCodeDone => 'Ja el tinc desat';

  @override
  String get nsfwCodeFileHeader =>
      'Codi de recuperació del filtre de contingut NSFW de Fern. Desa’l on el puguis trobar: és l’única cosa que treu el filtre si perds la contrasenya.';

  @override
  String get nsfwUnlockTitle => 'Treure el filtre NSFW';

  @override
  String get nsfwUnlockAction => 'Treure’l';

  @override
  String get nsfwUnlockWrong => 'Aquesta no és la contrasenya.';

  @override
  String nsfwUnlockHint(String hint) {
    return 'La teva frase clau: $hint';
  }

  @override
  String get nsfwUnlockNoHint =>
      'No vas posar cap frase clau. Si no recordes la contrasenya, et queda el codi de recuperació.';

  @override
  String get nsfwUnlockRecover => 'Fer servir el codi de recuperació';

  @override
  String get nsfwRecoverTitle => 'Recuperar l’accés';

  @override
  String get nsfwRecoverIntro =>
      'Escriu el codi que vas desar i tria una contrasenya nova. El codi es gasta en fer-lo servir: te’n donarem un altre, i aquell serà el que valgui a partir d’ara.';

  @override
  String get nsfwRecoverCodeLabel => 'Codi de recuperació';

  @override
  String get nsfwRecoverAction => 'Recuperar';

  @override
  String get nsfwRecoverWrong =>
      'Aquest codi no és. Mira’l una altra vegada: els guions i les majúscules són igual.';

  @override
  String get nsfwChangeTitle => 'Canviar la contrasenya';

  @override
  String get nsfwChangeCurrentLabel => 'Contrasenya d’ara';

  @override
  String get nsfwChangeNewLabel => 'Contrasenya nova';

  @override
  String get nsfwChangeAction => 'Canviar-la';

  @override
  String get nsfwChangeWrong => 'La contrasenya d’ara no és aquesta.';

  @override
  String get nsfwDisableTitle => 'Desactivar el filtre';

  @override
  String get nsfwDisableWarning =>
      'S’esborra la contrasenya, es desmarquen totes les etiquetes i el seu contingut es torna a veure. No s’esborra res de la teva biblioteca. Per tornar a tenir filtre caldrà posar-lo de zero i marcar les etiquetes una altra vegada.';

  @override
  String get nsfwDisableSecretLabel => 'Contrasenya o codi de recuperació';

  @override
  String get nsfwDisableWrong => 'Ni la contrasenya ni el codi.';

  @override
  String get nsfwDisableFailed =>
      'No s\'han pogut treure les marques, així que la contrasenya s\'ha quedat com estava. Torna-ho a provar.';

  @override
  String tagNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Amaga $count continguts.',
      one: 'Amaga 1 contingut.',
      zero: 'Ara mateix no hi ha contingut amb aquesta etiqueta.',
    );
    return '$_temp0';
  }

  @override
  String get tagNsfwOnTooltip => 'Marcada com a NSFW · prem per desmarcar-la';

  @override
  String get tagNsfwOffTooltip => 'Marcar com a NSFW';

  @override
  String get nsfwMarkOnTooltip => 'Marcat com a NSFW · prem per desmarcar-lo';

  @override
  String get mediaNsfwMark => 'Marcar com a NSFW';

  @override
  String get mediaNsfwUnmark => 'Treure la marca NSFW';

  @override
  String get duplicatesScanSectionTitle => 'Cerca automàtica';

  @override
  String get duplicatesScanSectionNote =>
      'El contingut repetit no molesta el dia que entra; molesta mesos després, quan ja hi ha quaranta còpies i ningú no se\'n recorda de mirar-ho.';

  @override
  String get duplicatesAutoScanLabel => 'Que el Fern cerqui repetits sol';

  @override
  String get duplicatesAutoScanDescription =>
      'En obrir el Fern, si ha passat el temps que triïs aquí sota, repassa tota la biblioteca sense que li ho demanis: corre per darrere amb la prioritat més baixa, així que no destorba el que estiguis fent, i només t\'avisa si troba alguna cosa. Apagat, els repetits només es cerquen quan prems «Cerca ara» a Contingut repetit.';

  @override
  String get duplicatesScanPeriodLabel => 'Cada quant';

  @override
  String get duplicatesMovingLabel => 'Mirar també vídeos i GIF';

  @override
  String get duplicatesMovingDescription =>
      'D\'un vídeo es compara el fotograma del 10 % de la seva durada, no el primer: els vídeos comencen en negre o amb una caràtula, i per aquí en sortirien agrupats tres que no tenen res a veure. Costa força més que una imatge, així que amb una biblioteca plena de vídeos el primer escaneig s\'allarga. El que ja s\'hagi calculat es continua comparant encara que ho apaguis.';

  @override
  String get duplicatesPeriodMonthly => 'Cada mes';

  @override
  String get duplicatesPeriodQuarterly => 'Cada tres mesos';

  @override
  String get duplicatesPeriodBiannual => 'Cada sis mesos';

  @override
  String get duplicatesPeriodYearly => 'Cada any';

  @override
  String duplicatesLastScan(String date) {
    return 'Darrer escaneig: $date';
  }

  @override
  String get duplicatesLastScanNever => 'Encara no s\'ha escanejat mai';

  @override
  String get duplicatesOpenViewer => 'Veure a pantalla completa';

  @override
  String get duplicatesThresholdSectionTitle => 'Llistó de semblança';

  @override
  String get duplicatesThresholdSectionNote =>
      'Quant es poden diferenciar dos continguts i seguir comptant com el mateix. Apujar-lo agrupa més i comença a ajuntar coses que només s\'assemblen; abaixar-lo deixa repetits sense trobar. S\'aplica a l\'escaneig següent, no al que ja s\'ha agrupat.';

  @override
  String get duplicatesThresholdLabel => 'Llistó';

  @override
  String get duplicatesRehashSectionTitle => 'Començar de zero';

  @override
  String get duplicatesRehashSectionNote =>
      'Llença totes les empremtes i les torna a calcular en l\'escaneig següent. És la sortida per quan l\'agrupació surt malament i no se sap per què. Els grups que ja has contestat es queden com estan.';

  @override
  String get duplicatesRehashButton => 'Recalcular totes les empremtes';

  @override
  String get duplicatesRehashRunning => 'Esborrant les empremtes';

  @override
  String duplicatesRehashDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Esborrades $count empremtes. Es tornaran a calcular en l\'escaneig següent.',
      one:
          'Esborrada 1 empremta. Es tornarà a calcular en l\'escaneig següent.',
      zero: 'No hi havia res a esborrar',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesRehashFailed =>
      'No s\'han pogut esborrar les empremtes.';

  @override
  String get settingsHelp => 'Ajuda';

  @override
  String get tutorialSectionTitle => 'Voltes guiades';

  @override
  String get tutorialSectionNote =>
      'Deu recorreguts que cobreixen tota l\'aplicació, un per matèria. Seguint-los tots no queda res per explicar. Es pot deixar qualsevol en qualsevol moment.';

  @override
  String get tutorialOfferTitle => 'Et mostro l\'aplicació?';

  @override
  String get tutorialOfferBody =>
      'Un recorregut de deu passos pel que és cada cosa i on és. N\'hi ha nou més, un per matèria, a Configuració → Ajuda. Es deixa quan vulguis.';

  @override
  String get tutorialOfferAccept => 'Començar';

  @override
  String get tutorialOfferDecline => 'Ara no';

  @override
  String tutorialProgress(int position, int total) {
    return '$position de $total';
  }

  @override
  String get tutorialSkip => 'Sortir';

  @override
  String get tutorialBack => 'Enrere';

  @override
  String get tutorialNext => 'Següent';

  @override
  String get tutorialDone => 'Fet';

  @override
  String get tutorialWelcomeTitle => 'Benvingut a FeRN';

  @override
  String get tutorialWelcomeBody =>
      'FeRN desa el contingut que col·leccionis: el porta, l\'ordena amb etiquetes i creadors, i pot aprendre a reconèixer el que hi surt. S\'avança amb Següent o amb les fletxes, i se surt amb Escape.';

  @override
  String get tutorialSidebarTitle => 'Per aquí es navega';

  @override
  String get tutorialSidebarBody =>
      'Totes les pantalles hi són: la teva biblioteca, el que portes de fora, els preferits, la paperera i els gestors de creadors, etiquetes, fernies i models. El botó de dalt el plega quan cal espai.';

  @override
  String get tutorialImportTitle => 'Per aquí entra el contingut';

  @override
  String get tutorialImportBody =>
      'Portes contingut d\'una font remota —Reddit, Pixiv, Danbooru, Gelbooru, Pinterest, Pawchive— o d\'una carpeta del teu disc. El que arriba espera aquí fins que l\'acceptes, així que res no entra a la biblioteca sense que ho vegis.';

  @override
  String get tutorialContentTitle => 'Aquí apareix tot';

  @override
  String get tutorialContentBody =>
      'La teva biblioteca: tot el que has acceptat. Un clic obre el visor, el botó dret treu les accions, i se\'n poden marcar diversos alhora per tractar-los junts.';

  @override
  String get tutorialTagsTitle => 'Etiqueta arrossegant';

  @override
  String get tutorialTagsBody =>
      'Les etiquetes del menú també són llocs on deixar anar: arrossega un o diversos continguts damunt d\'una i queden etiquetats. En prémer-la, la biblioteca es queda amb el que la porta.';

  @override
  String get tutorialCreateTitle => 'Crear coses';

  @override
  String get tutorialCreateBody =>
      'D\'aquí surten els creadors, les etiquetes, els fernies i els models. Un creador és qui va fer alguna cosa; una etiqueta és qualsevol cosa per la qual vulguis agrupar; un fernie és una cara o un objecte que vols que FeRN aprengui.';

  @override
  String get tutorialSearchTitle => 'Cercar';

  @override
  String get tutorialSearchBody =>
      'Escriu i FeRN t\'ofereix el que encaixa: una etiqueta, un creador, una descripció. El que triïs es queda com una píndola, i les píndoles s\'acumulen: amb dues de posades s\'ensenya el que compleix totes dues.';

  @override
  String get tutorialSettingsTitle => 'Tota la resta és aquí';

  @override
  String get tutorialSettingsBody =>
      'Idioma, tema, carpetes, fonts remotes, reconeixement i el bloqueig de contingut. A Ajuda hi ha els altres nou recorreguts: un per matèria, i entre tots cobreixen tota l\'aplicació.';

  @override
  String get tourGeneralTitle => 'Volta general';

  @override
  String get tourGeneralDescription =>
      'Què és FeRN, per a què serveix cada pantalla i on és cada cosa. Comença per aquí.';

  @override
  String get tourImportingTitle => 'Portar i revisar contingut';

  @override
  String get tourImportingDescription =>
      'D\'on surt el contingut, com es revisa i què cal perquè arribi a la biblioteca.';

  @override
  String get tourImporting1Title => 'D\'on i quant';

  @override
  String get tourImporting1Body =>
      'Tries la font —una de remota o una carpeta d\'aquest equip—, dius si vols tot o només el nou des de l\'últim cop, i prems Portar. Una font remota porta el que tinguis marcat com a preferit allà.';

  @override
  String get tourImporting2Title => 'Cada font demana les seves claus';

  @override
  String get tourImporting2Body =>
      'Les fonts remotes necessiten les dades del teu compte, i es posen a Configuració → Fonts remotes. Cadascuna explica com aconseguir-les: no són la teva contrasenya, sinó claus que la plataforma dona per a això.';

  @override
  String get tourImporting3Title => 'Res d\'això encara no és teu';

  @override
  String get tourImporting3Body =>
      'Aquesta graella és la safata d\'entrada: el que s\'ha portat, esperant que diguis què fer-ne. Ja és al teu disc, però no és a la teva biblioteca i no surt a les cerques.';

  @override
  String get tourImporting4Title => 'Obre\'n un i decideix';

  @override
  String get tourImporting4Body =>
      'Un clic l\'obre al visor. Allà el deses, i passa a ser definitiu, o el descartes: descartar el treu de la base de dades i et pregunta si esborrar també el fitxer.';

  @override
  String get tourImporting5Title => 'La fitxa, sense sortir del visor';

  @override
  String get tourImporting5Body =>
      'El plafó lateral és on se li posa creador, etiquetes, descripció i enllaços. S\'edita mentre es mira, que és quan se sap què és. En desar, a més, es passa al següent.';

  @override
  String get tourManagersTitle => 'Etiquetes, persones i creadors';

  @override
  String get tourManagersDescription =>
      'Tot el que serveix per ordenar la biblioteca: l\'arbre d\'etiquetes, les germanes, les persones, els creadors i l\'etiquetatge automàtic.';

  @override
  String get tourManagers1Title => 'Els creadors';

  @override
  String get tourManagers1Body =>
      'Un creador és qui va fer alguna cosa: un artista, un compte, un estudi. Cada contingut en té un, i només un. En triar-ne un aquí, la pantalla s\'omple amb el seu.';

  @override
  String get tourManagers2Title => 'La seva fitxa';

  @override
  String get tourManagers2Body =>
      'Nom, avatar i els enllaços on publica. Aquests enllaços no són adorn: són el que permet que FeRN li posi el creador sol quan arriba alguna cosa des d\'una d\'aquestes adreces.';

  @override
  String get tourManagers3Title => 'Els avatars';

  @override
  String get tourManagers3Body =>
      'Prem la imatge i tries d\'on surt: un fitxer de l\'equip, o la teva pròpia biblioteca. De la biblioteca pots retallar un quadrat de qualsevol imatge, que és el que un avatar és de debò.';

  @override
  String get tourManagers4Title => 'Les etiquetes van igual';

  @override
  String get tourManagers4Body =>
      'Amb una diferència: un contingut té un creador, però tantes etiquetes com vulguis. Una etiqueta és qualsevol cosa per la qual vulguis agrupar: una sèrie, un color, un ambient, un lloc.';

  @override
  String get tourManagers5Title =>
      'Les etiquetes pengen les unes de les altres';

  @override
  String get tourManagers5Body =>
      'Arrossega\'n una sobre una altra i queda penjant d\'ella. Aquí hi ha l\'avantatge: posar una etiqueta filla posa també totes les que té a sobre, així que allò etiquetat amb un personatge surt també en cercar la seva sèrie.';

  @override
  String get tourFernieTitle => 'Fernies i el mode fernie';

  @override
  String get tourFernieDescription =>
      'Què és un fernie, d\'on surten els seus exemples i totes les maneres de marcar-li regions al teu contingut.';

  @override
  String get tourFernie1Title => 'Què és un fernie';

  @override
  String get tourFernie1Body =>
      'Una cara, un personatge o un objecte que vols que FeRN aprengui a reconèixer al teu contingut. No és una etiqueta: una etiqueta diu què és una cosa, un fernie és un exemple de quin aspecte té.';

  @override
  String get tourFernie2Title => 'Enllaça\'l amb alguna cosa';

  @override
  String get tourFernie2Body =>
      'Cada fernie pot apuntar a una etiqueta o a un creador. Aquest enllaç és el que converteix el reconeixement en etiquetatge: quan es trobi el fernie, això és el que es proposa. Sense res enllaçat només serveix per entrenar.';

  @override
  String get tourFernie3Title => 'Les seves regions';

  @override
  String get tourFernie3Body =>
      'Cada retall és un exemple seu, i són els exemples amb què aprèn un model. Com més i més variats, millor: amb poca varietat aprendrà el fons en comptes de la cosa.';

  @override
  String get tourFernie4Title => 'Es marquen al visor';

  @override
  String get tourFernie4Body =>
      'Obre un contingut i entra al mode fernie. Amb l\'eina de marcar, arrossega un requadre sobre el que vulguis i tries de qui és. En vídeo i GIF la regió és del fotograma en què siguis.';

  @override
  String get tourFernie5Title => 'Corregir el marcat';

  @override
  String get tourFernie5Body =>
      'L\'altra eina tria el que ja hi és: es mou, s\'estira pels tiradors, es dona a un altre fernie o s\'esborra. Res no s\'escriu fins que surts desant, així que es pot desfer pel camí.';

  @override
  String get tourModelsTitle => 'Models i reconeixement';

  @override
  String get tourModels1Title => 'Els teus models';

  @override
  String get tourModels1Body =>
      'Un model és el que de debò reconeix. S\'arma amb els fernies que li posis, s\'entrena un cop, i a partir d\'aquí pot mirar el teu contingut i dir el que veu.';

  @override
  String get tourModels2Title => 'Abans, l\'entorn';

  @override
  String get tourModels2Body =>
      'El reconeixement corre sobre Python, i FeRN te l\'instal·la: Configuració → Reconeixement i prémer instal·lar. Són uns quants centenars de megues i es fa un sol cop. Amb targeta gràfica va molt més ràpid.';

  @override
  String get tourModels3Title => 'Armar-ne un';

  @override
  String get tourModels3Body =>
      'Li tries els seus fernies i què ha de contestar: si cadascun hi és o no hi és, o quin d\'ells ha trobat i on. El segon necessita almenys dos fernies i regions marcades al contingut.';

  @override
  String get tourModels4Title => 'Entrenar triga';

  @override
  String get tourModels4Body =>
      'De minuts a hores, segons el que li hagis donat i la màquina que tinguis. Corre per darrere i pots seguir fent servir FeRN; l\'indicador de dalt diu per quina època va i quant queda a ull.';

  @override
  String get tourModels5Title => 'Reconèixer';

  @override
  String get tourModels5Body =>
      'Un model ja entrenat repassa el contingut que li posis —un, una selecció o tota la biblioteca— i proposa el que veu. Per sota del seu llistó de seguretat no proposa res.';

  @override
  String get tourDuplicatesTitle => 'Contingut repetit';

  @override
  String get tourDuplicatesDescription =>
      'Com es busca el repetit, com es decideix quina còpia es queda i de què depèn que dues coses comptin com la mateixa.';

  @override
  String get tourDuplicates1Title => 'Cercar repetits';

  @override
  String get tourDuplicates1Body =>
      'Prem Cercar ara i FeRN repassa tota la biblioteca calculant una empremta de cada contingut. El primer cop pot trigar una estona; després només calcula la del nou.';

  @override
  String get tourDuplicates2Title => 'Els grups';

  @override
  String get tourDuplicates2Body =>
      'Cada grup són còpies que s\'assemblen prou per ser el mateix: la mateixa imatge en dues mides, o desada dos cops des de llocs diferents. Els que ja has contestat no tornen a sortir.';

  @override
  String get tourDuplicates3Title => 'Es decideix quina es queda';

  @override
  String get tourDuplicates3Body =>
      'Tries la còpia que conserves i la resta es descarten. Abans pots fusionar en la que es queda les etiquetes, el creador, el preferit i la descripció de les que se\'n van.';

  @override
  String get tourDuplicates4Title => 'O dir que no són la mateixa';

  @override
  String get tourDuplicates4Body =>
      'Si el grup s\'equivoca, digues-ho i no es torna a oferir. Dues coses que només s\'assemblen no són un repetit, i això només ho saps tu.';

  @override
  String get tourDuplicates5Title => 'El llistó, a Configuració';

  @override
  String get tourDuplicates5Body =>
      'Quant es poden diferenciar dos continguts i seguir comptant com el mateix. Pujar-lo agrupa més i comença a ajuntar coses que només s\'assemblen; baixar-lo deixa només les còpies gairebé idèntiques.';

  @override
  String get tourModelsDescription =>
      'L\'entorn de Python, com s\'arma i s\'entrena un model, què passa amb el que proposa i com l\'arbre decideix quins s\'executen.';

  @override
  String get tourModels6Title => 'Res no s\'aplica sol';

  @override
  String get tourModels6Body =>
      'El que veu es queda en suggeriment fins que l\'acceptes, al plafó del contingut o de cop des de la pantalla d\'importació. Rebutjar-ne una és dir que no es torni a oferir per a aquell contingut.';

  @override
  String get tourModels7Title => 'L\'arbre de models';

  @override
  String get tourModels7Body =>
      'Un model que no és a l\'arbre no s\'executa mai en reconèixer. L\'arbre és el que diu quins corren i en quin ordre.';

  @override
  String get tourModels8Title => 'Ficar-los i penjar-los';

  @override
  String get tourModels8Body =>
      'El plafó de la dreta són els models que són fora. Tria un node de l\'arbre i el que fiquis penjarà d\'ell. Un model no pot penjar d\'ell mateix ni ser dos cops a l\'arbre.';

  @override
  String get tourLibraryTitle => 'La biblioteca i el visor';

  @override
  String get tourLibraryDescription =>
      'La graella, marcar-ne diversos alhora, el menú del botó dret i tot el que sap fer el visor.';

  @override
  String get tourSearchingTitle => 'Cercar i filtrar';

  @override
  String get tourSearchingDescription =>
      'Les píndoles que s\'acumulen, el text lliure, els filtres de la barra i les altres maneres d\'acotar el que veus.';

  @override
  String get tourNsfwTitle => 'El bloqueig de contingut';

  @override
  String get tourNsfwDescription =>
      'Una contrasenya que amaga el que marquis, què s\'amaga amb això i com es comporta obert i tancat.';

  @override
  String get tourFilesTitle => 'Fitxers i manteniment';

  @override
  String get tourFilesDescription =>
      'On viu el teu contingut al disc, què fa FeRN amb aquests fitxers i com es neteja després.';

  @override
  String get tutorialViewerTitle => 'El visor';

  @override
  String get tutorialViewerBody =>
      'Obrir alguna cosa ocupa tota la pantalla: s\'apropa amb la roda, es passa d\'un a un altre amb les fletxes, i el plafó lateral és on se li posa creador, etiquetes i descripció mentre ho mires.';

  @override
  String get tutorialJobsTitle => 'El que corre per darrere';

  @override
  String get tutorialJobsBody =>
      'Les importacions, el reconeixement, els entrenaments i la cerca de repetits corren per darrere: aquest indicador diu què hi ha en marxa, per on va i permet aturar-ho. Mentrestant pots seguir fent servir FeRN.';

  @override
  String get tourImporting6Title => 'El que no vols que torni';

  @override
  String get tourImporting6Body =>
      'Una font remota torna a oferir el mateix cada cop. En descartar alguna cosa pots dir a més que no te la torni a oferir: se salta abans de baixar-la, i la llista del que has bloquejat és a Configuració → Base de dades.';

  @override
  String get tourImporting7Title => 'El que pot passar sol';

  @override
  String get tourImporting7Body =>
      'El que arriba pot etiquetar-se sol si l\'adreça d\'on ve està vinculada a una etiqueta, marcar-se com a NSFW si ho encens a la capçalera, i passar pels teus models si ho demanes a Configuració.';

  @override
  String get tourImporting8Title => 'De cop';

  @override
  String get tourImporting8Body =>
      'No cal anar d\'un en un: marca\'n diversos i la capçalera et deixa acceptar-los tots, descartar-los tots, o acceptar de cop els suggeriments dels teus models que passin de la seguretat que triïs.';

  @override
  String get tourImporting9Title => 'I ja és a Contingut';

  @override
  String get tourImporting9Body =>
      'El que has desat surt de la graella d\'importació i apareix a la biblioteca. A partir d\'aquí es cerca, s\'etiqueta i entra a tota la resta que fa FeRN.';

  @override
  String get tourLibrary1Title => 'Tot el que tens';

  @override
  String get tourLibrary1Body =>
      'La graella respecta la forma de cada contingut, així que es reconeixen tant per la silueta com pel que hi ha dins. En desplaçar-te es va carregant el que ve.';

  @override
  String get tourLibrary2Title => 'Diversos alhora';

  @override
  String get tourLibrary2Body =>
      'Cada cel·la té la seva casella al cantó: marca\'n una i estàs seleccionant. Majúscules i clic estira la selecció fins allà, seguint l\'ordre de la pantalla. El que facis després va sobre totes.';

  @override
  String get tourLibrary3Title => 'El botó dret';

  @override
  String get tourLibrary3Body =>
      'Sobre qualsevol cel·la treu el que es pot fer: marcar-lo com a preferit, enviar-lo a la paperera, reconèixer-lo amb els teus models o obrir la carpeta on és. Amb una selecció feta, va sobre tota ella.';

  @override
  String get tourLibrary4Title => 'La paperera retorna';

  @override
  String get tourLibrary4Body =>
      'Enviar alguna cosa a la paperera no l\'esborra: es queda allà un temps i es pot restablir amb tot el que tenia. Buidar la paperera és el que esborra de debò, i això pregunta abans.';

  @override
  String get tourLibrary5Title => 'Ordenar i filtrar aquí';

  @override
  String get tourLibrary5Body =>
      'La capçalera diu quants n\'hi ha i permet ordenar-los —el més nou, el més vell, a l\'atzar— i quedar-te només amb imatges, només amb vídeo, o només amb el que va venir d\'una font.';

  @override
  String get tourLibrary6Title => 'Dins del visor';

  @override
  String get tourLibrary6Body =>
      'La roda apropa, el botó central —o la barra espaiadora— arrossega la imatge, i el doble clic la torna a ajustar a la pantalla. Les fletxes passen a l\'anterior i al següent sense sortir.';

  @override
  String get tourLibrary7Title => 'El plafó d\'informació';

  @override
  String get tourLibrary7Body =>
      'Creador, etiquetes, descripció i enllaços, tot editable allà mateix. També ensenya el que proposen els teus models, i un botó que explica d\'on ha sortit cada etiqueta d\'aquell contingut.';

  @override
  String get tourLibrary8Title => 'Preferits';

  @override
  String get tourLibrary8Body =>
      'El cor marca el que vols tornar a trobar sense recordar com ho vas etiquetar. Tot el marcat té la seva pròpia pantalla al menú.';

  @override
  String get tourLibrary9Title => 'Vídeo i animació';

  @override
  String get tourLibrary9Body =>
      'El vídeo i els GIF es reprodueixen al visor amb una línia de temps que es pot recórrer fotograma a fotograma. Això importa més endavant: una regió de fernie és d\'un fotograma, no de tot el vídeo.';

  @override
  String get tourManagers6Title => 'I algunes van juntes';

  @override
  String get tourManagers6Body =>
      'En deixar-ne anar una sobre una altra també es pot triar relacionar-les en comptes de penjar-les: són germanes. Les germanes no són ni a sobre ni a sota: posar-ne una posa també l\'altra, perquè van sempre juntes.';

  @override
  String get tourManagers7Title => 'Les persones són etiquetes';

  @override
  String get tourManagers7Body =>
      'Una etiqueta es pot marcar com a persona: algú o un personatge que surt al contingut. És només una manera de tenir la llista ordenada —el botó de dalt canvia entre les dues llistes— i a la resta de l\'aplicació es comporten com qualsevol etiqueta.';

  @override
  String get tourManagers8Title => 'Etiquetar sol';

  @override
  String get tourManagers8Body =>
      'Una etiqueta pot tenir adreces vinculades. Tot el que arribi des d\'una d\'aquestes adreces entra ja etiquetat, i amb el que hi hagi a sobre i les seves germanes. D\'aquí sortirà la major part del teu etiquetatge.';

  @override
  String get tourManagers9Title => 'Una llista llarga, domada';

  @override
  String get tourManagers9Body =>
      'El xebró d\'una etiqueta plega la seva branca, i el cercador de sobre la llista la troba pel nom. Les dues coses van aquí i al menú lateral, i el que pleguis segueix plegat el cop següent.';

  @override
  String get tourManagers10Title => 'Etiquetar de cop';

  @override
  String get tourManagers10Body =>
      'Des de la biblioteca, arrossega un o diversos continguts sobre una etiqueta del menú. És la manera ràpida, i és per això que les etiquetes del menú són llocs on deixar anar.';

  @override
  String get tourManagers11Title => 'D\'on surt aquesta etiqueta?';

  @override
  String get tourManagers11Body =>
      'FeRN etiqueta sol per diversos camins, i al plafó tots es veuen igual. El botó del rellotge de cada contingut explica cadascuna: la vas posar tu, va coincidir una adreça, es va heretar, la va proposar un model, la va portar un fernie.';

  @override
  String get tourSearching1Title => 'La barra de cerca';

  @override
  String get tourSearching1Body =>
      'Funciona des de qualsevol pantalla. A mesura que escrius, FeRN t\'ofereix el que encaixa: etiquetes, creadors i contingut per la descripció. Cerca a la teva biblioteca, no a internet.';

  @override
  String get tourSearching2Title => 'El que tries es queda en una píndola';

  @override
  String get tourSearching2Body =>
      'Triar una etiqueta o un creador el converteix en una píndola de la barra. Una píndola cerca per aquella cosa exacta i no pel seu nom: el creador Pompeu porta el seu, i no el que només menciona la paraula.';

  @override
  String get tourSearching3Title => 'Les píndoles es creuen';

  @override
  String get tourSearching3Body =>
      'Amb dues píndoles s\'ensenya el que compleix totes dues, no el que en compleix alguna: aquesta etiqueta, d\'aquest creador. Aquí hi ha la utilitat. El retrocés amb el camp buit treu l\'última.';

  @override
  String get tourSearching4Title => 'El text lliure';

  @override
  String get tourSearching4Body =>
      'Si el que escrius no és una etiqueta ni un creador, prem Enter i es queda com a píndola de text lliure: cerca a les descripcions i als noms de fitxer. Útil per al que mai no vas arribar a etiquetar.';

  @override
  String get tourSearching5Title => 'Acotar el resultat';

  @override
  String get tourSearching5Body =>
      'El filtre del costat de la barra decideix quines classes de resultat compten i permet quedar-te només amb imatges, només amb vídeo o només amb una font. Amb una sola píndola, a més, permet descartar grups sencers.';

  @override
  String get tourSearching6Title => 'El menú també filtra';

  @override
  String get tourSearching6Body =>
      'Prémer una etiqueta del menú lateral és el mateix que posar la seva píndola a la barra, així que des d\'allà pots seguir: afegeix un creador, afegeix una paraula. La barra sempre ensenya el que està filtrant.';

  @override
  String get tourSearching7Title => 'Cada llista té el seu';

  @override
  String get tourSearching7Body =>
      'Les llistes d\'etiquetes, creadors i fernies tenen el seu propi filtre a sobre. Aquell només acota la llista que estàs mirant, i no toca el que ensenya la graella.';

  @override
  String get tourFernie6Title => 'Quan l\'exemple és tot';

  @override
  String get tourFernie6Body =>
      'Hi ha un botó que marca tot el fotograma de cop, per quan el contingut no és més que la cosa. I a la fitxa d\'un fernie n\'hi ha un altre que agafa una etiqueta sencera i marca així tot el seu contingut.';

  @override
  String get tourFernie7Title => 'De suggeriment a exemple';

  @override
  String get tourFernie7Body =>
      'Quan un model ja ha proposat alguna cosa, el plafó ofereix convertir el que va veure en regions: dibuixa els requadres i tu acceptes els que estiguin bé. És la manera més ràpida de fer créixer un fernie.';

  @override
  String get tourFernie8Title => 'Marcar també etiqueta';

  @override
  String get tourFernie8Body =>
      'Marcar-li una regió a un contingut és dir que aquell fernie hi surt, així que el que enllaça se li posa al moment. El creador només si no en tenia ja un de propi.';

  @override
  String get tourFernie9Title => 'I després s\'entrena';

  @override
  String get tourFernie9Body =>
      'Els fernies sols no reconeixen res. El que reconeix és un model entrenat amb ells, i d\'això va el recorregut següent.';

  @override
  String get tourModels9Title => 'Cada branca té la seva condició';

  @override
  String get tourModels9Body =>
      'Un fill només s\'executa quan el pare detecta el fernie que li hagis posat a aquella unió. Aquí hi ha la gràcia: un de general filtra, i només el que troba passa als especialitzats.';

  @override
  String get tourModels10Title => 'Quan va sortir malament';

  @override
  String get tourModels10Body =>
      'Un entrenament es pot aturar a mitges, i a un model se li pot fer oblidar el que ha après: se\'n van els seus pesos i torna a estar sense entrenar, però es queden els seus fernies, els seus ajustos i el seu lloc a l\'arbre.';

  @override
  String get tourDuplicates6Title => 'I cerca sol';

  @override
  String get tourDuplicates6Body =>
      'Cada cert temps FeRN ho repassa pel seu compte i avisa si troba alguna cosa. Aquest període també és a Configuració, i apagar-ho també.';

  @override
  String get tourNsfw1Title => 'Què és el bloqueig';

  @override
  String get tourNsfw1Body =>
      'Una contrasenya que amaga part de la teva biblioteca. El que marquis com a NSFW desapareix mentre el bloqueig estigui tancat: no és a la graella, ni a les cerques, ni als recomptes.';

  @override
  String get tourNsfw2Title => 'Posar-lo en marxa';

  @override
  String get tourNsfw2Body =>
      'A Configuració, a la secció del bloqueig, es posa una contrasenya. FeRN et dona llavors un codi de recuperació: apunta\'l. És l\'única manera de tornar a entrar, perquè la contrasenya no es desa enlloc.';

  @override
  String get tourNsfw3Title => 'Obrir i tancar';

  @override
  String get tourNsfw3Body =>
      'Obrir demana la contrasenya; tancar no pregunta res i és immediat. Pots fer que recordi que està obert entre sessions, o que arrenqui tancat sempre.';

  @override
  String get tourNsfw4Title => 'Marcar una etiqueta o un creador';

  @override
  String get tourNsfw4Body =>
      'Les seves fitxes tenen un botó de bloqueig. Marcar una etiqueta amaga tot el que la porta, i tot el que en penja a l\'arbre. Marcar un creador l\'amaga a ell i a tot el seu contingut.';

  @override
  String get tourNsfw5Title => 'O un contingut solt';

  @override
  String get tourNsfw5Body =>
      'Qualsevol contingut es pot marcar pel seu compte des del visor, diguin el que diguin les seves etiquetes. I en importar pots fer que tot el que arribi entri ja marcat, cosa que estalvia marcar-ne cinquanta a mà.';

  @override
  String get tourNsfw6Title => 'Com es comporta';

  @override
  String get tourNsfw6Body =>
      'Tries què vol dir tancat: que el marcat desaparegui del tot, o que surti difuminat per saber que hi és. I tries si en obrir es veu tot o només el marcat.';

  @override
  String get tourNsfw7Title => 'Els enllaços també es marquen';

  @override
  String get tourNsfw7Body =>
      'Una etiqueta o un creador poden tenir adreces marcades: no s\'ensenyen amb el bloqueig tancat, però segueixen etiquetant el que arribi d\'elles. Amagar una adreça no és oblidar-la.';

  @override
  String get tourNsfw8Title => 'Desfer-se de tot';

  @override
  String get tourNsfw8Body =>
      'A Configuració → Base de dades es pot buidar només el marcat: només el contingut, perquè les etiquetes, els creadors, els fernies i els models es queden. Només s\'ofereix amb el bloqueig obert: tancat seria esborrar a cegues.';

  @override
  String get tourFiles1Title => 'On viu el teu contingut';

  @override
  String get tourFiles1Body =>
      'FeRN desa una base de dades amb el que sap, i els fitxers es queden al teu disc. A Configuració tries la carpeta de la biblioteca: allà és on va a parar el que portes.';

  @override
  String get tourFiles2Title => 'Vigilar una carpeta teva';

  @override
  String get tourFiles2Body =>
      'Pots apuntar FeRN a una carpeta que ja tinguis i portar-te el que hi ha dins. Tu decideixes si copia els fitxers a la biblioteca o els deixa on són i només se\'n recorda.';

  @override
  String get tourFiles3Title => 'Ordenar sol';

  @override
  String get tourFiles3Body =>
      'FeRN pot arxivar el que gestiona en carpetes per font, per creador o per data, perquè el disc s\'assembli a la biblioteca. Si canvies d\'idea després, mou el que ja hi és.';

  @override
  String get tourFiles4Title => 'La carpeta d\'avatars';

  @override
  String get tourFiles4Body =>
      'Els avatars són còpies que fa FeRN, així que viuen a la seva pròpia carpeta, que també tries tu. Canviar la carpeta s\'emporta el que hi ha dins: res no es queda sense la seva imatge.';

  @override
  String get tourFiles5Title => 'Moure la biblioteca';

  @override
  String get tourFiles5Body =>
      'Si apuntes la biblioteca a un altre disc, FeRN s\'ofereix a moure-hi el que gestiona i a actualitzar totes les rutes que té apuntades. És una operació llarga, així que t\'explica com ha anat.';

  @override
  String get tourFiles6Title => 'Fitxers que no fa servir ningú';

  @override
  String get tourFiles6Body =>
      'Amb el temps s\'acumulen orfes: avatars que vas reemplaçar, baixades la fitxa de les quals vas descartar, pesos d\'un model que ja no hi és. El botó de neteja de Configuració els troba, diu quant ocupen i pregunta abans d\'esborrar.';

  @override
  String get tourFiles7Title => 'Començar de zero';

  @override
  String get tourFiles7Body =>
      'Buidar la base de dades és l\'única cosa d\'aquí sense volta enrere, i pregunta dos cops. Tu tries si s\'emporta també els fitxers: sense això, els teus fitxers es queden on són i un escaneig els torna a portar.';

  @override
  String get tourFiles8Title => 'I t\'avisa quan acaba';

  @override
  String get tourFiles8Body =>
      'Els treballs llargs —importar, entrenar, reconèixer, cercar repetits— poden avisar-te en acabar, amb so o sense. Això també és a Configuració, i pots triar de quins.';

  @override
  String get viewerVolume => 'Volum';

  @override
  String get tagNameTaken => 'Ja hi ha una etiqueta amb aquest nom';

  @override
  String get filterByNameHint => 'Filtrar per nom';

  @override
  String tagDropAsChild(String name) {
    return 'Penjar de «$name»';
  }

  @override
  String tagDropAsSibling(String name) {
    return 'Relacionar amb «$name»';
  }

  @override
  String get importStopping => 'Aturant la importació…';
}
