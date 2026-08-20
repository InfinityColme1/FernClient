// Comprueba el mando del contenido que se mueve.
//
// Nace de cuatro fallos reales: el GIF empezaba a reproducirse solo al entrar al
// modo, la linea de tiempo no cuadraba con lo que se veia (el reloj iba a ritmo
// fijo y la imagen al suyo), no habia forma de sacar los fotogramas de en medio
// para arrastrar una region por todos ellos, y en un video habia que pulsar
// varias veces el boton de pasar de fotograma para moverse uno solo.
//
// Lo ultimo es lo que trajo las cuentas por numero de fotograma: comparar
// milisegundos con un margen deja fuera lo que el reproductor devuelve con unas
// micras de diferencia, y decidir si algo es "de este fotograma" con eso no se
// sostiene.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

/// Un GIF de cuatro fotogramas con duraciones desiguales, sin tocar el disco.
GifFrames _frames() {
  const durations = [100, 200, 100, 100];

  final starts = <Duration>[];
  var elapsed = Duration.zero;

  for (final duration in durations) {
    starts.add(elapsed);
    elapsed += Duration(milliseconds: duration);
  }

  return GifFrames(
    frames: [for (final _ in durations) Uint8List(0)],
    starts: starts,
    total: elapsed,
  );
}

