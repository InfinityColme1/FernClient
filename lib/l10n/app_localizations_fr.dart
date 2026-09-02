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
  String get actionClose => 'Fermer';

  @override
  String get actionClearSearch => 'Vider la recherche';

  @override
  String get actionDecrease => 'Diminuer';

  @override
  String get actionIncrease => 'Augmenter';

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
  String get viewerReturnToMedia => 'Revenir là où vous regardiez';

  @override
  String get viewerReturnToMediaDescription =>
      'En quittant la visionneuse, la grille se place sur le contenu que vous venez de voir au lieu de rester où vous l\'aviez laissée.';

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
  String get trainingCancelling => 'Arrêt à la fin de cette époque…';

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
  String get modelImportWeightsHint =>
      'Un fichier .pt entraîné ailleurs. Il est copié dans le dossier de reconnaissance pour qu’il ne disparaisse pas sous le modèle.';

  @override
  String get modelForgetTrainingHint => 'Oublier l\'entraînement';

  @override
  String modelForgetTrainingTitle(String model) {
    return 'Oublier ce que $model a appris ?';
  }

  @override
  String get modelForgetTrainingLoses =>
      'Les poids, les métriques et la date de l\'entraînement s\'en vont, fichiers compris. Le réentraîner coûte ce qu\'il a coûté la première fois.';

  @override
  String get modelForgetTrainingKeeps =>
      'Les hyperparamètres, les fernies et la répartition restent tels quels. Le modèle redevient non entraîné et garde sa place dans l\'arbre.';

  @override
  String get modelForgetTrainingAction => 'Oublier';

  @override
  String get modelForgetTrainingDone => 'Il ne reste rien de cet entraînement.';

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
  String get jobsNone => 'Aucune tâche';

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
  String get actionRevealInExplorer => 'Voir le fichier dans l’explorateur';

  @override
  String get revealInExplorerFailed => 'Le fichier n’est plus là où il était.';

  @override
  String get mediaInfoTitle => 'Informations';

  @override
  String get descriptionHint => 'Ajouter une description';

  @override
  String get createdBy => 'Créé par :';

  @override
  String tagDropped(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus étiquetés avec $tag',
      one: 'Étiqueté avec $tag',
    );
    return '$_temp0';
  }

  @override
  String contextMenuTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sur les $count sélectionnés',
      one: 'Sur ce contenu',
    );
    return '$_temp0';
  }

  @override
  String get tagsTitle => 'Tags';

  @override
  String get addTags => 'Ajouter des tags';

  @override
  String get addFernies => 'Ajouter des fernies';

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
  String get tagRelationsTitle => 'Où se situe cette étiquette';

  @override
  String get tagRelationsNote =>
      'Au-dessus, l\'étiquette dont elle dépend. Sur les côtés, celles qui vont avec. Ce sont deux choses différentes : une étiquette qui dépend d\'une autre hérite de son contenu dans les recherches, celles qui vont ensemble sont seulement liées.';

  @override
  String get tagRelationsAddParent => 'Définir l\'étiquette parente';

  @override
  String get tagRelationsChangeParent => 'Changer la parente';

  @override
  String get tagRelationsAddSibling => 'Ajouter une étiquette liée';

  @override
  String get tagCollapseBranch => 'Replier ce qui dépend de celle-ci';

  @override
  String get tagExpandBranch => 'Déplier ce qui dépend de celle-ci';

  @override
  String get siblingDirectionBoth => 'Chacune ajoute l’autre';

  @override
  String siblingDirectionOneWay(String from, String to) {
    return '«$from» ajoute «$to»';
  }

  @override
  String get siblingDirectionNone => 'Aucune n’ajoute l’autre';

  @override
  String get siblingDirectionNote =>
      'Être liées dit qu’elles vont ensemble. La direction dit ce qui se passe quand on en ajoute une.';

  @override
  String get tagRelationsCreate => 'Créer une nouvelle étiquette';

  @override
  String get tagRelationsTooltip => 'Étiquette parente et liées';

  @override
  String get tagRelationsNoParent => 'Étiquette racine';

  @override
  String tagRelationsParentIs(String name) {
    return 'Dépend de $name';
  }

  @override
  String tagRelationsSiblingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liées',
      one: '1 liée',
    );
    return '$_temp0';
  }

  @override
  String get addSiblingTag => 'Ajouter une liée';

  @override
  String get actionRemove => 'Retirer';

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
  String get keepsSelectionOnDrop =>
      'Garder la sélection après l\'avoir déposée sur un tag';

  @override
  String get keepsSelectionOnDropDescription =>
      'Désactivé, déposer du contenu sur un tag le désélectionne, ce qui clôt le travail. Activé, il reste sélectionné pour pouvoir lui ajouter un autre tag sans tout resélectionner.';

  @override
  String get useCurrentImageAsAvatar => 'Utiliser l\'image que vous regardez';

  @override
  String get avatarCropTitle => 'Choisissez l\'avatar';

  @override
  String get avatarCropHint =>
      'Faites glisser un carré sur l\'image. La molette zoome.';

  @override
  String get avatarCropWholeImage => 'Utiliser l\'image entière';

  @override
  String get avatarSourceTitle => 'D\'où vient l\'image ?';

  @override
  String get avatarSourceLibrary => 'De la bibliothèque de Fern';

  @override
  String get avatarSourceDevice => 'Un fichier de cet ordinateur';

  @override
  String get avatarLibraryEmpty => 'Rien ici ne correspond';

  @override
  String get tagLogTitle => 'D\'où vient tout ça';

  @override
  String get tagLogNote => 'Ce qui a été mis sur ce contenu, et pourquoi.';

  @override
  String get tagLogGuessNote =>
      'Une partie n\'a pas été notée : elle est déduite des données telles qu\'elles sont maintenant, pas de ce qui s\'est passé. Ces lignes sont marquées.';

  @override
  String get tagLogGuessed => 'déduit';

  @override
  String get tagLogLoading => 'Lecture du journal…';

  @override
  String get tagLogEmpty => 'Rien n\'a été mis sur ce contenu.';

  @override
  String get tagLogManual => 'Vous l\'avez mise';

  @override
  String get tagLogSourceUrl => 'Une adresse liée correspondait';

  @override
  String get tagLogPlatform => 'La plateforme d\'où il vient';

  @override
  String get tagLogAncestor => 'Héritée de la branche';

  @override
  String tagLogAncestorOf(String tag) {
    return 'Au-dessus de $tag';
  }

  @override
  String get tagLogSibling => 'Va avec une autre étiquette';

  @override
  String tagLogSiblingOf(String tag) {
    return 'Va avec $tag';
  }

  @override
  String get tagLogRecognition =>
      'Vous avez accepté ce qu\'un modèle proposait';

  @override
  String get tagLogFernie => 'Ce qu\'un fernie marqué relie';

  @override
  String tagLogFernieOf(String fernie) {
    return 'Vous avez marqué $fernie ici';
  }

  @override
  String get assignCreatorSelectedTooltip =>
      'Mettre un créateur à la sélection';

  @override
  String assignCreatorToSelectionHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Il sera mis sur $count contenus, par-dessus le créateur qu\'ils ont actuellement.',
      one:
          'Il sera mis sur 1 contenu, par-dessus le créateur qu\'il a actuellement.',
    );
    return '$_temp0';
  }

  @override
  String get creatorTagsTooltip => 'Étiquettes de ce créateur';

  @override
  String get creatorTagsHint =>
      'Ce qui sera mis sur un contenu en même temps que ce créateur. Cela ne touche pas ce qui est déjà étiqueté : cela vaut à partir de maintenant.';

  @override
  String get tagLogCreator => 'Elle vient de son créateur';

  @override
  String tagLogCreatorOf(String name) {
    return 'Elle vient de $name';
  }

  @override
  String get tagLogUnknown => 'Rien de noté';

  @override
  String get actionTagLog => 'D\'où vient tout ça';

  @override
  String get viewerSaveSectionTitle => 'En enregistrant un média importé';

  @override
  String get viewerSaveSectionNote =>
      'Ce que fait la visionneuse quand vous validez un média importé. Dans tous les cas il quitte la grille d\'importation, donc la visionneuse ne peut pas rester où elle était.';

  @override
  String get viewerPrevious => 'Précédent';

  @override
  String get viewerNext => 'Suivant';

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
  String get settingsDatabase => 'Base de données';

  @override
  String get databaseSectionTitle => 'Base de données';

  @override
  String get databaseSectionNote =>
      'Tout ce que Fern sait de votre bibliothèque tient dans une base de données de cet ordinateur : les fiches des contenus, les tags, les créateurs, les fernies, les modèles et les régions marquées.';

  @override
  String get databaseWipeTitle => 'Supprimer la base de données';

  @override
  String get databaseWipeSectionNote =>
      'Remet Fern à l\'état d\'une installation neuve. Irréversible et sans sauvegarde de secours.';

  @override
  String get databaseWipeWarning =>
      'Ceci est irréversible. Fern ne conserve aucune copie de la base de données.';

  @override
  String get databaseWipeLoses =>
      'Vous perdez : toutes les fiches de contenu avec leur description et leurs favoris, tous les tags et créateurs, les fernies et toutes les régions marquées, les modèles entraînés et leur arbre, les suggestions de reconnaissance et les groupes de doublons.';

  @override
  String get databaseWipeKeeps =>
      'Vos fichiers restent où ils sont : rien n\'est supprimé du disque, et analyser le dossier de la bibliothèque les réenregistre. Les réglages, les mots de passe et les identifiants des sources restent également.';

  @override
  String get databaseWipeScopeAll => 'Tout';

  @override
  String get databaseWipeScopeAllNote =>
      'Étiquettes, créateurs, fernies, modèles : tout. L\'application repart de zéro.';

  @override
  String get databaseWipeScopeNsfw => 'Seulement ce qui est marqué NSFW';

  @override
  String get databaseWipeScopeNsfwNote =>
      'Le contenu marqué et ce qu\'il hérite des étiquettes et des créateurs marqués. Les étiquettes, les créateurs, les fernies et les modèles restent.';

  @override
  String get databaseWipeFiles => 'Supprimer aussi les fichiers du disque';

  @override
  String get databaseWipeFilesNote =>
      'Sans cela les fichiers restent où ils sont et une analyse les ramène. Avec, ils disparaissent : c\'est la partie sans retour.';

  @override
  String get databaseWipeConfirmFiles =>
      'Les fichiers partent aussi du disque. Ils sont supprimés en arrière-plan et vous pouvez suivre ça dans la liste des tâches.';

  @override
  String get databaseWipeConfirmNsfw =>
      'Seul ce qui est marqué NSFW s\'en va. Tout le reste reste tel quel.';

  @override
  String get databaseWipeContinue => 'J\'ai compris, continuer';

  @override
  String get databaseWipeConfirmTitle => 'Tapez la phrase pour confirmer';

  @override
  String get databaseWipeConfirmNote =>
      'Pour éviter tout accident, tapez la phrase suivante telle quelle :';

  @override
  String get databaseWipePhrase => 'Supprimer Base de Donnees';

  @override
  String get databaseWipeFieldLabel => 'Phrase de confirmation';

  @override
  String get databaseWipeAction => 'Supprimer la base de données';

  @override
  String get databaseWipeFailed =>
      'La base de données n\'a pas pu être supprimée.';

  @override
  String get databaseWipeDone => 'La base de données est vide.';

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
  String get redditGuideAction => 'Comment les obtenir ?';

  @override
  String get redditGuideTitle => 'Connecter Fern à Reddit';

  @override
  String get redditGuideIntro =>
      'Reddit n\'autorise personne à lire vos publications enregistrées tant que vous n\'avez pas déclaré une application sur votre compte. C\'est l\'affaire de deux minutes, et une seule fois.';

  @override
  String get redditGuideStep1 =>
      'Ouvrez reddit.com/prefs/apps avec le bouton ci-dessous. Il s\'ouvre dans Fern, vous êtes donc déjà connecté.';

  @override
  String get redditGuideStep2 =>
      'Descendez en bas de la page et appuyez sur « create another app... » (ou « are you a developer? create an app... »).';

  @override
  String get redditGuideStep3 =>
      'Choisissez le type « script ». C\'est l\'étape que l\'on rate : avec n\'importe quel autre type, Reddit crée quand même l\'application, puis refuse chaque requête sans dire pourquoi.';

  @override
  String get redditGuideStep4 =>
      'Donnez-lui le nom que vous voulez, laissez la description vide et collez ceci dans « redirect uri » :';

  @override
  String get redditGuideStep5 =>
      'Appuyez sur « create app ». Reddit affiche la fiche de l\'application que vous venez de créer.';

  @override
  String get redditGuideStep6 =>
      'L\'identifiant client est la courte chaîne juste sous « personal use script », en haut à gauche de la fiche. Le secret est le champ intitulé « secret ».';

  @override
  String get redditGuideStep7 =>
      'Revenez ici et collez les deux, ainsi que votre nom d\'utilisateur et votre mot de passe Reddit.';

  @override
  String get redditGuideTwoFactor =>
      'Avec la double authentification activée, le mot de passe s\'écrit motdepasse:code — Reddit attend les deux dans le même champ.';

  @override
  String get redditGuidePrivacy =>
      'Les quatre données restent sur cet ordinateur, chiffrées, et ne sont envoyées qu\'à Reddit.';

  @override
  String get redditGuideOpen => 'Ouvrir Reddit';

  @override
  String get redditGuideCopy => 'Copier l\'adresse de redirection';

  @override
  String get redditGuideCopied => 'Adresse de redirection copiée';

  @override
  String get emptyLibraryHint =>
      'Ce que vous récupérez depuis une plateforme ou un dossier apparaît ici une fois que vous l’avez passé en revue.';

  @override
  String get noTagsYetHint =>
      'Les étiquettes servent à retrouver les choses plus tard. Créez-en une depuis le + de la barre du haut.';

  @override
  String get noCreatorsYetHint =>
      'Un créateur regroupe tout ce qu’a fait la même personne. Créez-en un depuis le + de la barre du haut.';

  @override
  String get noFerniesYetHint =>
      'Un fernie est quelqu’un qu’un modèle apprend à reconnaître. Créez-en un depuis le + de la barre du haut, puis marquez-le sur vos contenus.';

  @override
  String get modelsEmptyHint =>
      'Un modèle apprend à reconnaître vos fernies. Créez-en un depuis le + de la barre du haut.';

  @override
  String get duplicatesNeverScannedHint =>
      'Appuyez sur « Chercher maintenant » et Fern parcourt toute la bibliothèque. La première fois peut prendre un moment.';

  @override
  String get duplicatesNoneHint =>
      'Relancez après un import, ou baissez le seuil de ressemblance dans les Réglages.';

  @override
  String get viewerInfoTooltip => 'Voir les informations';

  @override
  String get settingsOpenTooltip => 'Ouvrir les réglages';

  @override
  String get mediaFileMissing => 'Le fichier n’est plus là où il était';

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
  String get sourceGuideOpenSite => 'Ouvrir le site';

  @override
  String get sourceGuideOpenLogin => 'Ouvrir la page de connexion';

  @override
  String get sourceGuidePrivacy =>
      'Ce que vous collez reste sur cet ordinateur, chiffré, et n\'est envoyé qu\'à ce site.';

  @override
  String get sessionGuideStep1 =>
      'Appuyez sur le bouton ci-dessous. Fern ouvre le site dans son propre navigateur et vous amène à la page de connexion.';

  @override
  String get sessionGuideStep2 =>
      'Connectez-vous exactement comme ailleurs : captcha, code par courriel et tout le reste. C\'est précisément pour cela que cela ne peut pas se faire de l\'extérieur.';

  @override
  String get sessionGuideStep3 =>
      'Une fois connecté, appuyez sur la clé dans la barre du navigateur pour enregistrer la session. Sans cette étape rien n\'est enregistré et l\'importation continuera à dire que ce n\'est pas configuré.';

  @override
  String get sessionGuideExpires =>
      'Les sessions expirent d\'elles-mêmes au bout d\'un temps. Le cas échéant, Fern vous prévient et il suffit de refaire ces étapes.';

  @override
  String get danbooruGuideTitle => 'Connecter Fern à Danbooru';

  @override
  String get danbooruGuideIntro =>
      'Danbooru donne à chaque compte une clé d\'API pour que les programmes puissent lire en son nom. Elle se prend depuis votre fiche ; votre mot de passe n\'intervient pas.';

  @override
  String get danbooruGuideStep1 =>
      'Ouvrez votre fiche avec le bouton ci-dessous et assurez-vous d\'être connecté.';

  @override
  String get danbooruGuideStep2 =>
      'Trouvez la ligne « API Key » de votre fiche et appuyez sur « view ». Danbooru demande votre mot de passe pour l\'afficher.';

  @override
  String get danbooruGuideStep3 =>
      'S\'il n\'y en a pas encore, appuyez sur « Add » et donnez-lui le nom que vous voulez. Une seule suffit à Fern.';

  @override
  String get danbooruGuideStep4 => 'Copiez la longue chaîne qui s\'affiche.';

  @override
  String get danbooruGuideStep5 =>
      'Revenez ici : le nom d\'utilisateur est celui avec lequel vous vous connectez, et le second champ prend la clé, pas votre mot de passe. Danbooru l\'accepte et ne renvoie tout simplement rien.';

  @override
  String get danbooruGuideNote =>
      'Révoquer la clé depuis cette même page coupe l\'accès de Fern immédiatement, sans toucher à votre mot de passe.';

  @override
  String get gelbooruGuideTitle => 'Connecter Fern à Gelbooru';

  @override
  String get gelbooruGuideIntro =>
      'Gelbooru vous donne les deux valeurs d\'un coup, écrites sur une seule ligne. Couper cette ligne en deux, c\'est tout le travail.';

  @override
  String get gelbooruGuideStep1 =>
      'Ouvrez les options de votre compte avec le bouton ci-dessous et assurez-vous d\'être connecté.';

  @override
  String get gelbooruGuideStep2 =>
      'Descendez jusqu\'à « API Access Credentials » et ouvrez le lien proposé.';

  @override
  String get gelbooruGuideStep3 =>
      'Gelbooru affiche une ligne de ce genre : &api_key=abc123&user_id=456.';

  @override
  String get gelbooruGuideStep4 =>
      'Cette ligne contient deux valeurs distinctes. Ne la collez pas entière dans un champ : Gelbooru l\'accepte et ensuite plus rien ne fonctionne, sans dire pourquoi.';

  @override
  String get gelbooruGuideStep5 =>
      'Mettez ce qui suit user_id= dans le premier champ, et ce qui suit api_key= dans le second.';

  @override
  String get pixivGuideTitle => 'Connecter Fern à Pixiv';

  @override
  String get pixivGuideIntro =>
      'Pixiv n\'a pas de clés à copier. Il n\'y a rien à écrire ici : vous vous connectez dans Fern et c\'est la session qui vous identifie.';

  @override
  String get pixivGuideStep4 =>
      'C\'est tout. Rien à coller ici : allez à l\'écran d\'importation et choisissez Pixiv.';

  @override
  String get pinterestGuideTitle => 'Connecter Fern à Pinterest';

  @override
  String get pinterestGuideIntro =>
      'Votre nom d\'utilisateur suffit pour les tableaux publics. La session n\'est nécessaire que pour les tableaux secrets.';

  @override
  String get pinterestGuideStep1 =>
      'Écrivez votre nom d\'utilisateur Pinterest dans le champ ci-dessus. Avec cela, les tableaux publics fonctionnent déjà.';

  @override
  String get pinterestGuideStep2 =>
      'Seulement si vous voulez aussi les tableaux secrets, appuyez sur le bouton ci-dessous et connectez-vous.';

  @override
  String get pawchiveGuideTitle => 'Connecter Fern à Pawchive';

  @override
  String get pawchiveGuideIntro =>
      'Ici non plus il n\'y a pas de clés : vous vous connectez dans Fern et c\'est la session qui vous identifie.';

  @override
  String get pawchiveGuideStep4 =>
      'De retour ici, choisissez ci-dessous si vous voulez vos publications enregistrées ou tout ce que publient les créateurs que vous suivez.';

  @override
  String get pawchiveGuideLinks =>
      'Les publications renvoient souvent vers des sites de téléchargement (Mega, Drive, Pixeldrain). Fern récupère ce qu\'il peut tout seul et vous liste le reste à la fin de l\'importation.';

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
  String pendingLinksToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publications mènent à des sites de téléchargement',
      one: '1 publication mène à un site de téléchargement',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publications ont besoin de vous',
      one: '1 publication a besoin de vous',
    );
    return '$_temp0';
  }

  @override
  String get pendingLinksDescription =>
      'Elles mènent à des sites de téléchargement qui ne peuvent pas être parcourus tout seuls : ils ont leur propre attente, leur captcha ou leur liste de fichiers. Ouvrez ceux qui vous intéressent et récupérez-les depuis le navigateur.';

  @override
  String get pendingLinksFolder => 'dossier';

  @override
  String get pendingLinksFile => 'fichier';

  @override
  String get pawchiveByCreators => 'Importer par créateurs favoris';

  @override
  String get pawchiveByCreatorsDescription =>
      'Au lieu des publications que tu as mises en favoris, Fern parcourt tout ce que publient les créateurs que tu suis. Cela rapporte beaucoup plus, et chaque créateur est suivi séparément.';

  @override
  String get remoteImportAllWarning =>
      'Sans limite, Fern parcourt le compte entier. Sur un grand compte, cela représente des heures de téléchargement et plusieurs gigaoctets de disque. Vous pouvez l’arrêter quand vous voulez depuis l’écran d’import, et ce qui est déjà arrivé reste.';

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
  String browserLoadFailed(String reason) {
    return 'Impossible de charger la page ($reason)';
  }

  @override
  String browserLoadFailedHome(String reason) {
    return 'Impossible de charger la page ($reason) ; retour à la page d\'accueil';
  }

  @override
  String get browserReset => 'Repartir de zéro';

  @override
  String get browserResetDone => 'Le navigateur a été réinitialisé';

  @override
  String get browserResetting => 'Fermeture du moteur du navigateur…';

  @override
  String get browserSlow => 'Cette page met plus de temps que d\'habitude';

  @override
  String get browserEngineStuck =>
      'La page s\'est chargée mais rien ne s\'affiche. Le moteur du navigateur ne répond plus : fermez complètement Fern et rouvrez-le.';

  @override
  String get browserAsideImporting =>
      'Le navigateur est mis de côté pendant l\'importation';

  @override
  String get browserAsideImportingWhy =>
      'Récupérer beaucoup de contenu d\'un coup sollicite énormément la machine, et c\'est ce qui laisse le navigateur charger des pages qu\'il n\'affiche jamais. Ce qui n\'est pas lancé ne peut pas casser.';

  @override
  String get browserAsideAnyway => 'Le ramener quand même';

  @override
  String get browserAsideOnce =>
      'Seulement pour cette visite : en sortant et revenant, il est de nouveau mis de côté.';

  @override
  String get browserAsideTitle => 'Le navigateur pendant les importations';

  @override
  String get browserAsideNote =>
      'Récupérer beaucoup de contenu d\'un coup sollicite la machine, et c\'est ce qui laisse le navigateur charger des pages qu\'il n\'affiche jamais. Le mettre de côté l\'évite.';

  @override
  String get browserAsideAlways => 'Toujours le mettre de côté';

  @override
  String get browserAsideAlwaysDescription =>
      'Tant qu\'une importation est en cours. C\'est ce qui a été vu fonctionner.';

  @override
  String get browserAsideLarge => 'Seulement sur les grosses importations';

  @override
  String get browserAsideLargeDescription =>
      'Seulement quand l\'importation récupère tout, tout le nouveau, ou 50 et plus.';

  @override
  String get browserAsideNever => 'Jamais';

  @override
  String get browserAsideNeverDescription =>
      'Le navigateur reste. S\'il devient blanc, « Repartir de zéro » est dans sa barre.';

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
  String get importAsNsfwTooltip =>
      'Marquer comme NSFW tout ce qui est importé';

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
  String get sourceUrlsNote =>
      'N’importe quelle plateforme convient : tout ce qui dépend de l’adresse est récupéré. Sur celles qui identifient la galerie avec ce qui suit le « ? » —Danbooru, Gelbooru— copiez l’adresse entière, paramètres compris.';

  @override
  String get sourceUrlsLabel => 'Adresses';

  @override
  String get sourceUrlHint => 'reddit.com/r/exemple, pixiv.net/users/123…';

  @override
  String get addSourceUrl => 'Ajouter une adresse';

  @override
  String get noSourceUrls => 'Aucune adresse liée';

  @override
  String get databaseCleanupTitle => 'Nettoyer les fichiers orphelins';

  @override
  String get databaseCleanupNote =>
      'Les avatars sont des copies faites par Fern. Quand vous en changez un, la copie précédente n’est plus utilisée par rien et reste sur le disque. Ceci emporte tout ce que plus rien ne désigne.';

  @override
  String get databaseCleanupAction => 'Nettoyer';

  @override
  String databaseCleanupFound(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers orphelins, $size',
      one: '1 fichier orphelin, $size',
    );
    return '$_temp0';
  }

  @override
  String get databaseCleanupAvatars => 'Avatars sans propriétaire';

  @override
  String get databaseCleanupDownloads => 'Téléchargements absents de la base';

  @override
  String get databaseCleanupWeights => 'Poids qu’aucun modèle ne désigne';

  @override
  String get databaseCleanupKeeps =>
      'L’environnement Python, les jeux d’entraînement et les caches ne sont pas touchés.';

  @override
  String get databaseCleanupFailed => 'Le nettoyage n’a pas pu se terminer';

  @override
  String databaseCleanupDone(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers supprimés, $size libérés',
      one: '1 fichier supprimé, $size libérés',
      zero: 'Il n’y avait rien d’orphelin',
    );
    return '$_temp0';
  }

  @override
  String get blockedImportsTitle => 'À ne plus importer';

  @override
  String get blockedImportsNote =>
      'Ce que vous avez demandé à ne plus voir proposé. C’est ignoré sans être téléchargé.';

  @override
  String get blockedImportsNone => 'Rien n’est bloqué.';

  @override
  String get blockedImportsUnblock => 'Réimporter ceci';

  @override
  String get blockedImportsOpen => 'Ouvrir la page d’origine';

  @override
  String get blockedImportsClear => 'Tout oublier';

  @override
  String get blockImportAgain => 'Ne plus importer ceci';

  @override
  String get blockImportAgainDescription =>
      'La source continue de proposer ce que vous y avez enregistré. Coché, ceci est ignoré sans être téléchargé. Annulable dans Réglages, section Base de données.';

  @override
  String importSkippedBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignorés : vous avez demandé à ne plus les voir.',
      one: '1 ignoré : vous avez demandé à ne plus le voir.',
    );
    return '$_temp0';
  }

  @override
  String creatorNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Masque $count éléments.',
      one: 'Masque 1 élément.',
      zero: 'Ce créateur n’a aucun contenu pour l’instant.',
    );
    return '$_temp0';
  }

  @override
  String get creatorNsfwOnTooltip =>
      'Marqué comme NSFW · cliquez pour le démarquer';

  @override
  String get creatorNsfwOffTooltip => 'Marquer comme NSFW';

  @override
  String get searchChipDescription => 'Description';

  @override
  String get showsTagBranchOnFilter =>
      'Afficher toute la branche en filtrant les étiquettes';

  @override
  String get showsTagBranchOnFilterDescription =>
      'En filtrant la liste des étiquettes, chaque résultat arrive avec ce qui en dépend, pour voir la branche et pas seulement le nom.';

  @override
  String get peopleTitle => 'Personnes';

  @override
  String get navPersonaManager => 'Personnes';

  @override
  String get tagIsPerson => 'Cette étiquette est une personne';

  @override
  String get tagIsPersonDescription =>
      'Les personnes et les personnages se gèrent sur leur propre écran. Cela reste une étiquette : l\'attribution et la recherche fonctionnent pareil.';

  @override
  String get openPeopleTooltip => 'Aller aux personnes';

  @override
  String get openTagsTooltip => 'Aller aux étiquettes';

  @override
  String get noPeopleYet => 'Aucune personne pour l\'instant';

  @override
  String get noPeopleYetHint =>
      'Marquez une étiquette comme personne depuis sa fiche, ou créez-en une ici.';

  @override
  String get markLinkNsfwTooltip => 'Marquer l\'adresse comme non adaptée';

  @override
  String get unmarkLinkNsfwTooltip =>
      'L\'adresse est marquée comme non adaptée';

  @override
  String get openSourceUrlTooltip => 'Ouvrir l\'adresse dans le navigateur';

  @override
  String get editSourceUrlTooltip => 'Modifier l\'adresse';

  @override
  String get doneEditingSourceUrlTooltip => 'Terminer la modification';

  @override
  String get removeSourceUrlTooltip => 'Retirer l\'adresse';

  @override
  String get filtersType => 'Type de contenu';

  @override
  String get filterImages => 'Images';

  @override
  String get filterGifs => 'GIF';

  @override
  String get filterVideos => 'Vidéos';

  @override
  String get selectAllTooltip => 'Tout sélectionner à l’écran';

  @override
  String get selectNoneTooltip => 'Enlever la sélection';

  @override
  String get sortNewestFirst => 'Le plus récent d’abord';

  @override
  String get sortOldestFirst => 'Le plus ancien d’abord';

  @override
  String get sortFileName => 'Par nom de fichier';

  @override
  String get sortDescription => 'Par description';

  @override
  String get sortKind => 'Par type';

  @override
  String get sortRandom => 'Au hasard';

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
  String get jobsTooltip => 'Tâches';

  @override
  String get jobsTitle => 'Tâches';

  @override
  String get jobRunning => 'En cours…';

  @override
  String get jobCancelled => 'Arrêtée';

  @override
  String get jobDismissTooltip => 'Retirer de la liste';

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
  String get jobLinkReview => 'Liens à examiner';

  @override
  String get jobLinkImport => 'Récupération des liens';

  @override
  String get jobImport => 'Import en cours';

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
  String get notifyImport => 'Import terminé';

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
  String get jobTagRegions => 'Marquage du contenu d’une étiquette';

  @override
  String get jobFileCleanup => 'Suppression des fichiers';

  @override
  String get fernieImportTagTitle => 'Marquer une étiquette entière';

  @override
  String get fernieImportTagNote =>
      'Tout ce qui porte cette étiquette reçoit une région couvrant l’image entière, pour ce fernie. C’est ce que vous feriez à la main, un par un.';

  @override
  String get fernieImportTagAction => 'Les marquer';

  @override
  String get fernieImportTagTooltip =>
      'Marquer une étiquette entière comme régions';

  @override
  String get fernieImportTagFrames => 'Images par vidéo';

  @override
  String get fernieImportTagFramesNote =>
      'L’entraînement prend une image par région : une vidéo entière ferait des milliers de découpes presque identiques.';

  @override
  String fernieImportTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenus',
      one: '1 contenu',
      zero: 'Rien ne porte cette étiquette',
    );
    return '$_temp0';
  }

  @override
  String get fernieImportTagStarted =>
      'Le marquage a commencé ; vous pouvez le suivre dans la liste des tâches';

  @override
  String get fernieToolWholeFrame => 'Marquer l’image entière';

  @override
  String fernieAcceptAllProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accepter les $count régions détectées',
      one: 'Accepter la région détectée',
    );
    return '$_temp0';
  }

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
  String get fernieModeTooltip => 'Marquer des fernies sur ce contenu';

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
  String ferniePendingRegions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count régions portent sur du contenu non confirmé, elles n\'entraînent donc pas',
      one:
          '1 région porte sur du contenu non confirmé, elle n\'entraîne donc pas',
    );
    return '$_temp0';
  }

  @override
  String get viewerRecognize => 'Reconnaître avec les modèles';

  @override
  String get viewerRecognizing => 'Reconnaissance en cours…';

  @override
  String suggestionConfidence(int percent) {
    return '$percent %';
  }

  @override
  String suggestionInstances(int count) {
    return '×$count';
  }

  @override
  String get suggestionFromModel =>
      'Proposé par un modèle, pas encore confirmé';

  @override
  String get suggestionCreatorTitle => 'Créateur proposé';

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
  String get jobReviewTooltip => 'Décider de ces liens';

  @override
  String get notifyLinkReview => 'Des liens vous attendent';

  @override
  String get jobDetailTooltip => 'Voir ce qu\'ont fait les modèles';

  @override
  String get jobsClearFinished => 'Marquer les terminées comme vues';

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
  String get maxDetectionsLabel => 'Combien de fois la même chose est gardée';

  @override
  String get maxDetectionsDescription =>
      'Un modèle peut voir quatre voitures sur une photo. Chacune est une région distincte à marquer, donc toutes sont gardées — jusqu’à ce nombre. Un parking pourrait en donner cinquante.';

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
  String get remoteCreatorsMode => 'Créateurs';

  @override
  String get remoteContentMode => 'Contenu';

  @override
  String remoteCreatorNewPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles publications',
      one: '1 nouvelle publication',
      zero: 'rien de nouveau',
    );
    return '$_temp0';
  }

  @override
  String remoteCreatorImporting(String name) {
    return 'Récupération de $name…';
  }

  @override
  String remoteCreatorLastImport(String date) {
    return 'dernière fois le $date';
  }

  @override
  String remoteCreatorNewsSince(String date) {
    return 'du neuf depuis le $date';
  }

  @override
  String get remoteCreatorNeverImported => 'jamais importé';

  @override
  String get remoteCreatorKnown => 'déjà chez vous';

  @override
  String get remoteCreatorsEmpty => 'Aucun créateur dans cette source';

  @override
  String remoteCreatorsImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récupérer $count créateurs',
      one: 'Récupérer 1 créateur',
    );
    return '$_temp0';
  }

  @override
  String get importReviewLabel => 'Examiner';

  @override
  String get importSortLabel => 'Trier par';

  @override
  String get importCreatorsLabel => 'Afficher';

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
  String get duplicatesNeverScanned => 'Rien n\'a encore été analysé';

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
  String get settingsDuplicates => 'Contenu répété';

  @override
  String get settingsNsfw => 'Contenu NSFW';

  @override
  String get nsfwCoveredLabel => 'Contenu NSFW';

  @override
  String get nsfwViewsTitle => 'Comment il se comporte';

  @override
  String get nsfwViewsNote =>
      'Ce que vous voyez avec le filtre actif et ce que vous voyez sans lui. Les deux s’appliquent à ce qui sera affiché ensuite, sans rien redémarrer.';

  @override
  String get nsfwUnlockedViewLabel => 'Sans filtre NSFW';

  @override
  String get nsfwUnlockedViewMixed => 'Tout ensemble';

  @override
  String get nsfwUnlockedViewOnly => 'Seulement ce qui est marqué';

  @override
  String get nsfwUnlockedViewNote =>
      '« Seulement le marqué » en fait une bibliothèque à part : tant que le filtre est retiré, le reste de votre contenu n’apparaît pas.';

  @override
  String get nsfwLockedViewLabel => 'Avec filtre NSFW';

  @override
  String get nsfwLockedViewHidden => 'Il n’apparaît pas';

  @override
  String get nsfwLockedViewBlurred => 'Il apparaît couvert';

  @override
  String get nsfwChildTagsLabel =>
      'Marquer une étiquette marque aussi celles qui en dépendent';

  @override
  String get nsfwChildTagsDescription =>
      'Une étiquette qui dépend d\'une étiquette marquée cache aussi son contenu, sans avoir à la marquer séparément. Désactivé, chaque étiquette ne répond que du sien. Rien n\'est réécrit dans un cas comme dans l\'autre : activez-le et désactivez-le autant que vous voulez.';

  @override
  String get nsfwTagsHideMediaLabel =>
      'Une étiquette marquée cache aussi son contenu';

  @override
  String get nsfwTagsHideMediaDescription =>
      'Activé, il suffit qu\'un contenu porte une étiquette marquée pour qu\'il disparaisse entièrement. Désactivé, la marque reste sur l\'étiquette : le contenu reste visible avec ses autres étiquettes, et de celle qui est marquée il ne reste même pas le nom. Cela sert pour une étiquette qui dit quelque chose de délicat sur un contenu qui ne l\'est pas. Ce qui est marqué à la main et ce qui vient d\'un créateur marqué se cachent de la même façon dans les deux cas.';

  @override
  String get nsfwLockedViewNote =>
      'Couvert, le contenu marqué garde sa place dans la grille, flouté et avec un cadenas ; le toucher demande le mot de passe. C’est plus pratique, mais cela laisse voir qu’il y a quelque chose : combien, et de quelle forme.';

  @override
  String get nsfwSectionTitle => 'Filtre de contenu NSFW';

  @override
  String get nsfwSectionNote =>
      'Ce que vous marquez comme NSFW est caché : avec le filtre actif, cela n’apparaît nulle part, ni dans la corbeille ni dans les recherches.';

  @override
  String get nsfwSectionWarning =>
      'Cela cache, cela ne chiffre pas : les fichiers restent dans leur dossier sous leur nom, et quiconque ouvre l’explorateur les voit.';

  @override
  String get nsfwNotConfiguredNote =>
      'Il n’y a pas encore de mot de passe. Sans lui rien ne peut être marqué, et ce que vous avez se voit comme toujours.';

  @override
  String get nsfwConfigureAction => 'Définir un mot de passe';

  @override
  String get nsfwStateLocked =>
      'Filtre NSFW actif : le contenu marqué ne se voit pas';

  @override
  String get nsfwStateUnlocked => 'Filtre NSFW retiré : tout se voit';

  @override
  String get nsfwOpenAction => 'Retirer le filtre NSFW';

  @override
  String get nsfwCloseAction => 'Remettre le filtre';

  @override
  String get nsfwRememberLabel => 'Rester sans filtre à la réouverture de Fern';

  @override
  String get nsfwRememberDescription =>
      'Désactivé, fermer Fern remet le filtre. Activé, il reste comme vous l’avez laissé, et la première chose que vous verrez en ouvrant est ce que vous avez marqué.';

  @override
  String get nsfwChangePasswordAction => 'Changer le mot de passe';

  @override
  String get nsfwChangeDone =>
      'Mot de passe changé. Le code de récupération reste le même.';

  @override
  String get nsfwDisableNote =>
      'Désactiver le filtre démarque tout ce que vous aviez marqué —étiquettes, contenu, fernies et modèles— et cesse de cacher quoi que ce soit. Rien n’est supprimé : il était marqué, pas chiffré.';

  @override
  String get nsfwDisableAction => 'Désactiver le filtre';

  @override
  String nsfwDisableDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtre désactivé et $count étiquettes démarquées.',
      one: 'Filtre désactivé et 1 étiquette démarquée.',
      zero: 'Filtre désactivé. Aucune étiquette n’était marquée.',
    );
    return '$_temp0';
  }

  @override
  String get nsfwSetupTitle => 'Définir le mot de passe';

  @override
  String get nsfwPasswordLabel => 'Mot de passe';

  @override
  String get nsfwPasswordRepeatLabel => 'Répétez-le';

  @override
  String get nsfwHintLabel => 'Phrase indice (facultative)';

  @override
  String get nsfwHintNote =>
      'Elle vous est montrée après trois essais ratés, donc elle se lit sans connaître le mot de passe : qu’elle soit un indice pour vous, pas le mot de passe écrit autrement.';

  @override
  String get nsfwSetupAction => 'Enregistrer';

  @override
  String get nsfwPasswordEmpty => 'Écrivez un mot de passe.';

  @override
  String get nsfwPasswordMismatch =>
      'Les deux mots de passe ne sont pas identiques.';

  @override
  String get nsfwCodeTitle => 'Votre code de récupération';

  @override
  String get nsfwCodeIntro =>
      'C’est la seule chose qui retire le filtre si vous perdez le mot de passe, et il n’est montré que maintenant : Fern ne le garde pas, il en garde une empreinte. Copiez-le ou enregistrez-le dans un fichier avant de fermer.';

  @override
  String get nsfwCodeCopy => 'Copier';

  @override
  String get nsfwCodeCopied => 'Copié dans le presse-papiers.';

  @override
  String get nsfwCodeSave => 'Enregistrer dans un fichier';

  @override
  String nsfwCodeSaved(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get nsfwCodeSaveFailed =>
      'Le fichier n’a pas pu être enregistré. Copiez le code avant de fermer.';

  @override
  String get nsfwCodeDone => 'Je l’ai enregistré';

  @override
  String get nsfwCodeFileHeader =>
      'Code de récupération du filtre de contenu NSFW de Fern. Gardez-le où vous pourrez le retrouver : c’est la seule chose qui retire le filtre si vous perdez le mot de passe.';

  @override
  String get nsfwUnlockTitle => 'Retirer le filtre NSFW';

  @override
  String get nsfwUnlockAction => 'Le retirer';

  @override
  String get nsfwUnlockWrong => 'Ce n’est pas le mot de passe.';

  @override
  String nsfwUnlockHint(String hint) {
    return 'Votre phrase indice : $hint';
  }

  @override
  String get nsfwUnlockNoHint =>
      'Vous n’avez pas mis de phrase indice. Si le mot de passe vous échappe, il vous reste le code de récupération.';

  @override
  String get nsfwUnlockRecover => 'Utiliser le code de récupération';

  @override
  String get nsfwRecoverTitle => 'Récupérer l’accès';

  @override
  String get nsfwRecoverIntro =>
      'Écrivez le code que vous avez gardé et choisissez un nouveau mot de passe. Le code est consommé à l’usage : nous vous en donnerons un autre, et c’est celui-là qui vaudra désormais.';

  @override
  String get nsfwRecoverCodeLabel => 'Code de récupération';

  @override
  String get nsfwRecoverAction => 'Récupérer';

  @override
  String get nsfwRecoverWrong =>
      'Ce code n’est pas le bon. Regardez encore : les tirets et les majuscules n’ont pas d’importance.';

  @override
  String get nsfwChangeTitle => 'Changer le mot de passe';

  @override
  String get nsfwChangeCurrentLabel => 'Mot de passe actuel';

  @override
  String get nsfwChangeNewLabel => 'Nouveau mot de passe';

  @override
  String get nsfwChangeAction => 'Le changer';

  @override
  String get nsfwChangeWrong => 'Ce n’est pas le mot de passe actuel.';

  @override
  String get nsfwDisableTitle => 'Désactiver le filtre';

  @override
  String get nsfwDisableWarning =>
      'Le mot de passe est supprimé, toutes les étiquettes sont démarquées et leur contenu réapparaît. Rien n’est retiré de votre bibliothèque. Pour avoir de nouveau le filtre, il faudra le remettre de zéro et marquer les étiquettes à nouveau.';

  @override
  String get nsfwDisableSecretLabel => 'Mot de passe ou code de récupération';

  @override
  String get nsfwDisableWrong => 'Ni le mot de passe ni le code.';

  @override
  String get nsfwDisableFailed =>
      'Les marques n\'ont pas pu être retirées, le mot de passe est donc resté tel quel. Réessayez.';

  @override
  String tagNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cache $count contenus.',
      one: 'Cache 1 contenu.',
      zero: 'Il n’y a aucun contenu avec cette étiquette pour l’instant.',
    );
    return '$_temp0';
  }

  @override
  String get tagNsfwOnTooltip => 'Marquée NSFW · cliquez pour la démarquer';

  @override
  String get tagNsfwOffTooltip => 'Marquer comme NSFW';

  @override
  String get nsfwMarkOnTooltip => 'Marqué NSFW · cliquez pour le démarquer';

  @override
  String get mediaNsfwMark => 'Marquer comme NSFW';

  @override
  String get mediaNsfwUnmark => 'Retirer la marque NSFW';

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

  @override
  String get settingsHelp => 'Aide';

  @override
  String get tutorialSectionTitle => 'Visites guidées';

  @override
  String get tutorialSectionNote =>
      'Dix visites qui couvrent toute l\'application, une par sujet. En les suivant toutes, plus rien ne reste à expliquer. Vous pouvez quitter à tout moment.';

  @override
  String get tutorialOfferTitle => 'Je vous fais visiter ?';

  @override
  String get tutorialOfferBody =>
      'Une visite en dix étapes de ce qu\'est chaque chose et où elle se trouve. Il y en a neuf autres, une par sujet, dans Réglages → Aide. Vous pouvez partir quand vous voulez.';

  @override
  String get tutorialOfferAccept => 'Commencer';

  @override
  String get tutorialOfferDecline => 'Pas maintenant';

  @override
  String tutorialProgress(int position, int total) {
    return '$position sur $total';
  }

  @override
  String get tutorialSkip => 'Quitter';

  @override
  String get tutorialBack => 'Retour';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialDone => 'Terminé';

  @override
  String get tutorialWelcomeTitle => 'Bienvenue dans FeRN';

  @override
  String get tutorialWelcomeBody =>
      'FeRN garde le contenu que vous collectionnez : il l\'importe, le range avec des étiquettes et des créateurs, et peut apprendre à reconnaître ce qui s\'y trouve. Suivant ou les flèches pour avancer, Échap pour sortir.';

  @override
  String get tutorialSidebarTitle => 'C\'est par ici qu\'on navigue';

  @override
  String get tutorialSidebarBody =>
      'Tous les écrans sont là : votre bibliothèque, ce que vous importez, les favoris, la corbeille et les gestionnaires de créateurs, d\'étiquettes, de fernies et de modèles. Le bouton du haut le replie au besoin.';

  @override
  String get tutorialImportTitle => 'Le contenu entre par ici';

  @override
  String get tutorialImportBody =>
      'Vous importez depuis une source distante — Reddit, Pixiv, Danbooru, Gelbooru, Pinterest, Pawchive — ou depuis un dossier de votre disque. Ce qui arrive attend ici jusqu\'à ce que vous l\'acceptiez : rien n\'entre sans que vous le voyiez.';

  @override
  String get tutorialContentTitle => 'Et voilà où tout apparaît';

  @override
  String get tutorialContentBody =>
      'Votre bibliothèque : tout ce que vous avez accepté. Un clic ouvre la visionneuse, le clic droit sort les actions, et vous pouvez en cocher plusieurs pour les traiter ensemble.';

  @override
  String get tutorialTagsTitle => 'Étiquetez en glissant';

  @override
  String get tutorialTagsBody =>
      'Les étiquettes du menu sont aussi des cibles : glissez un ou plusieurs contenus dessus et ils sont étiquetés. En cliquant sur l\'une d\'elles, la bibliothèque ne garde que ce qui la porte.';

  @override
  String get tutorialCreateTitle => 'Créer des choses';

  @override
  String get tutorialCreateBody =>
      'C\'est d\'ici que naissent créateurs, étiquettes, fernies et modèles. Un créateur, c\'est qui a fait la chose ; une étiquette, ce par quoi vous voulez regrouper ; un fernie, un visage ou un objet que FeRN doit apprendre.';

  @override
  String get tutorialSearchTitle => 'Chercher';

  @override
  String get tutorialSearchBody =>
      'Tapez et FeRN propose ce qui correspond : une étiquette, un créateur, une description. Ce que vous choisissez devient une pastille, et les pastilles s\'accumulent : deux montrent ce qui remplit les deux.';

  @override
  String get tutorialSettingsTitle => 'Et tout le reste est ici';

  @override
  String get tutorialSettingsBody =>
      'Langue, thème, dossiers, sources distantes, reconnaissance et verrou de contenu. Dans Aide se trouvent les neuf autres visites : une par sujet, et ensemble elles couvrent toute l\'application.';

  @override
  String get tourGeneralTitle => 'Visite générale';

  @override
  String get tourGeneralDescription =>
      'Ce qu\'est FeRN, à quoi sert chaque écran et où se trouve chaque chose. Commencez par ici.';

  @override
  String get tourImportingTitle => 'Importer et vérifier';

  @override
  String get tourImportingDescription =>
      'D\'où vient le contenu, comment on le vérifie et ce qu\'il faut pour qu\'il rejoigne la bibliothèque.';

  @override
  String get tourImporting1Title => 'D\'où et combien';

  @override
  String get tourImporting1Body =>
      'Choisissez la source — distante ou un dossier de cet ordinateur —, dites si vous voulez tout ou seulement le nouveau depuis la dernière fois, et appuyez sur Importer. Une source distante apporte vos favoris là-bas.';

  @override
  String get tourImporting2Title => 'Chaque source demande ses clés';

  @override
  String get tourImporting2Body =>
      'Les sources distantes ont besoin des identifiants de votre compte, dans Réglages → Sources distantes. Chacune explique comment les obtenir : ce ne sont pas votre mot de passe mais des clés prévues pour ça.';

  @override
  String get tourImporting3Title => 'Rien de tout ça n\'est encore à vous';

  @override
  String get tourImporting3Body =>
      'Cette grille est la boîte de réception : ce qui a été importé, en attente de votre décision. C\'est déjà sur votre disque, mais pas dans votre bibliothèque et ça n\'apparaît pas dans les recherches.';

  @override
  String get tourImporting4Title => 'Ouvrez-en un et décidez';

  @override
  String get tourImporting4Body =>
      'Un clic l\'ouvre dans la visionneuse. Là vous l\'enregistrez — il devient définitif — ou vous le rejetez : rejeter le sort de la base et demande si le fichier doit partir aussi.';

  @override
  String get tourImporting5Title => 'La fiche, sans quitter la visionneuse';

  @override
  String get tourImporting5Body =>
      'Le panneau latéral sert à lui donner créateur, étiquettes, description et liens. On l\'édite en le regardant, c\'est-à-dire quand on sait ce que c\'est. Enregistrer passe aussi au suivant.';

  @override
  String get tourManagersTitle => 'Étiquettes, personnes et créateurs';

  @override
  String get tourManagersDescription =>
      'Tout ce qui sert à ranger la bibliothèque : l\'arbre d\'étiquettes, les sœurs, les personnes, les créateurs et l\'étiquetage automatique.';

  @override
  String get tourManagers1Title => 'Les créateurs';

  @override
  String get tourManagers1Body =>
      'Un créateur, c\'est qui a fait la chose : un artiste, un compte, un studio. Chaque élément en a un, et un seul. En choisir un ici remplit l\'écran avec tout ce qui est à lui.';

  @override
  String get tourManagers2Title => 'Sa fiche';

  @override
  String get tourManagers2Body =>
      'Nom, avatar et les liens vers où il publie. Ces liens ne sont pas décoratifs : ce sont eux qui permettent à FeRN de mettre le créateur tout seul quand quelque chose arrive de ces adresses.';

  @override
  String get tourManagers3Title => 'Les avatars';

  @override
  String get tourManagers3Body =>
      'Cliquez l\'image et choisissez d\'où elle vient : un fichier de l\'ordinateur, ou votre bibliothèque. Depuis la bibliothèque, vous pouvez découper un carré dans n\'importe quelle image.';

  @override
  String get tourManagers4Title => 'Les étiquettes, pareil';

  @override
  String get tourManagers4Body =>
      'Avec une différence : un élément a un créateur, mais autant d\'étiquettes que vous voulez. Une étiquette, c\'est ce par quoi vous voulez regrouper : une série, une couleur, une ambiance, un lieu.';

  @override
  String get tourManagers5Title => 'Les étiquettes pendent les unes des autres';

  @override
  String get tourManagers5Body =>
      'Glissez-en une sur une autre et elle en dépend. C\'est là l\'intérêt : poser une étiquette fille pose aussi toutes celles au-dessus, donc ce qui porte un personnage ressort aussi sous sa série.';

  @override
  String get tourFernieTitle => 'Fernies et le mode fernie';

  @override
  String get tourFernieDescription =>
      'Ce qu\'est un fernie, d\'où viennent ses exemples et toutes les façons de marquer des régions.';

  @override
  String get tourFernie1Title => 'Ce qu\'est un fernie';

  @override
  String get tourFernie1Body =>
      'Un visage, un personnage ou un objet que FeRN doit apprendre à reconnaître. Ce n\'est pas une étiquette : une étiquette dit ce qu\'est une chose, un fernie est un exemple de son apparence.';

  @override
  String get tourFernie2Title => 'Reliez-le à quelque chose';

  @override
  String get tourFernie2Body =>
      'Chaque fernie peut pointer vers une étiquette ou un créateur. Ce lien transforme la reconnaissance en étiquetage : quand le fernie est trouvé, c\'est ça qui est proposé. Sans lien, il ne sert qu\'à entraîner.';

  @override
  String get tourFernie3Title => 'Ses régions';

  @override
  String get tourFernie3Body =>
      'Chaque découpe est un exemple, et ce sont ces exemples qui font apprendre un modèle. Plus il y en a et plus ils sont variés, mieux c\'est : sans variété, il apprend le fond au lieu de la chose.';

  @override
  String get tourFernie4Title => 'On les marque dans la visionneuse';

  @override
  String get tourFernie4Body =>
      'Ouvrez un élément et entrez en mode fernie. Avec l\'outil de marquage, tracez un cadre autour de ce que vous voulez et dites à qui il est. En vidéo et GIF, la région appartient à l\'image affichée.';

  @override
  String get tourFernie5Title => 'Corriger ce qui est marqué';

  @override
  String get tourFernie5Body =>
      'L\'autre outil sélectionne ce qui existe déjà : déplacer, redimensionner par les poignées, donner à un autre fernie ou supprimer. Rien n\'est écrit tant que vous ne sortez pas en enregistrant.';

  @override
  String get tourModelsTitle => 'Modèles et reconnaissance';

  @override
  String get tourModels1Title => 'Vos modèles';

  @override
  String get tourModels1Body =>
      'Un modèle, c\'est ce qui reconnaît vraiment. On le construit avec les fernies qu\'on lui donne, on l\'entraîne une fois, et ensuite il regarde votre contenu et dit ce qu\'il voit.';

  @override
  String get tourModels2Title => 'D\'abord, l\'environnement';

  @override
  String get tourModels2Body =>
      'La reconnaissance tourne sur Python, et FeRN l\'installe pour vous : Réglages → Reconnaissance, puis installer. Quelques centaines de mégaoctets, une seule fois. Avec une carte graphique, c\'est bien plus rapide.';

  @override
  String get tourModels3Title => 'En construire un';

  @override
  String get tourModels3Body =>
      'Vous choisissez ses fernies et ce qu\'il doit répondre : si chacun est là ou non, ou lequel il a trouvé et où. Le second demande au moins deux fernies et des régions tracées.';

  @override
  String get tourModels4Title => 'L\'entraînement prend du temps';

  @override
  String get tourModels4Body =>
      'De quelques minutes à plusieurs heures, selon ce que vous lui donnez et votre machine. Ça tourne en arrière-plan ; l\'indicateur du haut dit à quelle époque il en est et le temps restant approximatif.';

  @override
  String get tourModels5Title => 'Reconnaître';

  @override
  String get tourModels5Body =>
      'Un modèle entraîné passe en revue ce que vous lui donnez — un élément, une sélection ou toute la bibliothèque — et propose ce qu\'il voit. Sous son seuil de confiance, il ne propose rien.';

  @override
  String get tourDuplicatesTitle => 'Contenu en double';

  @override
  String get tourDuplicatesDescription =>
      'Comment on cherche les doublons, comment on décide quelle copie reste et ce qui fait que deux choses comptent comme identiques.';

  @override
  String get tourDuplicates1Title => 'Chercher les doublons';

  @override
  String get tourDuplicates1Body =>
      'Appuyez sur Chercher et FeRN parcourt toute la bibliothèque en calculant une empreinte de chaque élément. La première fois peut être longue ; ensuite, seul le nouveau est traité.';

  @override
  String get tourDuplicates2Title => 'Les groupes';

  @override
  String get tourDuplicates2Body =>
      'Chaque groupe rassemble des copies assez semblables pour être la même chose : la même image en deux tailles, ou enregistrée deux fois depuis des endroits différents. Les groupes déjà traités ne reviennent pas.';

  @override
  String get tourDuplicates3Title => 'On décide laquelle reste';

  @override
  String get tourDuplicates3Body =>
      'Vous choisissez la copie à garder et les autres sont écartées. Avant, vous pouvez fusionner dans celle qui reste les étiquettes, le créateur, le favori et la description des autres.';

  @override
  String get tourDuplicates4Title => 'Ou dire qu\'elles diffèrent';

  @override
  String get tourDuplicates4Body =>
      'Si le groupe se trompe, dites-le et il ne reviendra pas. Deux choses qui se ressemblent seulement ne sont pas un doublon, et vous seul le savez.';

  @override
  String get tourDuplicates5Title => 'Le seuil, dans les Réglages';

  @override
  String get tourDuplicates5Body =>
      'À quel point deux éléments peuvent différer tout en comptant comme identiques. L\'augmenter regroupe davantage et rapproche des choses qui se ressemblent seulement ; le baisser ne garde que les copies quasi identiques.';

  @override
  String get tourModelsDescription =>
      'L\'environnement Python, comment on construit et entraîne un modèle, ce qu\'il propose, et comment l\'arbre décide lesquels s\'exécutent.';

  @override
  String get tourModels6Title => 'Rien ne s\'applique tout seul';

  @override
  String get tourModels6Body =>
      'Ce qu\'il voit reste une suggestion jusqu\'à ce que vous l\'acceptiez, dans le panneau ou en masse depuis l\'écran d\'import. La refuser, c\'est dire de ne plus la proposer pour cet élément.';

  @override
  String get tourModels7Title => 'L\'arbre des modèles';

  @override
  String get tourModels7Body =>
      'Un modèle absent de l\'arbre ne s\'exécute jamais. L\'arbre dit lesquels tournent et dans quel ordre.';

  @override
  String get tourModels8Title => 'Les placer et les accrocher';

  @override
  String get tourModels8Body =>
      'Le panneau de droite contient les modèles hors de l\'arbre. Choisissez un nœud et ce que vous ajoutez en dépendra. Un modèle ne peut pas dépendre de lui-même ni figurer deux fois.';

  @override
  String get tourLibraryTitle => 'La bibliothèque et la visionneuse';

  @override
  String get tourLibraryDescription =>
      'La grille, en sélectionner plusieurs, le menu du clic droit et tout ce que sait faire la visionneuse.';

  @override
  String get tourSearchingTitle => 'Chercher et filtrer';

  @override
  String get tourSearchingDescription =>
      'Les pastilles qui s\'accumulent, le texte libre, les filtres de la barre et les autres façons de réduire ce que vous voyez.';

  @override
  String get tourNsfwTitle => 'Le verrou de contenu';

  @override
  String get tourNsfwDescription =>
      'Un mot de passe qui masque ce que vous marquez, ce qui disparaît avec, et son comportement ouvert et fermé.';

  @override
  String get tourFilesTitle => 'Fichiers et entretien';

  @override
  String get tourFilesDescription =>
      'Où vit votre contenu sur le disque, ce que FeRN fait de ces fichiers et comment faire le ménage.';

  @override
  String get tutorialViewerTitle => 'La visionneuse';

  @override
  String get tutorialViewerBody =>
      'Ouvrir quelque chose occupe tout l\'écran : molette pour zoomer, flèches pour passer de l\'un à l\'autre, et le panneau latéral pour lui donner créateur, étiquettes et description pendant que vous le regardez.';

  @override
  String get tutorialJobsTitle => 'Ce qui tourne en arrière-plan';

  @override
  String get tutorialJobsBody =>
      'Imports, reconnaissance, entraînements et recherche de doublons tournent en arrière-plan : cet indicateur dit ce qui se passe, où ça en est, et permet d\'arrêter. Vous pouvez continuer à utiliser FeRN.';

  @override
  String get tourImporting6Title => 'Ce que vous ne voulez plus revoir';

  @override
  String get tourImporting6Body =>
      'Une source distante propose les mêmes favoris à chaque fois. En rejetant, vous pouvez dire de ne plus le proposer : ce sera ignoré avant même le téléchargement, et la liste est dans Réglages → Base de données.';

  @override
  String get tourImporting7Title => 'Ce qui peut se faire tout seul';

  @override
  String get tourImporting7Body =>
      'Ce qui arrive peut s\'étiqueter tout seul si l\'adresse d\'origine est liée à une étiquette, être marqué NSFW si vous l\'activez en haut, et passer par vos modèles si vous le demandez dans les Réglages.';

  @override
  String get tourImporting8Title => 'D\'un coup';

  @override
  String get tourImporting8Body =>
      'Pas besoin d\'y aller un par un : cochez-en plusieurs et l\'en-tête permet de tout accepter, tout rejeter, ou d\'accepter d\'un coup les suggestions de vos modèles au-dessus d\'un seuil que vous choisissez.';

  @override
  String get tourImporting9Title => 'Et le voilà dans Contenu';

  @override
  String get tourImporting9Body =>
      'Ce que vous avez enregistré quitte la grille d\'import et apparaît dans la bibliothèque. Dès lors, il est cherchable, étiquetable et concerné par tout le reste.';

  @override
  String get tourLibrary1Title => 'Tout ce que vous avez';

  @override
  String get tourLibrary1Body =>
      'La grille respecte les proportions de chaque élément : on les reconnaît autant à leur silhouette qu\'à leur contenu. Le défilement charge la suite au fur et à mesure.';

  @override
  String get tourLibrary2Title => 'Plusieurs à la fois';

  @override
  String get tourLibrary2Body =>
      'Chaque cellule a une case dans son coin : cochez-en une et vous sélectionnez. Maj+clic étend la sélection jusque-là, dans l\'ordre affiché. Ce que vous faites ensuite s\'applique à tout.';

  @override
  String get tourLibrary3Title => 'Le clic droit';

  @override
  String get tourLibrary3Body =>
      'Sur n\'importe quelle cellule, il sort ce qu\'on peut faire : mettre en favori, envoyer à la corbeille, le reconnaître avec vos modèles ou ouvrir son dossier. Avec une sélection, il agit sur toute la sélection.';

  @override
  String get tourLibrary4Title => 'La corbeille rend les choses';

  @override
  String get tourLibrary4Body =>
      'Envoyer à la corbeille ne supprime pas : la chose y attend un temps et peut revenir avec tout ce qu\'elle avait. Vider la corbeille, c\'est ce qui supprime vraiment, et ça demande confirmation.';

  @override
  String get tourLibrary5Title => 'Trier et filtrer ici';

  @override
  String get tourLibrary5Body =>
      'L\'en-tête dit combien il y en a et permet de trier — le plus récent, le plus ancien, au hasard — et de ne garder que les images, que la vidéo, ou que ce qui vient d\'une source.';

  @override
  String get tourLibrary6Title => 'Dans la visionneuse';

  @override
  String get tourLibrary6Body =>
      'La molette zoome, le bouton du milieu — ou la barre d\'espace — déplace l\'image, et un double clic la réajuste à l\'écran. Les flèches passent au précédent et au suivant sans quitter.';

  @override
  String get tourLibrary7Title => 'Le panneau d\'informations';

  @override
  String get tourLibrary7Body =>
      'Créateur, étiquettes, description et liens, tout modifiable sur place. Il montre aussi ce que proposent vos modèles, et un bouton qui explique d\'où vient chaque étiquette de cet élément.';

  @override
  String get tourLibrary8Title => 'Favoris';

  @override
  String get tourLibrary8Body =>
      'Le cœur marque ce que vous voulez retrouver sans vous souvenir de comment vous l\'aviez étiqueté. Tout ce qui est marqué a son propre écran dans le menu.';

  @override
  String get tourLibrary9Title => 'Vidéo et animation';

  @override
  String get tourLibrary9Body =>
      'Les vidéos et les GIF se lisent dans la visionneuse avec une ligne de temps parcourable image par image. Ça compte plus tard : une région de fernie appartient à une image, pas à tout le clip.';

  @override
  String get tourManagers6Title => 'Et certaines vont ensemble';

  @override
  String get tourManagers6Body =>
      'En déposant l\'une sur l\'autre, on peut aussi les relier au lieu de les imbriquer : ce sont des sœurs. Ni au-dessus ni en dessous — poser l\'une pose aussi l\'autre, parce qu\'elles vont toujours ensemble.';

  @override
  String get tourManagers7Title => 'Les personnes sont des étiquettes';

  @override
  String get tourManagers7Body =>
      'Une étiquette peut être marquée comme personne : quelqu\'un ou un personnage présent dans le contenu. Ce n\'est qu\'une façon de ranger la liste — le bouton du haut bascule entre les deux — et ailleurs elles se comportent comme les autres.';

  @override
  String get tourManagers8Title => 'Étiqueter tout seul';

  @override
  String get tourManagers8Body =>
      'Une étiquette peut avoir des adresses liées. Tout ce qui arrive de ces adresses entre déjà étiqueté, avec ce qui est au-dessus et ses sœurs. C\'est de là que viendra l\'essentiel de votre étiquetage.';

  @override
  String get tourManagers9Title => 'Une longue liste, domptée';

  @override
  String get tourManagers9Body =>
      'Le chevron d\'une étiquette replie sa branche, et le champ de recherche au-dessus la trouve par son nom. Les deux marchent ici et dans le menu, et ce que vous repliez le reste la fois suivante.';

  @override
  String get tourManagers10Title => 'Étiqueter en masse';

  @override
  String get tourManagers10Body =>
      'Depuis la bibliothèque, glissez un ou plusieurs éléments sur une étiquette du menu. C\'est la façon rapide, et c\'est pour ça que ces étiquettes sont des cibles.';

  @override
  String get tourManagers11Title => 'D\'où vient cette étiquette ?';

  @override
  String get tourManagers11Body =>
      'FeRN étiquette tout seul par plusieurs chemins, et dans le panneau ils se ressemblent tous. Le bouton horloge de chaque élément explique chacune : vous l\'avez mise, une adresse correspondait, elle a été héritée, un modèle l\'a proposée, un fernie l\'a apportée.';

  @override
  String get tourSearching1Title => 'La barre de recherche';

  @override
  String get tourSearching1Body =>
      'Elle marche depuis n\'importe quel écran. Pendant que vous tapez, FeRN propose ce qui correspond : étiquettes, créateurs et contenus par leur description. Elle cherche dans votre bibliothèque, pas sur internet.';

  @override
  String get tourSearching2Title =>
      'Ce que vous choisissez devient une pastille';

  @override
  String get tourSearching2Body =>
      'Choisir une étiquette ou un créateur en fait une pastille. Une pastille cherche cette chose précise, pas son nom : le créateur Pompeu ramène ce qui est à lui, pas ce qui mentionne le mot.';

  @override
  String get tourSearching3Title => 'Les pastilles se croisent';

  @override
  String get tourSearching3Body =>
      'Deux pastilles montrent ce qui remplit les deux, pas l\'une ou l\'autre : cette étiquette, de ce créateur. C\'est tout leur intérêt. Retour arrière sur un champ vide enlève la dernière.';

  @override
  String get tourSearching4Title => 'Le texte libre';

  @override
  String get tourSearching4Body =>
      'Si ce que vous tapez n\'est ni une étiquette ni un créateur, appuyez sur Entrée : ça devient une pastille de texte libre, qui cherche dans les descriptions et les noms de fichiers.';

  @override
  String get tourSearching5Title => 'Restreindre le résultat';

  @override
  String get tourSearching5Body =>
      'Le filtre à côté de la barre décide quels types de résultats comptent et permet de ne garder que les images, que la vidéo, ou qu\'une source. Avec une seule pastille, il permet aussi d\'écarter des groupes entiers.';

  @override
  String get tourSearching6Title => 'Le menu filtre aussi';

  @override
  String get tourSearching6Body =>
      'Cliquer une étiquette du menu revient à poser sa pastille dans la barre : vous pouvez continuer de là — ajoutez un créateur, un mot. La barre montre toujours ce qui filtre.';

  @override
  String get tourSearching7Title => 'Chaque liste a le sien';

  @override
  String get tourSearching7Body =>
      'Les listes d\'étiquettes, de créateurs et de fernies ont leur propre filtre au-dessus. Celui-ci ne réduit que la liste affichée, sans toucher à ce que montre la grille.';

  @override
  String get tourFernie6Title => 'Quand l\'exemple, c\'est tout';

  @override
  String get tourFernie6Body =>
      'Un bouton marque l\'image entière d\'un coup, quand l\'élément n\'est rien d\'autre que la chose. Et sur la fiche d\'un fernie, un autre prend une étiquette entière et marque ainsi tout son contenu.';

  @override
  String get tourFernie7Title => 'D\'une suggestion à un exemple';

  @override
  String get tourFernie7Body =>
      'Quand un modèle a déjà proposé quelque chose, le panneau propose d\'en faire des régions : il dessine les cadres et vous acceptez les bons. C\'est la façon la plus rapide d\'enrichir un fernie.';

  @override
  String get tourFernie8Title => 'Marquer étiquette aussi';

  @override
  String get tourFernie8Body =>
      'Marquer une région, c\'est dire que ce fernie est là : ce qu\'il relie est posé aussitôt sur l\'élément. Le créateur seulement s\'il n\'en avait pas déjà un.';

  @override
  String get tourFernie9Title => 'Et ensuite on entraîne';

  @override
  String get tourFernie9Body =>
      'Les fernies seuls ne reconnaissent rien. Ce qui reconnaît, c\'est un modèle entraîné avec eux : c\'est la visite suivante.';

  @override
  String get tourModels9Title => 'Chaque branche a sa condition';

  @override
  String get tourModels9Body =>
      'Un enfant ne s\'exécute que si le parent détecte le fernie posé sur ce lien. C\'est là l\'astuce : un modèle général filtre, et seul ce qu\'il trouve passe aux spécialisés.';

  @override
  String get tourModels10Title => 'Quand ça s\'est mal passé';

  @override
  String get tourModels10Body =>
      'On peut arrêter un entraînement en cours, et faire oublier à un modèle ce qu\'il a appris : ses poids partent, il redevient non entraîné, mais ses fernies, ses réglages et sa place dans l\'arbre restent.';

  @override
  String get tourDuplicates6Title => 'Et il cherche tout seul';

  @override
  String get tourDuplicates6Body =>
      'De temps en temps, FeRN repasse tout seul et prévient s\'il trouve quelque chose. Cette période est aussi dans les Réglages, tout comme le fait de la désactiver.';

  @override
  String get tourNsfw1Title => 'Ce qu\'est le verrou';

  @override
  String get tourNsfw1Body =>
      'Un mot de passe qui masque une partie de votre bibliothèque. Ce que vous marquez NSFW disparaît tant que le verrou est fermé : ni dans la grille, ni dans les recherches, ni dans les comptes.';

  @override
  String get tourNsfw2Title => 'Le mettre en place';

  @override
  String get tourNsfw2Body =>
      'Dans Réglages, section verrou, vous définissez un mot de passe. FeRN vous donne alors un code de récupération : notez-le. C\'est la seule façon de revenir, car le mot de passe n\'est stocké nulle part.';

  @override
  String get tourNsfw3Title => 'Ouvrir et fermer';

  @override
  String get tourNsfw3Body =>
      'Ouvrir demande le mot de passe ; fermer ne demande rien et est immédiat. Vous pouvez lui faire retenir qu\'il est ouvert d\'une session à l\'autre, ou le faire démarrer fermé à chaque fois.';

  @override
  String get tourNsfw4Title => 'Marquer une étiquette ou un créateur';

  @override
  String get tourNsfw4Body =>
      'Leurs fiches ont un bouton de verrou. Marquer une étiquette masque tout ce qui la porte, et tout ce qui en dépend dans l\'arbre. Marquer un créateur le masque, lui et tout son contenu.';

  @override
  String get tourNsfw5Title => 'Ou un élément isolé';

  @override
  String get tourNsfw5Body =>
      'N\'importe quel élément peut être marqué depuis la visionneuse, quelles que soient ses étiquettes. Et à l\'import, vous pouvez faire entrer tout ce qui arrive déjà marqué : ça évite d\'en marquer cinquante à la main.';

  @override
  String get tourNsfw6Title => 'Comment il se comporte';

  @override
  String get tourNsfw6Body =>
      'Vous choisissez ce que « fermé » veut dire : le contenu marqué disparaît, ou apparaît flouté pour qu\'on sache qu\'il est là. Et si ouvrir montre tout ou seulement ce qui est marqué.';

  @override
  String get tourNsfw7Title => 'Les liens aussi se marquent';

  @override
  String get tourNsfw7Body =>
      'Une étiquette ou un créateur peuvent avoir des adresses marquées : elles ne s\'affichent pas verrou fermé, mais continuent d\'étiqueter ce qui en arrive. Masquer une adresse n\'est pas l\'oublier.';

  @override
  String get tourNsfw8Title => 'Tout supprimer';

  @override
  String get tourNsfw8Body =>
      'Dans Réglages → Base de données, vous pouvez vider seulement ce qui est marqué : le contenu seul ; étiquettes, créateurs, fernies et modèles restent. Proposé uniquement verrou ouvert : fermé, ce serait supprimer à l\'aveugle.';

  @override
  String get tourFiles1Title => 'Où vit votre contenu';

  @override
  String get tourFiles1Body =>
      'FeRN tient une base de données de ce qu\'il sait, et les fichiers restent sur votre disque. Dans les Réglages, vous choisissez le dossier de la bibliothèque : c\'est là qu\'atterrit ce que vous importez.';

  @override
  String get tourFiles2Title => 'Surveiller un dossier à vous';

  @override
  String get tourFiles2Body =>
      'Vous pouvez pointer FeRN vers un dossier existant et importer ce qu\'il contient. À vous de décider s\'il copie les fichiers dans la bibliothèque ou les laisse en place en s\'en souvenant.';

  @override
  String get tourFiles3Title => 'Ranger tout seul';

  @override
  String get tourFiles3Body =>
      'FeRN peut classer ce qu\'il gère en dossiers par source, par créateur ou par date, pour que le disque ressemble à la bibliothèque. Si vous changez d\'avis, il déplace ce qui existe déjà.';

  @override
  String get tourFiles4Title => 'Le dossier des avatars';

  @override
  String get tourFiles4Body =>
      'Les avatars sont des copies faites par FeRN : ils vivent dans leur propre dossier, que vous choisissez aussi. Changer de dossier déplace son contenu : rien ne perd son image.';

  @override
  String get tourFiles5Title => 'Déplacer la bibliothèque';

  @override
  String get tourFiles5Body =>
      'Si vous pointez la bibliothèque vers un autre disque, FeRN propose d\'y déplacer ce qu\'il gère et de mettre à jour tous ses chemins. C\'est une opération longue : il vous dit comment ça s\'est passé.';

  @override
  String get tourFiles6Title => 'Des fichiers que personne n\'utilise';

  @override
  String get tourFiles6Body =>
      'Avec le temps, des orphelins s\'accumulent : avatars remplacés, téléchargements dont la fiche a été rejetée, poids d\'un modèle disparu. Le bouton de nettoyage les trouve, dit ce qu\'ils pèsent et demande avant de supprimer.';

  @override
  String get tourFiles7Title => 'Repartir de zéro';

  @override
  String get tourFiles7Body =>
      'Vider la base de données est la seule chose ici sans retour, et elle demande deux fois. Vous choisissez si les fichiers partent avec : sinon, ils restent en place et une analyse les ramène.';

  @override
  String get tourFiles8Title => 'Et il prévient quand c\'est fini';

  @override
  String get tourFiles8Body =>
      'Les tâches longues — importer, entraîner, reconnaître, chercher les doublons — peuvent vous prévenir à la fin, avec ou sans son. C\'est aussi dans les Réglages, et vous choisissez lesquelles.';

  @override
  String get viewerVolume => 'Volume';

  @override
  String get tagNameTaken => 'Une étiquette porte déjà ce nom';

  @override
  String get filterByNameHint => 'Filtrer par nom';

  @override
  String tagDropAsChild(String name) {
    return 'Rattacher à « $name »';
  }

  @override
  String tagDropAsSibling(String name) {
    return 'Associer à « $name »';
  }

  @override
  String get importStopping => 'Arrêt de l’importation…';
}
