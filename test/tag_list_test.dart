// La lista de etiquetas de la pantalla de gestión de etiquetas.
//
// Se monta el widget de verdad (no necesita base de datos ni blocs: recibe las
// etiquetas ya leídas) al ancho que le da la pantalla, que es el que hace que un
// nombre largo pueda desbordar la fila.

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dos raíces, una de ellas con hija y nieta, y un nombre desmedido para
/// comprobar el recorte.
const _longName = 'Una etiqueta con un nombre larguísimo que no cabe de ninguna manera';

final _tags = [
  TagEntity(
    id: 1,
    name: 'Paisajes',
    children: [
      TagEntity(
        id: 2,
        name: 'Montaña',
        children: [TagEntity(id: 3, name: _longName, children: const [])],
      ),
    ],
  ),
  const TagEntity(id: 4, name: 'Retratos', children: []),
];

Future<void> _pumpList(
  WidgetTester tester, {
  int? selectedTagId,
  ValueChanged<TagEntity>? onSelected,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: AppSizes.tagListWidth,
            child: TagList(
              tags: _tags,
              selectedTagId: selectedTagId,
              onSelected: onSelected ?? (_) {},
            ),
          ),
        ],
      ),
    ),
  ));
}

void main() {
  test('las etiquetas se aplanan madres antes que hijas, con su nivel', () {
    final rows = TagList.flatten(_tags);

    expect(
      rows.map((row) => (row.tag.id, row.depth)),
      [(1, 0), (2, 1), (3, 2), (4, 0)],
    );
  });

  testWidgets('un nombre largo se recorta en vez de desbordar la fila',
      (tester) async {
    await _pumpList(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final name = tester.widget<Text>(find.text(_longName));
    expect(name.overflow, TextOverflow.ellipsis);
    expect(name.maxLines, 1);
  });

  testWidgets('pulsar una etiqueta avisa de cuál es', (tester) async {
    TagEntity? tapped;
    await _pumpList(tester, onSelected: (tag) => tapped = tag);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retratos'));

    expect(tapped?.id, 4);
  });
}
