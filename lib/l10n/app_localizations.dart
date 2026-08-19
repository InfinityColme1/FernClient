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

  /// No description provided for @sidebarCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse the menu'**
  String get sidebarCollapse;

  /// No description provided for @sidebarExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand the menu'**
  String get sidebarExpand;

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

  /// No description provided for @viewerBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get viewerBack;

  /// No description provided for @viewerShare.
  ///
  /// In en, this message translates to:
  /// **'Copy to the clipboard'**
  String get viewerShare;

  /// No description provided for @viewerFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get viewerFullscreen;

  /// No description provided for @viewerExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get viewerExitFullscreen;

  /// No description provided for @viewerFavorite.
  ///
  /// In en, this message translates to:
  /// **'Mark as favourite'**
  String get viewerFavorite;

  /// No description provided for @viewerUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get viewerUnfavorite;

  /// No description provided for @viewerCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to the clipboard'**
  String get viewerCopied;

  /// No description provided for @viewerCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'This content could not be copied'**
  String get viewerCopyFailed;

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

  /// No description provided for @creatorNameTaken.
  ///
  /// In en, this message translates to:
  /// **'There is already a creator with that name'**
  String get creatorNameTaken;

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

  /// No description provided for @settingsViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get settingsViewer;

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

  /// No description provided for @viewerSaveSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving imported media'**
  String get viewerSaveSectionTitle;

  /// No description provided for @viewerSaveSectionNote.
  ///
  /// In en, this message translates to:
  /// **'What the viewer does once you mark an imported media as final. It leaves the import grid either way, so the viewer cannot stay where it was.'**
  String get viewerSaveSectionNote;

  /// No description provided for @viewerSaveNext.
  ///
  /// In en, this message translates to:
  /// **'Go to the next media'**
  String get viewerSaveNext;

  /// No description provided for @viewerSaveNextDescription.
  ///
  /// In en, this message translates to:
  /// **'The viewer moves on to the next media, just as if you had pressed the arrow. With nothing left to review, it closes.'**
  String get viewerSaveNextDescription;

  /// No description provided for @viewerSaveClose.
  ///
  /// In en, this message translates to:
  /// **'Close the viewer'**
  String get viewerSaveClose;

  /// No description provided for @viewerSaveCloseDescription.
  ///
  /// In en, this message translates to:
  /// **'The viewer closes and you are back at the import grid, already without that media.'**
  String get viewerSaveCloseDescription;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSectionTitle;

  /// No description provided for @themeSectionNote.
  ///
  /// In en, this message translates to:
  /// **'The colours the whole application is painted with.'**
  String get themeSectionNote;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow the system'**
  String get themeSystem;

  /// No description provided for @themeSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Light or dark, whichever your desktop is using.'**
  String get themeSystemDescription;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightDescription.
  ///
  /// In en, this message translates to:
  /// **'The colours Fern has always had.'**
  String get themeLightDescription;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'The same application, for a dark desktop.'**
  String get themeDarkDescription;

  /// No description provided for @themeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get themeCustom;

  /// No description provided for @themeCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'Your own colours, the ones you pick below.'**
  String get themeCustomDescription;

  /// No description provided for @customColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your colours'**
  String get customColorsTitle;

  /// No description provided for @customColorsNote.
  ///
  /// In en, this message translates to:
  /// **'Only within reach with the custom theme. Whatever you leave untouched is taken from the light or the dark theme, whichever suits the background you chose.'**
  String get customColorsNote;

  /// No description provided for @customColorPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get customColorPrimary;

  /// No description provided for @customColorSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get customColorSecondary;

  /// No description provided for @customColorTerciary.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get customColorTerciary;

  /// No description provided for @customColorError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get customColorError;

  /// No description provided for @customColorBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get customColorBackground;

  /// No description provided for @customColorSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get customColorSurface;

  /// No description provided for @customColorForeground.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get customColorForeground;

  /// No description provided for @customColorPick.
  ///
  /// In en, this message translates to:
  /// **'Choose colour'**
  String get customColorPick;

  /// No description provided for @customColorReset.
  ///
  /// In en, this message translates to:
  /// **'Back to the default colour'**
  String get customColorReset;

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a colour'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerHex.
  ///
  /// In en, this message translates to:
  /// **'Hex code'**
  String get colorPickerHex;

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

  /// No description provided for @pawchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Pawchive'**
  String get pawchiveTitle;

  /// No description provided for @pawchiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern downloads the posts you have favourited on Pawchive. There is nothing to fill in here: log in from Fern’s browser and press the key button there, and the session is saved.'**
  String get pawchiveDescription;

  /// No description provided for @linkChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{This post has {count} links}}'**
  String linkChoiceTitle(int count);

  /// No description provided for @linkChoiceUntitledPost.
  ///
  /// In en, this message translates to:
  /// **'Untitled post'**
  String get linkChoiceUntitledPost;

  /// No description provided for @linkChoiceApplyToAll.
  ///
  /// In en, this message translates to:
  /// **'Apply to the rest of the import'**
  String get linkChoiceApplyToAll;

  /// No description provided for @linkChoiceApplyToAllDescription.
  ///
  /// In en, this message translates to:
  /// **'The same answer is used for every post left, so you are not asked again.'**
  String get linkChoiceApplyToAllDescription;

  /// No description provided for @linkChoiceIgnore.
  ///
  /// In en, this message translates to:
  /// **'Skip post'**
  String get linkChoiceIgnore;

  /// No description provided for @linkChoiceSelection.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Download selection} other{Download {count}}}'**
  String linkChoiceSelection(int count);

  /// No description provided for @linkChoiceAll.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get linkChoiceAll;

  /// No description provided for @linkChoiceOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in the browser'**
  String get linkChoiceOpen;

  /// No description provided for @repositoryLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This post links to a file host} other{This post links to {count} file hosts}}'**
  String repositoryLinkTitle(int count);

  /// No description provided for @repositoryLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Fern cannot fetch from these on its own: they have their own waits and checks. You can open them in Fern’s browser and bring in what you want from there. The import carries on meanwhile.'**
  String get repositoryLinkDescription;

  /// No description provided for @repositoryLinkOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in the browser'**
  String get repositoryLinkOpen;

  /// No description provided for @pawchiveByCreators.
  ///
  /// In en, this message translates to:
  /// **'Import from favourited creators'**
  String get pawchiveByCreators;

  /// No description provided for @pawchiveByCreatorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Instead of the posts you have favourited, Fern goes through everything published by the creators you have favourited. It brings in a great deal more, and each creator is followed on its own.'**
  String get pawchiveByCreatorsDescription;

  /// No description provided for @remoteImportHeavyWarning.
  ///
  /// In en, this message translates to:
  /// **'This may take a long while: with no cap, Fern goes through the whole account and brings in everything, files inside posts included. You can stop it at any time from the import screen, and what has already arrived stays.'**
  String get remoteImportHeavyWarning;

  /// No description provided for @emptySource.
  ///
  /// In en, this message translates to:
  /// **'There was nothing to bring in from {source}.'**
  String emptySource(String source);

  /// No description provided for @emptySourcePawchiveCreators.
  ///
  /// In en, this message translates to:
  /// **'You have no favourited posts on Pawchive, but you do have favourited creators. Turn on \"Import from favourited creators\" in Settings, under Remote sources, and Fern will go through everything they publish.'**
  String get emptySourcePawchiveCreators;

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

  /// No description provided for @startupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fern could not start'**
  String get startupFailedTitle;

  /// No description provided for @startupFailedDatabase.
  ///
  /// In en, this message translates to:
  /// **'The database could not be brought up to the version this release needs.'**
  String get startupFailedDatabase;

  /// No description provided for @startupFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been lost: your content is still where it was. Close Fern and open it again, and if this keeps happening, the details below say what went wrong.'**
  String get startupFailedHint;

  /// No description provided for @settingsRecognition.
  ///
  /// In en, this message translates to:
  /// **'Recognition'**
  String get settingsRecognition;

  /// No description provided for @recognitionFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition data'**
  String get recognitionFolderTitle;

  /// No description provided for @recognitionFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Where Fern keeps everything it needs to recognise your content: the training environment, the trained models and the data sets it builds to train them. It can take several gigabytes, so you may prefer it on another drive.'**
  String get recognitionFolderDescription;

  /// No description provided for @recognitionFolder.
  ///
  /// In en, this message translates to:
  /// **'Recognition folder'**
  String get recognitionFolder;

  /// No description provided for @recognitionFolderMoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The folder was already there} =1{1 file moved to the new folder} other{{count} files moved to the new folder}}'**
  String recognitionFolderMoved(int count);

  /// No description provided for @recognitionFolderMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'The recognition data could not be moved'**
  String get recognitionFolderMoveFailed;

  /// No description provided for @jobsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tasks running'**
  String get jobsTooltip;

  /// No description provided for @jobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Background tasks'**
  String get jobsTitle;

  /// No description provided for @jobsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing running right now'**
  String get jobsEmpty;

  /// No description provided for @jobCancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel this task'**
  String get jobCancelTooltip;

  /// No description provided for @jobProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String jobProgress(int done, int total);

  /// No description provided for @jobQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get jobQueued;

  /// No description provided for @jobFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get jobFailed;

  /// No description provided for @jobTraining.
  ///
  /// In en, this message translates to:
  /// **'Training model'**
  String get jobTraining;

  /// No description provided for @jobRecognition.
  ///
  /// In en, this message translates to:
  /// **'Recognising content'**
  String get jobRecognition;

  /// No description provided for @jobDuplicateScan.
  ///
  /// In en, this message translates to:
  /// **'Looking for repeated media'**
  String get jobDuplicateScan;

  /// No description provided for @jobHashing.
  ///
  /// In en, this message translates to:
  /// **'Reading content'**
  String get jobHashing;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notificationsTitle;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Training a model, recognising a batch or looking for repeated media can take a long while. Fern tells you when it is done so you do not have to keep checking.'**
  String get notificationsDescription;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Alert me'**
  String get notificationsEnabled;

  /// No description provided for @notificationsEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'With this off nothing is counted and nothing plays. What was already pending stays noted, and comes back when you turn it on again.'**
  String get notificationsEnabledDescription;

  /// No description provided for @notificationsMuted.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get notificationsMuted;

  /// No description provided for @notificationsMutedDescription.
  ///
  /// In en, this message translates to:
  /// **'Counters stay, sounds do not.'**
  String get notificationsMutedDescription;

  /// No description provided for @notificationsSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationsSoundTitle;

  /// No description provided for @notificationsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get notificationsVolume;

  /// No description provided for @notificationsMaxSeconds.
  ///
  /// In en, this message translates to:
  /// **'Play at most'**
  String get notificationsMaxSeconds;

  /// No description provided for @notificationsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String notificationsSeconds(int count);

  /// No description provided for @notificationsMaxSecondsDescription.
  ///
  /// In en, this message translates to:
  /// **'An alert is a short chime. If the audio you pick is longer, Fern stops it here instead of playing the whole thing. Your file is not touched.'**
  String get notificationsMaxSecondsDescription;

  /// No description provided for @notificationsEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to alert about'**
  String get notificationsEventsTitle;

  /// No description provided for @notificationsEventsDescription.
  ///
  /// In en, this message translates to:
  /// **'For each one, whether it puts a counter on the side menu and whether it plays a sound.'**
  String get notificationsEventsDescription;

  /// No description provided for @notificationsBadge.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get notificationsBadge;

  /// No description provided for @notificationsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationsSound;

  /// No description provided for @notificationsDefaultSound.
  ///
  /// In en, this message translates to:
  /// **'Fern sound'**
  String get notificationsDefaultSound;

  /// No description provided for @notificationsPreview.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get notificationsPreview;

  /// No description provided for @notificationsChooseSound.
  ///
  /// In en, this message translates to:
  /// **'Choose an audio file'**
  String get notificationsChooseSound;

  /// No description provided for @notificationsResetSound.
  ///
  /// In en, this message translates to:
  /// **'Back to the Fern sound'**
  String get notificationsResetSound;

  /// No description provided for @notifyDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Repeated media found'**
  String get notifyDuplicates;

  /// No description provided for @notifyTraining.
  ///
  /// In en, this message translates to:
  /// **'Model finished training'**
  String get notifyTraining;

  /// No description provided for @notifyRecognition.
  ///
  /// In en, this message translates to:
  /// **'Batch recognition finished'**
  String get notifyRecognition;

  /// No description provided for @notifyRemoteImport.
  ///
  /// In en, this message translates to:
  /// **'Remote import finished'**
  String get notifyRemoteImport;

  /// No description provided for @sidecarTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition engine'**
  String get sidecarTitle;

  /// No description provided for @sidecarDescription.
  ///
  /// In en, this message translates to:
  /// **'To train and recognise, Fern installs its own small Python environment inside the recognition folder. It does not touch your system and you do not need to have Python installed beforehand: it brings its own. It takes about 1.2 GB on disk and is only downloaded when you ask for it.'**
  String get sidecarDescription;

  /// No description provided for @sidecarUnsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Recognition is not available on this system yet.'**
  String get sidecarUnsupportedPlatform;

  /// No description provided for @sidecarNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed yet'**
  String get sidecarNotInstalled;

  /// No description provided for @sidecarDownloadingUv.
  ///
  /// In en, this message translates to:
  /// **'Downloading the installer'**
  String get sidecarDownloadingUv;

  /// No description provided for @sidecarInstallingPython.
  ///
  /// In en, this message translates to:
  /// **'Installing Python'**
  String get sidecarInstallingPython;

  /// No description provided for @sidecarCreatingVenv.
  ///
  /// In en, this message translates to:
  /// **'Preparing the environment'**
  String get sidecarCreatingVenv;

  /// No description provided for @sidecarDetectingHardware.
  ///
  /// In en, this message translates to:
  /// **'Checking your hardware'**
  String get sidecarDetectingHardware;

  /// No description provided for @sidecarInstallingTorch.
  ///
  /// In en, this message translates to:
  /// **'Downloading the engine'**
  String get sidecarInstallingTorch;

  /// No description provided for @sidecarInstallingUltralytics.
  ///
  /// In en, this message translates to:
  /// **'Installing YOLO'**
  String get sidecarInstallingUltralytics;

  /// No description provided for @sidecarCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up'**
  String get sidecarCleaning;

  /// No description provided for @sidecarVerifying.
  ///
  /// In en, this message translates to:
  /// **'Checking everything works'**
  String get sidecarVerifying;

  /// No description provided for @sidecarReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to train and recognise'**
  String get sidecarReady;

  /// No description provided for @sidecarError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get sidecarError;

  /// No description provided for @sidecarDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{received} MB of {total} MB'**
  String sidecarDownloaded(String received, String total);

  /// No description provided for @sidecarInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get sidecarInstall;

  /// No description provided for @sidecarReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall'**
  String get sidecarReinstall;

  /// No description provided for @sidecarEnableGpu.
  ///
  /// In en, this message translates to:
  /// **'Use the graphics card'**
  String get sidecarEnableGpu;

  /// No description provided for @sidecarUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get sidecarUninstall;

  /// No description provided for @sidecarShowLog.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get sidecarShowLog;

  /// No description provided for @sidecarHideLog.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get sidecarHideLog;

  /// No description provided for @sidecarFailureInUse.
  ///
  /// In en, this message translates to:
  /// **'The engine files are in use right now'**
  String get sidecarFailureInUse;

  /// No description provided for @sidecarFailureInUseHint.
  ///
  /// In en, this message translates to:
  /// **'Something still has them open, so they cannot be replaced. Close Fern completely, open it again and press Install. If it keeps happening, restart the computer: that always releases them.'**
  String get sidecarFailureInUseHint;

  /// No description provided for @sidecarFailureSpace.
  ///
  /// In en, this message translates to:
  /// **'There is no room left on the disk'**
  String get sidecarFailureSpace;

  /// No description provided for @sidecarFailureSpaceHint.
  ///
  /// In en, this message translates to:
  /// **'The engine needs about 1.5 GB free, counting what it uses while installing. Free up some space, or move the recognition folder to another drive from the field above.'**
  String get sidecarFailureSpaceHint;

  /// No description provided for @sidecarFailureNetwork.
  ///
  /// In en, this message translates to:
  /// **'The download could not be completed'**
  String get sidecarFailureNetwork;

  /// No description provided for @sidecarFailureNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and press Install again. What was already downloaded is kept, so it carries on where it left off.'**
  String get sidecarFailureNetworkHint;

  /// No description provided for @sidecarFailureBlocked.
  ///
  /// In en, this message translates to:
  /// **'The system would not let Fern run the installer'**
  String get sidecarFailureBlocked;

  /// No description provided for @sidecarFailureBlockedHint.
  ///
  /// In en, this message translates to:
  /// **'This is usually the antivirus stopping a freshly downloaded program. Allow Fern in your antivirus, or choose a recognition folder inside your own user folder, and try again.'**
  String get sidecarFailureBlockedHint;

  /// No description provided for @sidecarFailureMissing.
  ///
  /// In en, this message translates to:
  /// **'Something the engine needs is missing'**
  String get sidecarFailureMissing;

  /// No description provided for @sidecarFailureMissingHint.
  ///
  /// In en, this message translates to:
  /// **'The installation was left half done. Press Uninstall to clear it out and then Install again.'**
  String get sidecarFailureMissingHint;

  /// No description provided for @sidecarFailureUnknown.
  ///
  /// In en, this message translates to:
  /// **'The engine could not be installed'**
  String get sidecarFailureUnknown;

  /// No description provided for @sidecarFailureUnknownHint.
  ///
  /// In en, this message translates to:
  /// **'Press Install to try again. If it keeps failing, open the details below: they say exactly which step went wrong.'**
  String get sidecarFailureUnknownHint;

  /// No description provided for @sidecarInstallCpu.
  ///
  /// In en, this message translates to:
  /// **'Install for the processor'**
  String get sidecarInstallCpu;

  /// No description provided for @sidecarInstallGpu.
  ///
  /// In en, this message translates to:
  /// **'Install for the graphics card'**
  String get sidecarInstallGpu;

  /// No description provided for @sidecarEnableCpu.
  ///
  /// In en, this message translates to:
  /// **'Go back to the processor'**
  String get sidecarEnableCpu;

  /// No description provided for @sidecarPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent} %'**
  String sidecarPercent(int percent);

  /// No description provided for @sidecarBusyDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading packages...'**
  String get sidecarBusyDownloading;

  /// No description provided for @sidecarBusyUnpacking.
  ///
  /// In en, this message translates to:
  /// **'Unpacking what has arrived...'**
  String get sidecarBusyUnpacking;

  /// No description provided for @sidecarBusyPatience.
  ///
  /// In en, this message translates to:
  /// **'This step takes a few minutes.'**
  String get sidecarBusyPatience;

  /// No description provided for @sidecarBusySettling.
  ///
  /// In en, this message translates to:
  /// **'Putting everything in place...'**
  String get sidecarBusySettling;

  /// No description provided for @sidecarBusyKeepUsing.
  ///
  /// In en, this message translates to:
  /// **'You can keep using Fern meanwhile.'**
  String get sidecarBusyKeepUsing;

  /// No description provided for @gpuDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Install the graphics card version?'**
  String get gpuDialogTitle;

  /// No description provided for @gpuDialogBenefit.
  ///
  /// In en, this message translates to:
  /// **'Training goes much faster: what takes hours on the processor can be minutes on the graphics card.'**
  String get gpuDialogBenefit;

  /// No description provided for @gpuDialogTime.
  ///
  /// In en, this message translates to:
  /// **'The download is around 2.5 GB, so it can take a good while on a normal connection.'**
  String get gpuDialogTime;

  /// No description provided for @gpuDialogSize.
  ///
  /// In en, this message translates to:
  /// **'It takes about 5 GB on disk, instead of the 1.2 GB of the processor version.'**
  String get gpuDialogSize;

  /// No description provided for @gpuDialogReversible.
  ///
  /// In en, this message translates to:
  /// **'You can go back to the processor version whenever you want, without reinstalling everything.'**
  String get gpuDialogReversible;

  /// No description provided for @gpuDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Install it'**
  String get gpuDialogConfirm;
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
