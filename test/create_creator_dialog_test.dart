// Crear un creador con sus direcciones y su marca, sin salir del diálogo.
//
// Las dos cosas se podían hacer sólo desde la pantalla de gestión: había que
// crear el creador, ir a buscarlo a su lista y volver a abrirlo para vincularle
// una dirección o esconderlo. Y son justo las dos cosas que se saben al crearlo
// — de dónde sale su contenido, y si se quiere a la vista.
//
// La marca sólo se ofrece con contraseña puesta: sin ella no escondería nada.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/recognition/domain/usecases/save_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/save_model_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations texts;

  setUpAll(() async {
    texts = await AppLocalizations.delegate.load(const Locale('es'));
  });

  /// Monta el diálogo con lo justo para que se pinte.
  ///
  /// [isConfigured] es si hay contraseña puesta: de eso depende que la marca se
  /// ofrezca.
  Future<void> pump(
    WidgetTester tester, {
    required bool isConfigured,
    bool isTag = false,
  }) async {
    await getIt.reset();
    getIt.registerSingleton<NsfwModeService>(_Mode(isConfigured));
    getIt.registerSingleton<SearchTagsUseCase>(_NoSearch());
    getIt.registerSingleton<SaveTagUseCase>(_NoSaveTag());
    getIt.registerSingleton<SaveCreatorUseCase>(_NoSaveCreator());
    getIt.registerSingleton<SaveCreatorTagsUseCase>(_NoSaveCreatorTags());
    getIt.registerSingleton<SaveFernieUseCase>(_NoSaveFernie());
    getIt.registerSingleton<SaveModelUseCase>(_NoSaveModel());

    addTearDown(getIt.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: isTag ? const FernCreateDialog.tag() : const FernCreateDialog.creator(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('el diálogo de crear un creador', () {
    testWidgets('ofrece vincularle direcciones', (tester) async {
      await pump(tester, isConfigured: false);

      expect(find.byTooltip(texts.assignUrlsTooltip), findsOneWidget);
    });

    // Los mismos que su ficha de la pantalla de gestion: lo que trae puesto es
    // parte de como se define un creador, y tenerlo solo despues de crearlo
    // obligaba a crearlo, ir a buscarlo y volver a abrirlo.
    testWidgets('y decir que etiquetas trae consigo', (tester) async {
      await pump(tester, isConfigured: false);

      expect(find.byTooltip(texts.creatorTagsTooltip), findsOneWidget);
    });

    testWidgets('y marcarlo, con contraseña puesta', (tester) async {
      await pump(tester, isConfigured: true);

      expect(find.byTooltip(texts.creatorNsfwOffTooltip), findsOneWidget);
    });

    // Sin contraseña, marcar no escondería nada: el botón no sale.
    testWidgets('sin contraseña no se ofrece marcarlo', (tester) async {
      await pump(tester, isConfigured: false);

      expect(find.byTooltip(texts.creatorNsfwOffTooltip), findsNothing);
    });

    // Sin marcar, las dos variantes dicen lo mismo («Marcar como NSFW»); es al
    // marcarlo cuando el aviso tiene que hablar de un creador y no de una
    // etiqueta.
    testWidgets('y una vez marcado lo dice en masculino', (tester) async {
      await pump(tester, isConfigured: true);

      await tester.tap(find.byTooltip(texts.creatorNsfwOffTooltip));
      await tester.pumpAndSettle();

      expect(find.byTooltip(texts.creatorNsfwOnTooltip), findsOneWidget);
      expect(find.byTooltip(texts.tagNsfwOnTooltip), findsNothing);
    });

    // Lo que no es de un creador se queda donde estaba: decir que es una
    // persona sólo tiene sentido en una etiqueta.
    testWidgets('pero no que sea una persona', (tester) async {
      await pump(tester, isConfigured: true);

      expect(find.byTooltip(texts.tagIsPerson), findsNothing);
    });
  });

  group('y el de crear una etiqueta sigue igual', () {
    testWidgets('con sus tres botones', (tester) async {
      await pump(tester, isConfigured: true, isTag: true);

      expect(find.byTooltip(texts.tagIsPerson), findsOneWidget);
      expect(find.byTooltip(texts.tagNsfwOffTooltip), findsOneWidget);
      expect(find.byTooltip(texts.assignUrlsTooltip), findsOneWidget);
    });
  });
}

class _Mode implements NsfwModeService {
  final bool _isConfigured;

  _Mode(this._isConfigured);

  @override
  bool get isConfigured => _isConfigured;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Los casos de uso no se llegan a llamar: el diálogo sólo se pinta. Uno por
/// clase porque cada uno contesta cosas distintas y no se pueden juntar.
class _NoSearch implements SearchTagsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSaveTag implements SaveTagUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSaveCreator implements SaveCreatorUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSaveCreatorTags implements SaveCreatorTagsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSaveFernie implements SaveFernieUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoSaveModel implements SaveModelUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
