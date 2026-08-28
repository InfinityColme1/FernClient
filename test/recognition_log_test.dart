// El parte de lo que hizo cada modelo con un contenido.
//
// Existe por una queja concreta: «los modelos no han detectado nada» en imágenes
// que claramente llevan las mismas figuras del entrenamiento. Resultó no ser un
// fallo —el modelo las veía al 27 % y el listón estaba en el 35 %— pero eso no
// se podía saber desde la aplicación, y lo que no se puede ver no se puede
// arreglar.
//
// Lo que se comprueba aquí es que las cinco respuestas se distinguen. Las cinco
// se parecen desde fuera —no sale ninguna sugerencia— y piden cosas distintas:
// bajar el listón, entrenar el modelo, meterlo en el árbol, o nada porque de
// verdad no había nada.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/services/media_recognizer.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:flutter_test/flutter_test.dart';

ModelTreeNodeEntity _node(
  int id, {
  double threshold = 0.35,
  bool trained = true,
}) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'Modelo $id',
      weightsPath: trained ? 'C:/runs/$id/best.pt' : null,
      confidenceThreshold: threshold,
      createdAt: DateTime(2026),
    ),
  );
}

RawDetection _seen(int classIndex, double confidence) => RawDetection(
      classIndex: classIndex,
      confidence: confidence,
    );

