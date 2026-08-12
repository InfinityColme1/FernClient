// Comprueba que los anchos a los que se pliega el menú lateral y se cambia de
// layout dejan sitio a las cabeceras de las pantallas.
//
// Las cabeceras se rehacen aquí en vez de montar las pantallas de verdad: ésas
// necesitan la base de datos y los blocs, y lo que se mide es sólo lo que ocupa
// la fila. Si se le añade o se le quita algo a la cabecera de una pantalla, hay
// que reflejarlo aquí; el número que sale de esta prueba es el que llevan
// [AppSizes.largeScreenMinWidth] y [AppSizes.sidebarAutoCollapseMinWidth].
//
// La tipografía de la aplicación se carga a mano: sin ella se mide con la
// fuente de pruebas, en la que cada letra es un cuadrado, y los textos salen
// casi al doble de anchos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/collapsing_navigation_drawer_widget.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Anchos del menú lateral, que son los de [CollapsingNavigationDrawer].
const _sidebarExpandedWidth = 210.0;
const _sidebarCollapsedWidth = 70.0;

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

typedef HeaderBuilder = Widget Function(BuildContext context, AppLocalizations texts);

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

/// El armazón de pantalla grande con una cabecera dentro: la barra superior de
/// `MainLayout`, el hueco del menú lateral y la fila que va sobre la rejilla.
///
/// El buscador y el logo se sustituyen por su hueco: lo que se mide es el
/// espacio que ocupan, y el de verdad necesita blocs.
Widget _harness({
  required Locale locale,
  required HeaderBuilder header,
  required double sidebarWidth,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.xxxl),
              child: SizedBox(width: AppSizes.logoWidth, height: AppSizes.searchBarHeight),
            ),
            SizedBox(
              width: AppSizes.searchBarWidth,
              height: AppSizes.searchBarHeight,
            ),
          ],
        ),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.add)),
          IconButton(onPressed: null, icon: Icon(Icons.settings)),
          SizedBox(width: AppSpacing.l),
        ],
      ),
      body: Row(
        children: [
          SizedBox(width: sidebarWidth),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.xl,
                      bottom: AppSpacing.l,
                    ),
                    child: Builder(
                        builder: (context) =>
                            header(context, AppLocalizations.of(context))),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// --- Réplicas de las cabeceras, en su estado más cargado ---

Widget _countAndFiltersHeader(BuildContext context, String count) {
  final theme = Theme.of(context);
  return Row(
    children: [
      Text(count,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const Spacer(),
      FernPillButton(
        label: AppLocalizations.of(context).filters,
        icon: Icons.tune,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () {},
      ),
    ],
  );
}

/// Los recuentos se prueban con cinco cifras: es el ancho que llegan a ocupar.
const _sampleCount = 99999;

Widget _mediaHeader(BuildContext context, AppLocalizations texts) =>
    _countAndFiltersHeader(context, texts.mediaCount(_sampleCount));

Widget _favoritesHeader(BuildContext context, AppLocalizations texts) =>
    _countAndFiltersHeader(context, texts.favoritesCount(_sampleCount));

Widget _deletedHeader(BuildContext context, AppLocalizations texts) {
  final theme = Theme.of(context);
  return Row(
    children: [
      Text(texts.deletedCount(_sampleCount),
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(width: AppSpacing.m),
      Flexible(
        child: Text(
          texts.deletedRetentionNotice(deletedRetention.inDays),
          overflow: TextOverflow.ellipsis,
          style:
              theme.textTheme.bodySmall?.copyWith(color: AppColors.unremarked),
        ),
      ),
      const Spacer(),
      Text(texts.selectedCount(_sampleCount),
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.terciary)),
      const SizedBox(width: AppSpacing.l),
      IconButton(
        color: AppColors.black,
        onPressed: () {},
        icon: const Icon(Icons.delete_forever_outlined),
      ),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionRestore,
        icon: Icons.restore_from_trash_outlined,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () {},
      ),
    ],
  );
}

Widget _importHeader(BuildContext context, AppLocalizations texts) {
  final theme = Theme.of(context);
  return Row(
    children: [
      FernDropdownPill<String>(
        value: importSources.first,
        items: importSources,
        labelBuilder: (source) =>
            source == localComputerSource ? texts.sourceLocalComputer : source,
        onChanged: (_) {},
      ),
      const Spacer(),
      Text(texts.selectedCount(_sampleCount),
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.terciary)),
      const SizedBox(width: AppSpacing.l),
      Text(texts.mediaFetched(_sampleCount),
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const Spacer(),
      IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh, color: AppColors.black)),
      IconButton(
          onPressed: () {},
          icon: const Icon(Icons.folder_open_outlined, color: AppColors.black)),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionDelete,
        icon: Icons.delete_outline,
        backgroundColor: AppColors.terciary,
        foregroundColor: AppColors.white,
        onPressed: () {},
      ),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionConfirm,
        icon: Icons.check,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () {},
      ),
    ],
  );
}

