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
  }) {
    return tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: CollapsingListTile(
          title: 'Miraculous',
          icon: Symbols.sell,
          avatarPath: avatarPath,
          isExpanded: isExpanded,
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
}
