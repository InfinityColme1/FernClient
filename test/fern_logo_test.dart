// La geometria del rizo del logotipo.
//
// La marca se dibuja con un `CustomPainter`, y ahi dentro no se puede mirar
// nada: o se ve bien en pantalla o no. Lo que si se puede comprobar es la
// espiral, que es lo unico que tiene cuentas — y las dos cosas que se notan en
// cuanto fallan son que se salga de su caja y que el radio deje de encoger.

import 'dart:math' as math;

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _centro = Offset(logoCoilCentreX, logoCoilCentreY);

double _radio(Offset p) => (p - _centro).distance;

void main() {
  final puntos = fernFiddleheadPoints();

  test('el rizo se traza entero', () {
    expect(puntos, hasLength(logoCoilSteps + 1));
  });

  test('el radio encoge en todo el recorrido', () {
    // Si en algun tramo creciera, el rizo se cruzaria consigo mismo y dejaria de
    // leerse como un brote abriendose.
    for (var i = 1; i < puntos.length; i++) {
      expect(
        _radio(puntos[i]),
        lessThan(_radio(puntos[i - 1])),
        reason: 'el radio crece en el tramo $i',
      );
    }
  });

  test('empieza y acaba donde toca', () {
    expect(_radio(puntos.first), closeTo(logoCoilRadius, 0.01));
    expect(
      _radio(puntos.last),
      closeTo(logoCoilRadius / logoCoilShrink, 0.01),
    );
  });

  test('da vuelta y media larga', () {
    expect(logoCoilSweep / (2 * math.pi), closeTo(1.6, 0.01));
  });

  test('no se sale de su caja', () {
    // La caja es la reticula sobre la que se escala todo. Un punto fuera se
    // recortaria en pantalla, y el trazo tiene grosor: se le deja su mitad.
    const margen = logoStrokeWidth / 2;
    final ancho = logoMarkGridHeight * logoMarkAspect;

    for (final p in puntos) {
      expect(p.dx, greaterThanOrEqualTo(margen));
      expect(p.dx, lessThanOrEqualTo(ancho - margen));
      expect(p.dy, greaterThanOrEqualTo(margen));
      expect(p.dy, lessThanOrEqualTo(logoMarkGridHeight - margen));
    }
  });

  test('el rizo entra cerca del baston', () {
    // Si entrara lejos, el enlace entre el baston recto y la espiral seria una
    // curva larga y se leeria como un gancho, no como un brote.
    expect((puntos.first.dx - logoStaffX).abs(), lessThan(1.5));
    expect(puntos.first.dy, greaterThan(logoCoilCentreY));
  });

  testWidgets('el nombre lleva la e en minuscula', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FernLogo(height: 60))),
    ));

    expect(find.text('FeRN'), findsOneWidget);
  });

  testWidgets('y la marca sola no lo lleva', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FernLogo.mark(height: 60))),
    ));

    expect(find.text('FeRN'), findsNothing);
  });
}
