// Los colores de las barras que dicen como va un modelo.
//
// Suena a capricho y no lo es: la barra de reparto y las de las metricas estaban
// pintadas con el **primario**, que es el lavanda con el que estan pintadas las
// propias superficies de la aplicacion. Sobre una de ellas, la barra parecia
// vacia: el reparto se veia como si no hubiera nada asignado a entrenar, y un
// mAP de 0,99 como una barra en blanco.
//
// Lo que se comprueba es que **cada tramo se distinga del papel y de sus
// vecinos**, en los dos temas. No que sea un color concreto: eso seria repetir
// el codigo con otras palabras.

import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_split_row.dart';
import 'package:Fern/features/recognition/presentation/widgets/metrics_panel.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Si dos colores se distinguen a la vista.
///
/// Dos formas de distinguirse, y basta con una: **por luminosidad** —la razon de
/// contraste de siempre, de 1 a 21— o **por tono**. Hacen falta las dos medidas
/// porque cada una sola se equivoca en un sentido: la luminosidad dice que un
/// rosa sobre un gris claro se parecen (y no, salta a la vista), y la distancia
/// entre canales dice que dos grises muy separados en luminosidad se parecen.
///
/// Lo que se busca cazar es lo que fallaba de verdad: el lavanda del primario
/// sobre una superficie de la aplicacion, que se queda en 1,08 de contraste y en
/// 0,05 de distancia. Es decir, no verse por ninguno de los dos lados.
bool _tellApart(Color a, Color b) =>
    _contrast(a, b) >= _minContrast || _hueDistance(a, b) >= _minHueDistance;

const _minContrast = 1.4;
const _minHueDistance = 0.15;

double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;

  return (lighter + 0.05) / (darker + 0.05);
}

double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Lo lejos que estan por canales, que es lo que recoge el cambio de tono.
double _hueDistance(Color a, Color b) =>
    ((a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs()) / 3;

/// Como se cuenta lo que no se distingue, para los mensajes de las pruebas.
String _describe(Color a, Color b) =>
    'contraste ${_contrast(a, b).toStringAsFixed(2)}, '
    'distancia ${_hueDistance(a, b).toStringAsFixed(3)}';

ModelFernieEntity _assignment() {
  return ModelFernieEntity(
    id: 1,
    modelId: 1,
    fernie: FernieEntity(id: 1, name: 'Rombo', regionCount: 200, mediaCount: 20),
    split: DatasetSplit.balanced,
    classIndex: 0,
  );
}

/// Los colores de los tramos de la barra de reparto, de izquierda a derecha.
List<Color> _segmentColors(WidgetTester tester) {
  return tester
      .widgetList<ColoredBox>(find.descendant(
        of: find.byType(ClipRRect),
        matching: find.byType(ColoredBox),
      ))
      .map((box) => box.color)
      .toList();
}

Future<void> _pumpSplitRow(WidgetTester tester, ThemeData theme) {
  return tester.pumpWidget(MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: SizedBox(
        width: 500,
        child: FernieSplitRow(
          assignment: _assignment(),
          onSplitChanged: (_) {},
        ),
      ),
    ),
  ));
}

Future<void> _pumpMetrics(WidgetTester tester, ThemeData theme) {
  return tester.pumpWidget(MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('es')],
    locale: const Locale('es'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1200,
          child: MetricsPanel(
            model: RecognitionModelEntity(
              id: 1,
              name: 'Figuras',
              weightsPath: r'C:\runs\best.pt',
              lastMetrics: '{"map50":0.99,"map50_95":0.98}',
              createdAt: DateTime(2026),
            ),
          ),
        ),
      ),
    ),
  ));
}

void main() {
  final themes = {
    'claro': AppTheme.lightTheme,
    'oscuro': AppTheme.darkTheme,
  };

  for (final entry in themes.entries) {
    final name = entry.key;
    final theme = entry.value;
    final palette = theme.extension<AppPalette>()!;

    group('la barra de reparto en tema $name', () {
      testWidgets('los tres tramos se distinguen entre si', (tester) async {
        await _pumpSplitRow(tester, theme);

        final colors = _segmentColors(tester);
        expect(colors, hasLength(3));

        for (var i = 0; i < colors.length; i++) {
          for (var j = i + 1; j < colors.length; j++) {
            expect(
              _tellApart(colors[i], colors[j]),
              isTrue,
              reason: 'el tramo $i y el $j se leen igual: '
                  '${_describe(colors[i], colors[j])}',
            );
          }
        }
      });

      testWidgets('ninguno se confunde con el papel', (tester) async {
        await _pumpSplitRow(tester, theme);

        // Las superficies de la aplicacion estan pintadas de estos dos.
        for (final color in _segmentColors(tester)) {
          for (final paper in [palette.secondary, palette.white]) {
            expect(
              _tellApart(color, paper),
              isTrue,
              reason: 'un tramo se pierde sobre la superficie: '
                  '${_describe(color, paper)}',
            );
          }
        }
      });
    });

    group('las barras de metricas en tema $name', () {
      testWidgets('se ven sobre su propia pista y sobre el papel',
          (tester) async {
        await _pumpMetrics(tester, theme);

        final bars = tester
            .widgetList<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .toList();

        expect(bars, isNotEmpty);

        for (final bar in bars) {
          final filled = bar.color!;

          expect(
            _tellApart(filled, bar.backgroundColor!),
            isTrue,
            reason: 'lo lleno y lo vacio se leen igual: '
                '${_describe(filled, bar.backgroundColor!)}',
          );

          expect(
            _tellApart(filled, palette.secondary),
            isTrue,
            reason: 'la barra se pierde sobre la superficie: '
                '${_describe(filled, palette.secondary)}',
          );
        }
      });
    });
  }

  test('el liston de «se leen igual» no es un numero al azar', () {
    // Sirve de guarda del propio guarda: con un liston de cero, las
    // comprobaciones de arriba pasarian con cualquier par de colores.
    // Que de verdad caza el fallo que hubo: el lavanda del primario sobre la
    // superficie clara. Sin esto, las comprobaciones de arriba podrian estar
    // pasando por tener el liston por los suelos.
    expect(
      _tellApart(AppColors.light.primary, AppColors.light.secondary),
      isFalse,
      reason: _describe(AppColors.light.primary, AppColors.light.secondary),
    );

    expect(weakClassThreshold, lessThan(0.99));
  });
}
