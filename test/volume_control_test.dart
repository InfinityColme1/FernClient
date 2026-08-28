// El mando del volumen del visor.
//
// Tres cosas lo hacen útil y ninguna es evidente mirando el widget:
//
// - **El volumen sobrevive al cambio de contenido.** El reproductor se crea y se
//   destruye con cada vídeo, así que guardado ahí bajarlo duraría hasta el vídeo
//   siguiente.
// - **Sube hacia arriba.** Es un deslizador tumbado, y tumbarlo del revés es un
//   fallo que no salta a la vista leyendo el código.
// - **Avisa de cuándo está abierto.** Los mandos del visor se desvanecen solos;
//   sin ese aviso el panel se queda flotando sobre un botón que ya no está.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:Fern/features/media/presentation/widgets/media_timeline.dart';
import 'package:Fern/features/media/presentation/widgets/volume_control.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un GIF cualquiera: sirve para tener línea de tiempo sin reproductor.
GifFrames _frames() => GifFrames(
      frames: [Uint8List(0), Uint8List(0)],
      starts: const [Duration.zero, Duration(milliseconds: 100)],
      total: const Duration(milliseconds: 200),
    );

Future<void> _pump(
  WidgetTester tester, {
  required MediaPlaybackController playback,
  ValueChanged<double>? onCommitted,
  ValueChanged<bool>? onOpenChanged,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: VolumeControl(
          playback: playback,
          onCommitted: onCommitted,
          onOpenChanged: onOpenChanged,
          builder: (context, toggle) => IconButton(
            onPressed: toggle,
            icon: const Icon(Icons.volume_up),
          ),
        ),
      ),
    ),
  ));
}

/// Un mando que dice que suena, sin levantar mpv.
///
/// `hasVolume` contesta que si hay un reproductor abierto, y abrir uno de verdad
/// en una prueba es levantar mpv y tocar el disco. Los fotogramas del GIF dan la
/// linea de tiempo; esto da el sonido.
class _AudibleController extends MediaPlaybackController {
  @override
  bool get hasVolume => true;
}

Future<void> _pumpTimeline(
  WidgetTester tester, {
  required MediaTimelineMode mode,
  MediaPlaybackController? playback,
}) {
  final mando = playback ?? (_AudibleController()..attachFrames(_frames()));

  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 700,
          child: MediaTimeline(
            playback: mando,
            mode: mode,
            isOnionSkinOn: true,
            onToggleOnionSkin: () {},
            onToggleDragRegions: () {},
          ),
        ),
      ),
    ),
  ));
}

