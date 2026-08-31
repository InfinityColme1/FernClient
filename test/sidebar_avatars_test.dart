// Los avatares de la lista de etiquetas del menú lateral.
//
// Se monta el botón de verdad, que es quien decide entre la imagen y el icono;
// que el ajuste llegue hasta aquí o no es cosa del menú, y lo que se prueba
// aquí es lo que se ve cuando llega.

import 'dart:convert';
import 'dart:io';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:Fern/core/widgets/collapsing_list_tile_widget.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

/// Un PNG de un píxel, para que la ruta del avatar apunte a una imagen que
/// existe de verdad.
const _pixelPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  late Directory directory;
  late File picture;
  late AnimationController controller;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_sidebar_test');
    picture = await File(p.join(directory.path, 'avatar.png'))
        .writeAsBytes(base64Decode(_pixelPng));

    controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 100),
    );
  });

  tearDown(() async {
    controller.dispose();
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    String? avatarPath,
    bool isExpanded = true,
    bool hasChildren = false,
    bool isCollapsed = false,
    VoidCallback? onToggleCollapse,
    String title = 'Miraculous',
    Locale locale = const Locale('es'),
  }) {
    return tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CollapsingListTile(
          title: title,
          icon: Symbols.sell,
          avatarPath: avatarPath,
          isExpanded: isExpanded,
          hasChildren: hasChildren,
          isCollapsed: isCollapsed,
          onToggleCollapse: onToggleCollapse,
          animationController: controller,
          iconSize: AppSizes.iconLarge,
          textStyle: const TextStyle(),
          selectedColor: Colors.blue,
          textSelectedColor: Colors.black,
          unselectedColor: Colors.white,
          textUnselectedColor: Colors.grey,
        ),
      ),
    ));
  }

  testWidgets('sin avatar el botón se queda con su icono', (tester) async {
    await pumpTile(tester);

    expect(find.byIcon(Symbols.sell), findsOneWidget);
    expect(find.byType(FernAvatar), findsNothing);
  });

  testWidgets('con avatar la imagen sustituye al icono', (tester) async {
    await pumpTile(tester, avatarPath: picture.path);

    expect(find.byType(FernAvatar), findsOneWidget);
    expect(find.byIcon(Symbols.sell), findsNothing);
  });

  testWidgets('el avatar sigue estando con el menú plegado', (tester) async {
    // Es para lo que está: plegado no se ve el nombre, así que la imagen es lo
    // único que dice qué etiqueta es.
    await pumpTile(tester, avatarPath: picture.path, isExpanded: false);

    expect(find.byType(FernAvatar), findsOneWidget);
    expect(find.text('Miraculous'), findsNothing);
  });

  testWidgets('el avatar ocupa lo mismo que el icono al que sustituye',
      (tester) async {
    await pumpTile(tester, avatarPath: picture.path);

    final avatar = tester.widget<FernAvatar>(find.byType(FernAvatar));
    expect(avatar.radius * 2, AppSizes.iconLarge);
  });

  // El chevron con el que se pliega una rama del árbol de etiquetas.
  group('el chevron de plegar', () {
    testWidgets('sale en las que tienen hijas', (tester) async {
      await pumpTile(tester, hasChildren: true, onToggleCollapse: () {});

      expect(find.byIcon(Symbols.expand_more), findsOneWidget);
    });

    testWidgets('y apunta al lado cuando está plegada', (tester) async {
      await pumpTile(
        tester,
        hasChildren: true,
        isCollapsed: true,
        onToggleCollapse: () {},
      );

      expect(find.byIcon(Symbols.chevron_right), findsOneWidget);
      expect(find.byIcon(Symbols.expand_more), findsNothing);
    });

    // Uno que no hace nada en la mitad de las filas es ruido.
    testWidgets('no sale en las que no tienen', (tester) async {
      await pumpTile(tester, onToggleCollapse: () {});

      expect(find.byIcon(Symbols.expand_more), findsNothing);
      expect(find.byIcon(Symbols.chevron_right), findsNothing);
    });

    testWidgets('ni en lo que no es una etiqueta', (tester) async {
      // Sin quien lo atienda no se pinta, aunque diga que tiene hijas.
      await pumpTile(tester, hasChildren: true);

      expect(find.byIcon(Symbols.expand_more), findsNothing);
    });

    // El hueco es del árbol de etiquetas, no del menú entero: dárselo a las
    // opciones normales les quitaba veinte píxeles de título y los nombres
    // largos se cortaban con puntos suspensivos.
    testWidgets('lo que no es una etiqueta no reserva su hueco',
        (tester) async {
      await pumpTile(tester, title: 'Gestor de etiquetas');

      final sinHueco = tester.getTopLeft(find.text('Gestor de etiquetas')).dx;

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpTile(
        tester,
        title: 'Gestor de etiquetas',
        onToggleCollapse: () {},
      );

      final conHueco = tester.getTopLeft(find.text('Gestor de etiquetas')).dx;

      expect(sinHueco, lessThan(conHueco));
    });

    // Plegado sólo caben los iconos: ahí la jerarquía no se toca, lo plegado se
    // respeta igual pero no se puede cambiar desde ese estado.
    testWidgets('con el menú plegado no hay chevron', (tester) async {
      await pumpTile(
        tester,
        isExpanded: false,
        hasChildren: true,
        onToggleCollapse: () {},
      );

      expect(find.byIcon(Symbols.expand_more), findsNothing);
      expect(find.byIcon(Symbols.chevron_right), findsNothing);
    });

    testWidgets('pulsarlo avisa a quien lo pidió', (tester) async {
      var veces = 0;

      await pumpTile(
        tester,
        hasChildren: true,
        onToggleCollapse: () => veces++,
      );

      await tester.tap(find.byIcon(Symbols.expand_more));
      await tester.pump();

      expect(veces, 1);
    });

    // La fila más llena que puede haber, en la ventana más estrecha en la que
    // el menú sigue desplegado.
    testWidgets('la fila no desborda en ningún idioma', (tester) async {
      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
        Locale('fr'),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.takeException();

        await pumpTile(
          tester,
          locale: locale,
          avatarPath: picture.path,
          hasChildren: true,
          onToggleCollapse: () {},
          title: 'una etiqueta con un nombre larguísimo que no cabe de ninguna '
              'manera en el menú lateral',
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          tester.takeException(),
          isNull,
          reason: 'la fila desborda en ${locale.languageCode}',
        );
      }
    });
  });
}
