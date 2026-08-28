// El bloque de resultados de un modelo.
//
// Lo que importa aqui es **que no invente cifras**. Un modelo sin entrenar, unos
// pesos traidos de fuera o un JSON de una version anterior no tienen metricas, y
// pintar una barra a cero diria que el modelo acierta cero: una cifra muy
// distinta de no tenerla.
//
// Y que el bloque de rendimiento real **este a la vista aunque este vacio**: es
// la unica medida honesta de si el modelo sirve, y esconderla hasta la fase 5
// haria pensar que no se mide.

import 'dart:convert';
import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/metrics_panel.dart';
import 'package:Fern/features/recognition/presentation/widgets/run_images_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

String _metrics({
  Map<String, dynamic> changes = const {},
  List<String> without = const [],
}) {
  final data = {
    'map50': 0.83,
    'map50_95': 0.61,
    'precision': 0.88,
    'recall': 0.79,
    'per_class': {'marinette': 0.91, 'adrien': 0.87},
    'curves_dir': r'C:\fern\recognition\runs\7',
    ...changes,
  };

  for (final key in without) {
    data.remove(key);
  }

  return jsonEncode(data);
}

RecognitionModelEntity _model({
  String? lastMetrics,
  String? lastError,
  bool isImportedWeights = false,
}) {
  return RecognitionModelEntity(
    id: 7,
    name: 'Personajes',
    weightsPath: lastMetrics == null ? null : r'C:\runs\7\best.pt',
    lastMetrics: lastMetrics,
    lastError: lastError,
    isImportedWeights: isImportedWeights,
    createdAt: DateTime(2026),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  RecognitionModelEntity? model,
  ValueChanged<String>? onOpenFolder,
  void Function(String, RunImageKind)? onShowImages,
  VoidCallback? onRetry,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      // Ancho de pantalla y alto el que necesite: el panel ya no se desplaza
      // por dentro, lo hace la pagina.
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1200,
          child: MetricsPanel(
            model: model ?? _model(lastMetrics: _metrics()),
            onOpenFolder: onOpenFolder,
            onShowImages: onShowImages,
            onRetry: onRetry,
          ),
        ),
      ),
    ),
  ));
}

