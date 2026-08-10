import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/repositories/local_media_repository_impl.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/delete_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_details_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/get_scanned_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_media_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/scan_directory_usecase.dart';
import 'package:Fern/features/media/domain/usecases/select_scan_directory_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
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

  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<Isar>(await getIt<AppDatabase>().getIsar());

  getIt.registerLazySingleton<LocalMediaRepository>(() =>
      LocalMediaRepositoryImpl(appDatabase: getIt<Isar>())
  );

  getIt.registerSingleton<SelectAndScanDirectoryUsecase>(
    SelectAndScanDirectoryUsecase(
        preferencesService: getIt(), 
        localMediaRepository: getIt()
    )
  );

  getIt.registerSingleton<ScanDirectoryUseCase>(
    ScanDirectoryUseCase(
        localMediaRepository: getIt(),
        preferencesService: getIt()
    )
  );

  getIt.registerSingleton<GetScannedMediaUseCase>(
    GetScannedMediaUseCase(localMediaRepository: getIt())
  );
  
  getIt.registerSingleton<GetMediaListUsercase>(
    GetMediaListUsercase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<GetMediaDetailsUsecase>(
    GetMediaDetailsUsecase(localMediaRepository: getIt())
  );

  getIt.registerSingleton<SaveMediaUseCase>(
    SaveMediaUseCase(getIt())
  );

  getIt.registerSingleton<DeleteMediaUseCase>(
    DeleteMediaUseCase(getIt())
  );

  getIt.registerSingleton<SaveTagUseCase>(
    SaveTagUseCase(getIt())
  );

  getIt.registerSingleton<SaveCreatorUseCase>(
    SaveCreatorUseCase(getIt())
  );

  getIt.registerSingleton<SearchTagsUseCase>(
    SearchTagsUseCase(getIt())
  );

  getIt.registerSingleton<SearchCreatorsUseCase>(
    SearchCreatorsUseCase(getIt())
  );

  getIt.registerSingleton<MediaBloc>(
      MediaBloc(
        getScannedMediaUseCase: getIt(),
        scanDirectoryUseCase: getIt(),
        selectAndScanDirectoryUsecase: getIt(),
        getMediaDetailsUsecase: getIt(),
        saveMediaUseCase: getIt(),
        deleteMediaUseCase: getIt(),
      )
  );
}
