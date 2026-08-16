import 'dart:math' as math;

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/sidebar.dart';
import 'package:Fern/core/widgets/sidebar_toggle_button.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_search_bar.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
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
  /// Las opciones se arman en cada construcción porque sus etiquetas salen del
  /// idioma en curso, que puede cambiar sin salir de la pantalla.
  List<FernMenuOption<_CreateOption>> _createOptions(AppLocalizations texts) {
    return [
      FernMenuOption(
        value: _CreateOption.creator,
        label: texts.menuNewCreator,
        icon: Icons.person_outline,
      ),
      FernMenuOption(
        value: _CreateOption.tag,
        label: texts.menuNewTag,
        icon: Icons.label_outline,
      ),
      FernMenuOption(
        value: _CreateOption.collection,
        label: texts.menuNewCollection,
        icon: Icons.collections_outlined,
      ),
    ];
  }

  /// Abre el diálogo de la opción elegida. Las colecciones todavía no existen,
  /// así que se avisa y punto.
  void _onCreateSelected(_CreateOption option) {
    showFernDialog(
      context: context,
      builder: (context) => switch (option) {
        _CreateOption.creator => const FernCreateDialog.creator(),
        _CreateOption.tag => const FernCreateDialog.tag(),
        _CreateOption.collection => FernMessageDialog(
            imageAsset: fernEmptyImage,
            message: AppLocalizations.of(context).collectionsWip,
          ),
      },
    );
  }

  /// Ajustes de la aplicación, en el engranaje que hay junto al "+".
  void _openSettings() {
    showFernDialog(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
  }

  /// El menú lateral, tal cual se le pasó la última vez.
  ///
  /// Reescalar la ventana rehace esta rama en cada fotograma, y con el mismo
  /// widget de vuelta Flutter se salta su subárbol entero (la lista de
  /// etiquetas incluida). Antes lo daba el `const`, que ya no cabe ahora que el
  /// menú recibe si va plegado.
  Widget? _sidebar;
  bool? _sidebarCollapsed;

  Widget _buildSidebar({required bool isCollapsed}) {
    if (_sidebar == null || isCollapsed != _sidebarCollapsed) {
      _sidebarCollapsed = isCollapsed;
      _sidebar = Sidebar(
        iconSize: AppSizes.iconLarge,
        isCollapsed: isCollapsed,
      );
    }

    return _sidebar!;
  }

  /// Si el menú va plegado, y el veredicto del ancho con el que se decidió.
  ///
  /// El menú arranca siempre desplegado: el ancho sólo lo pliega al cruzar el
  /// umbral, así que abrir la aplicación en una ventana estrecha lo deja abierto
  /// y es el botón del menú quien manda hasta que la ventana cambie de lado.
  bool _isSidebarCollapsed = false;
  bool? _lastWidthVerdict;

  /// La mitad del ancho de la pantalla del dispositivo, en píxeles lógicos.
  ///
  /// Es la pantalla, no la ventana: el menú se pliega cuando la ventana ocupa
  /// media pantalla, así que hace falta saber cuánto es eso.
  double _halfScreenWidth(BuildContext context) {
    final display = View.of(context).display;
    return display.size.width / display.devicePixelRatio / 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLargeScreen = constraints.maxWidth > AppSizes.largeScreenMinWidth;

      if (isLargeScreen) {
        // El menú se pliega a media pantalla, pero si esa mitad todavía es muy
        // ancha se espera al ancho al que las cabeceras dejan de caber: lo que
        // no puede pasar es que desborden con el menú desplegado.
        final collapseWidth = math.max(
          _halfScreenWidth(context),
          AppSizes.sidebarAutoCollapseMinWidth,
        );

        final verdict = constraints.maxWidth <= collapseWidth;
        if (_lastWidthVerdict != null && verdict != _lastWidthVerdict) {
          _isSidebarCollapsed = verdict;
        }
        _lastWidthVerdict = verdict;

        return _buildLargeScreenLayout(
          context,
          widget.child,
          isSidebarCollapsed: _isSidebarCollapsed,
        );
      }

      return _buildSmallScreenLayout(context, widget.child);
    });
  }

  Widget _buildLargeScreenLayout(
    BuildContext context,
    Widget child, {
    required bool isSidebarCollapsed,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Lo que abre y cierra el menú, en la esquina de la que sale el
            // menú y junto al logo: desde ahí se ve y se alcanza igual con el
            // menú desplegado que plegado.
            SidebarToggleButton(
              isCollapsed: isSidebarCollapsed,
              onPressed: () => setState(
                () => _isSidebarCollapsed = !_isSidebarCollapsed,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
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
            options: _createOptions(AppLocalizations.of(context)),
            onSelected: _onCreateSelected,
            builder: (context, toggle) => IconButton(
              onPressed: toggle,
              icon: const Icon(Icons.add),
            ),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: AppSpacing.l),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(isCollapsed: isSidebarCollapsed),
          Expanded(child: child)
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, Widget child) {
    // TODO: diseñar el layout móvil. Por ahora se muestra un estado vacío.
    return Scaffold(
      body: Center(
        child: FernSurface(
          radius: AppSizes.radiusSmall,
          padding: AppSpacing.pagePadding,
          child: FernEmptyState(
            imageAsset: fernEmptyImage,
            message: AppLocalizations.of(context).mobileLayoutWip,
          ),
        ),
      ),
    );
  }
}
