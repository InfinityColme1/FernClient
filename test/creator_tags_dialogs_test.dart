// Los dos dialogos nuevos del creador.
//
// El de sus etiquetas —lo que trae consigo— y el de ponerselo a toda una
// seleccion. Se mide lo que se ve: lo que escriben ya esta medido contra la
// base de datos en `creator_tags_test.dart`.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/services/recent_picks.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_tags_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_to_selection_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

void main() {
  late AppLocalizations texts;

  setUpAll(() async {
    texts = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(WidgetTester tester, Widget dialog) async {
    await getIt.reset();
    getIt.registerSingleton<SearchTagsUseCase>(_NoSearchTags());
    getIt.registerSingleton<SearchCreatorsUseCase>(_NoSearchCreators());
    getIt.registerSingleton<RecentPicks>(_NoRecents());

    addTearDown(getIt.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: dialog),
    ));
    await tester.pumpAndSettle();
  }

  group('las etiquetas de un creador', () {
    testWidgets('salen las que ya tiene', (tester) async {
      await pump(
        tester,
        AssignCreatorTagsDialog(
          tags: [_tag(1, 'One Piece'), _tag(2, 'manga')],
          name: 'Uukkaa',
        ),
      );

      expect(find.text('One Piece'), findsOneWidget);
      expect(find.text('manga'), findsOneWidget);
    });

    // El panel dice de quien son: el dialogo se abre desde una ficha, pero
    // encima de ella, y sin el nombre no se sabe a cual se le esta poniendo.
    testWidgets('con el nombre de quien las trae', (tester) async {
      await pump(
        tester,
        AssignCreatorTagsDialog(tags: [_tag(1, 'One Piece')], name: 'Uukkaa'),
      );

      expect(find.text('Uukkaa'), findsOneWidget);
    });

    testWidgets('sin ninguna se dice que no hay', (tester) async {
      await pump(
        tester,
        const AssignCreatorTagsDialog(tags: [], name: 'Uukkaa'),
      );

      expect(find.text(texts.noTagsYet), findsOneWidget);
    });

    testWidgets('quitar una la saca de la lista', (tester) async {
      await pump(
        tester,
        AssignCreatorTagsDialog(
          tags: [_tag(1, 'One Piece'), _tag(2, 'manga')],
          name: 'Uukkaa',
        ),
      );

      // El aspa de la primera pildora.
      await tester.tap(find.byIcon(Symbols.cancel).first);
      await tester.pumpAndSettle();

      expect(find.text('One Piece'), findsNothing);
      expect(find.text('manga'), findsOneWidget);
    });

    // Aviso de que esto vale de aqui en adelante: quien relaciona una etiqueta
    // con un creador de cuatrocientos contenidos tiene que saber que no se le
    // van a etiquetar cuatrocientos contenidos.
    testWidgets('se avisa de que no reetiqueta lo que ya hay', (tester) async {
      await pump(
        tester,
        const AssignCreatorTagsDialog(tags: [], name: 'Uukkaa'),
      );

      expect(find.text(texts.creatorTagsHint), findsOneWidget);
    });
  });

  group('poner creador a la seleccion', () {
    // Es lo unico que lo distingue de ponerselo a uno: sin el numero, confirmar
    // es a ciegas.
    testWidgets('dice a cuantos va', (tester) async {
      await pump(tester, const AssignCreatorToSelectionDialog(count: 12));

      expect(
        find.text(texts.assignCreatorToSelectionHint(12)),
        findsOneWidget,
      );
    });

    testWidgets('y sin nadie elegido el panel dice cuantos son',
        (tester) async {
      await pump(tester, const AssignCreatorToSelectionDialog(count: 12));

      expect(find.text(texts.selectedCount(12)), findsOneWidget);
    });

    testWidgets('ofrece buscar un creador', (tester) async {
      await pump(tester, const AssignCreatorToSelectionDialog(count: 3));

      expect(find.text(texts.searchCreatorLabel), findsOneWidget);
    });

    // Marcando una tanda es justo cuando se descubre que el artista todavia no
    // existe.
    testWidgets('y crear uno que no existe', (tester) async {
      await pump(tester, const AssignCreatorToSelectionDialog(count: 3));

      expect(find.text(texts.createCreator), findsOneWidget);
    });
  });
}

/// Ninguno de los dos buscadores se llega a usar: los dialogos solo se pintan.
class _NoSearchTags implements SearchTagsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSearchCreators implements SearchCreatorsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoRecents implements RecentPicks {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
