// Marcar de una vez todo el contenido de una etiqueta como regiones de un
// fernie.
//
// Montar un fernie desde cero era abrir contenido a contenido y marcar el
// fotograma entero en cada uno. Cuando la etiqueta ya dice de qué va todo lo que
// lleva, ese trabajo es mecánico y se puede pedir de una vez.
//
// Lo que hay que sostener aquí, por orden de lo que más duele si falla:
//
// - **El muestreo.** El conjunto de entrenamiento saca una imagen por región,
//   así que marcar todos los fotogramas de un vídeo lo haría inviable.
// - **Cancelar deja datos coherentes.** Se escribe por tandas, no todo al final:
//   lo hecho está hecho y no se pierde al parar.
// - **No repetir.** Volver a pedirlo sobre la misma etiqueta no puede duplicar
//   las regiones que ya estaban.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/data/services/tag_regions_job_runner.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _fernieId = 7;
const _tagId = 3;

MediaSummaryEntity _media(int id, String name) =>
    MediaSummaryEntity(id: id, path: r'C:\biblioteca\' '$name');

void main() {
  late _FakeMedia media;
  late _FakeFernies fernies;
  late CancellationToken token;
  late List<int> progress;

  /// Se para en cuanto el trabajo avisa de que va por aquí.
  int? stopAfter;

  /// A quién se ha avisado de que ya está.
  late List<int> finished;

  setUp(() {
    media = _FakeMedia();
    fernies = _FakeFernies();
    token = CancellationToken();
    progress = [];
    stopAfter = null;
    finished = [];
  });

  Future<void> run({int samples = 3, Duration? videoLasts}) {
    final runner = TagRegionsJobRunner(
      media: media,
      fernies: fernies,
      durationOf: (_) async => videoLasts,
      onFinished: (fernieId) async => finished.add(fernieId),
    );

    return runner.run(JobContext(
      job: Job(
        id: 'uno',
        type: JobType.tagRegions,
        createdAt: DateTime(2026),
        payload: {
          TagRegionsJobRunner.fernieKey: _fernieId,
          TagRegionsJobRunner.tagKey: _tagId,
          TagRegionsJobRunner.samplesKey: samples,
        },
      ),
      token: token,
      report: (done, {total, stage}) {
        progress.add(done);
        if (done == stopAfter) token.cancel();
      },
    ));
  }

  group('las imágenes', () {
    test('reciben una región con el fotograma entero', () async {
      media.byTag = [_media(1, 'una.png')];

      await run();

      final region = fernies.written.single;
      expect(region.mediaId, 1);
      expect(region.fernieId, _fernieId);
      expect([region.x, region.y, region.w, region.h], [0, 0, 1, 1]);
    });

    // En una imagen el fotograma no significa nada.
    test('sin fotograma', () async {
      media.byTag = [_media(1, 'una.png')];

      await run();

      expect(fernies.written.single.frameMs, isNull);
    });

    test('una por cada una', () async {
      media.byTag = [_media(1, 'a.png'), _media(2, 'b.jpg'), _media(3, 'c.webp')];

      await run();

      expect(fernies.written.map((each) => each.mediaId), [1, 2, 3]);
    });
  });

  group('lo que se mueve', () {
    // La razón de que esto exista: el entrenamiento saca una imagen por región,
    // así que «todos los fotogramas» de un vídeo serían miles de recortes casi
    // idénticos.
    test('se muestrea, no se marca entero', () async {
      media.byTag = [_media(1, 'un.mp4')];

      await run(samples: 3, videoLasts: const Duration(seconds: 30));

      expect(fernies.written, hasLength(3));
    });

    test('los fotogramas se reparten a lo largo', () async {
      media.byTag = [_media(1, 'un.mp4')];

      await run(samples: 3, videoLasts: const Duration(seconds: 30));

      final frames = [for (final each in fernies.written) each.frameMs!];

      expect(frames, frames.toList()..sort(), reason: 'en orden');
      expect(frames.toSet(), hasLength(3), reason: 'sin repetir');
      expect(frames.last, lessThan(30000));
    });

    test('los GIF van por el mismo camino', () async {
      media.byTag = [_media(1, 'uno.gif')];

      await run(samples: 2, videoLasts: const Duration(seconds: 4));

      expect(fernies.written, hasLength(2));
    });

    // Un vídeo cuya duración no se puede leer se marca igual: perderlo del todo
    // es peor que marcarle sólo el principio.
    test('sin saber cuánto dura se marca el principio', () async {
      media.byTag = [_media(1, 'roto.mp4')];

      await run(videoLasts: null);

      expect(fernies.written.single.frameMs, 0);
    });
  });

  group('lo que ya estaba', () {
    test('no se vuelve a marcar', () async {
      media.byTag = [_media(1, 'una.png')];
      fernies.existing = [
        FernieRegionEntity(
          id: 1,
          mediaId: 1,
          fernieId: _fernieId,
          x: 0,
          y: 0,
          w: 1,
          h: 1,
        ),
      ];

      await run();

      expect(fernies.written, isEmpty);
    });

    // Por fotograma, no por contenido: un vídeo puede tener marcado un momento
    // y no los demás.
    test('pero los fotogramas que faltan sí', () async {
      media.byTag = [_media(1, 'un.mp4')];
      fernies.existing = [
        FernieRegionEntity(
          id: 1,
          mediaId: 1,
          fernieId: _fernieId,
          x: 0,
          y: 0,
          w: 1,
          h: 1,
          frameMs: 5000,
        ),
      ];

      await run(samples: 3, videoLasts: const Duration(seconds: 30));

      // El muestreo da tres momentos y uno de ellos ya estaba marcado: entran
      // los otros dos y ése se salta.
      expect(fernies.written, hasLength(2));
      expect(
        fernies.written.map((each) => each.frameMs),
        isNot(contains(5000)),
      );
    });
  });

  group('parar a mitad', () {
    test('deja escrito lo que ya había hecho', () async {
      media.byTag = [for (var id = 1; id <= 5; id++) _media(id, '$id.png')];
      stopAfter = 1;

      await run();

      // Lo hecho está hecho: lo que se llevaba mirado se escribe igual, no se
      // pierde por haber parado.
      expect(fernies.written, hasLength(1));
    });

    test('y no sigue mirando el resto', () async {
      media.byTag = [for (var id = 1; id <= 5; id++) _media(id, '$id.png')];
      stopAfter = 1;

      await run();

      // El cero de salida y el primero; de los cinco no se miran los otros
      // cuatro.
      expect(progress, [0, 1]);
    });
  });

  group('lo que no hace', () {
    test('con una etiqueta vacía no escribe nada', () async {
      media.byTag = const [];

      await run();

      expect(fernies.written, isEmpty);
      // Ni siquiera el cero de salida: no hay nada de lo que informar.
      expect(progress, isEmpty);
    });

    // Va sobre lo que la etiqueta devuelve, y eso ya viene recortado por el
    // filtro: el trabajo no puede enseñar por la puerta de atrás lo que la
    // pantalla esconde.
    test('sólo mira lo que la etiqueta le da', () async {
      media.byTag = [_media(1, 'una.png')];

      await run();

      expect(media.askedFor, [_tagId]);
    });
  });

  // El trabajo corre en la cola, así que quien lo pidió puede seguir con la
  // ficha del fernie delante: sin avisar, las regiones estaban en la base y no
  // en la rejilla, y había que salir de la pantalla y volver a entrar.
  group('avisar de que ya está', () {
    test('se avisa al terminar, con el fernie', () async {
      media.byTag = [_media(1, 'una.png')];

      await run();

      expect(finished, [_fernieId]);
    });

    // Lo escrito hasta donde se paró está escrito, y la pantalla tiene que
    // enseñarlo igual.
    test('y también si se para a mitad', () async {
      media.byTag = [for (var id = 1; id <= 5; id++) _media(id, '$id.png')];
      stopAfter = 1;

      await run();

      expect(finished, [_fernieId]);
    });

    // Sin nada que hacer no hay nada que releer: avisar movería la pantalla para
    // enseñar lo mismo.
    test('con una etiqueta vacía no se avisa', () async {
      media.byTag = const [];

      await run();

      expect(finished, isEmpty);
    });
  });
}

class _FakeMedia implements LocalMediaRepository {
  List<MediaSummaryEntity> byTag = const [];
  final askedFor = <int>[];

  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaByTag(int tagId) async {
    askedFor.add(tagId);

    return DataSuccess(byTag);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeFernies implements FernieRepository {
  final written = <FernieRegionEntity>[];
  List<FernieRegionEntity> existing = const [];

  @override
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfFernie(
    int fernieId,
  ) async =>
      DataSuccess(existing);

  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  ) async {
    written.addAll(regions);

    return DataSuccess(regions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
