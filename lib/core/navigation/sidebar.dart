import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/features/media/domain/services/collapsed_tags.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_states.dart';
import 'package:Fern/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:Fern/core/widgets/collapsing_navigation_drawer_widget.dart';


/// Menú lateral de la aplicación: las pantallas de la galería y, debajo, las
/// etiquetas que hay creadas.
///
/// Pulsar una etiqueta no lleva a ninguna pantalla nueva: filtra el contenido de
/// la pantalla de media por ella.
class Sidebar extends StatefulWidget {

  final double iconSize;

  /// Si el menú arranca plegado, y con qué lo pliega el armazón al estrecharse
  /// la ventana. Cruzar el umbral lo pliega o lo despliega; a partir de ahí el
  /// botón del propio menú manda.
  final bool isCollapsed;

  const Sidebar({
    super.key,
    required this.iconSize,
    this.isCollapsed = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _tagsBloc = getIt<TagsBloc>();
  final _settingsBloc = getIt<SettingsBloc>();
  final _notificationsBloc = getIt<NotificationsBloc>();

  /// Las ramas plegadas. Se escucha: plegar desde la pantalla de gestión tiene
  /// que verse aquí en el momento, y al revés.
  final _collapsed = getIt<CollapsedTags>();

  @override
  void initState() {
    super.initState();

    // El menú se rehace al cambiar de pantalla, pero las etiquetas no: se leen
    // la primera vez y el bloc (que es único) se las queda. Quien las cambia
    // avisa por su cuenta.
    if (!_tagsBloc.state.isLoaded) _tagsBloc.add(const LoadTagsEvent());

    _collapsed.addListener(_onCollapsedChanged);
  }

  @override
  void dispose() {
    _collapsed.removeListener(_onCollapsedChanged);
    super.dispose();
  }

  void _onCollapsedChanged() {
    if (mounted) setState(() {});
  }

  /// Pone [tag] a los contenidos que se han soltado encima.
  ///
  /// Y lo dice: al soltar, el contenido puede desaparecer de la rejilla —si la
  /// etiqueta esconde, o si se está mirando otra— y sin aviso el gesto parecería
  /// no haber hecho nada.
  void _tagDropped(TagEntity tag, List<int> mediaIds) {
    getIt<MediaBloc>().add(
      AddTagToMediaEvent(tagId: tag.id, mediaIds: mediaIds),
    );

    showFernToast(
      context,
      AppLocalizations.of(context).tagDropped(mediaIds.length, tag.name),
      icon: Symbols.sell,
    );
  }

  /// Filtra el contenido por la etiqueta pulsada.
  ///
  /// Se busca por la etiqueta y no por su nombre, así que es la misma búsqueda
  /// que hace el buscador al elegir una de sus sugerencias: sólo sale el
  /// contenido de **esta** etiqueta.
  void _filterByTag(TagEntity tag) {
    final router = GoRouter.of(context);
    if (router.state.matchedLocation != mediaRoute) router.go(mediaRoute);

    // La pantalla de media repite al abrirse la búsqueda que encuentre en el
    // estado, y eso pasa en el fotograma siguiente: el filtro se manda después
    // para que esa repetición, que todavía no lo conoce, no lo deshaga.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<MediaBloc>().add(SearchSuggestionSelectedEvent(
        SearchSuggestionEntity(
          id: tag.id,
          type: SearchResultType.tag,
          label: tag.name,
          imagePath: tag.picturePath,
        ),
      ));
    });
  }

  /// Con los avisos apagados no se pinta ningún contador: lo que hubiera
  /// pendiente sigue anotado, pero deja de enseñarse hasta que se vuelvan a
  /// encender.
  List<SidebarItem> _galleryItems(
    AppLocalizations texts,
    NotificationsState notifications, {
    required bool showBadges,
  }) {
    return [
      SidebarItem(
        id: mediaRoute,
        title: texts.navMedia,
        icon: Symbols.photo,
        onTap: () {
          GoRouter.of(context).go(mediaRoute);
        },
      ),
      SidebarItem(
          id: importRoute,
          title: texts.navImport,
          icon: Symbols.download,
          badgeCount: showBadges ? notifications.badgeFor(importRoute) : 0,
          onTap: () {
            GoRouter.of(context).go(importRoute);
          }
      ),
      // Experimental: el navegador de dentro de la aplicación. Quitar este
      // botón lo deja fuera de la aplicación sin tocar nada más.
      SidebarItem(
          id: browserRoute,
          title: texts.navBrowser,
          icon: Symbols.travel_explore,
          onTap: () {
            context.go(browserRoute);
          }
      ),
      SidebarItem(
          id: favoritesRoute,
          title: texts.navFavorites,
          icon: Symbols.favorite,
          onTap: () {
            context.go(favoritesRoute);
          }
      ),
      SidebarItem(
          id: creatorManagerRoute,
          title: texts.navCreatorManager,
          icon: Symbols.person,
          onTap: () {
            context.go(creatorManagerRoute);
          }
      ),
      SidebarItem(
          id: tagManagerRoute,
          title: texts.navTagManager,
          icon: Symbols.sell,
          onTap: () {
            context.go(tagManagerRoute);
          }
      ),
      SidebarItem(
          id: deletedRoute,
          title: texts.navDeleted,
          icon: Symbols.delete,
          onTap: () {
            context.go(deletedRoute);
          }
      ),
    ];
  }

  /// Los tres sitios del reconocimiento: los fernies (que es lo que se marca), el
  /// contenido repetido y los modelos.
  ///
  /// El árbol de modelos no está aquí a propósito: es un botón dentro de la
  /// pantalla de modelos, no un cuarto sitio del menú.
  List<SidebarItem> _recognitionItems(
    AppLocalizations texts,
    NotificationsState notifications, {
    required bool showBadges,
  }) {
    return [
      SidebarItem(
        id: fernieManagerRoute,
        title: texts.navFernies,
        icon: Symbols.face_retouching_natural,
        onTap: () {
          context.go(fernieManagerRoute);
        },
      ),
      SidebarItem(
        id: repeatedMediaRoute,
        title: texts.navRepeatedMedia,
        icon: Symbols.copy_all,
        badgeCount:
            showBadges ? notifications.badgeFor(repeatedMediaRoute) : 0,
        onTap: () {
          context.go(repeatedMediaRoute);
        },
      ),
      SidebarItem(
        id: modelsRoute,
        title: texts.navModels,
        icon: Symbols.hub,
        badgeCount: showBadges ? notifications.badgeFor(modelsRoute) : 0,
        onTap: () {
          context.go(modelsRoute);
        },
      ),
    ];
  }

  /// Las etiquetas en fila, madres antes que hijas, cada una con el nivel que le
  /// toca: el menú es una lista, así que la jerarquía se cuenta con la sangría
  /// de cada botón.
  ///
  /// El aplanado —lo plegado, y la rama entera de lo que encaja al buscar— es
  /// **el mismo que usa la pantalla de gestión** (`TagList.rowsOf`). Las dos
  /// listas enseñan el mismo árbol, y hacerlo por separado acabaría en dos
  /// comportamientos distintos en cuanto se arreglara algo en una.
  ///
  /// Con [showAvatars] cada una lleva su imagen en lugar del icono común, que es
  /// lo único que las distingue con el menú plegado. Las que no tengan imagen se
  /// quedan con el icono.
  List<SidebarItem> _tagItems(
    List<TagEntity> tags, {
    required bool showAvatars,
    required bool showsBranchOnFilter,
  }) {
    // Buscando no se pliega: lo que se ve es el resultado de una búsqueda, no el
    // árbol, y un chevron ahí escondería coincidencias.
    final isFiltering = _query.trim().isNotEmpty;

    return [
      for (final row in TagList.rowsOf(
        tags,
        query: _query,
        collapsed: _collapsed.ids,
        // El mismo ajuste que manda en la pantalla de gestión: si allí lo que
        // encaja viene con su rama, aquí también. Dos respuestas distintas a la
        // misma búsqueda serían dos listas que no se parecen.
        showsBranch: showsBranchOnFilter,
      ))
        SidebarItem(
          id: 'tag:${row.tag.id}',
          title: row.tag.name,
          icon: Symbols.sell,
          hasChildren: row.tag.children.isNotEmpty,
          isCollapsed: _collapsed.isCollapsed(row.tag.id),
          onToggleCollapse:
              isFiltering ? null : () => _collapsed.toggle(row.tag.id),
          // Arrastrando contenido: posarse encima abre la rama para poder
          // seguir bajando hasta una hija, y soltar la vuelve a cerrar.
          onSpringOpen: () => _collapsed.expandWhileDragging(row.tag.id),
          onSpringRelease: _collapsed.releaseDragged,
          // Con el filtro quitado, una etiqueta NSFW se veía en el menú igual
          // que las demás y no había forma de saber cuál escondía contenido.
          isNsfw: row.tag.isUnderNsfw,
          avatarPath: showAvatars ? row.tag.picturePath : null,
          depth: row.depth,
          onTap: () => _filterByTag(row.tag),
          // Arrastrar contenido hasta aquí se lo etiqueta. Es la forma rápida
          // de poner la misma etiqueta a treinta contenidos, que antes obligaba
          // a abrirlos uno a uno.
          onMediaDropped: (mediaIds) => _tagDropped(row.tag, mediaIds),
        ),
    ];
  }

  /// Lo escrito en el buscador de las etiquetas. Vacío es el árbol entero.
  ///
  /// Vive aquí y no en el menú de dentro porque lo que filtra son las filas que
  /// este menú construye, no cómo se pintan.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    // Los ajustes se escuchan, no se leen al montar el menú: encender los
    // avatares tiene que verse en el momento, sin cerrar la pantalla de ajustes.
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: _settingsBloc,
      buildWhen: (previous, current) =>
          previous.settings.showListAvatars !=
              current.settings.showListAvatars ||
          previous.settings.notifications.enabled !=
              current.settings.notifications.enabled ||
          // Cambiarlo en Ajustes tiene que verse aquí sin cerrar nada: el menú
          // está montado todo el rato y no hay «volver a entrar».
          previous.settings.showsTagBranchOnFilter !=
              current.settings.showsTagBranchOnFilter,
      builder: (context, settings) => BlocBuilder<TagsBloc, TagsState>(
        bloc: _tagsBloc,
        // Los contadores de avisos también se escuchan: encontrar repetidos o
        // terminar de reconocer tiene que encender la bolita sin que el usuario
        // cambie de pantalla.
        builder: (context, state) =>
            BlocBuilder<NotificationsBloc, NotificationsState>(
          bloc: _notificationsBloc,
          builder: (context, notifications) => CollapsingNavigationDrawer(
            // Qué botón se ve marcado lo dice la pantalla en la que se está, no
            // el último clic: se llega a las pantallas también desde los avisos
            // y desde dentro de la aplicación.
            currentLocation: GoRouterState.of(context).matchedLocation,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight(400)),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedColor: Theme.of(context).primaryColor,
            textSelectedColor: context.colors.black,
            unselectedColor: Theme.of(context).scaffoldBackgroundColor,
            textUnselectedColor: context.colors.unremarked,
            iconSize: widget.iconSize,
            isCollapsed: widget.isCollapsed,
            sections: [
              SidebarSection(
                title: texts.navGallery,
                items: _galleryItems(
                  texts,
                  notifications,
                  showBadges: settings.settings.notifications.enabled,
                ),
              ),
              SidebarSection(
                title: texts.navRecognition,
                items: _recognitionItems(
                  texts,
                  notifications,
                  showBadges: settings.settings.notifications.enabled,
                ),
              ),
              SidebarSection(
                title: texts.navTags,
                // Donde señala el tutorial al contar que las etiquetas también
                // son sitios donde soltar contenido.
                anchorId: TutorialAnchorId.sidebarTags,
                // El mismo buscador que la lista de la pantalla de gestión: con
                // un árbol grande, el menú es una lista larguísima justo donde
                // más se usa, que es al arrastrar contenido hasta una etiqueta.
                header: FernFilterField(
                  hintText: texts.searchEllipsisHint,
                  onChanged: (value) => setState(() => _query = value),
                ),
                items: _tagItems(
                  state.tags,
                  showAvatars: settings.settings.showListAvatars,
                  showsBranchOnFilter:
                      settings.settings.showsTagBranchOnFilter,
                ),
                // Mientras la primera lectura está en marcha no se dice que no
                // haya etiquetas: todavía no se sabe.
                emptyMessage: state.isLoaded ? texts.noTagsYet : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
