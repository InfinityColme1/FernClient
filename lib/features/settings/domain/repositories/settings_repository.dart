import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';

/// Ajustes de la aplicación.
///
/// La lectura es síncrona a propósito: los ajustes se consultan en cada
/// importación y en cada avatar que se guarda, así que viven cargados en
/// memoria y sólo la escritura toca el almacenamiento.
abstract class SettingsRepository {
  AppSettingsEntity getSettings();

  Future<void> saveSettings(AppSettingsEntity settings);
}
