import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';

/// Los ajustes que hace falta que existan para montar el repositorio.
///
/// Solo dos rutas: el resto de los ajustes no los toca nada de lo que se mide
/// contra la base de datos, y pedirlos seria inventarse valores que nadie lee.
class SettingsStub implements SettingsRepository {
  final String avatarsPath;

  SettingsStub({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: avatarsPath,
        recognitionPath: 'reconocimiento',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
