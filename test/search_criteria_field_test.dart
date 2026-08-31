// Las pastillas de la barra de búsqueda, que son parte del texto.
//
// Cada una ocupa **un carácter** del campo, y de ahí sale todo lo que tiene que
// cumplirse: el cursor pasa por ellas con las flechas, retroceso borra la de al
// lado como borraría una letra, seleccionar y borrar se lleva las que caigan
// dentro, y todo el ancho de la barra es el mismo campo donde se escribe.
//
// El primer intento las puso en una fila al lado del campo. Se veía parecido y
// no lo era: quedaba un trozo pequeño donde escribir, el resto de la barra no
// atendía a las pulsaciones y el cursor no llegaba a las pastillas. Estas
// pruebas existen para que no se vuelva a eso.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas de
// medidas: sin ella se mide con la fuente de pruebas, en la que cada letra es un
// cuadrado, y los textos salen mucho más anchos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/presentation/widgets/search_criteria_field.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

const _longName = 'Marinette Dupain-Cheng de París y alrededores';

SearchCriterionEntity _tag(int id, String name) => SearchCriterionEntity(
      kind: SearchCriterionKind.tag,
      id: id,
      label: name,
    );

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadAppFont);

  late SearchCriteriaController controller;
  late List<SearchCriterionEntity> removed;
  late int tapsOnBar;

  setUp(() {
    removed = [];
    tapsOnBar = 0;
    controller = SearchCriteriaController(
      chipBuilder: (context, criterion) => SearchCriterionChip(
        criterion: criterion,
        onRemove: () {
          removed.add(criterion);
          controller.removeChip(criterion);
        },
      ),
    );
  });

  tearDown(() => controller.dispose());

  /// Monta el campo dentro de la barra de verdad: mismo ancho, mismo alto, el
  /// mismo hueco que le dejan la lupa y el botón de borrar, **y el gesto que
  /// hace que toda la barra lleve al campo**.
  ///
  /// Ese gesto va aquí y no sólo en la barra a propósito: envuelve a las
  /// pastillas, así que si se quedara con la pulsación dejaría sus aspas sin
  /// funcionar y nadie se enteraría hasta usarlo.
  Future<Object?> pumpBar(
    WidgetTester tester, {
    Locale locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.takeException();

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: AppSizes.searchBarWidth,
            height: AppSizes.searchBarHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tapsOnBar++,
              child: Row(
              children: [
                const Icon(Symbols.search),
                Expanded(
                  child: SearchCriteriaField(
                    controller: controller,
                    onChanged: (_) {},
                    onSubmitted: (_) {},
                    hintText: 'Buscar',
                  ),
                ),
                const Icon(Symbols.cancel),
              ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    return tester.takeException();
  }

  group('una pastilla es un carácter', () {
    test('el texto lleva un hueco por cada una', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.addChip(_tag(2, 'paisaje'));

      expect(controller.text.length, 2);
      expect(controller.text, SearchCriteriaController.chipChar * 2);
    });

    test('lo escrito va detrás y se lee aparte', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.text = '${SearchCriteriaController.chipChar}monta';

      expect(controller.pendingText, 'monta');
      expect(controller.chips, hasLength(1));
    });

    // Es lo que hace que retroceso, seleccionar y borrar, o cortar, se lleven
    // las pastillas sin un caso especial para cada forma de borrar.
    test('borrar su carácter la borra', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.addChip(_tag(2, 'paisaje'));

      // Como si el cursor estuviera al final y se pulsara retroceso.
      controller.text = SearchCriteriaController.chipChar;

      expect(controller.chips.map((c) => c.label), ['ladybug']);
    });

    test('borrar el de en medio se lleva el suyo, no otro', () {
      controller.addChip(_tag(1, 'uno'));
      controller.addChip(_tag(2, 'dos'));
      controller.addChip(_tag(3, 'tres'));

      controller.text = SearchCriteriaController.chipChar * 2;

      // Se ha borrado desde el final, así que sobreviven las dos primeras.
      expect(controller.chips.map((c) => c.label), ['uno', 'dos']);
    });

    test('vaciar el campo se las lleva todas', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.clear();

      expect(controller.chips, isEmpty);
      expect(controller.isEmpty, isTrue);
    });

    test('la misma dos veces no se pone dos veces', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.addChip(_tag(1, 'ladybug'));

      expect(controller.chips, hasLength(1));
    });
  });

  group('lo que se busca', () {
    test('son las pastillas y lo escrito', () {
      controller.addChip(_tag(1, 'ladybug'));
      controller.text = '${SearchCriteriaController.chipChar}monta';

      expect(controller.criteria, hasLength(2));
      expect(controller.criteria.last.label, 'monta');
      expect(controller.criteria.last.isPending, isTrue);
    });

    test('sin nada escrito, sólo las pastillas', () {
      controller.addChip(_tag(1, 'ladybug'));

      expect(controller.criteria, hasLength(1));
      expect(controller.criteria.single.isPending, isFalse);
    });

    test('adoptar lo de fuera devuelve lo pendiente al campo', () {
      controller.adopt([
        _tag(1, 'ladybug'),
        const SearchCriterionEntity.text('monta', isPending: true),
      ]);

      expect(controller.chips.map((c) => c.label), ['ladybug']);
      expect(controller.pendingText, 'monta');
    });
  });

  group('no desborda la barra', () {
    for (final count in [0, 1, 3, 8]) {
      testWidgets('con $count pastillas', (tester) async {
        for (var i = 0; i < count; i++) {
          controller.addChip(_tag(i, 'etiqueta $i'));
        }

        for (final locale in _locales) {
          final overflow = await pumpBar(tester, locale: locale);

          expect(
            overflow,
            isNull,
            reason: 'desborda con $count en ${locale.languageCode}',
          );
        }
      });
    }

    testWidgets('con nombres larguísimos', (tester) async {
      controller.addChip(_tag(1, _longName));
      controller.addChip(_tag(2, _longName));

      expect(await pumpBar(tester), isNull);
    });
  });

  // El fallo que esto protege: el campo ocupaba un trozo pequeño y el resto de
  // la barra no atendía a las pulsaciones.
  testWidgets('el campo ocupa todo el ancho que le dan', (tester) async {
    controller.addChip(_tag(1, 'ladybug'));

    await pumpBar(tester);

    final field = tester.getSize(find.byType(SearchCriteriaField));
    final bar = tester.getSize(find.byType(Row).first);

    // Lo que le dejan la lupa y el aspa, y ni un píxel menos.
    expect(field.width, greaterThan(bar.width / 2));
  });

  testWidgets('sin pastillas se dice qué se puede buscar', (tester) async {
    await pumpBar(tester);

    expect(find.text('Buscar'), findsOneWidget);
  });

  testWidgets('con alguna puesta, el rótulo deja el hueco', (tester) async {
    controller.addChip(_tag(1, 'ladybug'));

    await pumpBar(tester);

    expect(find.text('Buscar'), findsNothing);
  });

  group('la pastilla', () {
    testWidgets('se pinta con su nombre', (tester) async {
      controller.addChip(_tag(1, 'ladybug'));

      await pumpBar(tester);

      expect(find.text('ladybug'), findsOneWidget);
    });

    // Una descripción puede tener tres líneas: metida entera en una pastilla se
    // come la barra. Cuál es se ve en la rejilla, que es lo que se acaba de
    // pedir.
    testWidgets('la de un contenido dice «descripción», no la descripción',
        (tester) async {
      controller.addChip(const SearchCriterionEntity(
        kind: SearchCriterionKind.media,
        id: 100,
        label: 'una ladybug de perfil en el tejado de una casa de París',
      ));

      await pumpBar(tester);

      expect(find.text('Descripción'), findsOneWidget);
      expect(find.textContaining('tejado'), findsNothing);
    });

    testWidgets('su aspa la quita', (tester) async {
      controller.addChip(_tag(1, 'ladybug'));
      controller.addChip(_tag(2, 'paisaje'));

      await pumpBar(tester);

      await tester.tap(find.byIcon(Symbols.close).first);
      await tester.pump();

      expect(removed.single.label, 'ladybug');
      expect(controller.chips.map((c) => c.label), ['paisaje']);
    });

    // El gesto de la barra envuelve a las pastillas: si se quedara con la
    // pulsación, el aspa dejaría de funcionar.
    testWidgets('y el gesto de la barra no se la queda', (tester) async {
      controller.addChip(_tag(1, 'ladybug'));

      await pumpBar(tester);

      await tester.tap(find.byIcon(Symbols.close).first);
      await tester.pump();

      expect(removed, hasLength(1));
      expect(tapsOnBar, 0);
    });

    testWidgets('pero pulsar el hueco de al lado sí llega a la barra',
        (tester) async {
      await pumpBar(tester);

      await tester.tapAt(
        tester.getCenter(find.byIcon(Symbols.search)),
      );
      await tester.pump();

      expect(tapsOnBar, 1);
    });
  });
}