void main() {
  /// Un reconocedor al que se le dice qué ve cada modelo.
  MediaRecognizer recognizer({
    Map<int, List<RawDetection>> sees = const {},
    List<double>? askedWith,
  }) {
    return MediaRecognizer(
      models: _FakeModels(const {
        1: {0: 10, 1: 11},
        2: {0: 20},
      }),
      durationOf: (_) async => null,
      extractFrames: (_, at) async => const [],
      predict: (model, imagePath, conf) async {
        askedWith?.add(conf);

        return sees[model.id] ?? const [];
      },
    );
  }

  Future<MediaRecognitionLog> logOf(
    MediaRecognizer subject,
    ModelTreeEntity tree,
  ) async {
    final result = await subject.recognize(
      mediaId: 7,
      path: 'C:/fotos/uno.jpg',
      tree: tree,
    );

    expect(result, isA<DataSuccess>());

    return result.data!.log;
  }

  RecognitionLogEntry entryOf(MediaRecognitionLog log, int modelId) =>
      log.models.firstWhere((one) => one.modelId == modelId);

  group('cómo se le pregunta al motor', () {
    test('se pregunta muy por debajo del listón del modelo', () async {
      final asked = <double>[];

      await logOf(
        recognizer(askedWith: asked),
        ModelTreeEntity(nodes: [_node(1, threshold: 0.9)]),
      );

      // Con el listón del modelo, lo que no llega nunca vuelve, y entonces no
      // hay forma de decir «lo vio, pero no lo suficiente».
      expect(asked, [recognitionFloor]);
      expect(recognitionFloor, lessThan(0.9));
    });
  });

  group('los cinco veredictos', () {
    test('propuso: pasó el listón', () async {
      final log = await logOf(
        recognizer(sees: {
          1: [_seen(0, 0.8)],
        }),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(entryOf(log, 1).verdict, RecognitionVerdict.proposed);
      expect(log.proposed, 1);
    });

    test('lo vio pero no llegó al listón', () async {
      final log = await logOf(
        recognizer(sees: {
          1: [_seen(0, 0.27)],
        }),
        ModelTreeEntity(nodes: [_node(1, threshold: 0.35)]),
      );

      final entry = entryOf(log, 1);

      // Es el caso que desconcierta: el modelo **sí** reconoció la figura.
      expect(entry.verdict, RecognitionVerdict.belowThreshold);
      expect(entry.rejected.single.percent, 27);
      expect(entry.threshold, 0.35);

      // Y no se propone: verlo poco no es verlo.
      expect(log.proposed, 0);
      expect(log.hasNearMisses, isTrue);
    });

    test('miró y no vio nada', () async {
      final log = await logOf(
        recognizer(),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(entryOf(log, 1).verdict, RecognitionVerdict.sawNothing);
      expect(log.hasNearMisses, isFalse);
    });

    test('no llegó a ejecutarse porque su rama no se abrió', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: const [
          ModelTreeEdgeEntity(id: 1, parentNodeId: 1, childNodeId: 2),
        ],
      );

      final log = await logOf(recognizer(), tree);

      // El padre no vio nada, así que el hijo no corre. No es un fallo, es el
      // árbol haciendo su trabajo, pero desde fuera se parece demasiado.
      expect(entryOf(log, 2).verdict, RecognitionVerdict.notReached);
    });

    test('no se ejecutó porque no tiene pesos', () async {
      final log = await logOf(
        recognizer(),
        ModelTreeEntity(nodes: [_node(1, trained: false)]),
      );

      expect(entryOf(log, 1).verdict, RecognitionVerdict.untrained);
    });
  });

  group('mover el listón cambia lo que se propone', () {
    /// Cuántas sugerencias salen con este listón, viendo siempre lo mismo.
    Future<int> proposedWith(double threshold) async {
      final result = await recognizer(sees: {
        1: [_seen(0, 0.8), _seen(1, 0.27)],
      }).recognize(
        mediaId: 7,
        path: 'C:/fotos/uno.jpg',
        tree: ModelTreeEntity(nodes: [_node(1, threshold: threshold)]),
      );

      return result.data!.suggestions.length;
    }

    test('con el listón alto sólo pasa lo muy seguro', () async {
      expect(await proposedWith(0.35), 1);
    });

    test('bajándolo pasa también lo que se quedaba fuera', () async {
      // Es el caso de la queja: el modelo veía la figura al 27 % y no proponía
      // nada. Con el listón por debajo, la propone.
      expect(await proposedWith(0.2), 2);
    });

    test('en el suelo pasa todo lo que el motor haya visto', () async {
      expect(await proposedWith(recognitionFloor), 2);
    });

    test('con el listón por las nubes no pasa nada', () async {
      expect(await proposedWith(0.95), 0);
    });
  });

  group('lo que se apunta', () {
    test('sale todo lo visto, pasara o no el listón', () async {
      final log = await logOf(
        recognizer(sees: {
          1: [_seen(0, 0.8), _seen(1, 0.2)],
        }),
        ModelTreeEntity(nodes: [_node(1, threshold: 0.35)]),
      );

      final entry = entryOf(log, 1);

      expect(entry.sightings, hasLength(2));
      expect(entry.accepted.single.fernieId, 10);
      expect(entry.rejected.single.fernieId, 11);
    });

    test('va de más seguro a menos', () async {
      final log = await logOf(
        recognizer(sees: {
          1: [_seen(1, 0.2), _seen(0, 0.8)],
        }),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Quien abre esto busca «¿qué es lo que más se parecía?».
      expect(
        entryOf(log, 1).sightings.map((one) => one.percent),
        [80, 20],
      );
    });

    test('lleva el nombre del fernie, no su número', () async {
      final log = await logOf(
        recognizer(sees: {
          1: [_seen(0, 0.8)],
        }),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Un parte lleno de números no le explica nada a quien lo abre.
      expect(entryOf(log, 1).sightings.single.fernieName, 'Fernie 10');
    });

    test('están todos los modelos del árbol, corrieran o no', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2, trained: false)],
      );

      final log = await logOf(recognizer(), tree);

      expect(log.models.map((one) => one.modelId).toList()..sort(), [1, 2]);
    });

    test('lleva el nombre del fichero, para poder enseñarlo suelto', () async {
      final log = await logOf(
        recognizer(),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(log.name, 'uno.jpg');
      expect(log.mediaId, 7);
    });
  });
  group('parar de verdad', () {
    /// Un vídeo de cinco fotogramas, todos del mismo fichero.
    List<SampledFrame> frames() => [
          for (var ms = 0; ms < 5000; ms += 1000)
            SampledFrame(path: 'C:/videos/uno.mp4', frameMs: ms),
        ];

    test('cancelar no espera a que se miren todos los fotogramas', () async {
      final token = CancellationToken();
      var predicciones = 0;

      final subject = MediaRecognizer(
        models: _FakeModels(const {1: {0: 10}}),
        durationOf: (_) async => const Duration(seconds: 5),
        extractFrames: (_, at) async => frames(),
        predict: (model, imagePath, conf) async {
          predicciones++;
          // Se cancela con la primera: lo que se comprueba es que no se hacen
          // las otras cuatro.
          token.cancel();

          return const [];
        },
      );

      await expectLater(
        subject.recognize(
          mediaId: 7,
          path: 'C:/videos/uno.mp4',
          tree: ModelTreeEntity(nodes: [_node(1)]),
          token: token,
        ),
        throwsA(isA<JobCancelledException>()),
      );

      // Un vídeo son veinte predicciones seguidas; sin comprobarlo entre
      // fotogramas, parar tarda las veinte.
      expect(predicciones, 1);
    });
  });
}

/// Modelos de mentira: cada uno con las clases que se le digan.
class _FakeModels implements ModelRepository {
  final Map<int, Map<int, int>> classes;

  const _FakeModels(this.classes);

  @override
  Future<DataState<List<ModelFernieEntity>>> getFerniesOfModel(
    int modelId,
  ) async {
    return DataSuccess([
      for (final entry in (classes[modelId] ?? const {}).entries)
        ModelFernieEntity(
          id: entry.value,
          modelId: modelId,
          fernie: FernieEntity(id: entry.value, name: 'Fernie ${entry.value}'),
          classIndex: entry.key,
        ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');

}
