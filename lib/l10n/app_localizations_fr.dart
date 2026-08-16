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
}
