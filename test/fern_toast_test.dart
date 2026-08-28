// El aviso breve de abajo.
//
// El que **lleva a algún sitio** se quedaba clavado en la pantalla: no armaba
// temporizador —a propósito, para dar tiempo a leerlo y decidir— pero tampoco
// tenía forma de cerrarse, así que a quien no le interesaba se le quedaba
// puesto para siempre. Es el aviso de «los modelos han encontrado N cosas», que
// lleva al parte del reconocimiento.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  /// Monta una pantalla con un botón que saca el aviso.
  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? onTap,
    String message = 'lo que ha pasado',
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showFernToast(context, message, onTap: onTap),
            child: const Text('avisar'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('avisar'));
    await tester.pump();
  }

  group('el aviso de siempre', () {
    testWidgets('aparece y se va solo', (tester) async {
      await pump(tester);

      expect(find.text('lo que ha pasado'), findsOneWidget);

      await tester.pump(toastDuration);
      await tester.pumpAndSettle();

      expect(find.text('lo que ha pasado'), findsNothing);
    });

    testWidgets('no lleva aspa: se va antes de que dé tiempo a pulsarla',
        (tester) async {
      await pump(tester);

      expect(find.byIcon(Symbols.close), findsNothing);

      await tester.pump(toastDuration);
      await tester.pumpAndSettle();
    });
  });

  group('el que lleva a algún sitio', () {
    testWidgets('dura más que el normal', (tester) async {
      await pump(tester, onTap: () {});

      // Pasado lo que dura uno normal, éste sigue: hay que leerlo y además
      // decidir si se pulsa.
      await tester.pump(toastDuration);
      await tester.pump();

      expect(find.text('lo que ha pasado'), findsOneWidget);

      await tester.pump(toastActionDuration);
      await tester.pumpAndSettle();
    });

    // Lo que fallaba: se quedaba puesto indefinidamente.
    testWidgets('pero también se va solo', (tester) async {
      await pump(tester, onTap: () {});

      await tester.pump(toastActionDuration);
      await tester.pumpAndSettle();

      expect(find.text('lo que ha pasado'), findsNothing);
    });

    testWidgets('y se puede cerrar sin ir a ninguna parte', (tester) async {
      var wentSomewhere = false;

      await pump(tester, onTap: () => wentSomewhere = true);

      await tester.tap(find.byIcon(Symbols.close));
      await tester.pumpAndSettle();

      expect(find.text('lo que ha pasado'), findsNothing);
      // Cerrar es cerrar: pulsar el aspa no puede llevar a donde lleva el aviso.
      expect(wentSomewhere, isFalse);
    });

    testWidgets('pulsarlo sí lleva, y lo cierra', (tester) async {
      var wentSomewhere = false;

      await pump(tester, onTap: () => wentSomewhere = true);

      await tester.tap(find.text('lo que ha pasado'));
      await tester.pumpAndSettle();

      expect(wentSomewhere, isTrue);
      expect(find.text('lo que ha pasado'), findsNothing);
    });
  });

  /// Una pantalla con un boton que va sacando avisos, uno por pulsacion.
  Future<void> pumpStack(WidgetTester tester, List<String> messages) async {
    var next = 0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showFernToast(context, messages[next++]),
            child: const Text('sacar'),
          ),
        ),
      ),
    ));

    for (var i = 0; i < messages.length; i++) {
      await tester.tap(find.text('sacar'));
      await tester.pump();
    }
  }

  testWidgets('varios se amontonan en vez de taparse', (tester) async {
    // Antes cada aviso quitaba al anterior, asi que dos cosas que terminaban a
    // la vez dejaban ver solo una.
    await pumpStack(tester, ['el primero', 'el segundo']);

    expect(find.text('el primero'), findsOneWidget);
    expect(find.text('el segundo'), findsOneWidget);

    await tester.pump(toastDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('al llegar el cuarto se va el mas viejo', (tester) async {
    await pumpStack(tester, ['uno', 'dos', 'tres', 'cuatro']);

    expect(find.text('uno'), findsNothing, reason: 'el mas viejo se va');
    for (final quedan in ['dos', 'tres', 'cuatro']) {
      expect(find.text(quedan), findsOneWidget, reason: quedan);
    }

    await tester.pump(toastDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('el mas nuevo va debajo', (tester) async {
    // Debajo, que es donde se mira: lo que acaba de pasar es lo mas cerca del
    // borde, y lo de antes va subiendo.
    await pumpStack(tester, ['el primero', 'el segundo']);

    expect(
      tester.getCenter(find.text('el segundo')).dy,
      greaterThan(tester.getCenter(find.text('el primero')).dy),
    );

    await tester.pump(toastDuration);
    await tester.pumpAndSettle();
  });
}
