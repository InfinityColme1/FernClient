import 'package:Fern/core/utils/grid_layout_cache.dart';
import 'package:Fern/core/utils/masonry_layout.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// La rejilla de mampostería de la aplicación.
///
/// Se diferencia de las de siempre en una cosa, y esa cosa lo cambia todo: **se
/// calcula entera antes de pintar nada**. Las perezosas no saben cuánto miden
/// hasta que las has recorrido, así que van estimando el total con la media de
/// lo que llevan colocado; esa estimación cambia con cada celda nueva, y con
/// ella cambian el tamaño y la posición de la barra de desplazamiento. Se
/// arrastra la barra hacia abajo y de pronto salta sola, porque debajo le han
/// movido la referencia.
///
/// Aquí el alto es exacto desde el primer fotograma. La barra deja de moverse
/// sola, y saber qué celdas hay a una altura concreta es una consulta —lo que
/// hace falta para cargar sólo lo que queda a la vista cuando se suelta la
/// barra—.
///
/// Sigue siendo perezosa: se calculan las **posiciones** de todas, que es
/// recorrer una lista, no se construye ninguna que no se vea.
class FernMasonryGrid extends StatefulWidget {
  /// Ancho partido por alto de cada celda, en orden. `null` en las que todavía
  /// no se sepa: entran con [fallbackRatio].
  final List<double?> ratios;

  final int columns;
  final double spacing;
  final EdgeInsets padding;
  final double cacheExtent;
  final double fallbackRatio;

  final ScrollController? controller;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Dónde buscar el reparto ya calculado, si lo hay.
  ///
  /// Sin ella se calcula cada vez, que es lo que hacía y lo que hacen las
  /// pruebas que montan la rejilla a pelo.
  final GridLayoutCache? cache;

  /// Se llama con la rejilla ya calculada, cada vez que cambia.
  ///
  /// Es por donde se entera quien necesita las cuentas: a qué altura está una
  /// celda concreta, o cuánto mide todo.
  final void Function(MasonryLayout layout)? onLayout;

  const FernMasonryGrid({
    super.key,
    required this.ratios,
    required this.columns,
    required this.spacing,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.cacheExtent = 0,
    this.fallbackRatio = 1,
    this.controller,
    this.onLayout,
    this.cache,
  });

  @override
  State<FernMasonryGrid> createState() => _FernMasonryGridState();
}

class _FernMasonryGridState extends State<FernMasonryGrid> {
  MasonryLayout _layout = MasonryLayout.empty;
  double _width = 0;

  /// Rehace las cuentas si han cambiado, y no en cada pintado.
  ///
  /// Colocar mil trescientas celdas es barato, pero se pintan sesenta veces por
  /// segundo mientras se desplaza: hacerlo cada vez sería justamente el trabajo
  /// que esta rejilla existe para quitar.
  void _measure(double width) {
    if (width == _width && widget.ratios.length == _layout.cells.length) return;

    _width = width;

    // Por la caché cuando la hay: el reparto de veinte mil celdas es el trozo
    // más grande del primer fotograma de una pantalla, y volviendo a la misma
    // lista es exactamente el mismo reparto.
    final cache = widget.cache;

    _layout = cache == null
        ? MasonryLayout.of(
            ratios: widget.ratios,
            columns: widget.columns,
            crossAxisExtent: width,
            spacing: widget.spacing,
            fallbackRatio: widget.fallbackRatio,
          )
        : cache.layoutOf(
            ratios: widget.ratios,
            columns: widget.columns,
            crossAxisExtent: width,
            spacing: widget.spacing,
            fallbackRatio: widget.fallbackRatio,
          );

    widget.onLayout?.call(_layout);
  }

  @override
  void didUpdateWidget(FernMasonryGrid old) {
    super.didUpdateWidget(old);

    // Lo que cambia el reparto: cuántas columnas hay, cuánto se separan y qué
    // proporción tiene cada celda. Lo último cambia cuando se descubre el
    // tamaño de un contenido que no lo tenía.
    if (old.columns != widget.columns ||
        old.spacing != widget.spacing ||
        old.fallbackRatio != widget.fallbackRatio ||
        !_sameRatios(old.ratios, widget.ratios)) {
      _width = 0;
    }
  }

  bool _sameRatios(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;

    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _measure(constraints.maxWidth - widget.padding.horizontal);

        return CustomScrollView(
          controller: widget.controller,
          cacheExtent: widget.cacheExtent,
          slivers: [
            SliverPadding(
              padding: widget.padding,
              sliver: SliverGrid(
                gridDelegate: _MasonryDelegate(_layout),
                delegate: SliverChildBuilderDelegate(
                  widget.itemBuilder,
                  childCount: _layout.cells.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Le da a la rejilla las posiciones ya calculadas.
class _MasonryDelegate extends SliverGridDelegate {
  final MasonryLayout layout;

  const _MasonryDelegate(this.layout);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) =>
      _MasonryGridLayout(layout);

  @override
  bool shouldRelayout(_MasonryDelegate old) => !identical(old.layout, layout);
}

class _MasonryGridLayout extends SliverGridLayout {
  final MasonryLayout layout;

  const _MasonryGridLayout(this.layout);

  @override
  double computeMaxScrollOffset(int childCount) => layout.extent;

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final cell = layout.cells[index];

    return SliverGridGeometry(
      scrollOffset: cell.top,
      crossAxisOffset: cell.left,
      mainAxisExtent: cell.height,
      crossAxisExtent: layout.columnWidth,
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) =>
      layout.firstVisibleAt(scrollOffset);

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) =>
      layout.lastVisibleAt(scrollOffset);
}