void main() {
  group('el volumen del mando', () {
    test('empieza a tope', () {
      expect(MediaPlaybackController().volume, viewerDefaultVolume);
    });

    test('no se sale de cero y uno', () async {
      final playback = MediaPlaybackController();

      await playback.setVolume(2.5);
      expect(playback.volume, 1);

      await playback.setVolume(-1);
      expect(playback.volume, 0);
    });

    test('sobrevive a cambiar de contenido', () async {
      // Lo que hace que bajarlo sirva de algo: `detach` deja el mando en reposo
      // para el contenido siguiente, y el volumen no es del contenido.
      final playback = MediaPlaybackController()..attachFrames(_frames());
      await playback.setVolume(0.3);

      playback.detach();

      expect(playback.volume, 0.3);
    });

    test('avisa al cambiar', () async {
      final playback = MediaPlaybackController();
      var avisos = 0;
      playback.addListener(() => avisos++);

      await playback.setVolume(0.4);
      expect(avisos, 1);

      // Poner el mismo no es un cambio.
      await playback.setVolume(0.4);
      expect(avisos, 1);
    });

    test('un GIF no tiene volumen que regular', () {
      final playback = MediaPlaybackController()..attachFrames(_frames());

      expect(playback.isPlayable, isTrue);
      expect(playback.hasVolume, isFalse);
    });

    test('sin nada abierto tampoco', () {
      expect(MediaPlaybackController().hasVolume, isFalse);
    });
  });

  group('lo que se guarda', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<PreferencesService> service() async =>
        PreferencesService(await SharedPreferences.getInstance());

    test('sin nada guardado, a tope', () async {
      expect((await service()).getViewerVolume(), viewerDefaultVolume);
    });

    test('va y vuelve', () async {
      final preferences = await service();
      await preferences.setViewerVolume(0.25);

      expect(preferences.getViewerVolume(), 0.25);
    });

    test('lo que viene fuera de rango se ignora', () async {
      // Puede venir de una version anterior o de un fichero tocado a mano. Un
      // volumen de 7 dejaria el visor gritando sin manera de saber por que.
      SharedPreferences.setMockInitialValues({viewerVolumePreferenceKey: 7.0});

      expect((await service()).getViewerVolume(), viewerDefaultVolume);
    });
  });

  group('donde sale el boton', () {
    testWidgets('mirando un video, si', (tester) async {
      await _pumpTimeline(tester, mode: MediaTimelineMode.viewing);

      expect(find.byIcon(Symbols.volume_up), findsOneWidget);
    });

    testWidgets('en modo fernie, no', (tester) async {
      // Marcando regiones, la fila es para el trabajo de marcar: el papel
      // cebolla y el arrastre. El volumen ahi sobra.
      await _pumpTimeline(tester, mode: MediaTimelineMode.marking);

      expect(find.byIcon(Symbols.volume_up), findsNothing);
      expect(find.byIcon(Symbols.volume_down), findsNothing);
      expect(find.byIcon(Symbols.volume_off), findsNothing);
    });

    testWidgets('en un GIF, no', (tester) async {
      // Un GIF no suena. El mando no es que este apagado: es que no pinta nada.
      await _pumpTimeline(
        tester,
        mode: MediaTimelineMode.viewing,
        playback: MediaPlaybackController()..attachFrames(_frames()),
      );

      expect(find.byIcon(Symbols.volume_up), findsNothing);
    });
  });

  group('el panel', () {
    testWidgets('nace cerrado y el boton lo abre', (tester) async {
      final playback = MediaPlaybackController();
      final abierto = <bool>[];

      await _pump(tester, playback: playback, onOpenChanged: abierto.add);

      expect(find.byType(Slider), findsNothing);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(abierto, [true]);
    });

    testWidgets('volver a pulsar donde esta el boton lo cierra', (tester) async {
      // Con el panel abierto, quien recoge el clic es la manta que lo cierra al
      // pulsar fuera, no el boton: el boton queda debajo. El resultado es el que
      // se espera —se cierra— y por eso vale, pero conviene que la prueba diga
      // lo que de verdad pasa. De ahi el `warnIfMissed`.
      final playback = MediaPlaybackController();
      final abierto = <bool>[];

      await _pump(tester, playback: playback, onOpenChanged: abierto.add);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsNothing);
      expect(abierto, [true, false]);
    });

    testWidgets('pulsar fuera lo cierra', (tester) async {
      final playback = MediaPlaybackController();
      final abierto = <bool>[];

      await _pump(tester, playback: playback, onOpenChanged: abierto.add);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Una esquina, lejos del panel y del boton.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsNothing);
      expect(abierto, [true, false]);
    });

    testWidgets('el deslizador esta tumbado', (tester) async {
      await _pump(tester, playback: MediaPlaybackController());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      final rotado = tester.widget<RotatedBox>(
        find.ancestor(
          of: find.byType(Slider),
          matching: find.byType(RotatedBox),
        ),
      );

      expect(rotado.quarterTurns, 3);
    });

    testWidgets('arrastrar hacia arriba sube', (tester) async {
      // La comprobacion que de verdad importa del deslizador vertical: tumbado
      // del reves, arrastrar hacia arriba bajaria, y eso no se ve leyendo.
      final playback = MediaPlaybackController();
      await playback.setVolume(0.5);

      await _pump(tester, playback: playback);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(0, -40));
      await tester.pumpAndSettle();

      expect(playback.volume, greaterThan(0.5));
    });

    testWidgets('arrastrar hacia abajo baja', (tester) async {
      final playback = MediaPlaybackController();
      await playback.setVolume(0.5);

      await _pump(tester, playback: playback);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(0, 40));
      await tester.pumpAndSettle();

      expect(playback.volume, lessThan(0.5));
    });

    testWidgets('lo elegido se manda a guardar una sola vez, al soltar',
        (tester) async {
      final playback = MediaPlaybackController();
      await playback.setVolume(0.5);

      final guardados = <double>[];
      await _pump(tester, playback: playback, onCommitted: guardados.add);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(0, -40));
      await tester.pumpAndSettle();

      expect(guardados, hasLength(1));
      expect(guardados.single, playback.volume);
    });
  });
}
