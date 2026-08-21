// Que dice la tarjeta de un modelo.
//
// Son cuatro cosas de un vistazo: quien es, que pregunta responde, cuanto
// material tiene y **si sirve ya para algo**. Lo que se comprueba aqui es
// sobre todo lo segundo, porque es donde hay una trampa: un clasificatorio con
// un solo fernie **no clasifica**, y la tarjeta tiene que decir lo que el modelo
// hace, no lo que el usuario eligio en su dia.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/model_card.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RecognitionModelEntity _model({
  String name = 'Personajes',
  ModelFunction function = ModelFunction.boolean,
  int fernieCount = 2,
  int regionCount = 200,
  String? weightsPath,
  String? lastError,
  bool isTraining = false,
}) {
  return RecognitionModelEntity(
    id: 1,
    name: name,
    function: function,
    fernieCount: fernieCount,
    regionCount: regionCount,
    weightsPath: weightsPath,
    lastError: lastError,
    isTraining: isTraining,
    createdAt: DateTime(2026),
  );
}

Future<void> _pump(
  WidgetTester tester,
  RecognitionModelEntity model, {
  double? progress,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          // Las medidas de verdad, no unas inventadas: si la tarjeta no cabe en
          // su celda, esta prueba tiene que enterarse antes que el usuario.
          width: modelCardWidth,
          height: modelCardHeight,
          child: ModelCard(
            model: model,
            progress: progress,
            onTap: onTap,
            onDelete: onDelete,
          ),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('dice quien es y con cuanto cuenta', (tester) async {
    await _pump(tester, _model(fernieCount: 3, regionCount: 214));

    expect(find.text('Personajes'), findsOneWidget);
    expect(find.textContaining('3 fernies'), findsOneWidget);
    expect(find.textContaining('214 regiones'), findsOneWidget);
  });

  testWidgets('un fernie solo se escribe en singular', (tester) async {
    await _pump(tester, _model(fernieCount: 1, regionCount: 1));

    expect(find.textContaining('1 fernie ·'), findsOneWidget);
    expect(find.textContaining('1 región'), findsOneWidget);
  });

  group('la funcion que se ensena', () {
    testWidgets('un clasificatorio con dos fernies clasifica', (tester) async {
      await _pump(
        tester,
        _model(function: ModelFunction.classification, fernieCount: 2),
      );

      expect(find.text('¿Cuál es?'), findsOneWidget);
    });

    testWidgets('con uno solo dice lo que de verdad hace', (tester) async {
      await _pump(
        tester,
        _model(function: ModelFunction.classification, fernieCount: 1),
      );

      // Clasificar entre una sola opcion no es clasificar: la tarjeta ensena lo
      // que el modelo hace, no lo que se eligio, y lo marca para que no parezca
      // que se ha cambiado solo.
      expect(find.text('¿Está? *'), findsOneWidget);
      expect(find.text('¿Cuál es?'), findsNothing);
    });
  });

  group('el estado', () {
    testWidgets('sin pesos, sin entrenar', (tester) async {
      await _pump(tester, _model());

      expect(find.text('Sin entrenar'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('con pesos, listo', (tester) async {
      await _pump(tester, _model(weightsPath: 'C:/runs/best.pt'));

      expect(find.text('Listo'), findsOneWidget);
    });

    testWidgets('entrenando ensena por donde va', (tester) async {
      await _pump(tester, _model(isTraining: true), progress: 0.34);

      expect(find.text('Entrenando'), findsOneWidget);

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Una barra que avanza y una que da vueltas no dicen lo mismo: con las
      // epocas contadas se sabe cuanto queda.
      expect(bar.value, 0.34);
    });

    testWidgets('sin saber cuanto queda, la barra da vueltas', (tester) async {
      await _pump(tester, _model(isTraining: true));

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(bar.value, isNull);
    });

    testWidgets('un fallo manda sobre los pesos viejos', (tester) async {
      await _pump(
        tester,
        _model(weightsPath: 'C:/runs/best.pt', lastError: 'OUT_OF_MEMORY'),
      );

      // Sigue habiendo con que reconocer, pero lo ultimo que se intento se
      // rompio y callarlo haria pensar que el modelo esta al dia.
      expect(find.text('El entrenamiento falló'), findsOneWidget);
    });

    testWidgets('entrenando manda sobre todo lo demas', (tester) async {
      await _pump(
        tester,
        _model(
          weightsPath: 'C:/runs/best.pt',
          lastError: 'OUT_OF_MEMORY',
          isTraining: true,
        ),
      );

      expect(find.text('Entrenando'), findsOneWidget);
    });
  });

  group('borrar', () {
    testWidgets('el boton solo esta con el cursor encima', (tester) async {
      var deleted = 0;
      await _pump(tester, _model(), onDelete: () => deleted++);

      // Una papelera permanente en cada tarjeta invita a pulsarla sin querer, y
      // aqui lo que se borra no vuelve.
      await tester.tap(find.byIcon(Icons.delete_outline), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(deleted, 0);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byType(ModelCard)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(deleted, 1);
    });

    testWidgets('sin a quien avisar, no hay boton', (tester) async {
      await _pump(tester, _model());

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('el cursor encima remarca la tarjeta', (tester) async {
      await _pump(tester, _model(), onDelete: () {});

      BoxBorder? borderNow() {
        // El que envuelve a la superficie, que es el que lleva la silueta: hay
        // mas AnimatedContainer dentro de la tarjeta.
        final container = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(FernSurface),
            matching: find.byType(AnimatedContainer),
          ),
        );

        return (container.decoration! as BoxDecoration).border;
      }

      expect(borderNow()?.top.color, Colors.transparent);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byType(ModelCard)));
      await tester.pumpAndSettle();

      expect(borderNow()?.top.color, isNot(Colors.transparent));
    });
  });

  testWidgets('se puede pulsar', (tester) async {
    var taps = 0;
    await _pump(tester, _model(), onTap: () => taps++);

    await tester.tap(find.byType(ModelCard));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('el cursor dice que se pulsa', (tester) async {
    await _pump(tester, _model(), onTap: () {});

    final inkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(ModelCard), matching: find.byType(InkWell)),
    );

    // Sin esto el cursor sigue siendo la flecha de siempre y la tarjeta no
    // parece pulsable, por mucho que se remarque al pasar por encima.
    expect(inkWell.mouseCursor, isNotNull);
  });
}
