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
import 'package:Fern/features/media/domain/services/sibling_direction.dart';
import 'package:Fern/features/media/presentation/widgets/tag_relations_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

TagEntity _tag(int id, String name, {List<int> muted = const []}) =>
    TagEntity(
      id: id,
      name: name,
      children: const [],
      mutedSiblings: muted,
    );

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
      // Sin tocar nada, la que tenía: aquí no había ninguna silenciada.
      expect(result?.directionOf(sibling.id), SiblingDirection.both);
    });
  });

  // Ser hermanas dice que van juntas; la dirección dice qué pasa al poner una.
  //
  // Se elige aquí porque es donde se ve la forma de la relación: el sentido es
  // parte de esa forma, y ponerlo en otro sitio obligaría a mirar en dos.
  group('la dirección', () {
    testWidgets('sólo la tienen las relacionadas', (tester) async {
      await open(tester, withParent: parent, withSiblings: [sibling]);

      // De la madre a la hija manda la jerarquía, y de la que se edita no hay
      // nada que decir: una sola flecha, la de la relacionada.
      expect(find.byIcon(Symbols.sync_alt), findsOneWidget);
    });

    testWidgets('sin relacionadas no se explica nada', (tester) async {
      final texts = await AppLocalizations.delegate.load(const Locale('es'));

      await open(tester, withParent: parent);

      expect(find.text(texts.siblingDirectionNote), findsNothing);
    });

    testWidgets('con una, se explica', (tester) async {
      final texts = await AppLocalizations.delegate.load(const Locale('es'));

      await open(tester, withSiblings: [sibling]);

      expect(find.text(texts.siblingDirectionNote), findsOneWidget);
    });

    testWidgets('se enseña la que hay puesta', (tester) async {
      // La relacionada no la pone: sólo va en un sentido.
      await open(
        tester,
        withSiblings: [_tag(3, 'la de al lado', muted: [1])],
      );

      expect(find.byIcon(Symbols.arrow_forward), findsOneWidget);
      expect(find.byIcon(Symbols.sync_alt), findsNothing);
    });

    // La tarjeta mide 200 px y ahora lleva avatar, nombre, sentido y aspa. Con
    // un nombre largo era donde iba a romperse.
    testWidgets('la tarjeta no desborda con un nombre largo', (tester) async {
      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
        Locale('fr'),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.takeException();

        tester.view.physicalSize = const Size(1600, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TagRelationsDialog(
              tag: self,
              parent: parent,
              siblings: [
                _tag(3, 'una etiqueta con un nombre larguísimo que no cabe'),
                _tag(5, 'otra igual de larga para el otro lado del árbol'),
              ],
              searchParents: (_) async => const [],
              searchSiblings: (_) async => const [],
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          tester.takeException(),
          isNull,
          reason: 'la tarjeta desborda en ${locale.languageCode}',
        );
      }
    });

    testWidgets('elegir otra la cambia y sale por la puerta', (tester) async {
      final texts = await AppLocalizations.delegate.load(const Locale('es'));
      TagRelations? result;

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
            body: Center(
              child: Builder(
                builder: (inner) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<TagRelations>(
                      context: inner,
                      builder: (_) => TagRelationsDialog(
                        tag: self,
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

      // El desplegable, y dentro la opción con los dos nombres escritos: un
      // icono de flecha a secas no dice hacia dónde apunta cuando la tarjeta
      // puede estar a un lado o al otro.
      await tester.tap(find.byIcon(Symbols.sync_alt));
      await tester.pumpAndSettle();

      await tester.tap(find.text(
        texts.siblingDirectionOneWay(self.name, sibling.name),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(result?.directionOf(sibling.id), SiblingDirection.forward);
      // Y la relación sigue estando: cambiar el sentido no la deshace.
      expect(result?.siblings.map((one) => one.id), [sibling.id]);
    });
  });
}
