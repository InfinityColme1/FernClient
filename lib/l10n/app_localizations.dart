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

  /// No description provided for @selectedOfCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String selectedOfCount(int selected, int total);

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

  /// No description provided for @viewerSkipBack.
  ///
  /// In en, this message translates to:
  /// **'Back five seconds'**
  String get viewerSkipBack;

  /// No description provided for @viewerSkipForward.
  ///
  /// In en, this message translates to:
  /// **'Forward five seconds'**
  String get viewerSkipForward;

  /// No description provided for @viewerLoop.
  ///
  /// In en, this message translates to:
  /// **'Play on repeat'**
  String get viewerLoop;

  /// No description provided for @viewerPlaybackSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Video playback'**
  String get viewerPlaybackSectionTitle;

  /// No description provided for @viewerPlaybackSectionNote.
  ///
  /// In en, this message translates to:
  /// **'What the viewer does to a video while you move along its timeline.'**
  String get viewerPlaybackSectionNote;

  /// No description provided for @viewerPauseWhenSeeking.
  ///
  /// In en, this message translates to:
  /// **'Pause when you take hold of the bar'**
  String get viewerPauseWhenSeeking;

  /// No description provided for @viewerPauseWhenSeekingDescription.
  ///
  /// In en, this message translates to:
  /// **'The video stops as soon as you take hold of the bar and stays where you leave it. Off, it carries on playing from wherever you drop it. Marking regions always pauses, whatever this says: a region is marked on a still frame.'**
  String get viewerPauseWhenSeekingDescription;

  /// No description provided for @fernieUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo the last region marked'**
  String get fernieUndo;

  /// No description provided for @createTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createTooltip;

  /// No description provided for @menuNewModel.
  ///
  /// In en, this message translates to:
  /// **'New model'**
  String get menuNewModel;

  /// No description provided for @newModelTitle.
  ///
  /// In en, this message translates to:
  /// **'New model'**
  String get newModelTitle;

  /// No description provided for @modelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model name'**
  String get modelNameLabel;

  /// No description provided for @modelFunctionLabel.
  ///
  /// In en, this message translates to:
  /// **'What it answers'**
  String get modelFunctionLabel;

  /// No description provided for @modelFunctionBoolean.
  ///
  /// In en, this message translates to:
  /// **'Is it there?'**
  String get modelFunctionBoolean;

  /// No description provided for @modelFunctionBooleanDescription.
  ///
  /// In en, this message translates to:
  /// **'Says whether each of its fernies is in the media. With several, it answers for each one on its own.'**
  String get modelFunctionBooleanDescription;

  /// No description provided for @modelFunctionClassification.
  ///
  /// In en, this message translates to:
  /// **'Which one is it?'**
  String get modelFunctionClassification;

  /// No description provided for @modelFunctionClassificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Tells its fernies apart and says which one it found, and where. Needs at least two: there is nothing to choose between with one.'**
  String get modelFunctionClassificationDescription;

  /// No description provided for @modelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get modelsTitle;

  /// No description provided for @modelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No models yet'**
  String get modelsEmpty;

  /// No description provided for @modelStatusUntrained.
  ///
  /// In en, this message translates to:
  /// **'Not trained'**
  String get modelStatusUntrained;

  /// No description provided for @modelStatusTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get modelStatusTraining;

  /// No description provided for @modelStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get modelStatusReady;

  /// No description provided for @modelStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Training failed'**
  String get modelStatusFailed;

  /// No description provided for @modelDegradedNotice.
  ///
  /// In en, this message translates to:
  /// **'With a single fernie there is nothing to choose between, so it answers whether it is there. Add another one to tell them apart.'**
  String get modelDegradedNotice;

  /// No description provided for @modelRegionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no regions} =1{1 region} other{{count} regions}}'**
  String modelRegionCount(int count);

  /// No description provided for @modelFernieCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no fernies} =1{1 fernie} other{{count} fernies}}'**
  String modelFernieCount(int count);

  /// No description provided for @modelDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this model?'**
  String get modelDeleteTitle;

  /// No description provided for @modelDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Its fernies stay where they are: they belong to you, not to the model. What is lost is what it had learned: the weights, the training charts and everything it left on disk.'**
  String get modelDeleteMessage;

  /// No description provided for @splitTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get splitTrain;

  /// No description provided for @splitValidation.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get splitValidation;

  /// No description provided for @splitTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get splitTest;

  /// No description provided for @modelRemoveFernie.
  ///
  /// In en, this message translates to:
  /// **'Take out of this model'**
  String get modelRemoveFernie;

  /// No description provided for @modelMediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no media} =1{1 media} other{{count} media}}'**
  String modelMediaCount(int count);

  /// No description provided for @modelTooFewRegions.
  ///
  /// In en, this message translates to:
  /// **'Fewer than {count} regions: not enough to train'**
  String modelTooFewRegions(int count);

  /// No description provided for @modelFewRegions.
  ///
  /// In en, this message translates to:
  /// **'Fewer than {count} regions: it will learn little'**
  String modelFewRegions(int count);

  /// No description provided for @modelTooFewMedia.
  ///
  /// In en, this message translates to:
  /// **'Too few different media: it will learn the background'**
  String get modelTooFewMedia;

  /// No description provided for @modelAssignedFernies.
  ///
  /// In en, this message translates to:
  /// **'Assigned fernies'**
  String get modelAssignedFernies;

  /// No description provided for @modelAddFernie.
  ///
  /// In en, this message translates to:
  /// **'Add fernie'**
  String get modelAddFernie;

  /// No description provided for @modelNoFernies.
  ///
  /// In en, this message translates to:
  /// **'A model with no fernies has nothing to learn. Add at least one.'**
  String get modelNoFernies;

  /// No description provided for @modelApplySplitToAll.
  ///
  /// In en, this message translates to:
  /// **'Apply this split to all'**
  String get modelApplySplitToAll;

  /// No description provided for @modelRetrainNotice.
  ///
  /// In en, this message translates to:
  /// **'Changing the fernies of a trained model means training it again: its weights no longer mean the same thing.'**
  String get modelRetrainNotice;

  /// No description provided for @modelSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get modelSaved;

  /// No description provided for @trainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingTitle;

  /// No description provided for @presetFast.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get presetFast;

  /// No description provided for @presetFastDescription.
  ///
  /// In en, this message translates to:
  /// **'To see whether the idea works before leaving the machine running all night. Also the sensible one without a graphics card.'**
  String get presetFastDescription;

  /// No description provided for @presetBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get presetBalanced;

  /// No description provided for @presetBalancedDescription.
  ///
  /// In en, this message translates to:
  /// **'What you want most of the time: enough to use the model for real.'**
  String get presetBalancedDescription;

  /// No description provided for @presetAccurate.
  ///
  /// In en, this message translates to:
  /// **'Thorough'**
  String get presetAccurate;

  /// No description provided for @presetAccurateDescription.
  ///
  /// In en, this message translates to:
  /// **'When there are already plenty of regions and the model matters. Takes a good while.'**
  String get presetAccurateDescription;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// No description provided for @presetCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'The settings do not match any of the above, so yours win.'**
  String get presetCustomDescription;

  /// No description provided for @trainingAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get trainingAdvanced;

  /// No description provided for @trainingEpochsLabel.
  ///
  /// In en, this message translates to:
  /// **'Epochs'**
  String get trainingEpochsLabel;

  /// No description provided for @trainingImageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Image size'**
  String get trainingImageSizeLabel;

  /// No description provided for @trainingBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get trainingBatchLabel;

  /// No description provided for @trainingBatchAuto.
  ///
  /// In en, this message translates to:
  /// **'-1 lets it decide'**
  String get trainingBatchAuto;

  /// No description provided for @trainingBackboneIs.
  ///
  /// In en, this message translates to:
  /// **'Network: {backbone}'**
  String trainingBackboneIs(String backbone);

  /// No description provided for @trainingStart.
  ///
  /// In en, this message translates to:
  /// **'Train model'**
  String get trainingStart;

  /// No description provided for @trainingRetrain.
  ///
  /// In en, this message translates to:
  /// **'Train again'**
  String get trainingRetrain;

  /// No description provided for @trainingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing the dataset...'**
  String get trainingPreparing;

  /// No description provided for @trainingEpoch.
  ///
  /// In en, this message translates to:
  /// **'Epoch {done} of {total}'**
  String trainingEpoch(int done, int total);

  /// No description provided for @trainingRemaining.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min left'**
  String trainingRemaining(int minutes);

  /// No description provided for @trainingEngineNotReady.
  ///
  /// In en, this message translates to:
  /// **'The recognition engine is not installed yet. Set it up in settings.'**
  String get trainingEngineNotReady;

  /// No description provided for @trainingNoValidation.
  ///
  /// In en, this message translates to:
  /// **'nothing set aside to validate, so training cannot tell when to stop'**
  String get trainingNoValidation;

  /// No description provided for @trainingImbalanced.
  ///
  /// In en, this message translates to:
  /// **'One fernie has more than {count} times the regions of another: the model will learn to always answer the big one'**
  String trainingImbalanced(int count);

  /// No description provided for @trainingQueued.
  ///
  /// In en, this message translates to:
  /// **'Training queued'**
  String get trainingQueued;

  /// No description provided for @metricsLastTraining.
  ///
  /// In en, this message translates to:
  /// **'Last training'**
  String get metricsLastTraining;

  /// No description provided for @metricMap50.
  ///
  /// In en, this message translates to:
  /// **'mAP50'**
  String get metricMap50;

  /// No description provided for @metricMap50to95.
  ///
  /// In en, this message translates to:
  /// **'mAP50-95'**
  String get metricMap50to95;

  /// No description provided for @metricPrecision.
  ///
  /// In en, this message translates to:
  /// **'Precision'**
  String get metricPrecision;

  /// No description provided for @metricRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get metricRecall;

  /// No description provided for @metricsPerClass.
  ///
  /// In en, this message translates to:
  /// **'Per fernie'**
  String get metricsPerClass;

  /// No description provided for @metricsConfusionMatrix.
  ///
  /// In en, this message translates to:
  /// **'Confusion matrix'**
  String get metricsConfusionMatrix;

  /// No description provided for @metricsCurves.
  ///
  /// In en, this message translates to:
  /// **'Curves'**
  String get metricsCurves;

  /// No description provided for @metricsOpenRunFolder.
  ///
  /// In en, this message translates to:
  /// **'Open run folder'**
  String get metricsOpenRunFolder;

  /// No description provided for @metricsRunFolderMissing.
  ///
  /// In en, this message translates to:
  /// **'That folder is no longer there.'**
  String get metricsRunFolderMissing;

  /// No description provided for @metricsRunImagesMissing.
  ///
  /// In en, this message translates to:
  /// **'Those images are no longer in the run folder. Deleting it does not break the model: the weights are all it needs to recognise.'**
  String get metricsRunImagesMissing;

  /// No description provided for @metricsNotTrainedYet.
  ///
  /// In en, this message translates to:
  /// **'Not trained yet.'**
  String get metricsNotTrainedYet;

  /// No description provided for @metricsImportedWeights.
  ///
  /// In en, this message translates to:
  /// **'The weights come from outside, so there are no training metrics.'**
  String get metricsImportedWeights;

  /// No description provided for @metricsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get metricsRetry;

  /// No description provided for @metricsRealPerformance.
  ///
  /// In en, this message translates to:
  /// **'Real performance'**
  String get metricsRealPerformance;

  /// No description provided for @metricsRealPerformanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data yet. It counts how many suggestions from this model you accept and reject while importing, which is the only honest measure of whether it works.'**
  String get metricsRealPerformanceEmpty;

  /// No description provided for @modelImportWeights.
  ///
  /// In en, this message translates to:
  /// **'Import weights'**
  String get modelImportWeights;

  /// No description provided for @modelImportWeightsHint.
  ///
  /// In en, this message translates to:
  /// **'A .pt file trained elsewhere. It is copied into the recognition folder so it does not disappear from under the model.'**
  String get modelImportWeightsHint;

  /// No description provided for @modelImportWeightsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Those weights could not be read: {error}'**
  String modelImportWeightsInvalid(String error);

  /// No description provided for @modelImportWeightsDone.
  ///
  /// In en, this message translates to:
  /// **'Weights imported: {classes}'**
  String modelImportWeightsDone(String classes);

  /// No description provided for @modelImportedBadge.
  ///
  /// In en, this message translates to:
  /// **'Imported weights'**
  String get modelImportedBadge;

  /// No description provided for @trainingFailedEngineStopped.
  ///
  /// In en, this message translates to:
  /// **'The recognition engine stopped mid-training. Try again; if it keeps happening, the machine is most likely running out of memory: lower the image size or the batch under Advanced.'**
  String get trainingFailedEngineStopped;

  /// No description provided for @trainingFailedOutOfMemory.
  ///
  /// In en, this message translates to:
  /// **'It ran out of memory. Lower the batch or the image size under Advanced and try again.'**
  String get trainingFailedOutOfMemory;

  /// No description provided for @trainingFailedDataset.
  ///
  /// In en, this message translates to:
  /// **'The material could not be prepared. Some files may have moved or been deleted since the regions were marked.'**
  String get trainingFailedDataset;

  /// No description provided for @trainingFailedWeights.
  ///
  /// In en, this message translates to:
  /// **'The starting weights are missing and could not be downloaded. Check the connection, or import weights of your own.'**
  String get trainingFailedWeights;

  /// No description provided for @trainingFailedNoSpace.
  ///
  /// In en, this message translates to:
  /// **'There is not enough room on disk. A video dataset is thousands of frames, so it needs a few gigabytes free.'**
  String get trainingFailedNoSpace;

  /// No description provided for @trainingFailedUnknown.
  ///
  /// In en, this message translates to:
  /// **'Training failed.'**
  String get trainingFailedUnknown;

  /// No description provided for @jobTrainingModel.
  ///
  /// In en, this message translates to:
  /// **'Training «{model}»'**
  String jobTrainingModel(String model);

  /// No description provided for @jobsNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing running'**
  String get jobsNone;

  /// No description provided for @treeTitle.
  ///
  /// In en, this message translates to:
  /// **'Model tree'**
  String get treeTitle;

  /// No description provided for @treeOpen.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get treeOpen;

  /// No description provided for @treeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the tree yet. A model that is not here never runs when recognising: add one from the panel on the right.'**
  String get treeEmpty;

  /// No description provided for @treeSearchModel.
  ///
  /// In en, this message translates to:
  /// **'Search a model'**
  String get treeSearchModel;

  /// No description provided for @treeAvailableModels.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get treeAvailableModels;

  /// No description provided for @treeAllInTree.
  ///
  /// In en, this message translates to:
  /// **'They are all in the tree already.'**
  String get treeAllInTree;

  /// No description provided for @treeNoModels.
  ///
  /// In en, this message translates to:
  /// **'There are no models yet.'**
  String get treeNoModels;

  /// No description provided for @treeRemoveNode.
  ///
  /// In en, this message translates to:
  /// **'Take out of the tree'**
  String get treeRemoveNode;

  /// No description provided for @treeNodeNotTrained.
  ///
  /// In en, this message translates to:
  /// **'Not trained'**
  String get treeNodeNotTrained;

  /// No description provided for @treeAddAsRoot.
  ///
  /// In en, this message translates to:
  /// **'Add on its own'**
  String get treeAddAsRoot;

  /// No description provided for @treeAddAsChild.
  ///
  /// In en, this message translates to:
  /// **'Hang from «{parent}»'**
  String treeAddAsChild(String parent);

  /// No description provided for @treeSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'«{name}» is selected: what you add from the panel hangs from it.'**
  String treeSelectedHint(String name);

  /// No description provided for @treeClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get treeClearSelection;

  /// No description provided for @treeEdgeAnyDetection.
  ///
  /// In en, this message translates to:
  /// **'anything'**
  String get treeEdgeAnyDetection;

  /// No description provided for @treeEdgeConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'When does it run?'**
  String get treeEdgeConditionTitle;

  /// No description provided for @treeEdgeConditionMessage.
  ///
  /// In en, this message translates to:
  /// **'«{child}» only runs when «{parent}» detects this. Without a fernie it runs on any detection, which means the specialised models run all the time: it works, but it is the thing to narrow down.'**
  String treeEdgeConditionMessage(String child, String parent);

  /// No description provided for @treeEdgeDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Unhook'**
  String get treeEdgeDisconnect;

  /// No description provided for @treeFitToView.
  ///
  /// In en, this message translates to:
  /// **'Fit to view'**
  String get treeFitToView;

  /// No description provided for @treeZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get treeZoomIn;

  /// No description provided for @treeZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get treeZoomOut;

  /// No description provided for @treeCannotConnect.
  ///
  /// In en, this message translates to:
  /// **'That cannot be hooked up: it would make the tree bite its own tail.'**
  String get treeCannotConnect;

  /// No description provided for @treeOutsideCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 model outside the tree} other{{count} models outside the tree}}'**
  String treeOutsideCount(int count);

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

  /// No description provided for @navRecognition.
  ///
  /// In en, this message translates to:
  /// **'Recognition'**
  String get navRecognition;

  /// No description provided for @navFernies.
  ///
  /// In en, this message translates to:
  /// **'Fernies'**
  String get navFernies;

  /// No description provided for @navRepeatedMedia.
  ///
  /// In en, this message translates to:
  /// **'Repeated media'**
  String get navRepeatedMedia;

  /// No description provided for @navModels.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get navModels;

  /// No description provided for @menuNewFernie.
  ///
  /// In en, this message translates to:
  /// **'New fernie'**
  String get menuNewFernie;

  /// No description provided for @newFernieTitle.
  ///
  /// In en, this message translates to:
  /// **'New fernie'**
  String get newFernieTitle;

  /// No description provided for @fernieNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Fernie name'**
  String get fernieNameLabel;

  /// No description provided for @ferniesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fernies'**
  String get ferniesTitle;

  /// No description provided for @addFernie.
  ///
  /// In en, this message translates to:
  /// **'Add fernie'**
  String get addFernie;

  /// No description provided for @noFerniesYet.
  ///
  /// In en, this message translates to:
  /// **'No fernies yet'**
  String get noFerniesYet;

  /// No description provided for @fernieNoRegions.
  ///
  /// In en, this message translates to:
  /// **'This fernie has no regions yet'**
  String get fernieNoRegions;

  /// No description provided for @fernieNoneHere.
  ///
  /// In en, this message translates to:
  /// **'No fernies marked here yet'**
  String get fernieNoneHere;

  /// No description provided for @fernieLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'It proposes'**
  String get fernieLinkLabel;

  /// No description provided for @fernieLinkNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get fernieLinkNone;

  /// No description provided for @fernieLinkTag.
  ///
  /// In en, this message translates to:
  /// **'A tag'**
  String get fernieLinkTag;

  /// No description provided for @fernieLinkCreator.
  ///
  /// In en, this message translates to:
  /// **'A creator'**
  String get fernieLinkCreator;

  /// No description provided for @fernieLinkNoneHint.
  ///
  /// In en, this message translates to:
  /// **'It only trains: on its own it tags nothing'**
  String get fernieLinkNoneHint;

  /// No description provided for @fernieLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'What it was linked to no longer exists'**
  String get fernieLinkMissing;

  /// No description provided for @fernieFewRegions.
  ///
  /// In en, this message translates to:
  /// **'Few regions to train reliably'**
  String get fernieFewRegions;

  /// No description provided for @fernieLowVariety.
  ///
  /// In en, this message translates to:
  /// **'Little variety: the model will learn the background, not the object'**
  String get fernieLowVariety;

  /// No description provided for @fernieRegionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending content: this region will not be used to train until you save it'**
  String get fernieRegionPending;

  /// No description provided for @fernieRegionTiny.
  ///
  /// In en, this message translates to:
  /// **'Very small region: it may not help the training'**
  String get fernieRegionTiny;

  /// No description provided for @actionDeleteFernie.
  ///
  /// In en, this message translates to:
  /// **'Delete fernie'**
  String get actionDeleteFernie;

  /// No description provided for @actionRemoveLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get actionRemoveLink;

  /// No description provided for @actionDeleteRegions.
  ///
  /// In en, this message translates to:
  /// **'Delete regions'**
  String get actionDeleteRegions;

  /// No description provided for @fernieToolSelect.
  ///
  /// In en, this message translates to:
  /// **'Mark regions'**
  String get fernieToolSelect;

  /// No description provided for @fernieToolEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit regions'**
  String get fernieToolEdit;

  /// No description provided for @fernieRegionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save the changes to this region'**
  String get fernieRegionConfirm;

  /// No description provided for @fernieRegionCancel.
  ///
  /// In en, this message translates to:
  /// **'Discard the changes to this region'**
  String get fernieRegionCancel;

  /// No description provided for @fernieRegionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this region'**
  String get fernieRegionDelete;

  /// No description provided for @fernieRegionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this region?'**
  String get fernieRegionDeleteTitle;

  /// No description provided for @fernieRegionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The region is removed from its fernie. If it was the only one of that fernie in this content, the fernie stops being marked here.'**
  String get fernieRegionDeleteMessage;

  /// No description provided for @fernieRegionDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the changes to the region?'**
  String get fernieRegionDiscardTitle;

  /// No description provided for @fernieRegionDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'What you changed in the selected region will not be saved.'**
  String get fernieRegionDiscardMessage;

  /// No description provided for @fernieTimelinePlay.
  ///
  /// In en, this message translates to:
  /// **'Play to check the marked regions'**
  String get fernieTimelinePlay;

  /// No description provided for @fernieTimelinePause.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get fernieTimelinePause;

  /// No description provided for @fernieFramePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous frame'**
  String get fernieFramePrevious;

  /// No description provided for @fernieFrameNext.
  ///
  /// In en, this message translates to:
  /// **'Next frame'**
  String get fernieFrameNext;

  /// No description provided for @fernieOnionSkin.
  ///
  /// In en, this message translates to:
  /// **'Onion skin: show the previous marked frame'**
  String get fernieOnionSkin;

  /// No description provided for @fernieDragRegions.
  ///
  /// In en, this message translates to:
  /// **'Drag the region across every frame in between'**
  String get fernieDragRegions;

  /// No description provided for @fernieModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark regions'**
  String get fernieModeTooltip;

  /// No description provided for @fernieModeAccept.
  ///
  /// In en, this message translates to:
  /// **'Save the regions'**
  String get fernieModeAccept;

  /// No description provided for @fernieModeCancel.
  ///
  /// In en, this message translates to:
  /// **'Discard the regions'**
  String get fernieModeCancel;

  /// No description provided for @fernieModeHint.
  ///
  /// In en, this message translates to:
  /// **'Drag over the content to mark a region. Hold space or the middle button to pan.'**
  String get fernieModeHint;

  /// No description provided for @fernieDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard what you marked?'**
  String get fernieDiscardTitle;

  /// No description provided for @fernieDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'The regions marked in this session will be lost.'**
  String get fernieDiscardMessage;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @assignRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign the region'**
  String get assignRegionTitle;

  /// No description provided for @searchFernieHint.
  ///
  /// In en, this message translates to:
  /// **'Search fernie...'**
  String get searchFernieHint;

  /// No description provided for @createFernie.
  ///
  /// In en, this message translates to:
  /// **'Create fernie'**
  String get createFernie;

  /// No description provided for @fernieRegionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No regions} =1{1 region} other{{count} regions}}'**
  String fernieRegionCount(int count);

  /// No description provided for @fernieMediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{in no media} =1{in 1 media} other{in {count} media}}'**
  String fernieMediaCount(int count);

  /// No description provided for @fernieRecommendedRegions.
  ///
  /// In en, this message translates to:
  /// **'At least {count} regions are recommended'**
  String fernieRecommendedRegions(int count);

  /// No description provided for @viewerRecognize.
  ///
  /// In en, this message translates to:
  /// **'Recognise with models'**
  String get viewerRecognize;

  /// No description provided for @viewerRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognising…'**
  String get viewerRecognizing;

  /// No description provided for @viewerRecognizeQueued.
  ///
  /// In en, this message translates to:
  /// **'Recognition queued'**
  String get viewerRecognizeQueued;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestionsTitle;

  /// No description provided for @suggestionConfidence.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String suggestionConfidence(int percent);

  /// No description provided for @suggestionFromModel.
  ///
  /// In en, this message translates to:
  /// **'Suggested by a model, not confirmed yet'**
  String get suggestionFromModel;

  /// No description provided for @suggestionCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested creator'**
  String get suggestionCreatorTitle;

  /// No description provided for @suggestionsNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing suggested here'**
  String get suggestionsNone;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @actionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get actionReject;

  /// No description provided for @suggestionAcceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get suggestionAcceptAll;

  /// No description provided for @suggestionRejectAll.
  ///
  /// In en, this message translates to:
  /// **'Reject all'**
  String get suggestionRejectAll;

  /// No description provided for @recognizeNoModelsInTree.
  ///
  /// In en, this message translates to:
  /// **'There are no models in the tree yet. Add one from the model tree screen.'**
  String get recognizeNoModelsInTree;

  /// No description provided for @recognizeNoTrainedModels.
  ///
  /// In en, this message translates to:
  /// **'No model in the tree has been trained yet. Train one, or import its weights from the model screen.'**
  String get recognizeNoTrainedModels;

  /// No description provided for @recognizeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The model tree could not be read.'**
  String get recognizeUnavailable;

  /// No description provided for @recognizeFoundNothing.
  ///
  /// In en, this message translates to:
  /// **'The models did not find anything here'**
  String get recognizeFoundNothing;

  /// No description provided for @recognizeNothingToDo.
  ///
  /// In en, this message translates to:
  /// **'There is nothing left to recognise here'**
  String get recognizeNothingToDo;

  /// No description provided for @recognizeSelectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recognise the selection'**
  String get recognizeSelectedTooltip;

  /// No description provided for @recognizeTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recognise everything with this tag'**
  String get recognizeTagTooltip;

  /// No description provided for @recognizeCreatorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recognise everything by this creator'**
  String get recognizeCreatorTooltip;

  /// No description provided for @recognizeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Recognise the library'**
  String get recognizeLibrary;

  /// No description provided for @recognizeLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognise the whole library'**
  String get recognizeLibraryTitle;

  /// No description provided for @recognizeLibraryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Recognising takes about one prediction per image, and several per video. Choose how much to go through.'**
  String get recognizeLibraryQuestion;

  /// No description provided for @recognizeLibraryOnlyNew.
  ///
  /// In en, this message translates to:
  /// **'Only what has never been looked at'**
  String get recognizeLibraryOnlyNew;

  /// No description provided for @recognizeLibraryAll.
  ///
  /// In en, this message translates to:
  /// **'Everything, again'**
  String get recognizeLibraryAll;

  /// No description provided for @recognizeLibraryAllHint.
  ///
  /// In en, this message translates to:
  /// **'Useful after training a better model.'**
  String get recognizeLibraryAllHint;

  /// No description provided for @recognizeJobLibrary.
  ///
  /// In en, this message translates to:
  /// **'Whole library'**
  String get recognizeJobLibrary;

  /// No description provided for @recognizeJobSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get recognizeJobSelection;

  /// No description provided for @recognizeQueuedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing queued} =1{1 item queued to recognise} other{{count} items queued to recognise}}'**
  String recognizeQueuedCount(int count);

  /// No description provided for @recognizeCountable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String recognizeCountable(int count);

  /// No description provided for @recognitionLogTitle.
  ///
  /// In en, this message translates to:
  /// **'What the models did'**
  String get recognitionLogTitle;

  /// No description provided for @recognitionLogNearMiss.
  ///
  /// In en, this message translates to:
  /// **'seen, below the bar'**
  String get recognitionLogNearMiss;

  /// No description provided for @recognitionLogNothing.
  ///
  /// In en, this message translates to:
  /// **'nothing'**
  String get recognitionLogNothing;

  /// No description provided for @recognitionLogVerdictProposed.
  ///
  /// In en, this message translates to:
  /// **'suggested'**
  String get recognitionLogVerdictProposed;

  /// No description provided for @recognitionLogVerdictBelow.
  ///
  /// In en, this message translates to:
  /// **'seen, but under {percent}%'**
  String recognitionLogVerdictBelow(int percent);

  /// No description provided for @recognitionLogVerdictNothing.
  ///
  /// In en, this message translates to:
  /// **'saw nothing'**
  String get recognitionLogVerdictNothing;

  /// No description provided for @recognitionLogVerdictNotReached.
  ///
  /// In en, this message translates to:
  /// **'did not run: its branch never opened'**
  String get recognitionLogVerdictNotReached;

  /// No description provided for @recognitionLogVerdictUntrained.
  ///
  /// In en, this message translates to:
  /// **'did not run: it has no weights'**
  String get recognitionLogVerdictUntrained;

  /// No description provided for @jobDetailTooltip.
  ///
  /// In en, this message translates to:
  /// **'See what the models did'**
  String get jobDetailTooltip;

  /// No description provided for @jobsClearFinished.
  ///
  /// In en, this message translates to:
  /// **'Dismiss the finished ones'**
  String get jobsClearFinished;

  /// No description provided for @recognitionLogFromToast.
  ///
  /// In en, this message translates to:
  /// **'Tap to see what the models did'**
  String get recognitionLogFromToast;

  /// No description provided for @recognitionLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One item} other{{count} items}}'**
  String recognitionLogSubtitle(int count);

  /// No description provided for @recognitionLogProposed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 suggestion} other{{count} suggestions}}'**
  String recognitionLogProposed(int count);

  /// No description provided for @jobDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get jobDone;

  /// No description provided for @recognizeFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 suggestion found. Tap to see how} other{{count} suggestions found. Tap to see how}}'**
  String recognizeFoundCount(int count);

  /// No description provided for @recognitionPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'When recognising'**
  String get recognitionPanelTitle;

  /// No description provided for @recognitionThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum confidence to suggest'**
  String get recognitionThresholdLabel;

  /// No description provided for @recognitionThresholdDescription.
  ///
  /// In en, this message translates to:
  /// **'Below this, what it sees is not proposed.'**
  String get recognitionThresholdDescription;

  /// No description provided for @recognitionThresholdEverything.
  ///
  /// In en, this message translates to:
  /// **'Everything it sees gets proposed, however unsure.'**
  String get recognitionThresholdEverything;

  /// No description provided for @recognitionThresholdAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recognitionThresholdAll;

  /// No description provided for @recognitionThresholdLower.
  ///
  /// In en, this message translates to:
  /// **'Lower the bar'**
  String get recognitionThresholdLower;

  /// No description provided for @recognitionThresholdRaise.
  ///
  /// In en, this message translates to:
  /// **'Raise the bar'**
  String get recognitionThresholdRaise;

  /// No description provided for @recognitionThresholdApplies.
  ///
  /// In en, this message translates to:
  /// **'Applies to the next recognition. What is already suggested does not change.'**
  String get recognitionThresholdApplies;

  /// No description provided for @recognizeReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'They will leave the library for a while'**
  String get recognizeReturnTitle;

  /// No description provided for @recognizeReturnHint.
  ///
  /// In en, this message translates to:
  /// **'Only the ones that get a suggestion. You can turn this off in Settings, under Recognition.'**
  String get recognizeReturnHint;

  /// No description provided for @recognizeReturnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Recognise anyway'**
  String get recognizeReturnConfirm;

  /// No description provided for @returnRecognizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Send recognised content back to importing'**
  String get returnRecognizedLabel;

  /// No description provided for @returnRecognizedDescription.
  ///
  /// In en, this message translates to:
  /// **'Content that gets a suggestion stops being final until you validate it. Turned off, the suggestions still show in the viewer panel and nothing moves.'**
  String get returnRecognizedDescription;

  /// No description provided for @recognizeReturnWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One item will go back to the import screen until you validate its tags.} other{{count} items will go back to the import screen until you validate their tags.}}'**
  String recognizeReturnWarning(int count);

  /// No description provided for @suggestionsPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Has suggestions waiting'**
  String get suggestionsPendingBadge;

  /// No description provided for @suggestionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get suggestionFilterAll;

  /// No description provided for @suggestionFilterWith.
  ///
  /// In en, this message translates to:
  /// **'With suggestions'**
  String get suggestionFilterWith;

  /// No description provided for @suggestionFilterNever.
  ///
  /// In en, this message translates to:
  /// **'Never looked at'**
  String get suggestionFilterNever;

  /// No description provided for @acceptAboveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Accepts what the models are over {percent}% sure about, in the selection. It does not mark anything as final.'**
  String acceptAboveTooltip(int percent);

  /// No description provided for @acceptAboveDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing was confident enough} =1{1 suggestion accepted} other{{count} suggestions accepted}}'**
  String acceptAboveDone(int count);

  /// No description provided for @actionClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get actionClearSelection;

  /// No description provided for @acceptAboveLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept over {percent}%'**
  String acceptAboveLabel(int percent);

  /// No description provided for @importShowLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get importShowLabel;

  /// No description provided for @importFetchLabel.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get importFetchLabel;

  /// No description provided for @recognizeJobImported.
  ///
  /// In en, this message translates to:
  /// **'Just imported'**
  String get recognizeJobImported;

  /// No description provided for @recognizeOnImportLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognise what has just been imported'**
  String get recognizeOnImportLabel;

  /// No description provided for @recognizeOnImportDescription.
  ///
  /// In en, this message translates to:
  /// **'New content goes to the models on its own, once the import settles. Costs nothing if no model is trained.'**
  String get recognizeOnImportDescription;

  /// No description provided for @suggestionMarkRegion.
  ///
  /// In en, this message translates to:
  /// **'Save as a region of this fernie'**
  String get suggestionMarkRegion;

  /// No description provided for @suggestionRegionSaved.
  ///
  /// In en, this message translates to:
  /// **'Region saved. It counts for the next training.'**
  String get suggestionRegionSaved;

  /// No description provided for @suggestionRegionFailed.
  ///
  /// In en, this message translates to:
  /// **'The region could not be saved'**
  String get suggestionRegionFailed;

  /// No description provided for @duplicatesScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan now'**
  String get duplicatesScanNow;

  /// No description provided for @duplicatesScanning.
  ///
  /// In en, this message translates to:
  /// **'Looking for repeats'**
  String get duplicatesScanning;

  /// No description provided for @duplicatesQueued.
  ///
  /// In en, this message translates to:
  /// **'Looking for repeats. It may take a while on the first run.'**
  String get duplicatesQueued;

  /// No description provided for @duplicatesNone.
  ///
  /// In en, this message translates to:
  /// **'No repeated content found'**
  String get duplicatesNone;

  /// No description provided for @duplicatesNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Scan again after importing, or lower the similarity bar in Settings.'**
  String get duplicatesNoneHint;

  /// No description provided for @duplicatesNeverScanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been scanned yet'**
  String get duplicatesNeverScanned;

  /// No description provided for @duplicatesNeverScannedHint.
  ///
  /// In en, this message translates to:
  /// **'Press “Scan now” and Fern goes through the whole library. It may take a while on the first run.'**
  String get duplicatesNeverScannedHint;

  /// No description provided for @duplicatesScanFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Scan finished: 1 new group} other{Scan finished: {count} new groups}}'**
  String duplicatesScanFound(int count);

  /// No description provided for @duplicatesScanNothingNew.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Scan finished: nothing new. 1 group still to review.} other{Scan finished: nothing new. {count} groups still to review.}}'**
  String duplicatesScanNothingNew(int count);

  /// No description provided for @duplicatesScanClean.
  ///
  /// In en, this message translates to:
  /// **'Scan finished: no repeated content.'**
  String get duplicatesScanClean;

  /// No description provided for @duplicatesScanStopped.
  ///
  /// In en, this message translates to:
  /// **'Scan stopped. The fingerprints already worked out stay done.'**
  String get duplicatesScanStopped;

  /// No description provided for @duplicatesScanFailed.
  ///
  /// In en, this message translates to:
  /// **'The scan could not finish. Try again.'**
  String get duplicatesScanFailed;

  /// No description provided for @duplicatesGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String duplicatesGroupCount(int count);

  /// No description provided for @duplicatesDistance.
  ///
  /// In en, this message translates to:
  /// **'distance {distance}'**
  String duplicatesDistance(int distance);

  /// No description provided for @duplicatesIdentical.
  ///
  /// In en, this message translates to:
  /// **'identical'**
  String get duplicatesIdentical;

  /// No description provided for @duplicatesCopyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 copy} other{{count} copies}}'**
  String duplicatesCopyCount(int count);

  /// No description provided for @duplicatesGroupPosition.
  ///
  /// In en, this message translates to:
  /// **'Group {position} of {total}'**
  String duplicatesGroupPosition(int position, int total);

  /// No description provided for @duplicatesKeepThis.
  ///
  /// In en, this message translates to:
  /// **'Keep this one'**
  String get duplicatesKeepThis;

  /// No description provided for @duplicatesMergeMetadata.
  ///
  /// In en, this message translates to:
  /// **'Merge metadata into the copy you keep'**
  String get duplicatesMergeMetadata;

  /// No description provided for @duplicatesMergeMetadataHint.
  ///
  /// In en, this message translates to:
  /// **'Tags, creator, favourite and description from the discarded copies.'**
  String get duplicatesMergeMetadataHint;

  /// No description provided for @duplicatesNotDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Not duplicates'**
  String get duplicatesNotDuplicates;

  /// No description provided for @duplicatesApplyAndNext.
  ///
  /// In en, this message translates to:
  /// **'Apply and next'**
  String get duplicatesApplyAndNext;

  /// No description provided for @duplicatesTagCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tags} =1{1 tag} other{{count} tags}}'**
  String duplicatesTagCount(int count);

  /// No description provided for @duplicatesFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get duplicatesFavorite;

  /// No description provided for @duplicatesNoCreator.
  ///
  /// In en, this message translates to:
  /// **'No creator'**
  String get duplicatesNoCreator;

  /// No description provided for @duplicatesUnknownSize.
  ///
  /// In en, this message translates to:
  /// **'Size unknown'**
  String get duplicatesUnknownSize;

  /// No description provided for @duplicatesPickGroup.
  ///
  /// In en, this message translates to:
  /// **'Pick a group to compare its copies'**
  String get duplicatesPickGroup;

  /// No description provided for @duplicatesApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'The group could not be resolved. Nothing was deleted.'**
  String get duplicatesApplyFailed;

  /// No description provided for @settingsDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Repeated content'**
  String get settingsDuplicates;

  /// No description provided for @duplicatesScanSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic search'**
  String get duplicatesScanSectionTitle;

  /// No description provided for @duplicatesScanSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Repeated content is not a nuisance the day it arrives; it is a nuisance months later, when there are forty copies and nobody remembers to look.'**
  String get duplicatesScanSectionNote;

  /// No description provided for @duplicatesAutoScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Let Fern look for repeats on its own'**
  String get duplicatesAutoScanLabel;

  /// No description provided for @duplicatesAutoScanDescription.
  ///
  /// In en, this message translates to:
  /// **'When you open Fern, if the time you pick below has gone by, it goes through the whole library without you asking: it runs in the background at the lowest priority, so it never gets in the way of what you are doing, and it only tells you if it finds something. Turned off, repeats are only looked for when you press “Scan now” in Repeated media.'**
  String get duplicatesAutoScanDescription;

  /// No description provided for @duplicatesScanPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get duplicatesScanPeriodLabel;

  /// No description provided for @duplicatesPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get duplicatesPeriodMonthly;

  /// No description provided for @duplicatesPeriodQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every three months'**
  String get duplicatesPeriodQuarterly;

  /// No description provided for @duplicatesPeriodBiannual.
  ///
  /// In en, this message translates to:
  /// **'Every six months'**
  String get duplicatesPeriodBiannual;

  /// No description provided for @duplicatesPeriodYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get duplicatesPeriodYearly;

  /// No description provided for @duplicatesLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last scan: {date}'**
  String duplicatesLastScan(String date);

  /// No description provided for @duplicatesLastScanNever.
  ///
  /// In en, this message translates to:
  /// **'Never scanned yet'**
  String get duplicatesLastScanNever;

  /// No description provided for @duplicatesOpenViewer.
  ///
  /// In en, this message translates to:
  /// **'Open full screen'**
  String get duplicatesOpenViewer;

  /// No description provided for @duplicatesThresholdSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Similarity bar'**
  String get duplicatesThresholdSectionTitle;

  /// No description provided for @duplicatesThresholdSectionNote.
  ///
  /// In en, this message translates to:
  /// **'How different two contents may be and still count as the same one. Raising it groups more and starts joining things that merely look alike; lowering it leaves repeats unfound. It applies to the next scan, not to what has already been grouped.'**
  String get duplicatesThresholdSectionNote;

  /// No description provided for @duplicatesThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get duplicatesThresholdLabel;

  /// No description provided for @duplicatesRehashSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get duplicatesRehashSectionTitle;

  /// No description provided for @duplicatesRehashSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Throws away every fingerprint and works them out again on the next scan. The way out when grouping goes wrong and there is no telling why. Groups you already answered are kept.'**
  String get duplicatesRehashSectionNote;

  /// No description provided for @duplicatesRehashButton.
  ///
  /// In en, this message translates to:
  /// **'Recalculate every fingerprint'**
  String get duplicatesRehashButton;

  /// No description provided for @duplicatesRehashRunning.
  ///
  /// In en, this message translates to:
  /// **'Clearing fingerprints'**
  String get duplicatesRehashRunning;

  /// No description provided for @duplicatesRehashDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{There was nothing to clear} =1{1 fingerprint cleared. It will be worked out again on the next scan.} other{{count} fingerprints cleared. They will be worked out again on the next scan.}}'**
  String duplicatesRehashDone(int count);

  /// No description provided for @duplicatesRehashFailed.
  ///
  /// In en, this message translates to:
  /// **'The fingerprints could not be cleared.'**
  String get duplicatesRehashFailed;
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
