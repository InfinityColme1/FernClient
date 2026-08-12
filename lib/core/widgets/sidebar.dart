import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'collapsing_navigation_drawer_widget.dart';


/// Menú lateral de la aplicación: las pantallas de la galería y, debajo, las
/// etiquetas que hay creadas.
///
/// Pulsar una etiqueta no lleva a ninguna pantalla nueva: filtra el contenido de
/// la pantalla de media por ella.
class Sidebar extends StatefulWidget {

  final double iconSize;

  const Sidebar({
    super.key,
    required this.iconSize
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _tagsBloc = getIt<TagsBloc>();

  @override
  void initState() {
    super.initState();

    // El menú se rehace al cambiar de pantalla, pero las etiquetas no: se leen
    // la primera vez y el bloc (que es único) se las queda. Quien las cambia
    // avisa por su cuenta.
    if (!_tagsBloc.state.isLoaded) _tagsBloc.add(const LoadTagsEvent());
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

  List<SidebarItem> _galleryItems(AppLocalizations texts) {
    return [
      SidebarItem(
        id: mediaRoute,
        title: texts.navMedia,
        icon: Icons.photo_outlined,
        onTap: () {
          GoRouter.of(context).go(mediaRoute);
        },
      ),
      SidebarItem(
          id: importRoute,
          title: texts.navImport,
          icon: Icons.file_download_outlined,
          onTap: () {
            GoRouter.of(context).go(importRoute);
          }
      ),
      SidebarItem(
          id: favoritesRoute,
          title: texts.navFavorites,
          icon: Icons.favorite_border_outlined,
          onTap: () {
            context.go(favoritesRoute);
          }
      ),
      SidebarItem(
          id: deletedRoute,
          title: texts.navDeleted,
          icon: Icons.delete_outline_outlined,
          onTap: () {
            context.go(deletedRoute);
          }
      ),
    ];
  }

  /// Las etiquetas en fila, madres antes que hijas, cada una con el nivel que le
  /// toca: el menú es una lista, así que la jerarquía se cuenta con [depth] y se
  /// ve en la sangría de cada botón.
  List<SidebarItem> _tagItems(List<TagEntity> tags, {int depth = 0}) {
    return [
      for (final tag in tags) ...[
        SidebarItem(
          id: 'tag:${tag.id}',
          title: tag.name,
          icon: Icons.sell_outlined,
          depth: depth,
          onTap: () => _filterByTag(tag),
        ),
        ..._tagItems(tag.children, depth: depth + 1),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<TagsBloc, TagsState>(
      bloc: _tagsBloc,
      builder: (context, state) => CollapsingNavigationDrawer(
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight(400)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedColor: Theme.of(context).primaryColor,
        textSelectedColor: AppColors.black,
        unselectedColor: Theme.of(context).scaffoldBackgroundColor,
        textUnselectedColor: AppColors.unremarked,
        iconSize: widget.iconSize,
        sections: [
          SidebarSection(
            title: texts.navGallery,
            items: _galleryItems(texts),
          ),
          SidebarSection(
            title: texts.navTags,
            items: _tagItems(state.tags),
            // Mientras la primera lectura está en marcha no se dice que no haya
            // etiquetas: todavía no se sabe.
            emptyMessage: state.isLoaded ? texts.noTagsYet : null,
          ),
        ],
      ),
    );
  }
}
