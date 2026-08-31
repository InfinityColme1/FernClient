// El botón de quitar de la píldora, el que lleva cada etiqueta elegida en el
// diálogo de asignación.
//
// Se monta el widget de verdad: la píldora no necesita ni base de datos ni
// blocs, recibe el texto y qué hacer al quitarla.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:Fern/core/ui/display/fern_chip.dart';
import 'package:Fern/core/ui/display/nsfw_tag_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Future<void> _pumpChip(WidgetTester tester, {VoidCallback? onRemove}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(child: FernChip(label: 'Miraculous', onRemove: onRemove)),
    ),
  ));
}

void main() {
  testWidgets('sin nada que hacer al quitarla no lleva botón', (tester) async {
    await _pumpChip(tester);

    expect(find.text('Miraculous'), findsOneWidget);
    expect(find.byIcon(Symbols.cancel), findsNothing);
  });

  testWidgets('el botón de quitar avisa al pulsarlo', (tester) async {
    var removed = 0;
    await _pumpChip(tester, onRemove: () => removed++);

    expect(find.byIcon(Symbols.cancel), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.cancel));
    await tester.pump();

    expect(removed, 1);
  });

  // La píldora del panel del contenido lleva ahora lo más que puede llevar:
  // avatar, nombre, la marca NSFW y la cruz. El panel es estrecho (350) y el
  // nombre de una etiqueta puede ser largo, así que es donde se desborda si se
  // desborda.
  group('la fila más cargada del panel', () {
    Future<Object?> pumpFull(WidgetTester tester, String label) async {
      await tester.pumpWidget(const SizedBox.shrink());
      tester.takeException();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(
            width: AppSizes.infoPanelWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FernChip.plain(
                label: label,
                leading: const FernAvatar(
                  fallbackIcon: Symbols.label,
                  radius: AppSizes.avatarMedium,
                  iconSize: AppSizes.iconMedium,
                ),
                trailing: const NsfwTagMark(),
                onRemove: () {},
              ),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      return tester.takeException();
    }

    testWidgets('con un nombre normal, cabe', (tester) async {
      expect(await pumpFull(tester, 'Miraculous'), isNull);
    });

    testWidgets('y con uno larguisimo tambien', (tester) async {
      expect(
        await pumpFull(
          tester,
          'Marinette Dupain-Cheng de Paris y sus alrededores conocidos',
        ),
        isNull,
      );
    });

    testWidgets('la cruz sigue siendo pulsable con la marca al lado',
        (tester) async {
      var removed = 0;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: FernChip.plain(
              label: 'Miraculous',
              trailing: const NsfwTagMark(),
              onRemove: () => removed++,
            ),
          ),
        ),
      ));

      await tester.tap(find.byIcon(Symbols.cancel));
      await tester.pump();

      expect(removed, 1);
    });
  });
}
