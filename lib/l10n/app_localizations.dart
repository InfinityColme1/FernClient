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

  /// No description provided for @navCreatorManager.
  ///
  /// In en, this message translates to:
  /// **'Creator Manager'**
  String get navCreatorManager;

  /// No description provided for @navTagManager.
  ///
  /// In en, this message translates to:
  /// **'Tag Manager'**
  String get navTagManager;

  /// No description provided for @navBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get navBrowser;

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

  /// No description provided for @filtersResultsFrom.
  ///
  /// In en, this message translates to:
  /// **'Show results from'**
  String get filtersResultsFrom;

  /// No description provided for @filterMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get filterMedia;

  /// No description provided for @filterTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get filterTags;

  /// No description provided for @filterCreators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get filterCreators;

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
  /// **'{days, plural, =1{Deleted for good after 1 day} other{Deleted for good after {days} days}}'**
  String deletedRetentionNotice(int days);

  /// No description provided for @deleteForeverTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently from the database'**
  String get deleteForeverTooltip;

  /// No description provided for @remoteImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Media is about to be imported from {source}'**
  String remoteImportWarning(String source);

  /// No description provided for @remoteImportAmountAll.
  ///
  /// In en, this message translates to:
  /// **'Everything saved in your account will be fetched.'**
  String get remoteImportAmountAll;

  /// No description provided for @remoteImportAmountSinceLast.
  ///
  /// In en, this message translates to:
  /// **'Whatever you have saved since the last import will be fetched.'**
  String get remoteImportAmountSinceLast;

  /// No description provided for @remoteImportAmountLimited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media at most will be fetched.} other{{count} media at most will be fetched.}}'**
  String remoteImportAmountLimited(int count);

  /// No description provided for @favoriteSelectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark the selection as favourite'**
  String get favoriteSelectedTooltip;

  /// No description provided for @deleteSelectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move the selection to the deleted screen'**
  String get deleteSelectedTooltip;

  /// No description provided for @deleteTrashWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media is about to be deleted for good} other{{count} media are about to be deleted for good}}'**
  String deleteTrashWarning(int count);

  /// No description provided for @deleteDiscardWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media is about to be discarded} other{{count} media are about to be discarded}}'**
  String deleteDiscardWarning(int count);

  /// No description provided for @deleteFilesFromDisk.
  ///
  /// In en, this message translates to:
  /// **'Delete the files from the disk as well'**
  String get deleteFilesFromDisk;

  /// No description provided for @deleteFilesFromDiskDescription.
  ///
  /// In en, this message translates to:
  /// **'If you clear it, the media leaves the database but its files stay where they are, so a later scan can pick them up again.'**
  String get deleteFilesFromDiskDescription;

  /// No description provided for @actionStopImport.
  ///
  /// In en, this message translates to:
  /// **'Stop the import'**
  String get actionStopImport;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get actionSelectFolder;

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

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hidePassword;

  /// No description provided for @actionUnassignTag.
  ///
  /// In en, this message translates to:
  /// **'Unassign tag'**
  String get actionUnassignTag;

  /// No description provided for @actionRemoveParentTag.
  ///
  /// In en, this message translates to:
  /// **'Remove parent'**
  String get actionRemoveParentTag;

  /// No description provided for @actionDeleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get actionDeleteTag;

  /// No description provided for @actionUnassignCreator.
  ///
  /// In en, this message translates to:
  /// **'Unassign creator'**
  String get actionUnassignCreator;

  /// No description provided for @actionDeleteCreator.
  ///
  /// In en, this message translates to:
  /// **'Delete creator'**
  String get actionDeleteCreator;

  /// No description provided for @sourceLocalComputer.
  ///
  /// In en, this message translates to:
  /// **'Local computer'**
  String get sourceLocalComputer;

  /// No description provided for @sourceAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sourceAll;

  /// No description provided for @sourceBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get sourceBrowser;

  /// No description provided for @sourceBrowserNote.
  ///
  /// In en, this message translates to:
  /// **'Open the browser'**
  String get sourceBrowserNote;

  /// No description provided for @sourceBrowserHint.
  ///
  /// In en, this message translates to:
  /// **'This content is not fetched from here: you pick it page by page on the Browser screen.'**
  String get sourceBrowserHint;

  /// No description provided for @sourceNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not set up yet'**
  String get sourceNotConfigured;

  /// No description provided for @sourceLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in to {source}'**
  String sourceLogIn(String source);

  /// No description provided for @sourceLogInHint.
  ///
  /// In en, this message translates to:
  /// **'Opens {source} in Fern\'s browser. Once you are in, press the key button there to save the session and come back.'**
  String sourceLogInHint(String source);

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

  /// No description provided for @creatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get creatorsTitle;

  /// No description provided for @noCreatorsYet.
  ///
  /// In en, this message translates to:
  /// **'No creators yet'**
  String get noCreatorsYet;

  /// No description provided for @noSocialProfiles.
  ///
  /// In en, this message translates to:
  /// **'No social profiles'**
  String get noSocialProfiles;

  /// No description provided for @openProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open the profile in the browser'**
  String get openProfileTooltip;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get editProfileTooltip;

  /// No description provided for @doneEditingProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Done editing'**
  String get doneEditingProfileTooltip;

  /// No description provided for @removeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get removeProfileTooltip;

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

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settingsFiles;

  /// No description provided for @settingsRemoteSources.
  ///
  /// In en, this message translates to:
  /// **'Remote sources'**
  String get settingsRemoteSources;

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

  /// No description provided for @sidebarSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Side menu'**
  String get sidebarSectionTitle;

  /// No description provided for @sidebarSectionNote.
  ///
  /// In en, this message translates to:
  /// **'How the tag list of the side menu is drawn.'**
  String get sidebarSectionNote;

  /// No description provided for @showListAvatars.
  ///
  /// In en, this message translates to:
  /// **'Show avatars in the list'**
  String get showListAvatars;

  /// No description provided for @showListAvatarsDescription.
  ///
  /// In en, this message translates to:
  /// **'Each tag is drawn with its own picture instead of the shared icon, so you can tell them apart while the menu is collapsed. Tags without a picture keep the icon.'**
  String get showListAvatarsDescription;

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

  /// No description provided for @redditTitle.
  ///
  /// In en, this message translates to:
  /// **'Reddit'**
  String get redditTitle;

  /// No description provided for @redditDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern downloads what you have saved in your Reddit account. Register a script application at reddit.com/prefs/apps to get the two keys.'**
  String get redditDescription;

  /// No description provided for @redditClientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get redditClientId;

  /// No description provided for @redditClientIdHint.
  ///
  /// In en, this message translates to:
  /// **'The key under the name of your application'**
  String get redditClientIdHint;

  /// No description provided for @redditClientSecret.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get redditClientSecret;

  /// No description provided for @redditClientSecretHint.
  ///
  /// In en, this message translates to:
  /// **'The secret of your application'**
  String get redditClientSecretHint;

  /// No description provided for @redditUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get redditUsername;

  /// No description provided for @redditUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your Reddit account, without /u/'**
  String get redditUsernameHint;

  /// No description provided for @redditPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get redditPassword;

  /// No description provided for @redditPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'The password of that account'**
  String get redditPasswordHint;

  /// No description provided for @redditCredentialsNote.
  ///
  /// In en, this message translates to:
  /// **'The credentials stay on this computer and are only used to talk to Reddit.'**
  String get redditCredentialsNote;

  /// No description provided for @settingsBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get settingsBrowser;

  /// No description provided for @browserHome.
  ///
  /// In en, this message translates to:
  /// **'Home page'**
  String get browserHome;

  /// No description provided for @browserHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home page'**
  String get browserHomeTitle;

  /// No description provided for @browserHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Where Fern\'s browser starts when you press the home button. It does not affect where it opens: coming back to the screen leaves the browser on the last page you visited.'**
  String get browserHomeDescription;

  /// No description provided for @browserHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get browserHomeLabel;

  /// No description provided for @credentialsRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'{source} did not accept your credentials'**
  String credentialsRejectedTitle(String source);

  /// No description provided for @credentialsRejectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Nothing could be imported: {source} turned down the account or the key it was given. Check them in Settings, under Remote sources.'**
  String credentialsRejectedDescription(String source);

  /// No description provided for @actionOpenRemoteSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenRemoteSettings;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {source} session is no longer valid'**
  String sessionExpiredTitle(String source);

  /// No description provided for @sessionExpiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern could not import anything: {source} has rejected the saved session. Log in again in the browser and press the key button there to save the new one.'**
  String sessionExpiredDescription(String source);

  /// No description provided for @browserImportedInto.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media ready to review under {source}} other{{count} media ready to review under {source}}}'**
  String browserImportedInto(int count, String source);

  /// No description provided for @browserImportKnown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 was already in the library} other{{count} were already in the library}}'**
  String browserImportKnown(int count);

  /// No description provided for @browserImportFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 could not be downloaded} other{{count} could not be downloaded}}'**
  String browserImportFailed(int count);

  /// No description provided for @browserImportNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing was brought in.'**
  String get browserImportNothing;

  /// No description provided for @danbooruTitle.
  ///
  /// In en, this message translates to:
  /// **'Danbooru'**
  String get danbooruTitle;

  /// No description provided for @danbooruDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern downloads the posts you have favourited on Danbooru. Its API is public: all it needs is your account name and an API key.'**
  String get danbooruDescription;

  /// No description provided for @danbooruUsername.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get danbooruUsername;

  /// No description provided for @danbooruUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your Danbooru user name'**
  String get danbooruUsernameHint;

  /// No description provided for @danbooruApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get danbooruApiKey;

  /// No description provided for @danbooruApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'A key from your Danbooru profile'**
  String get danbooruApiKeyHint;

  /// No description provided for @danbooruApiKeyNote.
  ///
  /// In en, this message translates to:
  /// **'On Danbooru, open your profile, go to API Key and create one. It is not your password: you can revoke it whenever you like without changing anything else. It stays on this computer and is only used to talk to Danbooru.'**
  String get danbooruApiKeyNote;

  /// No description provided for @gelbooruTitle.
  ///
  /// In en, this message translates to:
  /// **'Gelbooru'**
  String get gelbooruTitle;

  /// No description provided for @gelbooruDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern downloads the posts you have favourited on Gelbooru. Its favourites API is slower than the rest: it hands out references rather than posts, so each one has to be asked for separately.'**
  String get gelbooruDescription;

  /// No description provided for @gelbooruUserId.
  ///
  /// In en, this message translates to:
  /// **'Account id'**
  String get gelbooruUserId;

  /// No description provided for @gelbooruUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'The number of your Gelbooru account'**
  String get gelbooruUserIdHint;

  /// No description provided for @gelbooruApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get gelbooruApiKey;

  /// No description provided for @gelbooruApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'The key of that account'**
  String get gelbooruApiKeyHint;

  /// No description provided for @gelbooruApiKeyNote.
  ///
  /// In en, this message translates to:
  /// **'On Gelbooru, go to My Account, then Options, and look for API Access Credentials: both the id and the key are there. They stay on this computer and are only used to talk to Gelbooru.'**
  String get gelbooruApiKeyNote;

  /// No description provided for @pinterestTitle.
  ///
  /// In en, this message translates to:
  /// **'Pinterest'**
  String get pinterestTitle;

  /// No description provided for @pinterestDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern downloads what you have saved on Pinterest. Whatever is in public boards needs nothing but your account name.'**
  String get pinterestDescription;

  /// No description provided for @pinterestUsername.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get pinterestUsername;

  /// No description provided for @pinterestUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your Pinterest user name'**
  String get pinterestUsernameHint;

  /// No description provided for @pinterestSecretBoardsNote.
  ///
  /// In en, this message translates to:
  /// **'To bring in what you keep in secret boards, log in to Pinterest from Fern’s browser and press the key button there: the session is saved along with the name.'**
  String get pinterestSecretBoardsNote;

  /// No description provided for @browserAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address of a site'**
  String get browserAddressHint;

  /// No description provided for @browserBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get browserBack;

  /// No description provided for @browserForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get browserForward;

  /// No description provided for @browserReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get browserReload;

  /// No description provided for @browserSaveSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Save the session of this site so Fern can import from it'**
  String get browserSaveSessionHint;

  /// No description provided for @browserFindMediaHint.
  ///
  /// In en, this message translates to:
  /// **'Look for media on this page'**
  String get browserFindMediaHint;

  /// No description provided for @browserImportAction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1} other{Import {count}}}'**
  String browserImportAction(int count);

  /// No description provided for @browserSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select or clear all'**
  String get browserSelectAll;

  /// No description provided for @browserClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get browserClose;

  /// No description provided for @browserNoSession.
  ///
  /// In en, this message translates to:
  /// **'Fern cannot import from this site, so there is no session to save here.'**
  String get browserNoSession;

  /// No description provided for @browserSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'{source} session saved.'**
  String browserSessionSaved(String source);

  /// No description provided for @browserSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'There is no {source} session open here yet: log in first.'**
  String browserSessionMissing(String source);

  /// No description provided for @browserNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No media found on this page.'**
  String get browserNothingFound;

  /// No description provided for @browserFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media found} other{{count} media found}}'**
  String browserFound(int count);

  /// No description provided for @browserImporting.
  ///
  /// In en, this message translates to:
  /// **'Downloading {done} of {total}…'**
  String browserImporting(int done, int total);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'The import could not be completed: {error}'**
  String importFailed(String error);

  /// No description provided for @importLimitAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get importLimitAll;

  /// No description provided for @importLimitSinceLast.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get importLimitSinceLast;

  /// No description provided for @importLimitSinceLastTooltip.
  ///
  /// In en, this message translates to:
  /// **'Only what has been saved since the last import'**
  String get importLimitSinceLastTooltip;

  /// No description provided for @importLimitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Most items a scan brings in'**
  String get importLimitTooltip;

  /// No description provided for @lastImportNever.
  ///
  /// In en, this message translates to:
  /// **'Never imported'**
  String get lastImportNever;

  /// No description provided for @sourceNotConfiguredHint.
  ///
  /// In en, this message translates to:
  /// **'Set this source up in Settings before importing from it'**
  String get sourceNotConfiguredHint;

  /// No description provided for @lastImportHint.
  ///
  /// In en, this message translates to:
  /// **'When this source was last checked for new content'**
  String get lastImportHint;

  /// No description provided for @lastImportMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Just now} =1{1 min ago} other{{count} min ago}}'**
  String lastImportMinutes(int count);

  /// No description provided for @lastImportHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 h ago} other{{count} h ago}}'**
  String lastImportHours(int count);

  /// No description provided for @lastImportDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String lastImportDays(int count);

  /// No description provided for @assignUrlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked addresses'**
  String get assignUrlsTitle;

  /// No description provided for @assignUrlsTo.
  ///
  /// In en, this message translates to:
  /// **'Addresses linked to {name}'**
  String assignUrlsTo(String name);

  /// No description provided for @assignUrlsDescription.
  ///
  /// In en, this message translates to:
  /// **'Whatever is imported from these addresses gets this tag on its own, without asking the platform anything.'**
  String get assignUrlsDescription;

  /// No description provided for @assignUrlsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Link addresses to this tag'**
  String get assignUrlsTooltip;

  /// No description provided for @assignUrlsCreatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Whatever is imported from these addresses gets this creator on its own, without asking the platform anything.'**
  String get assignUrlsCreatorDescription;

  /// No description provided for @assignUrlsCreatorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Link addresses to this creator'**
  String get assignUrlsCreatorTooltip;

  /// No description provided for @sourceUrlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get sourceUrlsLabel;

  /// No description provided for @sourceUrlHint.
  ///
  /// In en, this message translates to:
  /// **'reddit.com/r/example'**
  String get sourceUrlHint;

  /// No description provided for @addSourceUrl.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addSourceUrl;

  /// No description provided for @filtersSource.
  ///
  /// In en, this message translates to:
  /// **'Show media from'**
  String get filtersSource;

  /// No description provided for @sourceLocal.
  ///
  /// In en, this message translates to:
  /// **'This computer'**
  String get sourceLocal;

  /// No description provided for @autoTagRemoteSource.
  ///
  /// In en, this message translates to:
  /// **'Auto-tag remote source'**
  String get autoTagRemoteSource;

  /// No description provided for @autoTagRemoteSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern creates a tag for each platform (Reddit, and so on) and puts it on what it imports from it. With this off the source is still recorded, and you filter by it from the Filters button.'**
  String get autoTagRemoteSourceDescription;
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
