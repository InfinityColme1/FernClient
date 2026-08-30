import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/buttons/fern_add_button.dart';
import 'package:Fern/core/ui/inputs/fern_field_label.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

/// Una dirección de la lista, con su marca.
class FernLink {
  final String url;

  /// No apta: con el bloqueo cerrado no se enseña.
  final bool isNsfw;

  const FernLink(this.url, {this.isNsfw = false});

  FernLink copyWith({String? url, bool? isNsfw}) =>
      FernLink(url ?? this.url, isNsfw: isNsfw ?? this.isNsfw);

  @override
  bool operator ==(Object other) =>
      other is FernLink && other.url == url && other.isNsfw == isNsfw;

  @override
  int get hashCode => Object.hash(url, isNsfw);
}

/// Una lista de direcciones que se editan en el sitio.
///
/// Es el bloque de los enlaces de redes sociales de la ficha de creador, sacado
/// aquí para que sea el mismo en los tres sitios donde se manejan enlaces: los
/// perfiles del creador, las direcciones vinculadas a una etiqueta y las de un
/// creador. Antes eran tres formularios distintos para lo mismo, y sólo uno de
/// ellos —el de los perfiles— dejaba abrir, editar y quitar.
///
/// Cada enlace tiene dos formas. En reposo es pulsable y se abre en el navegador
/// del sistema, con un botón al lado que lleva a la otra forma: abrir es lo que
/// se viene a hacer casi siempre, así que se hace de una pulsación. Editando es
/// un campo de texto con el botón que lo da por bueno y el que lo quita.
///
/// **No guarda nada.** Avisa por [onChanged] en cada cambio —cada tecla
/// incluida— y por [onCommitted] cuando un enlace queda terminado, y quien lo
/// use decide cuándo escribir: la ficha de creador guarda con su botón, el
/// diálogo de direcciones al confirmar, y la ficha de etiqueta en cuanto se
/// termina cada dirección.
class FernLinkListField extends StatefulWidget {
  /// Las direcciones de partida. Sólo se leen al nacer: a partir de ahí manda lo
  /// que el usuario escriba.
  final List<FernLink> links;

  /// La lista entera cada vez que cambia algo, ya sin los campos vacíos.
  ///
  /// **Incluye las escondidas.** Con el bloqueo cerrado hay filas que no se
  /// pintan, y dejarlas fuera de aquí haría que guardar la lista las borrara:
  /// exactamente lo que le pasaba a las direcciones de una etiqueta al guardar
  /// su nombre.
  final ValueChanged<List<FernLink>> onChanged;

  /// La lista entera cuando un enlace queda **terminado**: al dar por bueno el
  /// que se estaba editando, al quitar uno o al salir del campo.
  ///
  /// Es lo que separa a los dos usos. Los perfiles del creador se guardan con el
  /// formulario, así que les basta [onChanged]; las direcciones de una etiqueta
  /// tienen su propia escritura y no esperan a ningún botón, pero guardar en
  /// cada tecla sería una escritura por letra.
  final ValueChanged<List<FernLink>>? onCommitted;

  /// Si se puede marcar una dirección como no apta.
  ///
  /// Llega por parámetro y no se pregunta aquí: el catálogo no sabe del modo
  /// NSFW. Sin contraseña puesta no hay botón, como en el resto de la
  /// aplicación: marcar no escondaría nada y el botón prometería algo que no va
  /// a pasar.
  final bool canMarkNsfw;

  /// Si las marcadas no se pueden enseñar ahora mismo.
  ///
  /// Desaparecen de la lista, sin hueco ni recuento, como todo lo que esconde el
  /// filtro. Siguen estando: [onChanged] las sigue devolviendo.
  final bool hidesMarked;

  final String markNsfwTooltip;
  final String unmarkNsfwTooltip;

  /// El rótulo de encima. Sin él, la lista va suelta.
  final String? label;

  /// Una línea pequeña bajo el rótulo, para lo que haya que advertir (qué forma
  /// tiene una dirección que funciona, por ejemplo).
  final String? note;

  /// Qué se dice cuando no hay ninguna.
  final String emptyMessage;

  /// Lo que se ve en un campo vacío.
  final String hintText;

  /// El texto del botón de añadir.
  final String addLabel;

  final String openTooltip;
  final String editTooltip;
  final String removeTooltip;
  final String doneTooltip;

  /// Con cuántos campos vacíos arranca cuando no hay ninguna dirección.
  ///
  /// El diálogo de direcciones arranca con dos: uno solo se lee como «aquí va
  /// una dirección» y no cuenta que puede haber varias. Las fichas arrancan con
  /// cero, porque ahí lo que se enseña es lo que hay.
  final int initialEmptyFields;

