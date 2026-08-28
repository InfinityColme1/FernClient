import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/media/presentation/widgets/search_filter_menu.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/media/presentation/widgets/select_all_button.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
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

class _MediaView extends StatefulWidget {
  const _MediaView();

  @override
  State<_MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<_MediaView> {
  /// Nodo que recibe el foco de la pantalla para poder atender el teclado.
  ///
  /// El mismo patrón que el visor: un `Focus` con `autofocus` alrededor de todo
  /// y una función que mira las teclas. No hace falta un mapa de `Shortcuts`
  /// para un solo atajo, y meterlo aquí obligaría a montar `Actions` en una
  /// pantalla que no tiene ninguna otra acción de teclado.
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'MediaPageKeyboard');

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  /// Ctrl+A marca todo lo que hay a la vista, y lo desmarca si ya estaba todo.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.keyA) {
      return KeyEventResult.ignored;
    }
    if (!HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }

    final media = getIt<MediaBloc>().state.mediaList;
    if (media == null || media.isEmpty) return KeyEventResult.ignored;

    getIt<MediaBloc>().add(
      SelectAllMediaEvent([for (final one in media) one.id]),
    );

    return KeyEventResult.handled;
  }

  /// En qué orden se está pintando la biblioteca.
  ///
  /// Vive aquí para que el desplegable enseñe lo elegido sin esperar a que
  /// vuelva la consulta; lo que manda de verdad es lo guardado en
  /// preferencias, que es lo que lee quien pide el contenido.
  late MediaSortOrder _sortOrder = getIt<PreferencesService>()
      .getMediaSortOrder();

  /// Cómo se llama cada orden en el desplegable.
  String _sortLabel(MediaSortOrder order, AppLocalizations texts) =>
      switch (order) {
        MediaSortOrder.newestFirst => texts.sortNewestFirst,
        MediaSortOrder.oldestFirst => texts.sortOldestFirst,
        MediaSortOrder.fileName => texts.sortFileName,
        MediaSortOrder.description => texts.sortDescription,
        MediaSortOrder.kind => texts.sortKind,
        MediaSortOrder.random => texts.sortRandom,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return Focus(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: BlocConsumer<MediaBloc, MediaStates>(
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

          return FernGridScreen(
            // **Una sola fila, siempre.**
            //
            // Era un `Wrap` que bajaba a una segunda línea cuando no cabía, y no
            // cabía a menudo: los cuatro botones de la selección estaban puestos
            // siempre, apagados, ocupando su sitio aunque no hubiera nada
            // marcado. Cuatro controles muertos en la cabecera más usada de la
            // aplicación.
            //
            // Ahora sólo están cuando sirven. Sin selección la fila lleva la
            // cuenta y los tres controles de la derecha, y sobra ancho de
            // sobra; con selección aparecen sus acciones al lado de la cuenta,
            // que es donde se está mirando.
            header: Row(
              children: [
                Text(
                  texts.mediaCount(mediaList.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _SelectionActions(state: state),
                const Spacer(),
                SelectAllButton(
                  visible: state.mediaList ?? const [],
                  selectedIds: state.selectedIds,
                  onSelectAll: (ids) =>
                      context.read<MediaBloc>().add(SelectAllMediaEvent(ids)),
                ),
                const SizedBox(width: AppSpacing.s),
                // El orden sólo manda sobre la biblioteca: en una búsqueda el
                // contenido va agrupado por etiqueta y creador, y ahí el orden
                // lo pone el grupo.
                if (state.searchSections == null)
                  FernDropdownPill<MediaSortOrder>(
                    value: _sortOrder,
                    items: MediaSortOrder.values,
                    labelBuilder: (order) => _sortLabel(order, texts),
                    onChanged: (order) {
                      if (order == null) return;

                      setState(() => _sortOrder = order);
                      context.read<MediaBloc>().add(
                        MediaSortOrderChangedEvent(order),
                      );
                    },
                  ),
                // Son dos controles distintos: pegados se leen como uno partido
                // en dos, que es lo mismo que pasaba en la cabecera de
                // importación entre el desplegable y el menú de ver.
                const SizedBox(width: AppSpacing.m),
                SearchFilterMenu(
                  filters: state.searchFilters,
                  sourceFilters: state.sourceFilters,
                  typeFilters: state.typeFilters,
                  hasSearch: state.searchSections != null,
                ),
              ],
            ),
            body: sections == null
                ? MediaGrid(
                    mediaList: mediaList,
                    columns: mediaGridColumns,
                    isLoading: state.isBusy,
                    returnsToViewed: true,
                  )
                : MediaGrid.sections(
                    sections: sections,
                    columns: mediaGridColumns,
                    isLoading: state.isBusy,
                  ),
          );
        },
      ),
    );
  }
}

