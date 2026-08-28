// El deslizador que se mueve mientras lo mueves.
//
// Los de la aplicacion tomaban su posicion del sitio donde vive el valor de
// verdad y avisaban en cada pixel arrastrado: cada pixel era escribir un ajuste
// en disco, esperar a que el bloc lo devolviera y repintar. El tirador iba
// siempre por detras, a saltos.

import 'package:Fern/core/ui/inputs/fern_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double value,
  required void Function(double) onCommitted,
  void Function(double)? onPreview,
  void Function(double)? onDrag,
  Duration throttle = Duration.zero,
}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: FernSlider(
            value: value,
            max: 100,
            onCommitted: onCommitted,
            onPreview: onPreview,
            onDrag: onDrag,
            previewThrottle: throttle,
          ),
        ),
      ),
    ),
  ));
}

double _shown(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider)).value;

void main() {
  testWidgets('mientras se arrastra manda el tirador, no lo de fuera',
      (tester) async {
    // Lo de fuera se queda en cero a proposito: es lo que pasa de verdad
    // mientras el ajuste esta viajando al disco y de vuelta.
    await _pump(tester, value: 0, onCommitted: (_) {});

    final barra = tester.getRect(find.byType(Slider));
    final gesto = await tester.startGesture(barra.centerLeft);
    await gesto.moveTo(barra.center);
    await tester.pump();

    expect(_shown(tester), greaterThan(0));
  });

  testWidgets('al soltar avisa una sola vez', (tester) async {
    final avisos = <double>[];
    await _pump(tester, value: 0, onCommitted: avisos.add);

    final barra = tester.getRect(find.byType(Slider));
    final gesto = await tester.startGesture(barra.centerLeft);
    await gesto.moveTo(Offset(barra.center.dx, barra.center.dy));
    await tester.pump();
    expect(avisos, isEmpty, reason: 'no se avisa hasta soltar');

    await gesto.up();
    await tester.pumpAndSettle();

    expect(avisos, hasLength(1));
  });

  testWidgets('y no salta hacia atras mientras lo de fuera no llega',
      (tester) async {
    // Al soltar, el valor de fuera todavia es el viejo: si el tirador volviera a
    // el habria un fotograma en el que salta hacia atras, justo despues de
    // haberlo puesto donde se queria.
    await _pump(tester, value: 0, onCommitted: (_) {});

    final barra = tester.getRect(find.byType(Slider));
    final gesto = await tester.startGesture(barra.centerLeft);
    await gesto.moveTo(barra.center);
    await gesto.up();
    await tester.pumpAndSettle();

    expect(_shown(tester), greaterThan(0));
  });

  testWidgets('lo caro se avisa acotado y lo barato en cada movimiento',
      (tester) async {
    final caros = <double>[];
    final baratos = <double>[];

    await _pump(
      tester,
      value: 0,
      onCommitted: (_) {},
      onPreview: caros.add,
      onDrag: baratos.add,
      throttle: const Duration(seconds: 10),
    );

    final barra = tester.getRect(find.byType(Slider));
    final gesto = await tester.startGesture(barra.centerLeft);
    for (var i = 1; i <= 8; i++) {
      await gesto.moveTo(Offset(barra.left + barra.width * i / 10, barra.center.dy));
      await tester.pump();
    }
    await gesto.up();
    await tester.pumpAndSettle();

    // Con un acotado de diez segundos, lo caro se hace una vez y nada mas.
    expect(caros, hasLength(1));
    // Y lo barato, en todos: es lo que distingue un arrastre de un clic.
    expect(baratos.length, greaterThan(4));
  });
}
