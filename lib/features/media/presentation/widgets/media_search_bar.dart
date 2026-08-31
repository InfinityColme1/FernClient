import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/debouncer.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/usecases/search_suggestions_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/domain/services/search_criteria.dart';
import 'package:Fern/features/media/presentation/widgets/search_criteria_field.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

/// Buscador de la barra superior: busca sobre todo el contenido de la base de
/// datos (descripciones, nombres de fichero, etiquetas y creadores).
///
/// **Lo que se busca son pastillas, y se acumulan.** Cada una es una cosa por la
/// que acotar, y el contenido que sale es el que las cumple **todas**: «esta
/// etiqueta, de este creador». Se ponen al pulsar enter o al elegir una
/// sugerencia, y se quitan con su aspa o con retroceso teniendo el campo vacío.
///
/// Lo que hay escrito y todavía no es una pastilla busca igual: escribir y
/// esperar sigue actualizando la rejilla, como cuando sólo se podía buscar una
/// cosa. La diferencia es que ahora se cruza con lo que ya hubiera puesto.
///
/// Al escribir hace tres cosas: llevar a la pantalla de media, que es donde se
/// ven los resultados; sugerir hasta [mediaSearchSuggestionsLimit] coincidencias
/// en un desplegable; y, si se deja de escribir, actualizar la rejilla por su
/// cuenta pasado [mediaSearchDelay] sin cerrar las sugerencias.
class MediaSearchBar extends StatefulWidget {
  const MediaSearchBar({super.key});

  @override
  State<MediaSearchBar> createState() => _MediaSearchBarState();
}

class _MediaSearchBarState extends State<MediaSearchBar> {
  final _searchSuggestions = getIt<SearchSuggestionsUseCase>();
  final _bloc = getIt<MediaBloc>();

  late final SearchCriteriaController _controller =
      SearchCriteriaController(chipBuilder: _chip);
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  /// Espera corta: la de las sugerencias, para no consultar la base con cada
  /// pulsación.
  final Debouncer _suggestionsDebouncer = Debouncer(searchDebounceDuration);

  /// Espera larga: la que actualiza la rejilla cuando se deja de escribir.
  final Debouncer _searchDebouncer = Debouncer(mediaSearchDelay);

  List<SearchSuggestionEntity> _suggestions = const [];

  /// Se están buscando las sugerencias. Mientras dure, el buscador enseña el
  /// indicador de espera en el sitio del botón de borrar.
  bool _isSuggesting = false;

  /// Cuántas pastillas había la última vez que se miró.
  ///
  /// Sirve para distinguir «se ha escrito una letra» de «se ha borrado una
  /// pastilla»: las dos cosas llegan por el mismo sitio, porque una pastilla es
  /// un carácter del campo.
  int _chipCount = 0;

  /// Se arranca con lo que el bloc tenga puesto.
  ///
  /// La barra vive en la barra superior y el visor está fuera de ella, así que
  /// se rehace al ir y volver: sin esto, salir a mirar un contenido y volver
  /// dejaba la rejilla con la búsqueda hecha y la barra vacía.
  /// Mientras el bloqueo se abra y se cierre, hay que revisar las pastillas.
  StreamSubscription<bool>? _nsfwChanges;

  @override
  void initState() {
    super.initState();
    _adopt(_bloc.state.searchCriteria);

    if (getIt.isRegistered<NsfwModeService>()) {
      _nsfwChanges =
          getIt<NsfwModeService>().changes.listen((_) => _dropHidden());
    }
  }

  /// Quita las pastillas de lo que ya no se puede enseñar.
  ///
  /// Cerrar el bloqueo esconde la etiqueta o el creador de todas las listas y de
  /// todos los buscadores, pero su pastilla seguía en la barra **con su nombre a
  /// la vista**, que es justo lo que la marca esconde. Y con ella puesta la
  /// rejilla sale vacía sin explicar por qué.
  void _dropHidden() {
    if (!mounted) return;

    final visibility = getIt.isRegistered<NsfwVisibility>()
        ? getIt<NsfwVisibility>()
        : const ContentVisibility();

    bool hides(SearchCriterionEntity criterion) => switch (criterion.kind) {
          SearchCriterionKind.tag => visibility.hidesTag(criterion.id!),
          SearchCriterionKind.creator => visibility.hidesCreator(criterion.id!),
          SearchCriterionKind.media => visibility.hidesMedia(criterion.id!),
          SearchCriterionKind.text => false,
        };

    final kept = [
      for (final chip in _controller.chips)
        if (!hides(chip)) chip,
    ];

    if (kept.length == _controller.chips.length) return;

    setState(() {
      _controller.adopt([
        ...kept,
        if (_controller.pendingText.isNotEmpty)
          SearchCriterionEntity.text(_controller.pendingText, isPending: true),
      ]);
      _chipCount = kept.length;
    });

    _search();
  }

