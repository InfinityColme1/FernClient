// La lista de enlaces del catálogo: la de los perfiles del creador y la de las
// direcciones vinculadas de una etiqueta, que ahora son la misma.
//
// Se mide porque es un bloque de alto variable dentro de fichas que ya se
// salieron de la pantalla una vez. La regla que tiene que sostener es que **da
// igual cuántos enlaces haya**: con el hueco repartido no crece, y con un máximo
// no lo pasa. Lo que no quepa se desplaza por dentro.
//
// Y porque el reindexado al quitar una fila es fácil de romper: quitar la
// tercera no puede dejar en edición a la cuarta.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas de
// medidas: sin ella se mide con la fuente de pruebas, en la que cada letra es un
// cuadrado, y los textos salen mucho más altos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

/// Una ventana de portátil sin maximizar, que es donde se vio el problema de
/// alto en las fichas de gestión.
const _laptopHeight = 600.0;

/// Lo ancha que es la columna del formulario de una ficha de gestión: la mitad
/// de la ficha, menos el avatar. Estrecho a propósito: es donde un enlace largo
/// tiene que recortarse en vez de desbordar.
const _columnWidth = 300.0;

const _longLink =
    'https://www.deviantart.com/algun-artista-con-nombre-larguisimo/gallery/'
    '123456789/una-carpeta-con-un-nombre-todavia-mas-largo';

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

List<FernLink> _links(int count) =>
    [for (var i = 0; i < count; i++) FernLink('reddit.com/r/ejemplo$i')];

List<String> _urls(List<FernLink> links) =>
    [for (final link in links) link.url];

/// Monta la lista tal y como la usa una ficha: con el hueco repartido
/// ([fills]) o creciendo hasta un máximo.
Widget _harness(
  Widget field,
  Locale locale, {
  required bool bounded,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _columnWidth,
          // Con `fills` la lista necesita un alto acotado del que repartirse,
          // que es lo que le da la ficha.
          height: bounded ? null : 240.0,
          child: bounded ? field : Column(children: [Expanded(child: field)]),
        ),
      ),
    ),
  );
}

FernLinkListField _field({
  required List<FernLink> links,
  required bool fills,
  ValueChanged<List<FernLink>>? onChanged,
  ValueChanged<List<FernLink>>? onCommitted,
  bool canMarkNsfw = false,
  bool hidesMarked = false,
}) {
  return FernLinkListField(
    links: links,
    onChanged: onChanged ?? (_) {},
    onCommitted: onCommitted,
    label: 'Direcciones',
    emptyMessage: 'Sin direcciones vinculadas',
    hintText: 'reddit.com/r/ejemplo',
    addLabel: 'Añadir dirección',
    openTooltip: 'Abrir',
    editTooltip: 'Editar',
    removeTooltip: 'Quitar',
    doneTooltip: 'Terminar',
    canMarkNsfw: canMarkNsfw,
    hidesMarked: hidesMarked,
    markNsfwTooltip: 'Marcar',
    unmarkNsfwTooltip: 'Desmarcar',
    fills: fills,
  );
}

