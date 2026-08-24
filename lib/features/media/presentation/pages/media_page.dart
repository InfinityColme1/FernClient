import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/media/presentation/widgets/search_filter_menu.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Todo el contenido definitivo de la base de datos: el que ya se ha revisado
/// y guardado desde el visor. Lo pendiente de revisar vive en la pantalla de
/// importación.
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late final RecognitionHighlight _highlight = getIt<RecognitionHighlight>();

  /// Con qué evento se vuelve a leer lo que se está viendo.
  ///
  /// La pantalla enseña cosas distintas según lo que se le haya pedido —toda la
  /// biblioteca, una búsqueda, una etiqueta—, y releer con el evento de la
  /// biblioteca entera después de una búsqueda tiraría la búsqueda.
  MediaEvents get _reload {
    final bloc = getIt<MediaBloc>();
    final suggestion = bloc.state.searchSuggestion;
    final searchQuery = bloc.state.searchQuery;

    return switch ((suggestion, searchQuery)) {
      (final SearchSuggestionEntity suggestion, _) =>
        SearchSuggestionSelectedEvent(suggestion),
      (_, final String query) => SearchMediaEvent(query),
      _ => const LoadMediaLibraryEvent(),
    };
  }

  /// Un reconocimiento ha terminado sobre esta pantalla.
  ///
  /// Sin esto, el aviso salta pero la rejilla sigue siendo la de antes: los
  /// distintivos no aparecen hasta que el usuario sale y vuelve, que es
  /// exactamente lo que el aviso le estaba pidiendo que no hiciera falta.
  void _onRecognized() {
    if (!mounted) return;

    final bloc = getIt<MediaBloc>();

    if (!shouldReloadOnRecognition(
      highlighted: _highlight.route,
      screen: mediaRoute,
      hasSelection: bloc.state.selectedIds.isNotEmpty,
      isViewingMedia: bloc.state is DetailedMedia,
    )) {
      return;
    }

    bloc.add(_reload);
  }

  @override
  void dispose() {
    _highlight.removeListener(_onRecognized);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _highlight.addListener(_onRecognized);

    // Si hay una búsqueda en marcha (se ha escrito en el buscador desde otra
    // pantalla) se repite, no se descarta: es lo que se ha pedido ver. Y se
    // repite tal cual era: si venía de pulsar una sugerencia, por esa
    // sugerencia; si no, por el texto.
    getIt<MediaBloc>().add(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _MediaView(),
    );
  }
}

class _MediaView extends StatelessWidget {
  const _MediaView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // El contenido ya revisado se abre a pantalla completa: la
          // información se despliega sólo si se pide.
          context.push(viewerRoute);
        }
      },
      builder: (context, state) {
        final mediaList = state.mediaList ?? const [];
        // Los grupos que el filtro deja ver; `mediaList` ya viene recortada
        // igual, así que el contador cuenta lo que de verdad hay en la rejilla.
        final sections = state.visibleSearchSections;

        // Las acciones masivas actúan sobre la selección de la rejilla, así que
        // sin selección no hay nada sobre lo que actuar.
        final selectedCount = state.selectedIds.length;
        final hasSelection = selectedCount > 0;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.xl,
                  bottom: AppSpacing.l,
                ),
                child: Row(
                  children: [
                    Text(
                      texts.mediaCount(mediaList.length),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (hasSelection) ...[
                      Text(
                        texts.selectedCount(selectedCount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.terciary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                    ],
                    // Marcar como favorito y mandar a la papelera toda la
                    // selección de una vez. Sin selección se quedan apagados en
                    // su sitio, que es como se ve que hay que elegir algo antes.
                    IconButton(
                      tooltip: texts.favoriteSelectedTooltip,
                      onPressed: hasSelection
                          ? () => context
                              .read<MediaBloc>()
                              .add(const FavoriteSelectedMediaEvent())
                          : null,
                      icon: const Icon(Icons.favorite_border),
                    ),
                    // Reconocer lo que esté seleccionado. Es el segundo de
                    // los cuatro puntos de entrada del D16, y pasa por el mismo
                    // sitio que los otros tres.
                    IconButton(
                      tooltip: texts.recognizeSelectedTooltip,
                      onPressed: hasSelection
                          ? () => requestRecognition(
                                context,
                                state.selectedIds.toList(),
                                name: texts.recognizeJobSelection,
                              )
                          : null,
                      icon: const Icon(Icons.auto_awesome_outlined),
                    ),
                    // Esconder la selección detrás del filtro NSFW. Sólo con
                    // contraseña puesta: sin ella marcar no escondería nada y el
                    // botón prometería algo que no va a pasar.
                    //
                    // Marca, no interruptor: la selección puede mezclar marcado
                    // y sin marcar, y un botón que dependiera de eso haría cosas
                    // distintas según lo que hubiera dentro. Para quitarla está
                    // el visor, que sabe cómo está cada contenido.
                    if (getIt<NsfwModeService>().isConfigured)
                      IconButton(
                        tooltip: texts.mediaNsfwMark,
                        onPressed: hasSelection
                            ? () => context.read<MediaBloc>().add(
                                  const SetSelectedMediaNsfwEvent(isNsfw: true),
                                )
                            : null,
                        icon: const Icon(Icons.visibility_off_outlined),
                      ),
                    IconButton(
                      tooltip: texts.deleteSelectedTooltip,
                      onPressed: hasSelection
                          ? () => context
                              .read<MediaBloc>()
                              .add(const DeleteSelectedMediaEvent())
                          : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    SearchFilterMenu(
                      filters: state.searchFilters,
                      sourceFilters: state.sourceFilters,
                      hasSearch: state.searchSections != null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sections == null
                    ? MediaGrid(
                        mediaList: mediaList,
                        columns: 4,
                        isLoading: state.isBusy,
                      )
                    : MediaGrid.sections(
                        sections: sections,
                        columns: 4,
                        isLoading: state.isBusy,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
