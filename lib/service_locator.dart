
import 'package:fernclient/data/repositories/desktop_mediarepo_impl.dart';
import 'package:fernclient/domain/repositories/media_repo.dart';
import 'package:fernclient/domain/usecases/get_media_uc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  sl.registerLazySingleton<MediaRepository>(
    () => DesktopMediaRepoImpl(),
  );

  sl.registerLazySingleton(() => GetMediaItemsUseCase(sl<MediaRepository>()));
  
}