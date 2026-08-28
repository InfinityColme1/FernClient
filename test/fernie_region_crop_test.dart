// Comprueba que una celda con recorte enseña la región y no el fichero entero.
//
// Es la rejilla de la pantalla de fernies: cada celda es una región marcada, así
// que tiene que tomar la forma de la región y pintar sólo ese trozo. Lo que se
// mide aquí es cómo se coloca la imagen, no lo que se ve: sin fichero de verdad
// no hay píxeles que mirar, pero sí hay geometría que comprobar, y es en la
// geometría donde está el fallo que dejaría las regiones descuadradas.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _media = MediaSummaryEntity(id: 1, path: 'no_existe.jpg');

/// Monta una celda de [width] de ancho, con recorte o sin él.
Future<void> _pumpItem(
  WidgetTester tester, {
  required double width,
  RegionCrop? crop,
  String? warning,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MediaItem(media: _media, crop: crop, warning: warning),
        ),
      ),
    ),
  ));
}

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetDevicePixelRatio);
  });

  testWidgets('sin recorte la celda no cambia de comportamiento',
      (tester) async {
    await _pumpItem(tester, width: 200);

    // Sin recorte no hay nada que desbordar: la imagen se encaja en la celda,
    // que es el comportamiento de siempre.
    expect(find.byType(OverflowBox), findsNothing);
  });

  testWidgets('con recorte la imagen se amplía y se desplaza al trozo',
      (tester) async {
    // Un cuarto de la imagen, empezando por su centro.
    const crop = RegionCrop(x: 0.5, y: 0.5, w: 0.25, h: 0.25);

    await _pumpItem(tester, width: 200, crop: crop);

    final overflow = tester.widget<OverflowBox>(find.byType(OverflowBox));

    // Para que un cuarto del ancho llene los 200 de la celda, la imagen entera
    // tiene que medir cuatro veces eso.
    final fullWidth = overflow.maxWidth!;

    expect(fullWidth, closeTo(200 / crop.w, 0.01));
    expect(overflow.minWidth, fullWidth,
        reason: 'la imagen va a tamaño fijo, no encajada en la celda');

    // Y desplazarse hasta que la esquina de la región quede en la de la celda.
    //
    // Se busca el que cuelga del desbordamiento: la celda lleva además el
    // `Transform` del zoom que hace al pasar el ratón por encima.
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(OverflowBox),
            matching: find.byType(Transform),
          )
          .first,
    );
    final offset = transform.transform.getTranslation();

    expect(offset.x, closeTo(-crop.x * fullWidth, 0.01));
  });

  testWidgets('la celda se recorta a lo que se le pide', (tester) async {
    await _pumpItem(
      tester,
      width: 200,
      crop: const RegionCrop(x: 0.1, y: 0.1, w: 0.3, h: 0.3),
    );

    // Sin el recorte, la imagen ampliada se saldría por encima de las celdas de
    // al lado.
    expect(find.byType(ClipRect), findsWidgets);
    expect(tester.getSize(find.byType(MediaItem)).width, 200);
  });

  testWidgets('el contenido pendiente de revisar lleva su aviso',
      (tester) async {
    const message = 'no se usará para entrenar';

    await _pumpItem(
      tester,
      width: 200,
      crop: const RegionCrop(x: 0.1, y: 0.1, w: 0.3, h: 0.3),
      warning: message,
    );

    expect(find.byIcon(Symbols.warning_amber), findsOneWidget);

    // El aviso se lee al pasar el ratón, así que va en un tooltip y no en un
    // texto suelto: la celda es pequeña y una frase entera no cabría.
    //
    // Se busca el del icono de aviso: el botón de seleccionar tiene el suyo.
    final tooltip = tester.widget<Tooltip>(
      find.ancestor(
        of: find.byIcon(Symbols.warning_amber),
        matching: find.byType(Tooltip),
      ),
    );
    expect(tooltip.message, message);
  });

  testWidgets('sin aviso la celda no pinta ningún distintivo', (tester) async {
    await _pumpItem(
      tester,
      width: 200,
      crop: const RegionCrop(x: 0.1, y: 0.1, w: 0.3, h: 0.3),
    );

    expect(find.byIcon(Symbols.warning_amber), findsNothing);
  });

  testWidgets('una región degenerada no revienta la celda', (tester) async {
    await _pumpItem(
      tester,
      width: 200,
      crop: const RegionCrop(x: 0, y: 0, w: 0, h: 0),
    );

    // Nada que ampliar: la celda se queda con su hueco y no intenta pintar una
    // imagen de tamaño infinito.
    expect(tester.takeException(), isNull);
    expect(find.byType(OverflowBox), findsNothing);
  });
}