  /// Si la lista se queda con todo el alto que le den.
  ///
  /// Con `true` hay que ponerla dentro de algo con alto acotado (la ficha del
  /// creador lo hace con un `Expanded`) y la lista se estira o se encoge con
  /// ella. Con `false` crece con su contenido hasta [maxHeight] y a partir de
  /// ahí se desplaza por dentro, que es lo que hace falta en un diálogo.
  final bool fills;

  /// Hasta dónde puede crecer cuando [fills] es `false`.
  final double maxHeight;

  const FernLinkListField({
    super.key,
    required this.links,
    required this.onChanged,
    this.onCommitted,
    required this.emptyMessage,
    required this.hintText,
    required this.addLabel,
    required this.openTooltip,
    required this.editTooltip,
    required this.removeTooltip,
    required this.doneTooltip,
    this.canMarkNsfw = false,
    this.hidesMarked = false,
    this.markNsfwTooltip = '',
    this.unmarkNsfwTooltip = '',
    this.label,
    this.note,
    this.initialEmptyFields = 0,
    this.fills = false,
    this.maxHeight = 160.0,
  });

  @override
  State<FernLinkListField> createState() => _FernLinkListFieldState();
}

class _FernLinkListFieldState extends State<FernLinkListField> {
  late final List<TextEditingController> _controllers = [
    for (final link in widget.links) TextEditingController(text: link.url),
    for (var i = widget.links.length; i < widget.initialEmptyFields; i++)
      TextEditingController(),
  ];

  /// Cuáles están marcadas, por posición. Se recolocan con [_remove] igual que
  /// las que se están editando.
  late final Set<int> _marked = {
    for (var i = 0; i < widget.links.length; i++)
      if (widget.links[i].isNsfw) i,
  };

  /// Las posiciones que se están editando. Se entra enlace a enlace: lo normal
  /// es venir a tocar uno y no la lista entera.
  ///
  /// Los campos que nacen vacíos entran ya en edición: no hay nada que pulsar
  /// hasta que se escriba algo en ellos.
  late final Set<int> _editing = {
    for (var i = 0; i < _controllers.length; i++)
      if (_controllers[i].text.trim().isEmpty) i,
  };

  /// Lo escrito, sin los campos que se han quedado vacíos: dejar uno en blanco
  /// es otra forma de quitarlo.
  ///
  /// Con las escondidas dentro: no pintarlas no es quitarlas.
  List<FernLink> get _links => [
        for (var i = 0; i < _controllers.length; i++)
          if (_controllers[i].text.trim().isNotEmpty)
            FernLink(_controllers[i].text.trim(), isNsfw: _marked.contains(i)),
      ];

  /// Las posiciones que se pintan.
  ///
  /// Con el bloqueo cerrado, las marcadas no están: ni fila, ni hueco, ni
  /// recuento, como el resto de lo que esconde el filtro.
  List<int> get _visible => [
        for (var i = 0; i < _controllers.length; i++)
          if (!(widget.hidesMarked && _marked.contains(i))) i,
      ];

  void _notify() => widget.onChanged(_links);

  /// Un enlace ha quedado terminado.
  void _commit() {
    widget.onChanged(_links);
    widget.onCommitted?.call(_links);
  }

  /// Añade uno más, ya en modo edición.
  void _add() {
    setState(() {
      _controllers.add(TextEditingController());
      _editing.add(_controllers.length - 1);
    });
  }

  /// Marca o desmarca la de la posición [index].
  ///
  /// Con el bloqueo cerrado, marcarla la hace desaparecer en el acto. Es lo
  /// mismo que pasa al marcar una etiqueta desde su ficha, y por el mismo
  /// motivo: la marca dice qué se esconde, y esconderlo es lo que hace.
  void _toggleMark(int index) {
    setState(() {
      if (!_marked.remove(index)) _marked.add(index);
    });

    _commit();
  }

  /// Quita el de la posición [index].
  ///
  /// Las posiciones en edición se recolocan: las de debajo se quedan como están
  /// y las de encima bajan una, o se estaría editando un enlace distinto del que
  /// se abrió.
  void _remove(int index) {
    setState(() {
      _controllers.removeAt(index).dispose();

      // Los índices por debajo del que se va se quedan como están y los de
      // encima bajan uno. Vale para los dos conjuntos.
      Set<int> shifted(Set<int> positions) => positions
          .where((position) => position != index)
          .map((position) => position > index ? position - 1 : position)
          .toSet();

      final editing = shifted(_editing);
      final marked = shifted(_marked);

      _editing
        ..clear()
        ..addAll(editing);
      _marked
        ..clear()
        ..addAll(marked);
    });

    _commit();
  }

