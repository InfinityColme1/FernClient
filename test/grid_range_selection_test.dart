// Comprueba mayusculas + clic en las rejillas.
//
// En la rejilla de contenido ya se hacia: el gesto vive en la celda
// (`MediaItem`), y la rejilla normal se lo pasa a todas, asi que las pantallas
// de gestion de etiquetas y de creadores lo tienen por el mismo camino. La de
// fernies no, porque su rejilla es la variante de recortes y esa no lo pasaba.
//
// Aqui se comprueban las dos cosas: que la celda distingue el clic normal del
// clic con mayusculas, y que la rejilla de recortes se lo pasa.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// La rejilla pregunta qué contenidos están señalados por el último aviso de
/// reconocimiento. No hace falta ninguno para esta prueba, pero sin registrarlo
/// la rejilla no se puede ni construir.
void _registerHighlight() {
  if (getIt.isRegistered<RecognitionHighlight>()) return;

  getIt.registerSingleton<RecognitionHighlight>(RecognitionHighlight());
}

const _media = MediaSummaryEntity(id: 1, path: 'no_existe.jpg');
const _crop = RegionCrop(x: 0.1, y: 0.1, w: 0.4, h: 0.4);

Future<void> _pump(WidgetTester tester, Widget child) {
  _registerHighlight();

  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SizedBox(width: 600, height: 600, child: child)),
  ));
}

void main() {
  testWidgets('con mayusculas, la celda estira en vez de abrir', (tester) async {
    var opened = 0;
    var extended = 0;

    await _pump(
      tester,
      Center(
        child: SizedBox(
          width: 200,
          child: MediaItem(
            media: _media,
            onTap: () => opened++,
            onRangeSelectionRequested: () => extended++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MediaItem));
    await tester.pump();

    expect(opened, 1);
    expect(extended, 0);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.byType(MediaItem));
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    // Con mayusculas el clic no abre nada: lo que se esta haciendo es marcar
    // desde el ultimo elemento tocado hasta este.
    expect(opened, 1);
    expect(extended, 1);
  });

  testWidgets('la rejilla de recortes tambien lo pasa', (tester) async {
    MediaCrop? extended;

    await _pump(
      tester,
      MediaGrid.crops(
        crops: const [MediaCrop(id: 7, media: _media, crop: _crop)],
        columns: 2,
        onCropTap: (_) {},
        onCropRangeSelectionRequested: (crop) => extended = crop,
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.byType(MediaItem));
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(extended?.id, 7);
  });
}
