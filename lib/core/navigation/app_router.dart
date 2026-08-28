import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/main_layout.dart';
import 'package:Fern/core/navigation/page_transitions.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/features/browser/presentation/pages/browser_page.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:Fern/features/media/presentation/pages/creator_manager_page.dart';
import 'package:Fern/features/media/presentation/pages/delete_page.dart';
import 'package:Fern/features/media/presentation/pages/favorites_page.dart';
import 'package:Fern/features/media/presentation/pages/import_page.dart';
import 'package:Fern/features/media/presentation/pages/media_page.dart';
import 'package:Fern/features/media/presentation/pages/tag_manager_page.dart';
import 'package:Fern/features/media/presentation/pages/viewer_page.dart';
import 'package:Fern/features/recognition/presentation/pages/fernies_page.dart';
import 'package:Fern/features/recognition/presentation/pages/model_detail_page.dart';
import 'package:Fern/features/recognition/presentation/pages/model_tree_page.dart';
import 'package:Fern/features/recognition/presentation/pages/models_page.dart';
import 'package:Fern/features/duplicates/presentation/pages/repeated_media_page.dart';
import 'package:Fern/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/media/presentation/blocs/media_bloc.dart';
import '../service_locator.dart';


final appRouter = GoRouter(
  initialLocation: splashRoute,
  routes: [
    // La bienvenida va fuera del armazón: no lleva ni cabecera ni menú lateral,
    // sólo el logo. Sale con la transición de la aplicación, así que se
    // desvanece sobre la biblioteca en lugar de cortarse de golpe.
    GoRoute(
      path: splashRoute,
      pageBuilder: (context, state) => fernTransitionPage(
        key: state.pageKey,
        child: const SplashPage(),
      ),
    ),

    ShellRoute(
      // El armazón (barra superior + menú lateral) envuelve siempre a sus
      // pantallas. Si se le quitara al navegar al visor, las pantallas que
      // siguen montadas debajo perderían el `Scaffold` y con él el `Material`
      // que necesitan sus widgets, que es justo lo que asomaba durante la
      // transición.
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<MediaBloc>.value(value: getIt<MediaBloc>()),
            // El indicador de trabajos vive en la barra superior del armazón,
            // así que su bloc se provee aquí y no en cada pantalla.
            BlocProvider<JobsBloc>.value(value: getIt<JobsBloc>()),
            // Los contadores de avisos se pintan en el menú lateral y se dan
            // por vistos al llegar a la pantalla: los dos están aquí dentro.
            BlocProvider<NotificationsBloc>.value(
              value: getIt<NotificationsBloc>(),
            ),
          ],
          child: MainLayout(child: child),
        );
      },
      // Las pantallas del armazón entran con un fundido corto y nada más.
      //
      // Estaban sin transición, y el motivo escrito era bueno: se pasa de una a
      // otra por el menú lateral tantas veces al día que cualquier cosa que se
      // interponga entre pulsar y ver molesta. Lo que no es cierto es que un
      // fundido se interponga: la pantalla nueva está maquetada en su sitio
      // desde el primer fotograma y lo único que pasa es que se hace visible.
      // Lo que sí se notaba era el corte seco.
      //
      // El armazón no se mueve: lo único que cambia es lo de dentro.
      routes: [
        GoRoute(
            path: mediaRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: mediaRoute,
              family: ScreenFamily.grid,
              child: const MediaPage(),
            ),
        ),
        GoRoute(
            path: importRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: importRoute,
              family: ScreenFamily.grid,
              child: const ImportPage(),
            ),
        ),
        GoRoute(
            path: deletedRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: deletedRoute,
              family: ScreenFamily.grid,
              child: const DeletePage(),
            ),
        ),
        GoRoute(
            path: favoritesRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: favoritesRoute,
              family: ScreenFamily.grid,
              child: const FavoritesPage(),
            ),
        ),
        GoRoute(
            path: creatorManagerRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: creatorManagerRoute,
              family: ScreenFamily.management,
              child: const CreatorManagerPage(),
            ),
        ),
        GoRoute(
            path: tagManagerRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: tagManagerRoute,
              family: ScreenFamily.management,
              child: const TagManagerPage(),
            ),
        ),
        // Reconocimiento. La de fernies es la de esta fase; las otras dos
        // existen para que sus botones del menú lateral lleven a algún sitio
        // hasta que lleguen sus fases.
        GoRoute(
            path: fernieManagerRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: fernieManagerRoute,
              child: FerniesPage(
                // Se llega así al pulsar un fernie en el panel del visor: la
                // pantalla se abre con ése elegido y no con el primero.
                selectedFernieId: int.tryParse(
                  state.uri.queryParameters[fernieQueryParam] ?? '',
                ),
              ),
            ),
        ),
        GoRoute(
            path: repeatedMediaRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: repeatedMediaRoute,
              family: ScreenFamily.repeated,
              child: const RepeatedMediaPage(),
            ),
        ),
        GoRoute(
            path: modelsRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: modelsRoute,
              family: ScreenFamily.grid,
              child: const ModelsPage(),
            ),
            routes: [
              // El árbol también cuelga de la rejilla: es una vista **de** los
              // modelos, no un sitio aparte de la aplicación, y por eso no está
              // en el menú lateral.
              GoRoute(
                path: modelTreeRoute,
                pageBuilder: (context, state) => fernShellPage(
                  key: state.pageKey,
                  location: modelTreeRoute,
                  child: const ModelTreePage(),
                ),
              ),
              // Cuelga de la rejilla y no va suelta: así volver atrás lleva a
              // ella aunque se haya llegado desde otro sitio.
              GoRoute(
                path: modelDetailRoute,
                pageBuilder: (context, state) => fernShellPage(
                  key: state.pageKey,
                  location: modelDetailRoute,
                  child: ModelDetailPage(
                    modelId:
                        int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                  ),
                ),
              ),
            ],
        ),
        // Experimental: el navegador de dentro de la aplicación. Se quita de
        // aquí y del menú lateral, y la aplicación se queda como estaba.
        GoRoute(
            path: browserRoute,
            pageBuilder: (context, state) => fernShellPage(
              key: state.pageKey,
              location: browserRoute,
              // Sin animación: lo que ocupa esta pantalla es el motor de
              // navegación del sistema, no algo que pinte Flutter.
              family: ScreenFamily.instant,
              child: BrowserPage(
                initialUrl: state.uri.queryParameters[browserUrlQueryParam],
              ),
            ),
        ),
      ]
    ),

    // El visor va a pantalla completa sobre el armazón, no dentro de él: se
    // apila en el navegador raíz y deja intacta la pantalla de la que viene.
    GoRoute(
      path: viewerRoute,
      // Con la misma transición que las demás pantallas, sólo algo más larga: el
      // visor se abre sobre la que se estaba viendo y conviene que se entienda de
      // dónde sale. Como el resto, no desplaza nada de sitio, así que no puede
      // provocar desbordes mientras el layout se recoloca.
      pageBuilder: (context, state) => fernTransitionPage(
        key: state.pageKey,
        duration: viewerTransitionDuration,
        child: BlocProvider<MediaBloc>.value(
          value: getIt<MediaBloc>(),
          child: ViewerPage(
            openInfo: state.uri.queryParameters[viewerInfoQueryParam] == 'true',
            // Se llega así desde la rejilla de fernies, que enseña recortes: el
            // visor abre el contenido entero y señala de cuál se trataba.
            highlightRegionId: int.tryParse(
              state.uri.queryParameters[viewerHighlightQueryParam] ?? '',
            ),
          ),
        ),
      ),
    ),
  ]
);
