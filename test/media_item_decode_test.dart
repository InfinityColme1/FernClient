// Comprueba que reescalar la ventana no apaga y enciende las imágenes de la
// rejilla.
//
// La celda descodifica cada imagen al tamaño en el que la va a pintar, y ese
// tamaño es la clave con la que se guarda. Si siguiera al ancho exacto de la
// celda, cada fotograma de un reescalado pediría una imagen distinta, habría
// que volver al disco y la celda se quedaría en blanco mientras tanto: eso es
// el parpadeo. Aquí se comprueban las dos cosas que lo evitan.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una imagen que no está: lo que se mide es con qué parámetros se pide, no lo
/// que se pinta, así que basta con que la celda intente cargarla.
const _media = MediaSummaryEntity(id: 1, path: 'no_existe.jpg');

Future<Image> _pumpItemAt(WidgetTester tester, double width) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: const MediaItem(media: _media),
        ),
      ),
    ),
  ));

  return tester.widget<Image>(find.byType(Image));
}

void main() {
  setUp(() {
    // Con la escala a 1 el ancho de descodificación se lee directamente en los
    // píxeles lógicos de la celda.
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetDevicePixelRatio);
  });

  testWidgets('la imagen no se apaga al cambiar de resolución', (tester) async {
    final image = await _pumpItemAt(tester, 200);

    expect(image.gaplessPlayback, isTrue,
        reason: 'sin esto la celda se queda en blanco mientras descodifica');
  });

  testWidgets('el ancho de descodificación va a saltos', (tester) async {
    // Dos anchos del mismo salto: la imagen que se pide es la misma, así que no
    // hay que volver al disco.
    final narrow = await _pumpItemAt(tester, 200);
    final slightlyWider = await _pumpItemAt(tester, 210);

    expect(narrow.width, isNull); // el ancho lo pone la celda, no el widget
    expect(slightlyWider.image, equals(narrow.image),
        reason: 'un cambio de ancho pequeño no debería pedir otra imagen');

    // Y cuando el salto se agota, sube: la resolución sigue a la celda.
    final wide = await _pumpItemAt(tester, 400);

    expect(wide.image, isNot(equals(narrow.image)));
  });

  testWidgets('el salto redondea hacia arriba, nunca por debajo del tamaño real',
      (tester) async {
    const width = 200.0;
    final image = await _pumpItemAt(tester, width);
    final decodeWidth = (image.image as ResizeImage).width!;

    expect(decodeWidth, greaterThanOrEqualTo((width * mediaHoverScale).ceil()));
    expect(decodeWidth % mediaDecodeWidthStep, 0);
  });
}
