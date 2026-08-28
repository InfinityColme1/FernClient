// El texto que va rotando mientras se instala el entorno.
//
// Lo que hay que sostener es que no se mueva de sitio. Un `AnimatedSwitcher`
// centra sus hijos y se redimensiona al tamaño de cada uno, así que sin poner
// remedio cada frase aparecía corrida a la derecha y saltaba a la izquierda al
// desaparecer la anterior. Es muy fácil volver a romperlo tocando el widget, de
// ahí estas pruebas.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/presentation/widgets/sidecar_activity_text.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpActivity(WidgetTester tester) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SidecarActivityText()],
        ),
      ),
    ),
  ));
}

/// Dónde empieza el texto que se está viendo.
double leftEdgeOf(WidgetTester tester) {
  final texts = find.byType(Text);

  return tester
      .getTopLeft(texts.first)
      .dx;
}

void main() {
  testWidgets('todas las frases empiezan en la misma columna', (tester) async {
    await pumpActivity(tester);

    final first = leftEdgeOf(tester);

    // Se recorren varias frases, que son de largos muy distintos: es justo lo
    // que destapaba el salto.
    for (var change = 0; change < 4; change++) {
      await tester.pump(sidecarActivityRotation);
      await tester.pump(sidecarActivityFade);

      expect(
        leftEdgeOf(tester),
        first,
        reason: 'la frase ${change + 1} no empieza donde las demás',
      );
    }

    // Y a media transición, con las dos frases montadas, tampoco se mueve.
    await tester.pump(sidecarActivityRotation);
    await tester.pump(sidecarActivityFade ~/ 2);

    for (final text in find.byType(Text).evaluate()) {
      expect(tester.getTopLeft(find.byWidget(text.widget)).dx, first);
    }

    await tester.pump(sidecarActivityFade);
  });

  testWidgets('el hueco no cambia de tamaño al cambiar de frase',
      (tester) async {
    await pumpActivity(tester);

    final size = tester.getSize(find.byType(SidecarActivityText));

    await tester.pump(sidecarActivityRotation);
    await tester.pump(sidecarActivityFade ~/ 2);

    // A media transición, que es cuando hay dos frases dentro.
    expect(tester.getSize(find.byType(SidecarActivityText)), size);

    await tester.pump(sidecarActivityFade);

    expect(tester.getSize(find.byType(SidecarActivityText)), size);
  });

  testWidgets('la frase cambia sola, sin que nadie la toque', (tester) async {
    await pumpActivity(tester);

    final texts = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(texts.sidecarBusyDownloading), findsOneWidget);

    // Antes de que toque, sigue la misma.
    await tester.pump(sidecarActivityRotation ~/ 2);
    expect(find.text(texts.sidecarBusyDownloading), findsOneWidget);

    await tester.pump(sidecarActivityRotation);

    // El switcher arranca su animación en el fotograma siguiente al cambio y
    // retira la frase anterior cuando termina, así que hacen falta dos pasadas
    // completas para verlo ya sin ella.
    await tester.pump(sidecarActivityFade);
    await tester.pump(sidecarActivityFade);

    expect(find.text(texts.sidecarBusyUnpacking), findsOneWidget);
    expect(find.text(texts.sidecarBusyDownloading), findsNothing);
  });
}
