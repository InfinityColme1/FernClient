import 'dart:async';

import 'package:Fern/core/ui/inputs/fern_search_input.dart';
import 'package:Fern/core/utils/debouncer.dart';
import 'package:flutter/material.dart';

/// Buscador que resuelve sus sugerencias con una búsqueda asíncrona.
///
/// Envuelve a [FernSearchInput] y se encarga de lo que se repetía en todos los
/// diálogos: esperar a que se deje de escribir, lanzar la búsqueda y avisar del
/// elemento elegido, ya sea porque se ha pulsado una sugerencia o porque lo
/// escrito coincide con el nombre de una de ellas.
class FernEntitySearchField<T> extends StatefulWidget {
  final String label;
  final String hintText;

  /// Nombre con el que arranca el campo, para los formularios de edición: el
  /// elemento que ya está elegido aparece escrito, sin necesidad de buscarlo.
  final String initialValue;

  /// Búsqueda que alimenta las sugerencias. Es quien decide cuántas devuelve y
  /// qué elementos se descartan.
  final Future<List<T>> Function(String query) search;

  /// Nombre con el que se muestra cada elemento en el desplegable.
  final String Function(T item) labelOf;

  /// Qué va detrás de cada resultado. Lo usan los buscadores de etiquetas para
  /// marcar las NSFW.
  final Widget? Function(T item)? trailingOf;

  final ValueChanged<T> onSelected;

  /// Cada pulsación, con el texto que hay escrito. Hace falta para saber cuándo
  /// el campo se ha quedado vacío, que es la forma de deshacer lo elegido.
  final ValueChanged<String>? onChanged;

  final Duration debounce;

  /// Al elegir, el campo se vacía y queda listo para buscar otra cosa. Ver
  /// [FernSearchInput.clearOnSelected].
  final bool clearOnSelected;

  /// Qué ofrecer nada más pulsar el campo, antes de escribir.
  ///
  /// Son los últimos usados. Sin esto el campo no enseña nada hasta que se
  /// teclea, y asignar las mismas tres etiquetas a una tanda obliga a
  /// escribirlas enteras una y otra vez.
  final Future<List<T>> Function()? recents;

  const FernEntitySearchField({
    super.key,
    required this.label,
    required this.search,
    required this.labelOf,
    this.trailingOf,
    required this.onSelected,
    this.onChanged,
    this.hintText = '',
    this.initialValue = '',
    this.debounce = const Duration(milliseconds: 250),
    this.clearOnSelected = false,
    this.recents,
  });

  @override
  State<FernEntitySearchField<T>> createState() =>
      _FernEntitySearchFieldState<T>();
}

class _FernEntitySearchFieldState<T> extends State<FernEntitySearchField<T>> {
  late final Debouncer _debouncer = Debouncer(widget.debounce);

  List<T> _results = const [];

  /// Hay una búsqueda en marcha. El campo lo enseña con su indicador de espera,
  /// que es lo único que se ve mientras la base de datos responde.
  bool _isSearching = false;

  /// Último nombre avisado, para no repetir el aviso mientras se sigue
  /// escribiendo sobre una coincidencia ya elegida.
  String? _notifiedName;

  /// Trae los últimos usados y los pone en el desplegable.
  ///
  /// Sin esperar: no hay nada que escribir, así que no hay nada que esperar a
  /// que termine de escribirse. Y sin indicador: es una lectura de preferencias
  /// y de la base por identificador, no una búsqueda.
  Future<void> _loadRecents() async {
    final recents = widget.recents;
    if (recents == null) return;

    final found = await recents();
    if (!mounted) return;

    // Mientras se iba a buscarlos ha podido escribirse algo: entonces mandan las
    // sugerencias de lo escrito, que es lo que se acaba de pedir.
    if (_results.isNotEmpty || _isSearching) return;

    setState(() => _results = found);
  }

  void _onQueryChanged(String query) {
    widget.onChanged?.call(query);

    if (_notifiedName != null && query.trim().toLowerCase() != _notifiedName) {
      _notifiedName = null;
    }

    if (query.trim().isEmpty) {
      _debouncer.cancel();
      if (_results.isNotEmpty || _isSearching) {
        setState(() {
          _results = const [];
          _isSearching = false;
        });
      }

      // Borrar lo escrito devuelve el campo a como estaba al pulsarlo, con los
      // últimos usados: dejarlo en blanco sería castigar el haber escrito.
      unawaited(_loadRecents());
      return;
    }

    _debouncer.run(() => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);

    final results = await widget.search(query);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _results = results;
    });

    // Si se ha terminado de escribir un nombre que existe, vale como elegido
    // sin necesidad de pulsar la sugerencia.
    final match = _matching(query);
    if (match != null) _select(match);
  }

  T? _matching(String name) {
    final target = name.trim().toLowerCase();
    if (target.isEmpty) return null;

    for (final item in _results) {
      if (widget.labelOf(item).toLowerCase() == target) return item;
    }
    return null;
  }

  void _select(T item) {
    final name = widget.labelOf(item).toLowerCase();
    if (_notifiedName == name) return;

    setState(() {
      _notifiedName = name;
      // Lo elegido deja de sugerirse hasta la siguiente búsqueda.
      _results = _results.where((e) => e != item).toList();
    });

    widget.onSelected(item);
  }

  void _onSuggestionSelected(String name) {
    final item = _matching(name);
    if (item != null) _select(item);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FernSearchInput(
      label: widget.label,
      hintText: widget.hintText,
      initialValue: widget.initialValue,
      filterSuggestions: false,
      isSearching: _isSearching,
      suggestions: _results.map(widget.labelOf).toList(),
      trailingOf: widget.trailingOf == null
          ? null
          : (suggestion) {
              final item = _matching(suggestion);

              return item == null ? null : widget.trailingOf!(item);
            },
      clearOnSelected: widget.clearOnSelected,
      showsSuggestionsWhenEmpty: widget.recents != null,
      onFocusedEmpty: _loadRecents,
      onChanged: _onQueryChanged,
      onSelected: _onSuggestionSelected,
    );
  }
}
