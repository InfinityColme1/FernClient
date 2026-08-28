// Que los botones se lean, también de noche.
//
// Los de «copiar» y «guardar en un fichero» del código de recuperación estaban
// pintados con el fondo `secondary` y el texto `white`, y en la paleta oscura
// `white` **no es blanco**: es la superficie, casi negra. El resultado era texto
// 0xFF211F26 sobre 0xFF2B2930, que sobre el papel es un contraste de 1,1:1 y en
// pantalla es un botón que no se ve.
//
// Se mide el contraste de verdad en vez de comprobar qué color se pidió: lo que
// importa no es que ponga `black` sino que se lea, y una paleta a medida puede
// romperlo sin que nadie cambie una línea de estos widgets.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recovery_code_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// El contraste entre dos colores, como lo define WCAG.
double _contrast(Color a, Color b) {
  final one = a.computeLuminance();
  final other = b.computeLuminance();
  final lighter = one > other ? one : other;
  final darker = one > other ? other : one;

  return (lighter + 0.05) / (darker + 0.05);
}

/// El mínimo de WCAG para texto grande, que es lo que lleva un botón.
///
/// No se pide el 4,5:1 del texto corrido: estos son rótulos en negrita de
/// dieciséis puntos, y exigirles el listón del texto pequeño dejaría fuera
/// combinaciones que se leen perfectamente.
const _minimumContrast = 3.0;

void main() {
  final palettes = <String, AppPalette>{
    'clara': AppColors.light,
    'oscura': AppColors.dark,
  };

  group('los botones de las superficies se leen', () {
    // Es el par que usan los botones secundarios: los del código de
    // recuperación, el de desbloquear y los de las secciones de ajustes.
    test('texto sobre el fondo secundario', () {
      for (final entry in palettes.entries) {
        final palette = entry.value;

        expect(
          _contrast(palette.black, palette.secondary),
          greaterThanOrEqualTo(_minimumContrast),
          reason: 'en la paleta ${entry.key} no se lee el texto de los botones '
              'secundarios',
        );
      }
    });

    // El que estaba mal, para que quede dicho por qué no se vuelve a él.
    test('y por eso no se pinta con el color de la superficie', () {
      for (final entry in palettes.entries) {
        final palette = entry.value;

        expect(
          _contrast(palette.white, palette.secondary),
          lessThan(_minimumContrast),
          reason: 'en la paleta ${entry.key} `white` sobre `secondary` ya se '
              'lee; si es así, este aviso sobra',
        );
      }
    });
  });

  // Lo anterior mide la paleta; esto comprueba que los botones usan ese par y
  // no otro. Las dos hacen falta: una paleta legible pintada al revés se ve
  // igual de mal.
  group('el diálogo del código de recuperación', () {
    Future<void> pump(WidgetTester tester) async {
      // Ventana holgada a propósito: es donde el diálogo **no** llena la
      // pantalla y puede crecer. Apretado contra los bordes ya no crece —lo que
      // sobra se desplaza dentro— y la prueba no vería el fallo.
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: NsfwRecoveryCodeDialog(code: 'FERN-5QX2-ZM9M-XPBL'),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('sus botones se leen sobre el fondo que llevan',
        (tester) async {
      await pump(tester);

      final texts = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(texts, isNotEmpty);

      for (final button in texts) {
        final style = button.style;
        final foreground = style?.foregroundColor?.resolve({});
        final background = style?.backgroundColor?.resolve({});
        if (foreground == null || background == null) continue;

        expect(
          _contrast(foreground, background),
          greaterThanOrEqualTo(_minimumContrast),
          reason: 'un botón del diálogo no se lee',
        );
      }
    });

    // El mensaje aparece debajo de los botones, pero el diálogo va centrado: al
    // crecer se recoloca entero, y los botones se mueven bajo el ratón justo
    // después de pulsarlos.
    //
    // Se abre por su ruta de verdad y no suelto en un `Scaffold`: puesto a mano
    // ocupa todo el hueco que le den y entonces no crece, con lo que la
    // comprobación pasaría siempre sin comprobar nada. Medido: sin el hueco
    // reservado la tarjeta pasa de 588 a 603 píxeles de alto.
    testWidgets('el mensaje no mueve los botones ni estira el diálogo',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showNsfwRecoveryCode(context, 'FERN-5QX2-ZM9M-XPBL'),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      final card = find
          .descendant(of: find.byType(Dialog), matching: find.byType(Material))
          .first;
      final copy = find.text('Copiar');

      final heightBefore = tester.getSize(card).height;
      final positionBefore = tester.getTopLeft(copy);

      await tester.tap(copy);
      await tester.pumpAndSettle();

      expect(find.text('Copiado al portapapeles.'), findsOneWidget);
      expect(tester.getSize(card).height, heightBefore);
      expect(tester.getTopLeft(copy), positionBefore);

      // Y acotado, porque el otro mensaje que va aquí lleva la ruta del fichero
      // dentro: sin tope se saldría del hueco que se le ha reservado. No se
      // prueba guardando de verdad porque eso abriría el selector de carpetas
      // del sistema, así que se comprueba el tope en sí.
      final message = tester.widget<Text>(find.text('Copiado al portapapeles.'));
      expect(message.maxLines, 2);
      expect(message.overflow, TextOverflow.ellipsis);
    });
  });

  group('el resto de pares que se usan', () {
    test('el botón principal', () {
      for (final entry in palettes.entries) {
        expect(
          _contrast(entry.value.black, entry.value.primary),
          greaterThanOrEqualTo(_minimumContrast),
          reason: 'en la paleta ${entry.key} no se lee el botón principal',
        );
      }
    });

    test('el texto normal sobre el fondo de la aplicación', () {
      for (final entry in palettes.entries) {
        expect(
          _contrast(entry.value.black, entry.value.background),
          greaterThanOrEqualTo(4.5),
          reason: 'en la paleta ${entry.key} no se lee el texto corrido',
        );
      }
    });
  });
}
