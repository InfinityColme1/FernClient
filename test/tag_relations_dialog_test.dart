// El árbol de relaciones de una etiqueta.
//
// Sustituye a los dos buscadores y la lista de relacionadas que había en la
// ficha, que entre las tres cosas ocupaban tanto que la rejilla de contenido de
// debajo se salía de la pantalla.
//
// Lo que se comprueba aquí es lo que el árbol **cuenta**: quién está en el
// centro, quién encima y quién al lado, porque esa colocación es literalmente el
// significado de las tres relaciones. Y que lo elegido salga por la puerta: el
// diálogo no guarda nada, así que si se pierde por el camino no lo dice nadie.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_relations_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

void main() {
  final self = _tag(1, 'la que se edita');
  final parent = _tag(2, 'la madre');
  final sibling = _tag(3, 'la de al lado');
  final other = _tag(4, 'otra más');

  /// Monta el diálogo con las relaciones que se le digan.
  Future<void> open(
    WidgetTester tester, {
    TagEntity? withParent,
    List<TagEntity> withSiblings = const [],
    List<TagEntity> found = const [],
  }) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TagRelationsDialog(
            tag: self,
            parent: withParent,
            siblings: withSiblings,
            searchParents: (_) async => found,
            searchSiblings: (_) async => found,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('lo que enseña', () {
    testWidgets('la etiqueta que se edita, siempre', (tester) async {
      await open(tester);

      expect(find.text('la que se edita'), findsOneWidget);
    });

    testWidgets('la madre encima', (tester) async {
      await open(tester, withParent: parent);

      final selfBox = tester.getCenter(find.text('la que se edita'));
      final parentBox = tester.getCenter(find.text('la madre'));

      expect(parentBox.dy, lessThan(selfBox.dy));
    });

    // A la misma altura y no debajo: una relacionada no cuelga de nadie, y
    // ponerla más abajo la haría parecer una hija.
    testWidgets('las relacionadas al lado, no debajo', (tester) async {
      await open(tester, withSiblings: [sibling]);

      final selfBox = tester.getCenter(find.text('la que se edita'));
      final siblingBox = tester.getCenter(find.text('la de al lado'));

      expect(siblingBox.dy, selfBox.dy);
      expect(siblingBox.dx, isNot(selfBox.dx));
    });

    testWidgets('con dos relacionadas, una a cada lado', (tester) async {
      await open(tester, withSiblings: [sibling, other]);

      final selfBox = tester.getCenter(find.text('la que se edita'));
      final first = tester.getCenter(find.text('la de al lado'));
      final second = tester.getCenter(find.text('otra más'));

      expect(first.dx, greaterThan(selfBox.dx));
      expect(second.dx, lessThan(selfBox.dx));
    });
  });

  group('lo que se puede quitar', () {
    // Por el tooltip y no por el icono: el aspa de cerrar el diálogo es la misma
    // y contarla haría que estas comprobaciones dijeran cualquier cosa.
    final removers = find.byTooltip('Quitar');

    // La etiqueta de la que es el árbol no se puede sacar de él.
    testWidgets('la que se edita no lleva aspa', (tester) async {
      await open(tester);

      expect(removers, findsNothing);
    });

    testWidgets('la madre y las relacionadas sí', (tester) async {
      await open(tester, withParent: parent, withSiblings: [sibling]);

      expect(removers, findsNWidgets(2));
    });

    testWidgets('quitar la madre la saca del árbol', (tester) async {
      await open(tester, withParent: parent);

      await tester.tap(removers);
      await tester.pumpAndSettle();

      expect(find.text('la madre'), findsNothing);
      expect(find.text('la que se edita'), findsOneWidget);
    });

    testWidgets('quitar una relacionada la saca y deja el resto', (tester) async {
      await open(tester, withSiblings: [sibling, other]);

      await tester.tap(removers.first);
      await tester.pumpAndSettle();

      expect(find.text('la de al lado'), findsNothing);
      expect(find.text('otra más'), findsOneWidget);
    });
  });

  group('lo que devuelve', () {
    testWidgets('lo que había, si no se toca nada', (tester) async {
      TagRelations? result;

      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: Builder(
                builder: (inner) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<TagRelations>(
                      context: inner,
                      builder: (_) => TagRelationsDialog(
                        tag: self,
                        parent: parent,
                        siblings: [sibling],
                        searchParents: (_) async => const [],
                        searchSiblings: (_) async => const [],
                      ),
                    );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(result?.parent?.id, parent.id);
      expect(result?.siblings.map((one) => one.id), [sibling.id]);
    });
  });
}
