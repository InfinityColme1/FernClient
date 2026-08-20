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
}
