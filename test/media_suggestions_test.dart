// Cómo una fila guardada se convierte en algo que se puede enseñar.
//
// La tabla de resultados sólo tiene números —un modelo, un fernie, una
// confianza—, y con eso no se puede pintar nada. Lo que se comprueba aquí es la
// traducción: qué se enseña, con qué nombre, y sobre todo **qué no llega a
// enseñarse**, que es la parte que puede ensuciar una biblioteca.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _mediaId = 7;

RecognitionResultEntity _result({
  int id = 1,
  int fernieId = 10,
  int modelId = 1,
  double confidence = 0.9,
  SuggestionStatus status = SuggestionStatus.suggested,
}) {
  return RecognitionResultEntity(
    id: id,
    mediaId: _mediaId,
    modelId: modelId,
    fernieId: fernieId,
    confidence: confidence,
    status: status,
    createdAt: DateTime(2026),
  );
}

FernieEntity _fernie(
  int id, {
  String name = 'Fernie',
  String? picturePath,
  int? tagId,
  int? creatorId,
}) {
  return FernieEntity(
    id: id,
    name: name,
    picturePath: picturePath,
    linkedTagId: tagId,
    linkedCreatorId: creatorId,
  );
}

void main() {
  late _FakeResults results;
  late _FakeFernies fernies;
  late _FakeLibrary library;
  late GetMediaSuggestionsUseCase usecase;

  setUp(() {
    results = _FakeResults();
    fernies = _FakeFernies();
    library = _FakeLibrary();

    usecase = GetMediaSuggestionsUseCase(
      results: results,
      fernies: fernies,
      library: library,
    );
  });

  Future<List<MediaSuggestionEntity>> run() async {
    final found = await usecase(params: _mediaId);
    expect(found, isA<DataSuccess<List<MediaSuggestionEntity>>>());

    return found.data!;
  }

  group('qué se enseña', () {
    test('una sugerencia con su fernie', () async {
      results.rows = [_result(fernieId: 10)];
      fernies.rows = {10: _fernie(10, name: 'Marinette')};

      final found = await run();

      expect(found, hasLength(1));
      expect(found.single.fernie.name, 'Marinette');
    });

    test('el nombre y la cara son los de la etiqueta', () async {
      results.rows = [_result(fernieId: 10)];
      fernies.rows = {
        10: _fernie(10, name: 'lady-suit', picturePath: 'fernie.png', tagId: 3),
      };
      library.tags = {
        3: const TagEntity(
          id: 3,
          name: 'Ladybug',
          picturePath: 'tag.png',
          children: [],
        ),
      };

      final one = (await run()).single;

      // Quien mira el panel está decidiendo si le pone **esa etiqueta** al
      // contenido; cómo se llame el fernie por dentro no es asunto suyo. Y la
      // cara es la que va a ver ahí mismo en cuanto acepte.
      expect(one.label, 'Ladybug');
      expect(one.picturePath, 'tag.png');
      expect(one.tag?.id, 3);
    });

    test('sin enlace se cae al nombre del fernie', () async {
      results.rows = [_result(fernieId: 10)];
      fernies.rows = {10: _fernie(10, name: 'escuela')};

      final one = (await run()).single;

      expect(one.label, 'escuela');
      expect(one.proposes, FernieLinkKind.none);
    });

    test('un fernie de creador propone un creador', () async {
      results.rows = [_result(fernieId: 10)];
      fernies.rows = {10: _fernie(10, creatorId: 4)};
      library.creators = {4: const CreatorEntity(id: 4, name: 'Thomas Astruc')};

      final one = (await run()).single;

      expect(one.proposes, FernieLinkKind.creator);
      expect(one.creator?.id, 4);
      expect(one.label, 'Thomas Astruc');
    });

    test('una etiqueta borrada deja la sugerencia sin nada que proponer',
        () async {
      results.rows = [_result(fernieId: 10)];
      fernies.rows = {10: _fernie(10, name: 'lady-suit', tagId: 3)};
      library.tags = const {};

      final one = (await run()).single;

      // El fernie sigue diciendo que enlaza una etiqueta —el identificador
      // sobrevive a que alguien la borre—, pero no hay ninguna que poner. Si
      // esto dijera que propone una etiqueta, el panel enseñaría un botón de
      // aceptar que sólo puede dar un error.
      expect(one.proposes, FernieLinkKind.none);
      expect(one.tag, isNull);
      expect(one.label, 'lady-suit');
    });

    test('dos modelos sobre el mismo fernie dan dos sugerencias', () async {
      results.rows = [
        _result(id: 1, fernieId: 10, modelId: 1),
        _result(id: 2, fernieId: 10, modelId: 2),
      ];
      fernies.rows = {10: _fernie(10)};

      // Son dos opiniones distintas, y el acierto de cada modelo se cuenta por
      // separado.
      expect(await run(), hasLength(2));

      // El fernie se lee una vez aunque lo propongan los dos.
      expect(fernies.reads, [10]);
    });
  });

  group('qué no se enseña', () {
    test('lo ya aceptado', () async {
      results.rows = [_result(status: SuggestionStatus.accepted)];
      fernies.rows = {10: _fernie(10)};

      // Ya está puesto en el contenido: volver a enseñarlo sería volver a
      // preguntar lo mismo.
      expect(await run(), isEmpty);
    });

    test('lo ya rechazado', () async {
      results.rows = [_result(status: SuggestionStatus.rejected)];
      fernies.rows = {10: _fernie(10)};

      expect(await run(), isEmpty);
    });

    test('lo de un fernie que ya no existe', () async {
      results.rows = [_result(fernieId: 10), _result(id: 2, fernieId: 99)];
      fernies.rows = {10: _fernie(10)};

      // Borrar un fernie no borra lo que se propuso con él, y una sugerencia sin
      // nombre ni cara no se puede ni entender ni aceptar.
      final found = await run();

      expect(found, hasLength(1));
      expect(found.single.fernie.id, 10);
    });

    test('sin nada guardado no se lee ningún fernie', () async {
      results.rows = const [];

      expect(await run(), isEmpty);
      expect(fernies.reads, isEmpty);
    });
  });

  group('cuando algo falla', () {
    test('un fallo al leer se dice, no se calla con una lista vacía', () async {
      results.fails = true;

      // Devolver «no hay sugerencias» cuando lo que pasa es que no se han podido
      // leer haría creer que el modelo no ha visto nada.
      expect(await usecase(params: _mediaId), isA<DataException>());
    });
  });

  group('los tramos de confianza', () {
    MediaSuggestionEntity at(double confidence) => MediaSuggestionEntity(
          result: _result(confidence: confidence),
          fernie: _fernie(10),
        );

    test('el listón alto es el mismo que el de la aceptación masiva', () {
      expect(at(0.80).level, SuggestionConfidence.high);
      expect(at(0.79).level, SuggestionConfidence.medium);
    });

    test('por debajo de la mitad es poco fiable', () {
      expect(at(0.50).level, SuggestionConfidence.medium);
      expect(at(0.49).level, SuggestionConfidence.low);
    });

    test('el porcentaje va sin decimales', () {
      expect(at(0.924).percent, 92);
      expect(at(0.927).percent, 93);
      expect(at(1).percent, 100);
    });
  });
}

