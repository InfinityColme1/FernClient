// Comprueba la línea de tiempo del modo fernie.
//
// Es lo que permite marcar sobre un contenido que se mueve, así que tiene tres
// cosas que no se pueden romper: que el recorrido siga respondiendo al ratón
// —las muescas de lo ya marcado se pintan **encima** de él, y un dibujo encima
// es un candidato a comerse los gestos—, que el botón de arrastrar regiones no
// se pueda pulsar sin papel cebolla, que es el gesto al que modifica, y que la
// nube de una muesca aguante el viaje del cursor hasta ella.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_timeline.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Un GIF de medio segundo, sin tocar el disco.
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

FernieEntity _fernie(int id, String name) => FernieEntity(id: id, name: name);

/// Una muesca a los 100 ms con los fernies que se le pasen.
FernieMark _mark(List<String> names) => FernieMark(
      at: const Duration(milliseconds: 100),
      fernies: [
        for (final (index, name) in names.indexed) _fernie(index + 1, name),
      ],
    );

Future<void> _pump(
  WidgetTester tester, {
  required MediaPlaybackController playback,
  bool isOnionSkinOn = false,
  List<FernieMark> marks = const [],
  bool pauseOnSeek = false,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: MediaTimeline(
            playback: playback,
            mode: MediaTimelineMode.marking,
            marks: marks,
            pauseOnSeek: pauseOnSeek,
            isOnionSkinOn: isOnionSkinOn,
            onToggleOnionSkin: () {},
            isDraggingRegions: false,
            onToggleDragRegions: () {},
          ),
        ),
      ),
    ),
  ));
}

/// La misma barra, pero en el modo de mirar el contenido.
Future<void> _pumpViewing(
  WidgetTester tester, {
  required MediaPlaybackController playback,
  bool pauseOnSeek = false,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: MediaTimeline(playback: playback, pauseOnSeek: pauseOnSeek),
        ),
      ),
    ),
  ));
}

/// Si el botón que lleva [icon] se puede pulsar.
bool _isEnabled(WidgetTester tester, IconData icon) {
  final button = tester.widget<IconButton>(
    find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)),
  );

  return button.onPressed != null;
}

/// Dónde cae en pantalla la muesca de [at].
Offset _markCentre(WidgetTester tester, Duration at, Duration total) {
  final slider = tester.getRect(find.byType(Slider));

  // El hueco de los lados sale del tema de la barra, igual que en el widget: es
  // lo que hace que la muesca que se ve, la que se busca bajo el cursor y a la
  // que lleva pulsarla sean la misma.
  final inset = trackInset(SliderTheme.of(tester.element(find.byType(Slider))));
  final offset = markOffset(at, total, slider.width - inset * 2)!;

  return Offset(slider.left + inset + offset, slider.center.dy);
}

