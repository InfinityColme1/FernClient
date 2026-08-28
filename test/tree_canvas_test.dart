// El lienzo del arbol: donde cae cada tarjeta y que se puede tocar.
//
// La geometria se comprueba porque **las aristas se dibujan con esta misma
// cuenta**. Si la tarjeta se pinta en un sitio y la linea sale de otro, el arbol
// deja de decir quien ejecuta a quien, que es lo unico que decide.

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_canvas.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_drag_payload.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_edge_painter.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_node_card.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

ModelTreeNodeEntity _node(
  int id, {
  int row = 0,
  double column = 0,
  bool isTrained = true,
  String? name,
}) {
  return ModelTreeNodeEntity(
    id: id,
    row: row,
    column: column,
    model: RecognitionModelEntity(
      id: id,
      name: name ?? 'Modelo $id',
      weightsPath: isTrained ? 'C:/runs/$id/best.pt' : null,
      createdAt: DateTime(2026),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  ModelTreeEntity tree, {
  int? selectedNodeId,
  Map<int, String> edgeLabels = const {},
  bool isSimplified = false,
  ValueChanged<int>? onNodeTap,
  ValueChanged<int>? onNodeRemove,
  ValueChanged<int>? onEdgeTap,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: TreeCanvas(
            tree: tree,
            selectedNodeId: selectedNodeId,
            edgeLabels: edgeLabels,
            isSimplified: isSimplified,
            onNodeTap: onNodeTap,
            onNodeRemove: onNodeRemove,
            onEdgeTap: onEdgeTap,
          ),
        ),
      ),
    ),
  ));
}

