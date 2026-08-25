// El margen interior de la rejilla.
//
// Dentro de una superficie redondeada, la curva muerde las celdas de las
// esquinas: con un radio de 43 y 8 de margen, el mordisco se ve. Fuera de la
// superficie no hay curva que valga y el margen de más se notaría al revés, con
// la rejilla despegada del borde en las pantallas de gestión.

import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una celda cualquiera: lo que se mide es el margen de la rejilla, no lo que
/// se pinta dentro.
const _crop = MediaCrop(
  id: 1,
  media: MediaSummaryEntity(id: 1, path: 'no_existe.jpg'),
  crop: RegionCrop(x: 0, y: 0, w: 1, h: 1),
);

Future<EdgeInsets> _insetOf(WidgetTester tester, {required bool hasSurface}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: MediaGrid.crops(
        crops: const [_crop],
        columns: 4,
        hasSurface: hasSurface,
      ),
    ),
  ));

  final grid = tester.widget<MasonryGridView>(find.byType(MasonryGridView));

  return grid.padding! as EdgeInsets;
}

void main() {
  // La rejilla pregunta si hay contenido señalado por el último reconocimiento.
  // Aquí no lo hay, pero tiene que haber alguien a quien preguntar.
  setUp(() {
    getIt.registerSingleton<RecognitionHighlight>(RecognitionHighlight());
    addTearDown(getIt.reset);
  });

  testWidgets('sobre una superficie, se aparta de la curva', (tester) async {
    final inset = await _insetOf(tester, hasSurface: true);

    expect(inset, const EdgeInsets.all(AppSpacing.gridInset));
  });

  testWidgets('sin superficie, el margen de siempre', (tester) async {
    final inset = await _insetOf(tester, hasSurface: false);

    expect(inset, const EdgeInsets.all(AppSpacing.s));
  });

  test('el margen con superficie es mayor que el hueco entre celdas', () {
    // Es lo que hace que la curva no muerda: si alguien iguala las dos
    // constantes, esto vuelve a estar roto y aquí se nota.
    expect(AppSpacing.gridInset, greaterThan(AppSpacing.s));
  });
}
