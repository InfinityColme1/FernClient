import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
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
            SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                elevation: const WidgetStatePropertyAll<double>(0.0), // Elevación eliminada
                backgroundColor: const WidgetStatePropertyAll<Color>(AppColors.secondary),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: AppSpacing.l),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search, color: AppColors.black),
                hintText: "Search",
                hintStyle: WidgetStatePropertyAll<TextStyle?>(
                  Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.lightgray),
                ),
              );
            }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(3, (int index) {
                final String item = 'item $index';
                return ListTile(
                  title: Text(item, style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () {
                    controller.closeView(item);
                  },
                );
              });
            })
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
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