  /// Se queda con lo que se esté buscando, venga de donde venga.
  ///
  /// No todo lo que busca sale de aquí: pulsar una etiqueta en el menú lateral
  /// también pone una pastilla. Sin esto, la rejilla enseñaba el contenido de
  /// esa etiqueta y la barra seguía vacía, así que no había forma de ver por
  /// qué estaba acotada ni de quitarlo.
  void _adopt(List<SearchCriterionEntity> criteria) {
    _controller.adopt(criteria);
    _chipCount = _controller.chips.length;
  }

  /// Lo que se está buscando ahora mismo: las pastillas más lo escrito.
  List<SearchCriterionEntity> get _criteria => _controller.criteria;

  /// Ha cambiado el campo: puede ser lo escrito o una pastilla borrada con
  /// retroceso, que aquí es lo mismo porque una pastilla **es** un carácter.
  void _onQueryChanged(String _) {
    setState(() {});
    _goToMediaPage();

    // Quitar una pastilla se busca en el acto y no cuando se deje de escribir:
    // la espera es para no consultar la base con cada tecla, y borrar una
    // pastilla no es teclear, es deshacer algo que ya estaba puesto.
    if (_controller.chips.length != _chipCount) {
      _chipCount = _controller.chips.length;
      _suggestionsDebouncer.cancel();
      _hideOverlay();
      setState(() {
        _suggestions = const [];
        _isSuggesting = false;
      });
      _search();
      return;
    }

    final term = _controller.pendingText;
    if (term.isEmpty) {
      // Quedan las pastillas: borrar lo escrito no deshace la búsqueda entera,
      // sólo el trozo que todavía no se había confirmado.
      _suggestionsDebouncer.cancel();
      _hideOverlay();
      setState(() {
        _suggestions = const [];
        _isSuggesting = false;
      });
      _searchDebouncer.run(_search);
      return;
    }

    _suggestionsDebouncer.run(() => _loadSuggestions(term));
    _searchDebouncer.run(_search);
  }

  /// Los resultados se ven en la rejilla de la pantalla de media, así que
  /// escribir lleva allí desde cualquier otra pantalla.
  ///
  /// Si ya se está en ella no se vuelve a navegar: eso reconstruiría la pantalla
  /// y la búsqueda se perdería en cada pulsación.
  void _goToMediaPage() {
    final router = GoRouter.of(context);
    if (router.state.matchedLocation == mediaRoute) return;

    router.go(mediaRoute);
  }

  Future<void> _loadSuggestions(String term) async {
    setState(() => _isSuggesting = true);

    final result = await _searchSuggestions(params: term);
    if (!mounted) return;

    setState(() {
      _isSuggesting = false;
      _suggestions = result is DataSuccess
          ? result.data ?? const []
          : const <SearchSuggestionEntity>[];
    });
    _refreshOverlay();
  }

  /// Actualiza la rejilla. No toca el desplegable: cuando la búsqueda sale sola
  /// al dejar de escribir, las sugerencias siguen a la vista.
  void _search() {
    _searchDebouncer.cancel();
    _bloc.add(SearchCriteriaChangedEvent(_criteria));
  }

  /// Confirma lo escrito como pastilla y deja el campo listo para la siguiente.
  ///
  /// Si lo escrito **es** el nombre entero de una etiqueta o de un creador, la
  /// pastilla es de esa entidad y busca por su identificador: acotar a la
  /// etiqueta «Ladybug» no es lo mismo que buscar la palabra. Si no lo es, la
  /// pastilla es de texto libre y recoge lo mismo que recogía escribir.
  ///
  /// La coincidencia tiene que ser entera a propósito: bastando con que empiece
  /// igual, lo mismo escrito daría una cosa u otra según lo que hubiera en la
  /// base ese día.
  Future<void> _onSubmitted(String _) async {
    final term = _controller.pendingText;
    if (term.isEmpty) return;

    _suggestionsDebouncer.cancel();
    _searchDebouncer.cancel();
    _hideOverlay();

    final result = await _searchSuggestions(params: term);
    if (!mounted) return;

    _addChip(criterionFor(
      term,
      result is DataSuccess
          ? result.data ?? const []
          : const <SearchSuggestionEntity>[],
    ));
  }

