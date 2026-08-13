import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/debouncer.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/domain/usecases/search_suggestions_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Buscador de la barra superior: busca sobre todo el contenido de la base de
/// datos (descripciones, etiquetas y creadores).
///
/// Al escribir hace tres cosas: llevar a la pantalla de media, que es donde se
/// ven los resultados; sugerir hasta [mediaSearchSuggestionsLimit] coincidencias
/// en un desplegable; y, si se deja de escribir, actualizar la rejilla por su
/// cuenta pasado [mediaSearchDelay] sin cerrar las sugerencias.
///
/// La búsqueda se lanza además al pulsar enter o al elegir una sugerencia.
class MediaSearchBar extends StatefulWidget {
  const MediaSearchBar({super.key});

  @override
  State<MediaSearchBar> createState() => _MediaSearchBarState();
}

class _MediaSearchBarState extends State<MediaSearchBar> {
  final _searchSuggestions = getIt<SearchSuggestionsUseCase>();
  final _bloc = getIt<MediaBloc>();

  final TextEditingController _controller = TextEditingController();
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

  void _onQueryChanged(String value) {
    setState(() {});
    _goToMediaPage();

    final term = value.trim();
    if (term.isEmpty) {
      _reset();
      return;
    }

    _suggestionsDebouncer.run(() => _loadSuggestions(term));
    _searchDebouncer.run(() => _search(term));
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
  void _search(String term) {
    _searchDebouncer.cancel();
    _bloc.add(SearchMediaEvent(term));
  }

  void _onSubmitted(String value) {
    final term = value.trim();
    if (term.isEmpty) return;

    _hideOverlay();
    _search(term);
  }

  /// Al elegir una sugerencia se busca **esa** entidad, no su nombre: pulsar el
  /// creador "Pompeu" trae sus contenidos y nada más, aunque haya una etiqueta
  /// que también contenga la palabra.
  void _onSuggestionSelected(SearchSuggestionEntity suggestion) {
    _controller.text = suggestion.label;
    _suggestionsDebouncer.cancel();
    _searchDebouncer.cancel();
    _hideOverlay();
    setState(() {});
    _bloc.add(SearchSuggestionSelectedEvent(suggestion));
  }

  /// Deja el buscador como al principio: sin sugerencias y con la rejilla
  /// mostrando la biblioteca completa.
  void _reset() {
    _suggestionsDebouncer.cancel();
    _searchDebouncer.cancel();
    _hideOverlay();
    setState(() {
      _suggestions = const [];
      _isSuggesting = false;
    });
    _bloc.add(const ClearMediaSearchEvent());
  }

  void _clear() {
    _controller.clear();
    _reset();
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
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.lightgray),
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
    _hideOverlay();
    _suggestionsDebouncer.dispose();
    _searchDebouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.searchBarWidth,
      height: AppSizes.searchBarHeight,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.black),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                    onSubmitted: _onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: AppLocalizations.of(context).searchHint,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.lightgray),
                    ),
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
                else if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: _clear,
                    visualDensity: VisualDensity.compact,
                    iconSize: AppSizes.iconMedium,
                    icon: const Icon(Icons.cancel, color: AppColors.black),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
