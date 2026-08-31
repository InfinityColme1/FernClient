// Comprueba que la capa de marcado atiende al ratón cuando toca.
//
// Estas pruebas nacen de dos fallos reales: con el modo fernie encendido no
// funcionaba ningún gesto (la capa se quedaba apagada porque su rama del árbol
// no se reconstruía) y el doble clic para ajustar a pantalla no funcionaba en
// ningún modo (sólo existía dentro de la capa de entrada, que únicamente se
// montaba en modo fernie).

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/display/fern_region_selection_layer.dart';
import 'package:Fern/core/ui/display/region_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// El contenido y el hueco miden lo mismo, así que no hay bandas que descontar:
/// un punto de la pantalla es directamente su fracción del contenido.
const _size = Size(400, 400);

Future<TransformationController> pumpLayer(
  WidgetTester tester, {
  required bool enabled,
  Size? contentSize = _size,
  double regionsOpacity = 1,
  List<RegionVisual> regions = const [],
  int? highlightedIndex,
  double highlightIntensity = 0,
  FernRegionTool tool = FernRegionTool.mark,
  bool squareSelection = false,
  int? selectedIndex,
  void Function(Rect normalized, Offset screenPosition)? onRegionDrawn,
  ValueChanged<bool>? onDrawingChanged,
  void Function(int? index)? onSelectionRequested,
  void Function(Offset screenPosition)? onReassignRequested,
  ValueChanged<Rect>? onDraftChanged,
  VoidCallback? onTap,
}) async {
  final controller = TransformationController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _size.width,
          height: _size.height,
          child: FernRegionSelectionLayer(
            enabled: enabled,
            contentSize: contentSize,
            controller: controller,
            regions: regions,
            regionsOpacity: regionsOpacity,
            highlightedIndexes: {?highlightedIndex},
            highlightIntensity: highlightIntensity,
            tool: tool,
            squareSelection: squareSelection,
            selectedIndex: selectedIndex,
            onTap: onTap,
            onRegionDrawn: onRegionDrawn,
            onDrawingChanged: onDrawingChanged,
            onSelectionRequested: onSelectionRequested,
            onReassignRequested: onReassignRequested,
            onDraftChanged: onDraftChanged,
            child: const ColoredBox(color: Colors.black),
          ),
        ),
      ),
    ),
  ));

  return controller;
}

/// Un ratón de verdad: la capa mira qué botón viene pulsado, así que un dedo no
/// vale para probar el arrastre que marca región.
Future<void> dragMouse(
  WidgetTester tester,
  Offset from,
  Offset to,
) async {
  final gesture = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
  await tester.pump();

  await gesture.moveTo(to);
  await tester.pump();

  await gesture.up();
  await tester.pump();

  // El detector de doble clic deja un temporizador esperando al segundo toque;
  // sin agotarlo, la prueba termina con un temporizador vivo.
  await tester.pump(kDoubleTapTimeout);
}

