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
import 'package:Fern/core/constants/app_constants.dart';
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

/// Lo mismo, pero **en otro sitio**: es lo que distingue dos instancias de la
/// misma cosa de la misma cosa vista dos veces.
RawDetection _seenAt(
  int classIndex,
  double x, {
  double confidence = 0.9,
}) =>
    RawDetection(
      classIndex: classIndex,
      confidence: confidence,
      x: x,
      y: 0.2,
      w: 0.1,
      h: 0.1,
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
    int maxDetections = defaultMaxDetectionsPerClass,
  }) {
    return MediaRecognizer(
      models: _FakeModels(classes),
      frameSamples: () => samples,
      maxDetections: () => maxDetections,
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

      // Dos clases que apuntan al mismo fernie **sobre el mismo sitio** son la
      // misma cosa vista dos veces: contarla dos veces obligaría a decir que sí
      // dos veces sobre el mismo rectángulo.
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

  group('varios contenidos de una vez', () {
    // El recorrido en lote esta demostrado equivalente al de uno en uno en
    // model_tree_traversal_test. Lo que se comprueba aqui es lo de alrededor:
    // que a cada contenido le llegan sus cajas y no las del vecino, que se
    // pregunta una vez por nivel en lugar de una por contenido, y que un
    // fichero que no se puede abrir no se lleva por delante la tanda.

    /// Un reconocedor con predictor de tanda: apunta cuantas veces se le
    /// pregunta y con cuantas imagenes cada vez.
    ({MediaRecognizer subject, List<List<String>> calls}) batched({
      Map<int, Map<int, int>> classes = const {
        1: {0: 10},
      },
      Map<String, List<RawDetection>> sees = const {},
      Set<String> unreadable = const {},
    }) {
      final calls = <List<String>>[];

      return (
        calls: calls,
        subject: MediaRecognizer(
          models: _FakeModels(classes),
          durationOf: (_) async => null,
          extractFrames: (_, at) async => const [],
          predict: (model, imagePath, conf) async => sees[imagePath] ?? const [],
          predictMany: (model, imagePaths, conf, token) async {
            calls.add(imagePaths);

            return [
              for (final path in imagePaths) sees[path] ?? const <RawDetection>[],
            ];
          },
        ),
      );
    }

    test('a cada contenido le llegan sus cajas', () async {
      final harness = batched(
        classes: const {
          1: {0: 10, 1: 20},
        },
        sees: {
          'C:/fotos/uno.jpg': [_seen(0)],
          'C:/fotos/dos.jpg': [_seen(1)],
        },
      );

      final result = await harness.subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/fotos/uno.jpg'),
          RecognitionTarget(mediaId: 2, path: 'C:/fotos/dos.jpg'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(result, isA<DataSuccess>());

      // Repartir mal no da un error: da la sugerencia de un contenido puesta en
      // otro, y el usuario la acepta sin enterarse.
      expect(result.data![1]!.suggestions.single.fernieId, 10);
      expect(result.data![2]!.suggestions.single.fernieId, 20);
    });

    test('se pregunta una vez por nivel, no una por contenido', () async {
      final harness = batched();

      await harness.subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/fotos/uno.jpg'),
          RecognitionTarget(mediaId: 2, path: 'C:/fotos/dos.jpg'),
          RecognitionTarget(mediaId: 3, path: 'C:/fotos/tres.jpg'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(harness.calls, hasLength(1));
      expect(harness.calls.single, [
        'C:/fotos/uno.jpg',
        'C:/fotos/dos.jpg',
        'C:/fotos/tres.jpg',
      ]);
    });

    test('cada contenido se lleva su parte, con o sin sugerencias', () async {
      final harness = batched(
        sees: {
          'C:/fotos/uno.jpg': [_seen(0)],
        },
      );

      final result = await harness.subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/fotos/uno.jpg'),
          RecognitionTarget(mediaId: 2, path: 'C:/fotos/dos.jpg'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      // Es justamente cuando no sale ninguna sugerencia cuando alguien abre el
      // parte, asi que el que no propuso nada tambien tiene el suyo.
      expect(result.data![1]!.log.name, 'uno.jpg');
      expect(result.data![2]!.log.name, 'dos.jpg');
      expect(result.data![2]!.suggestions, isEmpty);
      expect(result.data![2]!.log.models, hasLength(1));
    });

    test('un fichero que no se puede abrir no se lleva la tanda', () async {
      final calls = <List<String>>[];

      final subject = MediaRecognizer(
        models: _FakeModels(const {
          1: {0: 10},
        }),
        durationOf: (path) async {
          if (path.endsWith('roto.mp4')) throw StateError('fichero roto');
          return null;
        },
        extractFrames: (_, at) async => const [],
        predict: (model, imagePath, conf) async => const [],
        predictMany: (model, imagePaths, conf, token) async {
          calls.add(imagePaths);
          return [for (final _ in imagePaths) const <RawDetection>[]];
        },
      );

      final result = await subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/fotos/uno.jpg'),
          RecognitionTarget(mediaId: 2, path: 'C:/videos/roto.mp4'),
          RecognitionTarget(mediaId: 3, path: 'C:/fotos/tres.jpg'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      // En una biblioteca de miles hay ficheros movidos, corruptos y formatos
      // raros: que uno deje sin reconocer a los otros veinticuatro es lo peor
      // que podria hacer esto.
      expect(result.data!.keys.toList()..sort(), [1, 3]);
      expect(calls.single, ['C:/fotos/uno.jpg', 'C:/fotos/tres.jpg']);
    });

    test('los fotogramas de un video van en la misma pregunta', () async {
      final calls = <List<String>>[];

      final subject = MediaRecognizer(
        models: _FakeModels(const {
          1: {0: 10},
        }),
        frameSamples: () => 3,
        durationOf: (_) async => const Duration(seconds: 3),
        extractFrames: (path, at) async => [
          for (final moment in at)
            SampledFrame(
              path: 'C:/cache/${moment.inMilliseconds}.jpg',
              frameMs: moment.inMilliseconds,
            ),
        ],
        predict: (model, imagePath, conf) async => const [],
        predictMany: (model, imagePaths, conf, token) async {
          calls.add(imagePaths);
          return [for (final _ in imagePaths) const <RawDetection>[]];
        },
      );

      await subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/videos/uno.mp4'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      // Un video eran veinte peticiones al motor, una por fotograma.
      expect(calls, hasLength(1));
      expect(calls.single, hasLength(3));
    });

    test('la senal de parada viaja con la pregunta', () async {
      final token = CancellationToken();
      CancellationToken? received;

      final subject = MediaRecognizer(
        models: _FakeModels(const {
          1: {0: 10},
        }),
        durationOf: (_) async => null,
        extractFrames: (_, at) async => const [],
        predict: (model, imagePath, conf) async => const [],
        predictMany: (model, imagePaths, conf, given) async {
          received = given;
          return [for (final _ in imagePaths) const <RawDetection>[]];
        },
      );

      await subject.recognizeMany(
        targets: const [
          RecognitionTarget(mediaId: 1, path: 'C:/fotos/uno.jpg'),
        ],
        tree: ModelTreeEntity(nodes: [_node(1)]),
        token: token,
      );

      // Una tanda mandada no se puede cortar desde aqui: lo unico que se puede
      // hacer es que la senal llegue hasta el motor.
      expect(received, same(token));
    });

    test('sin nada a lo que mirar no se pregunta', () async {
      final harness = batched();

      final result = await harness.subject.recognizeMany(
        targets: const [],
        tree: ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(result.data, isEmpty);
      expect(harness.calls, isEmpty);
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

  // Un modelo puede ver **lo mismo varias veces**: cuatro coches en una foto son
  // cuatro detecciones de la clase «coche», y las cuatro valen porque cada una es
  // una región distinta que se puede marcar. Antes se guardaba sólo la mejor y
  // las otras tres se perdían antes de llegar a la pantalla.
  group('varias veces lo mismo', () {
    test('cada instancia se queda', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
          },
          sees: {
            1: [_seenAt(0, 0.1), _seenAt(0, 0.4), _seenAt(0, 0.7)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(found, hasLength(3));
      expect(found.every((each) => each.fernieId == 10), isTrue);
    });

    test('con su sitio cada una', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
          },
          sees: {
            1: [_seenAt(0, 0.1), _seenAt(0, 0.4)],
          },
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect({for (final each in found) each.x}, {0.1, 0.4});
    });

    // Una foto de un aparcamiento puede dar cincuenta: sin tope son cincuenta
    // filas por contenido y un panel imposible de leer.
    test('hasta el tope que se diga', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
          },
          sees: {
            1: [
              for (var index = 0; index < 10; index++)
                _seenAt(0, index / 20, confidence: 0.5 + index / 100),
            ],
          },
          maxDetections: 4,
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(found, hasLength(4));
    });

    // Y las que se quedan son las mejores, no las primeras que llegaron.
    test('y son las más seguras', () async {
      final found = await run(
        recognizer(
          classes: const {
            1: {0: 10},
          },
          sees: {
            1: [
              _seenAt(0, 0.1, confidence: 0.5),
              _seenAt(0, 0.4, confidence: 0.9),
              _seenAt(0, 0.7, confidence: 0.7),
            ],
          },
          maxDetections: 2,
        ),
        ModelTreeEntity(nodes: [_node(1)]),
      );

      expect(
        {for (final each in found) each.confidence},
        {0.9, 0.7},
      );
    });
  });
}