  /// Abre el enlace en el navegador del sistema.
  ///
  /// Se le pone `https://` a lo que no traiga protocolo: sin él, el sistema no
  /// sabe a qué aplicación dárselo.
  Future<void> _open(String link) async {
    final value = link.trim();
    if (value.isEmpty) return;

    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.label;
    final note = widget.note;

    // Con el bloqueo cerrado y todas marcadas, lo que se ve es lo mismo que si no
    // hubiera ninguna. A propósito: un «hay 3 que no puedes ver» cuenta lo que la
    // marca está para no contar.
    final visible = _visible;

    final list = visible.isEmpty
        ? Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.emptyMessage,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.unremarked),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: !widget.fills,
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (_, position) => _row(visible[position]),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          FernFieldLabel(text: label),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (note != null) ...[
          Text(
            note,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: context.colors.unremarked),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        // Con el hueco que quede o con el que pida su contenido, según quien lo
        // use: en una ficha de alto fijo es este bloque el que se estira, y en
        // un diálogo es el diálogo el que crece hasta un tope.
        if (widget.fills)
          Expanded(child: list)
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: list,
          ),
        const SizedBox(height: AppSpacing.xs),
        FernAddButton.compact(label: widget.addLabel, onTap: _add),
      ],
    );
  }

  /// Un enlace de la lista, en una de sus dos formas.
  Widget _row(int index) {
    final controller = _controllers[index];

    if (_editing.contains(index)) {
      return SizedBox(
        height: linkRowHeight,
        child: Row(
          children: [
            Expanded(
              child: Focus(
                // Escribir y pulsar fuera es tan común como pulsar el visto: sin
                // esto, lo escrito se queda sin guardar y parece que no se ha
                // escrito nada.
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _commit();
                },
                child: TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                autofocus: true,
                // En cada tecla: quien lo use lee la lista de aquí, y si sólo se
                // avisara al salir de edición, guardar con un enlace a medio
                // escribir lo perdería.
                onChanged: (_) => _notify(),
                onSubmitted: (_) {
                  setState(() => _editing.remove(index));
                  _commit();
                },
                decoration: InputDecoration(hintText: widget.hintText),
                ),
              ),
            ),
            _rowButton(
              icon: Symbols.check,
              tooltip: widget.doneTooltip,
              onPressed: () {
                setState(() => _editing.remove(index));
                _commit();
              },
            ),
            _markButton(index),
            _rowButton(
              icon: Symbols.close,
              tooltip: widget.removeTooltip,
              onPressed: () => _remove(index),
            ),
          ],
        ),
      );
    }

    final link = controller.text.trim();

    return SizedBox(
      height: linkRowHeight,
      child: Row(
        children: [
          Expanded(
            // A mano y no con una píldora del catálogo: los enlaces son largos y
            // la columna donde viven es estrecha, así que el texto tiene que
            // poder recortarse.
            child: InkWell(
              onTap: () => _open(link),
              mouseCursor: WidgetStateMouseCursor.clickable,
              child: Tooltip(
                message: widget.openTooltip,
                child: Row(
                  children: [
                    const Icon(Symbols.open_in_new, size: AppSizes.iconCompact),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _markButton(index),
          _rowButton(
            icon: Symbols.edit,
            tooltip: widget.editTooltip,
            onPressed: () => setState(() => _editing.add(index)),
          ),
          // Quitar sin tener que entrar a editar: en una lista de direcciones
          // vinculadas se viene tantas veces a borrar una como a corregirla.
          _rowButton(
            icon: Symbols.close,
            tooltip: widget.removeTooltip,
            onPressed: () => _remove(index),
          ),
        ],
      ),
    );
  }

  /// El interruptor de «esta dirección no es apta».
  ///
  /// Con el mismo icono y el mismo color con el que la aplicación marca todo lo
  /// demás: encendido en el color de lo que hay que mirar dos veces, apagado
  /// como los otros botones de la fila.
  Widget _markButton(int index) {
    if (!widget.canMarkNsfw) return const SizedBox.shrink();

    final isMarked = _marked.contains(index);

    return IconButton(
      icon: Icon(
        Symbols.visibility_off,
        size: AppSizes.iconCompact,
        color: isMarked ? context.colors.terciary : null,
      ),
      tooltip: isMarked ? widget.unmarkNsfwTooltip : widget.markNsfwTooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: linkRowHeight,
        height: linkRowHeight,
      ),
      onPressed: () => _toggleMark(index),
    );
  }

  /// Los botones que acompañan a un enlace, sin el hueco que un `IconButton`
  /// reserva por defecto: son varios en una lista que tiene que caber.
  Widget _rowButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: AppSizes.iconCompact),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: linkRowHeight,
        height: linkRowHeight,
      ),
      onPressed: onPressed,
    );
  }
}
