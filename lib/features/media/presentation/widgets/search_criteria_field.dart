import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Las pastillas de la barra de búsqueda, **como parte del texto**.
///
/// Cada pastilla ocupa exactamente un carácter del campo, y ese carácter es el
/// que `WidgetSpan` usa para reservarle sitio. Eso es lo que hace que se
/// comporten como texto y no como algo pegado al lado: el cursor pasa por ellas
/// con las flechas, se seleccionan arrastrando, retroceso borra la de al lado
/// como borraría una letra, y todo el ancho de la barra es el mismo campo.
///
/// El primer intento las puso en una fila aparte, al lado del campo. Se veía
/// parecido y no lo era: quedaba un trozo pequeño donde escribir, el resto de la
/// barra no atendía a las pulsaciones, y el cursor no llegaba a las pastillas.
class SearchCriteriaController extends TextEditingController {
  /// El hueco que ocupa una pastilla dentro del texto.
  ///
  /// Es el mismo carácter con el que Flutter representa un `WidgetSpan` al
  /// convertir el texto a plano, y tiene que serlo: si no, lo que el campo cree
  /// que está escrito y lo que se pinta medirían distinto, y el cursor caería en
  /// otro sitio.
  static const chipChar = '￼';

  /// Cómo se pinta una pastilla. Lo pone quien usa el controlador, porque
  /// necesita el contexto para los colores y los textos.
  final Widget Function(BuildContext context, SearchCriterionEntity criterion)
      chipBuilder;

  SearchCriteriaController({required this.chipBuilder});

  List<SearchCriterionEntity> _chips = const [];

  /// Se está reescribiendo el campo desde aquí y no desde el teclado.
  bool _rebuilding = false;

  List<SearchCriterionEntity> get chips => List.unmodifiable(_chips);

  /// Lo escrito que todavía no es una pastilla, sin los huecos de las que sí.
  String get pendingText => text.replaceAll(chipChar, '').trim();

  /// Todo por lo que se está buscando: las pastillas y lo que se esté
  /// escribiendo.
  List<SearchCriterionEntity> get criteria => [
        ..._chips,
        if (pendingText.isNotEmpty)
          SearchCriterionEntity.text(pendingText, isPending: true),
      ];

  bool get isEmpty => _chips.isEmpty && pendingText.isEmpty;

  /// Confirma una pastilla y deja el campo listo para la siguiente.
  ///
  /// La misma dos veces no se añade: no acotaría nada y ocuparía sitio en una
  /// barra que no lo tiene.
  void addChip(SearchCriterionEntity criterion) {
    _write(_chips.contains(criterion) ? _chips : [..._chips, criterion]);
  }

  void removeChip(SearchCriterionEntity criterion) {
    _write(
      [
        for (final chip in _chips)
          if (chip != criterion) chip,
      ],
      text: text.replaceAll(chipChar, ''),
    );
  }

  /// Se queda con lo que se esté buscando, venga de donde venga.
  void adopt(List<SearchCriterionEntity> criteria) {
    final pending = criteria.where((each) => each.isPending);

    _write(
      [
        for (final criterion in criteria)
          if (!criterion.isPending) criterion,
      ],
      text: pending.isEmpty ? '' : pending.first.label,
    );
  }

  /// Reescribe el campo entero, con las pastillas delante y el texto detrás.
  ///
  /// Las pastillas van juntas al principio a propósito: es donde acaban de todas
  /// formas al confirmarlas una tras otra, y reordenarlas cada vez que se toca
  /// una sería mover de sitio lo que el usuario ya ha colocado.
  void _write(List<SearchCriterionEntity> chips, {String text = ''}) {
    _rebuilding = true;

    _chips = chips;
    final full = chipChar * chips.length + text;

    value = TextEditingValue(
      text: full,
      selection: TextSelection.collapsed(offset: full.length),
    );

    _rebuilding = false;
  }

  /// Las pastillas que sobreviven a una edición del usuario.
  ///
  /// Se compara lo que había con lo que hay quedándose con el principio y el
  /// final comunes: lo de en medio es lo que se ha sustituido, y las pastillas
  /// que caían ahí son las que se han borrado. Con eso, retroceso y selección se
  /// llevan las pastillas por delante igual que se llevarían letras, sin que
  /// haga falta un caso especial para cada forma de borrar.
  List<SearchCriterionEntity> _survivors(String before, String after) {
    var start = 0;
    while (start < before.length &&
        start < after.length &&
        before[start] == after[start]) {
      start++;
    }

    var endBefore = before.length;
    var endAfter = after.length;
    while (endBefore > start &&
        endAfter > start &&
        before[endBefore - 1] == after[endAfter - 1]) {
      endBefore--;
      endAfter--;
    }

    final kept = <SearchCriterionEntity>[];
    var index = 0;

    for (var i = 0; i < before.length; i++) {
      if (before[i] != chipChar) continue;

      final chip = index < _chips.length ? _chips[index] : null;
      index++;

      if (chip == null) continue;
      if (i >= start && i < endBefore) continue;

      kept.add(chip);
    }

    return kept;
  }

