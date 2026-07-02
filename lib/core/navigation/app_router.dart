import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/navigation/main_layout.dart';
import 'package:Fern/features/media/presentation/pages/media_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


final appRouter = GoRouter(
  initialLocation: mediaRoute,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
            path: mediaRoute,
            builder: (context, state) => MediaPage()
        ),
        GoRoute(
            path: importRoute,
            builder: (context, state) => Text("import")
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
    )
  ]
);