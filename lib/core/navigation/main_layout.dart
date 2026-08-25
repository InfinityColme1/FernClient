
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/navigation/sidebar.dart';
import 'package:Fern/core/widgets/sidebar_toggle_button.dart';
import 'package:Fern/features/jobs/presentation/widgets/jobs_indicator.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/presentation/widgets/recognition_log_dialog.dart';
import 'package:Fern/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_search_bar.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Fern/core/navigation/sidebar_collapse.dart';
import 'package:go_router/go_router.dart';

/// Lo que se puede crear desde el "+" de la barra superior.
///
/// Las colecciones estaban aquí sin existir: la opción se enseñaba y al
/// pulsarla salía un aviso de que todavía no. Se han retirado de la interfaz y
/// quedan apuntadas para la 3.0; una promesa que no se cumple cuesta más que la
/// función que falta.
enum _CreateOption { creator, tag, fernie, model }

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
        value: _CreateOption.fernie,
        label: texts.menuNewFernie,
        icon: Icons.face_retouching_natural,
        iconAsset: icFernie,
      ),
      FernMenuOption(
        value: _CreateOption.model,
        label: texts.menuNewModel,
        icon: Icons.hub_outlined,
      ),
    ];
  }

  /// Abre el diálogo de la opción elegida.
  void _onCreateSelected(_CreateOption option) {
    showFernDialog(
      context: context,
      builder: (context) => switch (option) {
        _CreateOption.creator => const FernCreateDialog.creator(),
        _CreateOption.tag => const FernCreateDialog.tag(),
        _CreateOption.fernie => const FernCreateDialog.fernie(),
        _CreateOption.model => const FernCreateDialog.model(),
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
  /// El menú arranca **desplegado**, y el ancho sólo lo pliega al cruzar el
  /// umbral: la regla de media pantalla no dice nada de una ventana que acaba
  /// de abrirse. Que ahí quepa desplegado es cosa del tamaño con el que nace la
  /// ventana. Entre umbral y umbral manda el botón del menú.
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

  /// La última pantalla por la que se ha pasado, para no repetir el aviso de
  /// "ya visto" en cada reconstrucción.
  String? _lastSeenRoute;

  /// Los avisos que llevaban a esta pantalla se dan por vistos al llegar a ella.
  ///
  /// Se hace aquí y no en el botón del menú porque a una pantalla se llega de
  /// muchas maneras (el buscador, un enlace, volver atrás), y lo que apaga el
  /// contador es haber ido a mirar, no por dónde se fue.
  ///
  /// [isPending] es que haya algo sin ver **para esta misma pantalla**. Sin eso,
  /// un aviso que llegaba estando ya en su pantalla no se iba nunca: la ruta no
  /// había cambiado, así que no se volvía a marcar, y sólo se limpiaba saliendo
  /// y volviendo. Estando delante ya se ha ido a mirar.
  void _markCurrentRouteSeen(BuildContext context, {required bool isPending}) {
    final route = GoRouterState.of(context).matchedLocation;
    if (route == _lastSeenRoute && !isPending) return;

    // Cambiar de pantalla es dar por visto lo señalado. Es una de las tres
    // formas: las otras son pasar el ratón por encima y abrir un contenido.
    //
    // Se apaga al **salir** y no al llegar: apagarlo al llegar lo borraría antes
    // de que la rejilla llegara a pintarlo.
    final highlight = getIt<RecognitionHighlight>();
    if (_lastSeenRoute != null && highlight.route != route) highlight.clear();

    _lastSeenRoute = route;

    // En el fotograma siguiente: durante la construcción no se puede tocar el
    // estado de nadie.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationsBloc>().add(RouteSeenEvent(route));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se mira el estado de los avisos, no sólo se lee: hace falta volver por
    // aquí cuando llega uno para poder darlo por visto si es de esta pantalla.
    final notifications = context.watch<NotificationsBloc>().state;

    _markCurrentRouteSeen(
      context,
      isPending: notifications.badgeFor(
        GoRouterState.of(context).matchedLocation,
      ) >
          0,
    );

    // Una sola forma de la aplicación, se estreche lo que se estreche. Lo
    // único que cambia con el ancho es que el menú lateral se pliega solo, y
    // por debajo de [AppSizes.largeScreenMinWidth] la ventana no puede llegar:
    // el propio ejecutable lo impide (`windows/runner/win32_window.cpp`).
    return LayoutBuilder(builder: (context, constraints) {
      final collapse = sidebarCollapse(
        width: constraints.maxWidth,
        halfScreenWidth: _halfScreenWidth(context),
        wasCollapsed: _isSidebarCollapsed,
        lastVerdict: _lastWidthVerdict,
      );

      _isSidebarCollapsed = collapse.isCollapsed;
      _lastWidthVerdict = collapse.verdict;

      return _buildLargeScreenLayout(
        context,
        widget.child,
        isSidebarCollapsed: _isSidebarCollapsed,
      );
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
          // Sólo asoma cuando hay algo corriendo por detrás, así que el resto
          // del tiempo la barra queda como estaba.
          //
          // El detalle de un reconocimiento se enchufa desde aquí y no desde
          // dentro: la lista de tareas es de la aplicación entera, y bastaría un
          // caso especial por tipo de trabajo para que acabara importando media
          // aplicación.
          JobsIndicator(
            hasDetail: (job) => getIt<RecognitionLogStore>().has(job.id),
            onDetail: (context, job) => showFernDialog<void, JobsBloc>(
              context: context,
              builder: (_) => RecognitionLogDialog(
                logs: getIt<RecognitionLogStore>().of(job.id),
              ),
            ),
          ),
          FernPopupMenu<_CreateOption>(
            options: _createOptions(AppLocalizations.of(context)),
            onSelected: _onCreateSelected,
            builder: (context, toggle) => IconButton(
              // Los demás botones de esta barra lo llevan, y éste es el que más
              // se usa: sin él, un icono «+» a secas no dice de qué.
              tooltip: AppLocalizations.of(context).createTooltip,
              onPressed: toggle,
              icon: const Icon(Icons.add),
            ),
          ),
          IconButton(
            // Los demás de esta barra lo llevan y éste se había quedado sin él.
            tooltip: AppLocalizations.of(context).settingsTitle,
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

}
