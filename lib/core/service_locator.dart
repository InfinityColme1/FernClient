import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/repositories/remote_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/data/services/external_media_resolver.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/migrate_avatars_usecase.dart';
import 'package:Fern/features/media/domain/usecases/organize_library_files_usecase.dart';
import 'package:Fern/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/confirm_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_list_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_missing_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_favorite_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/get_last_import_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_tree_usecase.dart';
import 'package:Fern/features/media/domain/usecases/mark_media_deleted_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_tag_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/restore_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_suggestion_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_suggestions_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/media/data/datasources/app_database.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  getIt.registerLazySingleton<PreferencesService>(() =>
      PreferencesService(getIt<SharedPreferences>())
  );

  // Ajustes. La carpeta por defecto de los avatares cuelga del directorio de
  // datos de la aplicación y se resuelve aquí, que es el único sitio donde se
  // puede esperar a que `path_provider` responda: a partir de este punto los
  // ajustes se leen sin esperas.
  final documentsDirectory = await getApplicationDocumentsDirectory();
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
        preferences: getIt<SharedPreferences>(),
        defaultAvatarsPath:
            p.join(documentsDirectory.path, appName, avatarsFolderName),
      ));

  getIt.registerSingleton<GetSettingsUseCase>(
    GetSettingsUseCase(getIt())
  );

  getIt.registerSingleton<SaveSettingsUseCase>(
    SaveSettingsUseCase(getIt())
  );

  getIt.registerLazySingleton<AvatarStorageService>(() =>
      AvatarStorageService(settingsRepository: getIt())
  );

  getIt.registerLazySingleton<MediaFileOrganizer>(() =>
      MediaFileOrganizer(settingsRepository: getIt())
  );

  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<Isar>(await getIt<AppDatabase>().getIsar());

  // Por aquí entra todo el contenido nuevo, venga del disco o de una API.
  getIt.registerLazySingleton<MediaRegistry>(() =>
      MediaRegistry(database: getIt<Isar>())
  );

  getIt.registerLazySingleton<LocalMediaRepository>(() =>
      LocalMediaRepositoryImpl(
        appDatabase: getIt<Isar>(),
        fileOrganizer: getIt(),
        avatarStorage: getIt(),
        registry: getIt(),
      )
  );

  // Fuentes remotas. La carpeta de descargas cuelga del directorio de datos de
  // la aplicación, igual que la de los avatares: es de donde salen los ficheros
  // hasta que la gestión de archivos los coloca en la biblioteca.
  getIt.registerLazySingleton<RedditApiClient>(() => RedditApiClient());

  getIt.registerLazySingleton<ExternalMediaResolver>(() =>
      ExternalMediaResolver()
  );

  getIt.registerLazySingleton<RemoteMediaDownloader>(() =>
      RemoteMediaDownloader(
        downloadsPath:
            p.join(documentsDirectory.path, appName, remoteDownloadsFolderName),
        resolver: getIt(),
      )
  );

  getIt.registerLazySingleton<RemoteMediaRepository>(() =>
      RemoteMediaRepositoryImpl(
        reddit: getIt(),
        downloader: getIt(),
        registry: getIt(),
        settingsRepository: getIt(),
        preferencesService: getIt(),
      )
  );

  getIt.registerSingleton<SelectAndScanDirectoryUsecase>(
    SelectAndScanDirectoryUsecase(
        preferencesService: getIt(), 
        localMediaRepository: getIt()
    )
  );

  getIt.registerSingleton<ScanSourceUseCase>(
    ScanSourceUseCase(
        localMediaRepository: getIt(),
        remoteMediaRepository: getIt(),
        preferencesService: getIt()
    )
  );

  getIt.registerSingleton<GetScannedMediaUseCase>(
    GetScannedMediaUseCase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<GetLastImportUseCase>(
    GetLastImportUseCase(getIt())
  );
  
  getIt.registerSingleton<GetMediaListUsercase>(
    GetMediaListUsercase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<GetDeletedMediaUseCase>(
    GetDeletedMediaUseCase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<GetFavoriteMediaUseCase>(
    GetFavoriteMediaUseCase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<SetMediaFavoriteUseCase>(
    SetMediaFavoriteUseCase(getIt())
  );

  getIt.registerSingleton<GetMediaDetailsUsecase>(
    GetMediaDetailsUsecase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<SaveMediaUseCase>(
    SaveMediaUseCase(getIt())
  );

  getIt.registerSingleton<DeleteMissingMediaUseCase>(
    DeleteMissingMediaUseCase(getIt())
  );

  getIt.registerSingleton<DeleteMediaListUseCase>(
    DeleteMediaListUseCase(getIt())
  );

  getIt.registerSingleton<MarkMediaDeletedUseCase>(
    MarkMediaDeletedUseCase(getIt())
  );

  getIt.registerSingleton<RestoreMediaUseCase>(
    RestoreMediaUseCase(getIt())
  );

  getIt.registerSingleton<PurgeDeletedMediaUseCase>(
    PurgeDeletedMediaUseCase(getIt())
  );

  getIt.registerSingleton<PurgeExpiredDeletedMediaUseCase>(
    PurgeExpiredDeletedMediaUseCase(getIt())
  );

  getIt.registerSingleton<ConfirmMediaListUseCase>(
    ConfirmMediaListUseCase(getIt())
  );

  getIt.registerSingleton<SaveTagUseCase>(
    SaveTagUseCase(getIt())
  );

  getIt.registerSingleton<UpdateTagUseCase>(
    UpdateTagUseCase(getIt())
  );

  getIt.registerSingleton<DeleteTagUseCase>(
    DeleteTagUseCase(getIt())
  );

  getIt.registerSingleton<GetMediaByTagUseCase>(
    GetMediaByTagUseCase(getIt())
  );

  getIt.registerSingleton<RemoveTagFromMediaUseCase>(
    RemoveTagFromMediaUseCase(getIt())
  );

  getIt.registerSingleton<SaveCreatorUseCase>(
    SaveCreatorUseCase(getIt())
  );

  getIt.registerSingleton<SearchTagsUseCase>(
    SearchTagsUseCase(getIt())
  );

  getIt.registerSingleton<GetTagTreeUseCase>(
    GetTagTreeUseCase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<SearchCreatorsUseCase>(
    SearchCreatorsUseCase(getIt())
  );

  getIt.registerSingleton<SearchSuggestionsUseCase>(
    SearchSuggestionsUseCase(getIt())
  );

  getIt.registerSingleton<SearchMediaUseCase>(
    SearchMediaUseCase(getIt())
  );

  getIt.registerSingleton<SearchMediaBySuggestionUseCase>(
    SearchMediaBySuggestionUseCase(getIt())
  );

  getIt.registerSingleton<OrganizeLibraryFilesUseCase>(
    OrganizeLibraryFilesUseCase(getIt())
  );

  getIt.registerSingleton<MigrateAvatarsUseCase>(
    MigrateAvatarsUseCase(getIt())
  );

  // Único: el idioma vive aquí y lo escucha `MaterialApp` desde la raíz, así
  // que no puede morir con el diálogo de ajustes.
  getIt.registerLazySingleton<SettingsBloc>(() => SettingsBloc(
        getSettings: getIt(),
        saveSettings: getIt(),
        migrateAvatars: getIt(),
        organizeLibraryFiles: getIt(),
      ));

  // Único por el mismo motivo que el de ajustes: las etiquetas se listan en el
  // menú lateral, que está en el marco de la aplicación y no en una pantalla.
  getIt.registerSingleton<TagsBloc>(
      TagsBloc(getTagTree: getIt())
  );

  getIt.registerSingleton<MediaBloc>(
      MediaBloc(
        getScannedMediaUseCase: getIt(),
        getLastImportUseCase: getIt(),
        scanSourceUseCase: getIt(),
        selectAndScanDirectoryUsecase: getIt(),
        getMediaDetailsUsecase: getIt(),
        saveMediaUseCase: getIt(),
        deleteMissingMediaUseCase: getIt(),
        deleteMediaListUseCase: getIt(),
        markMediaDeletedUseCase: getIt(),
        restoreMediaUseCase: getIt(),
        purgeDeletedMediaUseCase: getIt(),
        purgeExpiredDeletedMediaUseCase: getIt(),
        confirmMediaListUseCase: getIt(),
        getMediaListUsecase: getIt(),
        getDeletedMediaUseCase: getIt(),
        getFavoriteMediaUseCase: getIt(),
        getMediaByTagUseCase: getIt(),
        removeTagFromMediaUseCase: getIt(),
        setMediaFavoriteUseCase: getIt(),
        searchMediaUseCase: getIt(),
        searchMediaBySuggestionUseCase: getIt(),
      )
  );
}