void main() {
  late MediaPlaybackController playback;

  setUp(() => playback = MediaPlaybackController());
  tearDown(() => playback.dispose());

  testWidgets('sin nada que reproducir no ocupa sitio', (tester) async {
    await _pump(tester, playback: playback);

    // Con una imagen no hay fotogramas que recorrer, así que la línea de tiempo
    // se quita de en medio ella sola.
    expect(find.byType(Slider), findsNothing);
    expect(tester.getSize(find.byType(MediaTimeline)).height, 0);
  });

  testWidgets('con contenido que se mueve salen los mandos', (tester) async {
    playback.attachFrames(_frames());
    await _pump(tester, playback: playback);

    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Symbols.skip_previous), findsOneWidget);
    expect(find.byIcon(Symbols.skip_next), findsOneWidget);
    expect(find.byIcon(Symbols.play_arrow), findsOneWidget);
  });

  testWidgets('arrastrar regiones necesita el papel cebolla', (tester) async {
    playback.attachFrames(_frames());

    await _pump(tester, playback: playback);
    expect(_isEnabled(tester, Symbols.linear_scale), isFalse,
        reason: 'sin papel cebolla no hay nada que arrastrar');

    await _pump(tester, playback: playback, isOnionSkinOn: true);
    expect(_isEnabled(tester, Symbols.linear_scale), isTrue);
  });

  testWidgets('las muescas no se comen el recorrido', (tester) async {
    playback.attachFrames(_frames());

    await _pump(
      tester,
      playback: playback,
      marks: [_mark(const ['Katara'])],
    );

    // Lo marcado se pinta dentro del recorrido, como una forma suya. Una banda
    // encima tapaba la bola y podía quedarse con los gestos; pintándola como
    // parte de la barra, buscar un fotograma sigue funcionando igual.
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pump();

    expect(playback.position, greaterThan(Duration.zero));
  });

  testWidgets('marcando, buscar por la barra para el contenido',
      (tester) async {
    playback.attachFrames(_frames());
    await playback.play();

    await _pump(tester, playback: playback);

    // Marcando se para siempre, diga lo que diga el ajuste: se esta buscando un
    // fotograma concreto para marcar sobre el, y buscarlo con la reproduccion en
    // marcha es perseguirlo.
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pump();

    expect(playback.isPlaying, isFalse);
  });

  group('mirando, parar o no al coger la barra', () {
    testWidgets('de fabrica no para', (tester) async {
      playback.attachFrames(_frames());
      await playback.play();

      await _pumpViewing(tester, playback: playback);

      // Recorrer un video es normalmente buscar un momento **viendolo**, y
      // pararlo en cada toque obliga a darle a reproducir otra vez.
      await tester.tapAt(tester.getCenter(find.byType(Slider)));
      await tester.pump();

      expect(playback.isPlaying, isTrue);
      await playback.pause();
    });

    testWidgets('con el ajuste puesto, para', (tester) async {
      playback.attachFrames(_frames());
      await playback.play();

      await _pumpViewing(tester, playback: playback, pauseOnSeek: true);

      await tester.tapAt(tester.getCenter(find.byType(Slider)));
      await tester.pump();

      expect(playback.isPlaying, isFalse);
    });
  });

  group('los tramos marcados', () {
    /// Un contenido a treinta fotogramas por segundo, en milisegundos enteros.
    int frameOf(Duration at) => (at.inMilliseconds / 33.3333).round();

    List<MarkSpan> spansOf(List<int> instants) => markSpans(
          [
            for (final ms in instants)
              FernieMark(at: Duration(milliseconds: ms), fernies: const []),
          ],
          total: const Duration(milliseconds: 1000),
          frameIndexOf: frameOf,
        );

    test('los fotogramas seguidos se juntan en uno solo', () {
      // Un video marcado fotograma a fotograma son cientos de rayas de dos
      // pixeles pegadas, y lo que dicen en realidad es "de aqui a aqui hay
      // trabajo".
      final spans = spansOf([100, 133, 167, 200]);

      expect(spans, hasLength(1));
      expect(spans.single.start, closeTo(0.1, 0.001));
      expect(spans.single.end, closeTo(0.2, 0.001));
    });

    test('lo que esta separado sigue separado', () {
      final spans = spansOf([100, 133, 500, 533]);

      expect(spans, hasLength(2));
      expect(spans.first.end, closeTo(0.133, 0.001));
      expect(spans.last.start, closeTo(0.5, 0.001));
    });

    test('una muesca suelta es un tramo sin ancho', () {
      final spans = spansOf([400]);

      expect(spans, hasLength(1));
      expect(spans.single.start, spans.single.end);
    });

    test('llegan desordenadas y salen en orden', () {
      final spans = spansOf([533, 100, 500, 133]);

      expect(spans.map((span) => span.start), isNotEmpty);
      expect(spans.first.start, lessThan(spans.last.start));
    });

    test('sin duracion no hay tramos', () {
      expect(
        markSpans(
          [const FernieMark(at: Duration.zero, fernies: [])],
          total: Duration.zero,
          frameIndexOf: frameOf,
        ),
        isEmpty,
      );
    });
  });

  group('mirando el contenido', () {
    testWidgets('lleva saltos de cinco segundos, no de fotograma',
        (tester) async {
      playback.attachFrames(_frames());
      await _pumpViewing(tester, playback: playback);

      expect(find.byIcon(Symbols.replay_5), findsOneWidget);
      expect(find.byIcon(Symbols.forward_5), findsOneWidget);
      expect(find.byIcon(Symbols.repeat), findsOneWidget);

      // Los de marcar no pintan nada aquí: mirar un vídeo no se hace fotograma
      // a fotograma.
      expect(find.byIcon(Symbols.skip_next), findsNothing);
      expect(find.byIcon(Symbols.layers), findsNothing);
      expect(find.byIcon(Symbols.linear_scale), findsNothing);
    });

    testWidgets('el salto adelante no se sale del contenido', (tester) async {
      playback.attachFrames(_frames());
      await _pumpViewing(tester, playback: playback);

      await tester.tap(find.byIcon(Symbols.forward_5));
      await tester.pumpAndSettle();

      // El GIF de la prueba dura medio segundo: cinco segundos se lo comen
      // entero y la posición se queda en el final, no fuera.
      expect(playback.position, playback.duration);
    });
  });

  group('pulsar una muesca', () {
    /// Pulsa el recorrido [offset] pixeles a la derecha de la muesca de [at].
    Future<void> tapNear(
      WidgetTester tester,
      Duration at, {
      double offset = 0,
    }) async {
      final centre = _markCentre(tester, at, playback.duration);
      await tester.tapAt(centre.translate(offset, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('se cae en su fotograma, no cerca', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara'])],
      );

      // Cuatro pixeles al lado de la muesca: en un video largo cada pixel del
      // recorrido son decenas de fotogramas, asi que pulsar "encima" no basta
      // para caer en el que tiene la region.
      await tapNear(tester, const Duration(milliseconds: 100), offset: 4);

      expect(playback.position, const Duration(milliseconds: 100));
    });

    testWidgets('lejos de una muesca se queda donde se pulso', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara'])],
      );

      await tapNear(tester, const Duration(milliseconds: 400));

      // Sin muesca cerca manda el pixel pulsado, que es lo de siempre.
      expect(playback.position, isNot(const Duration(milliseconds: 100)));
    });

    testWidgets('arrastrando no tira hacia las muescas', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara'])],
      );

      // Arrastrando se esta buscando a mano: una barra que tira hacia las
      // muescas al soltar se sentiria trabada.
      final slider = tester.getRect(find.byType(Slider));
      final inset =
          trackInset(SliderTheme.of(tester.element(find.byType(Slider))));

      await tester.dragFrom(
        Offset(slider.right - inset - 1, slider.center.dy),
        Offset(-(slider.width - inset * 2) * 0.78, 0),
      );
      await tester.pumpAndSettle();

      expect(playback.position, isNot(const Duration(milliseconds: 100)));
    });
  });

  group('la nube de una muesca', () {
    late TestGesture mouse;

    /// Deja el ratón encima de la muesca de los 100 ms.
    Future<void> hoverMark(WidgetTester tester) async {
      mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(_markCentre(
        tester,
        const Duration(milliseconds: 100),
        playback.duration,
      ));
      await tester.pumpAndSettle();
    }

    /// Saca el ratón y deja que el reloj de cierre termine.
    ///
    /// Hace falta hacerlo a mano: una prueba que acabe con un temporizador vivo
    /// falla, y el cierre de la nube lleva un respiro para que dé tiempo a
    /// entrar en ella.
    Future<void> leave(WidgetTester tester) async {
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    testWidgets('enseña quién está marcado en ese instante', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara', 'Sokka'])],
      );

      expect(find.text('Katara'), findsNothing, reason: 'sin cursor encima');

      await hoverMark(tester);

      expect(find.text('Katara'), findsOneWidget);
      expect(find.text('Sokka'), findsOneWidget);

      await leave(tester);
      expect(find.text('Katara'), findsNothing);
    });

    testWidgets('lejos de una muesca no sale nada', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara'])],
      );

      mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      // El otro extremo del recorrido, donde no hay nada marcado.
      await mouse.moveTo(_markCentre(
        tester,
        const Duration(milliseconds: 400),
        playback.duration,
      ));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Katara'), findsNothing);
    });

    testWidgets('no se cierra al meter el cursor dentro', (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara', 'Sokka'])],
      );

      await hoverMark(tester);

      // Del recorrido a la nube el cursor pasa por fuera de las dos. Si se
      // cerrara en ese viaje no habría forma de desplazar los nombres que no
      // caben.
      await mouse.moveTo(tester.getCenter(find.text('Katara')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Katara'), findsOneWidget);

      await leave(tester);
    });

    testWidgets('enseña tres a la vez y el resto se desplazan',
        (tester) async {
      playback.attachFrames(_frames());
      await _pump(
        tester,
        playback: playback,
        marks: [_mark(const ['Katara', 'Sokka', 'Aang', 'Toph'])],
      );

      await hoverMark(tester);

      // Una nube que creciera con veinte nombres taparía el contenido, que es
      // justo lo que se está mirando.
      final rowHeight = tester.getSize(find.text('Katara')).height;
      expect(rowHeight, greaterThan(0));
      expect(
        tester.getSize(find.byType(ListView)).height,
        (AppSizes.avatarSmall * 2 + AppSpacing.xs * 2) * fernieMarkMaxNames,
      );

      expect(find.text('Toph'), findsNothing, reason: 'el cuarto no cabe');

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.text('Toph'), findsOneWidget);

      await leave(tester);
    });
  });
}
