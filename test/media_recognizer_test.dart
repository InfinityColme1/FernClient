// Pasar el arbol de modelos por un contenido.
//
// Aqui es donde todo lo anterior se convierte en algo, y donde hay dos cosas que
// sostener.
//
// La **traduccion**: unos pesos entrenados solo conocen numeros de clase, y quien
// es cada numero lo dice el modelo que los entreno. Traducir mal no da un error:
// da una sugerencia con el nombre de otro fernie, que el usuario acepta y le
// ensucia la biblioteca sin enterarse.
//
// Y que lo que salga de aqui sean **propuestas**: nada toca el contenido hasta
// que alguien las mira. Se prueba sin motor y sin disco: al reconocedor se le
// dice que contesta.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/features/recognition/data/services/media_recognizer.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un repositorio que sabe qué fernie es cada número de clase.
class _FakeModels implements ModelRepository {
  /// Por modelo: número de clase → fernie.
  final Map<int, Map<int, int>> classes;

  _FakeModels(this.classes);

  @override
  Future<DataState<List<ModelFernieEntity>>> getFerniesOfModel(
    int modelId,
  ) async {
    final mine = classes[modelId] ?? const {};

    return DataSuccess([
      for (final entry in mine.entries)
        ModelFernieEntity(
          id: entry.value,
          modelId: modelId,
          fernie: FernieEntity(id: entry.value, name: 'Fernie ${entry.value}'),
          split: DatasetSplit.balanced,
          classIndex: entry.key,
        ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

ModelTreeNodeEntity _node(int id, {double threshold = 0.5}) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'Modelo $id',
      weightsPath: 'C:/runs/$id/best.pt',
      confidenceThreshold: threshold,
      createdAt: DateTime(2026),
    ),
  );
}

RawDetection _seen(int classIndex, [double confidence = 0.9]) => RawDetection(
      classIndex: classIndex,
      confidence: confidence,
      x: 0.1,
      y: 0.2,
      w: 0.3,
      h: 0.4,
    );

void main() {
  /// Un reconocedor al que se le dice qué ve cada modelo en cada imagen.
  MediaRecognizer recognizer({
    Map<int, Map<int, int>> classes = const {
      1: {0: 10},
    },
    Map<int, List<RawDetection>> sees = const {},
    Duration? duration,
    List<SampledFrame> frames = const [],
    List<String>? asked,
    int samples = 5,
  }) {
    return MediaRecognizer(
      models: _FakeModels(classes),
      frameSamples: () => samples,
      durationOf: (_) async => duration,
      extractFrames: (_, at) async => frames,
      predict: (model, imagePath, conf) async {
        asked?.add(imagePath);

        return sees[model.id] ?? const [];
      },
    );
  }

  Future<List<RecognitionResultEntity>> run(
    MediaRecognizer subject,
    ModelTreeEntity tree, {
    String path = 'C:/fotos/uno.jpg',
    CancellationToken? token,
  }) async {
    final result = await subject.recognize(
      mediaId: 7,
      path: path,
      tree: tree,
      token: token,
    );

    expect(result, isA<DataSuccess>());

    return result.data!.suggestions;
  }

  group('la traduccion', () {
    test('el numero de clase se convierte en su fernie', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10, 1: 20},
          },
          sees: {
            1: [_seen(1)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Traducir mal no da un error: da una sugerencia con el nombre de otro
      // fernie, que alguien acepta sin enterarse.
      expect(found.single.fernieId, 20);
    });

    test('un numero que el modelo no conoce se descarta', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
          },
          sees: {
            1: [_seen(9)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Pasa si alguien saca un fernie del modelo despues de entrenarlo: los
      // pesos siguen conociendo esa clase y ya no significa nada.
      expect(found, isEmpty);
    });

    test('se apunta quien lo propuso', () async {
      final found = await run(
        recognizer(
          sees: {
            1: [_seen(0)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Hace falta para el rendimiento real: cuantas propuestas de **ese**
      // modelo se aceptan.
      expect(found.single.modelId, 1);
      expect(found.single.mediaId, 7);
    });

    test('la caja viaja con la sugerencia', () async {
      final found = await run(
        recognizer(
          sees: {
            1: [_seen(0)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(found.single.hasBox, isTrue);
      expect(found.single.x, 0.1);
    });

    test('sale sin guardar y sin revisar', () async {
      final found = await run(
        recognizer(
          sees: {
            1: [_seen(0)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Es una propuesta: hasta que alguien la mira no toca nada del contenido.
      expect(found.single.status, SuggestionStatus.suggested);
    });
  });

  group('el arbol manda', () {
    test('un hijo solo corre si el padre vio su clase', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: const [
          ModelTreeEdgeEntity(
            id: 1,
            parentNodeId: 1,
            childNodeId: 2,
            conditionFernieId: 10,
          ),
        ],
      );

      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
            2: {0: 20},
          },
          sees: {
            1: [_seen(0)],
            2: [_seen(0)],
          },
        ),
        tree,
      );

      expect(found.map((one) => one.fernieId).toList()..sort(), [10, 20]);
    });

    test('sin disparar al padre, el hijo no llega a mirar', () async {
      final asked = <String>[];

      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
        edges: const [
          ModelTreeEdgeEntity(
            id: 1,
            parentNodeId: 1,
            childNodeId: 2,
            conditionFernieId: 99,
          ),
        ],
      );

      await run(
        recognizer(
          classes: const {
            1: {0: 10},
            2: {0: 20},
          },
          sees: {
            1: [_seen(0)],
            2: [_seen(0)],
          },
          asked: asked,
        ),
        tree,
      );

      // La poda es el sentido del arbol: si el hijo mira igual, el ahorro no
      // existe y solo se nota en que tarda el triple.
      expect(asked, hasLength(1));
    });

    test('un modelo sin entrenar no se pregunta', () async {
      final asked = <String>[];

      final tree = ModelTreeEntity(nodes: [
        ModelTreeNodeEntity(
          id: 1,
          model: RecognitionModelEntity(
            id: 1,
            name: 'A medias',
            createdAt: DateTime(2026),
          ),
        ),
      ]);

      final found = await run(recognizer(asked: asked), tree);

      expect(asked, isEmpty);
      expect(found, isEmpty);
    });
  });

  group('lo que se mueve', () {
    test('una imagen se mira una vez, y es el propio fichero', () async {
      final asked = <String>[];

      await run(
        recognizer(asked: asked),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(asked, ['C:/fotos/uno.jpg']);
    });

    test('un video se mira por fotogramas', () async {
      final asked = <String>[];

      await run(
        recognizer(
          asked: asked,
          duration: const Duration(seconds: 10),
          frames: const [
            SampledFrame(path: 'C:/tmp/1.jpg', frameMs: 1000),
            SampledFrame(path: 'C:/tmp/2.jpg', frameMs: 5000),
          ],
        ),
        ModelTreeEntity(nodes: [_node(1)]),
        path: 'C:/videos/uno.mp4',
      );

      expect(asked, ['C:/tmp/1.jpg', 'C:/tmp/2.jpg']);
    });

    test('se guarda la mejor confianza y el momento en que se dio', () async {
      var call = 0;

      final subject = MediaRecognizer(
        models: _FakeModels(const {
          1: {0: 10},
        }),
        frameSamples: () => 2,
        durationOf: (_) async => const Duration(seconds: 10),
        extractFrames: (_, _) async => const [
          SampledFrame(path: 'C:/tmp/1.jpg', frameMs: 1000),
          SampledFrame(path: 'C:/tmp/2.jpg', frameMs: 5000),
        ],
        predict: (model, imagePath, conf) async {
          call++;
          return [_seen(0, call == 1 ? 0.4 : 0.9)];
        },
      );

      final found = await run(
        subject,
        ModelTreeEntity(nodes: [_node(1)]),
        path: 'C:/videos/uno.mp4',
      );

      expect(found.single.confidence, 0.9);
      expect(found.single.frameMs, 5000);
    });

    test('si no se puede sacar ningun fotograma, se mira el fichero', () async {
      final asked = <String>[];

      await run(
        recognizer(
          asked: asked,
          duration: const Duration(seconds: 10),
        ),
        ModelTreeEntity(nodes: [_node(1)]),
        path: 'C:/videos/uno.mp4',
      );

      // Peor que mirar el fichero tal cual es no reconocerlo.
      expect(asked, ['C:/videos/uno.mp4']);
    });
  });

  group('sin repetir', () {
    test('el mismo fernie del mismo modelo sale una vez', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10, 1: 10},
          },
          sees: {
            1: [_seen(0, 0.6), _seen(1, 0.8)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      // Dos propuestas del mismo modelo sobre el mismo fernie son la misma
      // sugerencia dos veces: obligarian a decir que si dos veces.
      expect(found, hasLength(1));
      expect(found.single.confidence, 0.8);
    });

    test('el mismo fernie de dos modelos sale dos veces', () async {
      final tree = ModelTreeEntity(
        nodes: [_node(1), _node(2)],
      );

      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
            2: {0: 10},
          },
          sees: {
            1: [_seen(0)],
            2: [_seen(0)],
          },
        ),
        tree,
      );

      // Son dos modelos opinando lo mismo, y el acierto de cada uno se cuenta
      // por separado.
      expect(found, hasLength(2));
    });
  });

  group('parar', () {
    test('cancelar deja de mirar', () async {
      final token = CancellationToken()..cancel();

      await expectLater(
        recognizer().recognize(
          mediaId: 7,
          path: 'C:/fotos/uno.jpg',
          tree: ModelTreeEntity(nodes: [_node(1)]),
          token: token,
        ),
        throwsA(isA<JobCancelledException>()),
      );
    });
  });
}
