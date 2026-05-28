
import 'package:fernclient/core/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
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
    )

  );
}