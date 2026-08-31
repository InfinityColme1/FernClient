// Elegir el avatar de la biblioteca en vez de ir a buscarlo por el disco.
//
// La cara de una etiqueta suele estar en su propio contenido, y la única forma
// de ponerla era el explorador de ficheros: buscar en el disco una imagen que
// la aplicación ya tiene guardada, sabe enseñar y tiene etiquetada.
//
// Lo que hay que sostener:
//
// - **Se busca como se busca en la aplicación.** La etiqueta y el texto se
//   cruzan, igual que las pastillas de la barra. Una segunda forma de buscar
//   que diga otra cosa sería lo peor que puede pasar aquí.
// - **Elegir no es trabajar con la biblioteca.** La rejilla no marca, no abre
//   el visor y no lleva menú del botón derecho: se coge una imagen prestada y
//   se cierra.
// - **La pregunta de dónde sale sigue teniendo las dos respuestas.** El
//   explorador de siempre no se va a ninguna parte.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/media_search_section_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/services/avatar_source.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_tree_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_criteria_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_library_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_source_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _media(int id, String path) =>
    MediaSummaryEntity(id: id, path: path);

TagEntity _tag(int id, String name) =>
    TagEntity(id: id, name: name, children: const []);

void main() {
  late AppLocalizations texts;
  late _FakeRepository repository;

  setUpAll(() async {
    texts = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    repository = _FakeRepository();

    getIt.reset();
    getIt.registerSingleton<SettingsRepository>(_Settings());
    getIt.registerSingleton<GetTagTreeUseCase>(
      GetTagTreeUseCase(localMediaRepository: repository),
    );
    getIt.registerSingleton<GetMediaListUsercase>(
      GetMediaListUsercase(localMediaRepository: repository),
    );
    getIt.registerSingleton<SearchMediaByCriteriaUseCase>(
      SearchMediaByCriteriaUseCase(repository),
    );
  });

  tearDown(() => getIt.reset());

  Future<MediaSummaryEntity?> open(WidgetTester tester) async {
    MediaSummaryEntity? chosen;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showDialog<MediaSummaryEntity>(
                context: context,
                builder: (_) => const AvatarLibraryDialog(),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    return chosen;
  }

  group('lo que se enseña', () {
    testWidgets('la biblioteca entera al abrir', (tester) async {
      await open(tester);

      expect(find.byType(MediaItem), findsNWidgets(3));
      // Sin nada puesto no se busca: eso es la biblioteca, no una búsqueda.
      expect(repository.asked, isEmpty);
    });

    testWidgets('y el árbol de etiquetas al lado', (tester) async {
      await open(tester);

      expect(find.byType(TagList), findsOneWidget);
      expect(find.text('Paisajes'), findsOneWidget);
    });

    // Fuera de la pantalla de gestión una persona es una etiqueta más, y así es
    // como se usa en todas partes. Repartidas, habría que saber en cuál de las
    // dos listas está guardada «Marinette» para poder buscar por ella.
    testWidgets('con las personas entre ellas', (tester) async {
      await open(tester);

      expect(find.text('Marinette'), findsOneWidget);
    });
  });

  group('elegir', () {
    testWidgets('pulsar un contenido lo devuelve', (tester) async {
      MediaSummaryEntity? chosen;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                chosen = await showDialog<MediaSummaryEntity>(
                  context: context,
                  builder: (_) => const AvatarLibraryDialog(),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MediaItem).first);
      await tester.pumpAndSettle();

      expect(chosen?.id, 1);
      expect(find.byType(AvatarLibraryDialog), findsNothing);
    });

    testWidgets('cerrarlo no devuelve nada', (tester) async {
      final chosen = await open(tester);

      expect(chosen, isNull);
      expect(find.byType(AvatarLibraryDialog), findsOneWidget);
    });
  });

  group('buscar', () {
    testWidgets('elegir una etiqueta busca por ella', (tester) async {
      await open(tester);

      await tester.tap(find.text('Paisajes'));
      await tester.pumpAndSettle();

      expect(repository.asked.last.single.id, 1);
      expect(repository.asked.last.single.kind, SearchCriterionKind.tag);
    });

    // Es la única forma de volver a la biblioteca entera sin cerrar el diálogo.
    testWidgets('y volver a pulsarla la suelta', (tester) async {
      await open(tester);

      await tester.tap(find.text('Paisajes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paisajes'));
      await tester.pumpAndSettle();

      // Soltarla no es buscar por nada: es volver a la biblioteca entera, que
      // no pasa por la búsqueda.
      expect(find.byType(MediaItem), findsNWidgets(3));
      expect(repository.asked, hasLength(1));
    });

    // Escribir no lanza una consulta por tecla: se espera a que se pare.
    testWidgets('escribir busca por el texto', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).last, 'montaña');
      await tester.pump(searchDebounceDuration);
      await tester.pumpAndSettle();

      expect(repository.asked.last.single.kind, SearchCriterionKind.text);
      expect(repository.asked.last.single.label, 'montaña');
    });

    testWidgets('y una tecla suelta no lanza nada todavía', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).last, 'm');
      await tester.pump(const Duration(milliseconds: 50));

      expect(repository.asked, isEmpty);

      // Se deja terminar la espera para no acabar con un temporizador vivo.
      await tester.pump(searchDebounceDuration);
      await tester.pumpAndSettle();
    });
  });

  // Lo que se cruza. Va aparte del widget para poder medirlo sin montar nada:
  // que la etiqueta y el texto se sumen en vez de pisarse es lo que hace que
  // buscar aquí signifique lo mismo que buscar en la barra.
  group('por qué se busca', () {
    test('sin nada puesto, por nada', () {
      expect(libraryPickerCriteria(), isEmpty);
    });

    test('sólo la etiqueta', () {
      final criteria = libraryPickerCriteria(tag: _tag(7, 'Paisajes'));

      expect(criteria.single.kind, SearchCriterionKind.tag);
      expect(criteria.single.id, 7);
    });

    test('sólo el texto', () {
      final criteria = libraryPickerCriteria(query: 'montaña');

      expect(criteria.single.kind, SearchCriterionKind.text);
      expect(criteria.single.label, 'montaña');
    });

    test('y los dos se cruzan', () {
      final criteria =
          libraryPickerCriteria(tag: _tag(7, 'Paisajes'), query: 'nieve');

      expect(criteria, hasLength(2));
    });

    // Un espacio no es una búsqueda: dejaría la rejilla vacía sin que nada lo
    // explique.
    test('lo escrito en blanco no cuenta', () {
      expect(libraryPickerCriteria(query: '   '), isEmpty);
    });
  });

  group('de dónde sale la imagen', () {
    Future<AvatarSource?> ask(WidgetTester tester) async {
      AvatarSource? answer;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                answer = await showDialog<AvatarSource>(
                  context: context,
                  builder: (_) => const AvatarSourceDialog(),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      return answer;
    }

    testWidgets('la biblioteca', (tester) async {
      AvatarSource? answer;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                answer = await showDialog<AvatarSource>(
                  context: context,
                  builder: (_) => const AvatarSourceDialog(),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(texts.avatarSourceLibrary));
      await tester.pumpAndSettle();

      expect(answer, AvatarSource.library);
    });

    // El explorador de siempre no se va a ninguna parte: hay avatares que no
    // están en la biblioteca y nunca van a estarlo.
    testWidgets('y el equipo siguen estando los dos', (tester) async {
      await ask(tester);

      expect(find.text(texts.avatarSourceLibrary), findsOneWidget);
      expect(find.text(texts.avatarSourceDevice), findsOneWidget);
    });
  });

  // 600 px es lo más bajo que la ventana se deja poner (`kMinimumWindowHeight`),
  // y 400 el caso extremo. El diálogo lleva dentro una lista y una rejilla, que
  // es lo más alto que puede pedir un diálogo de la aplicación.
  group('el alto', () {
    for (final height in [600.0, 400.0]) {
      testWidgets('no desborda a ${height.toInt()}px en ningún idioma',
          (tester) async {
        for (final locale in const [
          Locale('en'),
          Locale('es'),
          Locale('ca'),
          Locale('fr'),
        ]) {
          tester.view.physicalSize = Size(1200, height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          // El árbol se tira abajo antes de cada medida: reaprovechando los
          // render objects, el aviso sólo se da la primera vez.
          await tester.pumpWidget(const SizedBox.shrink());
          tester.takeException();

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: AvatarLibraryDialog()),
          ));
          await tester.pump(const Duration(milliseconds: 400));

          expect(
            tester.takeException(),
            isNull,
            reason: 'desborda a ${height.toInt()}px en ${locale.languageCode}',
          );
        }
      });
    }

    testWidgets('ni la pregunta de dónde sale', (tester) async {
      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
        Locale('fr'),
      ]) {
        tester.view.physicalSize = const Size(1000, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const SizedBox.shrink());
        tester.takeException();

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AvatarSourceDialog()),
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull, reason: locale.languageCode);
      }
    });
  });
}

class _FakeRepository implements LocalMediaRepository {
  /// Con qué criterios se ha pedido buscar, en orden.
  final List<List<SearchCriterionEntity>> asked = [];

  @override
  Future<DataState<List<TagEntity>>> getTagTree() async =>
      DataSuccess([
        _tag(1, 'Paisajes'),
        _tag(2, 'Retratos'),
        TagEntity(id: 3, name: 'Marinette', children: const [], isPerson: true),
      ]);

  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaList({
    MediaSortOrder order = MediaSortOrder.newestFirst,
  }) async =>
      DataSuccess([
        _media(1, 'una.png'),
        _media(2, 'otra.png'),
        _media(3, 'tercera.png'),
      ]);

  @override
  Future<DataState<List<MediaSearchSectionEntity>>> searchMediaByCriteria(
    List<SearchCriterionEntity> criteria,
  ) async {
    asked.add(criteria);

    return DataSuccess([
      MediaSearchSectionEntity(
        type: SearchResultType.tag,
        title: '',
        media: [_media(1, 'una.png')],
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Settings implements SettingsRepository {
  @override
  AppSettingsEntity getSettings() =>
      const AppSettingsEntity(avatarsPath: '', recognitionPath: '');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
