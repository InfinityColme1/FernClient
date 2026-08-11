import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/main_layout.dart';
import 'package:Fern/features/media/presentation/pages/import_page.dart';
import 'package:Fern/features/media/presentation/pages/media_page.dart';
import 'package:Fern/features/media/presentation/pages/viewer_page.dart';
import 'package:flutter/material.dart';
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
      routes: [
        GoRoute(
            path: mediaRoute,
            builder: (context, state) => const MediaPage()
        ),
        GoRoute(
            path: importRoute,
            builder: (context, state) => const ImportPage()
        ),
        GoRoute(
            path: favoritesRoute,
            builder: (context, state) => Text("favorites")
        ),
        GoRoute(
            path: deletedRoute,
            builder: (context, state) => Text("deleted")
        ),
      ]
    ),

    // El visor va a pantalla completa sobre el armazón, no dentro de él: se
    // apila en el navegador raíz y deja intacta la pantalla de la que viene.
    GoRoute(
      path: viewerRoute,
      // Entra con un fundido: no desplaza nada de sitio, así que no puede
      // provocar desbordes mientras el layout se recoloca.
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        transitionDuration: viewerTransitionDuration,
        reverseTransitionDuration: viewerTransitionDuration,
        child: BlocProvider<MediaBloc>.value(
          value: getIt<MediaBloc>(),
          child: ViewerPage(
            openInfo: state.uri.queryParameters[viewerInfoQueryParam] == 'true',
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    ),
  ]
);
