// El filtro de la cabecera de la pantalla de media.
//
// Lo que decide el filtro es qué grupos de la búsqueda se pintan, así que se
// comprueba sobre el estado: los grupos que ha encontrado el buscador se quedan
// enteros y lo único que cambia es cuáles pasan el filtro, que es lo que hace que
// volver a encender un tipo lo devuelva a la rejilla.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _media(int id) =>
    MediaSummaryEntity(id: id, path: 'media_$id.png', isImported: true);

/// Un grupo de cada tipo, como los que devuelve una búsqueda por texto.
final _sections = [
  MediaSearchSectionEntity(
    type: SearchResultType.media,
    title: 'montaña',
    media: [_media(1)],
  ),
  MediaSearchSectionEntity(
    type: SearchResultType.tag,
    title: 'Paisajes',
    media: [_media(2)],
  ),
  MediaSearchSectionEntity(
    type: SearchResultType.creator,
    title: 'Ansel',
    media: [_media(3)],
  ),
];

void main() {
  test('de partida se ven los tres tipos', () {
    final state = MediaLoading(searchSections: _sections);

    expect(state.searchFilters, allSearchResultTypes);
    expect(state.visibleSearchSections, _sections);
  });

  test('apagar un tipo deja fuera su grupo, no lo pierde', () {
    final state = MediaLoading(searchSections: _sections).copyWith(
      searchFilters: const {SearchResultType.media, SearchResultType.creator},
    );

    expect(
      state.visibleSearchSections?.map((section) => section.type),
      [SearchResultType.media, SearchResultType.creator],
    );
    // El grupo de etiquetas sigue en el estado: volver a encenderlo lo recupera
    // sin repetir la búsqueda.
    expect(state.searchSections, _sections);
  });

  test('con los tres apagados no queda nada que pintar', () {
    final state =
        MediaLoading(searchSections: _sections).copyWith(searchFilters: const {});

    expect(state.visibleSearchSections, isEmpty);
  });

  test('sin búsqueda el filtro no tiene nada que recortar', () {
    final state = MediaLoading(mediaList: [_media(1)]).copyWith(
      searchFilters: const {SearchResultType.tag},
    );

    expect(state.visibleSearchSections, isNull);
  });

  // El panel del filtro es un FernPopupPanel con casillas dentro: al contrario
  // que el desplegable de acciones, tiene que aguantar abierto mientras se
  // marcan y se desmarcan, que es lo que permite tocar varios tipos de una vez.
  testWidgets('el panel aguanta abierto al marcar una casilla', (tester) async {
    bool checked = true;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => FernPopupPanel(
            children: [
              FernCheckboxTile(
                label: 'Tags',
                value: checked,
                onChanged: (value) => setState(() => checked = value),
              ),
            ],
            builder: (context, toggle) =>
                TextButton(onPressed: toggle, child: const Text('Filters')),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Tags'), findsOneWidget);

    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();

    expect(checked, isFalse);
    expect(find.text('Tags'), findsOneWidget);
  });
}
