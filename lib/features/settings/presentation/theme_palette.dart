import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:flutter/material.dart';

/// De los colores guardados a la paleta con la que se pinta.
///
/// Es el único sitio donde los números que se guardan se vuelven colores: los
/// ajustes no saben de Flutter, y la aplicación no sabe de cómo se guardan.
extension CustomThemePalette on CustomThemeEntity {
  AppPalette get palette => AppColors.custom(
        primary: _asColor(primary),
        secondary: _asColor(secondary),
        terciary: _asColor(terciary),
        error: _asColor(error),
        background: _asColor(background),
        surface: _asColor(surface),
        foreground: _asColor(foreground),
      );

  /// El color que se enseña en la fila de [slot]: el que haya elegido el usuario
  /// o, si no ha tocado ése, el que le toca por herencia.
  ///
  /// Se lee de la paleta ya montada y no del tema de fábrica a secas porque los
  /// colores no se heredan sueltos: elegir un fondo oscuro cambia de qué lado
  /// (claro u oscuro) se hereda todo lo demás.
  Color colorOfOrInherited(CustomThemeColor slot) {
    final palette = this.palette;

    return switch (slot) {
      CustomThemeColor.primary => palette.primary,
      CustomThemeColor.secondary => palette.secondary,
      CustomThemeColor.terciary => palette.terciary,
      CustomThemeColor.error => palette.error,
      CustomThemeColor.background => palette.background,
      CustomThemeColor.surface => palette.white,
      CustomThemeColor.foreground => palette.black,
    };
  }
}

Color? _asColor(int? value) => value == null ? null : Color(value);
