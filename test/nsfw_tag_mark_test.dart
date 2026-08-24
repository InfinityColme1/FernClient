// Que una etiqueta marcada se reconozca allá donde aparezca.
//
// Con el filtro quitado, una etiqueta NSFW se pintaba exactamente igual que las
// demás: en el menú lateral, en los buscadores, en las etiquetas de un
// contenido. Y eso importa en las dos direcciones —quien asigna una sin saberlo
// acaba de esconder contenido, y quien busca por ella no entiende por qué la
// rejilla se queda a medias—.
//
// Se prueba la pieza compartida y los dos sitios que la reciben de una entidad
// distinta (la fila del buscador principal y el hueco de las sugerencias), que
// son donde el dato viaja y se puede perder por el camino.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/collapsing_list_tile_widget.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_tag_mark.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('la marca', () {
    // Escrita y no un icono: un ojo tachado obliga a adivinar qué significa, y
    // en una fila de etiquetas con avatares de colores se pierde.
    testWidgets('dice NSFW con todas sus letras', (tester) async {
      await tester.pumpWidget(_harness(const NsfwTagMark()));

      expect(find.text('NSFW'), findsOneWidget);
    });

    testWidgets('va en el acento, que es con el que se marca lo delicado',
        (tester) async {
      late Color expected;

      await tester.pumpWidget(_harness(
        Builder(builder: (context) {
          expected = context.colors.terciary;

          return const NsfwTagMark();
        }),
      ));

      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration as BoxDecoration;

      expect(decoration.color, expected);
      // Relleno y con las esquinas redondeadas: es un recuadro, no un borde.
      expect(decoration.borderRadius, isNotNull);
    });

    // Va detrás del nombre para no tapar el avatar de la etiqueta, que es con
    // lo que se la reconoce de un vistazo.
    testWidgets('la píldora la pone detrás y conserva el avatar',
        (tester) async {
      await tester.pumpWidget(_harness(
        const FernChip(
          label: 'delicada',
          leading: Text('avatar'),
          trailing: NsfwTagMark(),
        ),
      ));

      expect(find.text('avatar'), findsOneWidget);
      expect(find.byType(NsfwTagMark), findsOneWidget);

      final avatar = tester.getTopLeft(find.text('avatar'));
      final mark = tester.getTopLeft(find.byType(NsfwTagMark));

      expect(mark.dx, greaterThan(avatar.dx));
    });
  });

  // El menú lateral pinta las etiquetas con su avatar, y la marca no puede
  // quitárselo: es con lo que se reconoce una etiqueta con el menú plegado.
  group('el menú lateral', () {
    late AnimationController animation;

    setUp(() {
      animation = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 1),
      );
    });

    tearDown(() => animation.dispose());

    /// El botón del menú, con la animación puesta donde toca.
    ///
    /// El controlador va de desplegado (0) a plegado (1) y decide el **ancho**;
    /// `isExpanded` decide el **contenido**. Dejarlos descuadrados monta un
    /// botón estrecho con el contenido del ancho, que desborda por motivos que
    /// no tienen nada que ver con lo que se prueba.
    CollapsingListTile tile({
      required bool isNsfw,
      required bool isExpanded,
    }) {
      animation.value = isExpanded ? 0 : 1;

      return CollapsingListTile(
          title: 'delicada',
          icon: Icons.sell_outlined,
          isNsfw: isNsfw,
          isExpanded: isExpanded,
          onTap: () {},
          animationController: animation,
          iconSize: 24,
          textStyle: const TextStyle(),
          selectedColor: Colors.blue,
          textSelectedColor: Colors.white,
          unselectedColor: Colors.transparent,
          textUnselectedColor: Colors.black,
      );
    }

    testWidgets('marca las etiquetas escondidas', (tester) async {
      await tester.pumpWidget(_harness(
        tile(isNsfw: true, isExpanded: true),
      ));

      expect(find.byType(NsfwTagMark), findsOneWidget);
      // Y el icono sigue siendo el de siempre: la marca no lo sustituye.
      expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    });

    testWidgets('y no toca las demás', (tester) async {
      await tester.pumpWidget(_harness(
        tile(isNsfw: false, isExpanded: true),
      ));

      expect(find.byType(NsfwTagMark), findsNothing);
    });

    // El menú tiene ancho fijo, así que el recuadro le quita sitio al nombre.
    // Con uno largo tiene que ceder el texto, no desbordarse la fila.
    testWidgets('un nombre largo no desborda la fila', (tester) async {
      await tester.pumpWidget(_harness(
        CollapsingListTile(
          title: 'una etiqueta con un nombre larguísimo que no cabe ni de lejos',
          icon: Icons.sell_outlined,
          isNsfw: true,
          onTap: () {},
          animationController: animation..value = 0,
          iconSize: 24,
          textStyle: const TextStyle(),
          selectedColor: Colors.blue,
          textSelectedColor: Colors.white,
          unselectedColor: Colors.transparent,
          textUnselectedColor: Colors.black,
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(NsfwTagMark), findsOneWidget);
    });

    // Plegado no hay título al que acompañar y el recuadro no cabe.
    testWidgets('con el menú plegado no se pinta', (tester) async {
      await tester.pumpWidget(_harness(
        tile(isNsfw: true, isExpanded: false),
      ));

      expect(find.byType(NsfwTagMark), findsNothing);
    });
  });

  group('la fila del buscador', () {
    testWidgets('marca las etiquetas NSFW', (tester) async {
      await tester.pumpWidget(_harness(
        SearchResultRow.suggestion(
          label: 'delicada',
          type: SearchResultType.tag,
          isNsfw: true,
          onTap: () {},
        ),
      ));

      expect(find.byType(NsfwTagMark), findsOneWidget);
    });

    testWidgets('y no toca las demás', (tester) async {
      await tester.pumpWidget(_harness(
        SearchResultRow.suggestion(
          label: 'normal',
          type: SearchResultType.tag,
          onTap: () {},
        ),
      ));

      expect(find.byType(NsfwTagMark), findsNothing);
    });
  });

  // El dato viaja desde el repositorio hasta la fila; si la entidad lo perdiera
  // por el camino, la fila lo pintaría bien y no se vería nada.
  test('la sugerencia lleva la marca consigo', () {
    const marked = SearchSuggestionEntity(
      id: 1,
      type: SearchResultType.tag,
      label: 'delicada',
      isNsfw: true,
    );

    expect(marked.isNsfw, isTrue);

    // Y de fábrica no: los contenidos y los creadores usan la misma entidad y
    // no tienen esta marca.
    const plain = SearchSuggestionEntity(
      id: 2,
      type: SearchResultType.media,
      label: 'una foto',
    );

    expect(plain.isNsfw, isFalse);
  });
}
