// El movimiento de la aplicacion.
//
// Dos cosas que no se ven leyendo el codigo y que rompen a quien las sufre:
// que «reducir movimiento» del sistema se respete, y que el aviso de lo que se
// esta arrastrando llegue tambien a las filas del menu lateral —que no van por
// `FernDropSlot` y por eso se quedaron fuera la primera vez—.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fern_motion.dart';
import 'package:Fern/core/ui/display/fern_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Duration> _duracionEn(
  WidgetTester tester, {
  required bool sinMovimiento,
}) async {
  late Duration medida;

  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(disableAnimations: sinMovimiento),
    child: Builder(
      builder: (context) {
        medida = context.motion(motionStandard);
        return const SizedBox();
      },
    ),
  ));

  return medida;
}

void main() {
  group('reducir movimiento', () {
    testWidgets('sin pedirlo, las duraciones son las suyas', (tester) async {
      expect(await _duracionEn(tester, sinMovimiento: false), motionStandard);
    });

    testWidgets('pidiendolo, se quedan en cero', (tester) async {
      // En cero y no quitadas: el estado final es el mismo, asi que no hay que
      // escribir dos versiones de cada pantalla.
      expect(await _duracionEn(tester, sinMovimiento: true), Duration.zero);
    });

    testWidgets('y un hueco de carga deja de latir', (tester) async {
      // Un latido se repite solo: no termina nunca, asi que acortarlo no vale de
      // nada. O no esta, o sigue molestando.
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FernSkeleton(width: 100, height: 100),
        ),
      ));

      expect(find.byType(AnimatedBuilder), findsNothing);
    });

    testWidgets('sin pedirlo, si late', (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FernSkeleton(width: 100, height: 100),
        ),
      ));

      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });
  });

  group('el fundido cruzado', () {
    // Las dos pantallas van una encima de otra, asi que lo que se ve es la de
    // arriba compuesta sobre la de abajo compuesta sobre el fondo. Con
    // opacidades complementarias —una a t y la otra a 1-t— a mitad de camino las
    // dos estan al 50 % y por las dos se cuela el fondo: un 25 % de fondo
    // desnudo justo en el centro. Eso es el lavado que se ve como un salto.
    //
    // Lo que se exige aqui es que la pantalla **nunca se destape**.

    /// Cuanto fondo se ve entre las dos pantallas en el instante [t].
    double fondoVisible(double t) {
      final entrando = crossfadeInCurve.transform(t);
      final saliendo = crossfadeOutCurve.transform(t);

      // La que entra va a `entrando`; la que sale, a `1 - saliendo`.
      return (1 - entrando) * saliendo;
    }

    test('la pantalla no se destapa en ningun momento', () {
      for (var paso = 0; paso <= 100; paso++) {
        final t = paso / 100;

        expect(
          fondoVisible(t),
          lessThan(0.05),
          reason: 'en t=$t se cuela demasiado fondo entre las dos pantallas',
        );
      }
    });

    test('y con curvas complementarias si se destaparia', () {
      // La comprobacion de la comprobacion: sin las curvas, a mitad de camino se
      // cuela un cuarto de fondo. Si esto dejara de fallar seria que la medida
      // de arriba no mide nada.
      const ingenuo = Curves.linear;
      final t = 0.5;
      final leak = (1 - ingenuo.transform(t)) * ingenuo.transform(t);

      expect(leak, greaterThan(0.2));
    });

    test('empieza tapada y termina tapada', () {
      expect(fondoVisible(0), 0);
      expect(fondoVisible(1), 0);
    });
  });

  group('los tiempos', () {
    test('van de menos a mas', () {
      // Si alguien los toca, que no se crucen: lo que se resuelve en el sitio no
      // puede tardar mas que lo que cruza media pantalla.
      expect(motionFast, lessThan(motionStandard));
      expect(motionStandard, lessThan(motionEmphasized));
    });

    test('y el de siempre es el normal', () {
      expect(hoverAnimationDuration, motionFast);
    });
  });
}
