// Los botones de añadir del panel de informacion.
//
// Tres cosas que tienen que darse a la vez, y sacar una rompe otra:
//
// - **A la altura del titulo**, no en una fila propia debajo: ahi el boton
//   queda lejos de lo que nombra y se pierde una fila de alto en cada seccion.
// - **Con su texto entero**, que es lo que dice que hace.
// - **Alineados entre si**: sus rotulos son de distinto largo, asi que si cada
//   uno mide lo suyo los dos «+» caen en columnas distintas y las dos secciones
//   dejan de parecer la misma cosa. Van en un hueco del mismo ancho, medido con
//   el mayor de los dos rotulos de la lengua que este puesta.
//
// Y las tres juntas son las que fijan el ancho del panel: con el titulo y el
// boton entero, la cabecera pide unos trescientos sesenta puntos. Por eso estas
// dos cabeceras van sin icono: con el harian falta treinta mas.

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que el boton menudo ocupa ademas del rotulo. La misma cuenta que hace el
/// panel: si una cambia y la otra no, esta prueba se pone en rojo.
const _chrome = AppSpacing.xs * 2 +
    (AppSizes.borderThin * 2 + AppSpacing.xxs * 2 + AppSizes.iconSmall) +
    AppSpacing.s;

double _slotFor(BuildContext context, List<String> labels) {
  final style = Theme.of(context).textTheme.labelSmall;
  var widest = 0.0;

  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    if (painter.width > widest) widest = painter.width;
  }

  return widest + _chrome;
}

void main() {
  /// La cabecera tal y como la arma el panel, al ancho de verdad.
  Future<void> pump(
    WidgetTester tester,
    AppLocalizations texts, {
    required bool isTags,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SizedBox(
          width: AppSizes.infoPanelWidth,
          child: Padding(
            padding: AppSpacing.infoPadding,
            child: Builder(
              builder: (context) => FernSectionHeader(
                title: isTags ? texts.tagsTitle : texts.ferniesTitle,
                trailing: SizedBox(
                  width: _slotFor(context, [texts.addTags, texts.addFernies]),
                  child: FernAddButton.compact(
                    label: isTags ? texts.addTags : texts.addFernies,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final locale in AppLocalizations.supportedLocales) {
    final code = locale.languageCode;

    testWidgets('en $code caben el titulo y el boton enteros', (tester) async {
      final texts = await AppLocalizations.delegate.load(locale);

      for (final isTags in [true, false]) {
        final label = isTags ? texts.addTags : texts.addFernies;
        final title = isTags ? texts.tagsTitle : texts.ferniesTitle;

        // Lo que piden sueltos.
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    FernAddButton.compact(label: label, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final wantedTitle = tester.getSize(find.text(title)).width;
        final wantedLabel = tester.getSize(find.text(label)).width;

        // Y lo que ocupan dentro de la cabecera del panel.
        await pump(tester, texts, isTags: isTags);

        // Con el hueco que le dan: si es menor que lo que pide, sale con
        // puntos suspensivos. Mayor no es problema —le sobra sitio—, y pasa
        // siempre en el mas corto de los dos rotulos.
        expect(
          tester.getSize(find.text(title)).width,
          greaterThanOrEqualTo(wantedTitle),
          reason: 'el titulo «$title» sale recortado en $code',
        );
        expect(
          tester.getSize(find.text(label)).width,
          greaterThanOrEqualTo(wantedLabel),
          reason: 'el rotulo «$label» sale recortado en $code',
        );

        expect(tester.takeException(), isNull);
      }
    });

    // Los dos «+» en la misma columna: es lo que hace que las dos secciones se
    // lean como la misma cosa.
    testWidgets('y los dos «+» caen en la misma columna en $code',
        (tester) async {
      final texts = await AppLocalizations.delegate.load(locale);

      await pump(tester, texts, isTags: true);
      final tags = tester.getTopLeft(find.byType(FernAddButton)).dx;

      await pump(tester, texts, isTags: false);
      final fernies = tester.getTopLeft(find.byType(FernAddButton)).dx;

      expect(fernies, tags);
    });
  }
}