const _headers = <String, HeaderBuilder>{
  'media': _mediaHeader,
  'favoritos': _favoritesHeader,
  'papelera': _deletedHeader,
  'importación': _importHeader,
};

/// Monta el armazón a un ancho dado y devuelve el aviso de desbordamiento, si
/// lo hay.
Future<Object?> _overflowAt(
  WidgetTester tester, {
  required double width,
  required Locale locale,
  required HeaderBuilder header,
  required double sidebarWidth,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // El árbol se tira abajo antes de cada medida: si se reaprovechan los render
  // objects, el aviso sólo se da la primera vez y las medidas siguientes
  // saldrían limpias sin serlo.
  await tester.pumpWidget(const SizedBox.shrink());
  tester.takeException();

  await tester.pumpWidget(_harness(
    locale: locale,
    header: header,
    sidebarWidth: sidebarWidth,
  ));
  await tester.pump(const Duration(milliseconds: 400));

  return tester.takeException();
}

Future<void> _expectNoOverflow(
  WidgetTester tester, {
  required double width,
  required double sidebarWidth,
  required String description,
}) async {
  for (final entry in _headers.entries) {
    for (final locale in _locales) {
      final overflow = await _overflowAt(
        tester,
        width: width,
        locale: locale,
        header: entry.value,
        sidebarWidth: sidebarWidth,
      );

      expect(
        overflow,
        isNull,
        reason: '$description: la cabecera de ${entry.key} desborda a '
            '${width}px en ${locale.languageCode}',
      );
    }
  }
}

SidebarItem _item(String title) => SidebarItem(
      id: title,
      title: title,
      icon: Icons.sell_outlined,
      onTap: () {},
    );

Future<void> _pumpDrawer(WidgetTester tester, {required bool isCollapsed}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Row(
        children: [
          CollapsingNavigationDrawer(
            isCollapsed: isCollapsed,
            sections: [
              SidebarSection(title: 'Gallery', items: [_item('Media')]),
            ],
            textStyle: const TextStyle(fontSize: 14),
            iconSize: 24,
            backgroundColor: Colors.white,
            selectedColor: Colors.purple,
            textSelectedColor: Colors.black,
            unselectedColor: Colors.white,
            textUnselectedColor: Colors.grey,
          ),
        ],
      ),
    ),
  ));
}

double _drawerWidth(WidgetTester tester) =>
    tester.getSize(find.byType(CollapsingNavigationDrawer)).width;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadAppFont();
  });

  group('las cabeceras caben en los anchos de corte', () {
    testWidgets('con el menú desplegado, hasta que se pliega solo',
        (tester) async {
      await _expectNoOverflow(
        tester,
        width: AppSizes.sidebarAutoCollapseMinWidth,
        sidebarWidth: _sidebarExpandedWidth,
        description: 'menú desplegado',
      );
    });

    testWidgets('con el menú plegado, hasta que se cambia de layout',
        (tester) async {
      await _expectNoOverflow(
        tester,
        width: AppSizes.largeScreenMinWidth,
        sidebarWidth: _sidebarCollapsedWidth,
        description: 'menú plegado',
      );
    });

    test('el menú se pliega antes de que se cambie de layout', () {
      expect(AppSizes.sidebarAutoCollapseMinWidth,
          greaterThan(AppSizes.largeScreenMinWidth));
    });
  });

  group('el menú lateral obedece a quien lo monta', () {
    testWidgets('arranca plegado si se le pide, y sin animación',
        (tester) async {
      await _pumpDrawer(tester, isCollapsed: true);

      expect(_drawerWidth(tester), _sidebarCollapsedWidth);
    });

    testWidgets('se pliega y se despliega al cruzar el umbral',
        (tester) async {
      await _pumpDrawer(tester, isCollapsed: false);
      expect(_drawerWidth(tester), _sidebarExpandedWidth);

      await _pumpDrawer(tester, isCollapsed: true);
      await tester.pumpAndSettle();
      expect(_drawerWidth(tester), _sidebarCollapsedWidth);

      await _pumpDrawer(tester, isCollapsed: false);
      await tester.pumpAndSettle();
      expect(_drawerWidth(tester), _sidebarExpandedWidth);
    });

    testWidgets('su botón sigue mandando sin que lo deshaga la reconstrucción',
        (tester) async {
      await _pumpDrawer(tester, isCollapsed: false);

      await tester.tap(find.byType(AnimatedIcon));
      await tester.pumpAndSettle();
      expect(_drawerWidth(tester), _sidebarCollapsedWidth);

      // Una reconstrucción con la misma petición no toca lo que se ha hecho a
      // mano: sólo lo hace un cambio de la petición.
      await _pumpDrawer(tester, isCollapsed: false);
      await tester.pumpAndSettle();
      expect(_drawerWidth(tester), _sidebarCollapsedWidth);
    });
  });
}
