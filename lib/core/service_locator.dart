import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/import_cancellation.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/schema_migrator.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/features/notifications/data/services/notification_service.dart';
import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:Fern/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/repositories/remote_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_file_organizer.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/data/services/external_media_resolver.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/migrate_avatars_usecase.dart';
import 'package:Fern/features/media/domain/usecases/organize_library_files_usecase.dart';
import 'package:Fern/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/data/services/recognition_storage_service.dart';
import 'package:Fern/features/settings/domain/usecases/migrate_recognition_data_usecase.dart';
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
import 'package:Fern/features/media/domain/usecases/delete_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/delete_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_creator_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_creator_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/creators_bloc.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_deleted_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_favorite_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/get_last_import_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_ancestors_usecase.dart';
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
import 'package:Fern/features/media/domain/usecases/set_media_list_favorite_usecase.dart';
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
  
  getIt.registerLazySingleton<ImportCancellation>(() => ImportCancellation());

  // Los trabajos largos que corren por detrás (entrenar, reconocer, buscar
  // repetidos). Único: el indicador cuelga de la barra superior, que está en el
  // marco de la aplicación y no en una pantalla.
  getIt.registerSingleton<JobQueue>(JobQueue());

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
        defaultRecognitionPath:
            p.join(documentsDirectory.path, appName, recognitionFolderName),
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

  // Los avisos. El sonido va aparte del contador porque son dos cosas que se
  // encienden y se apagan por separado.
  getIt.registerLazySingleton<NotificationSoundService>(() =>
      NotificationSoundService(
        soundsPath: p.join(
          documentsDirectory.path,
          appName,
          notificationSoundsFolderName,
        ),
      )
  );

  getIt.registerLazySingleton<NotificationService>(() => NotificationService(
        preferences: getIt<SharedPreferences>(),
        settingsRepository: getIt(),
        sounds: getIt(),
      ));

  // Todo lo del reconocimiento vive bajo una sola carpeta, y este es el único
  // sitio que sabe cómo se reparte por dentro.
  getIt.registerLazySingleton<RecognitionStorageService>(() =>
      RecognitionStorageService(settingsRepository: getIt())
  );

  getIt.registerSingleton<MigrateRecognitionDataUseCase>(
    MigrateRecognitionDataUseCase(getIt())
  );

  // El motor de reconocimiento. No arranca nada al registrarse: el proceso de
  // Python se lanza la primera vez que hace falta y se cierra solo si nadie lo
  // usa.
  getIt.registerLazySingleton<RecognitionEngine>(() =>
      RecognitionEngine(storage: getIt())
  );

  getIt.registerLazySingleton<MediaFileOrganizer>(() =>
      MediaFileOrganizer(settingsRepository: getIt())
  );

  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<Isar>(await getIt<AppDatabase>().getIsar());

  // La base de datos se pone al día antes de que exista nadie que pueda leerla:
  // un repositorio registrado por encima de esta línea podría encontrarse las
  // filas a medio convertir. Si falla, no se sigue: lo recoge `main` y la
  // aplicación no llega a abrirse.
  getIt.registerLazySingleton<SchemaMigrator>(() =>
      SchemaMigrator(preferences: getIt<SharedPreferences>())
  );
  await getIt<SchemaMigrator>().run(getIt<Isar>());

  // Etiquetar con una etiqueta es etiquetar con toda su rama, y de eso se
  // encarga esto: lo usan por igual el guardado a mano y el automático.
  getIt.registerLazySingleton<TagHierarchy>(() =>
      TagHierarchy(database: getIt<Isar>())
  );

  // Por aquí entra todo el contenido nuevo, venga del disco o de una API.
  getIt.registerLazySingleton<MediaRegistry>(() =>
      MediaRegistry(database: getIt<Isar>(), tagHierarchy: getIt())
  );

  getIt.registerLazySingleton<LocalMediaRepository>(() =>
      LocalMediaRepositoryImpl(
        appDatabase: getIt<Isar>(),
        fileOrganizer: getIt(),
        avatarStorage: getIt(),
        registry: getIt(),
        tagHierarchy: getIt(),
      )
  );

  // Fuentes remotas. La carpeta de descargas cuelga del directorio de datos de
  // la aplicación, igual que la de los avatares: es de donde salen los ficheros
  // hasta que la gestión de archivos los coloca en la biblioteca.
  getIt.registerLazySingleton<RedditApiClient>(() => RedditApiClient());

  getIt.registerLazySingleton<PixivApiClient>(() => PixivApiClient());

  getIt.registerLazySingleton<DanbooruApiClient>(() => DanbooruApiClient());

  getIt.registerLazySingleton<GelbooruApiClient>(() => GelbooruApiClient());

  getIt.registerLazySingleton<PinterestApiClient>(() => PinterestApiClient());

  getIt.registerLazySingleton<PawchiveApiClient>(() => PawchiveApiClient());

  // Por aquí le pregunta al usuario una importación en marcha. Quien contesta
  // lo pone la interfaz al arrancar.
  getIt.registerLazySingleton<ImportDecisions>(() => ImportDecisions());

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
        pixiv: getIt(),
        danbooru: getIt(),
        gelbooru: getIt(),
        pinterest: getIt(),
        pawchive: getIt(),
        decisions: getIt(),
        downloader: getIt(),
        registry: getIt(),
        settingsRepository: getIt(),
        preferencesService: getIt(),
      )
  );

  getIt.registerSingleton<SelectAndScanDirectoryUsecase>(
    SelectAndScanDirectoryUsecase(
        preferencesService: getIt(),
        localMediaRepository: getIt(),
        cancellation: getIt()
    )
  );

  getIt.registerSingleton<ScanSourceUseCase>(
    ScanSourceUseCase(
        localMediaRepository: getIt(),
        remoteMediaRepository: getIt(),
        preferencesService: getIt(),
        cancellation: getIt()
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

  getIt.registerSingleton<SetMediaListFavoriteUseCase>(
    SetMediaListFavoriteUseCase(getIt())
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

  getIt.registerSingleton<SaveTagSourceUrlsUseCase>(
    SaveTagSourceUrlsUseCase(getIt())
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

  getIt.registerSingleton<UpdateCreatorUseCase>(
    UpdateCreatorUseCase(getIt())
  );

  getIt.registerSingleton<SaveCreatorSourceUrlsUseCase>(
    SaveCreatorSourceUrlsUseCase(getIt())
  );

  getIt.registerSingleton<DeleteCreatorUseCase>(
    DeleteCreatorUseCase(getIt())
  );

  getIt.registerSingleton<GetCreatorsUseCase>(
    GetCreatorsUseCase(getIt())
  );

  getIt.registerSingleton<GetMediaByCreatorUseCase>(
    GetMediaByCreatorUseCase(getIt())
  );

  getIt.registerSingleton<RemoveCreatorFromMediaUseCase>(
    RemoveCreatorFromMediaUseCase(getIt())
  );

  getIt.registerSingleton<SearchTagsUseCase>(
    SearchTagsUseCase(getIt())
  );

  getIt.registerSingleton<GetTagAncestorsUseCase>(
    GetTagAncestorsUseCase(getIt())
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
        migrateRecognitionData: getIt(),
      ));

  // Único por el mismo motivo que el de ajustes: los contadores se pintan en el
  // menú lateral, que está en el marco de la aplicación.
  getIt.registerSingleton<NotificationsBloc>(
      NotificationsBloc(service: getIt())
  );

  // Único por el mismo motivo que el de ajustes: el indicador de trabajos vive
  // en la barra superior y tiene que sobrevivir a los cambios de pantalla.
  getIt.registerSingleton<JobsBloc>(
      JobsBloc(queue: getIt())
  );

  // Único por el mismo motivo que el de ajustes: las etiquetas se listan en el
  // menú lateral, que está en el marco de la aplicación y no en una pantalla.
  getIt.registerSingleton<TagsBloc>(
      TagsBloc(getTagTree: getIt())
  );

  // Único como el de etiquetas: la lista de creadores se lee una vez y la
  // pantalla de gestión se la encuentra hecha al volver a ella.
  getIt.registerSingleton<CreatorsBloc>(
      CreatorsBloc(getCreators: getIt())
  );

  getIt.registerSingleton<MediaBloc>(
      MediaBloc(
        cancellation: getIt(),
        decisions: getIt(),
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
        getMediaByCreatorUseCase: getIt(),
        removeCreatorFromMediaUseCase: getIt(),
        setMediaFavoriteUseCase: getIt(),
        setMediaListFavoriteUseCase: getIt(),
        searchMediaUseCase: getIt(),
        searchMediaBySuggestionUseCase: getIt(),
        preferences: getIt(),
        notifications: getIt(),
      )
  );
}
