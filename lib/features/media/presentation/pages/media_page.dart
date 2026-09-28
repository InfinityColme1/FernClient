import 'dart:async';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/navigation/fern_screen_layout.dart';
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
import 'package:Fern/features/media/presentation/widgets/selection_lead.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_to_selection_dialog.dart';
import 'package:Fern/core/navigation/screen_entry.dart';
import 'package:Fern/core/navigation/lite_layout.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/viewed_media.dart';

/// Todo el contenido definitivo de la base de datos: el que ya se ha revisado
/// y guardado desde el visor. Lo pendiente de revisar vive en la pantalla de
/// importación.
class MediaPage extends StatefulWidget {
  /// La etiqueta por la que hay que filtrar nada más abrir, si se ha llegado
  /// aquí pulsando una del menú lateral.
  ///
  /// **Viaja con la navegación y no en un evento aparte.** Antes el menú
  /// navegaba y mandaba la búsqueda por su cuenta, y esta pantalla, al abrirse,
  /// pedía lo que hubiera en el estado —que todavía era lo de antes—: dos
  /// peticiones a la vez sobre el mismo bloc, y la rejilla se quedaba con la que
  /// terminara la última. A veces la etiqueta, a veces la biblioteca entera.
  final SearchSuggestionEntity? initialFilter;

