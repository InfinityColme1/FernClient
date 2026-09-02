// Mientras la pantalla entra, las celdas no empiezan a cargar nada.
//
// Entrar en una pantalla es construir la rejilla y, con ella, treinta miniaturas
// que se abren y se descodifican **justo encima de la animacion**. Es el trabajo
// que hacia que la transicion se viera a tirones, y no hay ninguna prisa por
// hacerlo ahi: la pantalla acaba de aparecer y nadie ha mirado todavia.
//
// Es el mismo mecanismo que ya cortaba la carga con la rejilla lanzada, con otra
// señal: para la celda la pregunta sigue siendo una sola, «¿empiezo a cargar
// ahora?».

import 'package:Fern/core/ui/display/fast_scroll_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que contesta una celda de la rejilla.
class _Cell extends StatelessWidget {
  const _Cell();

  @override
  Widget build(BuildContext context) =>
      Text(FastScrollScope.of(context) ? 'espera' : 'carga');
}

Future<void> _pump(WidgetTester tester, {required bool hold}) async {
  await tester.pumpWidget(MaterialApp(
    home: HoldThumbnailsScope(
      hold: hold,
      child: const FastScrollDetector(
        child: SingleChildScrollView(child: _Cell()),
      ),
    ),
  ));
}

void main() {
  testWidgets('sin nadie que pida esperar, se carga', (tester) async {
    await _pump(tester, hold: false);

    expect(find.text('carga'), findsOneWidget);
  });

  testWidgets('mientras la pantalla entra, se espera', (tester) async {
    await _pump(tester, hold: true);

    expect(find.text('espera'), findsOneWidget);
  });

  // Al terminar la transicion se carga lo que haya quedado delante, que es lo
  // unico que alguien va a mirar.
  testWidgets('y al terminar de entrar, se carga', (tester) async {
    await _pump(tester, hold: true);
    await _pump(tester, hold: false);

    expect(find.text('carga'), findsOneWidget);
  });

  // Sin nadie por encima que lo pida, la rejilla se comporta como siempre: la
  // señal es opcional y su ausencia no puede dejar la rejilla sin cargar.
  testWidgets('sin el aviso por encima, tambien se carga', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FastScrollDetector(
        child: SingleChildScrollView(child: _Cell()),
      ),
    ));

    expect(find.text('carga'), findsOneWidget);
  });
}