void main() {
  group('las cifras', () {
    testWidgets('se enseñan las cuatro con su barra', (tester) async {
      await _pump(tester);

      expect(find.text('0.83'), findsOneWidget);
      expect(find.text('0.61'), findsOneWidget);
      expect(find.text('0.88'), findsOneWidget);
      expect(find.text('0.79'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    });

    testWidgets('la que falta no pinta una barra a cero', (tester) async {
      await _pump(
        tester,
        model: _model(lastMetrics: _metrics(without: ['recall', 'precision'])),
      );

      // Un cero diria que el modelo acierta cero, que no es lo mismo que no
      // saberlo.
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('sin entrenar no hay cifras', (tester) async {
      await _pump(tester, model: _model());

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('sin entrenar'), findsOneWidget);
    });

    testWidgets('con pesos de fuera se dice que por eso no hay', (tester) async {
      await _pump(tester, model: _model(isImportedWeights: true));

      // No es lo mismo «no se ha entrenado» que «se entreno en otro sitio»: en
      // el segundo caso el modelo si sirve.
      expect(find.textContaining('vienen de fuera'), findsOneWidget);
    });

    testWidgets('un JSON de otra version no tumba la pantalla', (tester) async {
      await _pump(tester, model: _model(lastMetrics: 'esto no es json'));

      expect(tester.takeException(), isNull);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('por fernie', () {
    testWidgets('sale cada uno con su cifra', (tester) async {
      await _pump(tester);

      expect(find.textContaining('marinette 0.91'), findsOneWidget);
      expect(find.textContaining('adrien 0.87'), findsOneWidget);
    });

    testWidgets('el que va flojo lleva su aviso', (tester) async {
      await _pump(tester, model: _model(lastMetrics: _metrics(changes: {
        'per_class': {'marinette': 0.91, 'alya': 0.18},
      })));

      // Una media de 0,80 con un fernie a 0,18 se ve estupenda y falla justo con
      // ese.
      expect(find.byIcon(Symbols.warning_amber), findsOneWidget);
    });

    testWidgets('con todos por encima del liston no hay avisos',
        (tester) async {
      await _pump(tester);

      expect(find.byIcon(Symbols.warning_amber), findsNothing);
      expect(weakClassThreshold, lessThan(0.87));
    });
  });

  group('los botones de la run', () {
    testWidgets('con carpeta se ofrecen los tres', (tester) async {
      await _pump(tester, onOpenFolder: (_) {}, onShowImages: (_, _) {});

      expect(find.text('Matriz de confusión'), findsOneWidget);
      expect(find.text('Curvas'), findsOneWidget);
      expect(find.text('Abrir carpeta de la run'), findsOneWidget);
    });

    testWidgets('sin carpeta no se ofrece ninguno', (tester) async {
      await _pump(
        tester,
        model: _model(lastMetrics: _metrics(without: ['curves_dir'])),
        onOpenFolder: (_) {},
      );

      // Un boton que no lleva a ningun sitio es peor que no tenerlo.
      expect(find.text('Abrir carpeta de la run'), findsNothing);
    });

    testWidgets('cada uno pide lo suyo', (tester) async {
      final asked = <RunImageKind>[];
      String? opened;

      await _pump(
        tester,
        onOpenFolder: (path) => opened = path,
        onShowImages: (_, kind) => asked.add(kind),
      );

      // Con muchas metricas los botones caen por debajo del hueco: se llega a
      // ellos desplazando, que es justo lo que el panel tiene que permitir.
      for (final label in const [
        'Matriz de confusión',
        'Curvas',
        'Abrir carpeta de la run',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pump();
      }

      expect(asked, [RunImageKind.confusion, RunImageKind.curves]);
      expect(opened, contains('runs'));
    });
  });

  group('cuando fallo', () {
    testWidgets('se dice que se rompio, y en cristiano', (tester) async {
      await _pump(tester, model: _model(lastError: 'OUT_OF_MEMORY'));

      // Se guarda en el modelo y no en la cola porque la cola se vacia: al dia
      // siguiente la pantalla tiene que poder decir todavia que paso. Pero lo
      // que se enseña es que hacer, no el codigo: «OUT_OF_MEMORY» no le dice
      // nada a nadie.
      expect(find.text('OUT_OF_MEMORY'), findsNothing);
      expect(find.textContaining('sin memoria'), findsOneWidget);
      expect(find.textContaining('Avanzado'), findsOneWidget);
    });

    testWidgets('el motor parado explica que hacer', (tester) async {
      // Es el fallo que aparecio en la primera prueba de verdad, y con el
      // mensaje de antes no habia forma de saber que hacer con el.
      await _pump(tester, model: _model(
        lastError: 'SidecarException(SIDECAR_NOT_READY): The sidecar stopped '
            'while the request was in flight',
      ));

      expect(find.textContaining('se paró a media faena'), findsOneWidget);
      expect(find.textContaining('SIDECAR_NOT_READY'), findsNothing);
    });

    testWidgets('lo que no se reconoce si enseña el detalle', (tester) async {
      await _pump(tester, model: _model(lastError: 'Algo rarisimo del 2031'));

      // Es lo unico que hay: una frase inventada diria menos.
      expect(find.textContaining('ha fallado'), findsOneWidget);
      expect(find.text('Algo rarisimo del 2031'), findsOneWidget);
    });

    testWidgets('se puede volver a intentar', (tester) async {
      var retries = 0;
      await _pump(
        tester,
        model: _model(lastError: 'OUT_OF_MEMORY'),
        onRetry: () => retries++,
      );

      await tester.tap(find.text('Volver a intentarlo'));
      await tester.pump();

      expect(retries, 1);
    });

    testWidgets('con algo en marcha no se ofrece reintentar', (tester) async {
      await _pump(tester, model: _model(lastError: 'roto'));

      expect(find.text('Volver a intentarlo'), findsNothing);
    });
  });

  group('el rendimiento real', () {
    testWidgets('esta a la vista aunque este vacio', (tester) async {
      await _pump(tester);

      // Es la unica medida honesta de si el modelo sirve: esconderla hasta que
      // exista haria pensar que no se mide.
      expect(find.text('Rendimiento real'), findsOneWidget);
      expect(find.textContaining('Aún sin datos'), findsOneWidget);
    });

    testWidgets('tambien en un modelo sin entrenar', (tester) async {
      await _pump(tester, model: _model());

      expect(find.text('Rendimiento real'), findsOneWidget);
    });
  });

  group('las imagenes de la run', () {
    late Directory temp;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fern-run-');
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    Future<void> write(String name) =>
        File(p.join(temp.path, name)).writeAsString('png');

    test('solo se listan las que estan', () async {
      await write('confusion_matrix.png');

      final found = findRunImages(
        directory: temp.path,
        kind: RunImageKind.confusion,
      );

      // Los nombres cambian entre versiones de ultralytics: la lista es de
      // candidatos, no una promesa.
      expect(found, hasLength(1));
      expect(p.basename(found.single), 'confusion_matrix.png');
    });

    test('la normalizada va primero', () async {
      await write('confusion_matrix.png');
      await write('confusion_matrix_normalized.png');

      final found = findRunImages(
        directory: temp.path,
        kind: RunImageKind.confusion,
      );

      expect(p.basename(found.first), 'confusion_matrix_normalized.png');
    });

    test('cada clase busca las suyas', () async {
      await write('confusion_matrix.png');
      await write('PR_curve.png');

      expect(
        findRunImages(directory: temp.path, kind: RunImageKind.curves)
            .map(p.basename),
        ['PR_curve.png'],
      );
    });

    test('una carpeta que ya no esta devuelve nada, no revienta', () async {
      final found = findRunImages(
        directory: p.join(temp.path, 'lo-que-sea'),
        kind: RunImageKind.curves,
      );

      // La carpeta de runs es de las primeras que se borran para hacer sitio, y
      // el modelo sigue funcionando sin ella.
      expect(found, isEmpty);
    });
  });
}