  const MediaPage({super.key, this.initialFilter});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with ScreenEntryTask<MediaPage> {
  late final RecognitionHighlight _highlight = getIt<RecognitionHighlight>();

  /// Con qué evento se vuelve a leer lo que se está viendo.
  ///
  /// La pantalla enseña cosas distintas según lo que se le haya pedido —toda la
  /// biblioteca, una búsqueda, una etiqueta—, y releer con el evento de la
  /// biblioteca entera después de una búsqueda tiraría la búsqueda.
  MediaEvents get _reload {
    final criteria = getIt<MediaBloc>().state.searchCriteria;

    return criteria.isEmpty
        ? const LoadMediaLibraryEvent()
        : SearchCriteriaChangedEvent(criteria);
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

    // Antes de la transición y no al cargar: lo que hubiera de otra pantalla se
    // suelta ya, así que ésta entra con lo suyo (o con su hueco de carga) en vez
    // de enseñando el contenido de la anterior mientras dura la animación.
    getIt<MediaBloc>().add(
      const MediaScreenOpenedEvent(MediaListing.library),
    );
  }

  @override
  void onScreenEntered() {
    // Una sola petición, siempre. Si se ha llegado pulsando una etiqueta del
    // menú, se busca por ella; si no, se repite lo que hubiera en marcha —se ha
    // escrito en el buscador desde otra pantalla— tal cual era.
    final filter = widget.initialFilter;

    getIt<MediaBloc>().add(
      filter == null
          // Al entrar, sólo si hace falta: con la biblioteca ya leída y sin
          // nada que haya cambiado desde entonces, volver a leerla es el
          // trabajo que se notaba al ir y venir entre pantallas.
          ? (_hasSearch ? _reload : const LoadMediaLibraryEvent(ifStale: true))
          : SearchSuggestionSelectedEvent(filter),
    );
  }

  bool get _hasSearch => getIt<MediaBloc>().state.searchCriteria.isNotEmpty;

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

  /// Abrir o cerrar el filtro NSFW cambia la rejilla entera: se pide que
  /// aparezca de nuevo desde sus huecos, como al ordenar.
  late final StreamSubscription<bool> _nsfwChanges =
      getIt<NsfwModeService>().changes.listen((_) => _expectReveal());

  /// La lista que había cuando se pidió que la rejilla apareciera de nuevo, o
  /// `null` si no se ha pedido. Se pide al elegir orden o cambiar el filtro
  /// NSFW, pero **se hace al llegar la lista nueva**: haciéndolo al pulsar,
  /// los huecos se llenaban con el orden viejo y la lista nueva movía después
  /// las celdas ya hechas de golpe.
  List<MediaSummaryEntity>? _revealFrom;
  bool _isRevealPending = false;

  /// Cuántas veces ha vuelto a aparecer la rejilla. Ver
  /// [MediaGrid.revealKey].
  int _revealGeneration = 0;

  void _expectReveal() {
    _isRevealPending = true;
    _revealFrom = getIt<MediaBloc>().state.mediaList;
  }

  @override
  void initState() {
    super.initState();
    _nsfwChanges;
  }

  @override
  void dispose() {
    _nsfwChanges.cancel();
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

  /// Cuántas veces se ha elegido orden. Cada vez la rejilla vuelve arriba;
  /// va aparte del orden porque volver a elegir «al azar» también cuenta.
  int _sortGeneration = 0;

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

  /// La cabecera del modo reducido, en una sola fila baja: el logo —que aquí
  /// no hay barra superior—, cuántos hay, el orden y los filtros. Sin selección,
  /// que es para trabajar y no para mirar.
  Widget _liteHeader(
    BuildContext context,
    AppLocalizations texts,
    MediaStates state,
  ) {
    return Row(
      children: [
        const FernLogo(height: AppSizes.liteLogoHeight),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(
            texts.mediaCount(state.mediaList?.length ?? 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Flexible(child: _sortPill(context, texts)),
        const SizedBox(width: AppSpacing.s),
        _filterMenu(state),
      ],
    );
  }

  Widget _filterMenu(MediaStates state) {
    return SearchFilterMenu(
      sourceFilters: state.sourceFilters,
      typeFilters: state.typeFilters,
    );
  }

  Widget _sortPill(BuildContext context, AppLocalizations texts) {
    return FernDropdownPill<MediaSortOrder>(
      value: _sortOrder,
      items: MediaSortOrder.values,
      labelBuilder: (order) => _sortLabel(order, texts),
      onChanged: (order) {
        if (order == null) return;

        // Ordenar vuelve arriba: con otro orden, lo que había a esa altura ya
        // es otra cosa, y volver a lo último mirado bajaba la rejilla sola.
        getIt<ViewedMedia>().forget();
        _expectReveal();
        setState(() {
          _sortOrder = order;
          _sortGeneration++;
        });
        context.read<MediaBloc>().add(MediaSortOrderChangedEvent(order));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

          if (_isRevealPending && !identical(mediaList, _revealFrom)) {
            _isRevealPending = false;
            _revealGeneration++;
          }
          // Los grupos que el filtro deja ver; `mediaList` ya viene recortada
          // igual, así que el contador cuenta lo que de verdad hay en la rejilla.
          final sections = state.visibleSearchSections;

          // En modo reducido la cabecera se queda en la cuenta y el orden, y la
          // rejilla en las columnas que quepan.
          final isLite = isLiteLayout(context);
          final columns = isLite
              ? liteGridColumns(MediaQuery.sizeOf(context).width)
              : mediaGridColumns;

          // Las acciones masivas actúan sobre la selección de la rejilla, así que
          // sin selección no hay nada sobre lo que actuar.

          return FernGridScreen(
            // En modo reducido, rellenos de menos: cada punto de alto que no
            // se lleva la cabecera es rejilla.
            padding: isLite
                ? const EdgeInsets.only(top: AppSpacing.s, left: AppSpacing.m)
                : const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
            headerPadding: isLite
                ? const EdgeInsets.only(
                    right: AppSpacing.m,
                    bottom: AppSpacing.s,
                  )
                : const EdgeInsets.only(
                    right: AppSpacing.xl,
                    bottom: AppSpacing.l,
                  ),
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
            header: isLite
                ? _liteHeader(context, texts, state)
                : Row(
                  children: [
                    SelectionLead(
                      visible: mediaList,
                      selectedIds: state.selectedIds,
                      countLabel: texts.mediaCount(mediaList.length),
                      onSelectAll: (ids) =>
                          context.read<MediaBloc>().add(SelectAllMediaEvent(ids)),
                      onClear: () => context.read<MediaBloc>().add(
                        const ClearMediaSelectionEvent(),
                      ),
                    ),
                    _SelectionActions(state: state),
                    const Spacer(),
                    // El orden vale también sobre una búsqueda: ordena **dentro de
                    // cada grupo**, que es donde hay tanto contenido como en la
                    // biblioteca. Sin esto, buscar era la única pantalla en la que
                    // había que mirar lo que saliera en el orden que saliera.
                    _sortPill(context, texts),
                    // Son dos controles distintos: pegados se leen como uno partido
                    // en dos, que es lo mismo que pasaba en la cabecera de
                    // importación entre el desplegable y el menú de ver.
                    const SizedBox(width: AppSpacing.m),
                    _filterMenu(state),
                  ],
                ),
            body: sections == null
                ? MediaGrid(
                    mediaList: mediaList,
                    columns: columns,
                    isLoading: state.isBusy,
                    returnsToViewed: true,
                    scrollResetKey: _sortGeneration,
                    revealKey: _revealGeneration,
                    showsKind: _sortOrder == MediaSortOrder.kind,
                  )
                : MediaGrid.sections(
                    sections: sections,
                    columns: columns,
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
                // Separadas de la píldora de quitar la selección por un
                // divisor: son lo que se hace con ella, no parte de soltarla.
                const SizedBox(width: AppSpacing.m),
                const SizedBox(
                  height: AppSpacing.xl,
                  child: VerticalDivider(width: AppSpacing.l),
                ),

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
                // Ponerle el mismo creador a toda la tanda. Va con las
                // herramientas y no con lo que se marca: no es una marca, es
                // rellenar un dato que faltaba en cien contenidos a la vez.
                IconButton(
                  tooltip: texts.assignCreatorSelectedTooltip,
                  onPressed: () => showFernDialog<void, MediaBloc>(
                    context: context,
                    bloc: context.read<MediaBloc>(),
                    builder: (_) => AssignCreatorToSelectionDialog(
                      count: selectedIds.length,
                    ),
                  ),
                  icon: const Icon(Symbols.person_edit),
                ),
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
