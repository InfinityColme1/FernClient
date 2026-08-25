import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Las secciones de la pantalla de ajustes, en el orden en el que se listan.
enum SettingsSection {
  language(icon: Icons.language),
  appearance(icon: Icons.palette_outlined),
  viewer(icon: Icons.slideshow_outlined),
  files(icon: Icons.folder_outlined),
  remoteSources(icon: Icons.cloud_download_outlined),
  recognition(icon: Icons.center_focus_strong_outlined),
  duplicates(icon: Icons.copy_all_outlined),
  nsfw(icon: Icons.lock_outline),
  notifications(icon: Icons.notifications_none),

  /// Experimental: los ajustes del navegador de dentro de la aplicación.
  browser(icon: Icons.travel_explore_outlined),

  /// La última, y a propósito: es la única sección que no cambia cómo se
  /// comporta la aplicación sino que destruye algo.
  database(icon: Icons.storage_outlined);

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
        SettingsSection.database => texts.settingsDatabase,
      };
}
