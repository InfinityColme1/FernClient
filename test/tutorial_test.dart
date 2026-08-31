// El tutorial: que se ofrezca una sola vez, que se pueda dejar y que señale a
// donde dice que señala.
//
// Lo que se comprueba aquí es lo que lo hace opcional de verdad. Un tutorial que
// se vuelve a ofrecer cada vez que se abre la aplicación, o del que no se puede
// salir, deja de ser una oferta.

import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_controller.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_step.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_tours.dart';
import 'package:Fern/features/tutorial/presentation/widgets/tutorial_overlay.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TutorialController> _controller() async {
  SharedPreferences.setMockInitialValues({});

  return TutorialController(
    PreferencesService(await SharedPreferences.getInstance()),
  );
}

const _steps = [
  TutorialStep(title: 'uno', body: 'el primero'),
  TutorialStep(title: 'dos', body: 'el segundo', anchorId: 'algo'),
  TutorialStep(title: 'tres', body: 'el tercero'),
];

void main() {
  setUp(TutorialAnchors.reset);

  group('a quién se le ofrece', () {
    test('la primera vez que se abre la aplicación, sí', () async {
      expect((await _controller()).isUnoffered, isTrue);
    });

    test('una vez ofrecido, ya no', () async {
      final controller = await _controller();
      await controller.markOffered();

      expect(controller.isUnoffered, isFalse);
    });

    test('lo ofrecido sobrevive a cerrar la aplicación', () async {
      final controller = await _controller();
      await controller.markOffered();

      // Otro controlador sobre las mismas preferencias: es lo que hay al volver
      // a abrir.
      final next = TutorialController(
        PreferencesService(await SharedPreferences.getInstance()),
      );

      expect(next.isUnoffered, isFalse);
    });
  });

  group('el recorrido', () {
    test('empieza por el primero y sabe cuántos son', () async {
      final controller = await _controller()
        ..start(_steps);

      expect(controller.isRunning, isTrue);
      expect(controller.step?.title, 'uno');
      expect(controller.position, 1);
      expect(controller.total, 3);
      expect(controller.isFirst, isTrue);
      expect(controller.isLast, isFalse);
    });

    test('avanza y vuelve', () async {
      final controller = await _controller()
        ..start(_steps)
        ..next()
        ..next();

      expect(controller.step?.title, 'tres');
      expect(controller.isLast, isTrue);

      controller.back();
      expect(controller.step?.title, 'dos');
    });

    test('del primero no se vuelve más atrás', () async {
      final controller = await _controller()
        ..start(_steps)
        ..back();

      expect(controller.position, 1);
    });

    test('seguir en el último es terminar', () async {
      final controller = await _controller()
        ..start(_steps)
        ..next()
        ..next()
        ..next();

      expect(controller.isRunning, isFalse);
      expect(controller.step, isNull);
    });

    test('se puede dejar en cualquier paso', () async {
      final controller = await _controller()
        ..start(_steps)
        ..next()
        ..finish();

      expect(controller.isRunning, isFalse);
    });

    test('volver a arrancarlo empieza otra vez por el principio', () async {
      final controller = await _controller()
        ..start(_steps)
        ..next()
        ..finish()
        ..start(_steps);

      expect(controller.position, 1);
    });
  });

  group('a qué señala', () {
    testWidgets('un ancla montada dice qué trozo de pantalla ocupa',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: TutorialAnchor(
            id: 'algo',
            child: SizedBox(width: 120, height: 40),
          ),
        ),
      ));

      expect(TutorialAnchors.rectOf('algo'), const Rect.fromLTWH(0, 0, 120, 40));
    });

    testWidgets('lo que no está montado no señala a ningún sitio',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(TutorialAnchors.rectOf('algo'), isNull);
    });

    testWidgets('desmontar un ancla la retira', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: TutorialAnchor(id: 'algo', child: SizedBox()),
      ));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(TutorialAnchors.rectOf('algo'), isNull);
    });
  });

  group('el velo', () {
    Future<TutorialController> pump(WidgetTester tester) async {
      final controller = await _controller();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              // Que la pila ocupe la pantalla: el velo se coloca con
              // `Positioned.fill`, y los hijos colocados no dan tamano a la
              // pila. Sin esto la pila se encoge hasta el ancla y el cartel se
              // pinta dentro de cien pixeles.
              const SizedBox.expand(),
              const Positioned(
                left: 40,
                top: 40,
                child: TutorialAnchor(
                  id: 'algo',
                  child: SizedBox(width: 100, height: 100),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    TutorialOverlay(controller: controller),
              ),
            ],
          ),
        ),
      ));

      return controller;
    }

    testWidgets('sin tutorial no se ve nada', (tester) async {
      await pump(tester);

      expect(find.text('uno'), findsNothing);
    });

    testWidgets('con tutorial se ve el paso y por dónde va', (tester) async {
      final controller = await pump(tester);

      controller.start(_steps);
      await tester.pumpAndSettle();

      expect(find.text('uno'), findsOneWidget);
      expect(find.text('el primero'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('el botón de salir lo cierra', (tester) async {
      final controller = await pump(tester);

      controller.start(_steps);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(controller.isRunning, isFalse);
      expect(find.text('uno'), findsNothing);
    });

    testWidgets('el último paso se despide en vez de ofrecer otro',
        (tester) async {
      final controller = await pump(tester);

      controller.start(_steps);
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);

      controller
        ..next()
        ..next();
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });
  });

  group('donde cabe el cartel', () {
    /// El velo con un ancla del tamano y el sitio que se le diga.
    Future<Rect> cardRect(WidgetTester tester, Rect anchor) async {
      final controller = await _controller();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              Positioned.fromRect(
                rect: anchor,
                child: const TutorialAnchor(id: 'algo', child: SizedBox()),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    TutorialOverlay(controller: controller),
              ),
            ],
          ),
        ),
      ));

      controller.start(const [
        TutorialStep(title: 'senala', body: 'algo', anchorId: 'algo'),
      ]);
      await tester.pumpAndSettle();

      return tester.getRect(find.text('senala').first);
    }

    /// Lo que de verdad importa: que se vea entero.
    ///
    /// Estos dos casos son los que estaban rotos. El menu lateral es una columna
    /// que va de arriba abajo, asi que no deja franja ni encima ni debajo; la
    /// rejilla ocupa casi toda la pantalla y no deja ninguna de las cuatro. Con
    /// el alto estimado, los dos daban un sitio que empezaba fuera.
    void expectInside(Rect card, Size screen) {
      expect(card.top, greaterThanOrEqualTo(0));
      expect(card.left, greaterThanOrEqualTo(0));
      expect(card.right, lessThanOrEqualTo(screen.width));
      expect(card.bottom, lessThanOrEqualTo(screen.height));
    }

    testWidgets('senalando una columna alta, el cartel se ve entero',
        (tester) async {
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

      expectInside(
        await cardRect(tester, Rect.fromLTWH(0, 0, 250, screen.height)),
        screen,
      );
    });

    testWidgets('senalando casi toda la pantalla, el cartel se ve entero',
        (tester) async {
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

      expectInside(
        await cardRect(
          tester,
          Rect.fromLTWH(20, 20, screen.width - 40, screen.height - 40),
        ),
        screen,
      );
    });

    testWidgets('senalando algo pequeno arriba, el cartel va debajo',
        (tester) async {
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final card = await cardRect(tester, const Rect.fromLTWH(300, 10, 40, 40));

      expectInside(card, screen);
      expect(card.top, greaterThan(50));
    });
  });

  group('lo que se remarca', () {
    /// Lo que el velo esta senalando, leido de quien lo pinta.
    Rect? spotlightOf(WidgetTester tester) {
      final paints = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((paint) => paint.painter is TutorialSpotlightPainter);

      return (paints.first.painter! as TutorialSpotlightPainter).spotlight;
    }

    testWidgets('sigue a lo que entra hasta que se para', (tester) async {
      // **El fallo que esto cierra.** El panel de la derecha de los gestores
      // entra deslizandose desde fuera, y el foco se media en el primer
      // fotograma: salia corrido hacia la derecha y remarcaba media pantalla
      // vacia en vez de la lista.
      final controller = await _controller();
      const destino = Rect.fromLTWH(120, 60, 200, 400);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              // Entra desde fuera, como la pantalla de verdad.
              TweenAnimationBuilder<Rect?>(
                tween: RectTween(
                  begin: const Rect.fromLTWH(700, 60, 200, 400),
                  end: destino,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, rect, _) => Positioned.fromRect(
                  rect: rect!,
                  child: const TutorialAnchor(id: 'algo', child: SizedBox()),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    TutorialOverlay(controller: controller),
              ),
            ],
          ),
        ),
      ));

      controller.start(const [
        TutorialStep(title: 'senala', body: 'algo', anchorId: 'algo'),
      ]);
      await tester.pumpAndSettle();

      expect(spotlightOf(tester), destino);
    });

    testWidgets('no da por colocada una pantalla que aun no ha empezado a entrar',
        (tester) async {
      // **El fallo que esto cierra, y que se colo dos veces.** Justo despues de
      // que el tutorial pida la pantalla, su animacion de entrada todavia no ha
      // arrancado: dos fotogramas seguidos dan el mismo sitio y parece que ya
      // esta colocada. Se remarcaba el sitio de partida, fuera de la pantalla.
      final controller = await _controller();
      final entrada = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: tester,
      );
      addTearDown(entrada.dispose);

      const destino = Rect.fromLTWH(140, 40, 220, 380);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              ScreenTransitionScope(
                entering: entrada,
                leaving: kAlwaysDismissedAnimation,
                child: AnimatedBuilder(
                  animation: entrada,
                  builder: (context, _) => Positioned.fromRect(
                    rect: RectTween(
                      begin: const Rect.fromLTWH(760, 40, 220, 380),
                      end: destino,
                    ).transform(entrada.value)!,
                    child: const TutorialAnchor(id: 'algo', child: SizedBox()),
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    TutorialOverlay(controller: controller),
              ),
            ],
          ),
        ),
      ));

      controller.start(const [
        TutorialStep(title: 'senala', body: 'algo', anchorId: 'algo'),
      ]);

      // Unos cuantos fotogramas con la animacion parada en su sitio de partida:
      // es el hueco en el que el velo se daba por satisfecho.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      entrada.forward();
      await tester.pumpAndSettle();

      expect(spotlightOf(tester), destino);
    });

    testWidgets('lo que no llega a aparecer no se senala', (tester) async {
      final controller = await _controller();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) =>
                    TutorialOverlay(controller: controller),
              ),
            ],
          ),
        ),
      ));

      controller.start(const [
        TutorialStep(title: 'senala', body: 'nada', anchorId: 'no-existe'),
      ]);
      await tester.pumpAndSettle();

      expect(spotlightOf(tester), isNull);
    });
  });

  group('el cartel en la ventana mas pequena', () {
    testWidgets('el paso mas largo de cada idioma cabe sin desbordarse',
        (tester) async {
      // La ventana no puede hacerse menor que esto: lo impide el propio
      // ejecutable (`windows/runner/win32_window.h`). Si el cartel no cabe aqui,
      // no cabe en ninguna parte.
      tester.view.physicalSize = const Size(1180, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final locale in AppLocalizations.supportedLocales) {
        final controller = await _controller();
        late List<TutorialStep> todos;

        await tester.pumpWidget(MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            todos = [
              for (final tour in TutorialTour.values)
                ...tour.steps(AppLocalizations.of(context)),
            ];

            return Scaffold(
              body: Stack(
                children: [
                  const SizedBox.expand(),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) =>
                        TutorialOverlay(controller: controller),
                  ),
                ],
              ),
            );
          }),
        ));

        // El de texto mas largo de todos los recorridos, que es el unico que
        // puede no caber.
        todos.sort((a, b) => b.body.length.compareTo(a.body.length));

        controller.start([todos.first]);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: '$locale');
        expect(find.text(todos.first.body), findsOneWidget, reason: '$locale');
      }
    });
  });

  group('los recorridos', () {
    /// Todos los recorridos armados en un idioma.
    Future<Map<TutorialTour, List<TutorialStep>>> tours(
      WidgetTester tester,
      Locale locale,
    ) async {
      late Map<TutorialTour, List<TutorialStep>> built;

      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final texts = AppLocalizations.of(context);
          built = {
            for (final tour in TutorialTour.values) tour: tour.steps(texts),
          };

          return const SizedBox();
        }),
      ));

      return built;
    }

    testWidgets('todos tienen texto en los cuatro idiomas', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final entry in (await tours(tester, locale)).entries) {
          final donde = '${entry.key.name} en $locale';

          expect(entry.value, isNotEmpty, reason: donde);

          for (final step in entry.value) {
            expect(step.title, isNotEmpty, reason: donde);
            expect(step.body, isNotEmpty, reason: donde);
          }
        }
      }
    });

    testWidgets('ninguno lleva al visor', (tester) async {
      // El visor se abre por encima del marco de la aplicación, y el velo del
      // tutorial vive dentro de ese marco: llevar ahí seria taparlo con la
      // pantalla que se queria enseñar.
      for (final steps in (await tours(tester, const Locale('es'))).values) {
        for (final step in steps) {
          expect(step.route, isNot(viewerRoute));
        }
      }
    });

    testWidgets('el que cambia de pantalla lo dice en su primer paso',
        (tester) async {
      // Un recorrido especializado que no lleve a su pantalla se enseña sobre la
      // que hubiera, señalando a anclas que son de otra cosa.
      final built = await tours(tester, const Locale('es'));

      for (final entry in built.entries) {
        if (entry.key == TutorialTour.general) continue;

        expect(entry.value.first.route, isNotNull, reason: entry.key.name);
      }
    });

    testWidgets('ninguno se hace interminable', (tester) async {
      // Los recorridos son el manual de la aplicacion: entre todos tienen que
      // explicarlo todo, asi que se les dejo crecer. Lo que este tope evita es lo
      // otro: un recorrido de veinte pasos no se termina, y lo que no se termina
      // no explica nada.
      //
      // La profundidad se consigue **repartiendo en mas recorridos**, no
      // alargando uno: por eso son diez y no seis.
      for (final entry in (await tours(tester, const Locale('es'))).entries) {
        expect(entry.value.length, lessThanOrEqualTo(12),
            reason: entry.key.name);
      }
    });

    testWidgets('y ninguno se queda en dos pasos', (tester) async {
      // Un recorrido de dos pasos no es un recorrido: es un aviso. Si una
      // materia da para tan poco, va dentro de otra.
      for (final entry in (await tours(tester, const Locale('es'))).entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: entry.key.name);
      }
    });

    // Un titulo repetido en dos recorridos es casi siempre un copiar y pegar que
    // dejo el texto de otro paso.
    testWidgets('ningun paso repite el titulo de otro', (tester) async {
      final vistos = <String, String>{};

      for (final entry in (await tours(tester, const Locale('es'))).entries) {
        for (final step in entry.value) {
          expect(
            vistos[step.title],
            isNull,
            reason: '${step.title}: en ${entry.key.name} y en '
                '${vistos[step.title]}',
          );

          vistos[step.title] = entry.key.name;
        }
      }
    });

    // Son el manual: un paso que despacha un concepto en seis palabras no lo
    // explica, lo menciona.
    testWidgets('todos los pasos explican algo', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final entry in (await tours(tester, locale)).entries) {
          for (final step in entry.value) {
            expect(
              step.body.length,
              greaterThanOrEqualTo(80),
              reason: '${step.title} en $locale',
            );
          }
        }
      }
    });

    testWidgets('los diez salen en la ayuda con su nombre', (tester) async {
      final built = await tours(tester, const Locale('es'));

      expect(built.keys.length, TutorialTour.values.length);
      expect(TutorialTour.values, contains(TutorialTour.fernie));
      expect(TutorialTour.values, contains(TutorialTour.models));
      expect(TutorialTour.values, contains(TutorialTour.duplicates));
      expect(TutorialTour.values, contains(TutorialTour.managers));
      expect(TutorialTour.values, contains(TutorialTour.importing));

      // Las cuatro materias que faltaban: sin ellas, alguien que siguiera todos
      // los recorridos seguiria sin saber que es el bloqueo de contenido ni
      // donde viven sus ficheros.
      expect(TutorialTour.values, contains(TutorialTour.library));
      expect(TutorialTour.values, contains(TutorialTour.searching));
      expect(TutorialTour.values, contains(TutorialTour.nsfw));
      expect(TutorialTour.values, contains(TutorialTour.files));
    });
  });
}