void main() {
  setUpAll(_loadAppFont);

  Future<Object?> pumpAndTakeException(
    WidgetTester tester,
    Widget widget,
  ) async {
    tester.view.physicalSize = const Size(1000, _laptopHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // El árbol se tira abajo antes de cada medida: reaprovechando los render
    // objects, el aviso de desbordamiento sólo se da la primera vez y las
    // siguientes saldrían limpias sin serlo.
    await tester.pumpWidget(const SizedBox.shrink());
    tester.takeException();

    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 400));

    return tester.takeException();
  }

  group('con el hueco repartido', () {
    // Cero, uno y muchos: el caso vacío tiene su propio texto y el de muchos es
    // el que empujaba la ficha.
    for (final count in [0, 1, 8, 30]) {
      testWidgets('$count enlaces no desbordan', (tester) async {
        for (final locale in _locales) {
          final overflow = await pumpAndTakeException(
            tester,
            _harness(
              _field(links: _links(count), fills: true),
              locale,
              bounded: false,
            ),
          );

          expect(
            overflow,
            isNull,
            reason: 'desborda con $count enlaces en ${locale.languageCode}',
          );
        }
      });
    }

    // Lo que hace que la ficha mida siempre lo mismo: con el hueco repartido, la
    // lista no crece con el contenido.
    testWidgets('mide lo mismo con uno que con treinta', (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(_field(links: _links(1), fills: true), const Locale('es'),
            bounded: false),
      );
      final small = tester.getSize(find.byType(FernLinkListField));

      await pumpAndTakeException(
        tester,
        _harness(_field(links: _links(30), fills: true), const Locale('es'),
            bounded: false),
      );

      expect(tester.getSize(find.byType(FernLinkListField)), small);
    });
  });

  group('creciendo hasta un máximo', () {
    testWidgets('no pasa del tope por muchos que haya', (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(_field(links: _links(30), fills: false), const Locale('es'),
            bounded: true),
      );

      // El tope es el de la lista; encima van el rótulo y debajo el botón de
      // añadir, así que se deja margen para los dos.
      expect(
        tester.getSize(find.byType(FernLinkListField)).height,
        lessThan(160.0 + 80.0),
      );
    });

    testWidgets('un enlace larguísimo se recorta, no desborda', (tester) async {
      final overflow = await pumpAndTakeException(
        tester,
        _harness(
          _field(links: const [FernLink(_longLink)], fills: false),
          const Locale('es'),
          bounded: true,
        ),
      );

      expect(overflow, isNull);
    });
  });

  group('editar la lista', () {
    testWidgets('un enlace en reposo se abre de una pulsación', (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(_field(links: _links(2), fills: false), const Locale('es'),
            bounded: true),
      );

      // En reposo: el icono de abrir y el de editar, no el campo de texto.
      expect(find.byIcon(Symbols.open_in_new), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('los que nacen vacíos nacen en edición', (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(_field(links: const [], fills: false), const Locale('es'),
            bounded: true),
      );

      await tester.tap(find.text('Añadir dirección'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    // El reindexado: quitar una fila no puede dejar en edición a otra distinta
    // de la que se abrió.
    testWidgets('quitar una no deja editando a la siguiente', (tester) async {
      List<FernLink> current = _links(3);

      await pumpAndTakeException(
        tester,
        _harness(
          _field(
            links: _links(3),
            fills: false,
            onChanged: (links) => current = links,
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      // Se entra a editar la última.
      await tester.tap(find.byIcon(Symbols.edit).last);
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      // Y se quita la primera, que no es la que se estaba editando.
      await tester.tap(find.byIcon(Symbols.close).first);
      await tester.pump();

      expect(_urls(current), ['reddit.com/r/ejemplo1', 'reddit.com/r/ejemplo2']);
      // Sigue habiendo una sola en edición, y es la misma de antes.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Symbols.open_in_new), findsOneWidget);
    });

    testWidgets('quitar avisa con la lista ya sin ella', (tester) async {
      List<FernLink>? committed;

      await pumpAndTakeException(
        tester,
        _harness(
          FernLinkListField(
            links: _links(2),
            onChanged: (_) {},
            onCommitted: (links) => committed = links,
            label: 'Direcciones',
            emptyMessage: 'Sin direcciones vinculadas',
            hintText: 'reddit.com/r/ejemplo',
            addLabel: 'Añadir dirección',
            openTooltip: 'Abrir',
            editTooltip: 'Editar',
            removeTooltip: 'Quitar',
            doneTooltip: 'Terminar',
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      await tester.tap(find.byIcon(Symbols.close).first);
      await tester.pump();

      expect(_urls(committed!), ['reddit.com/r/ejemplo1']);
    });
  });

  group('la marca de no apta', () {
    testWidgets('sin contraseña puesta no hay botón', (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(
          _field(links: _links(2), fills: false),
          const Locale('es'),
          bounded: true,
        ),
      );

      expect(find.byIcon(Symbols.visibility_off), findsNothing);
    });

    testWidgets('marcar avisa con la dirección ya marcada', (tester) async {
      List<FernLink>? committed;

      await pumpAndTakeException(
        tester,
        _harness(
          _field(
            links: _links(2),
            fills: false,
            canMarkNsfw: true,
            onCommitted: (links) => committed = links,
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      await tester.tap(find.byIcon(Symbols.visibility_off).first);
      await tester.pump();

      expect(committed, isNotNull);
      expect(committed!.first.isNsfw, isTrue);
      expect(committed!.last.isNsfw, isFalse);
    });

    testWidgets('con el bloqueo cerrado, la marcada no se pinta',
        (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(
          _field(
            links: [
              const FernLink('reddit.com/r/normal'),
              const FernLink('reddit.com/r/marcada', isNsfw: true),
            ],
            fills: false,
            hidesMarked: true,
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      expect(find.text('reddit.com/r/normal'), findsOneWidget);
      expect(find.text('reddit.com/r/marcada'), findsNothing);
      // Ni fila, ni hueco, ni recuento.
      expect(find.textContaining('1'), findsNothing);
    });

    // El fallo que esto protege es el mismo que borraba las direcciones al
    // guardar el nombre de una etiqueta: lo que no se pinta no se puede caer de
    // la lista que se guarda.
    testWidgets('lo escondido sigue viajando al guardar', (tester) async {
      List<FernLink>? committed;

      await pumpAndTakeException(
        tester,
        _harness(
          _field(
            links: [
              const FernLink('reddit.com/r/normal'),
              const FernLink('reddit.com/r/marcada', isNsfw: true),
            ],
            fills: false,
            hidesMarked: true,
            onCommitted: (links) => committed = links,
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      // Se quita la única que se ve; la escondida no se ha tocado.
      await tester.tap(find.byIcon(Symbols.close).first);
      await tester.pump();

      expect(_urls(committed!), ['reddit.com/r/marcada']);
      expect(committed!.single.isNsfw, isTrue);
    });

    testWidgets('con todas marcadas y el bloqueo cerrado, se ve el vacío',
        (tester) async {
      await pumpAndTakeException(
        tester,
        _harness(
          _field(
            links: [const FernLink('reddit.com/r/marcada', isNsfw: true)],
            fills: false,
            hidesMarked: true,
          ),
          const Locale('es'),
          bounded: true,
        ),
      );

      expect(find.text('Sin direcciones vinculadas'), findsOneWidget);
    });
  });

  test('la fila mide lo que dice la constante', () {
    // Fijo para que las dos formas de una fila —el enlace en reposo y el campo
    // mientras se edita— midan lo mismo y la lista no dé un salto al entrar a
    // editar.
    expect(linkRowHeight, 32.0);
  });
}
