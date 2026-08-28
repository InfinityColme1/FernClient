// Cómo se ve una sugerencia en el panel de información.
//
// Lo importante no es que salga bonita: es que **no se pueda confundir con una
// etiqueta de verdad**. El panel es donde el usuario decide qué lleva su
// biblioteca, y una propuesta de un modelo que se leyera igual que algo
// confirmado convertiría cada equivocación del modelo en una etiqueta que nadie
// puso.
//
// Se comprueban las dos señales que la separan: el tono apagado y el porcentaje
// con su color por tramos.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/suggestion_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

MediaSuggestionEntity _suggestion({
  double confidence = 0.9,
  String name = 'lady-suit',
  TagEntity? tag,
  bool withBox = false,
}) {
  return MediaSuggestionEntity(
    result: RecognitionResultEntity(
      id: 1,
      mediaId: 7,
      modelId: 1,
      fernieId: 10,
      confidence: confidence,
      x: withBox ? 0.1 : null,
      y: withBox ? 0.2 : null,
      w: withBox ? 0.3 : null,
      h: withBox ? 0.4 : null,
      createdAt: DateTime(2026),
    ),
    fernie: FernieEntity(id: 10, name: name, linkedTagId: tag?.id),
    tag: tag,
  );
}

const _ladybug = TagEntity(id: 3, name: 'Ladybug', children: []);

/// El color con el que se ha pintado un texto.
Color? _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

Future<AppPalette> _pump(
  WidgetTester tester,
  MediaSuggestionEntity suggestion, {
  VoidCallback? onAccept,
  VoidCallback? onReject,
  VoidCallback? onMarkRegion,
  void Function(MediaSuggestionEntity?)? onSpotlight,
}) async {
  late AppPalette palette;

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          palette = context.colors;

          return SizedBox(
            width: 320,
            child: SuggestionRow(
              suggestion: suggestion,
              onAccept: onAccept,
              onReject: onReject,
              onMarkRegion: onMarkRegion,
              onSpotlight: onSpotlight,
            ),
          );
        },
      ),
    ),
  ));

  return palette;
}

