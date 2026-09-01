// Enter valida en los diálogos del bloqueo.
//
// Escribir la contraseña y pulsar Enter es el gesto de todo el mundo. Sin esto
// había que soltar el teclado, coger el ratón e ir a por el botón, y eso en un
// diálogo que se abre cada vez que se quiere ver el contenido escondido.
//
// Lo que se comprueba es que el campo **entrega** lo escrito: lo que pase
// después es lo mismo que hace el botón, y eso ya está probado donde toca.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required ValueChanged<String>? onSubmitted,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FernLabeledTextField(
          label: 'Contraseña',
          obscureText: true,
          onSubmitted: onSubmitted,
        ),
      ),
    ));
  }

  testWidgets('lo escrito se entrega al pulsar Enter', (tester) async {
    String? submitted;

    await pump(tester, onSubmitted: (value) => submitted = value);

    await tester.enterText(find.byType(TextField), 'secreto');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 'secreto');
  });

  // Un campo sin nada que hacer al enviar se comporta como siempre.
  testWidgets('sin nada que entregar, no pasa nada', (tester) async {
    await pump(tester, onSubmitted: null);

    await tester.enterText(find.byType(TextField), 'algo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  // La tecla dice lo que va a pasar en vez de meter un salto de línea.
  testWidgets('la tecla de entrada es la de confirmar', (tester) async {
    await pump(tester, onSubmitted: (_) {});

    expect(
      tester.widget<TextField>(find.byType(TextField)).textInputAction,
      TextInputAction.done,
    );
  });
}
