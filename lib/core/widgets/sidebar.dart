import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'collapsing_navigation_drawer_widget.dart';


class Sidebar extends StatelessWidget {

  final double iconSize;

  const Sidebar({
    super.key,
    required this.iconSize
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return CollapsingNavigationDrawer(
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight(400)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedColor: Theme.of(context).primaryColor,
      textSelectedColor: AppColors.black,
      unselectedColor: Theme.of(context).scaffoldBackgroundColor,
      textUnselectedColor: AppColors.unremarked,
      iconSize: iconSize,
      items: [
        SidebarItem(
          title: texts.navMedia,
          icon: Icons.photo_outlined,
          onTap: () {
            GoRouter.of(context).go(mediaRoute);
          },
        ),
        SidebarItem(
            title: texts.navImport,
            icon: Icons.file_download_outlined,
            onTap: () {
              GoRouter.of(context).go(importRoute);
            }
        ),
        SidebarItem(
            title: texts.navFavorites,
            icon: Icons.favorite_border_outlined,
            onTap: () {
              context.go(favoritesRoute);
            }
        ),
        SidebarItem(
            title: texts.navDeleted,
            icon: Icons.delete_outline_outlined,
            onTap: () {
              context.go(deletedRoute);
            }
        ),
      ]
    );
  }
}