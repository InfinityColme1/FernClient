import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// Cursor de todo lo pulsable: mano cuando está activo y flecha normal
  /// cuando está deshabilitado.
  static const _clickable = WidgetStateMouseCursor.clickable;

  static final lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    secondaryHeaderColor: AppColors.secondary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    fontFamily: 'Google Sans Flex',
    
    searchBarTheme: SearchBarThemeData(
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(AppColors.secondary),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(color: AppColors.black, fontSize: 14)
      ),
      hintStyle: WidgetStateProperty.all(
        const TextStyle(color: AppColors.lightgray, fontSize: 14)
      ),
    ),

    searchViewTheme: const SearchViewThemeData(
      elevation: 0,
      backgroundColor: AppColors.background,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
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
      style: const ButtonStyle(mouseCursor: _clickable),
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

    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(mouseCursor: _clickable),
    ),

    menuButtonTheme: const MenuButtonThemeData(
      style: ButtonStyle(mouseCursor: _clickable),
    ),

    tabBarTheme: const TabBarThemeData(mouseCursor: _clickable),

    // El lavanda de la aplicación no se ve sobre el fondo claro, así que las
    // esperas se pintan con el rosa, que es el color con el que la aplicación
    // llama la atención. Sin surco: sólo gira el trazo.
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.terciary,
      circularTrackColor: Colors.transparent,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.lightgray,
      thickness: 1,
      space: AppSpacing.l,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        color: AppColors.black,
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      toolbarHeight: 80,
      iconTheme: IconThemeData(color: AppColors.black),
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: AppColors.lightgray, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      border: UnderlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightgray),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightgray),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: AppColors.black, width: 2),
      ),
    ),
  );
}
