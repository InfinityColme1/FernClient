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
import 'package:Fern/core/widgets/sidebar_toggle_button.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/presentation/pages/import_page.dart';
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
        backgroundColor: AppColors.light.primary,
        foregroundColor: AppColors.light.black,
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
              theme.textTheme.bodySmall?.copyWith(color: AppColors.light.unremarked),
        ),
      ),
      const Spacer(),
      Text(texts.selectedCount(_sampleCount),
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.light.terciary)),
      const SizedBox(width: AppSpacing.l),
      IconButton(
        color: AppColors.light.black,
        onPressed: () {},
        icon: const Icon(Icons.delete_forever_outlined),
      ),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionRestore,
        icon: Icons.restore_from_trash_outlined,
        backgroundColor: AppColors.light.primary,
        foregroundColor: AppColors.light.black,
        onPressed: () {},
      ),
    ],
  );
}

/// El más largo de los avisos que la cabecera de importación pinta junto a la
/// fuente. Se miden todos porque cuál es el largo cambia con el idioma.
String _longestSourceNote(AppLocalizations texts) {
  return [
    texts.sourceNotConfigured,
    texts.lastImportNever,
    texts.lastImportMinutes(59),
    texts.lastImportHours(23),
    texts.lastImportDays(30),
  ].reduce((a, b) => a.length >= b.length ? a : b);
}

Widget _importHeader(BuildContext context, AppLocalizations texts) {
  final theme = Theme.of(context);
  return Row(
    children: [
      FernDropdownPill<ImportSource>(
        value: ImportSource.local,
        items: const [ImportSource.all, ...ImportSource.scannable],
        labelBuilder: (source) => source.name(texts),
        onChanged: (_) {},
      ),
      const SizedBox(width: AppSpacing.m),
      // El aviso de la fuente: lo que se pinta al lado del desplegable cuando
      // hay algo que decir de ella (aquí, el caso más largo).
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history,
              size: AppSizes.iconCompact, color: AppColors.light.gray),
          const SizedBox(width: AppSpacing.xs),
          // El aviso más largo de los que puede pintar la cabecera: es el que
          // decide cuánto ocupa la fila.
          Text(_longestSourceNote(texts),
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: AppColors.light.gray)),
        ],
      ),
      const Spacer(),
      Text(texts.selectedCount(_sampleCount),
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.light.terciary)),
      const SizedBox(width: AppSpacing.l),
      Text(texts.mediaFetched(_sampleCount),
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const Spacer(),
      FernDropdownPill<int>(
        value: unlimitedImportLimit,
        items: importLimitOptions,
        labelBuilder: (limit) => importLimitLabel(limit, texts),
        onChanged: (_) {},
      ),
      const SizedBox(width: AppSpacing.s),
      IconButton(
          onPressed: () {},
          icon: Icon(Icons.refresh, color: AppColors.light.black)),
      IconButton(
          onPressed: () {},
          icon: Icon(Icons.folder_open_outlined, color: AppColors.light.black)),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionDelete,
        icon: Icons.delete_outline,
        backgroundColor: AppColors.light.terciary,
        foregroundColor: AppColors.light.white,
        onPressed: () {},
      ),
      const SizedBox(width: AppSpacing.s),
      FernPillButton(
        label: texts.actionConfirm,
        icon: Icons.check,
        backgroundColor: AppColors.light.primary,
        foregroundColor: AppColors.light.black,
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

Future<void> _pumpToggle(
  WidgetTester tester, {
  required bool isCollapsed,
  required VoidCallback onPressed,
}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SidebarToggleButton(
        isCollapsed: isCollapsed,
        onPressed: onPressed,
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

    testWidgets('con el menú plegado, hasta el ancho mínimo de la ventana',
        (tester) async {
      await _expectNoOverflow(
        tester,
        width: AppSizes.largeScreenMinWidth,
        sidebarWidth: _sidebarCollapsedWidth,
        description: 'menú plegado',
      );
    });

    test('el menú se pliega antes de llegar al ancho mínimo', () {
      expect(AppSizes.sidebarAutoCollapseMinWidth,
          greaterThan(AppSizes.largeScreenMinWidth));
    });
  });

  // Ya no hay un layout de móvil al que caer: la aplicación se dibuja siempre
  // igual y lo único que cambia con el ancho es que el menú se pliega. Lo que
  // sostiene eso son dos números del ejecutable: el ancho por debajo del cual la
  // ventana no se deja estrechar, y el ancho con el que nace. Ninguno de los dos
  // se puede comprobar desde Dart montando nada, así que se leen del código.
  group('los anchos que impone el ejecutable', () {
    /// Un `constexpr int` del runner de Windows.
    int _declared(String file, String name) {
      final source = File('windows/runner/$file').readAsStringSync();
      final match =
          RegExp('$name = ([0-9]+);').firstMatch(source);

      expect(
        match,
        isNotNull,
        reason: '$name ha desaparecido de $file',
      );

      return int.parse(match!.group(1)!);
    }

    test('no se puede estrechar más de lo que miden las cabeceras', () {
      expect(
        _declared('win32_window.h', 'kMinimumWindowWidth'),
        AppSizes.largeScreenMinWidth,
        reason: 'el tope del ejecutable y el ancho que miden las cabeceras se '
            'han separado',
      );
    });

    test('y nace lo bastante ancha para el menú desplegado', () {
      // El menú arranca desplegado, así que la ventana tiene que nacer con
      // sitio para él: por debajo de esto, la cabecera de importación desborda
      // desde el primer fotograma.
      expect(
        _declared('main.cpp', 'kInitialWindowWidth'),
        greaterThanOrEqualTo(AppSizes.sidebarAutoCollapseMinWidth),
        reason: 'la ventana nace más estrecha de lo que necesita el menú '
            'desplegado',
      );
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

    testWidgets('una reconstrucción con lo mismo no lo mueve', (tester) async {
      await _pumpDrawer(tester, isCollapsed: true);
      await tester.pumpAndSettle();

      await _pumpDrawer(tester, isCollapsed: true);
      await tester.pumpAndSettle();

      expect(_drawerWidth(tester), _sidebarCollapsedWidth);
    });

    testWidgets('el botón de plegarlo ya no está dentro del menú',
        (tester) async {
      // Está en la cabecera, junto al logo: dentro del menú no se alcanzaba sin
      // bajar hasta el final de la lista de etiquetas.
      await _pumpDrawer(tester, isCollapsed: false);

      expect(find.byType(AnimatedIcon), findsNothing);
    });
  });

  group('el botón que pliega el menú', () {
    testWidgets('avisa de que se le ha pulsado', (tester) async {
      var pulsado = 0;

      await _pumpToggle(
        tester,
        isCollapsed: false,
        onPressed: () => pulsado++,
      );

      await tester.tap(find.byType(SidebarToggleButton));
      await tester.pumpAndSettle();

      // No decide él: sólo avisa, y quien monta la pantalla es quien pliega.
      expect(pulsado, 1);
    });

    testWidgets('dice lo que va a hacer según cómo esté el menú',
        (tester) async {
      await _pumpToggle(tester, isCollapsed: false, onPressed: () {});
      var button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.tooltip, isNotNull);
      final abierto = button.tooltip;

      await _pumpToggle(tester, isCollapsed: true, onPressed: () {});
      button = tester.widget<IconButton>(find.byType(IconButton));

      expect(button.tooltip, isNot(abierto));
    });
  });
}
