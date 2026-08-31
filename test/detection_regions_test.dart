// Dónde vio el modelo lo que propone, y cómo eso se convierte en región.
//
// El rectángulo se guardaba al detectar y no se enseñaba en ninguna parte, así
// que la pregunta inmediata al leer «Estrella 66 %» —dónde— no tenía respuesta.
// Y el acierto de un modelo se perdía: había que volver a marcar a mano lo que
// ya estaba bien marcado.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/data/services/suggestion_spotlight.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/usecases/turn_detection_into_region_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSuggestionEntity _suggestion({
  double? x = 0.1,
  double? y = 0.2,
  double? w = 0.3,
  double? h = 0.4,
  int? frameMs,
  int fernieId = 7,
}) {
  return MediaSuggestionEntity(
    result: RecognitionResultEntity(
      id: 1,
      mediaId: 42,
      modelId: 1,
      fernieId: fernieId,
      confidence: 0.9,
      x: x,
      y: y,
      w: w,
      h: h,
      frameMs: frameMs,
      createdAt: DateTime(2026),
    ),
    fernie: FernieEntity(id: fernieId, name: 'Rombo'),
  );
}

/// Una detección señalada, tal y como la manda el panel.
SpottedBox _spot(
  int id,
  ({double x, double y, double w, double h}) box, {
  String label = 'Rombo',
  int? frameMs,
}) =>
    (id: id, box: box, label: label, frameMs: frameMs);