void main() {
  group('la geometria', () {
    test('el primer nodo va en el origen', () {
      expect(treeNodeOffset(_node(1)), Offset.zero);
    });

    test('cada columna se corre lo que mide una tarjeta y su hueco', () {
      final offset = treeNodeOffset(_node(1, column: 2));

      expect(
        offset.dx,
        2 * (AppSizes.treeNodeWidth + AppSizes.treeColumnGap),
      );
      expect(offset.dy, 0);
    });

    test('cada fila baja lo que mide una tarjeta y su hueco', () {
      final offset = treeNodeOffset(_node(1, row: 3));

      expect(offset.dx, 0);
      expect(
        offset.dy,
        3 * (AppSizes.treeNodeHeight + AppSizes.treeRowGap),
      );
    });

    test('el lienzo mide lo que ocupa el arbol', () {
      final size = treeCanvasSize(ModelTreeEntity(nodes: [
        _node(1),
        _node(2, column: 1),
        _node(3, row: 1),
      ]));

      expect(
        size.width,
        2 * AppSizes.treeNodeWidth + AppSizes.treeColumnGap,
      );
      expect(
        size.height,
        2 * AppSizes.treeNodeHeight + AppSizes.treeRowGap,
      );
    });

    test('un arbol vacio ocupa una tarjeta, no cero', () {
      // Con cero de ancho el lienzo no se puede desplazar ni recibe toques.
      final size = treeCanvasSize(ModelTreeEntity.empty);

      expect(size.width, AppSizes.treeNodeWidth);
      expect(size.height, AppSizes.treeNodeHeight);
    });
  });

  group('las tarjetas', () {
    testWidgets('se pinta una por nodo, con su nombre', (tester) async {
      await _pump(
        tester,
        ModelTreeEntity(nodes: [
          _node(1, name: 'General'),
          _node(2, column: 1, name: 'Personajes'),
        ]),
      );

      expect(find.byType(TreeNodeCard), findsNWidgets(2));
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Personajes'), findsOneWidget);
    });

    testWidgets('la que no esta entrenada lo dice', (tester) async {
      await _pump(
        tester,
        ModelTreeEntity(nodes: [_node(1, isTrained: false)]),
      );

      // Se salta al reconocer, y con ella todo lo que cuelgue: eso no se ve
      // mirando el arbol si no se dice en la tarjeta.
      expect(find.text('Sin entrenar'), findsOneWidget);
      expect(find.byIcon(Symbols.warning_amber), findsOneWidget);
    });

    testWidgets('pulsarla la elige', (tester) async {
      final tapped = <int>[];
      await _pump(
        tester,
        ModelTreeEntity(nodes: [_node(7)]),
        onNodeTap: tapped.add,
      );

      await tester.tap(find.byType(TreeNodeCard));
      await tester.pump();

      expect(tapped, [7]);
    });

    testWidgets('con el lienzo alejado se queda con el nombre', (tester) async {
      await _pump(
        tester,
        ModelTreeEntity(nodes: [_node(1, isTrained: false)]),
        isSimplified: true,
        onNodeRemove: (_) {},
      );

      // A ese tamano lo demas no se lee y solo emborrona.
      expect(find.text('Sin entrenar'), findsNothing);
      expect(find.byIcon(Symbols.close), findsNothing);
      expect(find.text('Modelo 1'), findsOneWidget);
    });

    testWidgets('se puede sacar del arbol', (tester) async {
      final removed = <int>[];
      await _pump(
        tester,
        ModelTreeEntity(nodes: [_node(3)]),
        onNodeRemove: removed.add,
      );

      await tester.tap(find.byIcon(Symbols.close));
      await tester.pump();

      expect(removed, [3]);
    });
  });

  group('las etiquetas de un mismo padre', () {
    /// Las lineas que pinta el lienzo para un arbol dado.
    List<TreeEdgeLine> linesOf(ModelTreeEntity tree) {
      final lines = <TreeEdgeLine>[];

      for (final edge in tree.edges) {
        final parent = tree.nodeById(edge.parentNodeId)!;
        final child = tree.nodeById(edge.childNodeId)!;

        lines.add(TreeEdgeLine(
          edgeId: edge.id,
          from: Offset(
            treeNodeOffset(parent).dx + AppSizes.treeNodeWidth / 2,
            treeNodeOffset(parent).dy + AppSizes.treeNodeHeight,
          ),
          to: Offset(
            treeNodeOffset(child).dx + AppSizes.treeNodeWidth / 2,
            treeNodeOffset(child).dy,
          ),
        ));
      }

      return lines;
    }

    test('no se amontonan con varios hijos', () {
      // Un padre con cinco hijos: es el caso que se vio de verdad, con las
      // etiquetas unas encima de otras y sin forma de pulsar la que se queria.
      final tree = ModelTreeEntity(
        nodes: [
          _node(1, column: 2),
          for (var id = 2; id <= 6; id++) _node(id, row: 1, column: (id - 2).toDouble()),
        ],
        edges: [
          for (var id = 2; id <= 6; id++)
            ModelTreeEdgeEntity(id: id, parentNodeId: 1, childNodeId: id),
        ],
      );

      final points = [for (final line in linesOf(tree)) line.labelPoint.dx]
        ..sort();

      for (var index = 1; index < points.length; index++) {
        expect(
          points[index] - points[index - 1],
          greaterThanOrEqualTo(treeEdgeLabelMaxWidth),
          reason: 'dos etiquetas se pisan',
        );
      }
    });

    test('cada una cae cerca de su hijo', () {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2, row: 1, column: 3)],
        edges: const [
          ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 2),
        ],
      );

      final line = linesOf(tree).single;

      // Mas cerca del hijo que del padre: es lo que las separa, porque los hijos
      // ya estan separados entre si.
      expect(
        (line.labelPoint.dx - line.to.dx).abs(),
        lessThan((line.labelPoint.dx - line.from.dx).abs()),
      );
    });

    test('la etiqueta y la zona pulsable son el mismo punto', () {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2, row: 1, column: 1)],
        edges: const [
          ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 2),
        ],
      );

      final line = linesOf(tree).single;

      // Lo calcula la propia linea justamente para que no puedan separarse: si
      // el pintor y la zona pulsable no coinciden, se pulsa donde no se ve nada.
      expect(line.labelPoint, Offset.lerp(line.from, line.to, treeEdgeLabelAt));
    });
  });

  group('lo que se puede soltar sobre un nodo', () {
    /// Un lienzo montado a mano, solo para preguntarle que acepta.
    TreeCanvas canvasOf(ModelTreeEntity tree) => TreeCanvas(
          tree: tree,
          onDropOnNode: (_, _) {},
        );

    test('un modelo del panel siempre vale', () {
      final canvas = canvasOf(ModelTreeEntity(nodes: [_node(1)]));

      // Es un nodo nuevo: algo que todavia no esta no puede cerrar un ciclo.
      expect(
        canvas.acceptsOnNode(
          const TreeModelPayload(modelId: 5, name: 'Otro'),
          1,
        ),
        isTrue,
      );
    });

    test('un nodo suelto se puede colgar de otro', () {
      final canvas = canvasOf(ModelTreeEntity(nodes: [_node(1), _node(2)]));

      expect(canvas.acceptsOnNode(const TreeNodePayload(2), 1), isTrue);
    });

    test('sobre si mismo no', () {
      final canvas = canvasOf(ModelTreeEntity(nodes: [_node(1)]));

      expect(canvas.acceptsOnNode(const TreeNodePayload(1), 1), isFalse);
    });

    test('sobre uno de sus descendientes no', () {
      //  1 → 2 → 3, y se intenta colgar el 1 del 3.
      final canvas = canvasOf(ModelTreeEntity(
        nodes: [_node(1), _node(2, row: 1), _node(3, row: 2)],
        edges: const [
          ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 2),
          ModelTreeEdgeEntity(id: 2, parentNodeId: 2, childNodeId: 3),
        ],
      ));

      // Es lo que la zona pinta en rojo: sin decirlo, soltar ahi se ve igual que
      // soltar bien, solo que no pasa nada.
      expect(canvas.acceptsOnNode(const TreeNodePayload(1), 3), isFalse);
    });

    test('sobre el padre que ya tiene no', () {
      final canvas = canvasOf(ModelTreeEntity(
        nodes: [_node(1), _node(2, row: 1)],
        edges: const [
          ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 2),
        ],
      ));

      expect(canvas.acceptsOnNode(const TreeNodePayload(2), 1), isFalse);
    });
  });

  group('las aristas', () {
    testWidgets('se puede tocar la de dos nodos unidos', (tester) async {
      final tapped = <int>[];

      await _pump(
        tester,
        ModelTreeEntity(
          nodes: [_node(1), _node(2, row: 1)],
          edges: const [
            ModelTreeEdgeEntity(id: 9, parentNodeId: 1, childNodeId: 2),
          ],
        ),
        edgeLabels: const {9: 'marinette'},
        onEdgeTap: tapped.add,
      );

      // Una curva de dos pixeles no se acierta con el raton: cada arista lleva
      // su propia zona pulsable **donde esta su etiqueta**, que es cerca del
      // hijo y no en mitad del trazo.
      final origin = tester.getTopLeft(find.byType(TreeCanvas));
      final from = Offset(
        AppSizes.treeNodeWidth / 2,
        AppSizes.treeNodeHeight,
      );
      final to = Offset(
        AppSizes.treeNodeWidth / 2,
        AppSizes.treeNodeHeight + AppSizes.treeRowGap,
      );

      await tester.tapAt(origin + Offset.lerp(from, to, treeEdgeLabelAt)!);
      await tester.pump();

      expect(tapped, [9]);
    });

    testWidgets('una arista a un nodo que no esta no rompe el lienzo',
        (tester) async {
      await _pump(
        tester,
        ModelTreeEntity(
          nodes: [_node(1)],
          edges: const [
            ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 99),
          ],
        ),
        onEdgeTap: (_) {},
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(TreeNodeCard), findsOneWidget);
    });
  });
}
