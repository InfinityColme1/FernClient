
import 'package:flutter/material.dart';

class AppIcons {
  static const Map<String, IconData> _icons = {
    "media": Icons.image,
    "import":  Icons.save_alt,
    "favorites": Icons.favorite_border,
    "collections": Icons.folder_open,
    "deleted":  Icons.delete_outline
  };

  static IconData getIcon(String name) {
    final key = name.toLowerCase().trim();
    return _icons[key] ?? Icons.question_mark;
  }
}