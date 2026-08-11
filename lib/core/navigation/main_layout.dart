import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/sidebar.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_search_bar.dart';
import 'package:flutter/material.dart';

/// Lo que se puede crear desde el "+" de la barra superior.
enum _CreateOption { creator, tag, collection }

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  static const _createOptions = [
    FernMenuOption(
      value: _CreateOption.creator,
      label: "New creator",
      icon: Icons.person_outline,
    ),
    FernMenuOption(
      value: _CreateOption.tag,
      label: "New tag",
      icon: Icons.label_outline,
    ),
    FernMenuOption(
      value: _CreateOption.collection,
      label: "New collection",
      icon: Icons.collections_outlined,
    ),
  ];

  /// Abre el diálogo de la opción elegida. Las colecciones todavía no existen,
  /// así que se avisa y punto.
  void _onCreateSelected(_CreateOption option) {
    showFernDialog(
      context: context,
      builder: (_) => switch (option) {
        _CreateOption.creator => const FernCreateDialog.creator(),
        _CreateOption.tag => const FernCreateDialog.tag(),
        _CreateOption.collection => const FernMessageDialog(
            imageAsset: fernEmptyImage,
            message: "Collections are still a work in progress",
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLargeScreen = constraints.maxWidth > AppSizes.largeScreenMinWidth;

      if (isLargeScreen) {
        return _buildLargeScreenLayout(context, widget.child);
      }

      return _buildSmallScreenLayout(context, widget.child);
    });
  }

  Widget _buildLargeScreenLayout(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xxxl),
              child: Image.asset(
                appLogo,
                width: AppSizes.logoWidth,
              ),
            ),
            const MediaSearchBar(),
          ],
        ),
        actions: [
          FernPopupMenu<_CreateOption>(
            options: _createOptions,
            onSelected: _onCreateSelected,
            builder: (context, toggle) => IconButton(
              onPressed: toggle,
              icon: const Icon(Icons.add),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          const SizedBox(width: AppSpacing.l),
        ],
      ),
      body: Row(
        children: [
          const Sidebar(
            iconSize: AppSizes.iconLarge,
          ),
          Expanded(child: child)
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, Widget child) {
    // TODO: diseñar el layout móvil. Por ahora se muestra un estado vacío.
    return const Scaffold(
      body: Center(
        child: FernSurface(
          radius: AppSizes.radiusSmall,
          padding: AppSpacing.pagePadding,
          child: FernEmptyState(
            imageAsset: fernEmptyImage,
            message: "Mobile layout coming soon",
          ),
        ),
      ),
    );
  }
}
