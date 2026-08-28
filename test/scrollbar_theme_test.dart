// La barra de desplazamiento: que no salga mordida y que no sea una raya.
//
// Las dos cosas que se comprueban aquí son las dos que estaban mal. La primera
// es geométrica: la rejilla de contenido vive dentro de una superficie de
// esquinas redondeadas y **recortada**, así que una barra pegada al canto entra
// en la curva justo en sus dos extremos y sale mordida. La segunda es que en
// reposo y bajo el ratón se vea distinta, que es lo que la convierte en algo que
// se coge en vez de en una raya que hay que apuntar.

import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ScrollbarThemeData _barra(ThemeData tema) => tema.scrollbarTheme;

/// Hasta qué altura muerde una esquina de radio [radio] a algo que pasa a
/// [separacion] del borde.
///
/// La esquina redondeada es un cuarto de círculo con el centro metido [radio]
/// hacia dentro por los dos lados. Una vertical que pasa a [separacion] del
/// canto queda fuera del círculo —y por tanto recortada— desde el borde hasta
/// esta altura.
double _mordida(double radio, double separacion) {
  final dentro = radio - separacion;

  return radio - math.sqrt(radio * radio - dentro * dentro);
}

void main() {
  test('la barra empieza y acaba fuera de la curva de la superficie', () {
    // El caso peor es el lado del pulgar más cercano al canto: el que primero
    // entra en la curva.
    final mordida = _mordida(
      AppSizes.radiusSurface,
      AppSizes.scrollbarMargin,
    );

    expect(
      AppSizes.scrollbarEndInset,
      greaterThanOrEqualTo(mordida),
      reason: 'con este hueco la barra todavía entra en la esquina redondeada '
          'de la superficie, que es lo que la recortaba',
    );
  });

  test('el carril deja hueco de sobra para la pastilla mas gorda', () {
    // El fallo que esto cierra: el hueco contra el canto se subio pensando que
    // apartaba la pastilla del contenido, y hace justo lo contrario — la mete
    // hacia dentro, que es hacia el contenido. Lo que de verdad la separa es el
    // carril que se aparta el contenido, y tiene que dar para el hueco del canto,
    // para lo gorda que llega a ponerse y para un margen que se vea.
    final ocupa = AppSizes.scrollbarMargin + AppSizes.scrollbarThicknessDragged;

    expect(AppSizes.scrollbarLane, greaterThan(ocupa));
    expect(
      AppSizes.scrollbarLane - ocupa,
      greaterThanOrEqualTo(AppSizes.scrollbarThickness),
      reason: 'con menos hueco que lo fina que es la propia barra, la pastilla '
          'se lee como parte del contenido y no como un mando aparte',
    );
  });

  test('el hueco contra el canto no se come el carril', () {
    // Subir uno sin subir el otro es empujar la pastilla contra el contenido.
    expect(AppSizes.scrollbarMargin, lessThan(AppSizes.scrollbarLane / 2));
  });

  test('el pulgar crece al acercarse y al arrastrarlo', () {
    final grosor = _barra(AppTheme.lightTheme).thickness!;

    final reposo = grosor.resolve({});
    final encima = grosor.resolve({WidgetState.hovered});
    final arrastrando = grosor.resolve({WidgetState.dragged});

    expect(encima, greaterThan(reposo!));
    expect(arrastrando, greaterThan(encima!));
  });

  test('el surco sólo sale con el ratón encima', () {
    final tema = _barra(AppTheme.lightTheme);

    expect(tema.trackVisibility!.resolve({}), isFalse);
    expect(tema.trackVisibility!.resolve({WidgetState.hovered}), isTrue);
    expect(tema.trackColor!.resolve({}), Colors.transparent);
    expect(
      tema.trackColor!.resolve({WidgetState.hovered}),
      isNot(Colors.transparent),
    );
  });

  test('los colores salen de la paleta y cambian al arrastrar', () {
    for (final (tema, paleta) in [
      (AppTheme.lightTheme, AppColors.light),
      (AppTheme.darkTheme, AppColors.dark),
    ]) {
      final pulgar = _barra(tema).thumbColor!;

      expect(pulgar.resolve({}), paleta.unremarked);
      expect(pulgar.resolve({WidgetState.hovered}), paleta.gray);
      expect(pulgar.resolve({WidgetState.dragged}), paleta.primary);
    }
  });

  testWidgets('una lista desplazable cualquiera hereda la barra de la app',
      (tester) async {
    // Lo que de verdad importa: la mayoría de las barras de la aplicación no las
    // pone ningún widget nuestro, las pone Flutter sola. Si el aspecto viviera
    // en un widget en vez de en el tema, ésas seguirían siendo las de fábrica.
    await tester.pumpWidget(MaterialApp(
      // Windows a proposito: la barra que Flutter pone sola solo aparece en
      // escritorio, y la aplicacion es de escritorio. En una prueba, sin decirlo,
      // se da por hecho un movil y no habria barra ninguna que mirar.
      theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.windows),
      home: Scaffold(
        body: ListView(
          children: [for (var i = 0; i < 50; i++) SizedBox(height: 40)],
        ),
      ),
    ));

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar).first);
    final heredado = ScrollbarTheme.of(tester.element(find.byType(Scrollbar).first));

    expect(scrollbar, isNotNull);
    expect(heredado.mainAxisMargin, AppSizes.scrollbarEndInset);
    expect(heredado.thumbColor!.resolve({}), AppColors.light.unremarked);
  });
}
