// La fila de un fernie dentro de un modelo: sus avisos y su barra de reparto.
//
// Lo que se comprueba de la barra es que **el reparto siempre suma cien**. Es la
// unica regla que no se puede romper: un reparto que suma noventa deja regiones
// sin destino, y uno que suma ciento diez las mete dos veces.
//
// Y los avisos, porque son lo que evita que alguien entrene veinte minutos para
// nada. El de «pocos contenidos» es el importante: ese fallo **no se ve en las
// metricas** —salen bien— y solo aparece cuando el modelo se usa de verdad.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_split_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

ModelFernieEntity _assignment({
  int regionCount = 200,
  int mediaCount = 20,
  DatasetSplit split = DatasetSplit.balanced,
}) {
  return ModelFernieEntity(
    id: 1,
    modelId: 1,
    fernie: FernieEntity(
      id: 1,
      name: 'Marinette',
      regionCount: regionCount,
      mediaCount: mediaCount,
    ),
    split: split,
    classIndex: 0,
  );
}

Future<void> _pump(
  WidgetTester tester,
  ModelFernieEntity assignment, {
  ValueChanged<DatasetSplit>? onSplitChanged,
  VoidCallback? onRemove,
  double width = 400,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: FernieSplitRow(
            assignment: assignment,
            onSplitChanged: onSplitChanged,
            onRemove: onRemove,
          ),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('dice quien es y cuanto aporta', (tester) async {
    await _pump(tester, _assignment(regionCount: 214, mediaCount: 31));

    expect(find.text('Marinette'), findsOneWidget);
    expect(find.textContaining('214 regiones'), findsOneWidget);
    expect(find.textContaining('31 contenidos'), findsOneWidget);
  });

  testWidgets('ensena el reparto en numeros', (tester) async {
    await _pump(
      tester,
      _assignment(split: const DatasetSplit(train: 80, validation: 15, test: 5)),
    );

    expect(find.text('Entrenar 80%'), findsOneWidget);
    expect(find.text('Validar 15%'), findsOneWidget);
    expect(find.text('Probar 5%'), findsOneWidget);
  });

  group('con un entrenamiento en marcha', () {
    testWidgets('el reparto no se toca', (tester) async {
      // Sin quien lo escuche, la fila se queda de solo lectura: el dataset ya
      // esta montado con lo que habia, y moverlo ahora no cambiaria nada de lo
      // que esta corriendo pero lo pareceria.
      await _pump(tester, _assignment());

      final before = tester
          .widget<FernieSplitRow>(find.byType(FernieSplitRow))
          .assignment
          .split;

      await tester.drag(find.byType(FernieSplitRow), const Offset(-120, 0));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(before, DatasetSplit.balanced);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('y tampoco se saca del modelo', (tester) async {
      await _pump(tester, _assignment());

      expect(find.byIcon(Symbols.close), findsNothing);
    });
  });

  group('los avisos', () {
    testWidgets('con material de sobra no hay ninguno', (tester) async {
      await _pump(tester, _assignment(regionCount: 200, mediaCount: 20));

      expect(find.byIcon(Symbols.warning_amber), findsNothing);
    });

    testWidgets('con muy pocas regiones no da ni para entrenar',
        (tester) async {
      await _pump(tester, _assignment(regionCount: 8, mediaCount: 8));

      expect(
        find.textContaining('Menos de $minRegionsPerClass regiones'),
        findsOneWidget,
      );
    });

    testWidgets('con pocos contenidos aprendera el fondo', (tester) async {
      // Doscientas regiones, pero de dos ficheros: el aviso mas importante de
      // los tres, porque este fallo no se ve en las metricas.
      await _pump(tester, _assignment(regionCount: 200, mediaCount: 2));

      expect(find.textContaining('aprenderá el fondo'), findsOneWidget);
    });

    testWidgets('el de no poder entrenar manda sobre los demas',
        (tester) async {
      await _pump(tester, _assignment(regionCount: 5, mediaCount: 1));

      // Los dos son ciertos, pero de nada sirve avisar de que aprendera el
      // fondo si ni siquiera va a poder entrenar.
      expect(
        find.textContaining('Menos de $minRegionsPerClass regiones'),
        findsOneWidget,
      );
      expect(find.textContaining('aprenderá el fondo'), findsNothing);
    });

    testWidgets('el aviso se lee entero aunque la columna sea estrecha',
        (tester) async {
      // El ancho de la columna de fernies del detalle, que es donde se vio
      // cortado: al lado de los numeros solo cabian cuatro palabras.
      await _pump(
        tester,
        _assignment(regionCount: 200, mediaCount: 2),
        width: 260,
      );

      final paragraph = tester.renderObject<RenderParagraph>(
        find.textContaining('aprenderá el fondo'),
      );

      // Un aviso que explica **por que** el modelo va a salir malo no explica
      // nada cortado con puntos suspensivos.
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.height, greaterThan(paragraph.preferredLineHeight));
    });
  });

  group('la barra', () {
    testWidgets('arrastrar el primer tirador reparte sin perder nada',
        (tester) async {
      final seen = <DatasetSplit>[];
      await _pump(tester, _assignment(), onSplitChanged: seen.add);

      // El rectangulo de la barra, no el de la fila entera: el centro de la
      // fila cae en el avatar.
      final bar = tester.getRect(find.byType(GestureDetector));

      // Se agarra por donde cae el primer tirador (70 %) y se lleva a la
      // izquierda.
      await tester.dragFrom(
        Offset(bar.left + bar.width * 0.7, bar.center.dy),
        Offset(-bar.width * 0.2, 0),
      );
      await tester.pumpAndSettle();

      expect(seen, isNotEmpty);

      for (final split in seen) {
        expect(split.total, 100, reason: 'un reparto que no suma cien: $split');
        expect(split.isValid, isTrue);
      }

      expect(seen.last.train, lessThan(70));
    });

    testWidgets('mientras se arrastra se mueve solo, sin avisar a nadie',
        (tester) async {
      final seen = <DatasetSplit>[];
      await _pump(tester, _assignment(), onSplitChanged: seen.add);

      final bar = tester.getRect(find.byType(GestureDetector));
      final drag = await tester.startGesture(
        Offset(bar.left + bar.width * 0.7, bar.center.dy),
      );

      await drag.moveBy(Offset(-bar.width * 0.2, 0));
      await tester.pump();

      // Ya se ve movido...
      expect(find.text('Entrenar 70%'), findsNothing);
      expect(find.text('Entrenar 50%'), findsOneWidget);

      // ...pero todavia no se ha guardado nada. Guardar en cada movimiento del
      // raton escribe en la base de datos decenas de veces por segundo y deja
      // el tirador arrastrandose detras del dedo.
      expect(seen, isEmpty);

      await drag.up();
      await tester.pumpAndSettle();

      // Al soltar, una sola vez.
      expect(seen, hasLength(1));
      expect(seen.single.train, 50);
    });

    testWidgets('nunca se sale de los limites', (tester) async {
      final seen = <DatasetSplit>[];
      await _pump(tester, _assignment(), onSplitChanged: seen.add);

      final bar = tester.getRect(find.byType(GestureDetector));

      // Muy a la izquierda: mas alla del cero.
      await tester.dragFrom(
        Offset(bar.left + bar.width * 0.7, bar.center.dy),
        Offset(-bar.width * 2, 0),
      );
      await tester.pumpAndSettle();

      for (final split in seen) {
        expect(split.train, greaterThanOrEqualTo(0));
        expect(split.validation, greaterThanOrEqualTo(0));
        expect(split.test, greaterThanOrEqualTo(0));
        expect(split.total, 100);
      }
    });

    testWidgets('sin a quien avisar, no se puede arrastrar', (tester) async {
      await _pump(tester, _assignment());

      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  testWidgets('se puede sacar del modelo', (tester) async {
    var removed = 0;
    await _pump(tester, _assignment(), onRemove: () => removed++);

    await tester.tap(find.byIcon(Symbols.close));
    await tester.pump();

    expect(removed, 1);
  });
}
