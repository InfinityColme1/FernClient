import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_siblings_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_tag_usecase.dart';
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

  /// Se ha soltado una etiqueta sobre otra y se ha elegido qué hacer.
  ///
  /// Las dos opciones tocan cosas distintas: colgar cambia el árbol, relacionar
  /// crea un enlace entre dos etiquetas que se quedan donde estaban.
  Future<void> _onDropped(
    TagEntity dragged,
    TagEntity target,
    TagDropMode mode,
  ) async {
    final done = switch (mode) {
      TagDropMode.child => await _hangFrom(dragged, target),
      TagDropMode.related => await _relate(dragged, target),
    };

    if (!done || !mounted) return;

    // El árbol cambia en el menú lateral y en esta lista, así que se relee. Las
    // relacionadas no salen en el menú, pero sí en la ficha de las dos.
    _tagsBloc.add(const LoadTagsEvent());
  }

  /// Cuelga [tag] de [parent].
  ///
  /// Se guarda la etiqueta entera y no sólo su madre porque `updateTag` escribe
  /// lo que se le da: las del árbol vienen con su nombre, su avatar y sus
  /// direcciones, así que pasan intactas.
  Future<bool> _hangFrom(TagEntity tag, TagEntity parent) async {
    final result = await getIt<UpdateTagUseCase>()(
      params: UpdateTagParams(tag: tag, parent: parent),
    );

    return result is DataSuccess;
  }

  /// Relaciona [tag] con [other], sin moverlas del árbol.
  ///
  /// Se manda la lista entera y no sólo la nueva: es como se guardan las
  /// relacionadas, sustituyendo lo que hubiera. La relación es simétrica y de
  /// eso se encarga el repositorio.
  Future<bool> _relate(TagEntity tag, TagEntity other) async {
    final ids = {for (final each in tag.siblings) each.id};

    // Ya lo estaban: no hay nada que guardar ni nada que decir.
    if (!ids.add(other.id)) return false;

    final result = await getIt<SaveTagSiblingsUseCase>()(
      params: SaveTagSiblingsParams(tagId: tag.id, siblingIds: ids.toList()),
    );

    return result is DataSuccess;
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
            // Con la transición de la pantalla, igual que el resto.
            //
            // Sin ella, la pantalla vacía era lo único que no pasaba por la
            // coreografía: al ir de una gestión a otra estando las dos vacías,
            // los dos textos se pintaban a la vez y centrados en el mismo sitio,
            // así que se leían uno encima del otro.
            return ScreenSlotTransition(
              slot: ScreenSlot.grid,
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: state.isLoaded
                    ? FernEmptyState(
                        imageAsset: fernEmptyImage,
                        message: AppLocalizations.of(context).noTagsYet,
                        description:
                            AppLocalizations.of(context).noTagsYetHint,
                      )
                    : const Center(child: FernProgressIndicator()),
              ),
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
              parent: TagList.parentOf(state.tags, selected.id),
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
                onDropped: _onDropped,
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
