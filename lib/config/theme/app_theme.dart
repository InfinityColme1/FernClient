
import 'package:Fern/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    secondaryHeaderColor: AppColors.secondary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    fontFamily: 'Google Sans Flex',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: TextStyle(fontSize: 16,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22)
        )
      )
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.lightgray
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight(400)
      ),
      bodyMedium: TextStyle(
        color: AppColors.black,
        fontSize: 14,
          fontWeight: FontWeight(300)
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      toolbarHeight: 80,
    ),

    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.secondary),
      elevation: WidgetStateProperty.all(0),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontFamily: 'Google Sans Flex',
          fontSize: 14,
          color: AppColors.black,
          fontWeight: FontWeight(400)
        )
      ),
      constraints: BoxConstraints(
        minWidth: 300,
        maxWidth: 500,
        minHeight: 40,
        maxHeight: 40
      )
    )

  );
}