void main() {
  group('la caja de una sugerencia', () {
    test('sale como la apuntó el modelo', () {
      expect(_suggestion().box, (x: 0.1, y: 0.2, w: 0.3, h: 0.4));
    });

    test('sin coordenadas no hay caja', () {
      // Pasa con un fichero que el sidecar no supo medir. La sugerencia vale
      // igual; lo único que no se puede es enseñar dónde.
      expect(_suggestion(x: null).box, isNull);
      expect(_suggestion(w: null).box, isNull);
    });

    test('una caja sin superficie no es una caja', () {
      expect(_suggestion(w: 0).box, isNull);
      expect(_suggestion(h: -0.1).box, isNull);
    });
  });

  group('lo que se señala', () {
    late SuggestionSpotlight spotlight;
    var avisos = 0;

    setUp(() {
      avisos = 0;
      spotlight = SuggestionSpotlight()..addListener(() => avisos++);
    });

    test('señalar guarda la caja y el nombre', () {
      spotlight.show([_spot(1, (x: 0.1, y: 0.2, w: 0.3, h: 0.4), label: 'Rombo')]);

      expect(spotlight.spotted.single.box, (x: 0.1, y: 0.2, w: 0.3, h: 0.4));
      expect(spotlight.spotted.single.label, 'Rombo');
      expect(avisos, 1);
    });

    test('señalar dos veces lo mismo no repinta', () {
      const box = (x: 0.1, y: 0.2, w: 0.3, h: 0.4);

      spotlight.show([_spot(1, box, label: 'Rombo')]);
      spotlight.show([_spot(1, box, label: 'Rombo')]);

      // Mover el ratón dentro de la misma fila dispara `onEnter` más de una
      // vez, y repintar el visor en cada una es trabajo para nada.
      expect(avisos, 1);
    });

    test('señalar otra fila sustituye a la anterior', () {
      spotlight.show([_spot(1, (x: 0.1, y: 0.1, w: 0.1, h: 0.1), label: 'Rombo')]);
      spotlight.show([_spot(1, (x: 0.5, y: 0.5, w: 0.2, h: 0.2), label: 'Cubo')]);

      // Las de **una fila** cada vez: enseñar las de todas a la vez llena el
      // contenido de rectángulos que se pisan, y la pregunta que se contesta es
      // «dónde ha visto **esto**».
      expect(spotlight.spotted.single.label, 'Cubo');
      expect(spotlight.spotted.single.box, (x: 0.5, y: 0.5, w: 0.2, h: 0.2));
    });

    test('dejar de señalar lo apaga', () {
      spotlight.show([_spot(1, (x: 0.1, y: 0.2, w: 0.3, h: 0.4), label: 'Rombo')]);
      spotlight.clear();

      expect(spotlight.isEmpty, isTrue);
      expect(spotlight.spotted, isEmpty);
      expect(avisos, 2);
    });

    test('apagar lo ya apagado no repinta', () {
      spotlight.clear();

      expect(avisos, 0);
    });
  });

  group('dejar la caja puesta', () {
    late SuggestionSpotlight spotlight;

    const box = (x: 0.1, y: 0.2, w: 0.3, h: 0.4);
    const otra = (x: 0.6, y: 0.6, w: 0.2, h: 0.2);

    setUp(() => spotlight = SuggestionSpotlight());

    test('fijar la deja puesta', () {
      expect(spotlight.pin([_spot(1, box, label: 'Rombo')]), isTrue);
      expect(spotlight.spotted.single.box, box);
      expect(spotlight.pinnedId, 1);
    });

    test('el ratón no la quita', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.clear();

      // Quien ha pulsado una fila quiere ver **esa** caja mientras decide, y que
      // se la quite el puntero al moverse es lo que hace inservible el
      // enseñar-al-pasar.
      expect(spotlight.spotted.single.box, box);
    });

    test('el ratón tampoco la cambia por otra', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.show([_spot(2, otra, label: 'Cubo')]);

      expect(spotlight.spotted.single.label, 'Rombo');
    });

    test('volver a pulsar la misma la suelta', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);

      expect(spotlight.pin([_spot(1, box, label: 'Rombo')]), isFalse);
      expect(spotlight.isEmpty, isTrue);
      expect(spotlight.pinnedId, isNull);
    });

    test('pulsar otra cambia a la otra', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.pin([_spot(2, otra, label: 'Cubo')]);

      expect(spotlight.pinnedId, 2);
      expect(spotlight.spotted.single.label, 'Cubo');
    });

    test('contestar la fila que la enseñaba la apaga', () {
      spotlight.show([_spot(7, box, label: 'Rombo')]);
      spotlight.releaseIf([7]);

      // La fila acaba de irse de la lista y ya no puede apagarla ella: sin esto
      // la caja se queda pintada hasta cambiar de contenido.
      expect(spotlight.isEmpty, isTrue);
    });

    test('contestar otra fila no la apaga', () {
      spotlight.show([_spot(7, box, label: 'Rombo')]);
      spotlight.releaseIf([9]);

      expect(spotlight.spotted.single.label, 'Rombo');
    });

    test('contestar la fila fijada también la apaga', () {
      spotlight.pin([_spot(7, box, label: 'Rombo')]);
      spotlight.releaseIf([7]);

      expect(spotlight.isEmpty, isTrue);
      expect(spotlight.pinnedId, isNull);
    });

    test('sin nada puesto no pasa nada', () {
      spotlight.releaseIf([7]);

      expect(spotlight.isEmpty, isTrue);
    });

    test('soltar lo suelta todo, fijado incluido', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.release();

      // Es lo que hay que llamar al cambiar de contenido o al salir del visor:
      // sin esto la caja de una imagen se queda pintada sobre la siguiente, y el
      // ratón no vuelve a mandar nunca.
      expect(spotlight.isEmpty, isTrue);
      expect(spotlight.pinnedId, isNull);
    });

    test('soltado, el ratón manda otra vez', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.release();
      spotlight.show([_spot(2, otra, label: 'Cubo')]);

      expect(spotlight.spotted.single.label, 'Cubo');
    });

    test('soltada, el ratón vuelve a mandar', () {
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.pin([_spot(1, box, label: 'Rombo')]);
      spotlight.show([_spot(2, otra, label: 'Cubo')]);

      expect(spotlight.spotted.single.label, 'Cubo');
    });
  });

  group('convertir la detección en región', () {
    late _FakeFernies fernies;
    late TurnDetectionIntoRegionUseCase usecase;

    setUp(() {
      fernies = _FakeFernies();
      usecase = TurnDetectionIntoRegionUseCase(fernies);
    });

    test('la región queda donde el modelo vio', () async {
      final result = await usecase(params: _suggestion());

      expect(result, isA<DataSuccess<FernieRegionEntity>>());

      final saved = fernies.saved.single;

      expect((saved.x, saved.y, saved.w, saved.h), (0.1, 0.2, 0.3, 0.4));
    });

    test('va al fernie que la vio', () async {
      await usecase(params: _suggestion(fernieId: 99));

      // Lo que se guarda es «aquí hay uno de éstos», y eso es del fernie. La
      // etiqueta que se ponga al contenido es otra decisión.
      expect(fernies.saved.single.fernieId, 99);
      expect(fernies.saved.single.mediaId, 42);
    });

    test('nace sin guardar, para que la base le dé número', () async {
      await usecase(params: _suggestion());

      expect(fernies.saved.single.id, unsavedId);
    });

    test('el fotograma viaja con ella', () async {
      await usecase(params: _suggestion(frameMs: 1500));

      // En un vídeo, una región sin momento está marcada sobre el fotograma
      // equivocado.
      expect(fernies.saved.single.frameMs, 1500);
    });

    test('sin caja no se guarda nada', () async {
      final result = await usecase(params: _suggestion(x: null));

      expect(result, isA<DataException>());
      expect(fernies.saved, isEmpty);
    });

    test('si la base falla, se dice', () async {
      fernies.broken = true;

      expect(await usecase(params: _suggestion()), isA<DataException>());
    });
  });
}

class _FakeFernies implements FernieRepository {
  final saved = <FernieRegionEntity>[];
  var broken = false;

  @override
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  ) async {
    if (broken) return DataException(Exception('no se pudo'));

    saved.addAll(regions);

    return DataSuccess(regions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
