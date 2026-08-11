// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navMedia => 'Media';

  @override
  String get navImport => 'Import';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navDeleted => 'Deleted';

  @override
  String get searchHint => 'Search';

  @override
  String get menuNewCreator => 'New creator';

  @override
  String get menuNewTag => 'New tag';

  @override
  String get menuNewCollection => 'New collection';

  @override
  String get collectionsWip => 'Collections are still a work in progress';

  @override
  String get mobileLayoutWip => 'Mobile layout coming soon';

  @override
  String mediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media',
      one: '1 media',
      zero: 'No media',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String get emptyLibrary => 'This looks a little empty';

  @override
  String mediaFetched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media fetched',
      one: '1 media fetched',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get actionImport => 'Import';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSave => 'Save';

  @override
  String get sourceLocalComputer => 'Local computer';

  @override
  String get selectItem => 'Select';

  @override
  String get deselectItem => 'Deselect';

  @override
  String get mediaInfoTitle => 'Media Info';

  @override
  String get descriptionHint => 'Add a description';

  @override
  String get createdBy => 'Created by:';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get addTag => 'Add Tag';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get tagNameSearchLabel => 'Tag name';

  @override
  String get tagSearchHint => 'Tag';

  @override
  String get createTag => 'Create Tag';

  @override
  String get searchCreatorLabel => 'Search Creator';

  @override
  String get creatorSearchHint => 'Name';

  @override
  String get createCreator => 'Create Creator';

  @override
  String get newTagTitle => 'New Tag';

  @override
  String get tagNameLabel => 'Tag Name';

  @override
  String get parentTagLabel => 'Parent tag (Optional)';

  @override
  String get newCreatorTitle => 'New Creator';

  @override
  String get creatorNameLabel => 'Creator Name';

  @override
  String get socialProfilesLabel => 'Social profiles';

  @override
  String get enterNameHint => 'Enter name';

  @override
  String get searchEllipsisHint => 'Search...';

  @override
  String get profileLinkHint => 'Profile link';

  @override
  String get addProfile => 'Add profile';

  @override
  String get resultTypeMedia => 'media';

  @override
  String get resultTypeTag => 'tag';

  @override
  String get resultTypeCreator => 'creator';

  @override
  String get noFolderSelected => 'No folder selected';

  @override
  String get chooseFolder => 'Choose folder';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsFiles => 'Files';

  @override
  String get languageSectionTitle => 'Application language';

  @override
  String get languageSectionNote =>
      'Every screen switches over as soon as you pick a language.';

  @override
  String get filesLocalTitle => 'Local files';

  @override
  String get syncLocalFiles => 'Sync local files';

  @override
  String get syncLocalFilesDescription =>
      'Fern moves the media it works with into a folder of its own, both what is already imported and what comes next.';

  @override
  String get libraryFolder => 'Library folder';

  @override
  String get copyFiles => 'Copy files';

  @override
  String get copyFilesDescription =>
      'Keep the original file where it was and work with a copy inside the library folder.';

  @override
  String get avatarsTitle => 'Avatars';

  @override
  String get avatarsDescription =>
      'Avatar images are always copied into their own folder, whether local files are synced or not. Changing the folder brings the existing avatars along.';

  @override
  String get avatarsFolder => 'Avatars folder';

  @override
  String get organizationTitle => 'Organization';

  @override
  String get organizationDescription =>
      'How the files are laid out inside the library folder. It does not affect avatar images.';

  @override
  String get organizationFlat => 'All files together';

  @override
  String get organizationFlatDescription =>
      'Every file sits directly in the library folder';

  @override
  String get organizationByTag => 'Subfolders by tag';

  @override
  String get organizationByTagDescription =>
      'One folder per tag, taken from the first tag of the content';

  @override
  String get organizationBySource => 'Subfolders by source';

  @override
  String get organizationBySourceDescription =>
      'One folder per origin: local, Pixiv, Twitter...';

  @override
  String get organizationByCreator => 'Subfolders by creator';

  @override
  String get organizationByCreatorDescription => 'One folder per creator';

  @override
  String get migrationTitle => 'Migration';

  @override
  String get migrationDescription =>
      'Sort every file already in the library with the criteria above.';

  @override
  String get migrateFiles => 'Migrate files';

  @override
  String avatarsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avatars moved to the new folder',
      one: '1 avatar moved to the new folder',
      zero: 'The avatars were already in that folder',
    );
    return '$_temp0';
  }

  @override
  String get avatarsMoveFailed => 'The avatars could not be moved';

  @override
  String filesOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files moved',
      one: '1 file moved',
      zero: 'Everything was already in place',
    );
    return '$_temp0';
  }

  @override
  String get filesOrganizeFailed => 'The files could not be organized';
}
