import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/display/fern_progress_indicator.dart';
import 'package:Fern/core/ui/inputs/fern_outlined_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Fern/l10n/app_localizations.dart';

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

  /// Qué va detrás de cada sugerencia, si algo va.
  ///
  /// Existe para que los buscadores de etiquetas puedan marcar las NSFW: una
  /// etiqueta marcada se autocompletaba igual que las demás, y quien la elegía
  /// sin saberlo acababa de esconder contenido. Las sugerencias siguen siendo
  /// texto —lo que se escribe en el campo al elegir una— y esto sólo decora.
  final Widget? Function(String suggestion)? trailingOf;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;
  final double maxSuggestionsHeight;

  /// Si es `false`, [suggestions] se muestra sin filtrar por el texto escrito.
  final bool filterSuggestions;

  /// Las sugerencias se están buscando. Mientras dure, el campo enseña el
  /// indicador de espera en lugar del botón de borrar: así se ve que lo que se ha
  /// escrito se está consultando y que el desplegable está por llegar.
  final bool isSearching;

  /// Al elegir una sugerencia, el campo se vacía y se queda listo para la
  /// siguiente búsqueda.
  ///
  /// Es para los buscadores que sirven para elegir **varias cosas seguidas**
  /// —las etiquetas de un contenido—, donde lo elegido ya se ve en otro sitio y
  /// dejarlo escrito obliga a borrarlo a mano antes de buscar lo siguiente. Los
  /// que eligen una sola cosa (el padre de una etiqueta, el enlace de un fernie)
  /// lo dejan apagado: ahí el nombre escrito **es** el valor del campo, y
  /// vaciarlo sería deshacer lo que se acaba de elegir.
  final bool clearOnSelected;

  /// El desplegable se enseña también con el campo vacío.
  ///
  /// Apagado por defecto: hasta ahora un campo vacío no tenía nada que enseñar,
  /// y con las sugerencias filtradas por el texto (`filterSuggestions`) un
  /// `contains('')` las dejaría pasar todas de golpe. Lo encienden los que traen
  /// sus propias sugerencias resueltas de fuera y tienen algo que ofrecer antes
  /// de escribir: los últimos usados.
  final bool showsSuggestionsWhenEmpty;

  /// El campo acaba de recibir el foco estando vacío.
  ///
  /// Es cuándo hay que ir a buscar lo que se va a ofrecer sin escribir nada.
  final VoidCallback? onFocusedEmpty;

  const FernSearchInput({
    super.key,
    required this.label,
    this.hintText = '',
    this.initialValue = '',
    this.suggestions = const [],
    this.trailingOf,
    this.onSelected,
    this.onChanged,
    this.maxSuggestionsHeight = 200,
    this.filterSuggestions = true,
    this.isSearching = false,
    this.clearOnSelected = false,
    this.showsSuggestionsWhenEmpty = false,
    this.onFocusedEmpty,
  });

  @override
  State<FernSearchInput> createState() => _FernSearchInputState();
}

class _FernSearchInputState extends State<FernSearchInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  /// Ata el campo con su desplegable para las pulsaciones.
  ///
  /// El desplegable flota en la capa de encima, así que no es hijo del campo y
  /// pulsarlo cuenta como pulsar fuera. Con los dos en el mismo grupo, «fuera»
  /// pasa a ser fuera de los dos, que es lo que se quiere decir.
  final Object _tapGroup = Object();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  /// Al entrar en el campo vacío se pide lo que haya que ofrecer.
  ///
  /// **Y no se cierra al salir del foco**, aunque lo pida el cuerpo. Pulsar una
  /// sugerencia le quita el foco al campo, así que cerrarlo ahí quitaba el
  /// desplegable de en medio entre el botón abajo y el botón arriba: la
  /// pulsación acababa en el aire y elegir una sugerencia no hacía nada. De
  /// cerrarlo al pulsar fuera se encarga el `TapRegion`, que sí distingue el
  /// desplegable del resto de la pantalla.
  void _onFocusChanged() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) return;

    if (!widget.showsSuggestionsWhenEmpty) return;
    if (_controller.text.isNotEmpty) return;

    widget.onFocusedEmpty?.call();
    _refreshOverlay();
  }

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
    final isEmpty = _controller.text.isEmpty;

    if ((isEmpty && !widget.showsSuggestionsWhenEmpty) ||
        _visibleSuggestions.isEmpty) {
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
          // El color va en el `Material` y no en una caja por debajo: las filas
          // pintan su fondo y su resalte sobre el `Material` más cercano, y con
          // una caja de color en medio quedaban tapados —pasar por encima de
          // una sugerencia no se notaba— y Flutter lo avisaba por consola.
          child: TapRegion(
            groupId: _tapGroup,
            child: Material(
            elevation: 0.0,
            color: context.colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: context.colors.lightgray),
              ),
              constraints: BoxConstraints(maxHeight: widget.maxSuggestionsHeight),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _visibleSuggestions
                    .map((suggestion) => ListTile(
                          trailing: widget.trailingOf?.call(suggestion),
                          title: Text(
                            suggestion,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontFamily: 'Courier'),
                          ),
                          onTap: () {
                            // Se escribe antes de avisar: quien escucha
                            // resuelve la sugerencia por su texto, así que
                            // tiene que estar puesto cuando le llegue.
                            _controller.text = suggestion;
                            widget.onSelected?.call(suggestion);

                            if (widget.clearOnSelected) {
                              _controller.clear();
                              widget.onChanged?.call('');
                            }

                            _hideOverlay();

                            // Vaciándose, el foco se queda: lo siguiente que se
                            // va a hacer es escribir la búsqueda siguiente, y
                            // devolver el cursor a mano es el trabajo que esto
                            // ahorra.
                            if (!widget.clearOnSelected) {
                              FocusScope.of(context).unfocus();
                            }

                            setState(() {});
                          },
                        ))
                    .toList(),
              ),
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
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapGroup,
      // Pulsar en cualquier otro sitio lo cierra, que es lo que antes hacía el
      // foco. La diferencia está en que esto sí sabe que el desplegable es parte
      // del campo aunque viva en otra capa.
      onTapOutside: (_) => _hideOverlay(),
      child: CompositedTransformTarget(
      link: _layerLink,
      child: FernOutlinedField(
        label: widget.label,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (val) {
            widget.onChanged?.call(val);
            _refreshOverlay();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            // Sin márgenes propios: los pone el tema, que es el mismo que los
            // pone en un campo de texto normal. Con los suyos, el texto de un
            // buscador y el de un campo de nombre no arrancaban a la misma
            // altura ni a la misma distancia del borde.
            //
            // **Ni fondo ni marco: los pinta [FernOutlinedField] por fuera.**
            // Con el relleno puesto se pintaban los dos, y el de dentro es un
            // rectángulo recto que tapaba el borde del de fuera justo en las
            // esquinas: la caja salía con las cuatro puntas comidas y sólo se
            // veían los cuatro lados rectos.
            filled: false,
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
                  tooltip: AppLocalizations.of(context).actionClearSearch,
                  icon: Icon(Symbols.cancel, color: context.colors.black),
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
      ),
    );
  }
}