/// Resultados de mentira: devuelve lo que se le ponga.
class _FakeResults implements RecognitionResultRepository {
  List<RecognitionResultEntity> rows = const [];
  bool fails = false;

  @override
  Future<DataState<List<RecognitionResultEntity>>> getForMedia(
    int mediaId,
  ) async {
    if (fails) return DataException(Exception('la base de datos no responde'));

    return DataSuccess([
      for (final row in rows)
        if (row.mediaId == mediaId) row,
    ]);
  }

  @override
  Future<DataState<int>> replaceSuggestions({
    required int mediaId,
    required List<RecognitionResultEntity> results,
    bool returnToReview = false,
  }) async =>
      const DataSuccess(0);

  @override
  Future<DataState<RecognitionResultEntity>> setStatus({
    required int id,
    required SuggestionStatus status,
  }) async =>
      DataException(Exception('aquí no se contesta nada'));

  @override
  Future<DataState<int>> purgeRejectedBefore(DateTime before) async =>
      const DataSuccess(0);
}

/// Fernies de mentira que apunta a cuáles le han preguntado.
class _FakeFernies implements FernieRepository {
  Map<int, FernieEntity> rows = const {};
  final List<int> reads = [];

  @override
  Future<DataState<FernieEntity>> getFernie(int id) async {
    reads.add(id);

    final found = rows[id];

    return found == null
        ? DataException(Exception('no existe'))
        : DataSuccess(found);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}

/// Biblioteca de mentira: sólo sabe de etiquetas y creadores por identificador.
class _FakeLibrary implements LocalMediaRepository {
  Map<int, TagEntity> tags = const {};
  Map<int, CreatorEntity> creators = const {};

  @override
  Future<DataState<TagEntity?>> getTag(int id) async => DataSuccess(tags[id]);

  @override
  Future<DataState<CreatorEntity?>> getCreator(int id) async =>
      DataSuccess(creators[id]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} no hace falta aquí');
}