  @override
  set value(TextEditingValue newValue) {
    if (!_rebuilding && newValue.text != super.value.text) {
      _chips = _survivors(super.value.text, newValue.text);
    }

    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    var index = 0;

    void flush() {
      if (buffer.isEmpty) return;

      spans.add(TextSpan(text: buffer.toString(), style: style));
      buffer.clear();
    }

    for (var i = 0; i < text.length; i++) {
      final char = text[i];

      if (char != chipChar) {
        buffer.write(char);
        continue;
      }

      flush();

      final chip = index < _chips.length ? _chips[index] : null;
      index++;

      // Un hueco sin pastilla no debería pasar, pero si pasara tiene que seguir
      // ocupando un carácter: dejarlo fuera descuadraría el cursor de ahí en
      // adelante.
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: chip == null
            ? const SizedBox.shrink()
            : chipBuilder(context, chip),
      ));
    }

    flush();

    return TextSpan(style: style, children: spans);
  }
}

/// El campo de la barra de búsqueda: las pastillas y lo que se escribe, en uno.
class SearchCriteriaField extends StatelessWidget {
  final SearchCriteriaController controller;
  final FocusNode? focusNode;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  /// Qué se lee en el campo vacío. Con alguna pastilla puesta no se enseña: el
  /// hueco es del texto que se esté escribiendo y el rótulo estorbaría más de lo
  /// que explica.
  final String hintText;

  const SearchCriteriaField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        isCollapsed: true,
        // Sin relleno propio: el fondo lo pinta la barra, y el del tema
        // (`filled: true`) se le sumaba debajo sin verse. Lo que sí se veía era
        // su velo al pasar el cursor por encima, que teñía la barra entera
        // desde que el campo la ocupa toda.
        filled: false,
        hoverColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: controller.chips.isEmpty ? hintText : null,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.colors.lightgray),
      ),
    );
  }
}

/// Una pastilla dentro del campo.
///
/// Ligera a propósito: va dentro de una barra de 40 px de alto y compite con el
/// texto que se está escribiendo, así que no lleva ni sombra ni superficie
/// propia, sólo un fondo que la separa de lo escrito.
class SearchCriterionChip extends StatelessWidget {
  final SearchCriterionEntity criterion;
  final VoidCallback onRemove;

  const SearchCriterionChip({
    super.key,
    required this.criterion,
    required this.onRemove,
  });

  /// Lo que se lee en la pastilla.
  ///
  /// De un contenido se enseña **la palabra y no su descripción**: una
  /// descripción puede tener tres líneas, y una pastilla que las lleve todas se
  /// come la barra entera. Cuál es se ve en la rejilla, que es lo que se acaba
  /// de pedir.
  String _label(AppLocalizations texts) =>
      criterion.kind == SearchCriterionKind.media
          ? texts.searchChipDescription
          : criterion.label;

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: searchChipVerticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // El texto libre no es nada de la base, así que no tiene cara que
              // enseñar.
              if (criterion.kind != SearchCriterionKind.text) ...[
                FernAvatar(
                  imagePath: criterion.imagePath,
                  fallbackIcon: criterion.resultType.icon,
                  radius: searchChipAvatarRadius,
                  iconSize: AppSizes.iconCompact,
                  backgroundColor: context.colors.secondary,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              // Con un tope: el nombre de una etiqueta puede ser largo, y sin
              // esto una sola pastilla deja la barra sin sitio para escribir.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: searchChipMaxWidth),
                child: Text(
                  _label(texts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              if (criterion.isNsfw) ...[
                const SizedBox(width: AppSpacing.xs),
                const NsfwTagMark(),
              ],
              const SizedBox(width: AppSpacing.xs),
              // Sin tinta ni velo al pasar por encima: la pastilla es pequeña y
              // va dentro de un campo de texto, así que un círculo sombreándose
              // detrás del aspa pesa más que el aspa. El cursor ya dice que se
              // puede pulsar.
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Symbols.close,
                    size: AppSizes.iconCompact,
                    color: context.colors.gray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
