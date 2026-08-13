import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/display/fern_progress_indicator.dart';
import 'package:Fern/core/ui/inputs/fern_outlined_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Campo de búsqueda con contorno, etiqueta flotante y sugerencias en overlay.
///
/// Las sugerencias pueden ser una lista fija, que el propio campo filtra por el
/// texto escrito, o venir ya resueltas de fuera (por ejemplo de una búsqueda en
/// la base de datos); en ese segundo caso hay que pasar
/// `filterSuggestions: false` para que se muestren tal cual llegan.
class FernSearchInput extends StatefulWidget {
  final String label;
  final String hintText;

  /// Texto con el que arranca el campo. Sirve para los formularios de edición,
  /// donde el valor que ya tiene lo que se está editando aparece escrito.
  final String initialValue;

  final List<String> suggestions;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;
  final double maxSuggestionsHeight;

  /// Si es `false`, [suggestions] se muestra sin filtrar por el texto escrito.
  final bool filterSuggestions;

  /// Las sugerencias se están buscando. Mientras dure, el campo enseña el
  /// indicador de espera en lugar del botón de borrar: así se ve que lo que se ha
  /// escrito se está consultando y que el desplegable está por llegar.
  final bool isSearching;

  const FernSearchInput({
    super.key,
    required this.label,
    this.hintText = '',
    this.initialValue = '',
    this.suggestions = const [],
    this.onSelected,
    this.onChanged,
    this.maxSuggestionsHeight = 200,
    this.filterSuggestions = true,
    this.isSearching = false,
  });

  @override
  State<FernSearchInput> createState() => _FernSearchInputState();
}

class _FernSearchInputState extends State<FernSearchInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> get _visibleSuggestions {
    if (!widget.filterSuggestions) return widget.suggestions;

    final text = _controller.text.toLowerCase();
    return widget.suggestions
        .where((s) => s.toLowerCase().contains(text))
        .toList();
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

  /// Muestra, oculta o repinta el desplegable según lo que haya que enseñar.
  void _refreshOverlay() {
    if (_controller.text.isEmpty || _visibleSuggestions.isEmpty) {
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
              constraints: BoxConstraints(maxHeight: widget.maxSuggestionsHeight),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _visibleSuggestions
                    .map((suggestion) => ListTile(
                          title: Text(
                            suggestion,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontFamily: 'Courier'),
                          ),
                          onTap: () {
                            _controller.text = suggestion;
                            widget.onSelected?.call(suggestion);
                            _hideOverlay();
                            FocusScope.of(context).unfocus();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FernSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.suggestions, widget.suggestions)) return;

    // Las sugerencias que llegan de fuera aparecen mientras se está pintando el
    // árbol; el overlay se toca cuando el frame ya ha terminado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshOverlay();
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FernOutlinedField(
        label: widget.label,
        child: TextField(
          controller: _controller,
          onChanged: (val) {
            widget.onChanged?.call(val);
            _refreshOverlay();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: switch ((widget.isSearching, _controller.text.isEmpty)) {
              // El indicador va donde iría el botón de borrar, con su mismo
              // hueco: al terminar la búsqueda el botón vuelve a su sitio sin que
              // el campo cambie de tamaño.
              (true, _) => const Padding(
                  padding: EdgeInsets.all(AppSpacing.m),
                  child: FernProgressIndicator.small(),
                ),
              (false, true) => null,
              (false, false) => IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.black),
                  onPressed: () {
                    _controller.clear();
                    _hideOverlay();
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                ),
            },
          ),
        ),
      ),
    );
  }
}
