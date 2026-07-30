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
      builder: (context, state, child) {
        return BlocProvider<MediaBloc>(
          create: (context) => getIt(),
          child: state.fullPath == viewerRoute
              ? child
              : MainLayout(child: child)
        );
      },
      routes: [
        GoRoute(
            path: mediaRoute,
            builder: (context, state) => MediaPage()
        ),
        GoRoute(
            path: importRoute,
            builder: (context, state) => ImportPage()
        ),
        GoRoute(
            path: favoritesRoute,
            builder: (context, state) => Text("favorites")
        ),
        GoRoute(
            path: deletedRoute,
            builder: (context, state) => Text("deleted")
        ),

        GoRoute(
            path: viewerRoute,
            builder: (context, state) => ViewerPage()
        )
      ]
    ),

  ]
);