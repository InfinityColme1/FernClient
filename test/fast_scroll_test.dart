// Que la rejilla no cargue nada mientras va lanzada.
//
// Cargar una miniatura cuesta abrir el fichero y descodificarlo. Haciendolo
// conforme se baja, un desplazamiento rapido pide cientos que no da tiempo a
// ensenar: se descodifican, se pintan medio fotograma y se tiran, y ese trabajo
// se lo quitan a las que si se van a quedar delante. De ahi que fuera lento **y**
// desigual.
//
// Lo que se comprueba aqui es sobre todo lo que **no** tiene que pasar: la rueda
// del raton y el desplazamiento lento no pueden verse afectados. Es la mitad de
// la peticion, y la que se rompe sin que nadie se de cuenta.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/fast_scroll_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una lista larga que dice, en cada celda, si la rejilla iba lanzada al
/// pintarla.
class _Spy extends StatelessWidget {
  final void Function(bool isFast) onBuilt;

  const _Spy({required this.onBuilt});

  @override
  Widget build(BuildContext context) {
    onBuilt(FastScrollScope.of(context));

    return const SizedBox(height: 200);
  }
}

void main() {
  /// Monta la lista y devuelve el ultimo estado visto por las celdas.
  Future<List<bool>> mount(WidgetTester tester) async {
    final seen = <bool>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FastScrollDetector(
          child: ListView.builder(
            itemCount: 500,
            itemBuilder: (context, index) => _Spy(onBuilt: seen.add),
          ),
        ),
      ),
    ));

    seen.clear();
    return seen;
  }

  testWidgets('de partida no va lanzada', (tester) async {
    final seen = await mount(tester);
    await tester.pump();

    expect(seen.any((fast) => fast), isFalse);
  });

  testWidgets('un lanzamiento la pone en marcha', (tester) async {
    final seen = await mount(tester);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 8000);

    // Fotograma a fotograma, que es como corre de verdad: la velocidad se mide
    // sobre una ventana de varios, no entre dos avisos sueltos.
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(seen.any((fast) => fast), isTrue);
  });

  testWidgets('y al parar se vuelve a cargar', (tester) async {
    final seen = await mount(tester);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 8000);

    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(seen.any((fast) => fast), isTrue, reason: 'iba lanzada');

    await tester.pumpAndSettle();

    // Lo ultimo que ven las celdas es que ya no va lanzada: es el momento de
    // cargar lo que ha quedado delante.
    expect(seen.last, isFalse);
  });

  testWidgets('la rueda del raton no la pone en marcha', (tester) async {
    final seen = await mount(tester);

    final centre = tester.getCenter(find.byType(ListView));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    pointer.hover(centre);

    // Varias vueltas seguidas, que es como se usa de verdad.
    for (var turn = 0; turn < 6; turn++) {
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(seen.any((fast) => fast), isFalse,
        reason: 'la rueda va muy por debajo del listón');
  });

  testWidgets('arrastrar la barra no carga hasta soltarla', (tester) async {
    final seen = await mount(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );

    // Despacio a proposito: doscientos pixeles en medio segundo. En escritorio
    // no se arrastra el contenido, asi que un arrastre **es la barra**, y hasta
    // que no se suelta no se sabe donde se va a quedar.
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(seen.any((fast) => fast), isTrue,
        reason: 'mientras se tiene cogida, no se carga');

    seen.clear();

    await gesture.up();
    await tester.pumpAndSettle();

    expect(seen.last, isFalse, reason: 'al soltarla, si');
  });

  test('el listón separa la rueda de un lanzamiento', () {
    // Es el número del que depende todo lo de arriba, y se deja dicho: una rueda
    // usada con ganas anda por mil o mil quinientos, y un lanzamiento empieza
    // por encima de tres mil.
    expect(fastScrollVelocity, greaterThan(2000));
    expect(fastScrollVelocity, lessThan(5000));
  });
}
