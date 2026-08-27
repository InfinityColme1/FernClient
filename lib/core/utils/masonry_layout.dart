import 'dart:math' as math;

/// Dónde cae una celda dentro de la rejilla.
class MasonryCell {
  /// A qué altura empieza, contando desde arriba del todo.
  final double top;

  /// Cuánto mide de alto.
  final double height;

  /// En qué columna está, y a qué distancia del borde izquierdo queda.
  final int column;
  final double left;

  const MasonryCell({
    required this.top,
    required this.height,
    required this.column,
    required this.left,
  });

  double get bottom => top + height;
}

/// Una rejilla de mampostería ya calculada entera.
///
/// **Por qué se calcula entera y por adelantado.** Una rejilla de mampostería
/// perezosa no sabe cuánto mide hasta que la ha recorrido, así que va
/// *estimando* el total con la media de lo que lleva colocado. Esa estimación
/// cambia con cada celda nueva, y con ella cambia el tamaño y la posición de la
/// barra de desplazamiento: se arrastra la barra hacia abajo y de pronto salta
/// arriba o abajo sola, porque debajo le han movido la referencia. Era lo que
/// hacía que desplazarse fuera tosco, y no tenía nada que ver con lo que
/// tardaran las miniaturas.
///
/// Calcularla entera se puede desde que el tamaño de cada contenido se guarda:
/// con las proporciones sabidas, colocar mil trescientas celdas es recorrer una
/// lista una vez. A partir de ahí el alto total es **exacto**, la barra deja de
/// moverse sola, y saber qué hay a una altura concreta —lo que hace falta para
/// cargar sólo lo que queda a la vista al soltar la barra— es una consulta y no
/// una adivinanza.
class MasonryLayout {
  final List<MasonryCell> cells;

  /// Lo que mide la rejilla de alto, de verdad.
  final double extent;

  /// El ancho de una columna.
  final double columnWidth;

  /// Cada cuánto se agrupan las celdas para poder preguntar qué hay a una
  /// altura sin recorrerlas todas.
  final double _bucketSize;

  /// Por cada tramo de altura, la primera y la última celda que lo tocan.
  final List<int> _firstAt;
  final List<int> _lastAt;

  const MasonryLayout._({
    required this.cells,
    required this.extent,
    required this.columnWidth,
    required double bucketSize,
    required List<int> firstAt,
    required List<int> lastAt,
  })  : _bucketSize = bucketSize,
        _firstAt = firstAt,
        _lastAt = lastAt;

  static const MasonryLayout empty = MasonryLayout._(
    cells: [],
    extent: 0,
    columnWidth: 0,
    bucketSize: 1,
    firstAt: [],
    lastAt: [],
  );

  bool get isEmpty => cells.isEmpty;

  /// La primera celda que puede verse a partir de [offset].
  ///
  /// Se queda corta a propósito cuando duda: construir una celda de más no se
  /// nota, y saltarse una que sí se ve deja un hueco en pantalla.
  int firstVisibleAt(double offset) {
    if (cells.isEmpty) return 0;

    final bucket = _bucketOf(offset);

    return _firstAt[bucket];
  }

  /// La última celda que puede verse hasta [offset]. Se pasa por lo mismo.
  int lastVisibleAt(double offset) {
    if (cells.isEmpty) return 0;

    final bucket = _bucketOf(offset);

    return _lastAt[bucket];
  }

  /// A qué altura hay que ponerse para ver la celda [index] centrada.
  ///
  /// Exacto, no estimado: es lo que hace que volver del visor caiga donde tiene
  /// que caer aunque las celdas midan cosas distintas.
  double offsetToCentre(int index, double viewportHeight) {
    if (index < 0 || index >= cells.length) return 0;

    final cell = cells[index];
    final wanted = cell.top + cell.height / 2 - viewportHeight / 2;
    final most = math.max(0.0, extent - viewportHeight);

    return wanted.clamp(0.0, most);
  }

  int _bucketOf(double offset) {
    final index = (offset / _bucketSize).floor();

    return index.clamp(0, _firstAt.length - 1);
  }

  /// Coloca [ratios] en [columns] columnas, poniendo cada celda en la columna
  /// que vaya más corta.
  ///
  /// Es el mismo reparto de siempre: lo único distinto es que ahora se hace de
  /// una vez y no según se va viendo, que es lo que permite saber el total.
  ///
  /// [ratios] es ancho partido por alto de cada celda. Lo que no se sepa entra
  /// con [fallbackRatio]: se colocará mal hasta que se sepa, pero se colocará.
  factory MasonryLayout.of({
    required List<double?> ratios,
    required int columns,
    required double crossAxisExtent,
    required double spacing,
    required double fallbackRatio,
    double bucketSize = 400,
  }) {
    if (ratios.isEmpty || columns <= 0 || crossAxisExtent <= 0) {
      return MasonryLayout.empty;
    }

    final width =
        (crossAxisExtent - spacing * (columns - 1)) / columns;
    if (width <= 0) return MasonryLayout.empty;

    // Lo que lleva cada columna. La siguiente celda va a la que vaya más corta,
    // y a igualdad, a la de más a la izquierda: así el reparto es siempre el
    // mismo para los mismos datos.
    final heights = List<double>.filled(columns, 0);
    final cells = <MasonryCell>[];

    for (final ratio in ratios) {
      var shortest = 0;
      for (var column = 1; column < columns; column++) {
        if (heights[column] < heights[shortest] - 0.01) shortest = column;
      }

      final safe = (ratio == null || ratio <= 0) ? fallbackRatio : ratio;
      final height = width / safe;

      final top = heights[shortest] == 0 ? 0.0 : heights[shortest] + spacing;

      cells.add(MasonryCell(
        top: top,
        height: height,
        column: shortest,
        left: shortest * (width + spacing),
      ));

      heights[shortest] = top + height;
    }

    final extent = heights.reduce(math.max);

    // Y el índice por tramos, para poder preguntar qué hay a una altura sin
    // recorrer las mil trescientas.
    final buckets = math.max(1, (extent / bucketSize).ceil() + 1);
    final firstAt = List<int>.filled(buckets, cells.length - 1);
    final lastAt = List<int>.filled(buckets, 0);

    for (var index = 0; index < cells.length; index++) {
      final cell = cells[index];

      final from = (cell.top / bucketSize).floor().clamp(0, buckets - 1);
      final to = (cell.bottom / bucketSize).floor().clamp(0, buckets - 1);

      for (var bucket = from; bucket <= to; bucket++) {
        if (index < firstAt[bucket]) firstAt[bucket] = index;
        if (index > lastAt[bucket]) lastAt[bucket] = index;
      }
    }

    // Un tramo por el que no pasa ninguna celda —no debería haberlo, pero el
    // redondeo existe— hereda el de arriba, que es lo prudente.
    for (var bucket = 1; bucket < buckets; bucket++) {
      if (firstAt[bucket] > lastAt[bucket]) {
        firstAt[bucket] = firstAt[bucket - 1];
        lastAt[bucket] = lastAt[bucket - 1];
      }
    }

    return MasonryLayout._(
      cells: cells,
      extent: extent,
      columnWidth: width,
      bucketSize: bucketSize,
      firstAt: firstAt,
      lastAt: lastAt,
    );
  }
}
