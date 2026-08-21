// El panel con el que se entrena un modelo.
//
// Lo que importa aqui es **que el boton no deje entrenar cuando no se puede**.
// Un entrenamiento que arranca sabiendo que va a fallar cuesta minutos u horas
// antes de decir lo que ya se sabia; el bloqueo es lo que convierte eso en un
// mensaje inmediato.
//
// Y que el preset marcado sea el que de verdad esta puesto: tocar un mando a
// mano deja de coincidir con cualquiera, y seguir enseñando «Equilibrado»
// mentiria sobre con que se va a entrenar.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_presets.dart';
import 'package:Fern/features/recognition/presentation/widgets/training_panel.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 0;

ModelFernieEntity _fernie({
  String name = 'Marinette',
  int regionCount = 200,
  int mediaCount = 20,
  DatasetSplit split = DatasetSplit.balanced,
}) {
  final id = _nextId++;

  return ModelFernieEntity(
    id: id,
    modelId: 1,
    fernie: FernieEntity(
      id: id,
      name: name,
      regionCount: regionCount,
      mediaCount: mediaCount,
    ),
    split: split,
    classIndex: id,
  );
}

/// Un modelo con los mandos del preset equilibrado ya puestos.
RecognitionModelEntity _model({
  TrainingPreset preset = TrainingPreset.balanced,
  String? weightsPath,
  int? epochs,
}) {
  final settings = settingsFor(preset: preset, function: ModelFunction.boolean);

  return RecognitionModelEntity(
    id: 1,
    name: 'Personajes',
    preset: preset,
    backbone: settings.backbone,
    epochs: epochs ?? settings.epochs,
    imgsz: settings.imgsz,
    weightsPath: weightsPath,
    fernieCount: 2,
    createdAt: DateTime(2026),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  RecognitionModelEntity? model,
  List<ModelFernieEntity>? fernies,
  bool isEngineReady = true,
  Job? job,
  ValueChanged<RecognitionModelEntity>? onSettingsChanged,
  VoidCallback? onTrain,
  VoidCallback? onCancel,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      // A lo ancho de la pantalla y con el alto que necesite: los presets van en
      // fila y el panel ya no se desplaza por dentro.
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1200,
          child: TrainingPanel(
            model: model ?? _model(),
            fernies: fernies ?? [_fernie(), _fernie(name: 'Adrien')],
            isEngineReady: isEngineReady,
            job: job,
            onSettingsChanged: onSettingsChanged,
            onTrain: onTrain,
            onCancel: onCancel,
          ),
        ),
      ),
    ),
  ));
}

/// Si el boton de entrenar se puede pulsar.
bool _canTrain(WidgetTester tester) {
  final button = tester.widget<ElevatedButton>(
    find.descendant(
      of: find.byType(TrainingPanel),
      matching: find.byType(ElevatedButton),
    ),
  );

  return button.onPressed != null;
}

Job _job({int done = 0, int total = 100, DateTime? startedAt}) {
  return Job(
    id: 'job-1',
    type: JobType.training,
    createdAt: DateTime(2026),
    status: JobStatus.running,
    done: done,
    total: total,
    startedAt: startedAt,
  );
}

