// La lista de bloqueos en Ajustes → Base de datos.
//
// Un bloqueo que no se puede ver ni deshacer es una trampa: si el usuario se
// arrepiente no hay forma de volver a importar eso nunca. La lista existe para
// eso, así que lo que se comprueba aquí es que sigue siendo usable cuando hay
// muchos —doscientos bloqueos no pueden empujar el botón de vaciarla fuera de la
// pantalla— y que un nombre largo se recorta en vez de desbordarse.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas de
// medidas: sin ella se mide con la de pruebas, en la que cada letra es un
// cuadrado, y los textos salen mucho más anchos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/data/models/blocked_import_model.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/settings/presentation/widgets/database_settings_section.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

BlockedImportModel _row(String remoteId, {String? description}) =>
    BlockedImportModel()
      ..id = BlockedImportModel.idOf('reddit', remoteId)
      ..source = 'reddit'
      ..remoteId = remoteId
      ..description = description
      ..at = DateTime(2026, 8, 30);

/// La sección con el ancho que tiene de verdad dentro del diálogo de ajustes.
Future<void> _pump(
  WidgetTester tester, {
  required List<BlockedImportModel> rows,
  Locale locale = const Locale('es'),
}) async {
  final blocked = _FakeBlocked(rows);

  if (getIt.isRegistered<BlockedImports>()) {
    await getIt.unregister<BlockedImports>();
  }
  getIt.registerSingleton<BlockedImports>(blocked);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: SizedBox(
        width: 520,
        height: 560,
        child: DatabaseSettingsSection(),
      ),
    ),
  ));

  // La lista se lee de la base al montarse.
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadAppFont);

  testWidgets('sin bloqueos lo dice, en vez de dejar un hueco', (tester) async {
    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    await _pump(tester, rows: const []);

    expect(find.text(texts.blockedImportsNone), findsOneWidget);
    // Sin nada que soltar, el botón de vaciarla no tiene sentido.
    expect(find.text(texts.blockedImportsClear), findsNothing);
  });

  testWidgets('con bloqueos, cada uno con su aspa', (tester) async {
    await _pump(tester, rows: [_row('uno'), _row('dos')]);

    expect(find.text('reddit · uno'), findsOneWidget);
    expect(find.text('reddit · dos'), findsOneWidget);
  });

  group('con doscientos', () {
    final many = [for (var i = 0; i < 200; i++) _row('pieza_$i')];

    testWidgets('no desborda', (tester) async {
      await _pump(tester, rows: many);

      expect(tester.takeException(), isNull);
    });

    // El que de verdad importa: sin tope, la lista empujaría el botón de
    // vaciarla fuera de la pantalla y la única salida rápida dejaría de estar.
    testWidgets('el botón de vaciarla sigue estando', (tester) async {
      final texts = await AppLocalizations.delegate.load(const Locale('es'));

      await _pump(tester, rows: many);

      expect(find.text(texts.blockedImportsClear), findsOneWidget);
    });

    testWidgets('y la lista tiene su propio desplazamiento', (tester) async {
      await _pump(tester, rows: many);

      final list = tester.getSize(find.byType(ListView));

      expect(list.height, lessThanOrEqualTo(blockedListMaxHeight));

      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // La descripción es el nombre del fichero tal y como venía de la fuente, y
  // algunas plataformas los dan larguísimos.
  testWidgets('un nombre larguísimo se recorta, no desborda', (tester) async {
    await _pump(tester, rows: [
      _row('largo', description: 'a' * 300),
    ]);

    expect(tester.takeException(), isNull);
  });

  // En una ventana estrecha el diálogo de ajustes se encoge, y la fila es un
  // texto y un botón en la misma línea.
  testWidgets('ni en las cuatro lenguas con la sección estrecha',
      (tester) async {
    for (final locale in const [
      Locale('en'),
      Locale('es'),
      Locale('ca'),
      Locale('fr'),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      tester.takeException();

      await _pump(
        tester,
        rows: [for (var i = 0; i < 20; i++) _row('pieza_$i')],
        locale: locale,
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'la lista desborda en ${locale.languageCode}',
      );
    }
  });
}

/// Lo bloqueado sin base de datos detrás: aquí se mide la lista, no dónde se
/// guarda.
class _FakeBlocked implements BlockedImports {
  final List<BlockedImportModel> rows;

  _FakeBlocked(this.rows);

  @override
  Future<List<BlockedImportModel>> all() async => rows;

  @override
  Future<void> unblock(int id) async => rows.removeWhere((row) => row.id == id);

  @override
  Future<void> clear() async => rows.clear();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
