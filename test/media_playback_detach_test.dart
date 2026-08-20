// Comprueba que soltar el contenido no revienta al deshacerse el arbol.
//
// Nace de un error visto en la aplicacion en marcha:
//
//   setState() or markNeedsBuild() called when widget tree was locked.
//   MediaPlaybackController.detach
//   _MediaViewerState._disposeVideo  <- desde dispose()
//   ...  BuildOwner.lockState  <-  el arbol esta bloqueado aqui
//
// El visor suelta el contenido desde su `dispose`, y Flutter deshace los widgets
// con el arbol bloqueado. Avisar a quien escuche justo ahi le hace pedir que se
// le reconstruya en un momento en el que no se puede, y el marco lo rechaza.
//
// Aqui se monta esa misma forma —alguien escuchando al mando y alguien que lo
// suelta al morir— y se quita del arbol la segunda parte.

import 'package:Fern/features/media/data/services/gif_frames.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GifFrames _frames() => GifFrames(
      frames: [Uint8List(0), Uint8List(0)],
      starts: const [Duration.zero, Duration(milliseconds: 100)],
      total: const Duration(milliseconds: 200),
    );

/// Quien suelta el contenido al morir, como hace `MediaViewer`.
class _Holder extends StatefulWidget {
  final MediaPlaybackController playback;
  final Object source;

  const _Holder({required this.playback, required this.source});

  @override
  State<_Holder> createState() => _HolderState();
}

class _HolderState extends State<_Holder> {
  @override
  void dispose() {
    widget.playback.detachSource(widget.source);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Quien escucha al mando, como el visor con su capa de regiones.
Widget _harness(MediaPlaybackController playback, Object source,
    {required bool holding}) {
  return MaterialApp(
    home: Column(
      children: [
        AnimatedBuilder(
          animation: playback,
          builder: (context, _) => Text('${playback.isPlayable}'),
        ),
        if (holding) _Holder(playback: playback, source: source),
      ],
    ),
  );
}

void main() {
  testWidgets('soltar el contenido al morir no rompe el fotograma',
      (tester) async {
    final playback = MediaPlaybackController();
    addTearDown(playback.dispose);

    final frames = _frames();
    playback.attachFrames(frames);

    await tester.pumpWidget(_harness(playback, frames, holding: true));
    expect(find.text('true'), findsOneWidget);

    // Se quita del arbol quien lo tenia: el `dispose` llega con el arbol
    // bloqueado, que es donde saltaba.
    await tester.pumpWidget(_harness(playback, frames, holding: false));

    expect(tester.takeException(), isNull);

    // Y el aviso llega igual, sólo que cuando se puede.
    await tester.pump();
    expect(find.text('false'), findsOneWidget);
  });

  testWidgets('soltarlo con el mando ya muerto no avisa a nadie',
      (tester) async {
    final playback = MediaPlaybackController();
    final frames = _frames();
    playback.attachFrames(frames);

    await tester.pumpWidget(_harness(playback, frames, holding: true));

    // Un `ChangeNotifier` muerto que avisa lanza. Soltar el contenido es de lo
    // último que se hace, así que tiene que saber callarse.
    playback.dispose();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
