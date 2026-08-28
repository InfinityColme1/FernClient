// Aceptar de golpe lo que los modelos ven con más seguridad.
//
// Es lo que hace usable revisar trescientos contenidos, y por eso mismo es lo
// que más daño puede hacer: escribe etiquetas sobre muchos contenidos a la vez y
// sin que nadie mire una por una. Lo que se comprueba aquí es que **sólo** hace
// eso: que no toca lo que no llega al listón, que no da nada por definitivo, y
// que un contenido que falle no se lleva por delante a los demás.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/media/suggestion_filter.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/accept_suggestions_above_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

RecognitionResultEntity _result({
  required int id,
  required int mediaId,
  required int fernieId,
  required double confidence,
}) {
  return RecognitionResultEntity(
    id: id,
    mediaId: mediaId,
    modelId: 1,
    fernieId: fernieId,
    confidence: confidence,
    createdAt: DateTime(2026),
  );
}

void main() {
  late _FakeResults results;
  late _FakeFernies fernies;
  late _FakeLibrary library;
  late AcceptSuggestionsAboveUseCase usecase;

  setUp(() {
    results = _FakeResults();
    // 10 enlaza la etiqueta 1; 11 la etiqueta 2; 20 enlaza el creador 5.
    fernies = _FakeFernies();
    library = _FakeLibrary();

    usecase = AcceptSuggestionsAboveUseCase(
      getSuggestions: GetMediaSuggestionsUseCase(
        results: results,
        fernies: fernies,
        library: library,
      ),
      answer: AnswerSuggestionsUseCase(results),
      library: library,
    );
  });

  Future<BulkAcceptResult> accept(
    List<int> mediaIds, {
    double threshold = suggestionHighConfidence,
  }) async {
    final result = await usecase(
      params: AcceptAboveParams(mediaIds: mediaIds, threshold: threshold),
    );

    expect(result, isA<DataSuccess<BulkAcceptResult>>());

    return result.data!;
  }

  group('qué se acepta', () {
    test('lo que pasa el listón', () async {
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9)];

      final done = await accept([7]);

      expect(done.accepted, 1);
      expect(library.tagsAdded[7], [1]);
      expect(results.answers, [(1, SuggestionStatus.accepted)]);
    });

    test('lo que no llega se queda sin tocar', () async {
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.7)];

      final done = await accept([7]);

      // Aceptar sin mirar lo que el modelo no tiene claro es justo lo que este
      // botón no puede hacer: son etiquetas escritas sobre cientos de
      // contenidos sin que nadie las lea.
      expect(done.accepted, 0);
      expect(library.tagsAdded, isEmpty);
      expect(results.answers, isEmpty);
    });

    test('el listón se puede mover', () async {
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.7)];

      expect((await accept([7], threshold: 0.5)).accepted, 1);
    });

    test('lo que no propone nada no se acepta', () async {
      // El fernie 99 no enlaza ninguna etiqueta ni ningún creador: no hay nada
      // que poner, así que aceptarlo no significaría nada.
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 99, confidence: 0.9)];

      final done = await accept([7]);

      expect(done.accepted, 0);
      expect(library.tagsAdded, isEmpty);
    });
  });

  group('lo que escribe', () {
    test('varias etiquetas van de una sola escritura', () async {
      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9),
        _result(id: 2, mediaId: 7, fernieId: 11, confidence: 0.85),
      ];

      await accept([7]);

      expect(library.tagsAdded[7]!.toList()..sort(), [1, 2]);
      expect(library.writes, 1);
    });

    test('el creador que gana es el más seguro', () async {
      fernies.rows[21] = FernieEntity(id: 21, name: 'otro', linkedCreatorId: 6);

      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 20, confidence: 0.85),
        _result(id: 2, mediaId: 7, fernieId: 21, confidence: 0.95),
      ];

      await accept([7]);

      // El creador es uno solo: si dos modelos proponen dos distintos hay que
      // elegir, y elegir el más seguro es lo único defendible.
      expect(library.creatorOf[7], 6);
    });

    test('con la etiqueta van las que están por encima', () async {
      // La jerarquía la resuelve el repositorio, igual que al ponerla a mano:
      // aceptar «Rombo simple» sin poner «Rombo» deja el contenido fuera de las
      // búsquedas por la etiqueta padre.
      library.ancestors[1] = [100];

      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9)];

      await accept([7]);

      expect(library.tagsAdded[7]!.toList()..sort(), [1, 100]);
    });

    test('no da el contenido por definitivo', () async {
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9)];

      await accept([7]);

      // Aceptar etiquetas y dar por revisado son dos cosas, y en la pantalla de
      // importación hay un botón de confirmar justo al lado.
      expect(library.confirmed, isEmpty);
    });
  });

  group('en lote', () {
    test('recorre todos los contenidos', () async {
      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9),
        _result(id: 2, mediaId: 8, fernieId: 10, confidence: 0.9),
      ];

      final done = await accept([7, 8]);

      expect(done.accepted, 2);
      expect(done.mediaTouched, 2);
    });

    test('uno que falla no para el lote', () async {
      library.broken = {7};

      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9),
        _result(id: 2, mediaId: 8, fernieId: 10, confidence: 0.9),
      ];

      final done = await accept([7, 8]);

      // Son decisiones independientes y el usuario ya las ha tomado todas de una
      // vez: que una falle no puede tirar las demás.
      expect(done.accepted, 1);
      expect(library.tagsAdded.containsKey(8), isTrue);
    });

    test('un contenido sin nada que aceptar no cuenta', () async {
      results.rows = [_result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9)];

      final done = await accept([7, 8, 9]);

      expect(done.mediaTouched, 1);
    });
  });

  group('lo que le pide a la base', () {
    test('lo enlazado se lee una vez por fernie, no por sugerencia', () async {
      // Dos modelos que proponen el mismo fernie: es la misma etiqueta.
      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9),
        _result(id: 2, mediaId: 7, fernieId: 10, confidence: 0.85),
      ];

      await accept([7]);

      expect(library.tagReads, [1]);
    });

    test('un fernie repetido tampoco se lee dos veces', () async {
      results.rows = [
        _result(id: 1, mediaId: 7, fernieId: 10, confidence: 0.9),
        _result(id: 2, mediaId: 7, fernieId: 11, confidence: 0.9),
        _result(id: 3, mediaId: 7, fernieId: 10, confidence: 0.8),
      ];

      await accept([7]);

      expect(library.tagReads..sort(), [1, 2]);
    });
  });

  group('el filtro de la pantalla', () {
    MediaSummaryEntity media({
      bool pending = false,
      DateTime? recognizedAt,
    }) {
      return MediaSummaryEntity(
        id: 1,
        path: 'C:/media/1.jpg',
        hasPendingSuggestions: pending,
        recognizedAt: recognizedAt,
      );
    }

    test('«todo» no deja nada fuera', () {
      expect(SuggestionFilter.all.matches(media()), isTrue);
    });

    test('«con sugerencias» sólo deja lo que tiene algo sin contestar', () {
      expect(
        SuggestionFilter.withSuggestions.matches(media(pending: true)),
        isTrue,
      );
      expect(SuggestionFilter.withSuggestions.matches(media()), isFalse);
    });

    test('«sin mirar nunca» no es lo mismo que «sin sugerencias»', () {
      // Un contenido mirado al que no se le encontró nada ya está hecho, y
      // volver a enseñarlo aquí es pedir que se revise dos veces lo mismo.
      final looked = media(recognizedAt: DateTime(2026));

      expect(SuggestionFilter.neverRecognised.matches(looked), isFalse);
      expect(SuggestionFilter.withSuggestions.matches(looked), isFalse);
      expect(SuggestionFilter.neverRecognised.matches(media()), isTrue);
    });
  });
}

