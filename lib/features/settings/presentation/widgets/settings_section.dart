import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Las secciones de la pantalla de ajustes, en el orden en el que se listan.
enum SettingsSection {
  language(icon: Symbols.language),
  appearance(icon: Symbols.palette),
  viewer(icon: Symbols.slideshow),
  files(icon: Symbols.folder),
  remoteSources(icon: Symbols.cloud_download),
  recognition(icon: Symbols.center_focus_strong),
  duplicates(icon: Symbols.copy_all),
  nsfw(icon: Symbols.lock),
  notifications(icon: Symbols.notifications_none),

  /// Experimental: los ajustes del navegador de dentro de la aplicación.
  browser(icon: Symbols.travel_explore),

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
