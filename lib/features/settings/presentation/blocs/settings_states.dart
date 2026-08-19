import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:equatable/equatable.dart';

/// Cómo ha acabado la última migración.
enum SettingsStatus {
  avatarsMigrated,
  avatarsFailed,
  filesOrganized,
  filesFailed,
  recognitionMigrated,
  recognitionFailed,
}

/// Resultado de la última migración: qué se hizo y sobre cuántos ficheros.
///
/// Se guarda así, en datos, y no como una frase ya montada: el texto lo pone la
/// pantalla con el idioma que esté puesto, y cambiar de idioma vuelve a
/// traducirlo sin tener que repetir la migración.
class SettingsResult extends Equatable {
  final SettingsStatus status;
  final int count;

  const SettingsResult(this.status, {this.count = 0});

  @override
  List<Object?> get props => [status, count];
}

/// Estado de la pantalla de ajustes.
///
/// No hay estado de carga inicial: los ajustes se leen de memoria, así que el
/// bloc nace con ellos puestos. [isWorking] sólo cubre lo que sí tarda, que es
/// mover ficheros por el disco.
class SettingsState extends Equatable {
  final AppSettingsEntity settings;

  /// Hay una migración en marcha (biblioteca o avatares).
  final bool isWorking;

  /// Resultado de la última migración, para enseñarlo junto al botón.
  final SettingsResult? lastResult;

  const SettingsState({
    required this.settings,
    this.isWorking = false,
    this.lastResult,
  });

  /// [lastResult] no se arrastra: cualquier cambio posterior deja obsoleto el
  /// resultado de la migración anterior, así que se limpia salvo que se pase
  /// uno nuevo.
  SettingsState copyWith({
    AppSettingsEntity? settings,
    bool? isWorking,
    SettingsResult? lastResult,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isWorking: isWorking ?? this.isWorking,
      lastResult: lastResult,
    );
  }

  @override
  List<Object?> get props => [settings, isWorking, lastResult];
}
