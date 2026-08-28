// El indicador de espera: cuándo sale y qué tapa.
//
// Son dos cosas distintas y se prueban por separado: la rejilla, que decide entre
// esperar y decir que no hay nada, y el velo (`FernBusyOverlay`), que deja el
// contenido anterior a la vista pero fuera de alcance mientras se espera.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
}

void main() {
  group('la rejilla sin contenido', () {
    testWidgets('espera con el hueco de lo que va a llegar', (tester) async {
      // Y no con un circulo dando vueltas: el hueco dice ademas que viene y
      // cuanto va a ocupar, asi que al llegar el contenido no se recoloca la
      // pantalla entera de golpe.
      await _pump(tester, const MediaGrid(mediaList: [], columns: 4, isLoading: true));
      await tester.pump();

      expect(find.byType(FernSkeletonGrid), findsOneWidget);
      expect(find.byType(FernEmptyState), findsNothing);
    });

    testWidgets('dice que está vacía sólo cuando ya se sabe', (tester) async {
      await _pump(tester, const MediaGrid(mediaList: [], columns: 4));
      await tester.pumpAndSettle();

      expect(find.byType(FernEmptyState), findsOneWidget);
      expect(find.byType(FernSkeletonGrid), findsNothing);
    });
  });

  group('el velo de espera', () {
    testWidgets('sin espera no pinta nada encima', (tester) async {
      await _pump(
        tester,
        const FernBusyOverlay(
          isBusy: false,
          child: SizedBox(width: 300, height: 300, child: Text('contenido')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('contenido'), findsOneWidget);
      expect(find.byType(FernProgressIndicator), findsNothing);
    });

    testWidgets('una espera corta no llega a enseñarse', (tester) async {
      // **Es lo que se veía como un parpadeo.** Escribir una etiqueta y releer la
      // biblioteca se resuelve en unas decenas de milisegundos: un velo que se
      // levanta y cae en ese tiempo no informa de nada, sólo se ve.
      await _pump(
        tester,
        const FernBusyOverlay(
          isBusy: true,
          child: SizedBox(width: 300, height: 300, child: Text('contenido')),
        ),
      );

      // Justo antes de cumplirse el margen: todavía nada.
      await tester.pump(busyOverlayDelay - const Duration(milliseconds: 20));
      expect(find.byType(FernProgressIndicator), findsNothing);

      // Y se acaba antes de llegar: no se ha enseñado en ningún momento.
      await _pump(
        tester,
        const FernBusyOverlay(
          isBusy: false,
          child: SizedBox(width: 300, height: 300, child: Text('contenido')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FernProgressIndicator), findsNothing);
    });

    testWidgets('y una larga sí', (tester) async {
      await _pump(
        tester,
        const FernBusyOverlay(
          isBusy: true,
          child: SizedBox(width: 300, height: 300, child: Text('contenido')),
        ),
      );

      await tester.pump(busyOverlayDelay);
      await tester.pump(busyOverlayFadeDuration);

      expect(find.byType(FernProgressIndicator), findsOneWidget);
    });

    testWidgets('deja ver el contenido anterior pero no pulsarlo',
        (tester) async {
      var taps = 0;

      await _pump(
        tester,
        FernBusyOverlay(
          isBusy: true,
          child: ElevatedButton(
            onPressed: () => taps++,
            child: const Text('guardar'),
          ),
        ),
      );
      // El velo no sale en el acto: una espera corta no llega a enseñarse, que
      // es lo que evita el parpadeo. Se deja pasar el margen y después lo que
      // tarda en aparecer.
      //
      // Y con el velo puesto no se puede esperar a que todo se asiente: el
      // indicador gira sin parar.
      await tester.pump(busyOverlayDelay);
      await tester.pump(busyOverlayFadeDuration);

      expect(find.text('guardar'), findsOneWidget);
      expect(find.byType(FernProgressIndicator), findsOneWidget);

      await tester.tap(find.text('guardar'), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);
    });
  });
}
