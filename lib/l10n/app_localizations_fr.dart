// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get sourceNotConfigured => 'Non configurée';

  @override
  String get selectItem => 'Sélectionner';

  @override
  String get deselectItem => 'Désélectionner';

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
