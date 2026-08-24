// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sidebarCollapse => 'Collapse the menu';

  @override
  String get sidebarExpand => 'Expand the menu';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navTags => 'Tags';

  @override
  String get navMedia => 'Media';

  @override
  String get navImport => 'Import';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navDeleted => 'Deleted';

  @override
  String get navCreatorManager => 'Creator Manager';

  @override
  String get navTagManager => 'Tag Manager';

  @override
  String get navBrowser => 'Browser';

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
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favorites',
      one: '1 favorite',
      zero: 'No favorites yet',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String get filtersResultsFrom => 'Show results from';

  @override
  String get filterMedia => 'Media';

  @override
  String get filterTags => 'Tags';

  @override
  String get filterCreators => 'Creators';

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
  String selectedOfCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media marked for deletion',
      one: '1 media marked for deletion',
      zero: 'Nothing marked for deletion',
    );
    return '$_temp0';
  }

  @override
  String deletedRetentionNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Deleted for good after $days days',
      one: 'Deleted for good after 1 day',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip => 'Delete permanently from the database';

  @override
  String remoteImportWarning(String source) {
    return 'Media is about to be imported from $source';
  }

  @override
  String get remoteImportAmountAll =>
      'Everything saved in your account will be fetched.';

  @override
  String get remoteImportAmountSinceLast =>
      'Whatever you have saved since the last import will be fetched.';

  @override
  String remoteImportAmountLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media at most will be fetched.',
      one: '1 media at most will be fetched.',
    );
    return '$_temp0';
  }

  @override
  String get favoriteSelectedTooltip => 'Mark the selection as favourite';

  @override
  String get deleteSelectedTooltip =>
      'Move the selection to the deleted screen';

  @override
  String deleteTrashWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media are about to be deleted for good',
      one: '1 media is about to be deleted for good',
    );
    return '$_temp0';
  }

  @override
  String deleteDiscardWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media are about to be discarded',
      one: '1 media is about to be discarded',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesFromDisk => 'Delete the files from the disk as well';

  @override
  String get deleteFilesFromDiskDescription =>
      'If you clear it, the media leaves the database but its files stay where they are, so a later scan can pick them up again.';

  @override
  String get actionStopImport => 'Stop the import';

  @override
  String get actionImport => 'Import';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionSelectFolder => 'Choose folder';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionSave => 'Save';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get actionUnassignTag => 'Unassign tag';

  @override
  String get actionRemoveParentTag => 'Remove parent';

  @override
  String get actionDeleteTag => 'Delete tag';

  @override
  String get actionUnassignCreator => 'Unassign creator';

  @override
  String get actionDeleteCreator => 'Delete creator';

  @override
  String get sourceLocalComputer => 'Local computer';

  @override
  String get sourceAll => 'All';

  @override
  String get sourceBrowser => 'Browser';

  @override
  String get sourceBrowserNote => 'Open the browser';

  @override
  String get sourceBrowserHint =>
      'This content is not fetched from here: you pick it page by page on the Browser screen.';

  @override
  String get sourceNotConfigured => 'Not set up yet';

  @override
  String sourceLogIn(String source) {
    return 'Log in to $source';
  }

  @override
  String sourceLogInHint(String source) {
    return 'Opens $source in Fern\'s browser. Once you are in, press the key button there to save the session and come back.';
  }

  @override
  String get selectItem => 'Select';

  @override
  String get deselectItem => 'Deselect';

  @override
  String get viewerBack => 'Back';

  @override
  String get viewerShare => 'Copy to the clipboard';

  @override
  String get viewerFullscreen => 'Full screen';

  @override
  String get viewerExitFullscreen => 'Exit full screen';

  @override
  String get viewerSkipBack => 'Back five seconds';

  @override
  String get viewerSkipForward => 'Forward five seconds';

  @override
  String get viewerLoop => 'Play on repeat';

  @override
  String get viewerPlaybackSectionTitle => 'Video playback';

  @override
  String get viewerPlaybackSectionNote =>
      'What the viewer does to a video while you move along its timeline.';

  @override
  String get viewerPauseWhenSeeking => 'Pause when you take hold of the bar';

  @override
  String get viewerPauseWhenSeekingDescription =>
      'The video stops as soon as you take hold of the bar and stays where you leave it. Off, it carries on playing from wherever you drop it. Marking regions always pauses, whatever this says: a region is marked on a still frame.';

  @override
  String get fernieUndo => 'Undo the last region marked';

  @override
  String get createTooltip => 'Create';

  @override
  String get menuNewModel => 'New model';

  @override
  String get newModelTitle => 'New model';

  @override
  String get modelNameLabel => 'Model name';

  @override
  String get modelFunctionLabel => 'What it answers';

  @override
  String get modelFunctionBoolean => 'Is it there?';

  @override
  String get modelFunctionBooleanDescription =>
      'Says whether each of its fernies is in the media. With several, it answers for each one on its own.';

  @override
  String get modelFunctionClassification => 'Which one is it?';

  @override
  String get modelFunctionClassificationDescription =>
      'Tells its fernies apart and says which one it found, and where. Needs at least two: there is nothing to choose between with one.';

  @override
  String get modelsTitle => 'Models';

  @override
  String get modelsEmpty => 'No models yet';

  @override
  String get modelStatusUntrained => 'Not trained';

  @override
  String get modelStatusTraining => 'Training';

  @override
  String get modelStatusReady => 'Ready';

  @override
  String get modelStatusFailed => 'Training failed';

  @override
  String get modelDegradedNotice =>
      'With a single fernie there is nothing to choose between, so it answers whether it is there. Add another one to tell them apart.';

  @override
  String modelRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regions',
      one: '1 region',
      zero: 'no regions',
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
      zero: 'no fernies',
    );
    return '$_temp0';
  }

  @override
  String get modelDeleteTitle => 'Delete this model?';

  @override
  String get modelDeleteMessage =>
      'Its fernies stay where they are: they belong to you, not to the model. What is lost is what it had learned: the weights, the training charts and everything it left on disk.';

  @override
  String get splitTrain => 'Train';

  @override
  String get splitValidation => 'Validate';

  @override
  String get splitTest => 'Test';

  @override
  String get modelRemoveFernie => 'Take out of this model';

  @override
  String modelMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media',
      one: '1 media',
      zero: 'no media',
    );
    return '$_temp0';
  }

  @override
  String modelTooFewRegions(int count) {
    return 'Fewer than $count regions: not enough to train';
  }

  @override
  String modelFewRegions(int count) {
    return 'Fewer than $count regions: it will learn little';
  }

  @override
  String get modelTooFewMedia =>
      'Too few different media: it will learn the background';

  @override
  String get modelAssignedFernies => 'Assigned fernies';

  @override
  String get modelAddFernie => 'Add fernie';

  @override
  String get modelNoFernies =>
      'A model with no fernies has nothing to learn. Add at least one.';

  @override
  String get modelApplySplitToAll => 'Apply this split to all';

  @override
  String get modelRetrainNotice =>
      'Changing the fernies of a trained model means training it again: its weights no longer mean the same thing.';

  @override
  String get modelSaved => 'Saved';

  @override
  String get trainingTitle => 'Training';

  @override
  String get presetFast => 'Quick';

  @override
  String get presetFastDescription =>
      'To see whether the idea works before leaving the machine running all night. Also the sensible one without a graphics card.';

  @override
  String get presetBalanced => 'Balanced';

  @override
  String get presetBalancedDescription =>
      'What you want most of the time: enough to use the model for real.';

  @override
  String get presetAccurate => 'Thorough';

  @override
  String get presetAccurateDescription =>
      'When there are already plenty of regions and the model matters. Takes a good while.';

  @override
  String get presetCustom => 'Custom';

  @override
  String get presetCustomDescription =>
      'The settings do not match any of the above, so yours win.';

  @override
  String get trainingAdvanced => 'Advanced';

  @override
  String get trainingEpochsLabel => 'Epochs';

  @override
  String get trainingImageSizeLabel => 'Image size';

  @override
  String get trainingBatchLabel => 'Batch';

  @override
  String get trainingBatchAuto => '-1 lets it decide';

  @override
  String trainingBackboneIs(String backbone) {
    return 'Network: $backbone';
  }

  @override
  String get trainingStart => 'Train model';

  @override
  String get trainingRetrain => 'Train again';

  @override
  String get trainingPreparing => 'Preparing the dataset...';

  @override
  String trainingEpoch(int done, int total) {
    return 'Epoch $done of $total';
  }

  @override
  String trainingRemaining(int minutes) {
    return 'About $minutes min left';
  }

  @override
  String get trainingEngineNotReady =>
      'The recognition engine is not installed yet. Set it up in settings.';

  @override
  String get trainingNoValidation =>
      'nothing set aside to validate, so training cannot tell when to stop';

  @override
  String trainingImbalanced(int count) {
    return 'One fernie has more than $count times the regions of another: the model will learn to always answer the big one';
  }

  @override
  String get trainingQueued => 'Training queued';

  @override
  String get metricsLastTraining => 'Last training';

  @override
  String get metricMap50 => 'mAP50';

  @override
  String get metricMap50to95 => 'mAP50-95';

  @override
  String get metricPrecision => 'Precision';

  @override
  String get metricRecall => 'Recall';

  @override
  String get metricsPerClass => 'Per fernie';

  @override
  String get metricsConfusionMatrix => 'Confusion matrix';

  @override
  String get metricsCurves => 'Curves';

  @override
  String get metricsOpenRunFolder => 'Open run folder';

  @override
  String get metricsRunFolderMissing => 'That folder is no longer there.';

  @override
  String get metricsRunImagesMissing =>
      'Those images are no longer in the run folder. Deleting it does not break the model: the weights are all it needs to recognise.';

  @override
  String get metricsNotTrainedYet => 'Not trained yet.';

  @override
  String get metricsImportedWeights =>
      'The weights come from outside, so there are no training metrics.';

  @override
  String get metricsRetry => 'Try again';

  @override
  String get metricsRealPerformance => 'Real performance';

  @override
  String get metricsRealPerformanceEmpty =>
      'No data yet. It counts how many suggestions from this model you accept and reject while importing, which is the only honest measure of whether it works.';

  @override
  String get modelImportWeights => 'Import weights';

  @override
  String get modelImportWeightsHint =>
      'A .pt file trained elsewhere. It is copied into the recognition folder so it does not disappear from under the model.';

  @override
  String modelImportWeightsInvalid(String error) {
    return 'Those weights could not be read: $error';
  }

  @override
  String modelImportWeightsDone(String classes) {
    return 'Weights imported: $classes';
  }

  @override
  String get modelImportedBadge => 'Imported weights';

  @override
  String get trainingFailedEngineStopped =>
      'The recognition engine stopped mid-training. Try again; if it keeps happening, the machine is most likely running out of memory: lower the image size or the batch under Advanced.';

  @override
  String get trainingFailedOutOfMemory =>
      'It ran out of memory. Lower the batch or the image size under Advanced and try again.';

  @override
  String get trainingFailedDataset =>
      'The material could not be prepared. Some files may have moved or been deleted since the regions were marked.';

  @override
  String get trainingFailedWeights =>
      'The starting weights are missing and could not be downloaded. Check the connection, or import weights of your own.';

  @override
  String get trainingFailedNoSpace =>
      'There is not enough room on disk. A video dataset is thousands of frames, so it needs a few gigabytes free.';

  @override
  String get trainingFailedUnknown => 'Training failed.';

  @override
  String jobTrainingModel(String model) {
    return 'Training «$model»';
  }

  @override
  String get jobsNone => 'Nothing running';

  @override
  String get treeTitle => 'Model tree';

  @override
  String get treeOpen => 'Tree';

  @override
  String get treeEmpty =>
      'Nothing in the tree yet. A model that is not here never runs when recognising: add one from the panel on the right.';

  @override
  String get treeSearchModel => 'Search a model';

  @override
  String get treeAvailableModels => 'Models';

  @override
  String get treeAllInTree => 'They are all in the tree already.';

  @override
  String get treeNoModels => 'There are no models yet.';

  @override
  String get treeRemoveNode => 'Take out of the tree';

  @override
  String get treeNodeNotTrained => 'Not trained';

  @override
  String get treeAddAsRoot => 'Add on its own';

  @override
  String treeAddAsChild(String parent) {
    return 'Hang from «$parent»';
  }

  @override
  String treeSelectedHint(String name) {
    return '«$name» is selected: what you add from the panel hangs from it.';
  }

  @override
  String get treeClearSelection => 'Deselect';

  @override
  String get treeEdgeAnyDetection => 'anything';

  @override
  String get treeEdgeConditionTitle => 'When does it run?';

  @override
  String treeEdgeConditionMessage(String child, String parent) {
    return '«$child» only runs when «$parent» detects this. Without a fernie it runs on any detection, which means the specialised models run all the time: it works, but it is the thing to narrow down.';
  }

  @override
  String get treeEdgeDisconnect => 'Unhook';

  @override
  String get treeFitToView => 'Fit to view';

  @override
  String get treeZoomIn => 'Zoom in';

  @override
  String get treeZoomOut => 'Zoom out';

  @override
  String get treeCannotConnect =>
      'That cannot be hooked up: it would make the tree bite its own tail.';

  @override
  String treeOutsideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models outside the tree',
      one: '1 model outside the tree',
    );
    return '$_temp0';
  }

  @override
  String get viewerFavorite => 'Mark as favourite';

  @override
  String get viewerUnfavorite => 'Remove from favourites';

  @override
  String get viewerCopied => 'Copied to the clipboard';

  @override
  String get viewerCopyFailed => 'This content could not be copied';

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
  String get creatorsTitle => 'Creators';

  @override
  String get noCreatorsYet => 'No creators yet';

  @override
  String get noSocialProfiles => 'No social profiles';

  @override
  String get openProfileTooltip => 'Open the profile in the browser';

  @override
  String get editProfileTooltip => 'Edit link';

  @override
  String get doneEditingProfileTooltip => 'Done editing';

  @override
  String get removeProfileTooltip => 'Remove link';

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
  String get creatorNameTaken => 'There is already a creator with that name';

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
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsViewer => 'Viewer';

  @override
  String get settingsFiles => 'Files';

  @override
  String get settingsRemoteSources => 'Remote sources';

  @override
  String get languageSectionTitle => 'Application language';

  @override
  String get languageSectionNote =>
      'Every screen switches over as soon as you pick a language.';

  @override
  String get sidebarSectionTitle => 'Side menu';

  @override
  String get sidebarSectionNote =>
      'How the tag list of the side menu is drawn.';

  @override
  String get showListAvatars => 'Show avatars in the list';

  @override
  String get showListAvatarsDescription =>
      'Each tag is drawn with its own picture instead of the shared icon, so you can tell them apart while the menu is collapsed. Tags without a picture keep the icon.';

  @override
  String get viewerSaveSectionTitle => 'Saving imported media';

  @override
  String get viewerSaveSectionNote =>
      'What the viewer does once you mark an imported media as final. It leaves the import grid either way, so the viewer cannot stay where it was.';

  @override
  String get viewerSaveNext => 'Go to the next media';

  @override
  String get viewerSaveNextDescription =>
      'The viewer moves on to the next media, just as if you had pressed the arrow. With nothing left to review, it closes.';

  @override
  String get viewerSaveClose => 'Close the viewer';

  @override
  String get viewerSaveCloseDescription =>
      'The viewer closes and you are back at the import grid, already without that media.';

  @override
  String get themeSectionTitle => 'Theme';

  @override
  String get themeSectionNote =>
      'The colours the whole application is painted with.';

  @override
  String get themeSystem => 'Follow the system';

  @override
  String get themeSystemDescription =>
      'Light or dark, whichever your desktop is using.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDescription => 'The colours Fern has always had.';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDescription =>
      'The same application, for a dark desktop.';

  @override
  String get themeCustom => 'Custom';

  @override
  String get themeCustomDescription =>
      'Your own colours, the ones you pick below.';

  @override
  String get customColorsTitle => 'Your colours';

  @override
  String get customColorsNote =>
      'Only within reach with the custom theme. Whatever you leave untouched is taken from the light or the dark theme, whichever suits the background you chose.';

  @override
  String get customColorPrimary => 'Primary';

  @override
  String get customColorSecondary => 'Secondary';

  @override
  String get customColorTerciary => 'Accent';

  @override
  String get customColorError => 'Error';

  @override
  String get customColorBackground => 'Background';

  @override
  String get customColorSurface => 'Surface';

  @override
  String get customColorForeground => 'Text';

  @override
  String get customColorPick => 'Choose colour';

  @override
  String get customColorReset => 'Back to the default colour';

  @override
  String get colorPickerTitle => 'Choose a colour';

  @override
  String get colorPickerHex => 'Hex code';

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

  @override
  String get redditTitle => 'Reddit';

  @override
  String get redditDescription =>
      'Fern downloads what you have saved in your Reddit account. Register a script application at reddit.com/prefs/apps to get the two keys.';

  @override
  String get redditClientId => 'Client ID';

  @override
  String get redditClientIdHint => 'The key under the name of your application';

  @override
  String get redditClientSecret => 'Client secret';

  @override
  String get redditClientSecretHint => 'The secret of your application';

  @override
  String get redditUsername => 'Username';

  @override
  String get redditUsernameHint => 'Your Reddit account, without /u/';

  @override
  String get redditPassword => 'Password';

  @override
  String get redditPasswordHint => 'The password of that account';

  @override
  String get redditCredentialsNote =>
      'The credentials stay on this computer and are only used to talk to Reddit.';

  @override
  String get settingsBrowser => 'Browser';

  @override
  String get browserHome => 'Home page';

  @override
  String get browserHomeTitle => 'Home page';

  @override
  String get browserHomeDescription =>
      'Where Fern\'s browser starts when you press the home button. It does not affect where it opens: coming back to the screen leaves the browser on the last page you visited.';

  @override
  String get browserHomeLabel => 'Address';

  @override
  String credentialsRejectedTitle(String source) {
    return '$source did not accept your credentials';
  }

  @override
  String credentialsRejectedDescription(String source) {
    return 'Nothing could be imported: $source turned down the account or the key it was given. Check them in Settings, under Remote sources.';
  }

  @override
  String get actionOpenRemoteSettings => 'Open settings';

  @override
  String sessionExpiredTitle(String source) {
    return 'Your $source session is no longer valid';
  }

  @override
  String sessionExpiredDescription(String source) {
    return 'Fern could not import anything: $source has rejected the saved session. Log in again in the browser and press the key button there to save the new one.';
  }

  @override
  String browserImportedInto(int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media ready to review under $source',
      one: '1 media ready to review under $source',
    );
    return '$_temp0';
  }

  @override
  String browserImportKnown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count were already in the library',
      one: '1 was already in the library',
    );
    return '$_temp0';
  }

  @override
  String browserImportFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count could not be downloaded',
      one: '1 could not be downloaded',
    );
    return '$_temp0';
  }

  @override
  String get browserImportNothing => 'Nothing was brought in.';

  @override
  String get danbooruTitle => 'Danbooru';

  @override
  String get danbooruDescription =>
      'Fern downloads the posts you have favourited on Danbooru. Its API is public: all it needs is your account name and an API key.';

  @override
  String get danbooruUsername => 'Account name';

  @override
  String get danbooruUsernameHint => 'Your Danbooru user name';

  @override
  String get danbooruApiKey => 'API key';

  @override
  String get danbooruApiKeyHint => 'A key from your Danbooru profile';

  @override
  String get danbooruApiKeyNote =>
      'On Danbooru, open your profile, go to API Key and create one. It is not your password: you can revoke it whenever you like without changing anything else. It stays on this computer and is only used to talk to Danbooru.';

  @override
  String get gelbooruTitle => 'Gelbooru';

  @override
  String get gelbooruDescription =>
      'Fern downloads the posts you have favourited on Gelbooru. Its favourites API is slower than the rest: it hands out references rather than posts, so each one has to be asked for separately.';

  @override
  String get gelbooruUserId => 'Account id';

  @override
  String get gelbooruUserIdHint => 'The number of your Gelbooru account';

  @override
  String get gelbooruApiKey => 'API key';

  @override
  String get gelbooruApiKeyHint => 'The key of that account';

  @override
  String get gelbooruApiKeyNote =>
      'On Gelbooru, go to My Account, then Options, and look for API Access Credentials: both the id and the key are there. They stay on this computer and are only used to talk to Gelbooru.';

  @override
  String get pinterestTitle => 'Pinterest';

  @override
  String get pinterestDescription =>
      'Fern downloads what you have saved on Pinterest. Whatever is in public boards needs nothing but your account name.';

  @override
  String get pinterestUsername => 'Account name';

  @override
  String get pinterestUsernameHint => 'Your Pinterest user name';

  @override
  String get pinterestSecretBoardsNote =>
      'To bring in what you keep in secret boards, log in to Pinterest from Fern’s browser and press the key button there: the session is saved along with the name.';

  @override
  String get pawchiveTitle => 'Pawchive';

  @override
  String get pawchiveDescription =>
      'Fern downloads the posts you have favourited on Pawchive. There is nothing to fill in here: log in from Fern’s browser and press the key button there, and the session is saved.';

  @override
  String linkChoiceTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This post has $count links',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceUntitledPost => 'Untitled post';

  @override
  String get linkChoiceApplyToAll => 'Apply to the rest of the import';

  @override
  String get linkChoiceApplyToAllDescription =>
      'The same answer is used for every post left, so you are not asked again.';

  @override
  String get linkChoiceIgnore => 'Skip post';

  @override
  String linkChoiceSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Download $count',
      zero: 'Download selection',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceAll => 'Download all';

  @override
  String get linkChoiceOpen => 'Open in the browser';

  @override
  String repositoryLinkTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This post links to $count file hosts',
      one: 'This post links to a file host',
    );
    return '$_temp0';
  }

  @override
  String get repositoryLinkDescription =>
      'Fern cannot fetch from these on its own: they have their own waits and checks. You can open them in Fern’s browser and bring in what you want from there. The import carries on meanwhile.';

  @override
  String get repositoryLinkOpen => 'Open in the browser';

  @override
  String get pawchiveByCreators => 'Import from favourited creators';

  @override
  String get pawchiveByCreatorsDescription =>
      'Instead of the posts you have favourited, Fern goes through everything published by the creators you have favourited. It brings in a great deal more, and each creator is followed on its own.';

  @override
  String get remoteImportHeavyWarning =>
      'This may take a long while: with no cap, Fern goes through the whole account and brings in everything, files inside posts included. You can stop it at any time from the import screen, and what has already arrived stays.';

  @override
  String emptySource(String source) {
    return 'There was nothing to bring in from $source.';
  }

  @override
  String get emptySourcePawchiveCreators =>
      'You have no favourited posts on Pawchive, but you do have favourited creators. Turn on \"Import from favourited creators\" in Settings, under Remote sources, and Fern will go through everything they publish.';

  @override
  String get browserAddressHint => 'Address of a site';

  @override
  String get browserBack => 'Back';

  @override
  String get browserForward => 'Forward';

  @override
  String get browserReload => 'Reload';

  @override
  String get browserSaveSessionHint =>
      'Save the session of this site so Fern can import from it';

  @override
  String get browserFindMediaHint => 'Look for media on this page';

  @override
  String browserImportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count',
      one: 'Import 1',
    );
    return '$_temp0';
  }

  @override
  String get browserSelectAll => 'Select or clear all';

  @override
  String get browserClose => 'Close';

  @override
  String get browserNoSession =>
      'Fern cannot import from this site, so there is no session to save here.';

  @override
  String browserSessionSaved(String source) {
    return '$source session saved.';
  }

  @override
  String browserSessionMissing(String source) {
    return 'There is no $source session open here yet: log in first.';
  }

  @override
  String get browserNothingFound => 'No media found on this page.';

  @override
  String browserFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media found',
      one: '1 media found',
    );
    return '$_temp0';
  }

  @override
  String browserImporting(int done, int total) {
    return 'Downloading $done of $total…';
  }

  @override
  String importFailed(String error) {
    return 'The import could not be completed: $error';
  }

  @override
  String get importLimitAll => 'All';

  @override
  String get importLimitSinceLast => 'New';

  @override
  String get importLimitSinceLastTooltip =>
      'Only what has been saved since the last import';

  @override
  String get importLimitTooltip => 'Most items a scan brings in';

  @override
  String get lastImportNever => 'Never imported';

  @override
  String get sourceNotConfiguredHint =>
      'Set this source up in Settings before importing from it';

  @override
  String get lastImportHint =>
      'When this source was last checked for new content';

  @override
  String lastImportMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
      zero: 'Just now',
    );
    return '$_temp0';
  }

  @override
  String lastImportHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String lastImportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get assignUrlsTitle => 'Linked addresses';

  @override
  String assignUrlsTo(String name) {
    return 'Addresses linked to $name';
  }

  @override
  String get assignUrlsDescription =>
      'Whatever is imported from these addresses gets this tag on its own, without asking the platform anything.';

  @override
  String get assignUrlsTooltip => 'Link addresses to this tag';

  @override
  String get assignUrlsCreatorDescription =>
      'Whatever is imported from these addresses gets this creator on its own, without asking the platform anything.';

  @override
  String get assignUrlsCreatorTooltip => 'Link addresses to this creator';

  @override
  String get sourceUrlsLabel => 'Addresses';

  @override
  String get sourceUrlHint => 'reddit.com/r/example';

  @override
  String get addSourceUrl => 'Add address';

  @override
  String get filtersSource => 'Show media from';

  @override
  String get sourceLocal => 'This computer';

  @override
  String get autoTagRemoteSource => 'Auto-tag remote source';

  @override
  String get autoTagRemoteSourceDescription =>
      'Fern creates a tag for each platform (Reddit, and so on) and puts it on what it imports from it. With this off the source is still recorded, and you filter by it from the Filters button.';

  @override
  String get startupFailedTitle => 'Fern could not start';

  @override
  String get startupFailedDatabase =>
      'The database could not be brought up to the version this release needs.';

  @override
  String get startupFailedHint =>
      'Nothing has been lost: your content is still where it was. Close Fern and open it again, and if this keeps happening, the details below say what went wrong.';

  @override
  String get settingsRecognition => 'Recognition';

  @override
  String get recognitionFolderTitle => 'Recognition data';

  @override
  String get recognitionFolderDescription =>
      'Where Fern keeps everything it needs to recognise your content: the training environment, the trained models and the data sets it builds to train them. It can take several gigabytes, so you may prefer it on another drive.';

  @override
  String get recognitionFolder => 'Recognition folder';

  @override
  String recognitionFolderMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files moved to the new folder',
      one: '1 file moved to the new folder',
      zero: 'The folder was already there',
    );
    return '$_temp0';
  }

  @override
  String get recognitionFolderMoveFailed =>
      'The recognition data could not be moved';

  @override
  String get jobsTooltip => 'Tasks running';

  @override
  String get jobsTitle => 'Background tasks';

  @override
  String get jobsEmpty => 'Nothing running right now';

  @override
  String get jobCancelTooltip => 'Cancel this task';

  @override
  String jobProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get jobQueued => 'Waiting';

  @override
  String get jobFailed => 'Failed';

  @override
  String get jobTraining => 'Training model';

  @override
  String get jobRecognition => 'Recognising content';

  @override
  String get jobDuplicateScan => 'Looking for repeated media';

  @override
  String get jobHashing => 'Reading content';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Alerts';

  @override
  String get notificationsDescription =>
      'Training a model, recognising a batch or looking for repeated media can take a long while. Fern tells you when it is done so you do not have to keep checking.';

  @override
  String get notificationsEnabled => 'Alert me';

  @override
  String get notificationsEnabledDescription =>
      'With this off nothing is counted and nothing plays. What was already pending stays noted, and comes back when you turn it on again.';

  @override
  String get notificationsMuted => 'Silent';

  @override
  String get notificationsMutedDescription => 'Counters stay, sounds do not.';

  @override
  String get notificationsSoundTitle => 'Sound';

  @override
  String get notificationsVolume => 'Volume';

  @override
  String get notificationsMaxSeconds => 'Play at most';

  @override
  String notificationsSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get notificationsMaxSecondsDescription =>
      'An alert is a short chime. If the audio you pick is longer, Fern stops it here instead of playing the whole thing. Your file is not touched.';

  @override
  String get notificationsEventsTitle => 'What to alert about';

  @override
  String get notificationsEventsDescription =>
      'For each one, whether it puts a counter on the side menu and whether it plays a sound.';

  @override
  String get notificationsBadge => 'Counter';

  @override
  String get notificationsSound => 'Sound';

  @override
  String get notificationsDefaultSound => 'Fern sound';

  @override
  String get notificationsPreview => 'Listen';

  @override
  String get notificationsChooseSound => 'Choose an audio file';

  @override
  String get notificationsResetSound => 'Back to the Fern sound';

  @override
  String get notifyDuplicates => 'Repeated media found';

  @override
  String get notifyTraining => 'Model finished training';

  @override
  String get notifyRecognition => 'Batch recognition finished';

  @override
  String get notifyRemoteImport => 'Remote import finished';

  @override
  String get sidecarTitle => 'Recognition engine';

  @override
  String get sidecarDescription =>
      'To train and recognise, Fern installs its own small Python environment inside the recognition folder. It does not touch your system and you do not need to have Python installed beforehand: it brings its own. It takes about 1.2 GB on disk and is only downloaded when you ask for it.';

  @override
  String get sidecarUnsupportedPlatform =>
      'Recognition is not available on this system yet.';

  @override
  String get sidecarNotInstalled => 'Not installed yet';

  @override
  String get sidecarDownloadingUv => 'Downloading the installer';

  @override
  String get sidecarInstallingPython => 'Installing Python';

  @override
  String get sidecarCreatingVenv => 'Preparing the environment';

  @override
  String get sidecarDetectingHardware => 'Checking your hardware';

  @override
  String get sidecarInstallingTorch => 'Downloading the engine';

  @override
  String get sidecarInstallingUltralytics => 'Installing YOLO';

  @override
  String get sidecarCleaning => 'Cleaning up';

  @override
  String get sidecarVerifying => 'Checking everything works';

  @override
  String get sidecarReady => 'Ready to train and recognise';

  @override
  String get sidecarError => 'Something went wrong';

  @override
  String sidecarDownloaded(String received, String total) {
    return '$received MB of $total MB';
  }

  @override
  String get sidecarInstall => 'Install';

  @override
  String get sidecarReinstall => 'Reinstall';

  @override
  String get sidecarEnableGpu => 'Use the graphics card';

  @override
  String get sidecarUninstall => 'Uninstall';

  @override
  String get sidecarShowLog => 'Show details';

  @override
  String get sidecarHideLog => 'Hide details';

  @override
  String get sidecarFailureInUse => 'The engine files are in use right now';

  @override
  String get sidecarFailureInUseHint =>
      'Something still has them open, so they cannot be replaced. Close Fern completely, open it again and press Install. If it keeps happening, restart the computer: that always releases them.';

  @override
  String get sidecarFailureSpace => 'There is no room left on the disk';

  @override
  String get sidecarFailureSpaceHint =>
      'The engine needs about 1.5 GB free, counting what it uses while installing. Free up some space, or move the recognition folder to another drive from the field above.';

  @override
  String get sidecarFailureNetwork => 'The download could not be completed';

  @override
  String get sidecarFailureNetworkHint =>
      'Check your internet connection and press Install again. What was already downloaded is kept, so it carries on where it left off.';

  @override
  String get sidecarFailureBlocked =>
      'The system would not let Fern run the installer';

  @override
  String get sidecarFailureBlockedHint =>
      'This is usually the antivirus stopping a freshly downloaded program. Allow Fern in your antivirus, or choose a recognition folder inside your own user folder, and try again.';

  @override
  String get sidecarFailureMissing => 'Something the engine needs is missing';

  @override
  String get sidecarFailureMissingHint =>
      'The installation was left half done. Press Uninstall to clear it out and then Install again.';

  @override
  String get sidecarFailureUnknown => 'The engine could not be installed';

  @override
  String get sidecarFailureUnknownHint =>
      'Press Install to try again. If it keeps failing, open the details below: they say exactly which step went wrong.';

  @override
  String get sidecarInstallCpu => 'Install for the processor';

  @override
  String get sidecarInstallGpu => 'Install for the graphics card';

  @override
  String get sidecarEnableCpu => 'Go back to the processor';

  @override
  String sidecarPercent(int percent) {
    return '$percent %';
  }

  @override
  String get sidecarBusyDownloading => 'Downloading packages...';

  @override
  String get sidecarBusyUnpacking => 'Unpacking what has arrived...';

  @override
  String get sidecarBusyPatience => 'This step takes a few minutes.';

  @override
  String get sidecarBusySettling => 'Putting everything in place...';

  @override
  String get sidecarBusyKeepUsing => 'You can keep using Fern meanwhile.';

  @override
  String get gpuDialogTitle => 'Install the graphics card version?';

  @override
  String get gpuDialogBenefit =>
      'Training goes much faster: what takes hours on the processor can be minutes on the graphics card.';

  @override
  String get gpuDialogTime =>
      'The download is around 2.5 GB, so it can take a good while on a normal connection.';

  @override
  String get gpuDialogSize =>
      'It takes about 5 GB on disk, instead of the 1.2 GB of the processor version.';

  @override
  String get gpuDialogReversible =>
      'You can go back to the processor version whenever you want, without reinstalling everything.';

  @override
  String get gpuDialogConfirm => 'Install it';

  @override
  String get navRecognition => 'Recognition';

  @override
  String get navFernies => 'Fernies';

  @override
  String get navRepeatedMedia => 'Repeated media';

  @override
  String get navModels => 'Model';

  @override
  String get menuNewFernie => 'New fernie';

  @override
  String get newFernieTitle => 'New fernie';

  @override
  String get fernieNameLabel => 'Fernie name';

  @override
  String get ferniesTitle => 'Fernies';

  @override
  String get addFernie => 'Add fernie';

  @override
  String get noFerniesYet => 'No fernies yet';

  @override
  String get fernieNoRegions => 'This fernie has no regions yet';

  @override
  String get fernieNoneHere => 'No fernies marked here yet';

  @override
  String get fernieLinkLabel => 'It proposes';

  @override
  String get fernieLinkNone => 'Nothing';

  @override
  String get fernieLinkTag => 'A tag';

  @override
  String get fernieLinkCreator => 'A creator';

  @override
  String get fernieLinkNoneHint => 'It only trains: on its own it tags nothing';

  @override
  String get fernieLinkMissing => 'What it was linked to no longer exists';

  @override
  String get fernieFewRegions => 'Few regions to train reliably';

  @override
  String get fernieLowVariety =>
      'Little variety: the model will learn the background, not the object';

  @override
  String get fernieRegionPending =>
      'Pending content: this region will not be used to train until you save it';

  @override
  String get fernieRegionTiny =>
      'Very small region: it may not help the training';

  @override
  String get actionDeleteFernie => 'Delete fernie';

  @override
  String get actionRemoveLink => 'Remove link';

  @override
  String get actionDeleteRegions => 'Delete regions';

  @override
  String get fernieToolSelect => 'Mark regions';

  @override
  String get fernieToolEdit => 'Edit regions';

  @override
  String get fernieRegionConfirm => 'Save the changes to this region';

  @override
  String get fernieRegionCancel => 'Discard the changes to this region';

  @override
  String get fernieRegionDelete => 'Delete this region';

  @override
  String get fernieRegionDeleteTitle => 'Delete this region?';

  @override
  String get fernieRegionDeleteMessage =>
      'The region is removed from its fernie. If it was the only one of that fernie in this content, the fernie stops being marked here.';

  @override
  String get fernieRegionDiscardTitle => 'Discard the changes to the region?';

  @override
  String get fernieRegionDiscardMessage =>
      'What you changed in the selected region will not be saved.';

  @override
  String get fernieTimelinePlay => 'Play to check the marked regions';

  @override
  String get fernieTimelinePause => 'Stop';

  @override
  String get fernieFramePrevious => 'Previous frame';

  @override
  String get fernieFrameNext => 'Next frame';

  @override
  String get fernieOnionSkin => 'Onion skin: show the previous marked frame';

  @override
  String get fernieDragRegions =>
      'Drag the region across every frame in between';

  @override
  String get fernieModeTooltip => 'Mark regions';

  @override
  String get fernieModeAccept => 'Save the regions';

  @override
  String get fernieModeCancel => 'Discard the regions';

  @override
  String get fernieModeHint =>
      'Drag over the content to mark a region. Hold space or the middle button to pan.';

  @override
  String get fernieDiscardTitle => 'Discard what you marked?';

  @override
  String get fernieDiscardMessage =>
      'The regions marked in this session will be lost.';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get assignRegionTitle => 'Assign the region';

  @override
  String get searchFernieHint => 'Search fernie...';

  @override
  String get createFernie => 'Create fernie';

  @override
  String fernieRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regions',
      one: '1 region',
      zero: 'No regions',
    );
    return '$_temp0';
  }

  @override
  String fernieMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count media',
      one: 'in 1 media',
      zero: 'in no media',
    );
    return '$_temp0';
  }

  @override
  String fernieRecommendedRegions(int count) {
    return 'At least $count regions are recommended';
  }

  @override
  String get viewerRecognize => 'Recognise with models';

  @override
  String get viewerRecognizing => 'Recognising…';

  @override
  String get viewerRecognizeQueued => 'Recognition queued';

  @override
  String get suggestionsTitle => 'Suggestions';

  @override
  String suggestionConfidence(int percent) {
    return '$percent%';
  }

  @override
  String get suggestionFromModel => 'Suggested by a model, not confirmed yet';

  @override
  String get suggestionCreatorTitle => 'Suggested creator';

  @override
  String get suggestionsNone => 'Nothing suggested here';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionReject => 'Reject';

  @override
  String get suggestionAcceptAll => 'Accept all';

  @override
  String get suggestionRejectAll => 'Reject all';

  @override
  String get recognizeNoModelsInTree =>
      'There are no models in the tree yet. Add one from the model tree screen.';

  @override
  String get recognizeNoTrainedModels =>
      'No model in the tree has been trained yet. Train one, or import its weights from the model screen.';

  @override
  String get recognizeUnavailable => 'The model tree could not be read.';

  @override
  String get recognizeFoundNothing => 'The models did not find anything here';

  @override
  String get recognizeNothingToDo => 'There is nothing left to recognise here';

  @override
  String get recognizeSelectedTooltip => 'Recognise the selection';

  @override
  String get recognizeTagTooltip => 'Recognise everything with this tag';

  @override
  String get recognizeCreatorTooltip => 'Recognise everything by this creator';

  @override
  String get recognizeLibrary => 'Recognise the library';

  @override
  String get recognizeLibraryTitle => 'Recognise the whole library';

  @override
  String get recognizeLibraryQuestion =>
      'Recognising takes about one prediction per image, and several per video. Choose how much to go through.';

  @override
  String get recognizeLibraryOnlyNew => 'Only what has never been looked at';

  @override
  String get recognizeLibraryAll => 'Everything, again';

  @override
  String get recognizeLibraryAllHint => 'Useful after training a better model.';

  @override
  String get recognizeJobLibrary => 'Whole library';

  @override
  String get recognizeJobSelection => 'Selection';

  @override
  String recognizeQueuedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items queued to recognise',
      one: '1 item queued to recognise',
      zero: 'Nothing queued',
    );
    return '$_temp0';
  }

  @override
  String recognizeCountable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get recognitionLogTitle => 'What the models did';

  @override
  String get recognitionLogNearMiss => 'seen, below the bar';

  @override
  String get recognitionLogNothing => 'nothing';

  @override
  String get recognitionLogVerdictProposed => 'suggested';

  @override
  String recognitionLogVerdictBelow(int percent) {
    return 'seen, but under $percent%';
  }

  @override
  String get recognitionLogVerdictNothing => 'saw nothing';

  @override
  String get recognitionLogVerdictNotReached =>
      'did not run: its branch never opened';

  @override
  String get recognitionLogVerdictUntrained => 'did not run: it has no weights';

  @override
  String get jobDetailTooltip => 'See what the models did';

  @override
  String get jobsClearFinished => 'Dismiss the finished ones';

  @override
  String get recognitionLogFromToast => 'Tap to see what the models did';

  @override
  String recognitionLogSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: 'One item',
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
  String get jobDone => 'Done';

  @override
  String recognizeFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions found. Tap to see how',
      one: '1 suggestion found. Tap to see how',
    );
    return '$_temp0';
  }

  @override
  String get recognitionPanelTitle => 'When recognising';

  @override
  String get recognitionThresholdLabel => 'Minimum confidence to suggest';

  @override
  String get recognitionThresholdDescription =>
      'Below this, what it sees is not proposed.';

  @override
  String get recognitionThresholdEverything =>
      'Everything it sees gets proposed, however unsure.';

  @override
  String get recognitionThresholdAll => 'All';

  @override
  String get recognitionThresholdLower => 'Lower the bar';

  @override
  String get recognitionThresholdRaise => 'Raise the bar';

  @override
  String get recognitionThresholdApplies =>
      'Applies to the next recognition. What is already suggested does not change.';

  @override
  String get recognizeReturnTitle => 'They will leave the library for a while';

  @override
  String get recognizeReturnHint =>
      'Only the ones that get a suggestion. You can turn this off in Settings, under Recognition.';

  @override
  String get recognizeReturnConfirm => 'Recognise anyway';

  @override
  String get returnRecognizedLabel =>
      'Send recognised content back to importing';

  @override
  String get returnRecognizedDescription =>
      'Content that gets a suggestion stops being final until you validate it. Turned off, the suggestions still show in the viewer panel and nothing moves.';

  @override
  String recognizeReturnWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items will go back to the import screen until you validate their tags.',
      one:
          'One item will go back to the import screen until you validate its tags.',
    );
    return '$_temp0';
  }

  @override
  String get suggestionsPendingBadge => 'Has suggestions waiting';

  @override
  String get suggestionFilterAll => 'Everything';

  @override
  String get suggestionFilterWith => 'With suggestions';

  @override
  String get suggestionFilterNever => 'Never looked at';

  @override
  String acceptAboveTooltip(int percent) {
    return 'Accepts what the models are over $percent% sure about, in the selection. It does not mark anything as final.';
  }

  @override
  String acceptAboveDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions accepted',
      one: '1 suggestion accepted',
      zero: 'Nothing was confident enough',
    );
    return '$_temp0';
  }

  @override
  String get actionClearSelection => 'Clear selection';

  @override
  String acceptAboveLabel(int percent) {
    return 'Accept over $percent%';
  }

  @override
  String get importShowLabel => 'Show';

  @override
  String get importFetchLabel => 'Fetch';

  @override
  String get recognizeJobImported => 'Just imported';

  @override
  String get recognizeOnImportLabel => 'Recognise what has just been imported';

  @override
  String get recognizeOnImportDescription =>
      'New content goes to the models on its own, once the import settles. Costs nothing if no model is trained.';

  @override
  String get suggestionMarkRegion => 'Save as a region of this fernie';

  @override
  String get suggestionRegionSaved =>
      'Region saved. It counts for the next training.';

  @override
  String get suggestionRegionFailed => 'The region could not be saved';

  @override
  String get duplicatesScanNow => 'Scan now';

  @override
  String get duplicatesScanning => 'Looking for repeats';

  @override
  String get duplicatesQueued =>
      'Looking for repeats. It may take a while on the first run.';

  @override
  String get duplicatesNone => 'No repeated content found';

  @override
  String get duplicatesNoneHint =>
      'Scan again after importing, or lower the similarity bar in Settings.';

  @override
  String get duplicatesNeverScanned => 'Nothing has been scanned yet';

  @override
  String get duplicatesNeverScannedHint =>
      'Press “Scan now” and Fern goes through the whole library. It may take a while on the first run.';

  @override
  String duplicatesScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scan finished: $count new groups',
      one: 'Scan finished: 1 new group',
    );
    return '$_temp0';
  }

  @override
  String duplicatesScanNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scan finished: nothing new. $count groups still to review.',
      one: 'Scan finished: nothing new. 1 group still to review.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesScanClean => 'Scan finished: no repeated content.';

  @override
  String get duplicatesScanStopped =>
      'Scan stopped. The fingerprints already worked out stay done.';

  @override
  String get duplicatesScanFailed => 'The scan could not finish. Try again.';

  @override
  String duplicatesGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String duplicatesDistance(int distance) {
    return 'distance $distance';
  }

  @override
  String get duplicatesIdentical => 'identical';

  @override
  String duplicatesCopyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copies',
      one: '1 copy',
    );
    return '$_temp0';
  }

  @override
  String duplicatesGroupPosition(int position, int total) {
    return 'Group $position of $total';
  }

  @override
  String get duplicatesKeepThis => 'Keep this one';

  @override
  String get duplicatesMergeMetadata => 'Merge metadata into the copy you keep';

  @override
  String get duplicatesMergeMetadataHint =>
      'Tags, creator, favourite and description from the discarded copies.';

  @override
  String get duplicatesNotDuplicates => 'Not duplicates';

  @override
  String get duplicatesApplyAndNext => 'Apply and next';

  @override
  String duplicatesTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
      zero: 'No tags',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesFavorite => 'Favourite';

  @override
  String get duplicatesNoCreator => 'No creator';

  @override
  String get duplicatesUnknownSize => 'Size unknown';

  @override
  String get duplicatesPickGroup => 'Pick a group to compare its copies';

  @override
  String get duplicatesApplyFailed =>
      'The group could not be resolved. Nothing was deleted.';

  @override
  String get settingsDuplicates => 'Repeated content';

  @override
  String get settingsNsfw => 'NSFW content';

  @override
  String get nsfwCoveredLabel => 'NSFW content';

  @override
  String get nsfwViewsTitle => 'How it behaves';

  @override
  String get nsfwViewsNote =>
      'What you see with the filter on and what you see with it off. Both apply to whatever is drawn next, with nothing to restart.';

  @override
  String get nsfwUnlockedViewLabel => 'Without the NSFW filter';

  @override
  String get nsfwUnlockedViewMixed => 'Everything together';

  @override
  String get nsfwUnlockedViewOnly => 'Only what is marked';

  @override
  String get nsfwUnlockedViewNote =>
      '“Only what is marked” turns it into a separate library: while the filter is off, the rest of your content does not show up.';

  @override
  String get nsfwLockedViewLabel => 'With the NSFW filter';

  @override
  String get nsfwLockedViewHidden => 'It does not show up';

  @override
  String get nsfwLockedViewBlurred => 'It shows up covered';

  @override
  String get nsfwChildTagsLabel => 'Marking a tag also marks the ones under it';

  @override
  String get nsfwChildTagsDescription =>
      'A tag that hangs from a marked one hides its content too, without having to mark it as well. Turned off, each tag answers only for its own. Nothing is rewritten either way: turn it on and off as you like.';

  @override
  String get nsfwLockedViewNote =>
      'Covered, marked content keeps its place in the grid, blurred and with a padlock; touching it asks for the password. It is handier, but it does show that something is there: how much, and what shape it has.';

  @override
  String get nsfwSectionTitle => 'NSFW content filter';

  @override
  String get nsfwSectionNote =>
      'What you mark as NSFW gets hidden: with the filter on it shows up nowhere, not in the trash and not in searches.';

  @override
  String get nsfwSectionWarning =>
      'This hides, it does not encrypt: the files stay in their folder under their own names, and anyone who opens the file explorer sees them.';

  @override
  String get nsfwNotConfiguredNote =>
      'There is no password yet. Without one nothing can be marked, and what you have now is shown as always.';

  @override
  String get nsfwConfigureAction => 'Set a password';

  @override
  String get nsfwStateLocked => 'NSFW filter on: marked content is hidden';

  @override
  String get nsfwStateUnlocked => 'NSFW filter off: everything is shown';

  @override
  String get nsfwOpenAction => 'Turn off the NSFW filter';

  @override
  String get nsfwCloseAction => 'Turn the NSFW filter back on';

  @override
  String get nsfwRememberLabel =>
      'Keep the filter off when Fern is opened again';

  @override
  String get nsfwRememberDescription =>
      'Turned off, closing Fern puts the filter back. Turned on it stays as you left it, and the first thing you see on opening is whatever you marked.';

  @override
  String get nsfwChangePasswordAction => 'Change the password';

  @override
  String get nsfwChangeDone =>
      'Password changed. The recovery code is still the same one.';

  @override
  String get nsfwDisableNote =>
      'Turning the filter off for good unmarks every tag and stops hiding anything. Your content is untouched: it was marked, not encrypted.';

  @override
  String get nsfwDisableAction => 'Turn the filter off for good';

  @override
  String nsfwDisableDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filter turned off and $count tags unmarked.',
      one: 'Filter turned off and 1 tag unmarked.',
      zero: 'Filter turned off. No tag was marked.',
    );
    return '$_temp0';
  }

  @override
  String get nsfwSetupTitle => 'Set the password';

  @override
  String get nsfwPasswordLabel => 'Password';

  @override
  String get nsfwPasswordRepeatLabel => 'Repeat it';

  @override
  String get nsfwHintLabel => 'Hint phrase (optional)';

  @override
  String get nsfwHintNote =>
      'It is shown to you after three failed attempts, so it can be read without knowing the password: make it a hint for you, not the password written another way.';

  @override
  String get nsfwSetupAction => 'Save';

  @override
  String get nsfwPasswordEmpty => 'Write a password.';

  @override
  String get nsfwPasswordMismatch => 'The two passwords are not the same.';

  @override
  String get nsfwCodeTitle => 'Your recovery code';

  @override
  String get nsfwCodeIntro =>
      'It is the only thing that lifts the filter if you lose the password, and it is only shown now: Fern does not keep it, it keeps a fingerprint of it. Copy it or save it to a file before closing.';

  @override
  String get nsfwCodeCopy => 'Copy';

  @override
  String get nsfwCodeCopied => 'Copied to the clipboard.';

  @override
  String get nsfwCodeSave => 'Save to a file';

  @override
  String nsfwCodeSaved(String path) {
    return 'Saved in $path';
  }

  @override
  String get nsfwCodeSaveFailed =>
      'The file could not be saved. Copy the code before closing.';

  @override
  String get nsfwCodeDone => 'I have it saved';

  @override
  String get nsfwCodeFileHeader =>
      'Recovery code for Fern’s NSFW content filter. Keep it somewhere you can find it: it is the only thing that lifts the filter if you lose the password.';

  @override
  String get nsfwUnlockTitle => 'Turn off the NSFW filter';

  @override
  String get nsfwUnlockAction => 'Turn it off';

  @override
  String get nsfwUnlockWrong => 'That is not the password.';

  @override
  String nsfwUnlockHint(String hint) {
    return 'Your hint phrase: $hint';
  }

  @override
  String get nsfwUnlockNoHint =>
      'You did not set a hint phrase. If you cannot remember the password, the recovery code is still there.';

  @override
  String get nsfwUnlockRecover => 'Use the recovery code';

  @override
  String get nsfwRecoverTitle => 'Recover access';

  @override
  String get nsfwRecoverIntro =>
      'Write the code you saved and pick a new password. The code is spent once used: you will get another one, and that will be the one that works from now on.';

  @override
  String get nsfwRecoverCodeLabel => 'Recovery code';

  @override
  String get nsfwRecoverAction => 'Recover';

  @override
  String get nsfwRecoverWrong =>
      'That code is not right. Look again: dashes and capitals do not matter.';

  @override
  String get nsfwChangeTitle => 'Change the password';

  @override
  String get nsfwChangeCurrentLabel => 'Current password';

  @override
  String get nsfwChangeNewLabel => 'New password';

  @override
  String get nsfwChangeAction => 'Change it';

  @override
  String get nsfwChangeWrong => 'That is not the current password.';

  @override
  String get nsfwDisableTitle => 'Turn the filter off for good';

  @override
  String get nsfwDisableWarning =>
      'The password is deleted, every tag is unmarked and its content shows up again. Nothing is removed from your library. To have the filter again you would set it up from scratch and mark the tags once more.';

  @override
  String get nsfwDisableSecretLabel => 'Password or recovery code';

  @override
  String get nsfwDisableWrong => 'Neither the password nor the code.';

  @override
  String get nsfwDisableFailed =>
      'The marks could not be removed, so the password has been left as it was. Try again.';

  @override
  String tagNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hides $count items.',
      one: 'Hides 1 item.',
      zero: 'There is no content with this tag right now.',
    );
    return '$_temp0';
  }

  @override
  String get tagNsfwOnTooltip => 'Marked as NSFW · click to unmark';

  @override
  String get tagNsfwOffTooltip => 'Mark as NSFW';

  @override
  String get tagNsfwBadge => 'NSFW tag';

  @override
  String get mediaNsfwMark => 'Mark as NSFW';

  @override
  String get mediaNsfwUnmark => 'Unmark as NSFW';

  @override
  String mediaNsfwMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items marked as NSFW.',
      one: '1 item marked as NSFW.',
      zero: 'Nothing changed.',
    );
    return '$_temp0';
  }

  @override
  String mediaNsfwUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items unmarked.',
      one: '1 item unmarked.',
      zero: 'Nothing changed.',
    );
    return '$_temp0';
  }

  @override
  String get mediaNsfwByTag => 'Marked by one of its tags';

  @override
  String get duplicatesScanSectionTitle => 'Automatic search';

  @override
  String get duplicatesScanSectionNote =>
      'Repeated content is not a nuisance the day it arrives; it is a nuisance months later, when there are forty copies and nobody remembers to look.';

  @override
  String get duplicatesAutoScanLabel => 'Let Fern look for repeats on its own';

  @override
  String get duplicatesAutoScanDescription =>
      'When you open Fern, if the time you pick below has gone by, it goes through the whole library without you asking: it runs in the background at the lowest priority, so it never gets in the way of what you are doing, and it only tells you if it finds something. Turned off, repeats are only looked for when you press “Scan now” in Repeated media.';

  @override
  String get duplicatesScanPeriodLabel => 'How often';

  @override
  String get duplicatesMovingLabel => 'Look at videos and GIFs too';

  @override
  String get duplicatesMovingDescription =>
      'From a video it compares the frame at 10% of its length, not the first one: videos start on black or on a title card, and that alone would group three that have nothing to do with each other. It costs far more than an image, so a library full of videos makes the first scan much longer. Whatever has already been worked out keeps being compared even if you turn this off.';

  @override
  String get duplicatesPeriodMonthly => 'Every month';

  @override
  String get duplicatesPeriodQuarterly => 'Every three months';

  @override
  String get duplicatesPeriodBiannual => 'Every six months';

  @override
  String get duplicatesPeriodYearly => 'Every year';

  @override
  String duplicatesLastScan(String date) {
    return 'Last scan: $date';
  }

  @override
  String get duplicatesLastScanNever => 'Never scanned yet';

  @override
  String get duplicatesOpenViewer => 'Open full screen';

  @override
  String get duplicatesThresholdSectionTitle => 'Similarity bar';

  @override
  String get duplicatesThresholdSectionNote =>
      'How different two contents may be and still count as the same one. Raising it groups more and starts joining things that merely look alike; lowering it leaves repeats unfound. It applies to the next scan, not to what has already been grouped.';

  @override
  String get duplicatesThresholdLabel => 'Bar';

  @override
  String get duplicatesRehashSectionTitle => 'Start over';

  @override
  String get duplicatesRehashSectionNote =>
      'Throws away every fingerprint and works them out again on the next scan. The way out when grouping goes wrong and there is no telling why. Groups you already answered are kept.';

  @override
  String get duplicatesRehashButton => 'Recalculate every fingerprint';

  @override
  String get duplicatesRehashRunning => 'Clearing fingerprints';

  @override
  String duplicatesRehashDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fingerprints cleared. They will be worked out again on the next scan.',
      one:
          '1 fingerprint cleared. It will be worked out again on the next scan.',
      zero: 'There was nothing to clear',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesRehashFailed => 'The fingerprints could not be cleared.';
}