class _FakeResults implements RecognitionResultRepository {
  List<RecognitionResultEntity> rows = const [];
  final answers = <(int, SuggestionStatus)>[];

  @override
  Future<DataState<List<RecognitionResultEntity>>> getForMedia(
    int mediaId,
  ) async {
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

    return DataSuccess(rows.firstWhere((one) => one.id == id));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeFernies implements FernieRepository {
  final Map<int, FernieEntity> rows = {
    10: FernieEntity(id: 10, name: 'uno', linkedTagId: 1),
    11: FernieEntity(id: 11, name: 'dos', linkedTagId: 2),
    20: FernieEntity(id: 20, name: 'autor', linkedCreatorId: 5),
    99: FernieEntity(id: 99, name: 'suelto'),
  };

  @override
  Future<DataState<FernieEntity>> getFernie(int id) async {
    final found = rows[id];

    return found == null
        ? DataException(Exception('no existe'))
        : DataSuccess(found);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeLibrary implements LocalMediaRepository {
  final tagsAdded = <int, List<int>>{};
  final creatorOf = <int, int>{};

  /// Los que se han dado por definitivos. Tiene que quedarse vacío.
  final confirmed = <int>[];

  /// Cuántas escrituras de etiquetas se han hecho.
  var writes = 0;

  /// Contenidos en los que escribir falla.
  Set<int> broken = const {};

  /// Cada lectura de etiqueta, para poder contarlas.
  final tagReads = <int>[];

  @override
  Future<DataState<TagEntity?>> getTag(int id) async {
    tagReads.add(id);

    return DataSuccess(TagEntity(id: id, name: 'etiqueta-$id', children: const []));
  }

  @override
  Future<DataState<CreatorEntity?>> getCreator(int id) async =>
      DataSuccess(CreatorEntity(id: id, name: 'creador-$id'));

  /// Qué etiquetas cuelgan de cuál, como haría la jerarquía de verdad.
  final ancestors = <int, List<int>>{};

  @override
  Future<DataState<int>> addTagsToMedia(int mediaId, List<int> tagIds) async {
    if (broken.contains(mediaId)) {
      return DataException(Exception('no se pudo escribir'));
    }

    writes++;
    tagsAdded[mediaId] = {
      for (final id in tagIds) ...[id, ...?ancestors[id]],
    }.toList();

    return DataSuccess(tagsAdded[mediaId]!.length);
  }

  @override
  Future<DataState<bool>> setMediaCreator(int mediaId, int creatorId) async {
    creatorOf[mediaId] = creatorId;

    return const DataSuccess(true);
  }

  @override
  Future<DataState> saveMedia(media) async {
    confirmed.add(media.id);

    return const DataSuccess(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
