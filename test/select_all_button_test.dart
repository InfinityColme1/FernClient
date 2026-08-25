// El botón de marcarlo todo, el mismo en contenido y en importación.
//
// Lo que se comprueba es lo que puede salir mal sin verse: que actúe sobre lo
// que hay **a la vista** y no sobre todo lo que hay —marcar lo que no se ve y
// borrarlo después es la clase de sorpresa que no se puede deshacer— y que con
// todo marcado haga lo contrario, que es la única otra cosa que se puede querer.

import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/select_all_button.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _media(int id) =>
    MediaSummaryEntity(id: id, path: 'C:/$id.jpg');

void main() {
  late List<List<int>> sent;

  setUp(() => sent = []);

  Future<void> pump(
    WidgetTester tester, {
    required List<MediaSummaryEntity> visible,
    Set<int> selectedIds = const {},
  }) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SelectAllButton(
          visible: visible,
          selectedIds: selectedIds,
          onSelectAll: sent.add,
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('manda marcar lo que se ve', (tester) async {
    await pump(tester, visible: [_media(1), _media(2)]);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(sent, hasLength(1));
    expect(sent.single, [1, 2]);
  });

  // Lo filtrado se queda fuera: la pantalla le pasa lo que está pintando, no
  // todo lo que tiene.
  testWidgets('sólo lo que se le pasa, no lo que hubiera detrás',
      (tester) async {
    await pump(tester, visible: [_media(7)]);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(sent.single, [7]);
  });

  testWidgets('sin nada a la vista, el botón no hace nada', (tester) async {
    await pump(tester, visible: const []);

    final button = tester.widget<IconButton>(find.byType(IconButton));

    expect(button.onPressed, isNull);
  });

  group('con todo marcado', () {
    testWidgets('el icono dice que va a soltarlo', (tester) async {
      await pump(
        tester,
        visible: [_media(1), _media(2)],
        selectedIds: {1, 2},
      );

      expect(find.byIcon(Icons.deselect), findsOneWidget);
    });

    testWidgets('y con parte marcada, que va a marcarlo', (tester) async {
      await pump(
        tester,
        visible: [_media(1), _media(2)],
        selectedIds: {1},
      );

      expect(find.byIcon(Icons.select_all), findsOneWidget);
    });
  });
}
