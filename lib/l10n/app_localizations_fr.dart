// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get sidebarCollapse => 'Replier le menu';

  @override
  String get sidebarExpand => 'Déplier le menu';

  @override
  String get navGallery => 'Galerie';

  @override
  String get navTags => 'Tags';

  @override
  String get navMedia => 'Médias';

  @override
  String get navImport => 'Importer';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navDeleted => 'Supprimés';

  @override
  String get navCreatorManager => 'Gestion des créateurs';

  @override
  String get navTagManager => 'Gestion des tags';

  @override
  String get navBrowser => 'Navigateur';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get menuNewCreator => 'Nouveau créateur';

  @override
  String get menuNewTag => 'Nouveau tag';

  @override
  String get menuNewCollection => 'Nouvelle collection';

  @override
  String get collectionsWip => 'Les collections sont encore en chantier';

  @override
  String get mobileLayoutWip => 'La version mobile arrive bientôt';

  @override
  String mediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias',
      one: '1 média',
      zero: 'Aucun média',
    );
    return '$_temp0';
  }

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoris',
      one: '1 favori',
      zero: 'Aucun favori pour le moment',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get filtersResultsFrom => 'Afficher les résultats de';

  @override
  String get filterMedia => 'Médias';

  @override
  String get filterTags => 'Tags';

  @override
  String get filterCreators => 'Créateurs';

  @override
  String get emptyLibrary => 'C\'est un peu vide par ici';

  @override
  String mediaFetched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias trouvés',
      one: '1 média trouvé',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String selectedOfCount(int selected, int total) {
    return '$selected sur $total sélectionnés';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médias marqués pour suppression',
      one: '1 média marqué pour suppression',
      zero: 'Rien à supprimer',
    );
    return '$_temp0';
  }

  @override
  String deletedRetentionNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Supprimé définitivement au bout de $days jours',
      one: 'Supprimé définitivement au bout d\'1 jour',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip =>
      'Supprimer définitivement de la base de données';

  @override
  String remoteImportWarning(String source) {
    return 'Du contenu va être importé depuis $source';
  }

  @override
  String get remoteImportAmountAll =>
      'Tout ce que vous avez enregistré sur votre compte sera récupéré.';

  @override
  String get remoteImportAmountSinceLast =>
      'Ce que vous avez enregistré depuis la dernière importation sera récupéré.';

  @override
  String remoteImportAmountLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus au maximum seront récupérés.',
      one: '1 contenu au maximum sera récupéré.',
    );
    return '$_temp0';
  }

  @override
  String get favoriteSelectedTooltip => 'Marquer la sélection comme favorite';

  @override
  String get deleteSelectedTooltip =>
      'Envoyer la sélection vers l\'écran des supprimés';

  @override
  String deleteTrashWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers vont être supprimés définitivement',
      one: '1 fichier va être supprimé définitivement',
    );
    return '$_temp0';
  }

  @override
  String deleteDiscardWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers vont être écartés',
      one: '1 fichier va être écarté',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesFromDisk => 'Supprimer aussi les fichiers du disque';

  @override
  String get deleteFilesFromDiskDescription =>
      'Si vous la décochez, le contenu quitte la base de données mais ses fichiers restent où ils sont, de sorte qu\'une analyse ultérieure peut les récupérer.';

  @override
  String get actionStopImport => 'Arrêter l\'importation';

  @override
  String get actionImport => 'Importer';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get actionSelectFolder => 'Choisir un dossier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get showPassword => 'Afficher';

  @override
  String get hidePassword => 'Masquer';

  @override
  String get actionUnassignTag => 'Retirer le tag';

  @override
  String get actionRemoveParentTag => 'Retirer le parent';

  @override
  String get actionDeleteTag => 'Supprimer le tag';

  @override
  String get actionUnassignCreator => 'Retirer le créateur';

  @override
  String get actionDeleteCreator => 'Supprimer le créateur';

  @override
  String get sourceLocalComputer => 'Ordinateur local';

  @override
  String get sourceAll => 'Toutes';

  @override
  String get sourceBrowser => 'Navigateur';

  @override
  String get sourceBrowserNote => 'Ouvrir le navigateur';

  @override
  String get sourceBrowserHint =>
      'Ce contenu ne se demande pas d\'ici : il se choisit page par page sur l\'écran du navigateur.';

  @override
  String get sourceNotConfigured => 'Non configurée';

  @override
  String sourceLogIn(String source) {
    return 'Connecte-toi à $source';
  }

  @override
  String sourceLogInHint(String source) {
    return 'Ouvre $source dans le navigateur de Fern. Une fois connecté, appuie là-bas sur le bouton de la clé pour enregistrer la session et reviens ici.';
  }

  @override
  String get selectItem => 'Sélectionner';

  @override
  String get deselectItem => 'Désélectionner';

  @override
  String get viewerBack => 'Retour';

  @override
  String get viewerShare => 'Copier dans le presse-papiers';

  @override
  String get viewerFullscreen => 'Plein écran';

  @override
  String get viewerExitFullscreen => 'Quitter le plein écran';

  @override
  String get viewerSkipBack => 'Reculer de cinq secondes';

  @override
  String get viewerSkipForward => 'Avancer de cinq secondes';

  @override
  String get viewerLoop => 'Lire en boucle';

  @override
  String get viewerPlaybackSectionTitle => 'Lecture vidéo';

  @override
  String get viewerPlaybackSectionNote =>
      'Ce que la visionneuse fait à une vidéo pendant que vous parcourez sa ligne de temps.';

  @override
  String get viewerPauseWhenSeeking => 'Mettre en pause en saisissant la barre';

  @override
  String get viewerPauseWhenSeekingDescription =>
      'La vidéo s’arrête dès que vous saisissez la barre et reste où vous la laissez. Désactivé, elle continue depuis l’endroit où vous la relâchez. Le marquage de régions met toujours en pause, quoi qu’en dise ce réglage : une région se marque sur une image fixe.';

  @override
  String get fernieUndo => 'Annuler la dernière région marquée';

  @override
  String get createTooltip => 'Créer';

  @override
  String get menuNewModel => 'Nouveau modèle';

  @override
  String get newModelTitle => 'Nouveau modèle';

  @override
  String get modelNameLabel => 'Nom du modèle';

  @override
  String get modelFunctionLabel => 'Ce à quoi il répond';

  @override
  String get modelFunctionBoolean => 'Est-ce présent ?';

  @override
  String get modelFunctionBooleanDescription =>
      'Dit si chacun de ses fernies est dans le contenu. Avec plusieurs, il répond pour chacun séparément.';

  @override
  String get modelFunctionClassification => 'Lequel est-ce ?';

  @override
  String get modelFunctionClassificationDescription =>
      'Distingue ses fernies et dit lequel il a trouvé, et où. Il lui en faut au moins deux : avec un seul, il n’y a pas de choix.';

  @override
  String get modelsTitle => 'Modèles';

  @override
  String get modelsEmpty => 'Pas encore de modèles';

  @override
  String get modelStatusUntrained => 'Non entraîné';

  @override
  String get modelStatusTraining => 'Entraînement';

  @override
  String get modelStatusReady => 'Prêt';

  @override
  String get modelStatusFailed => 'L’entraînement a échoué';

  @override
  String get modelDegradedNotice =>
      'Avec un seul fernie il n’y a pas de choix, alors il répond s’il est là ou non. Ajoutez-en un autre pour qu’il les distingue.';

  @override
  String modelRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count régions',
      one: '1 région',
      zero: 'aucune région',
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
      zero: 'aucun fernie',
    );
    return '$_temp0';
  }

  @override
  String get modelDeleteTitle => 'Supprimer ce modèle ?';

  @override
  String get modelDeleteMessage =>
      'Ses fernies restent où ils sont : ils sont à vous, pas au modèle. Ce qui se perd, c’est ce qu’il avait appris : les poids, les graphiques de l’entraînement et tout ce qu’il a laissé sur le disque.';

  @override
  String get splitTrain => 'Entraîner';

  @override
  String get splitValidation => 'Valider';

  @override
  String get splitTest => 'Tester';

  @override
  String get modelRemoveFernie => 'Retirer de ce modèle';

  @override
  String modelMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus',
      one: '1 contenu',
      zero: 'aucun contenu',
    );
    return '$_temp0';
  }

  @override
  String modelTooFewRegions(int count) {
    return 'Moins de $count régions : pas de quoi entraîner';
  }

  @override
  String modelFewRegions(int count) {
    return 'Moins de $count régions : il apprendra peu';
  }

  @override
  String get modelTooFewMedia =>
      'Trop peu de contenus différents : il apprendra le fond';

  @override
  String get modelAssignedFernies => 'Fernies assignés';

  @override
  String get modelAddFernie => 'Ajouter un fernie';

  @override
  String get modelNoFernies =>
      'Un modèle sans fernies n’a rien à apprendre. Ajoutez-en au moins un.';

  @override
  String get modelApplySplitToAll => 'Appliquer cette répartition à tous';

  @override
  String get modelRetrainNotice =>
      'Changer les fernies d’un modèle entraîné oblige à le réentraîner : ses poids ne veulent plus dire la même chose.';

  @override
  String get modelSaved => 'Enregistré';

  @override
  String get trainingTitle => 'Entraînement';

  @override
  String get presetFast => 'Rapide';

  @override
  String get presetFastDescription =>
      'Pour voir si l’idée fonctionne avant de laisser la machine tourner toute la nuit. Aussi le choix raisonnable sans carte graphique.';

  @override
  String get presetBalanced => 'Équilibré';

  @override
  String get presetBalancedDescription =>
      'Ce qu’on veut la plupart du temps : de quoi utiliser le modèle pour de vrai.';

  @override
  String get presetAccurate => 'Soigné';

  @override
  String get presetAccurateDescription =>
      'Quand il y a déjà beaucoup de régions et que le modèle compte. Prend un bon moment.';

  @override
  String get presetCustom => 'Personnalisé';

  @override
  String get presetCustomDescription =>
      'Les réglages ne correspondent à aucun de ceux du dessus : les vôtres l’emportent.';

  @override
  String get trainingAdvanced => 'Avancé';

  @override
  String get trainingEpochsLabel => 'Époques';

  @override
  String get trainingImageSizeLabel => 'Taille d’image';

  @override
  String get trainingBatchLabel => 'Lot';

  @override
  String get trainingBatchAuto => '-1 le laisse décider';

  @override
  String trainingBackboneIs(String backbone) {
    return 'Réseau : $backbone';
  }

  @override
  String get trainingStart => 'Entraîner le modèle';

  @override
  String get trainingRetrain => 'Réentraîner';

  @override
  String get trainingPreparing => 'Préparation du matériel...';

  @override
  String trainingEpoch(int done, int total) {
    return 'Époque $done sur $total';
  }

  @override
  String trainingRemaining(int minutes) {
    return 'Environ $minutes min restantes';
  }

  @override
  String get trainingEngineNotReady =>
      'Le moteur de reconnaissance n’est pas encore installé. Il se prépare depuis les réglages.';

  @override
  String get trainingNoValidation =>
      'ne laisse rien pour valider : l’entraînement ne saura pas quand s’arrêter';

  @override
  String trainingImbalanced(int count) {
    return 'Un fernie a plus de $count fois les régions d’un autre : le modèle apprendra à toujours répondre le majoritaire';
  }

  @override
  String get trainingQueued => 'Entraînement en file';

  @override
  String get metricsLastTraining => 'Dernier entraînement';

  @override
  String get metricMap50 => 'mAP50';

  @override
  String get metricMap50to95 => 'mAP50-95';

  @override
  String get metricPrecision => 'Précision';

  @override
  String get metricRecall => 'Rappel';

  @override
  String get metricsPerClass => 'Par fernie';

  @override
  String get metricsConfusionMatrix => 'Matrice de confusion';

  @override
  String get metricsCurves => 'Courbes';

  @override
  String get metricsOpenRunFolder => 'Ouvrir le dossier de la run';

  @override
  String get metricsRunFolderMissing => 'Ce dossier n’existe plus.';

  @override
  String get metricsRunImagesMissing =>
      'Ces images ne sont plus dans le dossier de la run. Le supprimer ne casse pas le modèle : les poids suffisent pour reconnaître.';

  @override
  String get metricsNotTrainedYet => 'Pas encore entraîné.';

  @override
  String get metricsImportedWeights =>
      'Les poids viennent de l’extérieur : il n’y a pas de métriques d’entraînement.';

  @override
  String get metricsRetry => 'Réessayer';

  @override
  String get metricsRealPerformance => 'Performance réelle';

  @override
  String get metricsRealPerformanceEmpty =>
      'Pas encore de données. On compte combien de suggestions de ce modèle vous acceptez et rejetez à l’import : la seule mesure honnête de son utilité.';

  @override
  String get modelImportWeights => 'Importer des poids';

  @override
  String get modelImportWeightsHint =>
      'Un fichier .pt entraîné ailleurs. Il est copié dans le dossier de reconnaissance pour qu’il ne disparaisse pas sous le modèle.';

  @override
  String modelImportWeightsInvalid(String error) {
    return 'Ces poids n’ont pas pu être lus : $error';
  }

  @override
  String modelImportWeightsDone(String classes) {
    return 'Poids importés : $classes';
  }

  @override
  String get modelImportedBadge => 'Poids importés';

  @override
  String get trainingFailedEngineStopped =>
      'Le moteur de reconnaissance s’est arrêté en cours de route. Réessayez ; si cela se reproduit, la machine manque sans doute de mémoire : baissez la taille d’image ou le lot dans « Avancé ».';

  @override
  String get trainingFailedOutOfMemory =>
      'Plus de mémoire disponible. Baissez le lot ou la taille d’image dans « Avancé » et réessayez.';

  @override
  String get trainingFailedDataset =>
      'Le matériel n’a pas pu être préparé. Des contenus ont peut-être été déplacés ou supprimés depuis que les régions ont été marquées.';

  @override
  String get trainingFailedWeights =>
      'Les poids de départ manquent et n’ont pas pu être téléchargés. Vérifiez la connexion, ou importez vos propres poids.';

  @override
  String get trainingFailedNoSpace =>
      'Pas assez de place sur le disque. Un jeu de données vidéo, ce sont des milliers d’images : il faut quelques gigas libres.';

  @override
  String get trainingFailedUnknown => 'L’entraînement a échoué.';

  @override
  String jobTrainingModel(String model) {
    return 'Entraînement de « $model »';
  }

  @override
  String get jobsNone => 'Rien en cours';

  @override
  String get treeTitle => 'Arbre de modèles';

  @override
  String get treeOpen => 'Arbre';

  @override
  String get treeEmpty =>
      'Rien dans l’arbre pour l’instant. Un modèle qui n’y est pas ne s’exécute jamais à la reconnaissance : ajoutez-en un depuis le panneau de droite.';

  @override
  String get treeSearchModel => 'Chercher un modèle';

  @override
  String get treeAvailableModels => 'Modèles';

  @override
  String get treeAllInTree => 'Ils sont déjà tous dans l’arbre.';

  @override
  String get treeNoModels => 'Il n’y a pas encore de modèles.';

  @override
  String get treeRemoveNode => 'Retirer de l’arbre';

  @override
  String get treeNodeNotTrained => 'Pas entraîné';

  @override
  String get treeAddAsRoot => 'Ajouter seul';

  @override
  String treeAddAsChild(String parent) {
    return 'Rattacher à « $parent »';
  }

  @override
  String treeSelectedHint(String name) {
    return '« $name » est sélectionné : ce que vous ajoutez depuis le panneau lui sera rattaché.';
  }

  @override
  String get treeClearSelection => 'Désélectionner';

  @override
  String get treeEdgeAnyDetection => 'n’importe quoi';

  @override
  String get treeEdgeConditionTitle => 'Quand s’exécute-t-il ?';

  @override
  String treeEdgeConditionMessage(String child, String parent) {
    return '« $child » ne s’exécute que lorsque « $parent » détecte ceci. Sans fernie, il s’exécute à la moindre détection : les spécialisés tournent alors tout le temps. Ça marche, mais c’est ce qu’il faut affiner.';
  }

  @override
  String get treeEdgeDisconnect => 'Détacher';

  @override
  String get treeFitToView => 'Ajuster à la vue';

  @override
  String get treeZoomIn => 'Zoom avant';

  @override
  String get treeZoomOut => 'Zoom arrière';

  @override
  String get treeCannotConnect =>
      'Impossible de rattacher : l’arbre se mordrait la queue.';

  @override
  String treeOutsideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modèles hors de l’arbre',
      one: '1 modèle hors de l’arbre',
    );
    return '$_temp0';
  }

  @override
  String get viewerFavorite => 'Ajouter aux favoris';

  @override
  String get viewerUnfavorite => 'Retirer des favoris';

  @override
  String get viewerCopied => 'Copié dans le presse-papiers';

  @override
  String get viewerCopyFailed => 'Impossible de copier ce contenu';

  @override
  String get mediaInfoTitle => 'Informations';

  @override
  String get descriptionHint => 'Ajouter une description';

  @override
  String get createdBy => 'Créé par :';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get addTag => 'Ajouter un tag';

  @override
  String get noTagsYet => 'Aucun tag pour l\'instant';

  @override
  String get creatorsTitle => 'Créateurs';

  @override
  String get noCreatorsYet => 'Aucun créateur pour l\'instant';

  @override
  String get noSocialProfiles => 'Aucun profil social';

  @override
  String get openProfileTooltip => 'Ouvrir le profil dans le navigateur';

  @override
  String get editProfileTooltip => 'Modifier le lien';

  @override
  String get doneEditingProfileTooltip => 'Terminer la modification';

  @override
  String get removeProfileTooltip => 'Retirer le lien';

  @override
  String get tagNameSearchLabel => 'Nom du tag';

  @override
  String get tagSearchHint => 'Tag';

  @override
  String get createTag => 'Créer un tag';

  @override
  String get searchCreatorLabel => 'Rechercher un créateur';

  @override
  String get creatorSearchHint => 'Nom';

  @override
  String get createCreator => 'Créer un créateur';

  @override
  String get newTagTitle => 'Nouveau tag';

  @override
  String get tagNameLabel => 'Nom du tag';

  @override
  String get parentTagLabel => 'Tag parent (facultatif)';

  @override
  String get newCreatorTitle => 'Nouveau créateur';

  @override
  String get creatorNameLabel => 'Nom du créateur';

  @override
  String get creatorNameTaken => 'Il existe déjà un créateur avec ce nom';

  @override
  String get socialProfilesLabel => 'Profils sociaux';

  @override
  String get enterNameHint => 'Saisissez un nom';

  @override
  String get searchEllipsisHint => 'Rechercher...';

  @override
  String get profileLinkHint => 'Lien du profil';

  @override
  String get addProfile => 'Ajouter un profil';

  @override
  String get resultTypeMedia => 'média';

  @override
  String get resultTypeTag => 'tag';

  @override
  String get resultTypeCreator => 'créateur';

  @override
  String get noFolderSelected => 'Aucun dossier sélectionné';

  @override
  String get chooseFolder => 'Choisir un dossier';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsViewer => 'Visionneuse';

  @override
  String get settingsFiles => 'Fichiers';

  @override
  String get settingsRemoteSources => 'Sources distantes';

  @override
  String get languageSectionTitle => 'Langue de l\'application';

  @override
  String get languageSectionNote =>
      'Toute l\'application change de langue dès que vous en choisissez une.';

  @override
  String get sidebarSectionTitle => 'Menu latéral';

  @override
  String get sidebarSectionNote =>
      'Comment la liste des tags du menu latéral est dessinée.';

  @override
  String get showListAvatars => 'Afficher les avatars dans la liste';

  @override
  String get showListAvatarsDescription =>
      'Chaque tag est dessiné avec sa propre image au lieu de l\'icône commune, ce qui permet de les distinguer quand le menu est replié. Les tags sans image gardent l\'icône.';

  @override
  String get viewerSaveSectionTitle => 'En enregistrant un média importé';

  @override
  String get viewerSaveSectionNote =>
      'Ce que fait la visionneuse quand vous validez un média importé. Dans tous les cas il quitte la grille d\'importation, donc la visionneuse ne peut pas rester où elle était.';

  @override
  String get viewerSaveNext => 'Aller au média suivant';

  @override
  String get viewerSaveNextDescription =>
      'La visionneuse passe au média suivant, comme si vous aviez appuyé sur la flèche. S\'il ne reste rien à revoir, elle se ferme.';

  @override
  String get viewerSaveClose => 'Fermer la visionneuse';

  @override
  String get viewerSaveCloseDescription =>
      'La visionneuse se ferme et vous revenez à la grille d\'importation, déjà sans ce média.';

  @override
  String get themeSectionTitle => 'Thème';

  @override
  String get themeSectionNote =>
      'Les couleurs avec lesquelles toute l\'application est peinte.';

  @override
  String get themeSystem => 'Suivre le système';

  @override
  String get themeSystemDescription =>
      'Clair ou sombre, selon ce qu\'utilise votre bureau.';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeLightDescription => 'Les couleurs de toujours de Fern.';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeDarkDescription =>
      'La même application, pour un bureau sombre.';

  @override
  String get themeCustom => 'Sur mesure';

  @override
  String get themeCustomDescription =>
      'Vos couleurs, celles que vous choisissez ci-dessous.';

  @override
  String get customColorsTitle => 'Vos couleurs';

  @override
  String get customColorsNote =>
      'Accessibles uniquement avec le thème sur mesure. Ce que vous ne changez pas est repris du thème clair ou du sombre, selon le fond que vous avez choisi.';

  @override
  String get customColorPrimary => 'Primaire';

  @override
  String get customColorSecondary => 'Secondaire';

  @override
  String get customColorTerciary => 'Accent';

  @override
  String get customColorError => 'Erreur';

  @override
  String get customColorBackground => 'Fond';

  @override
  String get customColorSurface => 'Surface';

  @override
  String get customColorForeground => 'Texte';

  @override
  String get customColorPick => 'Choisir la couleur';

  @override
  String get customColorReset => 'Revenir à la couleur d\'origine';

  @override
  String get colorPickerTitle => 'Choisissez une couleur';

  @override
  String get colorPickerHex => 'Code hexadécimal';

  @override
  String get filesLocalTitle => 'Fichiers locaux';

  @override
  String get syncLocalFiles => 'Synchroniser les fichiers locaux';

  @override
  String get syncLocalFilesDescription =>
      'Fern déplace dans un dossier dédié les médias avec lesquels il travaille, aussi bien ceux déjà importés que ceux à venir.';

  @override
  String get libraryFolder => 'Dossier de la bibliothèque';

  @override
  String get copyFiles => 'Copier les fichiers';

  @override
  String get copyFilesDescription =>
      'Conserve le fichier d\'origine à sa place et travaille avec une copie dans le dossier de la bibliothèque.';

  @override
  String get avatarsTitle => 'Avatars';

  @override
  String get avatarsDescription =>
      'Les images d\'avatar sont toujours copiées dans un dossier dédié, que la synchronisation des fichiers locaux soit activée ou non. Changer de dossier emmène les avatars existants avec lui.';

  @override
  String get avatarsFolder => 'Dossier des avatars';

  @override
  String get organizationTitle => 'Classement';

  @override
  String get organizationDescription =>
      'Comment les fichiers sont répartis dans le dossier de la bibliothèque. Sans effet sur les images d\'avatar.';

  @override
  String get organizationFlat => 'Tous les fichiers ensemble';

  @override
  String get organizationFlatDescription =>
      'Chaque fichier reste directement dans le dossier de la bibliothèque';

  @override
  String get organizationByTag => 'Sous-dossiers par tag';

  @override
  String get organizationByTagDescription =>
      'Un dossier par tag, d\'après le premier tag du contenu';

  @override
  String get organizationBySource => 'Sous-dossiers par source';

  @override
  String get organizationBySourceDescription =>
      'Un dossier par origine : local, Pixiv, Twitter...';

  @override
  String get organizationByCreator => 'Sous-dossiers par créateur';

  @override
  String get organizationByCreatorDescription => 'Un dossier par créateur';

  @override
  String get migrationTitle => 'Migration';

  @override
  String get migrationDescription =>
      'Classe selon les critères ci-dessus tous les fichiers déjà présents dans la bibliothèque.';

  @override
  String get migrateFiles => 'Migrer les fichiers';

  @override
  String avatarsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avatars déplacés vers le nouveau dossier',
      one: '1 avatar déplacé vers le nouveau dossier',
      zero: 'Les avatars étaient déjà dans ce dossier',
    );
    return '$_temp0';
  }

  @override
  String get avatarsMoveFailed => 'Les avatars n\'ont pas pu être déplacés';

  @override
  String filesOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers déplacés',
      one: '1 fichier déplacé',
      zero: 'Tout était déjà à sa place',
    );
    return '$_temp0';
  }

  @override
  String get filesOrganizeFailed => 'Les fichiers n\'ont pas pu être classés';

  @override
  String get redditTitle => 'Reddit';

  @override
  String get redditDescription =>
      'Fern télécharge ce que tu as enregistré sur ton compte Reddit. Crée une application de type script sur reddit.com/prefs/apps pour obtenir les deux clés.';

  @override
  String get redditClientId => 'Identifiant client';

  @override
  String get redditClientIdHint =>
      'La clé affichée sous le nom de ton application';

  @override
  String get redditClientSecret => 'Secret client';

  @override
  String get redditClientSecretHint => 'Le secret de ton application';

  @override
  String get redditUsername => 'Nom d\'utilisateur';

  @override
  String get redditUsernameHint => 'Ton compte Reddit, sans /u/';

  @override
  String get redditPassword => 'Mot de passe';

  @override
  String get redditPasswordHint => 'Le mot de passe de ce compte';

  @override
  String get redditCredentialsNote =>
      'Les identifiants restent sur cet ordinateur et ne servent qu\'à parler à Reddit.';

  @override
  String get settingsBrowser => 'Navigateur';

  @override
  String get browserHome => 'Page d\'accueil';

  @override
  String get browserHomeTitle => 'Page d\'accueil';

  @override
  String get browserHomeDescription =>
      'Où démarre le navigateur de Fern quand tu appuies sur le bouton d\'accueil. Cela ne décide pas de son ouverture : en revenant sur l\'écran, le navigateur reste sur la dernière page visitée.';

  @override
  String get browserHomeLabel => 'Adresse';

  @override
  String credentialsRejectedTitle(String source) {
    return '$source n\'a pas accepté tes identifiants';
  }

  @override
  String credentialsRejectedDescription(String source) {
    return 'Rien n\'a pu être importé : $source a rejeté le compte ou la clé qu\'on lui donnait. Vérifie-les dans Réglages, dans Sources distantes.';
  }

  @override
  String get actionOpenRemoteSettings => 'Ouvrir les réglages';

  @override
  String sessionExpiredTitle(String source) {
    return 'La session $source n\'est plus valable';
  }

  @override
  String sessionExpiredDescription(String source) {
    return 'Rien n\'a pu être importé : $source a rejeté la session enregistrée. Reconnecte-toi dans le navigateur et appuie là-bas sur le bouton de la clé pour enregistrer la nouvelle.';
  }

  @override
  String browserImportedInto(int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus prêts à être revus dans $source',
      one: '1 contenu prêt à être revu dans $source',
    );
    return '$_temp0';
  }

  @override
  String browserImportKnown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étaient déjà dans la bibliothèque',
      one: '1 était déjà dans la bibliothèque',
    );
    return '$_temp0';
  }

  @override
  String browserImportFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count n\'ont pas pu être téléchargés',
      one: '1 n\'a pas pu être téléchargé',
    );
    return '$_temp0';
  }

  @override
  String get browserImportNothing => 'Rien n\'a été apporté.';

  @override
  String get danbooruTitle => 'Danbooru';

  @override
  String get danbooruDescription =>
      'Fern télécharge les publications que tu as mises en favoris sur Danbooru. Son API est publique : il suffit du nom de ton compte et d\'une clé d\'API.';

  @override
  String get danbooruUsername => 'Nom du compte';

  @override
  String get danbooruUsernameHint => 'Ton nom d\'utilisateur sur Danbooru';

  @override
  String get danbooruApiKey => 'Clé d\'API';

  @override
  String get danbooruApiKeyHint => 'Une clé de ton profil Danbooru';

  @override
  String get danbooruApiKeyNote =>
      'Sur Danbooru, ouvre ton profil, va dans API Key et crées-en une. Ce n\'est pas ton mot de passe : tu peux la révoquer quand tu veux sans rien changer d\'autre. Elle reste sur cet ordinateur et ne sert qu\'à parler à Danbooru.';

  @override
  String get gelbooruTitle => 'Gelbooru';

  @override
  String get gelbooruDescription =>
      'Fern télécharge les publications que tu as mises en favoris sur Gelbooru. Son API de favoris est plus lente que les autres : elle donne des références au lieu des publications, il faut donc demander chacune séparément.';

  @override
  String get gelbooruUserId => 'Identifiant du compte';

  @override
  String get gelbooruUserIdHint => 'Le numéro de ton compte Gelbooru';

  @override
  String get gelbooruApiKey => 'Clé d\'API';

  @override
  String get gelbooruApiKeyHint => 'La clé de ce compte';

  @override
  String get gelbooruApiKeyNote =>
      'Sur Gelbooru, va dans My Account, puis Options, et cherche API Access Credentials : l\'identifiant et la clé y sont. Ils restent sur cet ordinateur et ne servent qu\'à parler à Gelbooru.';

  @override
  String get pinterestTitle => 'Pinterest';

  @override
  String get pinterestDescription =>
      'Fern télécharge ce que tu as enregistré sur Pinterest. Pour ce qui est dans des tableaux publics, il ne faut rien de plus que le nom de ton compte.';

  @override
  String get pinterestUsername => 'Nom du compte';

  @override
  String get pinterestUsernameHint => 'Ton nom d\'utilisateur sur Pinterest';

  @override
  String get pinterestSecretBoardsNote =>
      'Pour récupérer aussi ce que tu gardes dans des tableaux secrets, connecte-toi à Pinterest depuis le navigateur de Fern et appuie là-bas sur le bouton de la clé : la session est enregistrée à côté du nom.';

  @override
  String get pawchiveTitle => 'Pawchive';

  @override
  String get pawchiveDescription =>
      'Fern télécharge les publications que tu as mises en favoris sur Pawchive. Il n\'y a rien à remplir ici : connecte-toi depuis le navigateur de Fern et appuie là-bas sur le bouton de la clé, et la session est enregistrée toute seule.';

  @override
  String linkChoiceTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette publication contient $count liens',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceUntitledPost => 'Publication sans titre';

  @override
  String get linkChoiceApplyToAll => 'Appliquer au reste de l\'importation';

  @override
  String get linkChoiceApplyToAllDescription =>
      'La même réponse est utilisée pour toutes les publications restantes, sans redemander.';

  @override
  String get linkChoiceIgnore => 'Ignorer la publication';

  @override
  String linkChoiceSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Télécharger $count',
      zero: 'Télécharger la sélection',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceAll => 'Tout télécharger';

  @override
  String get linkChoiceOpen => 'Voir dans le navigateur';

  @override
  String repositoryLinkTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette publication mène à $count hébergeurs de fichiers',
      one: 'Cette publication mène à un hébergeur de fichiers',
    );
    return '$_temp0';
  }

  @override
  String get repositoryLinkDescription =>
      'Fern ne peut pas les parcourir tout seul : ce sont des pages avec leurs propres attentes et vérifications. Tu peux les ouvrir dans le navigateur de Fern et en rapporter ce que tu veux. L\'importation continue pendant ce temps.';

  @override
  String get repositoryLinkOpen => 'Voir dans le navigateur';

  @override
  String get pawchiveByCreators => 'Importer par créateurs favoris';

  @override
  String get pawchiveByCreatorsDescription =>
      'Au lieu des publications que tu as mises en favoris, Fern parcourt tout ce que publient les créateurs que tu suis. Cela rapporte beaucoup plus, et chaque créateur est suivi séparément.';

  @override
  String get remoteImportHeavyWarning =>
      'Cela peut prendre un bon moment : sans limite, Fern parcourt tout le compte et rapporte tout, y compris les fichiers contenus dans les publications. Tu peux l\'arrêter quand tu veux depuis l\'écran d\'importation, et ce qui est déjà arrivé reste.';

  @override
  String emptySource(String source) {
    return 'Il n\'y avait rien à rapporter de $source.';
  }

  @override
  String get emptySourcePawchiveCreators =>
      'Tu n\'as aucune publication en favori sur Pawchive, mais tu as des créateurs favoris. Active « Importer par créateurs favoris » dans Réglages, sous Sources distantes, et Fern parcourra tout ce qu\'ils publient.';

  @override
  String get browserAddressHint => 'Adresse d\'un site';

  @override
  String get browserBack => 'Retour';

  @override
  String get browserForward => 'Suivant';

  @override
  String get browserReload => 'Recharger';

  @override
  String get browserSaveSessionHint =>
      'Enregistrer la session de ce site pour pouvoir en importer';

  @override
  String get browserFindMediaHint => 'Chercher du contenu sur cette page';

  @override
  String browserImportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count',
      one: 'Importer 1',
    );
    return '$_temp0';
  }

  @override
  String get browserSelectAll => 'Tout cocher ou décocher';

  @override
  String get browserClose => 'Fermer';

  @override
  String get browserNoSession =>
      'Fern ne peut pas importer depuis ce site, il n\'y a donc aucune session à enregistrer ici.';

  @override
  String browserSessionSaved(String source) {
    return 'Session $source enregistrée.';
  }

  @override
  String browserSessionMissing(String source) {
    return 'Il n\'y a pas encore de session $source ici : connecte-toi d\'abord.';
  }

  @override
  String get browserNothingFound => 'Aucun contenu trouvé sur cette page.';

  @override
  String browserFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus trouvés',
      one: '1 contenu trouvé',
    );
    return '$_temp0';
  }

  @override
  String browserImporting(int done, int total) {
    return 'Téléchargement de $done sur $total…';
  }

  @override
  String importFailed(String error) {
    return 'L\'importation n\'a pas pu être terminée : $error';
  }

  @override
  String get importLimitAll => 'Tous';

  @override
  String get importLimitSinceLast => 'Nouveaux';

  @override
  String get importLimitSinceLastTooltip =>
      'Seulement ce qui a été enregistré depuis le dernier import';

  @override
  String get importLimitTooltip => 'Nombre maximum d\'éléments par analyse';

  @override
  String get lastImportNever => 'Jamais importé';

  @override
  String get sourceNotConfiguredHint =>
      'Configure cette source dans les réglages avant d\'importer';

  @override
  String get lastImportHint => 'Dernière fois que cette source a été consultée';

  @override
  String lastImportMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count min',
      one: 'Il y a 1 min',
      zero: 'Tout juste',
    );
    return '$_temp0';
  }

  @override
  String lastImportHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count h',
      one: 'Il y a 1 h',
    );
    return '$_temp0';
  }

  @override
  String lastImportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get assignUrlsTitle => 'Adresses liées';

  @override
  String assignUrlsTo(String name) {
    return 'Adresses liées à $name';
  }

  @override
  String get assignUrlsDescription =>
      'Ce qui est importé depuis ces adresses reçoit cette étiquette tout seul, sans rien demander à la plateforme.';

  @override
  String get assignUrlsTooltip => 'Lier des adresses à cette étiquette';

  @override
  String get assignUrlsCreatorDescription =>
      'Ce qui est importé depuis ces adresses reçoit ce créateur tout seul, sans rien demander à la plateforme.';

  @override
  String get assignUrlsCreatorTooltip => 'Lier des adresses à ce créateur';

  @override
  String get sourceUrlsLabel => 'Adresses';

  @override
  String get sourceUrlHint => 'reddit.com/r/exemple';

  @override
  String get addSourceUrl => 'Ajouter une adresse';

  @override
  String get filtersSource => 'Afficher le contenu de';

  @override
  String get sourceLocal => 'Cet ordinateur';

  @override
  String get autoTagRemoteSource => 'Étiqueter la source distante';

  @override
  String get autoTagRemoteSourceDescription =>
      'Fern crée une étiquette par plateforme (Reddit, et les suivantes) et la pose sur ce qu\'il en importe. Désactivé, la source est quand même enregistrée et se filtre depuis le bouton Filtres.';

  @override
  String get startupFailedTitle => 'Fern n\'a pas pu démarrer';

  @override
  String get startupFailedDatabase =>
      'La base de données n\'a pas pu être mise à jour vers ce que cette version attend.';

  @override
  String get startupFailedHint =>
      'Rien n\'est perdu : votre contenu est toujours là. Fermez Fern et rouvrez-le ; si cela continue, le détail ci-dessous indique ce qui a échoué.';

  @override
  String get settingsRecognition => 'Reconnaissance';

  @override
  String get recognitionFolderTitle => 'Données de reconnaissance';

  @override
  String get recognitionFolderDescription =>
      'Là où Fern garde tout ce qu\'il lui faut pour reconnaître votre contenu : l\'environnement d\'entraînement, les modèles entraînés et les jeux de données qu\'il prépare pour les entraîner. Cela peut prendre plusieurs gigas, vous préférerez peut-être un autre disque.';

  @override
  String get recognitionFolder => 'Dossier de reconnaissance';

  @override
  String recognitionFolderMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers déplacés vers le nouveau dossier',
      one: '1 fichier déplacé vers le nouveau dossier',
      zero: 'Le dossier y était déjà',
    );
    return '$_temp0';
  }

  @override
  String get recognitionFolderMoveFailed =>
      'Les données de reconnaissance n\'ont pas pu être déplacées';

  @override
  String get jobsTooltip => 'Tâches en cours';

  @override
  String get jobsTitle => 'Tâches en arrière-plan';

  @override
  String get jobsEmpty => 'Rien en cours pour le moment';

  @override
  String get jobCancelTooltip => 'Annuler cette tâche';

  @override
  String jobProgress(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get jobQueued => 'En attente';

  @override
  String get jobFailed => 'Échec';

  @override
  String get jobTraining => 'Entraînement du modèle';

  @override
  String get jobRecognition => 'Reconnaissance du contenu';

  @override
  String get jobDuplicateScan => 'Recherche de contenu en double';

  @override
  String get jobHashing => 'Lecture du contenu';

  @override
  String get settingsNotifications => 'Alertes';

  @override
  String get notificationsTitle => 'Alertes';

  @override
  String get notificationsDescription =>
      'Entraîner un modèle, reconnaître un lot ou chercher du contenu en double peut prendre un bon moment. Fern vous prévient quand c\'est fini, pour ne pas avoir à surveiller.';

  @override
  String get notificationsEnabled => 'Me prévenir';

  @override
  String get notificationsEnabledDescription =>
      'Désactivé, rien n\'est compté et rien ne sonne. Ce qui était en attente reste noté et réapparaît si vous réactivez.';

  @override
  String get notificationsMuted => 'Silence';

  @override
  String get notificationsMutedDescription =>
      'Les compteurs restent, les sons non.';

  @override
  String get notificationsSoundTitle => 'Son';

  @override
  String get notificationsVolume => 'Volume';

  @override
  String get notificationsMaxSeconds => 'Jouer au plus';

  @override
  String notificationsSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get notificationsMaxSecondsDescription =>
      'Une alerte est un son bref. Si l\'audio choisi dure plus longtemps, Fern l\'arrête ici au lieu de le jouer en entier. Votre fichier n\'est pas modifié.';

  @override
  String get notificationsEventsTitle => 'Quoi signaler';

  @override
  String get notificationsEventsDescription =>
      'Pour chacun : compteur dans le menu latéral, et son.';

  @override
  String get notificationsBadge => 'Compteur';

  @override
  String get notificationsSound => 'Son';

  @override
  String get notificationsDefaultSound => 'Son de Fern';

  @override
  String get notificationsPreview => 'Écouter';

  @override
  String get notificationsChooseSound => 'Choisir un audio';

  @override
  String get notificationsResetSound => 'Revenir au son de Fern';

  @override
  String get notifyDuplicates => 'Contenu en double trouvé';

  @override
  String get notifyTraining => 'Entraînement du modèle terminé';

  @override
  String get notifyRecognition => 'Reconnaissance par lot terminée';

  @override
  String get notifyRemoteImport => 'Import distant terminé';

  @override
  String get sidecarTitle => 'Moteur de reconnaissance';

  @override
  String get sidecarDescription =>
      'Pour entraîner et reconnaître, Fern installe son propre environnement Python dans le dossier de reconnaissance. Il ne touche pas à votre système et vous n\'avez pas besoin d\'avoir Python au préalable : il apporte le sien. Cela occupe environ 1,2 Go sur le disque et n\'est téléchargé que si vous le demandez.';

  @override
  String get sidecarUnsupportedPlatform =>
      'La reconnaissance n\'est pas encore disponible sur ce système.';

  @override
  String get sidecarNotInstalled => 'Pas encore installé';

  @override
  String get sidecarDownloadingUv => 'Téléchargement de l\'installeur';

  @override
  String get sidecarInstallingPython => 'Installation de Python';

  @override
  String get sidecarCreatingVenv => 'Préparation de l\'environnement';

  @override
  String get sidecarDetectingHardware => 'Analyse de votre matériel';

  @override
  String get sidecarInstallingTorch => 'Téléchargement du moteur';

  @override
  String get sidecarInstallingUltralytics => 'Installation de YOLO';

  @override
  String get sidecarCleaning => 'Nettoyage';

  @override
  String get sidecarVerifying => 'Vérification';

  @override
  String get sidecarReady => 'Prêt à entraîner et reconnaître';

  @override
  String get sidecarError => 'Quelque chose s\'est mal passé';

  @override
  String sidecarDownloaded(String received, String total) {
    return '$received Mo sur $total Mo';
  }

  @override
  String get sidecarInstall => 'Installer';

  @override
  String get sidecarReinstall => 'Réinstaller';

  @override
  String get sidecarEnableGpu => 'Utiliser la carte graphique';

  @override
  String get sidecarUninstall => 'Désinstaller';

  @override
  String get sidecarShowLog => 'Voir les détails';

  @override
  String get sidecarHideLog => 'Masquer les détails';

  @override
  String get sidecarFailureInUse =>
      'Les fichiers du moteur sont en cours d\'utilisation';

  @override
  String get sidecarFailureInUseHint =>
      'Quelque chose les garde ouverts, ils ne peuvent donc pas être remplacés. Fermez complètement Fern, rouvrez-le et appuyez sur Installer. Si cela persiste, redémarrez l\'ordinateur : cela les libère toujours.';

  @override
  String get sidecarFailureSpace => 'Il n\'y a plus de place sur le disque';

  @override
  String get sidecarFailureSpaceHint =>
      'Le moteur a besoin d\'environ 1,5 Go libres, en comptant ce qu\'il utilise pendant l\'installation. Libérez de l\'espace, ou déplacez le dossier de reconnaissance vers un autre disque depuis le champ ci-dessus.';

  @override
  String get sidecarFailureNetwork => 'Le téléchargement n\'a pas pu aboutir';

  @override
  String get sidecarFailureNetworkHint =>
      'Vérifiez votre connexion internet et appuyez de nouveau sur Installer. Ce qui était déjà téléchargé est conservé, la reprise se fait là où elle s\'était arrêtée.';

  @override
  String get sidecarFailureBlocked =>
      'Le système n\'a pas laissé Fern lancer l\'installeur';

  @override
  String get sidecarFailureBlockedHint =>
      'C\'est en général l\'antivirus, qui bloque les programmes fraîchement téléchargés. Autorisez Fern dans votre antivirus, ou choisissez un dossier de reconnaissance dans votre dossier utilisateur, puis réessayez.';

  @override
  String get sidecarFailureMissing => 'Il manque quelque chose au moteur';

  @override
  String get sidecarFailureMissingHint =>
      'L\'installation est restée à moitié faite. Appuyez sur Désinstaller pour la nettoyer, puis sur Installer.';

  @override
  String get sidecarFailureUnknown => 'Le moteur n\'a pas pu être installé';

  @override
  String get sidecarFailureUnknownHint =>
      'Appuyez sur Installer pour réessayer. Si cela échoue encore, ouvrez les détails ci-dessous : ils indiquent exactement l\'étape qui a échoué.';

  @override
  String get sidecarInstallCpu => 'Installer pour le processeur';

  @override
  String get sidecarInstallGpu => 'Installer pour la carte graphique';

  @override
  String get sidecarEnableCpu => 'Revenir au processeur';

  @override
  String sidecarPercent(int percent) {
    return '$percent %';
  }

  @override
  String get sidecarBusyDownloading => 'Téléchargement des paquets...';

  @override
  String get sidecarBusyUnpacking => 'Décompression de ce qui arrive...';

  @override
  String get sidecarBusyPatience => 'Cette étape prend quelques minutes.';

  @override
  String get sidecarBusySettling => 'Mise en place...';

  @override
  String get sidecarBusyKeepUsing =>
      'Vous pouvez continuer à utiliser Fern pendant ce temps.';

  @override
  String get gpuDialogTitle => 'Installer la version carte graphique ?';

  @override
  String get gpuDialogBenefit =>
      'L\'entraînement est bien plus rapide : ce qui prend des heures sur le processeur peut prendre des minutes sur la carte graphique.';

  @override
  String get gpuDialogTime =>
      'Le téléchargement fait environ 2,5 Go : sur une connexion normale, cela peut prendre un bon moment.';

  @override
  String get gpuDialogSize =>
      'Cela occupe environ 5 Go sur le disque, au lieu des 1,2 Go de la version processeur.';

  @override
  String get gpuDialogReversible =>
      'Vous pourrez revenir à la version processeur quand vous voudrez, sans tout réinstaller.';

  @override
  String get gpuDialogConfirm => 'L\'installer';

  @override
  String get navRecognition => 'Reconnaissance';

  @override
  String get navFernies => 'Fernies';

  @override
  String get navRepeatedMedia => 'Contenu en double';

  @override
  String get navModels => 'Modèles';

  @override
  String get menuNewFernie => 'Nouveau fernie';

  @override
  String get newFernieTitle => 'Nouveau fernie';

  @override
  String get fernieNameLabel => 'Nom du fernie';

  @override
  String get ferniesTitle => 'Fernies';

  @override
  String get addFernie => 'Ajouter un fernie';

  @override
  String get noFerniesYet => 'Aucun fernie pour l’instant';

  @override
  String get fernieNoRegions => 'Ce fernie n’a encore aucune région';

  @override
  String get fernieNoneHere => 'Aucun fernie marqué ici pour l’instant';

  @override
  String get fernieLinkLabel => 'Il propose';

  @override
  String get fernieLinkNone => 'Rien';

  @override
  String get fernieLinkTag => 'Une étiquette';

  @override
  String get fernieLinkCreator => 'Un créateur';

  @override
  String get fernieLinkNoneHint =>
      'Il ne fait qu’entraîner : seul, il n’étiquette rien';

  @override
  String get fernieLinkMissing => 'Ce à quoi il était lié n’existe plus';

  @override
  String get fernieFewRegions =>
      'Trop peu de régions pour entraîner de façon fiable';

  @override
  String get fernieLowVariety =>
      'Peu de variété : le modèle apprendra le fond, pas l’objet';

  @override
  String get fernieRegionPending =>
      'Contenu en attente de révision : cette région ne servira pas à l’entraînement tant qu’il n’est pas enregistré';

  @override
  String get fernieRegionTiny =>
      'Région très petite : elle peut n’apporter rien à l’entraînement';

  @override
  String get actionDeleteFernie => 'Supprimer le fernie';

  @override
  String get actionRemoveLink => 'Retirer le lien';

  @override
  String get actionDeleteRegions => 'Supprimer les régions';

  @override
  String get fernieToolSelect => 'Marquer des régions';

  @override
  String get fernieToolEdit => 'Modifier des régions';

  @override
  String get fernieRegionConfirm =>
      'Enregistrer les modifications de cette région';

  @override
  String get fernieRegionCancel =>
      'Abandonner les modifications de cette région';

  @override
  String get fernieRegionDelete => 'Supprimer cette région';

  @override
  String get fernieRegionDeleteTitle => 'Supprimer cette région ?';

  @override
  String get fernieRegionDeleteMessage =>
      'La région quitte son fernie. Si c’était la seule de ce fernie dans ce contenu, le fernie n’y sera plus marqué.';

  @override
  String get fernieRegionDiscardTitle =>
      'Abandonner les modifications de la région ?';

  @override
  String get fernieRegionDiscardMessage =>
      'Ce que vous avez changé dans la région sélectionnée ne sera pas enregistré.';

  @override
  String get fernieTimelinePlay => 'Lire pour vérifier les régions marquées';

  @override
  String get fernieTimelinePause => 'Arrêter';

  @override
  String get fernieFramePrevious => 'Image précédente';

  @override
  String get fernieFrameNext => 'Image suivante';

  @override
  String get fernieOnionSkin =>
      'Pelure d’oignon : voir l’image marquée précédente';

  @override
  String get fernieDragRegions =>
      'Faire glisser la région sur toutes les images intermédiaires';

  @override
  String get fernieModeTooltip => 'Marquer des régions';

  @override
  String get fernieModeAccept => 'Enregistrer les régions';

  @override
  String get fernieModeCancel => 'Abandonner les régions';

  @override
  String get fernieModeHint =>
      'Faites glisser sur le contenu pour marquer une région. Maintenez espace ou le bouton du milieu pour déplacer.';

  @override
  String get fernieDiscardTitle => 'Abandonner ce qui est marqué ?';

  @override
  String get fernieDiscardMessage =>
      'Les régions marquées pendant cette session seront perdues.';

  @override
  String get actionDiscard => 'Abandonner';

  @override
  String get assignRegionTitle => 'Assigner la région';

  @override
  String get searchFernieHint => 'Chercher un fernie...';

  @override
  String get createFernie => 'Créer un fernie';

  @override
  String fernieRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count régions',
      one: '1 région',
      zero: 'Aucune région',
    );
    return '$_temp0';
  }

  @override
  String fernieMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count contenus',
      one: 'dans 1 contenu',
      zero: 'dans aucun contenu',
    );
    return '$_temp0';
  }

  @override
  String fernieRecommendedRegions(int count) {
    return 'Au moins $count régions sont recommandées';
  }

  @override
  String get viewerRecognize => 'Reconnaître avec les modèles';

  @override
  String get viewerRecognizing => 'Reconnaissance en cours…';

  @override
  String get viewerRecognizeQueued => 'Reconnaissance en file d\'attente';

  @override
  String get suggestionsTitle => 'Suggestions';

  @override
  String suggestionConfidence(int percent) {
    return '$percent %';
  }

  @override
  String get suggestionFromModel =>
      'Proposé par un modèle, pas encore confirmé';

  @override
  String get suggestionCreatorTitle => 'Créateur proposé';

  @override
  String get suggestionsNone => 'Rien de proposé ici';

  @override
  String get actionAccept => 'Accepter';

  @override
  String get actionReject => 'Refuser';

  @override
  String get suggestionAcceptAll => 'Tout accepter';

  @override
  String get suggestionRejectAll => 'Tout refuser';

  @override
  String get recognizeNoModelsInTree =>
      'Il n\'y a encore aucun modèle dans l\'arbre. Ajoutez-en un depuis l\'écran de l\'arbre de modèles.';

  @override
  String get recognizeNoTrainedModels =>
      'Aucun modèle de l\'arbre n\'est entraîné. Entraînez-en un, ou importez ses poids depuis l\'écran du modèle.';

  @override
  String get recognizeUnavailable => 'L\'arbre de modèles n\'a pas pu être lu.';

  @override
  String get recognizeFoundNothing => 'Les modèles n\'ont rien trouvé ici';

  @override
  String get recognizeNothingToDo => 'Il ne reste rien à reconnaître ici';

  @override
  String get recognizeSelectedTooltip => 'Reconnaître la sélection';

  @override
  String get recognizeTagTooltip => 'Reconnaître tout ce qui porte ce tag';

  @override
  String get recognizeCreatorTooltip => 'Reconnaître tout de ce créateur';

  @override
  String get recognizeLibrary => 'Reconnaître la bibliothèque';

  @override
  String get recognizeLibraryTitle => 'Reconnaître toute la bibliothèque';

  @override
  String get recognizeLibraryQuestion =>
      'Reconnaître coûte une prédiction par image, et plusieurs par vidéo. Choisissez l\'étendue.';

  @override
  String get recognizeLibraryOnlyNew =>
      'Seulement ce qui n\'a jamais été examiné';

  @override
  String get recognizeLibraryAll => 'Tout, à nouveau';

  @override
  String get recognizeLibraryAllHint =>
      'Utile après avoir entraîné un meilleur modèle.';

  @override
  String get recognizeJobLibrary => 'Bibliothèque entière';

  @override
  String get recognizeJobSelection => 'Sélection';

  @override
  String recognizeQueuedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments en file pour la reconnaissance',
      one: '1 élément en file pour la reconnaissance',
      zero: 'Rien mis en file',
    );
    return '$_temp0';
  }

  @override
  String recognizeCountable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get recognitionLogTitle => 'Ce qu\'ont fait les modèles';

  @override
  String get recognitionLogNearMiss => 'vu, sous le seuil';

  @override
  String get recognitionLogNothing => 'rien';

  @override
  String get recognitionLogVerdictProposed => 'le propose';

  @override
  String recognitionLogVerdictBelow(int percent) {
    return 'vu, mais sous les $percent %';
  }

  @override
  String get recognitionLogVerdictNothing => 'n\'a rien vu';

  @override
  String get recognitionLogVerdictNotReached =>
      'n\'a pas tourné : sa branche ne s\'est pas ouverte';

  @override
  String get recognitionLogVerdictUntrained =>
      'n\'a pas tourné : il n\'a pas de poids';

  @override
  String get jobDetailTooltip => 'Voir ce qu\'ont fait les modèles';

  @override
  String get jobsClearFinished => 'Marquer les terminées comme vues';

  @override
  String get recognitionLogFromToast =>
      'Touchez pour voir ce qu\'ont fait les modèles';

  @override
  String recognitionLogSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: 'Un élément',
    );
    return '$_temp0';
  }

  @override
  String recognitionLogProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions',
      one: '1 suggestion',
    );
    return '$_temp0';
  }

  @override
  String get jobDone => 'Terminée';

  @override
  String recognizeFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions. Touchez pour voir comment',
      one: '1 suggestion. Touchez pour voir comment',
    );
    return '$_temp0';
  }

  @override
  String get recognitionPanelTitle => 'À la reconnaissance';

  @override
  String get recognitionThresholdLabel => 'Confiance minimale pour proposer';

  @override
  String get recognitionThresholdDescription =>
      'En dessous, ce qu\'il voit n\'est pas proposé.';

  @override
  String get recognitionThresholdEverything =>
      'Tout ce qu\'il voit est proposé, même sans certitude.';

  @override
  String get recognitionThresholdAll => 'Tout';

  @override
  String get recognitionThresholdLower => 'Baisser le seuil';

  @override
  String get recognitionThresholdRaise => 'Relever le seuil';

  @override
  String get recognitionThresholdApplies =>
      'S\'applique à la prochaine reconnaissance. Ce qui est déjà proposé ne change pas.';

  @override
  String get recognizeReturnTitle => 'Ils quitteront la bibliothèque un moment';

  @override
  String get recognizeReturnHint =>
      'Seulement ceux qui reçoivent une suggestion. Désactivable dans Réglages, section Reconnaissance.';

  @override
  String get recognizeReturnConfirm => 'Reconnaître quand même';

  @override
  String get returnRecognizedLabel =>
      'Renvoyer le contenu reconnu vers l\'importation';

  @override
  String get returnRecognizedDescription =>
      'Ce qui reçoit une suggestion cesse d\'être définitif jusqu\'à validation. Désactivé, les suggestions restent visibles dans le panneau et rien ne bouge.';

  @override
  String recognizeReturnWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count éléments retourneront à l\'écran d\'importation jusqu\'à ce que vous validiez leurs tags.',
      one:
          'Un élément retournera à l\'écran d\'importation jusqu\'à ce que vous validiez ses tags.',
    );
    return '$_temp0';
  }

  @override
  String get suggestionsPendingBadge => 'A des suggestions en attente';

  @override
  String get suggestionFilterAll => 'Tout';

  @override
  String get suggestionFilterWith => 'Avec suggestions';

  @override
  String get suggestionFilterNever => 'Jamais examiné';

  @override
  String acceptAboveTooltip(int percent) {
    return 'Accepte ce dont les modèles sont sûrs à plus de $percent %, dans la sélection. Ne valide rien.';
  }

  @override
  String acceptAboveDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions acceptées',
      one: '1 suggestion acceptée',
      zero: 'Rien n\'était assez sûr',
    );
    return '$_temp0';
  }

  @override
  String get actionClearSelection => 'Quitter la sélection';

  @override
  String acceptAboveLabel(int percent) {
    return 'Accepter au-delà de $percent %';
  }

  @override
  String get importShowLabel => 'Afficher';

  @override
  String get importFetchLabel => 'Récupérer';

  @override
  String get recognizeJobImported => 'Tout juste importé';

  @override
  String get recognizeOnImportLabel =>
      'Reconnaître ce qui vient d\'être importé';

  @override
  String get recognizeOnImportDescription =>
      'Le nouveau contenu passe par les modèles tout seul, une fois l\'import calmé. Ne coûte rien si aucun modèle n\'est entraîné.';

  @override
  String get suggestionMarkRegion => 'Enregistrer comme région de ce fernie';

  @override
  String get suggestionRegionSaved =>
      'Région enregistrée. Elle compte pour le prochain entraînement.';

  @override
  String get suggestionRegionFailed => 'La région n\'a pas pu être enregistrée';

  @override
  String get duplicatesScanNow => 'Chercher maintenant';

  @override
  String get duplicatesScanning => 'Recherche de doublons';

  @override
  String get duplicatesQueued =>
      'Recherche de contenu en double. La première fois peut prendre un moment.';

  @override
  String get duplicatesNone => 'Aucun contenu en double';

  @override
  String get duplicatesNoneHint =>
      'Relancez après un import, ou baissez le seuil de ressemblance dans les Réglages.';

  @override
  String get duplicatesNeverScanned => 'Rien n\'a encore été analysé';

  @override
  String get duplicatesNeverScannedHint =>
      'Appuyez sur « Chercher maintenant » et Fern parcourt toute la bibliothèque. La première fois peut prendre un moment.';

  @override
  String duplicatesScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recherche terminée : $count nouveaux groupes',
      one: 'Recherche terminée : 1 nouveau groupe',
    );
    return '$_temp0';
  }

  @override
  String duplicatesScanNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Recherche terminée : rien de nouveau. $count groupes restent à revoir.',
      one: 'Recherche terminée : rien de nouveau. 1 groupe reste à revoir.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesScanClean =>
      'Recherche terminée : aucun contenu en double.';

  @override
  String get duplicatesScanStopped =>
      'Recherche arrêtée. Les empreintes déjà calculées restent faites.';

  @override
  String get duplicatesScanFailed =>
      'La recherche n\'a pas pu aboutir. Réessayez.';

  @override
  String duplicatesGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
    );
    return '$_temp0';
  }

  @override
  String duplicatesDistance(int distance) {
    return 'distance $distance';
  }

  @override
  String get duplicatesIdentical => 'identique';

  @override
  String duplicatesCopyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copies',
      one: '1 copie',
    );
    return '$_temp0';
  }

  @override
  String duplicatesGroupPosition(int position, int total) {
    return 'Groupe $position sur $total';
  }

  @override
  String get duplicatesKeepThis => 'Garder celle-ci';

  @override
  String get duplicatesMergeMetadata =>
      'Fusionner les métadonnées dans la copie conservée';

  @override
  String get duplicatesMergeMetadataHint =>
      'Étiquettes, créateur, favori et description des copies écartées.';

  @override
  String get duplicatesNotDuplicates => 'Pas des doublons';

  @override
  String get duplicatesApplyAndNext => 'Appliquer et suivant';

  @override
  String duplicatesTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étiquettes',
      one: '1 étiquette',
      zero: 'Aucune étiquette',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesFavorite => 'Favori';

  @override
  String get duplicatesNoCreator => 'Sans créateur';

  @override
  String get duplicatesUnknownSize => 'Taille inconnue';

  @override
  String get duplicatesPickGroup =>
      'Choisis un groupe pour comparer ses copies';

  @override
  String get duplicatesApplyFailed =>
      'Le groupe n\'a pas pu être résolu. Rien n\'a été supprimé.';

  @override
  String get settingsDuplicates => 'Contenu répété';

  @override
  String get duplicatesScanSectionTitle => 'Recherche automatique';

  @override
  String get duplicatesScanSectionNote =>
      'Le contenu répété ne gêne pas le jour où il arrive ; il gêne des mois plus tard, quand il y a quarante copies et que personne ne pense à regarder.';

  @override
  String get duplicatesAutoScanLabel =>
      'Laisser Fern chercher les doublons tout seul';

  @override
  String get duplicatesAutoScanDescription =>
      'À l\'ouverture de Fern, si le délai choisi ci-dessous est écoulé, il parcourt toute la bibliothèque sans que vous le demandiez : il s\'exécute en arrière-plan avec la priorité la plus basse, sans jamais gêner ce que vous faites, et il ne vous prévient que s\'il trouve quelque chose. Désactivé, les doublons ne sont cherchés que lorsque vous appuyez sur « Chercher maintenant » dans Contenu en double.';

  @override
  String get duplicatesScanPeriodLabel => 'À quelle fréquence';

  @override
  String get duplicatesMovingLabel => 'Regarder aussi les vidéos et les GIF';

  @override
  String get duplicatesMovingDescription =>
      'D\'une vidéo, c\'est l\'image à 10 % de sa durée qui est comparée, pas la première : les vidéos commencent sur du noir ou sur un générique, et cela seul en regrouperait trois qui n\'ont rien à voir. Cela coûte bien plus qu\'une image, donc une bibliothèque pleine de vidéos allonge beaucoup la première analyse. Ce qui a déjà été calculé continue d\'être comparé même si vous désactivez ceci.';

  @override
  String get duplicatesPeriodMonthly => 'Tous les mois';

  @override
  String get duplicatesPeriodQuarterly => 'Tous les trois mois';

  @override
  String get duplicatesPeriodBiannual => 'Tous les six mois';

  @override
  String get duplicatesPeriodYearly => 'Tous les ans';

  @override
  String duplicatesLastScan(String date) {
    return 'Dernière analyse : $date';
  }

  @override
  String get duplicatesLastScanNever => 'Jamais analysé jusqu\'ici';

  @override
  String get duplicatesOpenViewer => 'Voir en plein écran';

  @override
  String get duplicatesThresholdSectionTitle => 'Seuil de similarité';

  @override
  String get duplicatesThresholdSectionNote =>
      'À quel point deux contenus peuvent différer tout en comptant pour le même. L\'augmenter regroupe davantage et commence à réunir des choses qui se ressemblent seulement ; le baisser laisse des répétitions non trouvées. Il s\'applique à la prochaine analyse, pas à ce qui est déjà regroupé.';

  @override
  String get duplicatesThresholdLabel => 'Seuil';

  @override
  String get duplicatesRehashSectionTitle => 'Repartir de zéro';

  @override
  String get duplicatesRehashSectionNote =>
      'Jette toutes les empreintes et les recalcule à la prochaine analyse. C\'est la sortie de secours quand le regroupement se passe mal sans qu\'on sache pourquoi. Les groupes déjà traités restent tels quels.';

  @override
  String get duplicatesRehashButton => 'Recalculer toutes les empreintes';

  @override
  String get duplicatesRehashRunning => 'Suppression des empreintes';

  @override
  String duplicatesRehashDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count empreintes supprimées. Elles seront recalculées à la prochaine analyse.',
      one:
          '1 empreinte supprimée. Elle sera recalculée à la prochaine analyse.',
      zero: 'Il n\'y avait rien à supprimer',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesRehashFailed =>
      'Les empreintes n\'ont pas pu être supprimées.';
}
