import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

class SaveSettingsUseCase extends UseCase<void, AppSettingsEntity> {
  final SettingsRepository _repository;

  SaveSettingsUseCase(this._repository);

  @override
  Future<void> call({AppSettingsEntity? params}) {
    return _repository.saveSettings(params!);
  }
}
