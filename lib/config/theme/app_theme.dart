import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// Cursor de todo lo pulsable: mano cuando está activo y flecha normal
  /// cuando está deshabilitado.
  static const _clickable = WidgetStateMouseCursor.clickable;

  static final lightTheme = of(AppColors.light);
  static final darkTheme = of(AppColors.dark);

  /// El tema de la aplicación pintado con [palette].
  ///
  /// Es uno solo para las tres paletas (la clara, la oscura y la del usuario):
  /// lo que cambia entre temas son los colores, no cómo está hecha la
  /// aplicación. La paleta viaja además dentro del tema, que es de donde la
  /// leen las pantallas con `context.colors`.
  static ThemeData of(AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      extensions: [palette],
      primaryColor: palette.primary,
      secondaryHeaderColor: palette.secondary,
      scaffoldBackgroundColor: palette.background,
      brightness: palette.brightness,
      fontFamily: 'Google Sans Flex',

      // Lo que pinta Flutter por su cuenta (los menús del sistema, la selección
      // de texto, los diálogos de fábrica) sale de aquí, así que también tiene
      // que saber de qué color va la aplicación.
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: palette.brightness,
      ).copyWith(
        primary: palette.primary,
        secondary: palette.secondary,
        tertiary: palette.terciary,
        error: palette.error,
        surface: palette.white,
        onSurface: palette.black,
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(palette.secondary),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge)),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(color: palette.black, fontSize: 14)
        ),
        hintStyle: WidgetStateProperty.all(
          TextStyle(color: palette.lightgray, fontSize: 14)
        ),
      ),

      searchViewTheme: SearchViewThemeData(
        elevation: 0,
        backgroundColor: palette.background,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.black,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          ),
          elevation: 0,
        ).copyWith(mouseCursor: _clickable),
      ),

      textButtonTheme: TextButtonThemeData(
        style: const ButtonStyle(mouseCursor: _clickable),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: const ButtonStyle(mouseCursor: _clickable),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: _clickable,
          // Un botón que no se puede pulsar se pinta en gris claro: es lo único
          // que lo distingue de uno que sí, porque no tiene ni fondo ni texto.
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? palette.lightgray
                : palette.black,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: const ButtonStyle(mouseCursor: _clickable),
      ),

      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(mouseCursor: _clickable),
      ),

      listTileTheme: const ListTileThemeData(mouseCursor: _clickable),

      checkboxTheme: const CheckboxThemeData(mouseCursor: _clickable),

      radioTheme: const RadioThemeData(mouseCursor: _clickable),

      switchTheme: const SwitchThemeData(mouseCursor: _clickable),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          mouseCursor: _clickable,
          backgroundColor: WidgetStatePropertyAll(palette.white),
        ),
      ),

      menuButtonTheme: const MenuButtonThemeData(
        style: ButtonStyle(mouseCursor: _clickable),
      ),

      tabBarTheme: const TabBarThemeData(mouseCursor: _clickable),

      // El lavanda de la aplicación no se ve sobre el fondo claro, así que las
      // esperas se pintan con el rosa, que es el color con el que la aplicación
      // llama la atención. Sin surco: sólo gira el trazo.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.terciary,
        circularTrackColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: palette.lightgray,
        thickness: 1,
        space: AppSpacing.l,
      ),

      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: palette.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: palette.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: palette.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: palette.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // El rótulo de una fila del menú lateral. Estaba en uso sin estar
        // definido, así que caía en el estilo de fábrica de Material y se salía
        // de la tipografía de la aplicación.
        labelLarge: TextStyle(
          color: palette.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: palette.black,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        toolbarHeight: 80,
        iconTheme: IconThemeData(color: palette.black),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: palette.lightgray, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.lightgray),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.lightgray),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.black, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.error, width: 2),
        ),
      ),
    );
  }
}
