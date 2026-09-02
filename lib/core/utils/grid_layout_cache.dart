import 'package:Fern/core/utils/masonry_layout.dart';

/// Lo que la rejilla deriva de una lista, guardado entre pantallas.
///
/// **Por qué existe.** Abrir una pantalla construye la rejilla desde cero, y con
/// ella tres recorridos de toda la lista: las proporciones de cada celda, el
/// orden en el que se pintan y el reparto en columnas. Con veinte mil contenidos
/// eso es el trozo de trabajo más grande del primer fotograma de la pantalla que
/// entra, o sea justo encima de la transición — y se rehacía **aunque la lista
/// fuera exactamente la misma**, porque el widget que lo guardaba era nuevo.
///
/// Vive fuera de los widgets precisamente por eso: lo que hay que sobrevivir es
/// el cambio de pantalla.
///
/// **La clave es la identidad de la lista.** Ninguna de estas listas se toca por
/// dentro: cada cambio construye una nueva. Así que dos listas distintas son dos
/// instancias distintas, y la misma instancia es el mismo trabajo. Equivocarse
/// sólo puede costar un cálculo de más, nunca un reparto viejo: una lista nueva
/// nunca acierta con la clave de otra.
///
/// Se guardan [_slots] entradas y no una: durante un fundido cruzado hay dos
/// rejillas vivas a la vez, y con una sola se pisarían la una a la otra en cada
/// fotograma.
class GridLayoutCache {
  static const _slots = 4;

  final _derived = <_Derived>[];
  final _layouts = <_Layout>[];

  /// Las proporciones de [source], calculándolas sólo la primera vez.
  List<double?> ratiosOf(Object source, List<double?> Function() build) {
    final found = _derivedOf(source);
    return found.ratios ??= build();
  }

  /// Los identificadores en el orden en el que se pintan, igual.
  List<int> idsOf(Object source, List<int> Function() build) {
    final found = _derivedOf(source);
    return found.ids ??= build();
  }

  /// El reparto en columnas de [ratios] con estas medidas.
  ///
  /// Las medidas se comparan por valor y las proporciones por identidad: las
  /// primeras son cuatro números y las segundas son la lista entera.
  MasonryLayout layoutOf({
    required List<double?> ratios,
    required int columns,
    required double crossAxisExtent,
    required double spacing,
    required double fallbackRatio,
  }) {
    for (final entry in _layouts) {
      if (entry.matches(
        ratios: ratios,
        columns: columns,
        crossAxisExtent: crossAxisExtent,
        spacing: spacing,
        fallbackRatio: fallbackRatio,
      )) {
        return entry.layout;
      }
    }

    final layout = MasonryLayout.of(
      ratios: ratios,
      columns: columns,
      crossAxisExtent: crossAxisExtent,
      spacing: spacing,
      fallbackRatio: fallbackRatio,
    );

    _push(
      _layouts,
      _Layout(
        ratios: ratios,
        columns: columns,
        crossAxisExtent: crossAxisExtent,
        spacing: spacing,
        fallbackRatio: fallbackRatio,
        layout: layout,
      ),
    );

    return layout;
  }

  _Derived _derivedOf(Object source) {
    for (final entry in _derived) {
      if (identical(entry.source, source)) return entry;
    }

    final entry = _Derived(source);
    _push(_derived, entry);

    return entry;
  }

  /// Deja la entrada nueva delante y tira la más vieja si sobra.
  ///
  /// Delante porque lo que se acaba de usar es lo que más papeletas tiene de
  /// volver a usarse en el fotograma siguiente.
  void _push<T>(List<T> slots, T entry) {
    slots.insert(0, entry);
    if (slots.length > _slots) slots.removeLast();
  }
}

class _Derived {
  final Object source;

  List<double?>? ratios;
  List<int>? ids;

  _Derived(this.source);
}

class _Layout {
  final List<double?> ratios;
  final int columns;
  final double crossAxisExtent;
  final double spacing;
  final double fallbackRatio;
  final MasonryLayout layout;

  _Layout({
    required this.ratios,
    required this.columns,
    required this.crossAxisExtent,
    required this.spacing,
    required this.fallbackRatio,
    required this.layout,
  });

  bool matches({
    required List<double?> ratios,
    required int columns,
    required double crossAxisExtent,
    required double spacing,
    required double fallbackRatio,
  }) =>
      identical(this.ratios, ratios) &&
      this.columns == columns &&
      this.crossAxisExtent == crossAxisExtent &&
      this.spacing == spacing &&
      this.fallbackRatio == fallbackRatio;
}
