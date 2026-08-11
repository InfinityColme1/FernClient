import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:equatable/equatable.dart';

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
  final String? statusMessage;

  const SettingsState({
    required this.settings,
    this.isWorking = false,
    this.statusMessage,
  });

  SettingsState copyWith({
    AppSettingsEntity? settings,
    bool? isWorking,
    String? statusMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isWorking: isWorking ?? this.isWorking,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [settings, isWorking, statusMessage];
}