  /// Al elegir una sugerencia se busca **esa** entidad, no su nombre: pulsar el
  /// creador «Pompeu» trae sus contenidos y nada más, aunque haya una etiqueta
  /// que también contenga la palabra.
  void _onSuggestionSelected(SearchSuggestionEntity suggestion) {
    _suggestionsDebouncer.cancel();
    _searchDebouncer.cancel();
    _hideOverlay();

    _addChip(SearchCriterionEntity.of(suggestion));
  }

  /// Pone una pastilla y vacía el campo.
  ///
  /// La misma dos veces no se añade: no acotaría nada y ocuparía sitio en una
  /// barra que no lo tiene.
  void _addChip(SearchCriterionEntity criterion) {
    setState(() {
      _controller.addChip(criterion);
      _suggestions = const [];
      _isSuggesting = false;
    });

    _chipCount = _controller.chips.length;
    _focusNode.requestFocus();
    _search();
  }

  void _removeChip(SearchCriterionEntity criterion) {
    setState(() => _controller.removeChip(criterion));

    _chipCount = _controller.chips.length;
    _focusNode.requestFocus();
    _search();
  }

  /// Cómo se pinta cada pastilla dentro del campo.
  Widget _chip(BuildContext context, SearchCriterionEntity criterion) =>
      SearchCriterionChip(
        criterion: criterion,
        onRemove: () => _removeChip(criterion),
      );

  /// Deja el buscador como al principio: sin pastillas, sin sugerencias y con la
  /// rejilla mostrando la biblioteca completa.
  void _clear() {
    _suggestionsDebouncer.cancel();
    _searchDebouncer.cancel();
    _hideOverlay();

    setState(() {
      _controller.clear();
      _chipCount = 0;
      _suggestions = const [];
      _isSuggesting = false;
    });

    _bloc.add(const ClearMediaSearchEvent());
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshOverlay() {
    if (_suggestions.isEmpty) {
      _hideOverlay();
      return;
    }

    _showOverlay();
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + AppSpacing.xs),
          child: Material(
            elevation: 0.0,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: context.colors.lightgray),
              ),
              constraints: const BoxConstraints(
                maxHeight: mediaSearchSuggestionsMaxHeight,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final suggestion in _suggestions)
                    SearchResultRow.suggestion(
                      label: suggestion.label,
                      imagePath: suggestion.imagePath,
                      type: suggestion.type,
                      isNsfw: suggestion.isNsfw,
                      onTap: () => _onSuggestionSelected(suggestion),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nsfwChanges?.cancel();
    _hideOverlay();
    _suggestionsDebouncer.dispose();
    _searchDebouncer.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSomething = !_controller.isEmpty;

    return BlocListener<MediaBloc, MediaStates>(
      bloc: _bloc,
      // Sólo lo que no ha salido de aquí: lo que emite la propia barra ya está
      // puesto, y volver a adoptarlo le quitaría al campo lo que se esté
      // escribiendo en ese momento.
      listenWhen: (_, current) => current.searchCriteria != _criteria,
      listener: (_, current) => setState(() => _adopt(current.searchCriteria)),
      child: _bar(context, hasSomething: hasSomething),
    );
  }

  Widget _bar(BuildContext context, {required bool hasSomething}) {
    return SizedBox(
      width: AppSizes.searchBarWidth,
      height: AppSizes.searchBarHeight,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.secondary,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          // Toda la barra lleva al campo, no sólo el trozo donde cae el
          // cursor: es una barra de búsqueda, y pulsar en el hueco de al lado
          // del texto tiene que ponerse a escribir. Las pastillas y el botón de
          // borrar van dentro y se quedan con su pulsación, que es lo que hace
          // el árbol de gestos con lo más interior.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _focusNode.requestFocus,
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Row(
              children: [
                Icon(Symbols.search, color: context.colors.black),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: SearchCriteriaField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onQueryChanged,
                    onSubmitted: _onSubmitted,
                    hintText: AppLocalizations.of(context).searchHint,
                  ),
                ),
                // Mientras se consultan las sugerencias, el indicador de espera
                // ocupa el sitio del botón de borrar: es el mismo hueco, así que
                // el campo de texto no cambia de ancho al aparecer.
                if (_isSuggesting)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s),
                    child: FernProgressIndicator.small(),
                  )
                else if (hasSomething)
                  IconButton(
                    tooltip: AppLocalizations.of(context).actionClearSearch,
                    onPressed: _clear,
                    visualDensity: VisualDensity.compact,
                    iconSize: AppSizes.iconMedium,
                    icon: Icon(Symbols.cancel, color: context.colors.black),
                  ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
