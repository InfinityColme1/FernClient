// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navMedia => 'Médias';

  @override
  String get navImport => 'Importer';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navDeleted => 'Supprimés';

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
  String get filters => 'Filtres';

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
  String get actionImport => 'Importer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get sourceLocalComputer => 'Ordinateur local';

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
  String get settingsFiles => 'Fichiers';

  @override
  String get languageSectionTitle => 'Langue de l\'application';

  @override
  String get languageSectionNote =>
      'Toute l\'application change de langue dès que vous en choisissez une.';

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
}
