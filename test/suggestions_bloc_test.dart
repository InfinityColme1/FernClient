// El bloc de sugerencias del visor.
//
// Dos cosas de aquí no se pueden arreglar después. La primera es **soltar lo del
// contenido anterior al cambiar**: el panel es de donde se aceptan etiquetas, y
// enseñar aunque sea un instante las sugerencias de otro contenido es el camino
// más corto para etiquetar lo que no es.
//
// La segunda es **releer al terminar el trabajo**. Sin eso, pulsar «reconocer»
// deja al usuario mirando un panel vacío y habría que salir del visor y volver
// a entrar para ver lo que ha salido.

import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/data/services/recognition_job_runner.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_tree_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_states.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeResults results;
  late _FakeFernies fernies;
  late _FakeLibrary library;
  late _FakeTree tree;
  late JobQueue queue;
  late SuggestionsBloc bloc;

  /// Deja que el bloc procese lo que tenga pendiente.
  ///
  /// Los eventos van por una cola interna y leer es asíncrono, así que sin esto
  /// se miraría el estado antes de que hubiera pasado nada.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    results = _FakeResults();
    fernies = _FakeFernies()..rows = {10: _fernie(10, tagId: 1)};
    library = _FakeLibrary();
    // De partida, un modelo entrenado en el árbol: es lo que hace falta para que
    // el botón de reconocer sirva de algo.
    tree = _FakeTree()..nodes = [_node(1, trained: true)];
    queue = JobQueue();

    bloc = SuggestionsBloc(
      getSuggestions: GetMediaSuggestionsUseCase(
        results: results,
        fernies: fernies,
        library: library,
      ),
      answer: AnswerSuggestionsUseCase(results),
      launcher: RecognitionLauncher(
        canRecognize: CanRecognizeUseCase(tree),
        jobs: queue,
      ),
      jobs: queue,
    );
  });

  tearDown(() async {
    await bloc.close();
    queue.dispose();
  });

  group('leer', () {
    test('deja las sugerencias del contenido', () async {
      results.rows = [_result(mediaId: 7)];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      expect(bloc.state.mediaId, 7);
      expect(bloc.state.suggestions, hasLength(1));
      expect(bloc.state.isLoading, isFalse);
    });

    test('cambiar de contenido suelta lo del anterior', () async {
      results.rows = [_result(mediaId: 7)];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();
      expect(bloc.state.suggestions, hasLength(1));

      // Se mira **mientras** lee el siguiente: es el instante en el que un panel
      // descuidado seguiría enseñando lo de antes.
      results.hold = Completer<void>();
      bloc.add(const LoadSuggestionsEvent(8));
      await settle();

      expect(bloc.state.mediaId, 8);
      expect(bloc.state.suggestions, isEmpty);

      results.hold!.complete();
      await settle();
    });

    test('lo que llega tarde de otro contenido se tira', () async {
      results.rows = [_result(mediaId: 7)];
      results.hold = Completer<void>();

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      // Se pasa al siguiente antes de que la lectura del anterior termine.
      final late = results.hold!;
      results.hold = null;
      results.rows = const [];

      bloc.add(const LoadSuggestionsEvent(8));
      await settle();

      late.complete();
      await settle();

      expect(bloc.state.mediaId, 8);
      expect(bloc.state.suggestions, isEmpty);
    });

    test('un fallo al leer deja el panel vacío, no a medias', () async {
      results.fails = true;

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      expect(bloc.state.suggestions, isEmpty);
      expect(bloc.state.isLoading, isFalse);
    });
  });

  group('repartir por secciones', () {
    test('cada enlace va a su sitio', () async {
      fernies.rows = {
        10: _fernie(10, tagId: 1),
        20: _fernie(20, creatorId: 2),
        30: _fernie(30),
      };
      results.rows = [
        _result(mediaId: 7, id: 1, fernieId: 10),
        _result(mediaId: 7, id: 2, fernieId: 20),
        _result(mediaId: 7, id: 3, fernieId: 30),
      ];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      expect(bloc.state.tagSuggestions, hasLength(1));
      expect(bloc.state.creatorSuggestions, hasLength(1));

      // El que no enlaza nada no propone nada, pero la detección sigue
      // guardada: cuenta para el rendimiento del modelo.
      expect(bloc.state.suggestions, hasLength(3));
    });
  });

  group('contestar', () {
    /// Deja el bloc con dos sugerencias sobre el contenido 7.
    Future<List<MediaSuggestionEntity>> loadTwo() async {
      results.rows = [
        _result(mediaId: 7, id: 1),
        _result(mediaId: 7, id: 2),
      ];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      return bloc.state.suggestions;
    }

    test('rechazar quita la fila y baja a la base de datos', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsRejectedEvent([two.first]));
      await settle();

      expect(bloc.state.suggestions, hasLength(1));

      // Rechazar no cambia nada del contenido, así que no hay ningún «Guardar»
      // que pudiera confirmarlo después. Quien rechaza todas y no acepta
      // ninguna ni siquiera enciende el botón de guardar.
      expect(results.answers, [(two.first.id, SuggestionStatus.rejected)]);
    });

    test('aceptar quita la fila pero todavía no escribe', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsAcceptedEvent([two.first]));
      await settle();

      expect(bloc.state.suggestions, hasLength(1));
      expect(bloc.state.accepted, hasLength(1));

      // La etiqueta está entre los cambios sin guardar del contenido: apuntar
      // aquí que se aceptó dejaría la sugerencia contestada y la etiqueta sin
      // poner si el usuario se marchara sin guardar.
      expect(results.answers, isEmpty);
    });

    test('guardar confirma lo aceptado', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsAcceptedEvent(two));
      await settle();

      bloc.add(const SuggestionsCommittedEvent());
      await settle();

      expect(results.answers, [
        (two[0].id, SuggestionStatus.accepted),
        (two[1].id, SuggestionStatus.accepted),
      ]);
      expect(bloc.state.accepted, isEmpty);
    });

    test('guardar dos veces no confirma dos veces', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsAcceptedEvent([two.first]));
      await settle();

      bloc.add(const SuggestionsCommittedEvent());
      await settle();
      bloc.add(const SuggestionsCommittedEvent());
      await settle();

      expect(results.answers, hasLength(1));
    });

    test('guardar sin haber aceptado nada no escribe', () async {
      await loadTwo();

      bloc.add(const SuggestionsCommittedEvent());
      await settle();

      expect(results.answers, isEmpty);
    });

    test('irse sin guardar deja la sugerencia como estaba', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsAcceptedEvent([two.first]));
      await settle();

      // Pasar al siguiente contenido: el `MediaBloc` tira los cambios sin
      // guardar del anterior, y esto tiene que tirar los suyos con ellos.
      bloc.add(const LoadSuggestionsEvent(8));
      await settle();

      expect(bloc.state.accepted, isEmpty);
      expect(results.answers, isEmpty);
    });

    test('lo aceptado sin confirmar no vuelve a la lista', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsAcceptedEvent([two.first]));
      await settle();

      // Vuelve a la lista sólo al releer de verdad, que es lo correcto: en la
      // base de datos sigue sin contestar.
      expect(
        bloc.state.suggestions.map((one) => one.id),
        isNot(contains(two.first.id)),
      );
    });

    test('contestar en bloque contesta todas', () async {
      final two = await loadTwo();

      bloc.add(SuggestionsRejectedEvent(two));
      await settle();

      expect(bloc.state.suggestions, isEmpty);
      expect(results.answers, hasLength(2));
    });

    test('contestar una lista vacía no hace nada', () async {
      await loadTwo();

      bloc.add(const SuggestionsRejectedEvent([]));
      bloc.add(const SuggestionsAcceptedEvent([]));
      await settle();

      expect(bloc.state.suggestions, hasLength(2));
      expect(results.answers, isEmpty);
    });
  });

  group('mandar a reconocer', () {
    test('encola el contenido que se está viendo', () async {
      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      final job = queue.jobs.single;

      expect(bloc.state.lastAttempt, RecognitionAttempt.queued);
      expect(job.type, JobType.recognition);
      expect(job.payload[RecognitionJobRunner.mediaIdsKey], [7]);
      expect(job.priority, JobPriority.high);
    });

    test('sin contenido no encola nada', () async {
      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(queue.jobs, isEmpty);
    });

    test('no encola dos veces el mismo', () async {
      // El trabajo se queda esperando: así sigue vivo mientras se pulsa otra
      // vez, que es lo que pasa cuando alguien pulsa dos veces seguidas.
      queue.register(JobType.recognition, (context) => Completer<void>().future);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();
      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(queue.jobs, hasLength(1));
    });
  });

  group('cuando no hay con qué reconocer', () {
    // Es el caso que hizo que pulsar el botón no hiciera nada visible: un
    // trabajo sin ningún modelo entrenado termina en milisegundos y ni siquiera
    // llega a aparecer en la lista de tareas, así que desde fuera es idéntico a
    // que la función esté rota.

    test('con el árbol vacío no se encola nada, y se cuenta', () async {
      tree.nodes = const [];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(queue.jobs, isEmpty);
      expect(bloc.state.readiness, RecognitionReadiness.noModelsInTree);

      // Sin esto, pulsar el botón no cambia nada de la pantalla y es idéntico a
      // que esté roto.
      expect(bloc.state.lastAttempt, RecognitionAttempt.refused);
      expect(bloc.state.attempts, 1);
    });

    test('pulsar antes de saber si se puede no miente', () async {
      tree.nodes = const [];

      // Sin dejar que la lectura vuelva antes: es lo que pasa al pulsar nada
      // más abrir un contenido. El árbol se mira **al pulsar**, no al abrir,
      // precisamente para que el motivo sea el de verdad y no «no se ha podido
      // leer el árbol».
      bloc.add(const LoadSuggestionsEvent(7));
      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(bloc.state.lastAttempt, RecognitionAttempt.refused);
      expect(bloc.state.readiness, RecognitionReadiness.noModelsInTree);
    });

    test('pedirlo dos veces avisa dos veces', () async {
      tree.nodes = const [];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();
      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      // Con sólo el resultado, la segunda vez no cambiaría nada y volvería a
      // parecer que el botón no hace nada.
      expect(bloc.state.attempts, 2);
    });

    test('un modelo entrenado después deja de rechazarlo', () async {
      tree.nodes = [_node(1, trained: false)];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();
      expect(bloc.state.lastAttempt, RecognitionAttempt.refused);

      // Entrenar desde otra pantalla no puede obligar a salir del visor y
      // volver a entrar.
      tree.nodes = [_node(1, trained: true)];

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(bloc.state.lastAttempt, RecognitionAttempt.queued);
      expect(queue.jobs, hasLength(1));
    });

    test('con modelos sin entrenar tampoco se encola', () async {
      tree.nodes = [_node(1, trained: false), _node(2, trained: false)];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(queue.jobs, isEmpty);

      // El motivo importa: uno se arregla metiendo un modelo en el árbol y el
      // otro entrenándolo, y son dos recados distintos para el usuario.
      expect(bloc.state.readiness, RecognitionReadiness.noTrainedModels);
    });

    test('basta un modelo entrenado entre varios', () async {
      tree.nodes = [_node(1, trained: false), _node(2, trained: true)];

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      // Los que no estén entrenados se saltan sin parar a los demás.
      expect(queue.jobs, hasLength(1));
    });

    test('si el árbol no se puede leer, no se finge que sí', () async {
      tree.fails = true;

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(queue.jobs, isEmpty);
      expect(bloc.state.readiness, RecognitionReadiness.unknown);
    });
  });

  group('cómo acaba un reconocimiento', () {
    test('terminar se cuenta, salga algo o no', () async {
      queue.register(JobType.recognition, (context) async {});

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      final before = bloc.state.finishedRuns;

      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();

      // El botón se apaga mientras trabaja y se enciende al acabar, y eso por sí
      // solo no distingue «no ha visto nada» de «está roto».
      expect(bloc.state.finishedRuns, before + 1);
      expect(bloc.state.lastRunSuggestions, 0);
    });

    test('abrir un contenido no cuenta como reconocimiento', () async {
      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      // Decirlo cada vez que se abre algo sería ruido.
      expect(bloc.state.finishedRuns, 0);
    });

    test('terminar con sugerencias dice cuántas', () async {
      queue.register(JobType.recognition, (context) async {
        results.rows = [_result(mediaId: 7)];
      });

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();

      expect(bloc.state.finishedRuns, 1);
      expect(bloc.state.lastRunSuggestions, 1);
    });

    test('dos veces seguidas avisa dos veces', () async {
      queue.register(JobType.recognition, (context) async {});

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();
      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();

      // Con una bandera en vez de un contador, la segunda vez volvería a parecer
      // que no ha pasado nada.
      expect(bloc.state.finishedRuns, 2);
    });

    test('se guarda el trabajo, para poder llegar a su parte', () async {
      queue.register(JobType.recognition, (context) async {});

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();

      // El parte de lo que hicieron los modelos se guarda por trabajo: sin su
      // identificador, el aviso no tiene a dónde llevar.
      expect(bloc.state.lastJobId, queue.jobs.single.id);
    });
  });

  group('enterarse de la cola', () {
    test('mientras el trabajo vive, el botón sabe que está ocupado', () async {
      queue.register(JobType.recognition, (context) => Completer<void>().future);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();

      expect(bloc.state.isRecognizing, isTrue);
    });

    test('al terminar el trabajo relee solo', () async {
      var runs = 0;
      queue.register(JobType.recognition, (context) async => runs++);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();
      expect(bloc.state.suggestions, isEmpty);

      // El trabajo de mentira no escribe nada, así que se pone aquí lo que
      // habría dejado escrito.
      results.rows = [_result(mediaId: 7)];

      bloc.add(const RecognizeCurrentMediaEvent());
      await _pump();

      expect(runs, 1);
      expect(bloc.state.isRecognizing, isFalse);

      // Sin esto habría que salir del visor y volver a entrar.
      expect(bloc.state.suggestions, hasLength(1));
    });

    test('un trabajo de otro contenido no toca este', () async {
      queue.register(JobType.recognition, (context) => Completer<void>().future);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      queue.enqueue(
        type: JobType.recognition,
        payload: {
          RecognitionJobRunner.mediaIdsKey: [99],
        },
      );
      await settle();

      expect(bloc.state.isRecognizing, isFalse);
    });

    test('un lote que incluye este contenido sí lo toca', () async {
      queue.register(JobType.recognition, (context) => Completer<void>().future);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      // Se puede estar reconociendo la biblioteca entera y haber entrado a
      // mirar justo uno de los de la lista.
      queue.enqueue(
        type: JobType.recognition,
        payload: {
          RecognitionJobRunner.mediaIdsKey: [1, 7, 9],
        },
      );
      await settle();

      expect(bloc.state.isRecognizing, isTrue);
    });

    test('un trabajo de otra clase no cuenta', () async {
      queue.register(JobType.training, (context) => Completer<void>().future);

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      queue.enqueue(
        type: JobType.training,
        payload: {
          RecognitionJobRunner.mediaIdsKey: [7],
        },
      );
      await settle();

      expect(bloc.state.isRecognizing, isFalse);
    });

    test('cancelar también relee', () async {
      // Este sí atiende a la señal: un trabajo que la ignorase se quedaría
      // corriendo para siempre, y lo que se comprueba es lo de después.
      queue.register(
        JobType.recognition,
        (context) => context.token.whenCancelled,
      );

      bloc.add(const LoadSuggestionsEvent(7));
      await settle();

      bloc.add(const RecognizeCurrentMediaEvent());
      await settle();
      expect(bloc.state.isRecognizing, isTrue);

      // Puede haber dejado hechos unos cuantos antes de pararse.
      results.rows = [_result(mediaId: 7)];
      queue.cancel(queue.jobs.single.id);
      await _pump();

      expect(bloc.state.isRecognizing, isFalse);
      expect(bloc.state.suggestions, hasLength(1));
    });
  });
}