void main() {
  group('cursor', () {
    testWidgets('en modo fernie el cursor es una cruz', (tester) async {
      await pumpLayer(tester, enabled: true);

      final cursors = tester
          .widgetList<MouseRegion>(find.byType(MouseRegion))
          .map((region) => region.cursor);

      expect(cursors, contains(SystemMouseCursors.precise));
    });

    testWidgets('en modo visualización el cursor es el normal', (tester) async {
      await pumpLayer(tester, enabled: false);

      final cursors = tester
          .widgetList<MouseRegion>(find.byType(MouseRegion))
          .map((region) => region.cursor);

      expect(cursors, isNot(contains(SystemMouseCursors.precise)));
    });
  });

  group('doble clic para ajustar a pantalla', () {
    testWidgets('funciona en modo visualización', (tester) async {
      final controller = await pumpLayer(tester, enabled: false);

      controller.value = Matrix4.identity()..scaleByDouble(3, 3, 3, 1);
      expect(controller.value, isNot(Matrix4.identity()));

      final center = tester.getCenter(find.byType(FernRegionSelectionLayer));
      await tester.tapAt(center);
      await tester.pump(kDoubleTapMinTime);
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(controller.value, Matrix4.identity());
    });

    testWidgets('funciona también en modo fernie', (tester) async {
      final controller = await pumpLayer(tester, enabled: true);

      controller.value = Matrix4.identity()..scaleByDouble(2, 2, 2, 1);

      final center = tester.getCenter(find.byType(FernRegionSelectionLayer));
      await tester.tapAt(center);
      await tester.pump(kDoubleTapMinTime);
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(controller.value, Matrix4.identity());
    });
  });

  group('marcar una región', () {
    testWidgets('arrastrar en modo fernie da la región arrastrada',
        (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        onRegionDrawn: (normalized, _) => drawn = normalized,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(300, 300),
      );

      expect(drawn, isNotNull, reason: 'el arrastre tiene que marcar región');
      expect(drawn!.left, closeTo(0.25, 0.01));
      expect(drawn!.top, closeTo(0.25, 0.01));
      expect(drawn!.right, closeTo(0.75, 0.01));
      expect(drawn!.bottom, closeTo(0.75, 0.01));
    });

    testWidgets('en modo visualización no se marca nada', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: false,
        onRegionDrawn: (normalized, _) => drawn = normalized,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(300, 300),
      );

      expect(drawn, isNull);
    });

    testWidgets('sin la medida del fichero no se marca nada', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        contentSize: null,
        onRegionDrawn: (normalized, _) => drawn = normalized,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(300, 300),
      );

      // Sin saber cuánto mide el contenido, la región saldría en coordenadas
      // inventadas: es preferible no marcar nada.
      expect(drawn, isNull);
    });

    testWidgets('un arrastre minúsculo no cuenta como región', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        onRegionDrawn: (normalized, _) => drawn = normalized,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(103, 103),
      );

      expect(drawn, isNull);
    });
  });

  group('avisar de que se está marcando', () {
    testWidgets('se avisa al empezar y al soltar', (tester) async {
      // Es lo que el visor usa para apartar sus mandos: marcar algo pegado al
      // borde de arriba no puede pelearse con la barra de acciones.
      final avisos = <bool>[];

      await pumpLayer(
        tester,
        enabled: true,
        onDrawingChanged: avisos.add,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(300, 300),
      );

      expect(avisos, [true, false]);
    });

    testWidgets('en modo visualización no se avisa de nada', (tester) async {
      final avisos = <bool>[];

      await pumpLayer(
        tester,
        enabled: false,
        onDrawingChanged: avisos.add,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(300, 300),
      );

      expect(avisos, isEmpty);
    });
  });

  group('regiones apiladas', () {
    /// Dos regiones, una encima de la otra: la de índice 1 tapa por completo a
    /// la de índice 0.
    const apiladas = [
      RegionVisual(rect: Rect.fromLTRB(0.1, 0.1, 0.9, 0.9)),
      RegionVisual(rect: Rect.fromLTRB(0.2, 0.2, 0.8, 0.8)),
    ];

    /// El centro del contenido, donde las dos se solapan.
    Offset centro(WidgetTester tester) =>
        tester.getCenter(find.byType(FernRegionSelectionLayer));

    Future<void> doubleClick(WidgetTester tester, Offset at) async {
      await tester.tapAt(at);
      await tester.pump(kDoubleTapMinTime);
      await tester.tapAt(at);
      await tester.pumpAndSettle();
    }

    testWidgets('sin nada elegido, el doble clic coge la de encima',
        (tester) async {
      final pedidas = <int?>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: apiladas,
        onSelectionRequested: pedidas.add,
      );

      await doubleClick(tester, centro(tester));

      // La de encima es la última de la lista, que es la que se pinta al final.
      expect(pedidas.last, 1);
    });

    testWidgets('con la de encima elegida, el doble clic baja a la de abajo',
        (tester) async {
      final pedidas = <int?>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: apiladas,
        selectedIndex: 1,
        onSelectionRequested: pedidas.add,
      );

      await doubleClick(tester, centro(tester));

      expect(pedidas.last, 0, reason: 'tiene que llegar a la de debajo');
    });

    testWidgets('con la de abajo elegida, el doble clic no vuelve a subir',
        (tester) async {
      final pedidas = <int?>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: apiladas,
        selectedIndex: 0,
        onSelectionRequested: pedidas.add,
      );

      await doubleClick(tester, centro(tester));

      // Volver a la de encima taparía otra vez el menú de la de debajo, que es
      // justo lo que este gesto viene a desbloquear.
      expect(pedidas, isEmpty);
    });

    testWidgets('el menú de la elegida espera por si viene un doble clic',
        (tester) async {
      final reasignadas = <Offset>[];
      final pedidas = <int?>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: apiladas,
        selectedIndex: 1,
        onSelectionRequested: pedidas.add,
        onReassignRequested: reasignadas.add,
      );

      await doubleClick(tester, centro(tester));

      // El doble clic gana: el menú de la de encima no llega a abrirse y se baja
      // a la de debajo.
      expect(reasignadas, isEmpty);
      expect(pedidas.last, 0);
    });

    testWidgets('un clic suelto sobre la elegida sí abre su menú',
        (tester) async {
      final reasignadas = <Offset>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: apiladas,
        selectedIndex: 1,
        onReassignRequested: reasignadas.add,
      );

      await tester.tapAt(centro(tester));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();

      expect(reasignadas, hasLength(1));
    });

    testWidgets('sin nada debajo, el menú se abre sin esperar', (tester) async {
      final reasignadas = <Offset>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: const [
          RegionVisual(rect: Rect.fromLTRB(0.2, 0.2, 0.8, 0.8)),
        ],
        selectedIndex: 0,
        onReassignRequested: reasignadas.add,
      );

      await tester.tapAt(centro(tester));
      await tester.pump();

      // Sin ambigüedad no hay nada que esperar: el menú sale en el acto.
      expect(reasignadas, hasLength(1));

      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
    });
  });

  group('mover una región', () {
    const region = [
      RegionVisual(rect: Rect.fromLTRB(0.25, 0.25, 0.5, 0.5)),
    ];

    testWidgets('la región sigue al ratón sin quedarse atrás', (tester) async {
      // El rectángulo de fuera no cambia en toda la prueba, que es justo lo que
      // pasa en la aplicación mientras el bloc no ha contestado todavía. Si la
      // capa se apoyara en él, cada movimiento pisaría al anterior y la región
      // sólo avanzaría lo del último.
      final drafts = <Rect>[];

      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: region,
        selectedIndex: 0,
        onDraftChanged: drafts.add,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));

      // Se arrastra desde dentro de la región, 40 px a la derecha, en cuatro
      // pasos de 10.
      final gesture = await tester.startGesture(
        origin + const Offset(150, 150),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();

      for (var step = 1; step <= 4; step++) {
        await gesture.moveTo(origin + Offset(150 + step * 10, 150));
        await tester.pump();
      }

      await gesture.up();
      await tester.pump(kDoubleTapTimeout);

      expect(drafts, isNotEmpty);

      // Cuarenta píxeles de cuatrocientos son una décima del contenido: el
      // desplazamiento acumulado tiene que ser ése y no el de un solo paso.
      expect(drafts.last.left, closeTo(0.35, 0.005));
      expect(drafts.last.width, closeTo(0.25, 0.005),
          reason: 'mover no puede cambiar el tamaño');
    });
  });

  group('el cursor sobre una región', () {
    const region = [
      RegionVisual(rect: Rect.fromLTRB(0.25, 0.25, 0.75, 0.75)),
    ];

    /// El cursor que hay puesto tras dejar el ratón en [at].
    ///
    /// El puntero se quita al terminar: dos punteros vivos a la vez sacan de
    /// quicio al seguidor de ratón de Flutter, y aquí se consulta varias veces
    /// en la misma prueba.
    Future<MouseCursor> cursorAt(WidgetTester tester, Offset at) async {
      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);

      await gesture.moveTo(at);
      await tester.pumpAndSettle();

      final cursor = tester
          .widgetList<MouseRegion>(find.byType(MouseRegion))
          .map((each) => each.cursor)
          .firstWhere(
            (cursor) => cursor != SystemMouseCursors.basic,
            orElse: () => SystemMouseCursors.basic,
          );

      await gesture.removePointer();
      await tester.pumpAndSettle();

      return cursor;
    }

    testWidgets('en las esquinas sale la flecha diagonal', (tester) async {
      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: region,
        selectedIndex: 0,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));

      // La región va de 100 a 300 sobre un contenido de 400.
      expect(
        await cursorAt(tester, origin + const Offset(100, 100)),
        SystemMouseCursors.resizeUpLeftDownRight,
      );
      expect(
        await cursorAt(tester, origin + const Offset(300, 100)),
        SystemMouseCursors.resizeUpRightDownLeft,
      );
    });

    testWidgets('en los lados sale la flecha recta', (tester) async {
      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: region,
        selectedIndex: 0,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));

      expect(
        await cursorAt(tester, origin + const Offset(200, 100)),
        SystemMouseCursors.resizeUpDown,
      );
      expect(
        await cursorAt(tester, origin + const Offset(100, 200)),
        SystemMouseCursors.resizeLeftRight,
      );
    });

    testWidgets('por dentro sale el de mover', (tester) async {
      await pumpLayer(
        tester,
        enabled: true,
        tool: FernRegionTool.edit,
        regions: region,
        selectedIndex: 0,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));

      expect(
        await cursorAt(tester, origin + const Offset(200, 200)),
        SystemMouseCursors.move,
      );
    });

    testWidgets('con la herramienta de marcar el cursor no cambia',
        (tester) async {
      await pumpLayer(
        tester,
        enabled: true,
        regions: region,
        selectedIndex: 0,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));

      // Marcando, el borde de una región no significa nada: se sigue dibujando.
      expect(
        await cursorAt(tester, origin + const Offset(100, 100)),
        SystemMouseCursors.precise,
      );
    });
  });

  group('cuándo se ven las regiones', () {
    /// El pintor que ha quedado montado, para poder preguntarle con qué ajustes
    /// se está dibujando.
    RegionPainter painterOf(WidgetTester tester) {
      final paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(FernRegionSelectionLayer),
              matching: find.byType(CustomPaint),
            )
            .first,
      );

      return paint.painter! as RegionPainter;
    }

    testWidgets('fuera del modo fernie las regiones están escondidas',
        (tester) async {
      await pumpLayer(tester, enabled: false, regionsOpacity: 0);

      expect(painterOf(tester).regionsOpacity, 0);
    });

    testWidgets('en modo fernie las regiones se ven', (tester) async {
      await pumpLayer(tester, enabled: true, regionsOpacity: 1);

      expect(painterOf(tester).regionsOpacity, 1);
    });

    testWidgets('la región resaltada se ve aunque las demás estén escondidas',
        (tester) async {
      // Es lo que pasa al abrir el visor desde la rejilla de fernies: el modo
      // está apagado, así que no se ve ninguna región salvo la señalada.
      await pumpLayer(
        tester,
        enabled: false,
        regionsOpacity: 0,
        highlightedIndex: 0,
        highlightIntensity: 1,
        regions: const [
          RegionVisual(rect: Rect.fromLTRB(0.2, 0.2, 0.6, 0.6)),
        ],
      );

      final painter = painterOf(tester);
      expect(painter.regionsOpacity, 0);
      expect(painter.highlightIntensity, 1);
      expect(painter.highlightedIndexes, {0});
    });
  });

  group('el toque de mirar', () {
    testWidgets('un toque suelto llega fuera del modo', (tester) async {
      var taps = 0;

      await pumpLayer(tester, enabled: false, onTap: () => taps++);

      await tester.tap(find.byType(FernRegionSelectionLayer));
      // El toque no se resuelve hasta que se descarta el doble: los dos gestos
      // empiezan igual.
      await tester.pump(kDoubleTapTimeout);

      expect(taps, 1);
    });

    testWidgets('marcando, el toque no es suyo', (tester) async {
      var taps = 0;

      // Dentro del modo un toque significa otra cosa (elegir una región), y de
      // eso se encarga la capa de marcar.
      await pumpLayer(tester, enabled: true, onTap: () => taps++);

      await tester.tap(find.byType(FernRegionSelectionLayer));
      await tester.pump(kDoubleTapTimeout);

      expect(taps, 0);
    });

    testWidgets('el doble toque sigue ajustando a pantalla', (tester) async {
      var taps = 0;

      final controller =
          await pumpLayer(tester, enabled: false, onTap: () => taps++);

      controller.value = Matrix4.identity()..scale(3.0);
      await tester.pump();

      final centre = tester.getCenter(find.byType(FernRegionSelectionLayer));
      await tester.tapAt(centre);
      await tester.pump(kDoubleTapMinTime);
      await tester.tapAt(centre);
      await tester.pumpAndSettle();

      // El doble toque no cuenta como toque suelto: son dos gestos distintos.
      expect(taps, 0);
      expect(controller.value, Matrix4.identity());
    });
  });

  // El recorte del avatar: lo que se arrastra es un cuadrado, no un rectángulo
  // libre. El avatar es redondo, así que lo que se marca tiene que ser
  // exactamente lo que se va a ver.
  group('la selección cuadrada', () {
    testWidgets('un arrastre torcido sale cuadrado', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        squareSelection: true,
        onRegionDrawn: (rect, _) => drawn = rect,
      );

      // Cien de ancho y treinta de alto: manda el eje que más se ha movido.
      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(200, 130),
      );

      expect(drawn, isNotNull);
      expect(drawn!.width, closeTo(drawn!.height, 0.001));
      expect(drawn!.width, closeTo(0.25, 0.001));
    });

    // Lo que hay que sostener de verdad: **cuadrado en píxeles**, que es lo que
    // se ve. En una imagen apaisada, un cuadrado de píxeles no tiene los lados
    // iguales medido en fracciones del contenido.
    testWidgets('cuadrado en píxeles, no en fracciones', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        squareSelection: true,
        contentSize: const Size(400, 200),
        onRegionDrawn: (rect, _) => drawn = rect,
      );

      // La imagen se pinta centrada y con bandas arriba y abajo: ocupa de 100 a
      // 300 en vertical.
      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(50, 120),
        origin + const Offset(150, 160),
      );

      expect(drawn, isNotNull);
      expect(drawn!.width * 400, closeTo(drawn!.height * 200, 0.5));
    });

    testWidgets('y no se sale de la imagen', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        squareSelection: true,
        onRegionDrawn: (rect, _) => drawn = rect,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(350, 100),
        origin + const Offset(399, 399),
      );

      expect(drawn, isNotNull);
      expect(drawn!.right, lessThanOrEqualTo(1.0));
      expect(drawn!.width, closeTo(drawn!.height, 0.001));
    });

    // Sin pedirla, la capa sigue marcando rectángulos libres: es lo que hace el
    // modo fernie, donde una región es la forma que tenga lo que se marca.
    testWidgets('sin pedirla el rectángulo sigue siendo libre', (tester) async {
      Rect? drawn;

      await pumpLayer(
        tester,
        enabled: true,
        onRegionDrawn: (rect, _) => drawn = rect,
      );

      final origin = tester.getTopLeft(find.byType(FernRegionSelectionLayer));
      await dragMouse(
        tester,
        origin + const Offset(100, 100),
        origin + const Offset(200, 130),
      );

      expect(drawn, isNotNull);
      expect(drawn!.width, closeTo(0.25, 0.001));
      expect(drawn!.height, closeTo(0.075, 0.001));
    });
  });
}
