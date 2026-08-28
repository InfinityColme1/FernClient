// Lo que se mira antes de dejar que alguien entrene.
//
// Entrenar cuesta entre minutos y horas. Casi todo lo que sale mal se puede
// saber **antes** mirando los recuentos, y decirlo entonces es la diferencia
// entre corregirlo en un minuto y descubrirlo por la manana.
//
// El aviso de «pocos contenidos» y el de desequilibrio son los dos que importan
// de verdad, y por la misma razon: **no salen en las metricas**. Un modelo que
// ha aprendido el fondo, o que contesta siempre la clase mayoritaria, saca unas
// cifras estupendas y luego falla con todo lo demas.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/services/training_checks.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 0;

ModelFernieEntity _fernie({
  String name = 'Marinette',
  int regionCount = 200,
  int mediaCount = 20,
  int? usableRegionCount,
  int? usableMediaCount,
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
      usableRegionCount: usableRegionCount,
      usableMediaCount: usableMediaCount,
    ),
    split: split,
    classIndex: id,
  );
}

RecognitionModelEntity _model() =>
    RecognitionModelEntity(id: 1, name: 'Personajes', createdAt: DateTime(2026));

List<TrainingIssue> _check(
  List<ModelFernieEntity> fernies, {
  bool isEngineReady = true,
}) {
  return checkTraining(
    model: _model(),
    fernies: fernies,
    isEngineReady: isEngineReady,
  );
}

Set<TrainingIssueKind> _kinds(List<TrainingIssue> issues) =>
    {for (final issue in issues) issue.kind};

void main() {
  setUp(() => _nextId = 0);

  test('con material de sobra no hay nada que decir', () {
    final issues = _check([_fernie(), _fernie(name: 'Adrien')]);

    expect(issues, isEmpty);
    expect(canTrain(issues), isTrue);
  });

  group('lo que impide entrenar', () {
    test('un modelo sin fernies no tiene nada que aprender', () {
      final issues = _check([]);

      expect(_kinds(issues), contains(TrainingIssueKind.noFernies));
      expect(canTrain(issues), isFalse);
    });

    test('sin fernies no se dice nada mas', () {
      // Todo lo demas es sobre ellos: soltar cinco avisos mas seria ruido.
      expect(_check([]), hasLength(1));
    });

    test('un fernie con muy pocas regiones', () {
      final issues = _check([
        _fernie(),
        _fernie(name: 'Alya', regionCount: 8, mediaCount: 8),
      ]);

      final tooFew = issues
          .where((i) => i.kind == TrainingIssueKind.tooFewRegions)
          .single;

      expect(tooFew.isBlocking, isTrue);
      expect(tooFew.fernieName, 'Alya');
      expect(tooFew.amount, minRegionsPerClass);
      expect(canTrain(issues), isFalse);
    });

    test('un reparto sin validacion', () {
      final issues = _check([
        _fernie(split: const DatasetSplit(train: 100, validation: 0, test: 0)),
      ]);

      // Sin conjunto de validacion, el entrenamiento no sabe cuando parar ni
      // que tal va.
      expect(_kinds(issues), contains(TrainingIssueKind.noValidation));
      expect(canTrain(issues), isFalse);
    });

    test('el motor sin preparar', () {
      final issues = _check([_fernie()], isEngineReady: false);

      expect(_kinds(issues), contains(TrainingIssueKind.engineNotReady));
      expect(canTrain(issues), isFalse);
    });
  });

  group('lo marcado frente a lo que entrena', () {
    // Una region sobre contenido sin confirmar se guarda igual pero no entra en
    // el conjunto de datos (D29). Contarla aqui dejaba entrenar con cero
    // muestras a un fernie que decia tener doscientas.
    test('doscientas marcadas y ocho utilizables impiden entrenar', () {
      final issues = _check([
        _fernie(),
        _fernie(
          name: 'Alya',
          regionCount: 200,
          mediaCount: 20,
          usableRegionCount: 8,
          usableMediaCount: 2,
        ),
      ]);

      final tooFew = issues
          .where((i) => i.kind == TrainingIssueKind.tooFewRegions)
          .single;

      expect(tooFew.fernieName, 'Alya');
      expect(canTrain(issues), isFalse);
    });

    test('la variedad tambien se mide sobre lo que entrena', () {
      final issues = _check([
        _fernie(
          regionCount: 200,
          mediaCount: 20,
          usableRegionCount: 200,
          usableMediaCount: 1,
        ),
      ]);

      expect(_kinds(issues), contains(TrainingIssueKind.tooFewMedia));
    });

    test('el desequilibrio se mide sobre lo que entrena', () {
      // Marcado estan igualados; lo que entrena, diez a uno.
      final issues = _check([
        _fernie(regionCount: 200, usableRegionCount: 200),
        _fernie(name: 'Adrien', regionCount: 200, usableRegionCount: 20),
      ]);

      expect(_kinds(issues), contains(TrainingIssueKind.imbalanced));
    });

    test('sin nada pendiente los dos recuentos son el mismo', () {
      expect(_check([_fernie(), _fernie(name: 'Adrien')]), isEmpty);
    });
  });

  group('lo que solo se avisa', () {
    test('pocas regiones, pero suficientes', () {
      final issues = _check([_fernie(regionCount: 30)]);

      final few =
          issues.where((i) => i.kind == TrainingIssueKind.fewRegions).single;

      expect(few.isBlocking, isFalse);
      expect(canTrain(issues), isTrue, reason: 'se entrena igual, sabiendo');
    });

    test('muchas regiones de muy pocos ficheros', () {
      // Doscientas regiones de dos ficheros: el modelo aprendera el fondo, y
      // las metricas no lo van a decir.
      final issues = _check([_fernie(regionCount: 200, mediaCount: 2)]);

      final media =
          issues.where((i) => i.kind == TrainingIssueKind.tooFewMedia).single;

      expect(media.isBlocking, isFalse);
      expect(media.amount, minMediaPerClass);
    });

    test('un fernie con diez veces mas que otro', () {
      final issues = _check([
        _fernie(regionCount: 1000),
        _fernie(name: 'Adrien', regionCount: 100),
      ]);

      // Con diez a uno el modelo aprende a contestar siempre el mayoritario:
      // acierta el noventa por ciento sin haber aprendido nada.
      expect(_kinds(issues), contains(TrainingIssueKind.imbalanced));
      expect(canTrain(issues), isTrue);
    });

    test('nueve a uno todavia pasa', () {
      final issues = _check([
        _fernie(regionCount: 900),
        _fernie(name: 'Adrien', regionCount: 100),
      ]);

      expect(_kinds(issues), isNot(contains(TrainingIssueKind.imbalanced)));
    });
  });

  test('se dicen todos, no el primero', () {
    // Quien vaya a arreglarlo prefiere la lista entera a irlos descubriendo de
    // uno en uno, entrenando entre medias.
    final issues = _check([
      _fernie(regionCount: 5, mediaCount: 1),
      _fernie(name: 'Adrien', regionCount: 2000, mediaCount: 200),
    ]);

    expect(
      _kinds(issues),
      containsAll([
        TrainingIssueKind.tooFewRegions,
        TrainingIssueKind.tooFewMedia,
        TrainingIssueKind.imbalanced,
      ]),
    );
  });
}