void main() {
  // El mando avisa a quien escuche esperando a que el arbol este libre, y para
  // saber si lo esta pregunta por el marco. Aqui no hay pantalla, pero el marco
  // tiene que existir igual.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MediaPlaybackController playback;

  setUp(() {
    playback = MediaPlaybackController();
    playback.attachFrames(_frames());
  });

  tearDown(() => playback.dispose());

  test('un GIF recien abierto esta parado y al principio', () {
    expect(playback.isPlayable, isTrue);
    expect(playback.isPlaying, isFalse, reason: 'no puede arrancar solo');
    expect(playback.position, Duration.zero);
    expect(playback.duration, const Duration(milliseconds: 500));
  });

  test('el paso de fotograma es lo que dura el que se esta viendo', () {
    // El primero dura 100 y el segundo 200: el paso no es una media.
    expect(playback.frameStep, const Duration(milliseconds: 100));

    playback.seekTo(const Duration(milliseconds: 100));
    expect(playback.frameStep, const Duration(milliseconds: 200));
  });

  test('la tolerancia es medio fotograma', () {
    // Con un margen ancho se verian a la vez las regiones de medio segundo
    // alrededor y marcar fotograma a fotograma seria imposible.
    expect(playback.frameTolerance, const Duration(milliseconds: 50));
  });

  group('saltar de fotograma', () {
    test('cae justo en el principio de cada uno', () async {
      await playback.stepFrames(1);
      expect(playback.position, const Duration(milliseconds: 100));

      await playback.stepFrames(1);
      expect(playback.position, const Duration(milliseconds: 300));

      await playback.stepFrames(-1);
      expect(playback.position, const Duration(milliseconds: 100));
    });

    test('no se sale por ninguno de los dos extremos', () async {
      await playback.stepFrames(-5);
      expect(playback.position, Duration.zero);

      await playback.stepFrames(99);
      expect(playback.position, const Duration(milliseconds: 400));
    });

    test('saltar deja el GIF parado', () async {
      await playback.play();
      expect(playback.isPlaying, isTrue);

      await playback.stepFrames(1);

      // Se estaba buscando un fotograma concreto: seguir corriendo lo perderia.
      expect(playback.isPlaying, isFalse);
    });
  });

  group('esperar a que haya algo que reproducir', () {
    test('con contenido ya abierto se atiende en el momento', () {
      var calls = 0;
      playback.whenPlayable(() => calls++);

      expect(calls, 1);
    });

    test('sin nada abierto se espera al reproductor', () {
      // El reproductor tarda en abrir el fichero, asi que el visor llega antes
      // que el: al abrirse sobre una region de un video que hay que señalar, se
      // encuentra el mando en reposo y no puede ni saltar ni parar.
      final waiting = MediaPlaybackController();
      addTearDown(waiting.dispose);

      var calls = 0;
      waiting.whenPlayable(() => calls++);

      expect(calls, 0, reason: 'todavia no hay nada que hacer');

      waiting.attachFrames(_frames());
      expect(calls, 1);

      // Y se deja de escuchar: el siguiente contenido no vuelve a dispararlo.
      waiting.attachFrames(_frames());
      expect(calls, 1);
    });
  });

  group('soltar el contenido', () {
    test('soltar lo viejo no se lleva lo que ya se engancho', () {
      // Al rehacerse un trozo del arbol, Flutter monta el nuevo antes de
      // deshacer el viejo: primero se engancha el contenido nuevo y despues
      // llega el dispose del que se va. Soltando sin mirar, ese dispose dejaba
      // el mando vacio con el contenido ya abierto, y el video perdia de golpe
      // la linea de tiempo, el espacio y el clic.
      final old = playback.frames!;
      final fresh = _frames();

      playback.attachFrames(fresh);
      playback.detachSource(old);

      expect(playback.isPlayable, isTrue);
      expect(identical(playback.frames, fresh), isTrue);
    });

    test('soltar lo suyo si lo suelta', () {
      playback.detachSource(playback.frames);

      expect(playback.isPlayable, isFalse);
      expect(playback.frames, isNull);
    });

    test('soltar nada no hace nada', () {
      playback.detachSource(null);

      expect(playback.isPlayable, isTrue);
    });
  });

  group('en que fotograma se esta', () {
    test('en un GIF, el que cubre el instante', () {
      expect(playback.frameIndexOf(Duration.zero), 0);
      expect(playback.frameIndexOf(const Duration(milliseconds: 99)), 0);
      expect(playback.frameIndexOf(const Duration(milliseconds: 100)), 1);
      expect(playback.frameIndexOf(const Duration(milliseconds: 299)), 1);
      expect(playback.frameIndexOf(const Duration(milliseconds: 300)), 2);
    });

    test('el principio del fotograma es donde se apunta una region', () {
      playback.seekTo(const Duration(milliseconds: 250));

      // La region se apunta en el principio del fotograma y no donde se quedo
      // parado: asi todas las de un mismo fotograma caen en el mismo sitio.
      expect(playback.frameStart, const Duration(milliseconds: 100));
    });

    test('dos instantes del mismo fotograma son el mismo fotograma', () {
      expect(playback.isSameFrame(100, 250), isTrue);
      expect(playback.isSameFrame(100, 300), isFalse);
    });
  });

  group('sin GIF, la rejilla del video', () {
    late MediaPlaybackController video;

    setUp(() => video = MediaPlaybackController());
    tearDown(() => video.dispose());

    test('el fotograma sale del paso, redondeando al mas cercano', () {
      // Sin pista todavia el paso es el de partida, treinta fotogramas por
      // segundo. Se redondea porque el reproductor devuelve el instante del
      // fotograma con la precision que le da la pista: truncar dejaria la mitad
      // de las veces en el anterior.
      expect(video.frameStep, defaultFrameStep);
      expect(video.frameIndexOf(Duration.zero), 0);
      expect(video.frameIndexOf(const Duration(milliseconds: 33)), 1);
      expect(video.frameIndexOf(const Duration(milliseconds: 1000)), 30);
    });

    test('lo apuntado en milisegundos vuelve a su fotograma', () {
      // Una region se guarda en milisegundos enteros, asi que el principio del
      // fotograma pierde las micras al guardarse. Tiene que seguir cayendo en
      // el mismo sitio al leerla.
      for (var index = 0; index < 200; index++) {
        final stored = video.frameStartOf(index).inMilliseconds;
        expect(video.frameIndexOf(Duration(milliseconds: stored)), index);
      }
    });
  });

  group('los fotogramas de en medio', () {
    test('van del siguiente al de partida hasta el de llegada', () {
      final between = playback.framesBetween(
        Duration.zero,
        const Duration(milliseconds: 300),
      );

      // El de partida no entra, el de llegada si.
      expect(between, [
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 300),
      ]);
    });

    test('sin recorrido no hay nada en medio', () {
      expect(
        playback.framesBetween(
          const Duration(milliseconds: 300),
          const Duration(milliseconds: 100),
        ),
        isEmpty,
      );
    });

    test('se corta al tope para no llenar la base de golpe', () {
      final between = playback.framesBetween(
        Duration.zero,
        const Duration(milliseconds: 400),
        maxFrames: 2,
      );

      expect(between, hasLength(2));
      expect(maxDraggedFrames, greaterThan(0));
    });
  });
}
