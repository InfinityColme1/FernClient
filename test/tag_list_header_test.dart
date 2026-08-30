// La cabecera de la lista de etiquetas, ahora que lleva un botón al lado.
//
// La lista vive en una columna estrecha (`AppSizes.tagListWidth`, 260) y el
// botón que lleva a la otra lista le come sitio al título. En francés los
// rótulos son los más largos de los cuatro idiomas, así que es ahí donde se
// desborda si se desborda.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas de
// medidas: sin ella se mide con la fuente de pruebas, en la que cada letra es un
// cuadrado, y los textos salen mucho más anchos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

/// Una ventana de portátil sin maximizar.
const _laptopHeight = 600.0;

final _tags = [
  const TagEntity(id: 1, name: 'Paisajes', children: []),
  const TagEntity(id: 2, name: 'Marinette', children: [], isPerson: true),
];

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

Future<Object?> _pumpAt(
  WidgetTester tester, {
  required Locale locale,
  required bool showsPeople,
}) async {
  tester.view.physicalSize = const Size(1000, _laptopHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // El árbol se tira abajo antes de cada medida: reaprovechando los render
  // objects, el aviso de desbordamiento sólo se da la primera vez.
  await tester.pumpWidget(const SizedBox.shrink());
  tester.takeException();

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        // El ancho de verdad de la columna, no uno cómodo.
        width: AppSizes.tagListWidth,
        height: _laptopHeight,
        child: TagList(
          tags: _tags,
          onSelected: (_) {},
          showsPeople: showsPeople,
          onSwitchList: () {},
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 400));

  return tester.takeException();
}

void main() {
  setUpAll(_loadAppFont);

  for (final showsPeople in [false, true]) {
    final which = showsPeople ? 'personas' : 'etiquetas';

    testWidgets('la cabecera de $which no desborda con el botón',
        (tester) async {
      for (final locale in _locales) {
        final overflow = await _pumpAt(
          tester,
          locale: locale,
          showsPeople: showsPeople,
        );

        expect(
          overflow,
          isNull,
          reason: 'la cabecera de $which desborda en ${locale.languageCode}',
        );
      }
    });
  }

  testWidgets('el botón cabe entero junto al título', (tester) async {
    await _pumpAt(tester, locale: const Locale('fr'), showsPeople: false);

    final button = tester.getRect(find.byType(IconButton).first);

    expect(button.right, lessThanOrEqualTo(AppSizes.tagListWidth));
    expect(button.width, greaterThan(0));
  });
}