/// Lo que se puede hacer con lo que está marcado, y cuántos son.
///
/// **Sólo existe mientras hay algo marcado.** Antes estaba siempre puesto y
/// apagado, ocupando sitio en la cabecera más usada de la aplicación para
/// prometer cuatro acciones que no se podían hacer. Un control apagado que nunca
/// se enciende solo no enseña nada: lo que enseña es que hay que marcar algo, y
/// eso ya lo dice la rejilla.
///
/// El orden es el mismo que el de la barra del visor: primero lo que se marca
/// —y se desmarca con otro clic—, después las herramientas, y al final, con
/// hueco propio, lo que no tiene vuelta atrás.
class _SelectionActions extends StatelessWidget {
  final MediaStates state;

  const _SelectionActions({required this.state});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedIds = state.selectedIds;

    // Entra y sale en vez de aparecer de golpe: la cabecera cambia de contenido
    // al marcar, y sin transición eso es un salto.
    return AnimatedSwitcher(
      duration: context.motion(motionStandard),
      switchInCurve: motionEnterCurve,
      switchOutCurve: motionExitCurve,
      transitionBuilder: (child, animation) => SizeTransition(
        axis: Axis.horizontal,
        // Crece desde la izquierda, pegado a la cuenta que tiene al lado.
        alignment: Alignment.centerLeft,
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: selectedIds.isEmpty
          ? const SizedBox.shrink()
          : Row(
              key: const ValueKey('con-seleccion'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: AppSpacing.l),
                Text(
                  texts.selectedCount(selectedIds.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.terciary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),

                // --- Lo que se marca ---------------------------------------
                IconButton(
                  tooltip: texts.favoriteSelectedTooltip,
                  onPressed: () => context.read<MediaBloc>().add(
                    const FavoriteSelectedMediaEvent(),
                  ),
                  icon: const Icon(Symbols.favorite),
                ),
                // Esconder la selección detrás del filtro NSFW. Sólo con
                // contraseña puesta: sin ella marcar no escondería nada y el
                // botón prometería algo que no va a pasar.
                //
                // Marca, no interruptor: la selección puede mezclar marcado y
                // sin marcar, y un botón que dependiera de eso haría cosas
                // distintas según lo que hubiera dentro. Para quitarla está el
                // visor, que sabe cómo está cada contenido.
                if (getIt<NsfwModeService>().isConfigured)
                  IconButton(
                    tooltip: texts.mediaNsfwMark,
                    onPressed: () => context.read<MediaBloc>().add(
                      const SetSelectedMediaNsfwEvent(isNsfw: true),
                    ),
                    icon: const Icon(Symbols.visibility_off),
                  ),

                // --- Herramientas ------------------------------------------
                const SizedBox(width: AppSpacing.s),
                // Reconocer lo que esté seleccionado. Es el segundo de los
                // cuatro puntos de entrada del D16, y pasa por el mismo sitio
                // que los otros tres.
                IconButton(
                  tooltip: texts.recognizeSelectedTooltip,
                  onPressed: () => requestRecognition(
                    context,
                    selectedIds.toList(),
                    name: texts.recognizeJobSelection,
                  ),
                  icon: const Icon(Symbols.auto_awesome),
                ),

                // --- Lo que no tiene vuelta atrás --------------------------
                //
                // Con hueco propio: estaba pegado al de esconder y al de
                // seleccionar todo, que es donde un clic de más cuesta caro.
                const SizedBox(width: AppSpacing.l),
                IconButton(
                  tooltip: texts.deleteSelectedTooltip,
                  onPressed: () => context.read<MediaBloc>().add(
                    const DeleteSelectedMediaEvent(),
                  ),
                  icon: const Icon(Symbols.delete),
                ),
                const SizedBox(width: AppSpacing.l),
              ],
            ),
    );
  }
}
