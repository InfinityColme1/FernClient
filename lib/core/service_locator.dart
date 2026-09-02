import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_controller.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/media_size_store.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/schema_migrator.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/notifications/data/services/notification_service.dart';
import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:Fern/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:Fern/features/recognition/data/repositories/fernie_repository_impl.dart';
import 'package:Fern/features/recognition/data/repositories/model_repository_impl.dart';
import 'package:Fern/features/recognition/data/services/dataset_builder.dart';
import 'package:Fern/features/recognition/data/services/training_job_runner.dart';
import 'package:Fern/features/recognition/data/repositories/model_tree_repository_impl.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/data/repositories/recognition_result_repository_impl.dart';
import 'package:Fern/features/recognition/data/services/media_recognizer.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/accept_suggestions_above_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';
import 'package:Fern/features/duplicates/data/repositories/duplicate_repository_impl.dart';
import 'package:Fern/features/duplicates/data/services/automatic_duplicate_scan.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scan_runner.dart';
import 'package:Fern/features/duplicates/domain/usecases/rehash_library_usecase.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_details_loader.dart';
import 'package:Fern/features/duplicates/domain/usecases/apply_duplicate_group_usecase.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scanner.dart';
import 'package:Fern/features/duplicates/data/services/video_frame_reader.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/recognition/data/services/gif_frame_extractor.dart';
import 'package:Fern/features/recognition/data/services/suggestion_spotlight.dart';
import 'package:Fern/features/recognition/domain/usecases/purge_old_rejections_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/turn_detection_into_region_usecase.dart';
import 'package:Fern/features/recognition/data/services/import_recognition_hook.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_recognizable_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:Fern/features/recognition/data/services/model_files.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/presentation/blocs/model_tree_bloc.dart';
import 'package:Fern/features/recognition/data/services/weights_importer.dart';
import 'package:Fern/features/recognition/domain/usecases/import_model_weights_usecase.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/assign_fernie_to_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/clear_stale_training_flags_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/forget_training_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_models_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/remove_fernie_from_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/save_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_model_split_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_events.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/adopt_fernie_tag_usecase.dart';
import 'package:Fern/features/recognition/data/services/tag_regions_job_runner.dart';
import 'package:Fern/features/recognition/domain/usecases/apply_fernie_link_to_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/add_fernie_regions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/set_fernie_nsfw_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/set_model_nsfw_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_of_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/save_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/search_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
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
import 'package:Fern/features/settings/data/services/database_maintenance_service.dart';
import 'package:Fern/features/settings/data/services/file_deletion_job_runner.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:Fern/features/settings/data/services/leftover_files.dart';
import 'package:Fern/features/settings/domain/usecases/sweep_unused_files_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/wipe_database_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/crop_avatar_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/store_avatar_usecase.dart';
import 'package:Fern/features/media/data/services/import_feed.dart';
import 'package:Fern/features/media/presentation/widgets/viewed_media.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/data/services/import_job_runner.dart';
import 'package:Fern/features/media/data/services/link_import_job_runner.dart';
import 'package:Fern/features/media/data/services/link_reviews_storage.dart';
import 'package:Fern/features/media/data/services/pending_link_reviews.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:Fern/core/services/secret_storage.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/core/utils/grid_layout_cache.dart';
import 'package:Fern/features/media/data/services/library_revision.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/nsfw/data/services/preferences_nsfw_storage.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
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
import 'package:Fern/features/media/domain/usecases/add_tag_to_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_siblings_usecase.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:Fern/features/media/domain/services/recent_picks.dart';
import 'package:Fern/features/media/domain/usecases/set_creator_nsfw_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_tag_nsfw_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remove_creator_from_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_list_creator_usecase.dart';
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
import 'package:Fern/features/media/domain/usecases/get_tag_relatives_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_tag_log_usecase.dart';
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
import 'package:Fern/features/media/domain/usecases/search_media_by_criteria_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_suggestions_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_list_favorite_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_media_nsfw_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_remote_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/remember_media_sizes_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_import_directory_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/creators_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/media/data/datasources/app_database.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  

  // Los trabajos largos que corren por detrás (entrenar, reconocer, buscar
  // repetidos). Único: el indicador cuelga de la barra superior, que está en el
  // marco de la aplicación y no en una pantalla.
  getIt.registerSingleton<JobQueue>(JobQueue());

  getIt.registerLazySingleton<PreferencesService>(() =>
      PreferencesService(getIt<SharedPreferences>())
  );

  // El tutorial. Unico y fuera de las pantallas porque no lo arranca solo el
  // velo que lo pinta: lo arranca la primera vez que se abre la aplicacion, y
  // tambien el boton de los ajustes, que esta en otro sitio del arbol.
  getIt.registerLazySingleton<TutorialController>(
    () => TutorialController(getIt<PreferencesService>()),
  );

  // Ajustes. La carpeta por defecto de los avatares cuelga del directorio de
  // datos de la aplicación y se resuelve aquí, que es el único sitio donde se
  // puede esperar a que `path_provider` responda: a partir de este punto los
  // ajustes se leen sin esperas.
  final documentsDirectory = await getApplicationDocumentsDirectory();
  // Las credenciales de las fuentes remotas van cifradas con DPAPI, atadas a
  // la cuenta de Windows. Hasta ahora estaban en claro en el fichero de
  // preferencias.
  getIt.registerLazySingleton<SecretStorage>(
    () => SecretStorage(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
        preferences: getIt<SharedPreferences>(),
        secrets: getIt<SecretStorage>(),
        defaultAvatarsPath:
            p.join(documentsDirectory.path, appName, avatarsFolderName),
        defaultRecognitionPath:
            p.join(documentsDirectory.path, appName, recognitionFolderName),
      ));

  // Lo que quedara en claro se cifra al arrancar, una vez. Sin pedirle nada al
  // usuario: sus credenciales siguen funcionando y no tiene que volver a
  // escribirlas.
  final migrated =
      await getIt<SecretStorage>().migrate(SettingsRepositoryImpl.secretKeys);
  if (migrated > 0) {
    debugPrint('Credenciales cifradas por primera vez: $migrated');
  }

  getIt.registerSingleton<GetSettingsUseCase>(
    GetSettingsUseCase(getIt())
  );

  getIt.registerSingleton<SaveSettingsUseCase>(
    SaveSettingsUseCase(getIt())
  );

  getIt.registerLazySingleton<AvatarStorageService>(() =>
      AvatarStorageService(settingsRepository: getIt())
  );

  // Y por donde lo piden las pantallas: elegir una imagen es cosa suya, copiarla
  // a la carpeta de avatares no.
  getIt.registerLazySingleton<CropAvatarUseCase>(
    () => CropAvatarUseCase(storage: getIt()),
  );
  getIt.registerLazySingleton<StoreAvatarUseCase>(
    () => StoreAvatarUseCase(storage: getIt()),
  );

  // Vaciar la base de datos entera. Es lo único de la aplicación que destruye
  // sin posibilidad de deshacer, y por eso la pantalla lo pide dos veces.
  getIt.registerLazySingleton<DatabaseMaintenanceService>(
    () => DatabaseMaintenanceService(
      database: getIt<Isar>(),
      preferences: getIt(),
      blocked: getIt(),
      collapsedTags: getIt(),
      media: getIt<LocalMediaRepository>(),
      nsfw: getIt<NsfwIndex>(),
    ),
  );

  // Borrar del disco lo que el vaciado deja huérfano. Va por la cola: son miles
  // de ficheros y minutos de trabajo, y en el diálogo dejaría la ventana
  // bloqueada sin decir por dónde va.
  getIt.registerLazySingleton<FileDeletionJobRunner>(
    () => FileDeletionJobRunner(organizer: getIt<MediaFileOrganizer>()),
  );

  getIt<JobQueue>().register(
    JobType.fileCleanup,
    (context) => getIt<FileDeletionJobRunner>().run(context),
  );

  // Se lleva las copias de avatar que ya no usa nadie. Necesita la base entera:
  // un avatar está en uso si lo apunta cualquiera de las cinco colecciones que
  // tienen imagen, y la que se olvidara perdería sus ficheros.
  getIt.registerLazySingleton<AvatarJanitor>(
    () => AvatarJanitor(database: getIt<Isar>(), storage: getIt()),
  );

  // Los ficheros sueltos de la carpeta de trabajo: avatares sin dueño,
  // descargas cuya fila ya no está y pesos que no apunta ningún modelo. **No**
  // el entorno de Python ni los conjuntos de entrenamiento: lo primero no está
  // en la base de datos y llevárselo rompería el reconocimiento.
  getIt.registerLazySingleton<LeftoverFiles>(
    () => LeftoverFiles(
      database: getIt<Isar>(),
      avatars: getIt<AvatarJanitor>(),
      downloadsPath: () => getIt<RemoteMediaDownloader>().downloadsPath,
      recognitionPath: () =>
          getIt<SettingsRepository>().getSettings().recognitionPath,
    ),
  );

  getIt.registerLazySingleton<SweepUnusedFilesUseCase>(
    () => SweepUnusedFilesUseCase(leftovers: getIt()),
  );

  getIt.registerLazySingleton<WipeDatabaseUseCase>(
    () => WipeDatabaseUseCase(maintenance: getIt(), jobs: getIt<JobQueue>()),
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

  // Lo que el usuario ha dicho que no quiere volver a importar. Se lee entero al
  // arrancar: se pregunta una vez por cada pieza de cada importación, y eso no
  // puede ser una consulta.
  //
  // Aquí arriba y no junto a los casos de uso que lo tocan: el repositorio
  // remoto lo pide al construirse, y como se construye la primera vez que se
  // usa, registrarlo más abajo dejaba el arranque contando con que nadie
  // importara antes de llegar a esa línea. No era así.
  getIt.registerSingleton<BlockedImports>(
    BlockedImports(database: getIt<Isar>()),
  );
  await getIt<BlockedImports>().rebuild();

  // Qué ramas de etiquetas están plegadas. Único y escuchado por las dos listas
  // que pintan el árbol: plegar desde una tiene que verse en la otra.
  getIt.registerSingleton<CollapsedTags>(
    CollapsedTags(preferences: getIt()),
  );

  // Etiquetar con una etiqueta es etiquetar con toda su rama, y de eso se
  // encarga esto: lo usan por igual el guardado a mano y el automático.
  getIt.registerLazySingleton<TagHierarchy>(() =>
      TagHierarchy(database: getIt<Isar>())
  );

  // Por aquí entra todo el contenido nuevo, venga del disco o de una API.
  getIt.registerLazySingleton<MediaRegistry>(() =>
      MediaRegistry(
        database: getIt<Isar>(),
        tagHierarchy: getIt(),
        // Lo que acaba de nacer se manda a reconocer. Se resuelve el enganche
        // aquí dentro y no al montar esto porque el alta se registra mucho
        // antes que el reconocimiento, y pedirlo ahora sería pedirlo demasiado
        // pronto.
        onRegistered: (mediaId) =>
            getIt<ImportRecognitionHook>().mediaArrived(mediaId),
      ));

  // Lo que la rejilla deriva de una lista, guardado entre pantallas: las
  // proporciones, el orden y el reparto en columnas.
  getIt.registerLazySingleton<GridLayoutCache>(() => GridLayoutCache());

  // Por qué versión va la biblioteca. Escucha a Isar, así que se registra con
  // la base ya abierta y antes que quien pregunta.
  getIt.registerLazySingleton<LibraryRevision>(
    () => LibraryRevision(
      database: getIt<Isar>(),
      // Abrir y cerrar el bloqueo no escribe nada y cambia la biblioteca
      // entera: sin esto, volver a ella después de cerrarlo devolvía la
      // guardada, con el contenido escondido todavía dentro.
      visibilityChanges: getIt<NsfwModeService>().changes,
    ),
  );

  // El bloqueo de contenido no apto. Las tres piezas van juntas y en este
  // orden: el índice sabe **qué** está bloqueado, el modo sabe **si** el
  // bloqueo está levantado, y lo que el repositorio pregunta es la suma de las
  // dos.
  getIt.registerLazySingleton<NsfwIndex>(() =>
      NsfwIndex(
        database: getIt<Isar>(),
        hierarchy: getIt(),
        // Se lee al reconstruir, no al montar: el usuario puede cambiarlo desde
        // los ajustes y lo siguiente que se pinte ya sale como toca.
        marksChildren: () =>
            getIt<SettingsRepository>().getSettings().nsfwMarksChildTags,
        hidesTaggedMedia: () =>
            getIt<SettingsRepository>().getSettings().nsfwTagsHideMedia,
        // Marcar una etiqueta o un creador esconde su contenido sin tocar una
        // sola fila de contenido, así que Isar no se entera: se avisa aquí.
        onRebuilt: () => getIt<LibraryRevision>().bump(),
      )
  );

  getIt.registerLazySingleton<NsfwModeService>(() =>
      NsfwModeService(
        storage: PreferencesNsfwStorage(getIt<SharedPreferences>()),
      )
  );

  getIt.registerLazySingleton<NsfwVisibility>(() =>
      NsfwVisibility(
        index: getIt(),
        mode: getIt(),
        // Se leen en el momento de preguntar, no ahora: cambiarlos en los
        // ajustes tiene que notarse en lo siguiente que se pinte, sin reiniciar
        // nada.
        showsOnlyMarked: () =>
            getIt<SettingsRepository>().getSettings().nsfwUnlockedView ==
            NsfwUnlockedView.onlyNsfw,
        covers: () =>
            getIt<SettingsRepository>().getSettings().nsfwLockedView ==
            NsfwLockedView.blurred,
      )
  );

  // Lo bloqueado se resuelve antes de que se pinte nada: arrancar con el índice
  // vacío es arrancar enseñando durante un instante justo lo que hay que
  // esconder, y un instante basta.
  await getIt<NsfwIndex>().rebuild();
  getIt<NsfwModeService>().restore();

  getIt.registerLazySingleton<LocalMediaRepository>(() =>
      LocalMediaRepositoryImpl(
        shuffle: getIt<ShuffleSeed>(),
        appDatabase: getIt<Isar>(),
        fileOrganizer: getIt(),
        avatarStorage: getIt(),
        registry: getIt(),
        tagHierarchy: getIt(),
        visibility: getIt<NsfwVisibility>(),
        // Cualquier cosa que toque etiquetas puede cambiar lo que está
        // bloqueado, así que el índice se rehace desde el propio repositorio y
        // no desde cada pantalla que marque algo.
        onNsfwChanged: getIt<NsfwIndex>().rebuild,
      )
  );

  // Los fernies van en su propio repositorio y no dentro del de contenido: aquél
  // ya mezcla contenido, etiquetas, creadores y búsqueda en más de mil
  // quinientas líneas, y el reconocimiento es un dominio con vida propia.
  getIt.registerLazySingleton<FernieRepository>(() =>
      FernieRepositoryImpl(
        database: getIt<Isar>(),
        avatarStorage: getIt(),
        // Marcar un fernie cambia lo que está escondido, así que el índice se
        // rehace desde aquí y no desde la pantalla que lo marca.
        onNsfwChanged: getIt<NsfwIndex>().rebuild,
      )
  );

  // Los modelos van aparte de los fernies por lo mismo: son otro dominio, con
  // su propia vida (entrenar, guardar pesos, medir) que no tiene nada que ver
  // con marcar regiones.
  getIt.registerLazySingleton<ModelRepository>(
      () => ModelRepositoryImpl(
        database: getIt<Isar>(),
        onNsfwChanged: getIt<NsfwIndex>().rebuild,
      )
  );

  // El que materializa el dataset con el que se entrena. No guarda estado: se
  // le pasa un plan y escribe.
  getIt.registerLazySingleton<DatasetBuilder>(() => DatasetBuilder());

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

  // Una sola baraja para toda la aplicación: la rejilla y el visor tienen
  // que ver el contenido en el mismo orden.
  getIt.registerLazySingleton<ShuffleSeed>(ShuffleSeed.new);

  // Quien sabe de qué pantalla se viene y a cuál se va. Lo leen las dos a
  // la vez mientras dura la transición: ninguna de ellas conoce a la otra.
  getIt.registerLazySingleton<ScreenChoreography>(ScreenChoreography.new);

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
        blocked: getIt(),
      )
  );

  getIt.registerSingleton<SelectImportDirectoryUsecase>(
    SelectImportDirectoryUsecase(preferencesService: getIt())
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

  getIt.registerSingleton<GetRemoteCreatorsUseCase>(
    GetRemoteCreatorsUseCase(remote: getIt(), creators: getIt())
  );

  getIt.registerSingleton<CountRemoteCreatorPostsUseCase>(
    CountRemoteCreatorPostsUseCase(remote: getIt())
  );

  getIt.registerSingleton<RememberMediaSizesUseCase>(
    RememberMediaSizesUseCase(repository: getIt())
  );

  // Y quién escribe lo que la rejilla va descubriendo. El almacén está en
  // `core/` y no sabe de base de datos: se le dice aquí a dónde va lo suyo.
  MediaSizeStore.instance.writer = (sizes) async {
    await getIt<RememberMediaSizesUseCase>()(params: sizes);
  };

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

  getIt.registerSingleton<SetMediaNsfwUseCase>(
    SetMediaNsfwUseCase(getIt<LocalMediaRepository>()),
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

  // Darle a un fernie sin enlace la etiqueta que se llama como el: es lo que
  // hace aceptable su sugerencia, que hasta ahora solo se podia rechazar.
  // Le pone al contenido lo que el fernie enlaza al marcarle una región: decir
  // que ahí sale «Marinette» y no ponerle la etiqueta era dejar el trabajo a
  // medias.
  getIt.registerLazySingleton<ApplyFernieLinkToMediaUseCase>(
    () => ApplyFernieLinkToMediaUseCase(getIt<LocalMediaRepository>()),
  );

  getIt.registerLazySingleton<AdoptFernieTagUseCase>(() =>
    AdoptFernieTagUseCase(
      media: getIt<LocalMediaRepository>(),
      fernies: getIt<FernieRepository>(),
      saveTag: getIt<SaveTagUseCase>(),
    )
  );

  getIt.registerSingleton<SaveTagSourceUrlsUseCase>(
    SaveTagSourceUrlsUseCase(getIt())
  );

  getIt.registerSingleton<DeleteTagUseCase>(
    DeleteTagUseCase(getIt())
  );

  getIt.registerSingleton<RecentPicks>(
    RecentPicks(preferences: getIt(), repository: getIt())
  );

  getIt.registerSingleton<SetCreatorNsfwUseCase>(
    SetCreatorNsfwUseCase(getIt())
  );

  getIt.registerSingleton<SetTagNsfwUseCase>(
    SetTagNsfwUseCase(getIt())
  );

  getIt.registerSingleton<AddTagToMediaUseCase>(
    AddTagToMediaUseCase(getIt())
  );

  getIt.registerSingleton<SaveTagSiblingsUseCase>(
    SaveTagSiblingsUseCase(getIt())
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

  getIt.registerSingleton<GetCreatorUseCase>(
    GetCreatorUseCase(getIt())
  );

  getIt.registerSingleton<SaveCreatorTagsUseCase>(
    SaveCreatorTagsUseCase(getIt())
  );

  getIt.registerSingleton<SetMediaListCreatorUseCase>(
    SetMediaListCreatorUseCase(getIt())
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

  // Los que leen para la interfaz llevan el filtro puesto; los que escriben no
  // lo necesitan, y quien lee para trabajar —entrenar, reconocer— va por el
  // repositorio y ni pasa por aquí.
  getIt.registerSingleton<GetModelsUseCase>(
    GetModelsUseCase(getIt(), visibility: getIt<NsfwVisibility>()),
  );
  getIt.registerSingleton<GetModelUseCase>(
    GetModelUseCase(getIt(), visibility: getIt<NsfwVisibility>()),
  );
  getIt.registerSingleton<SaveModelUseCase>(SaveModelUseCase(getIt()));
  getIt.registerSingleton<SetModelNsfwUseCase>(SetModelNsfwUseCase(getIt()));
  // Borrar un modelo se lleva también lo que dejó en disco: los pesos, la
  // carpeta de la run y el dataset temporal si se quedó a medias. Los fernies no
  // se tocan, que son suyos y no del modelo.
  // El árbol que decide en qué orden se ejecutan los modelos. Único como el
  // bloc de modelos: la pantalla se encuentra el árbol hecho al volver a ella.
  getIt.registerLazySingleton<ModelTreeRepository>(
    () => ModelTreeRepositoryImpl(database: getIt(), models: getIt()),
  );

  // Perezoso a propósito: pide un caso de uso de fernies que se registra más
  // abajo, y uno impaciente lo resolvería antes de que exista. Se monta la
  // primera vez que se abre la pantalla del árbol, que es de sobra.
  getIt.registerLazySingleton<ModelTreeBloc>(
    () => ModelTreeBloc(
      repository: getIt(),
      getModels: getIt(),
      getFernie: getIt(),
      visibility: getIt<NsfwVisibility>(),
    ),
  );

  getIt.registerLazySingleton<ModelFiles>(
    () => ModelFiles(
      root: () async => getIt<SettingsRepository>().getSettings().recognitionPath,
    ),
  );

  // Olvidar lo entrenado sin perder cómo se pidió: hiperparámetros, fernies y
  // reparto se quedan.
  getIt.registerLazySingleton<ForgetTrainingUseCase>(
    () => ForgetTrainingUseCase(models: getIt(), files: getIt()),
  );
  getIt.registerSingleton<DeleteModelUseCase>(
    DeleteModelUseCase(getIt(), getIt()),
  );
  getIt.registerSingleton<GetFerniesOfModelUseCase>(
    GetFerniesOfModelUseCase(getIt(), visibility: getIt<NsfwVisibility>()),
  );
  getIt.registerSingleton<AssignFernieToModelUseCase>(
    AssignFernieToModelUseCase(getIt()),
  );
  getIt.registerSingleton<RemoveFernieFromModelUseCase>(
    RemoveFernieFromModelUseCase(getIt()),
  );
  getIt.registerSingleton<UpdateModelSplitUseCase>(
    UpdateModelSplitUseCase(getIt()),
  );
  getIt.registerSingleton<ClearStaleTrainingFlagsUseCase>(
    ClearStaleTrainingFlagsUseCase(getIt()),
  );

  getIt.registerSingleton<GetFerniesUseCase>(
    GetFerniesUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<GetFernieUseCase>(
    GetFernieUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<SearchFerniesUseCase>(
    SearchFerniesUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<SetFernieNsfwUseCase>(
    SetFernieNsfwUseCase(getIt())
  );

  getIt.registerSingleton<SaveFernieUseCase>(
    SaveFernieUseCase(getIt())
  );

  getIt.registerSingleton<UpdateFernieUseCase>(
    // Con el filtro delante: enlazar un fernie con una etiqueta marcada lo marca
    // a él también, y quien sabe qué etiquetas están marcadas es esto.
    UpdateFernieUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<DeleteFernieUseCase>(
    DeleteFernieUseCase(getIt())
  );

  getIt.registerSingleton<AddFernieRegionsUseCase>(
    AddFernieRegionsUseCase(getIt())
  );

  getIt.registerSingleton<UpdateFernieRegionUseCase>(
    UpdateFernieRegionUseCase(getIt())
  );

  getIt.registerSingleton<DeleteFernieRegionUseCase>(
    DeleteFernieRegionUseCase(getIt())
  );

  getIt.registerSingleton<DeleteRegionsOfMediaUseCase>(
    DeleteRegionsOfMediaUseCase(getIt())
  );

  getIt.registerSingleton<GetRegionsOfMediaUseCase>(
    GetRegionsOfMediaUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<GetFerniesOfMediaUseCase>(
    GetFerniesOfMediaUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<GetMediaOfFernieUseCase>(
    GetMediaOfFernieUseCase(getIt(), visibility: getIt<NsfwVisibility>())
  );

  getIt.registerSingleton<SearchTagsUseCase>(
    SearchTagsUseCase(getIt())
  );

  getIt.registerSingleton<GetTagRelativesUseCase>(
    GetTagRelativesUseCase(getIt())
  );

  // Por qué un contenido tiene lo que tiene puesto. Junta la biblioteca y los
  // fernies, que viven en dos sitios distintos.
  getIt.registerLazySingleton<GetMediaTagLogUseCase>(
    () => GetMediaTagLogUseCase(library: getIt(), fernies: getIt()),
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

  getIt.registerSingleton<SearchMediaByCriteriaUseCase>(
    SearchMediaByCriteriaUseCase(getIt())
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
        // Cambiar si la marca arrastra a las hijas cambia qué está escondido:
        // se rehace el índice y se repinta lo que haya delante, igual que al
        // quitar o poner el filtro.
        onNsfwScopeChanged: () async {
          await getIt<NsfwIndex>().rebuild();

          getIt<TagsBloc>().add(const LoadTagsEvent());
          getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());
        },
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

  // Único como el de etiquetas: los fernies se crean desde el "+" de la barra
  // superior y desde el visor, así que la pantalla de gestión tiene que
  // encontrárselos hechos al volver a ella.
  getIt.registerSingleton<FerniesBloc>(
      FerniesBloc(
        getFernies: getIt(),
        getMediaOfFernie: getIt(),
        deleteRegion: getIt(),
      )
  );

  // Único como el de fernies, y por lo mismo: la rejilla de modelos y el detalle
  // de uno comparten datos, así que crear o borrar en una tiene que verse en la
  // otra sin releer nada a mano.
  getIt.registerSingleton<ModelsBloc>(
      ModelsBloc(
        getModels: getIt(),
        getModel: getIt(),
        deleteModel: getIt(),
        getFernies: getIt(),
        assignFernie: getIt(),
        removeFernie: getIt(),
        updateSplit: getIt(),
      )
  );

  // Quien sabe entrenar. Se registra en la cola, que es la que decide cuándo le
  // toca: entrenar puede durar horas y mientras tanto se sigue usando la
  // aplicación.
  // Los pesos traídos de fuera: el plan B del doc 02 para quien no tenga con
  // qué entrenar aquí.
  getIt.registerLazySingleton<WeightsImporter>(
    () => WeightsImporter(
      models: getIt(),
      inspect: (path) => getIt<RecognitionEngine>().inspect(path),
      root: () async => getIt<SettingsRepository>().getSettings().recognitionPath,
    ),
  );

  getIt.registerLazySingleton<ImportModelWeightsUseCase>(
    () => ImportModelWeightsUseCase(getIt()),
  );

  getIt.registerLazySingleton<TrainingJobRunner>(
    () => TrainingJobRunner(
      models: getIt(),
      datasets: getIt(),
      engine: getIt(),
      root: () async => getIt<SettingsRepository>().getSettings().recognitionPath,
      // Juntar las regiones de todos los fernies de un modelo toca los dos
      // repositorios, así que se arma aquí y el runner no tiene que saber de
      // ninguno.
      regionsOf: (modelId) => _regionsForModel(modelId),
      notifyFinished: () =>
          getIt<NotificationService>().notify(NotificationKind.trainingFinished),
    ),
  );

  getIt<JobQueue>().register(
    JobType.training,
    (context) => getIt<TrainingJobRunner>().run(context),
  );

  // Lo que los modelos proponen sobre un contenido. Vive aparte de las etiquetas
  // del contenido porque una propuesta no es una etiqueta: hasta que el usuario
  // la acepta no toca nada suyo.
  getIt.registerLazySingleton<RecognitionResultRepository>(
    () => RecognitionResultRepositoryImpl(database: getIt()),
  );

  // Perezoso a propósito: el repositorio del que tira se registra unas líneas
  // más abajo, y en ansioso esto reventaría al arrancar.
  getIt.registerLazySingleton<GetMediaSuggestionsUseCase>(
    () => GetMediaSuggestionsUseCase(
      results: getIt(),
      fernies: getIt(),
      library: getIt(),
      visibility: getIt<NsfwVisibility>(),
    ),
  );

  getIt.registerLazySingleton<AnswerSuggestionsUseCase>(
    () => AnswerSuggestionsUseCase(getIt()),
  );

  getIt.registerLazySingleton<AcceptSuggestionsAboveUseCase>(
    () => AcceptSuggestionsAboveUseCase(
      getSuggestions: getIt(),
      answer: getIt(),
      library: getIt(),
    ),
  );

  getIt.registerLazySingleton<CanRecognizeUseCase>(
    () => CanRecognizeUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetRecognizableMediaUseCase>(
    () => GetRecognizableMediaUseCase(getIt()),
  );

  // Por aquí pasan los cuatro puntos de entrada del D16. Uno solo, y no uno por
  // pantalla: la comprobación de si hay con qué reconocer es lo que evita
  // encolar un trabajo que termina en milisegundos sin dejar rastro, y basta
  // que una pantalla se la salte para que el usuario vuelva a encontrarse un
  // botón que no hace nada.
  getIt.registerLazySingleton<RecognitionLauncher>(
    () => RecognitionLauncher(canRecognize: getIt(), jobs: getIt()),
  );

  getIt.registerLazySingleton<SuggestionSpotlight>(() => SuggestionSpotlight());

  getIt.registerLazySingleton<PurgeOldRejectionsUseCase>(
    () => PurgeOldRejectionsUseCase(getIt()),
  );

  getIt.registerLazySingleton<TurnDetectionIntoRegionUseCase>(
    () => TurnDetectionIntoRegionUseCase(getIt()),
  );

  getIt.registerLazySingleton<ImportRecognitionHook>(
    () => ImportRecognitionHook(
      launcher: getIt(),
      // Se lee en cada tanda: entre que llega el primer fichero y sale el
      // trabajo pueden pasar minutos, y lo que vale es lo que el usuario quiere
      // ahora, no lo que quería cuando empezó la importación.
      isEnabled: () =>
          getIt<SettingsRepository>().getSettings().recognizeOnImport,
      // El nombre del trabajo se resuelve con el idioma puesto, que es lo que
      // hay que hacer fuera de la interfaz: aquí no hay ningún `BuildContext`
      // del que sacarlo.
      name: () => lookupAppLocalizations(
        Locale(getIt<SettingsRepository>().getSettings().language.code),
      ).recognizeJobImported,
    ),
  );

  getIt.registerLazySingleton<MediaRecognizer>(
    () => MediaRecognizer(
      models: getIt(),
      // Cuántos fotogramas se miran de un vídeo se resuelve **en cada
      // reconocimiento** y no al montar esto: el usuario puede cambiarlo entre
      // dos trabajos sin reiniciar.
      frameSamples: () =>
          getIt<SettingsRepository>().getSettings().frameSamples,
      predict: _predictWith,
      // Y con qué se pregunta por toda una tanda de golpe, que es lo que hace
      // que reconocer una biblioteca no sean tres peticiones por contenido.
      predictMany: _predictManyWith,
      durationOf: _durationOf,
      // Cuántas veces se guarda lo mismo visto en un contenido. Se lee al
      // reconocer y no al arrancar: cambiarlo en Ajustes vale para el siguiente
      // trabajo, sin reiniciar.
      maxDetections: () =>
          getIt<SettingsRepository>().getSettings().maxDetectionsPerClass,
      extractFrames: _extractFrames,
    ),
  );

  // El parte de lo que hizo cada reconocimiento. En memoria y único: es
  // material de diagnóstico que sólo interesa mientras la pregunta está fresca.
  getIt.registerSingleton<RecognitionLogStore>(RecognitionLogStore());

  // Qué contenidos señalar al llegar a la pantalla del último aviso.
  getIt.registerSingleton<RecognitionHighlight>(RecognitionHighlight());

  // Y a dónde volver al salir del visor.
  getIt.registerSingleton<ViewedMedia>(ViewedMedia());

  getIt.registerLazySingleton<RecognitionJobRunner>(
    () => RecognitionJobRunner(
      tree: getIt(),
      results: getIt(),
      recognizer: getIt(),
      pathOf: _pathOfMedia,
      logs: getIt(),
      returnToReview: () =>
          getIt<SettingsRepository>().getSettings().returnRecognizedToImport,
      notifyFinished: _notifyRecognitionFinished,
    ),
  );

  getIt<JobQueue>().register(
    JobType.recognition,
    (context) => getIt<RecognitionJobRunner>().run(context),
  );

  // Traerse contenido también es un trabajo de fondo: tarda lo que tarde la
  // cuenta que se recorra, y hasta ahora sólo existía mientras se estuviera
  // mirando la pantalla de importación.
  getIt.registerSingleton<ImportFeed>(ImportFeed());

  getIt.registerLazySingleton<ImportJobRunner>(
    () => ImportJobRunner(
      scan: getIt(),
      feed: getIt(),
    ),
  );

  getIt<JobQueue>().register(
    JobType.mediaImport,
    (context) => getIt<ImportJobRunner>().run(context),
  );

  // Las publicaciones con enlaces que esperan a que alguien decida. No son
  // trabajo: son preguntas aparcadas, y por eso su tipo de tarea no se ejecuta
  // nunca.
  getIt.registerLazySingleton<LinkReviewsStorage>(
    () => LinkReviewsStorage(preferences: getIt()),
  );

  getIt.registerLazySingleton<PendingLinkReviews>(
    () => PendingLinkReviews()
      ..persist = (reviews) => getIt<LinkReviewsStorage>().write(reviews),
  );

  // Y lo que quedó sin contestar la última vez vuelve a la lista. Aparcar una
  // pregunta es decir «esto lo miro otro día», y otro día suele ser después de
  // cerrar la aplicación: perderlas al cerrar convertiría aparcar en tirar.
  for (final saved in getIt<LinkReviewsStorage>().read()) {
    final id = getIt<JobQueue>().enqueue(
      type: JobType.linkReview,
      priority: JobPriority.normal,
      payload: {Job.nameKey: saved.postTitle},
    );

    getIt<PendingLinkReviews>().add(LinkReview(
      jobId: id,
      postTitle: saved.postTitle,
      links: saved.links,
      source: saved.source,
      namePrefix: saved.namePrefix,
      sourceUrls: saved.sourceUrls,
    ));
  }

  // Y se van con su tarea: quitarla de la lista es decir que no interesa.
  getIt<JobQueue>().changes.listen((jobs) {
    getIt<PendingLinkReviews>().keepOnly({
      for (final job in jobs)
        if (job.status.isActive) job.id,
    });
  });

  getIt.registerLazySingleton<LinkImportJobRunner>(
    () => LinkImportJobRunner(fetch: _fetchLink),
  );

  getIt<JobQueue>().register(
    JobType.linkImport,
    (context) => getIt<LinkImportJobRunner>().run(context),
  );

  getIt.registerLazySingleton<DuplicateRepository>(
    () => DuplicateRepositoryImpl(
      database: getIt<Isar>(),
      // El mismo filtro que el contenido: un grupo de repetidos que no se puede
      // abrir no se propone.
      visibility: getIt<NsfwVisibility>(),
    ),
  );

  getIt.registerLazySingleton<DuplicateScanner>(
    () => DuplicateScanner(
      // De las imágenes y los GIF, sus propios bytes. De los vídeos, el
      // fotograma del 10 %, que lo saca el servicio de previsualización: es el
      // mismo que llena la rejilla, así que un vídeo que ya se ha visto tiene
      // su fotograma en la caché del disco y no hay que volver a abrirlo.
      read: hashableBytesReader(
        VideoFrameReader(
          duration: (path) async =>
              (await MediaPreviewService.instance.load(path))?.duration,
          frameAt: (path, moment) async =>
              (await MediaPreviewService.instance.loadFrames(path, [moment]))[moment],
        ),
      ),
      write: (mediaId, hashes) =>
          getIt<DuplicateRepository>().saveHashes(mediaId, hashes),
    ),
  );

  getIt.registerLazySingleton<DuplicateScanRunner>(
    () => DuplicateScanRunner(
      repository: getIt(),
      scanner: getIt(),
      // Se lee en cada escaneo: entre uno y otro el usuario puede haber movido
      // el listón desde los ajustes.
      threshold: () => getIt<SettingsRepository>().getSettings().duplicateThreshold,
      // Igual que el listón: se lee al empezar cada escaneo, no al arrancar la
      // aplicación.
      includesMoving: () =>
          getIt<SettingsRepository>().getSettings().duplicateScanIncludesMoving,
      notify: (count) => getIt<NotificationService>().notify(
        NotificationKind.duplicatesFound,
        count: count,
      ),
      // La sella el escaneo al terminar bien, venga del botón o de la
      // aplicación: para decidir cuándo toca el siguiente, los dos son el
      // mismo trabajo.
      stamp: () =>
          getIt<PreferencesService>().setLastDuplicateScan(DateTime.now()),
    ),
  );

  getIt.registerLazySingleton<RehashLibraryUseCase>(
    () => RehashLibraryUseCase(
      getIt<DuplicateRepository>(),
      forgetLastScan: () =>
          getIt<PreferencesService>().clearLastDuplicateScan(),
    ),
  );

  getIt.registerLazySingleton<AutomaticDuplicateScan>(
    () => AutomaticDuplicateScan(
      jobs: getIt<JobQueue>(),
      settings: () => getIt<SettingsRepository>().getSettings(),
      lastScan: () => getIt<PreferencesService>().getLastDuplicateScan(),
    ),
  );

  // Marcar de una vez todo el contenido de una etiqueta como regiones de un
  // fernie. Va por la cola porque saber cuánto dura cada vídeo es abrir su
  // fichero, y con una etiqueta grande eso son minutos.
  getIt.registerLazySingleton<TagRegionsJobRunner>(
    () => TagRegionsJobRunner(
      media: getIt<LocalMediaRepository>(),
      fernies: getIt<FernieRepository>(),
      durationOf: _durationOf,
      onFinished: _notifyTagRegionsFinished,
    ),
  );

  getIt<JobQueue>().register(
    JobType.tagRegions,
    (context) => getIt<TagRegionsJobRunner>().run(context),
  );

  getIt<JobQueue>().register(
    JobType.duplicateScan,
    (context) => getIt<DuplicateScanRunner>().run(context),
  );

  getIt.registerLazySingleton<DuplicateDetailsLoader>(
    () => DuplicateDetailsLoader(
      details: (mediaId) =>
          getIt<GetMediaDetailsUsecase>()(params: mediaId),
    ),
  );

  getIt.registerLazySingleton<ApplyDuplicateGroupUseCase>(
    () => ApplyDuplicateGroupUseCase(
      media: getIt<LocalMediaRepository>(),
      duplicates: getIt<DuplicateRepository>(),
      fernies: getIt<FernieRepository>(),
    ),
  );

  getIt.registerLazySingleton<DismissDuplicateGroupUseCase>(
    () => DismissDuplicateGroupUseCase(getIt<DuplicateRepository>()),
  );

  // Un entrenamiento que se quedó a medias porque el equipo se apagó deja el
  // modelo marcado para siempre, y así no se dejaría entrenar nunca más. Se
  // desatasca al arrancar, antes de que ninguna pantalla lo lea.
  await getIt<ClearStaleTrainingFlagsUseCase>()();

  // Buscar repetidos por cuenta propia, si toca. Va después de registrar la
  // cola y su ejecutor, y no espera a que termine: encolar es decir que hay que
  // hacerlo, y esto corre mientras la aplicación todavía se está montando.
  getIt<AutomaticDuplicateScan>().runIfDue();
  getIt<ModelsBloc>().add(const LoadModelsEvent());

  // Único como el de etiquetas: la lista de creadores se lee una vez y la
  // pantalla de gestión se la encuentra hecha al volver a ella.
  getIt.registerSingleton<CreatorsBloc>(
      CreatorsBloc(getCreators: getIt())
  );

  getIt.registerSingleton<MediaBloc>(
      MediaBloc(
        shuffle: getIt<ShuffleSeed>(),
        decisions: getIt(),
        // Se lee al soltar y no ahora: cambiarlo en los ajustes tiene que
        // notarse en lo siguiente que se suelte, sin reiniciar nada.
        keepsSelectionOnDrop: () =>
            getIt<SettingsRepository>().getSettings().keepsSelectionOnDrop,
        getScannedMediaUseCase: getIt(),
        getLastImportUseCase: getIt(),
        jobs: getIt(),
        importFeed: getIt(),
        selectImportDirectoryUsecase: getIt(),
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
    setMediaNsfwUseCase: getIt(),
    setMediaListCreatorUseCase: getIt(),
    libraryRevision: getIt<LibraryRevision>(),
    rememberedSource: () => getIt<PreferencesService>().getLastImportSource(),
    rememberSource: (source) =>
        getIt<PreferencesService>().setLastImportSource(source),
        addTagToMediaUseCase: getIt(),
        searchMediaByCriteriaUseCase: getIt(),
        blocked: () => getIt<BlockedImports>(),
        preferences: getIt(),
        notifications: getIt(),
      )
  );

  // Abrir o cerrar el bloqueo no cambia el contenido, cambia **qué se puede
  // ver**, así que hay que releer lo que ya estuviera pintado: sin esto, cerrar
  // el modo deja la rejilla enseñando lo que acaba de esconderse hasta que el
  // usuario cambie de pantalla, que es la forma más silenciosa de que falle un
  // bloqueo.
  //
  // Va aquí, al final, porque necesita los dos blocs ya registrados, y sin
  // cancelar la suscripción porque estos tres viven lo que vive la aplicación.
  getIt<NsfwModeService>().changes.listen((_) {
    getIt<TagsBloc>().add(const LoadTagsEvent());
    // Los creadores también se marcan, así que su lista también cambia al abrir
    // y cerrar. Se quedó fuera de aquí cuando no se podían marcar, y el síntoma
    // era que había que salir de la pantalla y volver para verla al día.
    getIt<CreatorsBloc>().add(const LoadCreatorsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());

    // Los fernies y los modelos también: son pantallas que se quedan montadas,
    // y cerrar el filtro sin releerlas las dejaría enseñando lo que acaba de
    // esconderse hasta que el usuario se moviera de sitio.
    getIt<FerniesBloc>().add(const LoadFerniesEvent());
    getIt<ModelsBloc>().add(const LoadModelsEvent());
  });
}

/// Las regiones con las que se entrena un modelo, listas para el dataset.
///
/// Avisa de que hay sugerencias esperando, y **dónde**.
///
/// El aviso lleva a la pantalla en la que están los contenidos, no siempre a la
/// de importación: reconocer contenido ya definitivo terminaba mandando al
/// usuario a un sitio donde no está lo que acaba de reconocer.
///
/// Y deja señalados esos contenidos, para que al llegar se vea cuáles son entre
/// las trescientas miniaturas de la rejilla.
Future<void> _notifyRecognitionFinished(Set<int> mediaIds) async {
  final pending = await _hasPendingReview(mediaIds);
  final route = pending ? importRoute : mediaRoute;

  getIt<RecognitionHighlight>().show(route: route, mediaIds: mediaIds);

  // Cuántos, no cuántas veces. El contador del menú dice lo que hay pendiente
  // de mirar, y lo que hay pendiente son contenidos: un «1» después de
  // reconocer trescientos no invita a ir a verlo.
  await getIt<NotificationService>().notify(
    NotificationKind.recognitionFinished,
    count: mediaIds.length,
    route: route,
  );
}

/// Marcar una etiqueta entera ha terminado: la pantalla de fernies tiene que
/// enseñar lo que se acaba de escribir.
///
/// El trabajo corre en la cola, así que quien lo pidió puede seguir con la ficha
/// del fernie delante. Sin esto, las regiones estaban en la base y no en la
/// rejilla, y había que salir de la pantalla y volver a entrar.
Future<void> _notifyTagRegionsFinished(int fernieId) async {
  final fernies = getIt<FerniesBloc>();

  // La lista, por el recuento de regiones de cada fernie.
  fernies.add(const LoadFerniesEvent());

  // Y la rejilla, sólo si es el fernie que se está mirando: recargarla estando
  // en otro sería leer de más para no enseñar nada.
  if (fernies.state.selectedFernieId == fernieId) {
    fernies.add(const ReloadFernieRegionsEvent());
  }
}

/// Si alguno de estos contenidos está todavía pendiente de revisar.
///
/// Basta uno: un lote mezclado se resuelve en la pantalla de importación, que es
/// donde el usuario tiene que pasar de todas formas.
Future<bool> _hasPendingReview(Set<int> mediaIds) async {
  for (final id in mediaIds) {
    final found = await getIt<GetMediaDetailsUsecase>()(params: id);

    if (found is DataSuccess && found.data?.isImported == false) return true;
  }

  return false;
}

/// Se trae un enlace suelto y lo da de alta bajo la fuente de la que salió.
///
/// Es el mismo camino que lo que trae una publicación —el mismo descargador y el
/// mismo registro—, con la única diferencia de que la decisión de traérselo llega
/// a destiempo: cuando el usuario contesta la tarea que quedó aparcada.
Future<MediaSummaryEntity?> _fetchLink({
  required String url,
  required String name,
  required ImportSource source,
  required String description,
  required List<String> sourceUrls,
  required bool asArchive,
}) async {
  final path = await getIt<RemoteMediaDownloader>().download(
    url: url,
    name: name,
    source: source,
    asArchive: asArchive,
  );
  if (path == null) return null;

  return getIt<MediaRegistry>().register(
    path: path,
    source: source,
    description: description.isEmpty ? null : description,
    sourceUrls: sourceUrls,
  );
}

/// Dónde está guardado un contenido.
Future<String?> _pathOfMedia(int mediaId) async {
  final result = await getIt<GetMediaDetailsUsecase>()(params: mediaId);

  return result is DataSuccess ? result.data?.path : null;
}

/// El descodificador de GIF del reconocimiento, con su caché de uno.
final _gifFrames = GifFrameExtractor();

/// Cuánto dura un contenido, si es de los que duran.
///
/// Un GIF no pasa por el reproductor de vídeo: `GifFrames` lo descodifica en
/// otro hilo y dice su duración de verdad, no la que libmpv deduzca.
Future<Duration?> _durationOf(String path) async {
  if (path.isGifPath) return _gifFrames.durationOf(path);

  final preview = await MediaPreviewService.instance.load(path);

  return preview?.duration;
}

/// Saca los fotogramas que hay que mirar de un vídeo.
///
/// Con el servicio de previsualizaciones, que los pide **de una vez**: abrir el
/// fichero es lo caro —crear el reproductor, esperar a que diga su duración, su
/// tamaño y su primer fotograma—, y hacerlo cinco veces por vídeo era lo que
/// convertía un lote de vídeos en minutos de espera. Además los cachea en
/// disco, así que volver a reconocer el mismo vídeo no lo abre siquiera.
///
/// Los que no se puedan sacar se saltan. Un fotograma perdido es una mirada
/// menos, no un reconocimiento fallido.
Future<List<SampledFrame>> _extractFrames(String path, List<Duration> at) async {
  // El GIF va por su lado: sus fotogramas son los que son, y dos momentos que
  // caigan en el mismo dan una sola mirada. Los momentos que salen son los de
  // inicio de cada fotograma, no los que se pidieron.
  if (path.isGifPath) {
    final frames = await _gifFrames.extract(path, at);
    final moments = frames.keys.toList()..sort();

    return framesInOrder(moments, {
      for (final entry in frames.entries)
        entry.key: SampledFrame(
          path: entry.value,
          frameMs: entry.key.inMilliseconds,
        ),
    });
  }

  final frames = await MediaPreviewService.instance.loadFrames(path, at);

  return framesInOrder(at, {
    for (final entry in frames.entries)
      entry.key: SampledFrame(
        path: entry.value,
        frameMs: entry.key.inMilliseconds,
      ),
  });
}

/// Lo que ve un modelo en una imagen.
///
/// Es la de varias con una sola: la conversion de lo que contesta el sidecar
/// vive en un unico sitio, o las dos acabarian leyendo la caja de forma
/// distinta.
///
/// El liston lo pone quien llama y **no el modelo**. Antes lo ponia el modelo,
/// que ahorraba traer detecciones por el tubo, pero dejaba a la aplicacion sin
/// poder distinguir «no ha visto nada» de «lo vio al 27 % y tu liston esta en el
/// 35 %». Lo primero no se puede arreglar; lo segundo si, y era lo que pasaba de
/// verdad. Lo que sobra son unas pocas cajas por imagen.
Future<List<RawDetection>> _predictWith(
  RecognitionModelEntity model,
  String imagePath,
  double confidence,
) async {
  final byImage = await _predictManyWith(model, [imagePath], confidence, null);

  return byImage.isEmpty ? const [] : byImage.first;
}

/// Lo que ve un modelo en **varias imágenes de una vez**.
///
/// Es la misma petición que la de una imagen —el sidecar siempre recibió una
/// lista— pero con la lista llena. Reconocer una biblioteca con un árbol de tres
/// modelos eran tres peticiones por contenido; así son tres por tanda.
///
/// Contesta **una lista por imagen y en el mismo orden en que se pidieron**. El
/// sidecar devuelve una entrada por imagen, incluidas las que ya no están en su
/// sitio (que vuelven vacías), así que el orden se sostiene; aun así se rellena
/// hasta el número pedido, porque quien lo usa reparte por posición y un hueco
/// le pondría las cajas de un contenido en otro.
Future<List<List<RawDetection>>> _predictManyWith(
  RecognitionModelEntity model,
  List<String> imagePaths,
  double confidence,
  CancellationToken? token,
) async {
  final weights = model.weightsPath;
  if (weights == null) return [for (final _ in imagePaths) const []];

  final result = await getIt<RecognitionEngine>().predict(
    {
      'weights': weights,
      'images': imagePaths,
      'conf': confidence,
      'imgsz': model.imgsz,
    },
    // Para que parar pare de verdad a media tanda: el sidecar mira la señal
    // entre imagen e imagen.
    token: token,
  );

  final images = result['results'];
  if (images is! List) return [for (final _ in imagePaths) const []];

  final byImage = <List<RawDetection>>[];

  for (final image in images) {
    byImage.add(image is Map ? _detectionsOf(image['detections']) : const []);
  }

  while (byImage.length < imagePaths.length) {
    byImage.add(const []);
  }

  return byImage;
}

/// Las cajas de una respuesta del sidecar, ya en el formato de la aplicación.
List<RawDetection> _detectionsOf(Object? found) {
  if (found is! List) return const [];

  final detections = <RawDetection>[];

  for (final one in found) {
    if (one is! Map) continue;

    final classIndex = one['class'];
    final confidence = one['conf'];
    if (classIndex is! int || confidence is! num) continue;

    // La caja llega en el formato de ultralytics —centro y tamaño, ya
    // normalizados— y aquí se guarda con la esquina superior izquierda, que es
    // como están las regiones y como el visor las pinta.
    final box = boxFromCenter(one['box']);

    detections.add(RawDetection(
      classIndex: classIndex,
      confidence: confidence.toDouble(),
      x: box?.x,
      y: box?.y,
      w: box?.w,
      h: box?.h,
    ));
  }

  return detections;
}

/// Junta lo de los dos repositorios: del de modelos salen los fernies y su
/// número de clase, y del de fernies, las regiones de cada uno con el contenido
/// al que pertenecen.
Future<List<DatasetRegion>> _regionsForModel(int modelId) async {
  final assignments = await getIt<ModelRepository>().getFerniesOfModel(modelId);
  if (assignments is! DataSuccess) return const [];

  final regions = <DatasetRegion>[];

  for (final assignment in assignments.data ?? const <ModelFernieEntity>[]) {
    final media =
        await getIt<FernieRepository>().getMediaOfFernie(assignment.fernie.id);
    if (media is! DataSuccess) continue;

    for (final entry in media.data ?? const <FernieRegionMediaEntity>[]) {
      regions.add(DatasetRegion(
        regionId: entry.region.id,
        mediaId: entry.media.id,
        mediaPath: entry.media.path,
        frameMs: entry.region.frameMs,
        x: entry.region.x,
        y: entry.region.y,
        w: entry.region.w,
        h: entry.region.h,
        classIndex: assignment.classIndex,
        // Lo que todavía no es definitivo no entrena (D29): la región viaja con
        // el dato y el planificador la deja fuera.
        isDefinitive: entry.media.isImported,
      ));
    }
  }

  return regions;
}
