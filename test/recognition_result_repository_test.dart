// Las sugerencias, guardadas.
//
// Se prueba contra una base de datos de verdad porque lo que importa es lo que
// pasa **entre** dos tablas: la marca de «tiene algo sin mirar» vive en el
// sumario del contenido y las sugerencias en otra colección. Si se separan, la
// pantalla de importación filtra por una cosa y enseña otra, y no hay forma de
// que el usuario entienda por que un contenido aparece vacio.
//
// Y que reconocer otra vez **no borre lo ya contestado**: es la unica medida del
// acierto real de un modelo, y ademas volveria a preguntar por algo que el
// usuario ya decidio.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media_tag_log_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_result_model.dart';
import 'package:Fern/features/recognition/data/repositories/recognition_result_repository_impl.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late RecognitionResultRepositoryImpl repository;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilación de la aplicación '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_results_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        MediaTagLogModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
        ModelTreeNodeModelSchema,
        ModelTreeEdgeModelSchema,
        RecognitionResultModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    repository = RecognitionResultRepositoryImpl(database: isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Da de alta un contenido y devuelve su identificador.
  Future<int> addMedia(int id) async {
    final summary = MediaSummaryModel()
      ..id = id
      ..path = 'C:/media/$id.jpg';

    await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));

    return id;
  }

  RecognitionResultEntity suggestion(
    int mediaId, {
    int fernieId = 10,
    int modelId = 1,
    double confidence = 0.9,
  }) {
    return RecognitionResultEntity(
      mediaId: mediaId,
      modelId: modelId,
      fernieId: fernieId,
      confidence: confidence,
      createdAt: DateTime(2026),
    );
  }

  Future<MediaSummaryModel> summaryOf(int id) async =>
      (await isar.mediaSummaryModels.get(id))!;

  group('guardar lo propuesto', () {
    test('se guarda y se puede leer', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media)],
      );

      final found = await repository.getForMedia(media);

      expect(found.data, hasLength(1));
      expect(found.data!.single.fernieId, 10);
      expect(found.data!.single.status, SuggestionStatus.suggested);
    });

    test('sale de mas seguro a menos', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [
          suggestion(media, fernieId: 10, confidence: 0.4),
          suggestion(media, fernieId: 20, confidence: 0.95),
          suggestion(media, fernieId: 30, confidence: 0.7),
        ],
      );

      final found = (await repository.getForMedia(media)).data!;

      // Quien abre esto viene a decir que si o que no: lo que mas probablemente
      // sea correcto es lo primero que quiere ver.
      expect(found.map((one) => one.fernieId), [20, 30, 10]);
    });

    test('el contenido queda marcado como pendiente', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media)],
      );

      // La marca esta en el sumario para poder filtrar la rejilla sin preguntar
      // por las sugerencias de cada elemento.
      expect((await summaryOf(media)).hasPendingSuggestions, isTrue);
      expect((await summaryOf(media)).recognizedAt, isNotNull);
    });

    test('sin nada propuesto, el contenido queda sin pendientes', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(mediaId: media, results: const []);

      // Se reconocio: lo que pasa es que no habia nada. Y se apunta la fecha,
      // para no volver a mirarlo al reconocer la biblioteca entera.
      expect((await summaryOf(media)).hasPendingSuggestions, isFalse);
      expect((await summaryOf(media)).recognizedAt, isNotNull);
    });
  });

  group('volver a reconocer', () {
    test('reemplaza lo que no se habia mirado', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media, fernieId: 10)],
      );

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media, fernieId: 20)],
      );

      // Reconocer con un modelo mejor tiene que dar **su** respuesta, no la de
      // antes y la de ahora juntas.
      final found = (await repository.getForMedia(media)).data!;
      expect(found.map((one) => one.fernieId), [20]);
    });

    test('no toca lo ya aceptado ni lo rechazado', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [
          suggestion(media, fernieId: 10),
          suggestion(media, fernieId: 20),
        ],
      );

      final existing = (await repository.getForMedia(media)).data!;
      await repository.setStatus(
        id: existing.first.id,
        status: SuggestionStatus.accepted,
      );

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media, fernieId: 30)],
      );

      final found = (await repository.getForMedia(media)).data!;

      // Lo contestado es la unica medida del acierto real, y ademas volveria a
      // preguntarse por algo que el usuario ya decidio.
      expect(found.map((one) => one.fernieId).toList()..sort(), [10, 30]);
    });

    test('lo de otro contenido no se toca', () async {
      final one = await addMedia(1);
      final two = await addMedia(2);

      await repository.replaceSuggestions(
        mediaId: one,
        results: [suggestion(one)],
      );
      await repository.replaceSuggestions(
        mediaId: two,
        results: [suggestion(two)],
      );

      await repository.replaceSuggestions(mediaId: one, results: const []);

      expect((await repository.getForMedia(two)).data, hasLength(1));
    });
  });

  group('devolver a revisión', () {
    /// Si el contenido sigue siendo definitivo.
    Future<bool> isFinal(int id) async => (await summaryOf(id)).isImported;

    Future<void> addFinal(int id) async {
      final summary = MediaSummaryModel()
        ..id = id
        ..path = 'C:/media/$id.jpg'
        ..isImported = true;

      await isar.writeTxn(() => isar.mediaSummaryModels.put(summary));
    }

    test('lo que recibe una sugerencia deja de ser definitivo', () async {
      await addFinal(1);

      await repository.replaceSuggestions(
        mediaId: 1,
        results: [suggestion(1)],
        returnToReview: true,
      );

      // Una sugerencia sin validar es contenido a medias, y dejarlo en la
      // biblioteca como si nada esconde el trabajo pendiente.
      expect(await isFinal(1), isFalse);
    });

    test('sin sugerencias no se mueve de sitio', () async {
      await addFinal(1);

      await repository.replaceSuggestions(
        mediaId: 1,
        results: const [],
        returnToReview: true,
      );

      // Reconocer algo y no encontrarle nada no es motivo para sacarlo de la
      // biblioteca.
      expect(await isFinal(1), isTrue);
    });

    test('con el ajuste apagado no se mueve nada', () async {
      await addFinal(1);

      await repository.replaceSuggestions(
        mediaId: 1,
        results: [suggestion(1)],
      );

      expect(await isFinal(1), isTrue);

      // Y las sugerencias están igualmente: apagarlo no esconde nada, sólo deja
      // el contenido donde estaba.
      expect((await repository.getForMedia(1)).data, hasLength(1));
    });

    test('se mueve en la misma escritura que la marca', () async {
      await addFinal(1);

      await repository.replaceSuggestions(
        mediaId: 1,
        results: [suggestion(1)],
        returnToReview: true,
      );

      // Entre dos escrituras el contenido estaría en la biblioteca con
      // sugerencias sin revisar, que es justo lo que esto evita.
      final summary = await summaryOf(1);
      expect(summary.isImported, isFalse);
      expect(summary.hasPendingSuggestions, isTrue);
    });
  });

  group('contestar', () {
    test('aceptar deja el contenido sin pendientes si era la ultima', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media)],
      );

      final only = (await repository.getForMedia(media)).data!.single;
      await repository.setStatus(
        id: only.id,
        status: SuggestionStatus.accepted,
      );

      expect((await summaryOf(media)).hasPendingSuggestions, isFalse);
    });

    test('con otra sin mirar, el contenido sigue pendiente', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [
          suggestion(media, fernieId: 10),
          suggestion(media, fernieId: 20),
        ],
      );

      final first = (await repository.getForMedia(media)).data!.first;
      await repository.setStatus(
        id: first.id,
        status: SuggestionStatus.rejected,
      );

      // Apagar la marca sin mirar si queda algo esconderia la otra del filtro
      // para siempre.
      expect((await summaryOf(media)).hasPendingSuggestions, isTrue);
    });

    test('contestar no cuenta como haber vuelto a mirar', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media)],
      );

      final looked = (await summaryOf(media)).recognizedAt;

      final only = (await repository.getForMedia(media)).data!.single;
      await repository.setStatus(
        id: only.id,
        status: SuggestionStatus.accepted,
      );

      // La fecha es de cuando pasaron los modelos por el contenido. Contestar no
      // vuelve a mirar nada, y moverla haria que «reconocido hace un momento»
      // dijera algo que no ha pasado.
      expect((await summaryOf(media)).recognizedAt, looked);
    });

    test('una sugerencia que no existe se dice', () async {
      final result = await repository.setStatus(
        id: 999,
        status: SuggestionStatus.accepted,
      );

      expect(result, isA<DataException>());
    });
  });

  group('la purga', () {
    test('lo rechazado hace tiempo se va', () async {
      final media = await addMedia(1);

      await isar.writeTxn(() => isar.recognitionResultModels.put(
            RecognitionResultModel()
              ..mediaId = media
              ..modelId = 1
              ..fernieId = 10
              ..confidence = 0.5
              ..status = SuggestionStatus.rejected
              ..createdAt = DateTime(2025),
          ));

      final purged = await repository.purgeRejectedBefore(DateTime(2026));

      expect(purged.data, 1);
      expect(await isar.recognitionResultModels.count(), 0);
    });

    test('lo aceptado no se toca por viejo que sea', () async {
      final media = await addMedia(1);

      await isar.writeTxn(() => isar.recognitionResultModels.put(
            RecognitionResultModel()
              ..mediaId = media
              ..modelId = 1
              ..fernieId = 10
              ..confidence = 0.5
              ..status = SuggestionStatus.accepted
              ..createdAt = DateTime(2020),
          ));

      await repository.purgeRejectedBefore(DateTime(2026));

      // Es la unica fuente del acierto real de un modelo.
      expect(await isar.recognitionResultModels.count(), 1);
    });

    test('lo sin mirar tampoco', () async {
      final media = await addMedia(1);

      await repository.replaceSuggestions(
        mediaId: media,
        results: [suggestion(media)],
      );

      await repository.purgeRejectedBefore(DateTime(2030));

      expect(await isar.recognitionResultModels.count(), 1);
    });
  });
}

String? _isarLibrary() {
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';

  final candidates = [
    r'build\windows\x64\runner\Debug\isar.dll',
    r'build\windows\x64\runner\Release\isar.dll',
    '$pubCache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }

  return null;
}