void main() {
  group('qué se lee', () {
    testWidgets('el nombre de lo enlazado y su confianza', (tester) async {
      await _pump(tester, _suggestion(confidence: 0.92, tag: _ladybug));

      expect(find.text('Ladybug'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
    });

    testWidgets('sin enlace, el nombre del fernie', (tester) async {
      await _pump(tester, _suggestion(name: 'escuela'));

      expect(find.text('escuela'), findsOneWidget);
    });

    testWidgets('el porcentaje va sin decimales', (tester) async {
      await _pump(tester, _suggestion(confidence: 0.417));

      // Dos cifras más por sugerencia en un panel estrecho, para una diferencia
      // que no cambia ninguna decisión.
      expect(find.text('42%'), findsOneWidget);
    });
  });

  group('que no se confunda con una etiqueta', () {
    testWidgets('el nombre va apagado', (tester) async {
      final palette = await _pump(tester, _suggestion(name: 'escuela'));

      // El mismo tono con el que el diálogo de asignar pinta lo que todavía no
      // está puesto: es el mismo estado y merece el mismo aspecto.
      expect(_colorOf(tester, 'escuela'), palette.unremarked);
    });

    testWidgets('lleva siempre el porcentaje', (tester) async {
      // Es la otra mitad de la señal: sin él, una etiqueta apagada podría ser
      // sólo una etiqueta apagada.
      await _pump(tester, _suggestion(confidence: 1));

      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('el color del porcentaje', () {
    testWidgets('lo muy seguro va con el acento', (tester) async {
      final palette = await _pump(tester, _suggestion(confidence: 0.85));

      expect(_colorOf(tester, '85%'), palette.terciary);
    });

    testWidgets('lo intermedio va con el gris apagado', (tester) async {
      final palette = await _pump(tester, _suggestion(confidence: 0.6));

      expect(_colorOf(tester, '60%'), palette.unremarked);
    });

    testWidgets('lo poco fiable se ve de verdad distinto', (tester) async {
      // El tramo bajo se marca con opacidad y no con otro gris: en la paleta
      // clara —la de fábrica— el gris de los textos secundarios y el de lo
      // apagado son el mismo color, así que dos de los tres tramos saldrían
      // idénticos. Se comprueba contra el color de al lado, no contra un token,
      // que es lo que de verdad tiene que diferenciarse.
      await _pump(tester, _suggestion(confidence: 0.6));
      final medium = _colorOf(tester, '60%');

      await _pump(tester, _suggestion(confidence: 0.2));
      final low = _colorOf(tester, '20%');

      expect(low, isNotNull);
      expect(low, isNot(medium));
      expect(low!.a, lessThan(medium!.a));
    });

    testWidgets('el listón alto es el de la aceptación masiva', (tester) async {
      // Si el color prometiera «bueno» por debajo de donde acepta el botón de
      // aceptar todo, estaría prometiendo algo que el botón no hace.
      final palette = await _pump(tester, _suggestion(confidence: 0.80));
      expect(_colorOf(tester, '80%'), palette.terciary);

      await _pump(tester, _suggestion(confidence: 0.79));
      expect(_colorOf(tester, '79%'), isNot(palette.terciary));
    });
  });

  group('los botones de contestar', () {
    testWidgets('sin nada que hacer, ninguno aparece', (tester) async {
      await _pump(tester, _suggestion());

      // Es la fila del paso anterior: se puede mirar, no contestar.
      expect(find.byIcon(Symbols.check), findsNothing);
      expect(find.byIcon(Symbols.close), findsNothing);
    });

    testWidgets('con qué proponer, aparecen los dos', (tester) async {
      await _pump(
        tester,
        _suggestion(tag: _ladybug),
        onAccept: () {},
        onReject: () {},
      );

      expect(find.byIcon(Symbols.check), findsOneWidget);
      expect(find.byIcon(Symbols.close), findsOneWidget);
    });

    testWidgets('sin nada que poner, sólo se puede rechazar', (tester) async {
      // Un fernie que no enlaza nada, o cuya etiqueta alguien borró: enseñar el
      // botón de aceptar y dar un error al pulsarlo sería peor que no
      // enseñarlo.
      await _pump(tester, _suggestion(), onReject: () {});

      expect(find.byIcon(Symbols.check), findsNothing);
      expect(find.byIcon(Symbols.close), findsOneWidget);
    });

    testWidgets('aceptar avisa a quien lo pidió', (tester) async {
      var accepted = 0;

      await _pump(
        tester,
        _suggestion(tag: _ladybug),
        onAccept: () => accepted++,
        onReject: () {},
      );

      await tester.tap(find.byIcon(Symbols.check));
      await tester.pump();

      expect(accepted, 1);
    });

    testWidgets('rechazar avisa a quien lo pidió', (tester) async {
      var rejected = 0;

      await _pump(
        tester,
        _suggestion(tag: _ladybug),
        onAccept: () {},
        onReject: () => rejected++,
      );

      await tester.tap(find.byIcon(Symbols.close));
      await tester.pump();

      expect(rejected, 1);
    });
  });

  group('dónde lo vio', () {
    testWidgets('con caja se ofrece guardarla como región', (tester) async {
      var marked = 0;

      await _pump(
        tester,
        _suggestion(withBox: true),
        onMarkRegion: () => marked++,
      );

      await tester.tap(find.byIcon(Symbols.crop_free));

      // Es lo que cierra el círculo: sin esto, cada acierto del modelo se pierde
      // y hay que volver a marcar a mano lo que ya estaba bien marcado.
      expect(marked, 1);
    });

    testWidgets('sin caja no se ofrece', (tester) async {
      await _pump(tester, _suggestion(), onMarkRegion: () {});

      // No hay sitio que guardar: una región sin rectángulo no es una región.
      expect(find.byIcon(Symbols.crop_free), findsNothing);
    });

    testWidgets('pasar por encima avisa con la sugerencia', (tester) async {
      final seen = <MediaSuggestionEntity?>[];

      await _pump(
        tester,
        _suggestion(withBox: true),
        onSpotlight: seen.add,
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(SuggestionRow)));
      await tester.pump();

      expect(seen.length, 1);
      expect(seen.single, isNotNull);

      // Y salir lo apaga: un rectángulo que se queda puesto deja de contestar
      // «dónde ha visto esto» y pasa a ser decoración.
      await mouse.moveTo(const Offset(500, 500));
      await tester.pump();

      expect(seen, [isNotNull, isNull]);
    });

    testWidgets('sin caja no se señala nada', (tester) async {
      final seen = <MediaSuggestionEntity?>[];

      await _pump(tester, _suggestion(), onSpotlight: seen.add);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(SuggestionRow)));
      await tester.pump();

      expect(seen, isEmpty);
    });
  });
}
