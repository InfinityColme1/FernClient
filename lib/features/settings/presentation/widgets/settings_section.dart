import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Las secciones de la pantalla de ajustes, en el orden en el que se listan.
///
/// El orden va de lo que se toca el primer día a lo que no se toca casi nunca, y
/// **en cuatro bloques**: cómo se ve y cómo se comporta la aplicación conmigo;
/// dónde vive el contenido y por dónde entra; lo que la aplicación hace sola con
/// él; y lo que casi nunca se abre —la ayuda y lo que destruye—.
///
/// Estaba mezclado: los avisos caían detrás del bloqueo de contenido y el
/// navegador —que es por donde entra contenido— detrás de los avisos, así que
/// para tocar dos cosas de la misma familia había que cruzar la lista entera.
enum SettingsSection {
  // Cómo se ve y cómo se comporta esto conmigo.
  language(icon: Symbols.language),
  appearance(icon: Symbols.palette),
  viewer(icon: Symbols.slideshow),
  notifications(icon: Symbols.notifications_none),

  // Dónde vive el contenido y por dónde entra.
  files(icon: Symbols.folder),
  remoteSources(icon: Symbols.cloud_download),

  /// Experimental: los ajustes del navegador de dentro de la aplicación.
  ///
  /// Va con las fuentes porque es una más: el navegador está para traerse
  /// contenido de sitios que no tienen fuente propia.
  browser(icon: Symbols.travel_explore),

  // Lo que la aplicación hace sola con lo que ya tiene.
  recognition(icon: Symbols.center_focus_strong),
  duplicates(icon: Symbols.copy_all),
  nsfw(icon: Symbols.lock),

  /// La ayuda: desde aquí se vuelve a ver el tutorial.
  help(icon: Symbols.help),

  /// La última, y a propósito: es la única sección que no cambia cómo se
  /// comporta la aplicación sino que destruye algo.
  database(icon: Symbols.storage);

  const SettingsSection({required this.icon});

  final IconData icon;

  String title(AppLocalizations texts) => switch (this) {
        SettingsSection.language => texts.settingsLanguage,
        SettingsSection.appearance => texts.settingsAppearance,
        SettingsSection.viewer => texts.settingsViewer,
        SettingsSection.files => texts.settingsFiles,
        SettingsSection.remoteSources => texts.settingsRemoteSources,
        SettingsSection.recognition => texts.settingsRecognition,
        SettingsSection.duplicates => texts.settingsDuplicates,
        SettingsSection.nsfw => texts.settingsNsfw,
        SettingsSection.notifications => texts.settingsNotifications,
        SettingsSection.browser => texts.settingsBrowser,
        SettingsSection.help => texts.settingsHelp,
        SettingsSection.database => texts.settingsDatabase,
      };
}
