// Comprueba que el botón de añadir encaja con lo que tiene al lado y que su
// respuesta al ratón se lee como una sola cosa.
//
// Nace de dos cosas que se vieron en la aplicación: el círculo del "+" salía
// mucho más pequeño que los avatares de la misma fila, y al pasar el ratón por
// encima usaba un color y al pulsar otro, lo que se leía como dos botones
// distintos en vez de uno.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una fila como la de la sección de fernies: el botón de añadir y un avatar.
Future<void> _pumpRow(WidgetTester tester, {VoidCallback? onTap}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FernAddButton(label: 'Añadir fernie', onTap: onTap),
            const FernAvatarTile(label: 'Katara'),
          ],
        ),
      ),
    ),
  ));
}

/// El color de fondo del círculo del "+".
Color? _circleColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(FernAddButton),
      matching: find.byType(AnimatedContainer),
    ),
  );

  return (container.decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('el círculo mide lo mismo que el avatar de al lado',
      (tester) async {
    await _pumpRow(tester);

    final circle = tester.getSize(
      find.descendant(
        of: find.byType(FernAddButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final avatar = tester.getSize(
      find.descendant(
        of: find.byType(FernAvatarTile),
        matching: find.byType(CircleAvatar),
      ),
    );

    expect(circle.width, avatar.width);
    expect(circle.height, avatar.height);
  });

  testWidgets('los dos rótulos caen a la misma altura', (tester) async {
    await _pumpRow(tester);

    // En una fila mezclada, el texto de debajo del "+" y el del avatar tienen
    // que alinearse: si no, la fila se lee torcida.
    expect(
      tester.getTopLeft(find.text('Añadir fernie')).dy,
      closeTo(tester.getTopLeft(find.text('Katara')).dy, 0.01),
    );
  });

  testWidgets('la variante suelta conserva su círculo pequeño', (tester) async {
    // Se puede pedir el tamaño de siempre para los sitios donde el botón va
    // suelto bajo un buscador y no acompaña a ninguna rejilla.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: FernAddButton(
            label: 'Crear etiqueta',
            radius: AppSizes.addButtonRadius,
          ),
        ),
      ),
    ));

    final circle = tester.getSize(
      find.descendant(
        of: find.byType(FernAddButton),
        matching: find.byType(AnimatedContainer),
      ),
    );

    expect(circle.width, AppSizes.addButtonRadius * 2);
  });

  testWidgets('el realce es de un solo color', (tester) async {
    await _pumpRow(tester, onTap: () {});

    final context = tester.element(find.byType(FernAddButton));
    final highlight = context.colors.secondary;

    expect(_circleColor(tester)!.a, 0, reason: 'en reposo no se ve');

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.text('Añadir fernie')));
    await tester.pumpAndSettle();

    expect(_circleColor(tester), highlight, reason: 'con el ratón encima');

    // Y al pulsar **el mismo**: dos tonos distintos se leen como dos botones.
    // Lo que distingue la pulsación es el encogido.
    await gesture.down(tester.getCenter(find.text('Añadir fernie')));
    await tester.pumpAndSettle();

    expect(_circleColor(tester), highlight, reason: 'y al pulsar, el mismo');

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('el desvanecido no pasa por otro color', (tester) async {
    await _pumpRow(tester, onTap: () {});

    final context = tester.element(find.byType(FernAddButton));
    final highlight = context.colors.secondary;

    // El color de reposo tiene que ser el de realce a cero, no
    // `Colors.transparent`.
    //
    // Aquél es negro invisible: el desvanecido interpola todos los canales a la
    // vez, así que el círculo pasaría por un gris a media opacidad camino del
    // tono de verdad y se vería un parpadeo de dos colores. Comparando los
    // canales de color (no el alfa) queda fijado que por el camino sólo cambia
    // la opacidad.
    final resting = _circleColor(tester)!;

    expect(resting.r, highlight.r);
    expect(resting.g, highlight.g);
    expect(resting.b, highlight.b);
    expect(resting.a, 0);
  });

  testWidgets('desactivado no se realza ni al pasar por encima',
      (tester) async {
    await _pumpRow(tester);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.text('Añadir fernie')));
    await tester.pumpAndSettle();

    expect(_circleColor(tester)!.a, 0);
  });
}