/// Da varias vueltas al bucle de eventos.
///
/// La cadena es larga —la cola avisa, el bloc se entera, pide releer y la
/// lectura vuelve—, y una sola vuelta se queda a mitad.
Future<void> _pump() async {
  for (var i = 0; i < 12; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

FernieEntity _fernie(int id, {int? tagId, int? creatorId}) => FernieEntity(
      id: id,
      name: 'fernie-$id',
      linkedTagId: tagId,
      linkedCreatorId: creatorId,
    );

RecognitionResultEntity _result({
  required int mediaId,
  int id = 1,
  int fernieId = 10,
}) {
  return RecognitionResultEntity(
    id: id,
    mediaId: mediaId,
    modelId: 1,
    fernieId: fernieId,
    confidence: 0.9,
    createdAt: DateTime(2026),
  );
}

class _FakeResults implements RecognitionResultRepository {
  List<RecognitionResultEntity> rows = const [];
  bool fails = false;

  /// Lo que se ha contestado, en orden. Es lo que dice si una decisión ha
  /// llegado a la base de datos o se ha quedado en la pantalla.
  final List<(int, SuggestionStatus)> answers = [];

  /// Con esto puesto, leer no vuelve hasta que se complete: es como se mira el
  /// estado del bloc mientras la lectura está a medias.
  Completer<void>? hold;

  @override
  Future<DataState<List<RecognitionResultEntity>>> getForMedia(
    int mediaId,
  ) async {
    await hold?.future;

    if (fails) return DataException(Exception('la base de datos no responde'));

    return DataSuccess([
      for (final row in rows)
        if (row.mediaId == mediaId) row,
    ]);
  }

  @override
  Future<DataState<RecognitionResultEntity>> setStatus({
    required int id,
    required SuggestionStatus status,
  }) async {
    answers.add((id, status));

    final row = rows.firstWhere((one) => one.id == id);

    return DataSuccess(row.copyWith(status: status));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}

class _FakeFernies implements FernieRepository {
  Map<int, FernieEntity> rows = const {};

  @override
  Future<DataState<FernieEntity>> getFernie(int id) async {
    final found = rows[id];

    return found == null
        ? DataException(Exception('no existe'))
        : DataSuccess(found);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}

/// Biblioteca de mentira: la etiqueta 1 existe, y nada más.
class _FakeLibrary implements LocalMediaRepository {
  @override
  Future<DataState<TagEntity?>> getTag(int id) async => DataSuccess(
        id == 1
            ? const TagEntity(id: 1, name: 'Ladybug', children: [])
            : null,
      );

  @override
  Future<DataState<CreatorEntity?>> getCreator(int id) async => DataSuccess(
        id == 2 ? const CreatorEntity(id: 2, name: 'Thomas Astruc') : null,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}

/// Un nodo del árbol, con o sin pesos.
ModelTreeNodeEntity _node(int id, {required bool trained}) {
  return ModelTreeNodeEntity(
    id: id,
    model: RecognitionModelEntity(
      id: id,
      name: 'modelo-$id',
      weightsPath: trained ? 'C:/pesos/best.pt' : null,
      createdAt: DateTime(2026),
    ),
  );
}

/// Árbol de mentira: devuelve los nodos que se le pongan.
class _FakeTree implements ModelTreeRepository {
  List<ModelTreeNodeEntity> nodes = const [];
  bool fails = false;

  @override
  Future<DataState<ModelTreeEntity>> getTree() async {
    if (fails) return DataException(Exception('no se puede leer el árbol'));

    return DataSuccess(ModelTreeEntity(nodes: nodes));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}
