// El diálogo que cuenta qué hicieron los modelos.
//
// Lo que se comprueba es que cada modelo se reconoce **de un vistazo**: el log
// es una lista de nombres parecidos —«Figuras de prueba», «Formas nuevas»— y
// leerlos uno a uno para encontrar el que interesa es justo lo que el árbol
// evita poniéndoles cara.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/recognition_log_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RecognitionLogEntry _entry({
  required int modelId,
  required String name,
  String? picturePath,
  RecognitionVerdict verdict = RecognitionVerdict.proposed,
  List<RecognitionSighting> sightings = const [],
}) {
  return RecognitionLogEntry(
    modelId: modelId,
    modelName: name,
    picturePath: picturePath,
    verdict: verdict,
    threshold: 0.35,
    sightings: sightings,
  );
}

void main() {
  /// El diálogo tal y como se abre de verdad, dentro de su `FernDialog`.
  Future<void> openReal(
    WidgetTester tester,
    List<MediaRecognitionLog> logs, {
    Size screen = const Size(1280, 720),
  }) async {
    await tester.binding.setSurfaceSize(screen);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Con `showDialog` y no dentro de un `Scaffold`: el diálogo se abre en el
    // overlay, donde el alto disponible es el de la pantalla entera y nadie lo
    // acota por él. Montarlo dentro de un `Scaffold` lo acota de balde y esconde
    // justo el fallo que esto vigila.
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: const [AppColors.dark]),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => RecognitionLogDialog(logs: logs),
          ),
          child: const Text('abrir'),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, List<RecognitionLogEntry> models) {
    return tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RecognitionLogDialog(
          logs: [
            MediaRecognitionLog(
              mediaId: 1,
              name: 'img-000.jpg',
              models: models,
              at: DateTime(2026),
            ),
          ],
        ),
      ),
    ));
  }

  group('la cara de cada modelo', () {
    testWidgets('cada modelo lleva la suya', (tester) async {
      await open(tester, [
        _entry(modelId: 1, name: 'Figuras', picturePath: 'C:/caras/uno.png'),
        _entry(modelId: 2, name: 'Formas', picturePath: 'C:/caras/dos.png'),
      ]);

      final avatars = tester
          .widgetList<FernAvatar>(find.byType(FernAvatar))
          .map((one) => one.imagePath)
          .toList();

      expect(avatars, ['C:/caras/uno.png', 'C:/caras/dos.png']);
    });

    testWidgets('un modelo sin cara no rompe la fila', (tester) async {
      await open(tester, [_entry(modelId: 1, name: 'Sin cara')]);

      expect(find.byType(FernAvatar), findsOneWidget);
      expect(find.text('Sin cara'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el nombre sigue estando, no lo sustituye', (tester) async {
      // La cara es para encontrarlo rápido, no para adivinarlo: dos modelos con
      // la misma imagen y distinto nombre son dos cosas distintas.
      await open(tester, [
        _entry(modelId: 1, name: 'Figuras', picturePath: 'C:/caras/uno.png'),
      ]);

      expect(find.text('Figuras'), findsOneWidget);
    });
  });

  group('qué dijo cada uno', () {
    testWidgets('lo que vio se cuelga del modelo', (tester) async {
      await open(tester, [
        _entry(
          modelId: 1,
          name: 'Figuras',
          sightings: const [
            RecognitionSighting(fernieId: 1, fernieName: 'Rombo', confidence: 0.9),
            RecognitionSighting(fernieId: 2, fernieName: 'Cubo', confidence: 0.2),
          ],
        ),
      ]);

      expect(find.text('Rombo · 90 %'), findsOneWidget);
      expect(find.text('Cubo · 20 %'), findsOneWidget);
    });

    testWidgets('lo que no llegó al listón va tachado', (tester) async {
      await open(tester, [
        _entry(
          modelId: 1,
          name: 'Figuras',
          verdict: RecognitionVerdict.belowThreshold,
          sightings: const [
            RecognitionSighting(fernieId: 2, fernieName: 'Cubo', confidence: 0.2),
          ],
        ),
      ]);

      // Se ve de un vistazo que el modelo **sí** reconoció algo y que lo que
      // falló fue el listón, que es lo único que el usuario puede mover.
      final text = tester.widget<Text>(find.text('Cubo · 20 %'));

      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('el que no corrió lo dice', (tester) async {
      await open(tester, [
        _entry(
          modelId: 1,
          name: 'Variantes',
          verdict: RecognitionVerdict.notReached,
        ),
      ]);

      // No es un fallo, es el árbol haciendo su trabajo. Pero desde fuera es
      // idéntico a que el modelo haya fallado.
      expect(find.text('no corrió: su rama no se abrió'), findsOneWidget);
    });
  });

  group('cuando hay muchos', () {
    /// Un lote de [count] contenidos, cada uno con tres modelos que han visto
    /// cosas: es el parte de «reconocer la biblioteca», que es donde esto se
    /// usa de verdad.
    List<MediaRecognitionLog> lote(int count) => [
          for (var id = 0; id < count; id++)
            MediaRecognitionLog(
              mediaId: id,
              name: 'img-$id.jpg',
              models: [
                for (var model = 1; model <= 3; model++)
                  _entry(
                    modelId: model,
                    name: 'Modelo $model',
                    sightings: const [
                      RecognitionSighting(
                          fernieId: 1, fernieName: 'Rombo', confidence: 0.9),
                      RecognitionSighting(
                          fernieId: 2, fernieName: 'Cubo', confidence: 0.2),
                    ],
                  ),
              ],
              at: DateTime(2026),
            ),
        ];

    testWidgets('la lista larga cabe', (tester) async {
      await openReal(tester, lote(40));

      // Sin tope de alto el diálogo crece hasta salirse de la pantalla, y lo
      // que se ve es la franja de desbordamiento.
      expect(tester.takeException(), isNull);
    });

    testWidgets('desplegar uno no la desborda', (tester) async {
      await openReal(tester, lote(40));

      await tester.tap(find.text('img-0.jpg'));
      await tester.pumpAndSettle();

      // Lo desplegado son tres modelos con dos detecciones cada uno: si el
      // diálogo no cede, eso es lo que se sale por abajo.
      expect(tester.takeException(), isNull);
    });

    testWidgets('con la ventana baja tampoco', (tester) async {
      await openReal(tester, lote(40), screen: const Size(1280, 400));

      await tester.tap(find.text('img-0.jpg'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('lo que no cabe se puede desplazar', (tester) async {
      await openReal(tester, lote(40));

      // Que quepa no puede significar que se pierda: lo de más abajo tiene que
      // estar a un desplazamiento de distancia.
      expect(find.byType(Scrollable), findsWidgets);
    });
  });
}
