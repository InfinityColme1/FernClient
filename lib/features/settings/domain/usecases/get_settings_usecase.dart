import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

/// Ajustes actuales.
///
/// No extiende [UseCase] porque la lectura es síncrona: los ajustes están en
/// memoria y quien los pide (la pantalla de ajustes, el organizador de
/// ficheros, el almacén de avatares) los necesita sin esperar.
class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  AppSettingsEntity call() => _repository.getSettings();
}
