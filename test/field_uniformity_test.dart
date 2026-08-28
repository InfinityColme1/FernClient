// Todos los campos se ven igual.
//
// Había dos estilos conviviendo en el mismo diálogo: el campo de texto normal
// —rótulo en negrita encima y marco fino— y el marco con contorno grueso del
// color del texto y el rótulo colgado del borde, que usaban los buscadores y los
// selectores de carpeta. El segundo se llevaba toda la atención de la pantalla
// sin merecerla más que el primero.
//
// Lo que esto sostiene es que el marco de un buscador salga del **mismo sitio**
// que el de un campo de texto: el tema. Comprobar que los dos son de un color
// concreto no valdría, porque los dos podrían ser de ese color y aun así dejar
// de coincidir en cuanto alguien tocara el tema.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/inputs/fern_field_label.dart';
import 'package:Fern/core/ui/inputs/fern_labeled_text_field.dart';
import 'package:Fern/core/ui/inputs/fern_outlined_field.dart';
import 'package:Fern/core/ui/inputs/fern_search_input.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ));
  }

  /// La caja que pinta el marco de un [FernOutlinedField].
  BoxDecoration frameOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(FernOutlinedField),
        matching: find.byType(Container),
      ),
    );

    return container.decoration! as BoxDecoration;
  }

  testWidgets('el marco de un buscador es el del tema de los campos de texto',
      (tester) async {
    await pump(
      tester,
      const FernOutlinedField(label: 'Buscar creador', child: SizedBox()),
    );

    final frame = frameOf(tester);
    final input = AppTheme.darkTheme.inputDecorationTheme;
    final border = input.border! as OutlineInputBorder;

    expect(frame.color, input.fillColor);
    expect(frame.border, Border.fromBorderSide(border.borderSide));
    expect(frame.borderRadius, border.borderRadius);
  });

  testWidgets('y el rótulo va encima, como el de un campo de texto',
      (tester) async {
    await pump(
      tester,
      const Column(
        children: [
          FernLabeledTextField(label: 'Nombre de la etiqueta'),
          FernOutlinedField(label: 'Buscar creador', child: SizedBox()),
        ],
      ),
    );

    // Los dos rótulos son el mismo widget, así que se leen con el mismo cuerpo
    // y el mismo peso. Con dos implementaciones distintas esto pasaba a ser una
    // coincidencia que nadie vigilaba.
    expect(find.byType(FernFieldLabel), findsNWidgets(2));

    final labels = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(FernFieldLabel),
        matching: find.byType(Text),
      ),
    );

    expect(labels.map((one) => one.style), everyElement(labels.first.style));
  });

  testWidgets('el fondo y el borde los pinta uno solo', (tester) async {
    // Los pintaban los dos: el marco por fuera y el campo por dentro. En los
    // lados rectos no se notaba —son del mismo color— pero el de dentro es un
    // rectángulo recto, así que en las esquinas se comía la curva del de fuera y
    // la caja salía con las cuatro puntas cortadas.
    await pump(
      tester,
      const FernSearchInput(label: 'Buscar creador'),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.decoration!.filled, isFalse);
    expect(field.decoration!.border, InputBorder.none);

    // Y el marco no recorta: recortar el contenido contra la curva era lo que
    // se llevaba por delante el borde de las esquinas.
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(FernOutlinedField),
        matching: find.byType(Container),
      ),
    );

    expect(container.clipBehavior, Clip.none);
  });

  testWidgets('sin rótulo no se deja el hueco', (tester) async {
    await pump(
      tester,
      const FernOutlinedField(label: '', child: SizedBox()),
    );

    expect(find.byType(FernFieldLabel), findsNothing);
  });
}
