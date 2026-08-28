// El mando que decide con cuánta seguridad propone un modelo.
//
// Existía en el modelo desde el principio y no se podía tocar desde ninguna
// parte: con el listón clavado en el 35 %, un modelo que veía una figura al 27 %
// no proponía nada y la aplicación decía «no ha detectado nada». Cierto, inútil,
// y sin manera de arreglarlo.
//
// Lo que se comprueba: que se ve lo que vale, que se puede llegar hasta «todo lo
// que vea», y que no se puede pasar de ahí ni por arriba ni por abajo. Los dos
// topes importan: por debajo del suelo no se le ha preguntado al motor, así que
// el mando no cambiaría nada; y un listón del cien por cien es apagar el modelo.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/recognition_panel.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

RecognitionModelEntity _model(double threshold) => RecognitionModelEntity(
      id: 1,
      name: 'Figuras',
      confidenceThreshold: threshold,
      createdAt: DateTime(2026),
    );

void main() {
  late List<RecognitionModelEntity> saved;

  setUp(() => saved = []);

  Future<void> pump(WidgetTester tester, double threshold) {
    return tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('es')],
      locale: const Locale('es'),
      home: Scaffold(
        body: SizedBox(
          width: 700,
          child: RecognitionPanel(
            model: _model(threshold),
            onChanged: saved.add,
          ),
        ),
      ),
    ));
  }

  group('lo que se lee', () {
    testWidgets('el listón sale en tanto por ciento', (tester) async {
      await pump(tester, 0.35);

      expect(find.text('35 %'), findsOneWidget);
    });

    testWidgets('en el mínimo se dice con palabras, no con el número',
        (tester) async {
      await pump(tester, recognitionFloor);

      // «5 %» no le dice a nadie que eso significa «enséñamelo todo».
      expect(find.text('Todo'), findsOneWidget);
      expect(
        find.text('Se propone todo lo que vea, por poco seguro que esté.'),
        findsOneWidget,
      );
    });

    testWidgets('avisa de que lo ya propuesto no cambia', (tester) async {
      await pump(tester, 0.35);

      // Sin esto, alguien lo baja, vuelve al contenido y cree que el mando no
      // hace nada: las sugerencias guardadas se filtraron con el listón de antes.
      expect(
        find.text(
          'Vale para el próximo reconocimiento. Lo ya propuesto no cambia.',
        ),
        findsOneWidget,
      );
    });
  });

  group('moverlo', () {
    testWidgets('bajar resta cinco puntos', (tester) async {
      await pump(tester, 0.35);

      await tester.tap(find.byIcon(Symbols.remove));
      await tester.pump();

      expect(saved.single.confidenceThreshold, closeTo(0.30, 0.0001));
    });

    testWidgets('subir suma cinco puntos', (tester) async {
      await pump(tester, 0.35);

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();

      expect(saved.single.confidenceThreshold, closeTo(0.40, 0.0001));
    });

    testWidgets('se puede llegar hasta el mínimo', (tester) async {
      await pump(tester, recognitionFloor + 0.05);

      await tester.tap(find.byIcon(Symbols.remove));
      await tester.pump();

      expect(saved.single.confidenceThreshold, closeTo(recognitionFloor, 0.0001));
    });
  });

  group('los dos topes', () {
    testWidgets('en el mínimo no se puede bajar más', (tester) async {
      await pump(tester, recognitionFloor);

      // Por debajo del suelo ni se le pregunta al motor: un mando que se mueve
      // sin que cambie nada es peor que uno que se para.
      final button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Symbols.remove),
          matching: find.byType(IconButton),
        ),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('arriba se para antes del cien por cien', (tester) async {
      await pump(tester, 0.95);

      // Un listón que no deja pasar jamás una sugerencia es apagar el modelo.
      final button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Symbols.add),
          matching: find.byType(IconButton),
        ),
      );

      expect(button.onPressed, isNull);
    });
  });
}
