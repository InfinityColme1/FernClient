// El dialogo con las imagenes que dejo el entrenamiento.
//
// Lo que importa aqui es **que quepa**. Con alto fijo, en una ventana baja
// desbordaba por abajo: las ultimas curvas quedaban debajo del borde y no habia
// forma de llegar a ellas, porque lo que sobresale de un dialogo no se desplaza,
// simplemente no esta.

import 'dart:io';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/recognition/presentation/widgets/metrics_panel.dart';
import 'package:Fern/features/recognition/presentation/widgets/run_images_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String directory,
  required Size window,
  RunImageKind kind = RunImageKind.curves,
}) async {
  tester.view.physicalSize = window;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: RunImagesDialog(directory: directory, kind: kind),
    ),
  ));

  await tester.pump();
}

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('fern-run-dialog-');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  testWidgets('en una ventana baja no desborda', (tester) async {
    // Mas baja que el alto que el dialogo pedia, que es cuando aparecia la
    // franja amarilla.
    await _pump(tester, directory: temp.path, window: const Size(1200, 620));

    expect(tester.takeException(), isNull);
  });

  testWidgets('en una ventana muy baja tampoco', (tester) async {
    await _pump(tester, directory: temp.path, window: const Size(1000, 420));

    expect(tester.takeException(), isNull);
  });

  testWidgets('en una alta sigue cabiendo', (tester) async {
    await _pump(tester, directory: temp.path, window: const Size(1400, 1200));

    expect(tester.takeException(), isNull);
  });

  testWidgets('sin imagenes lo dice en vez de quedarse en blanco',
      (tester) async {
    await _pump(tester, directory: temp.path, window: const Size(1200, 900));

    // La carpeta de runs es de las primeras que se borran para hacer sitio.
    expect(find.textContaining('ya no están'), findsOneWidget);
  });

  testWidgets('el dialogo cabe en la ventana', (tester) async {
    const window = Size(1200, 620);
    await _pump(tester, directory: temp.path, window: window);

    final dialog = tester.getRect(find.byType(Dialog));

    // Lo que sobresale de un dialogo no se desplaza: sencillamente no esta.
    expect(dialog.height, lessThanOrEqualTo(window.height));
    expect(dialog.bottom, lessThanOrEqualTo(window.height));
  });

  testWidgets('y en una ventana holgada no se encoge de mas', (tester) async {
    await _pump(tester, directory: temp.path, window: const Size(1400, 1200));

    // Con sitio de sobra pide su alto entero: encogerlo siempre por si acaso
    // dejaria media pantalla en blanco en un monitor grande.
    final dialog = tester.getRect(find.byType(Dialog));

    expect(dialog.height, greaterThan(AppSizes.runImagesDialogHeight));
  });
}