void main() {
  setUp(() => _nextId = 0);

  group('el boton', () {
    testWidgets('con todo en orden se puede entrenar', (tester) async {
      await _pump(tester, onTrain: () {});

      expect(_canTrain(tester), isTrue);
      expect(find.text('Entrenar modelo'), findsOneWidget);
    });

    testWidgets('con pesos ya entrenados dice volver a entrenar',
        (tester) async {
      await _pump(tester, model: _model(weightsPath: 'C:/runs/best.pt'));

      expect(find.text('Volver a entrenar'), findsOneWidget);
    });

    testWidgets('sin fernies no deja', (tester) async {
      await _pump(tester, fernies: const [], onTrain: () {});

      // Un entrenamiento que arranca sabiendo que va a fallar cuesta minutos u
      // horas antes de decir lo que ya se sabia.
      expect(_canTrain(tester), isFalse);
    });

    testWidgets('con un fernie sin material suficiente no deja',
        (tester) async {
      await _pump(
        tester,
        fernies: [_fernie(), _fernie(name: 'Alya', regionCount: 5)],
        onTrain: () {},
      );

      expect(_canTrain(tester), isFalse);
      expect(find.textContaining('Alya'), findsOneWidget);
    });

    testWidgets('sin motor instalado no deja', (tester) async {
      await _pump(tester, isEngineReady: false, onTrain: () {});

      expect(_canTrain(tester), isFalse);
      expect(find.textContaining('motor de reconocimiento'), findsOneWidget);
    });

    testWidgets('un aviso que no bloquea deja entrenar igual', (tester) async {
      await _pump(
        tester,
        fernies: [_fernie(regionCount: 30), _fernie(name: 'Adrien')],
        onTrain: () {},
      );

      // Se entrena sabiendo, que es distinto de no poder.
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
      expect(_canTrain(tester), isTrue);
    });

    testWidgets('pulsarlo avisa', (tester) async {
      var trains = 0;
      await _pump(tester, onTrain: () => trains++);

      await tester.tap(find.text('Entrenar modelo'));
      await tester.pump();

      expect(trains, 1);
    });
  });

  group('los presets', () {
    testWidgets('se marca el que de verdad esta puesto', (tester) async {
      await _pump(tester, model: _model(preset: TrainingPreset.fast));

      final tile = tester.widget<FernRadioTile<TrainingPreset>>(
        find.byWidgetPredicate(
          (widget) =>
              widget is FernRadioTile<TrainingPreset> &&
              widget.value == TrainingPreset.fast,
        ),
      );

      expect(tile.groupValue, TrainingPreset.fast);
    });

    testWidgets('personalizado no se ofrece si no es lo que hay',
        (tester) async {
      await _pump(tester);

      // No es algo que se elija: es lo que queda al tocar los mandos.
      expect(find.text('Personalizado'), findsNothing);
    });

    testWidgets('con los mandos tocados, el preset es personalizado',
        (tester) async {
      // Las mismas cifras del equilibrado salvo las epocas.
      await _pump(tester, model: _model(epochs: 137));

      expect(find.text('Personalizado'), findsOneWidget);
    });

    testWidgets('elegir uno manda sus cifras', (tester) async {
      RecognitionModelEntity? saved;
      await _pump(tester, onSettingsChanged: (model) => saved = model);

      await tester.tap(find.text('Rápido'));
      await tester.pump();

      final expected =
          settingsFor(preset: TrainingPreset.fast, function: ModelFunction.boolean);

      expect(saved, isNotNull);
      expect(saved!.preset, TrainingPreset.fast);
      expect(saved!.epochs, expected.epochs);
      expect(saved!.imgsz, expected.imgsz);
      expect(saved!.backbone, expected.backbone);
    });
  });

  group('mientras entrena', () {
    testWidgets('ensena por que epoca va', (tester) async {
      await _pump(tester, job: _job(done: 34, total: 100));

      expect(find.text('Época 34 de 100'), findsOneWidget);

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.34, 0.001));
    });

    testWidgets('antes de la primera epoca dice que esta preparando',
        (tester) async {
      // Montar el dataset puede tardar tanto como entrenar cuando hay muchos
      // fotogramas de video, y una barra parada sin explicacion parece un
      // cuelgue.
      await _pump(tester, job: _job(done: 0, total: 0));

      expect(find.text('Preparando el material...'), findsOneWidget);
    });

    testWidgets('el boton de entrenar deja sitio al de cancelar',
        (tester) async {
      var cancels = 0;
      await _pump(tester, job: _job(done: 10), onCancel: () => cancels++);

      expect(find.text('Entrenar modelo'), findsNothing);

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(cancels, 1);
    });

    testWidgets('los presets no se tocan con algo en marcha', (tester) async {
      await _pump(tester, job: _job(done: 10), onSettingsChanged: (_) {});

      final tiles = tester
          .widgetList<FernRadioTile<TrainingPreset>>(
            find.byType(FernRadioTile<TrainingPreset>),
          )
          .toList();

      expect(tiles, isNotEmpty);

      // Cambiarlos a media faena no cambiaria nada de lo que ya esta corriendo,
      // pero lo pareceria.
      for (final tile in tiles) {
        expect(tile.onChanged, isNull, reason: 'el de ${tile.value}');
      }
    });
  });
}
