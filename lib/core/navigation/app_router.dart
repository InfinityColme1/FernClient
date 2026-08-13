import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/main_layout.dart';
import 'package:Fern/core/navigation/page_transitions.dart';
import 'package:Fern/features/media/presentation/pages/delete_page.dart';
import 'package:Fern/features/media/presentation/pages/favorites_page.dart';
import 'package:Fern/features/media/presentation/pages/import_page.dart';
import 'package:Fern/features/media/presentation/pages/media_page.dart';
import 'package:Fern/features/media/presentation/pages/tag_manager_page.dart';
import 'package:Fern/features/media/presentation/pages/viewer_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/media/presentation/blocs/media_bloc.dart';
import '../service_locator.dart';


final appRouter = GoRouter(
  initialLocation: mediaRoute,
  routes: [
    ShellRoute(
      // El armazón (barra superior + menú lateral) envuelve siempre a sus
      // pantallas. Si se le quitara al navegar al visor, las pantallas que
      // siguen montadas debajo perderían el `Scaffold` y con él el `Material`
      // que necesitan sus widgets, que es justo lo que asomaba durante la
      // transición.
      builder: (context, state, child) {
        return BlocProvider<MediaBloc>.value(
          value: getIt<MediaBloc>(),
          child: MainLayout(child: child),
        );
      },
      // Todas las pantallas del armazón entran y salen con la misma transición
      // (`fernTransitionPage`), así que pasar de una a otra es un fundido y no un
      // cambio seco. El armazón no se mueve: lo que se desvanece es sólo lo que
      // hay dentro.
      routes: [
        GoRoute(
            path: mediaRoute,
            pageBuilder: (context, state) => fernTransitionPage(
              key: state.pageKey,
              child: const MediaPage(),
            ),
        ),
        GoRoute(
            path: importRoute,
            pageBuilder: (context, state) => fernTransitionPage(
              key: state.pageKey,
              child: const ImportPage(),
            ),
        ),
        GoRoute(
            path: deletedRoute,
            pageBuilder: (context, state) => fernTransitionPage(
              key: state.pageKey,
              child: const DeletePage(),
            ),
        ),
        GoRoute(
            path: favoritesRoute,
            pageBuilder: (context, state) => fernTransitionPage(
              key: state.pageKey,
              child: const FavoritesPage(),
            ),
        ),
        GoRoute(
            path: tagManagerRoute,
            pageBuilder: (context, state) => fernTransitionPage(
              key: state.pageKey,
              child: const TagManagerPage(),
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
          ),
        ),
      ),
    ),
  ]
);
