import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';

/// Cómo se cuenta cada resultado de migración en la pantalla.
///
/// El resultado se guarda en datos ([SettingsResult]) y se traduce aquí, así
/// que cambiar de idioma vuelve a escribir el aviso de la última migración sin
/// tener que repetirla. Está en un solo sitio porque hay varias secciones que
/// enseñan resultados y todas tienen que decir lo mismo.
extension SettingsResultLabels on SettingsResult {
  String message(AppLocalizations texts) => switch (status) {
        SettingsStatus.avatarsMigrated => texts.avatarsMoved(count),
        SettingsStatus.avatarsFailed => texts.avatarsMoveFailed,
        SettingsStatus.filesOrganized => texts.filesOrganized(count),
        SettingsStatus.filesFailed => texts.filesOrganizeFailed,
        SettingsStatus.recognitionMigrated =>
          texts.recognitionFolderMoved(count),
        SettingsStatus.recognitionFailed =>
          texts.recognitionFolderMoveFailed,
      };
}

/// A qué sección de los ajustes pertenece cada resultado.
///
/// El estado de la última migración es uno solo y lo comparten todas las
/// secciones, así que cada una tiene que saber cuáles son suyos: sin esto, mover
/// la carpeta de reconocimiento dejaría un aviso colgando en la sección de
/// ficheros.
extension SettingsStatusOwner on SettingsStatus {
  bool get isFiles =>
      this == SettingsStatus.avatarsMigrated ||
      this == SettingsStatus.avatarsFailed ||
      this == SettingsStatus.filesOrganized ||
      this == SettingsStatus.filesFailed;

  bool get isRecognition =>
      this == SettingsStatus.recognitionMigrated ||
      this == SettingsStatus.recognitionFailed;
}
