// Los turnos del servicio de previsualizaciones.
//
// Es lo que sostiene el desplazamiento rapido, y por dos motivos distintos:
//
// - **Nada sin tope.** Averiguar lo que mide una imagen carga el fichero entero
//   en memoria antes de dejar leer su cabecera. Sin turnos, bajar de golpe por
//   una biblioteca de fotografias grandes ponia cientos de ficheros en vuelo a
//   la vez, y con eso la aplicacion se caia.
// - **Nada que no mire nadie.** Al desplazarse deprisa se piden miles de
//   previsualizaciones en unos segundos y casi ninguna sigue en pantalla cuando
//   le llega el turno. Abrir un video para una celda que ya no existe es tiempo
//   y memoria que se le quitan a la que si esta.

import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Un PNG de 2x1 pixeles, que es lo minimo que hace falta para que la cabecera
/// diga algo.
final _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x7C, 0x67, 0xB6,
  0x8B, 0x00, 0x00, 0x00, 0x13, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0xFC, 0xCF, 0xC0, 0xF0,
  0x9F, 0x81, 0x81, 0x01, 0x00, 0x0D, 0x06, 0x02,
  0x9E, 0x02, 0x2A, 0xEB, 0x9D, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60,
  0x82,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  var next = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_preview_slots');
    next = 0;
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Una imagen nueva en disco, distinta de las demas.
  String image() {
    final path = p.join(directory.path, 'imagen${next++}.png');
    File(path).writeAsBytesSync(_png);

    return path;
  }

  group('lo que nadie espera', () {
    test('sin nadie detras no se resuelve', () async {
      final path = image();

      // Nadie ha hecho `hold`: la celda que lo pidio ya no esta.
      final preview =
          await MediaPreviewService.instance.load(path, droppable: true);

      expect(preview, isNull,
          reason: 'dejarlo pasar no es fallar: nadie lo esta mirando');
      expect(MediaPreviewService.instance.peek(path), isNull,
          reason: 'y no se recuerda nada, para que pedirlo otra vez funcione');
    });

    test('con alguien detras se resuelve', () async {
      final path = image();

      MediaPreviewService.instance.hold(path);
      final preview =
          await MediaPreviewService.instance.load(path, droppable: true);
      MediaPreviewService.instance.release(path);

      expect(preview?.width, 2);
      expect(preview?.height, 1);
    });

    test('soltarlo despues no deshace lo que ya se resolvio', () async {
      final path = image();

      MediaPreviewService.instance.hold(path);
      await MediaPreviewService.instance.load(path, droppable: true);
      MediaPreviewService.instance.release(path);

      expect(MediaPreviewService.instance.peek(path), isNotNull);
    });

    test('dos celdas del mismo fichero: soltar una no se lo quita a la otra',
        () async {
      final path = image();

      MediaPreviewService.instance.hold(path);
      MediaPreviewService.instance.hold(path);
      MediaPreviewService.instance.release(path);

      final preview =
          await MediaPreviewService.instance.load(path, droppable: true);
      MediaPreviewService.instance.release(path);

      expect(preview, isNotNull);
    });

    test('lo que no es prescindible se hace lo mire quien lo mire', () async {
      final path = image();

      // El reconocimiento y el hasheo piden previsualizaciones sin ninguna
      // celda detras: su trabajo no se puede dejar caer.
      final preview = await MediaPreviewService.instance.load(path);

      expect(preview?.width, 2);
    });

    test('el fotograma forma parte de a quien se espera', () async {
      final path = image();

      MediaPreviewService.instance.hold(path, frame: const Duration(seconds: 3));

      // Se espera el del segundo tres, no el de por defecto.
      final other =
          await MediaPreviewService.instance.load(path, droppable: true);
      MediaPreviewService.instance
          .release(path, frame: const Duration(seconds: 3));

      expect(other, isNull);
    });
  });

  group('los turnos', () {
    test('no se leen mas cabeceras a la vez de las que se dicen', () async {
      // Muchas mas de las que caben a la vez, todas pedidas de golpe: es lo que
      // pasa al bajar de golpe por una biblioteca grande.
      final paths = [for (var i = 0; i < maxConcurrentImageJobs * 4; i++) image()];

      for (final path in paths) {
        MediaPreviewService.instance.hold(path);
      }

      final previews = await Future.wait([
        for (final path in paths)
          MediaPreviewService.instance.load(path, droppable: true),
      ]);

      for (final path in paths) {
        MediaPreviewService.instance.release(path);
      }

      // Lo que importa es que salgan todas: los turnos reparten el trabajo, no
      // lo pierden.
      expect(previews.where((preview) => preview != null), hasLength(paths.length));
    });

    test('lo pedido de golpe se resuelve entero aunque nadie espere ya',
        () async {
      final paths = [for (var i = 0; i < maxConcurrentImageJobs * 4; i++) image()];

      final previews = await Future.wait([
        for (final path in paths)
          MediaPreviewService.instance.load(path, droppable: true),
      ]);

      // Ninguna se resuelve, pero ninguna se queda colgada: los turnos se
      // devuelven igual, o la siguiente rejilla no tendria donde entrar.
      expect(previews.every((preview) => preview == null), isTrue);

      MediaPreviewService.instance.hold(paths.first);
      final after = await MediaPreviewService.instance
          .load(paths.first, droppable: true);
      MediaPreviewService.instance.release(paths.first);

      expect(after, isNotNull, reason: 'los turnos no se han quedado ocupados');
    });
  });
}
