import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @navGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get navGallery;

  /// No description provided for @navTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get navTags;

  /// No description provided for @navMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get navMedia;

  /// No description provided for @navImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get navImport;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get navDeleted;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @menuNewCreator.
  ///
  /// In en, this message translates to:
  /// **'New creator'**
  String get menuNewCreator;

  /// No description provided for @menuNewTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get menuNewTag;

  /// No description provided for @menuNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get menuNewCollection;

  /// No description provided for @collectionsWip.
  ///
  /// In en, this message translates to:
  /// **'Collections are still a work in progress'**
  String get collectionsWip;

  /// No description provided for @mobileLayoutWip.
  ///
  /// In en, this message translates to:
  /// **'Mobile layout coming soon'**
  String get mobileLayoutWip;

  /// No description provided for @mediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No media} =1{1 media} other{{count} media}}'**
  String mediaCount(int count);

  /// No description provided for @favoritesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No favorites yet} =1{1 favorite} other{{count} favorites}}'**
  String favoritesCount(int count);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @emptyLibrary.
  ///
  /// In en, this message translates to:
  /// **'This looks a little empty'**
  String get emptyLibrary;

  /// No description provided for @mediaFetched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media fetched} other{{count} media fetched}}'**
  String mediaFetched(int count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing marked for deletion} =1{1 media marked for deletion} other{{count} media marked for deletion}}'**
  String deletedCount(int count);

  /// No description provided for @deletedRetentionNotice.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Marked media is deleted for good after 1 day} other{Marked media is deleted for good after {days} days}}'**
  String deletedRetentionNotice(int days);

  /// No description provided for @deleteForeverTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently from the database'**
  String get deleteForeverTooltip;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @sourceLocalComputer.
  ///
  /// In en, this message translates to:
  /// **'Local computer'**
  String get sourceLocalComputer;

  /// No description provided for @selectItem.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectItem;

  /// No description provided for @deselectItem.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get deselectItem;

  /// No description provided for @mediaInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Info'**
  String get mediaInfoTitle;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get descriptionHint;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by:'**
  String get createdBy;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @tagNameSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameSearchLabel;

  /// No description provided for @tagSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tagSearchHint;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get createTag;

  /// No description provided for @searchCreatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Creator'**
  String get searchCreatorLabel;

  /// No description provided for @creatorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get creatorSearchHint;

  /// No description provided for @createCreator.
  ///
  /// In en, this message translates to:
  /// **'Create Creator'**
  String get createCreator;

  /// No description provided for @newTagTitle.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get newTagTitle;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagNameLabel;

  /// No description provided for @parentTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent tag (Optional)'**
  String get parentTagLabel;

  /// No description provided for @newCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'New Creator'**
  String get newCreatorTitle;

  /// No description provided for @creatorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Creator Name'**
  String get creatorNameLabel;

  /// No description provided for @socialProfilesLabel.
  ///
  /// In en, this message translates to:
  /// **'Social profiles'**
  String get socialProfilesLabel;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterNameHint;

  /// No description provided for @searchEllipsisHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchEllipsisHint;

  /// No description provided for @profileLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Profile link'**
  String get profileLinkHint;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get addProfile;

  /// No description provided for @resultTypeMedia.
  ///
  /// In en, this message translates to:
  /// **'media'**
  String get resultTypeMedia;

  /// No description provided for @resultTypeTag.
  ///
  /// In en, this message translates to:
  /// **'tag'**
  String get resultTypeTag;

  /// No description provided for @resultTypeCreator.
  ///
  /// In en, this message translates to:
  /// **'creator'**
  String get resultTypeCreator;

  /// No description provided for @noFolderSelected.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get noFolderSelected;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get chooseFolder;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settingsFiles;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get languageSectionTitle;

  /// No description provided for @languageSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Every screen switches over as soon as you pick a language.'**
  String get languageSectionNote;

  /// No description provided for @filesLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Local files'**
  String get filesLocalTitle;

  /// No description provided for @syncLocalFiles.
  ///
  /// In en, this message translates to:
  /// **'Sync local files'**
  String get syncLocalFiles;

  /// No description provided for @syncLocalFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern moves the media it works with into a folder of its own, both what is already imported and what comes next.'**
  String get syncLocalFilesDescription;

  /// No description provided for @libraryFolder.
  ///
  /// In en, this message translates to:
  /// **'Library folder'**
  String get libraryFolder;

  /// No description provided for @copyFiles.
  ///
  /// In en, this message translates to:
  /// **'Copy files'**
  String get copyFiles;

  /// No description provided for @copyFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep the original file where it was and work with a copy inside the library folder.'**
  String get copyFilesDescription;

  /// No description provided for @avatarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get avatarsTitle;

  /// No description provided for @avatarsDescription.
  ///
  /// In en, this message translates to:
  /// **'Avatar images are always copied into their own folder, whether local files are synced or not. Changing the folder brings the existing avatars along.'**
  String get avatarsDescription;

  /// No description provided for @avatarsFolder.
  ///
  /// In en, this message translates to:
  /// **'Avatars folder'**
  String get avatarsFolder;

  /// No description provided for @organizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationTitle;

  /// No description provided for @organizationDescription.
  ///
  /// In en, this message translates to:
  /// **'How the files are laid out inside the library folder. It does not affect avatar images.'**
  String get organizationDescription;

  /// No description provided for @organizationFlat.
  ///
  /// In en, this message translates to:
  /// **'All files together'**
  String get organizationFlat;

  /// No description provided for @organizationFlatDescription.
  ///
  /// In en, this message translates to:
  /// **'Every file sits directly in the library folder'**
  String get organizationFlatDescription;

  /// No description provided for @organizationByTag.
  ///
  /// In en, this message translates to:
  /// **'Subfolders by tag'**
  String get organizationByTag;

  /// No description provided for @organizationByTagDescription.
  ///
  /// In en, this message translates to:
  /// **'One folder per tag, taken from the first tag of the content'**
  String get organizationByTagDescription;

  /// No description provided for @organizationBySource.
  ///
  /// In en, this message translates to:
  /// **'Subfolders by source'**
  String get organizationBySource;

  /// No description provided for @organizationBySourceDescription.
  ///
  /// In en, this message translates to:
  /// **'One folder per origin: local, Pixiv, Twitter...'**
  String get organizationBySourceDescription;

  /// No description provided for @organizationByCreator.
  ///
  /// In en, this message translates to:
  /// **'Subfolders by creator'**
  String get organizationByCreator;

  /// No description provided for @organizationByCreatorDescription.
  ///
  /// In en, this message translates to:
  /// **'One folder per creator'**
  String get organizationByCreatorDescription;

  /// No description provided for @migrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration'**
  String get migrationTitle;

  /// No description provided for @migrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Sort every file already in the library with the criteria above.'**
  String get migrationDescription;

  /// No description provided for @migrateFiles.
  ///
  /// In en, this message translates to:
  /// **'Migrate files'**
  String get migrateFiles;

  /// No description provided for @avatarsMoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The avatars were already in that folder} =1{1 avatar moved to the new folder} other{{count} avatars moved to the new folder}}'**
  String avatarsMoved(int count);

  /// No description provided for @avatarsMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'The avatars could not be moved'**
  String get avatarsMoveFailed;

  /// No description provided for @filesOrganized.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything was already in place} =1{1 file moved} other{{count} files moved}}'**
  String filesOrganized(int count);

  /// No description provided for @filesOrganizeFailed.
  ///
  /// In en, this message translates to:
  /// **'The files could not be organized'**
  String get filesOrganizeFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
