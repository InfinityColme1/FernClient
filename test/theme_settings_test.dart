// El tema de la aplicación: las paletas de fábrica, la que se monta el usuario
// y cómo llegan a las pantallas.
//
// Lo que se comprueba aquí es lo que no se ve mirando una captura: que los
// colores viajan dentro del tema (y por tanto cambian solos al cambiarlo), que
// un color sin elegir se hereda del lado que toca, y que las filas de color no
// se pueden tocar mientras el tema no sea el del usuario.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/dialogs/fern_color_picker_dialog.dart';
import 'package:Fern/core/ui/inputs/fern_color_field.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:Fern/features/settings/presentation/theme_palette.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [child] con el tema puesto, que es de donde salen los colores.
Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
}

void main() {
  group('las paletas de fábrica', () {
    test('el tema oscuro no es el claro con otros nombres', () {
      expect(AppColors.dark.brightness, Brightness.dark);
      expect(AppColors.light.brightness, Brightness.light);

      // Los papeles se dan la vuelta: lo que se escribe pasa a ser claro y la
      // superficie, oscura.
      expect(
        AppColors.dark.black.computeLuminance(),
        greaterThan(AppColors.light.black.computeLuminance()),
      );
      expect(
        AppColors.dark.white.computeLuminance(),
        lessThan(AppColors.light.white.computeLuminance()),
      );
    });

    test('el velo del contenido oscurece en los dos temas', () {
      // Se pone sobre miniaturas y fotos, no sobre superficies de la
      // aplicación: si en el tema oscuro se aclarase, lo que va encima dejaría
      // de leerse.
      expect(AppColors.light.scrim.computeLuminance(), lessThan(0.1));
      expect(AppColors.dark.scrim.computeLuminance(), lessThan(0.1));
    });
  });

  group('el tema a medida', () {
    test('sin tocar nada es el tema claro', () {
      const empty = CustomThemeEntity();

      expect(empty.isEmpty, isTrue);
      expect(empty.palette.primary, AppColors.light.primary);
      expect(empty.palette.brightness, Brightness.light);
    });

    test('lo que no se elige se hereda del tema claro', () {
      const custom = CustomThemeEntity(primary: 0xFF00FF00);

      expect(custom.palette.primary, const Color(0xFF00FF00));
      expect(custom.palette.gray, AppColors.light.gray);
      expect(custom.palette.lightgray, AppColors.light.lightgray);
    });

    test('con un fondo oscuro se hereda del tema oscuro', () {
      // Es lo que mantiene la aplicación legible cuando sólo se cambia el
      // fondo: los grises de los textos y de los bordes se van con él.
      const custom = CustomThemeEntity(background: 0xFF101010);

      expect(custom.palette.brightness, Brightness.dark);
      expect(custom.palette.black, AppColors.dark.black);
      expect(custom.palette.white, AppColors.dark.white);
    });

    test('la fila de un color sin elegir enseña el que hereda', () {
      const custom = CustomThemeEntity(primary: 0xFF00FF00);

      expect(custom.colorOf(CustomThemeColor.secondary), isNull);
      expect(
        custom.colorOfOrInherited(CustomThemeColor.secondary),
        AppColors.light.secondary,
      );
    });

    test('restablecer un color lo devuelve al de fábrica', () {
      const custom = CustomThemeEntity(primary: 0xFF00FF00);

      final reset = custom.withColor(CustomThemeColor.primary, null);

      expect(reset.colorOf(CustomThemeColor.primary), isNull);
      expect(reset.palette.primary, AppColors.light.primary);
    });
  });

  group('el tema que llega a las pantallas', () {
    test('lleva dentro la paleta con la que se ha pintado', () {
      final theme = AppTheme.of(AppColors.dark);

      expect(theme.extension<AppPalette>(), AppColors.dark);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.dark.background);
    });

    testWidgets('las pantallas lo leen con context.colors', (tester) async {
      late AppPalette read;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.of(AppColors.dark),
        home: Builder(builder: (context) {
          read = context.colors;
          return const SizedBox.shrink();
        }),
      ));

      expect(read, AppColors.dark);
    });
  });

  group('la fila de un color', () {
    testWidgets('desactivada se atenúa y no abre el selector', (tester) async {
      await _pump(
        tester,
        const FernColorField(
          label: 'Primario',
          color: Color(0xFF00FF00),
          isCustom: false,
        ),
      );

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('Primario'),
          matching: find.byType(Opacity),
        ).first,
      );
      expect(opacity.opacity, disabledOptionOpacity);

      await tester.tap(find.text('Primario'));
      await tester.pumpAndSettle();

      expect(find.byType(FernColorPickerDialog), findsNothing);
    });

    testWidgets('activada abre el selector', (tester) async {
      await _pump(
        tester,
        FernColorField(
          label: 'Primario',
          color: const Color(0xFF00FF00),
          isCustom: true,
          onChanged: (_) {},
        ),
      );

      await tester.tap(find.text('Primario'));
      await tester.pumpAndSettle();

      expect(find.byType(FernColorPickerDialog), findsOneWidget);
    });

    testWidgets('enseña el código del color que tiene puesto', (tester) async {
      await _pump(
        tester,
        const FernColorField(
          label: 'Primario',
          color: Color(0xFF1D1B20),
          isCustom: true,
        ),
      );

      expect(find.text('#1D1B20'), findsOneWidget);
    });
  });
}
