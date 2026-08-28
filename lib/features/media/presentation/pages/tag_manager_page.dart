import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/media/presentation/widgets/tag_card.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Gestión de etiquetas: a la derecha todas las etiquetas de la aplicación y, a
/// la izquierda, la etiqueta elegida.
///
/// De la etiqueta elegida se ven dos cosas: su ficha (`TagCard`), donde se
/// editan su nombre, su avatar y de quién cuelga, y su contenido en una rejilla,
/// donde se puede seleccionar para quitarle la etiqueta desde la ficha.
///
/// Las etiquetas salen del `TagsBloc`, que es el mismo que lista el menú lateral:
/// lo que se guarde aquí se ve allí sin tener que reiniciar.
class TagManagerPage extends StatefulWidget {
  const TagManagerPage({super.key});

  @override
  State<TagManagerPage> createState() => _TagManagerPageState();
}

class _TagManagerPageState extends State<TagManagerPage> {
  final _tagsBloc = getIt<TagsBloc>();

  /// La etiqueta elegida, por identificador y no por entidad: al guardarla
  /// cambian su nombre y su avatar, pero sigue siendo la misma etiqueta.
  int? _selectedTagId;

  @override
  void initState() {
    super.initState();

    if (!_tagsBloc.state.isLoaded) _tagsBloc.add(const LoadTagsEvent());

    // Si las etiquetas ya estaban leídas no va a llegar ningún estado nuevo que
    // dispare la selección por defecto, así que se resuelve en cuanto se puede
    // llamar a `setState`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSelection(_tagsBloc.state);
    });
  }

  /// Deja elegida una etiqueta que exista.
  ///
  /// Se llama al entrar y cada vez que cambian las etiquetas: por defecto queda
  /// elegida la primera, y si la que estaba elegida ha desaparecido se hace lo
  /// mismo en lugar de quedarse enseñando algo que ya no está.
  void _syncSelection(TagsState state) {
    final tags = TagList.flatten(state.tags);
    if (tags.isEmpty) return;

    final isStillThere = tags.any((row) => row.tag.id == _selectedTagId);
    if (isStillThere) return;

    _select(tags.first.tag);
  }

  /// Elige una etiqueta y pide su contenido para la rejilla.
  void _select(TagEntity tag) {
    if (_selectedTagId == tag.id) return;

    setState(() => _selectedTagId = tag.id);
    getIt<MediaBloc>().add(LoadMediaByTagEvent(tag.id));
  }

  /// Etiqueta de la que cuelga [id], si cuelga de alguna. La jerarquía sólo se
  /// conoce de arriba abajo (cada etiqueta tiene sus hijas), así que el padre se
  /// busca recorriendo el árbol.
  TagEntity? _parentOf(List<TagEntity> tags, int id) {
    for (final tag in tags) {
      if (tag.children.any((child) => child.id == id)) return tag;

      final found = _parentOf(tag.children, id);
      if (found != null) return found;
    }
    return null;
  }

  TagEntity? _selectedTag(List<TagRow> rows) {
    for (final row in rows) {
      if (row.tag.id == _selectedTagId) return row.tag;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: BlocConsumer<TagsBloc, TagsState>(
        bloc: _tagsBloc,
        listener: (context, state) => _syncSelection(state),
        builder: (context, state) {
          final rows = TagList.flatten(state.tags);

          // Sin etiquetas no hay nada que gestionar: se dice y punto. Mientras la
          // primera lectura está en marcha no se dice que no haya ninguna,
          // todavía no se sabe: se espera con el indicador.
          if (rows.isEmpty) {
            return Padding(
              padding: AppSpacing.pagePadding,
              child: state.isLoaded
                  ? FernEmptyState(
                      imageAsset: fernEmptyImage,
                      message: AppLocalizations.of(context).noTagsYet,
                      description:
                          AppLocalizations.of(context).noTagsYetHint,
                    )
                  : const Center(child: FernProgressIndicator()),
            );
          }

          final selected = _selectedTag(rows) ?? rows.first.tag;

          return FernManagementScreen(
            padding: const EdgeInsets.only(
              top: AppSpacing.l,
              left: AppSpacing.l,
              right: AppSpacing.l,
              bottom: AppSpacing.l,
            ),
            listWidth: AppSizes.tagListWidth,
            cardBuilder: (context, _) => TagCard(
              // La ficha se rehace al cambiar de etiqueta: sus campos arrancan
              // con los valores de la etiqueta, así que tienen que volver a
              // nacer con los de la nueva.
              key: ValueKey(selected.id),
              tag: selected,
              parent: _parentOf(state.tags, selected.id),
            ),
            grid: _tagMedia(),
            // Al guardar o borrar una etiqueta la lista se vuelve a leer: hasta
            // que llegue se queda la de antes, con el indicador encima.
            list: FernBusyOverlay(
              isBusy: state.isBusy,
              // La lista va directamente sobre el fondo, sin superficie propia
              // de la que copiar el redondeo.
              radius: AppSizes.radiusMedium,
              child: TagList(
                tags: state.tags,
                selectedTagId: selected.id,
                onSelected: _select,
              ),
            ),
          );
        },
      ),
    );
  }

  /// El contenido de la etiqueta elegida.
  Widget _tagMedia() {
    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        // Como en las demás rejillas: el contenido se abre a pantalla completa
        // y al cerrarlo se vuelve aquí, con la etiqueta elegida tal y como
        // estaba.
        if (state is DetailedMedia) context.push(viewerRoute);
      },
      builder: (context, state) => MediaGrid(
        mediaList: state.mediaList ?? const [],
        columns: tagManagerGridColumns,
        isLoading: state.isBusy,
        // La superficie de esta pantalla es la de la ficha: la rejilla va
        // directamente sobre el fondo.
        hasSurface: false,
      ),
    );
  }
}
