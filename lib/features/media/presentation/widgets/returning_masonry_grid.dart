import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/masonry_layout.dart';
import 'package:flutter/material.dart';

/// La rejilla de contenido, con la vuelta del visor.
///
/// Al salir del visor la rejilla se queda donde se dejó, y con unos cientos de
/// miniaturas eso es perder el sitio. Esto la lleva hasta lo que se acaba de
/// mirar y lo deja a media altura.
///
/// Va aparte y con estado para no convertir `MediaGrid` entera en un widget con
/// estado: lo único que cambia aquí es a qué altura está el scroll, y rehacer
/// por eso las trescientas celdas de debajo sería el repintado más caro de la
/// aplicación.
///
/// El salto se da **una vez por celda**: repintar la rejilla —porque se marque
/// algo, porque llegue contenido nuevo— no puede arrastrar al usuario de vuelta
/// a donde estaba mirando hace rato.
class ReturningMasonryGrid extends StatefulWidget {
  final int columns;
  final EdgeInsets padding;
  final double cacheExtent;
  final double spacing;

  /// Ancho partido por alto de cada celda, en orden. `null` en las que todavía
  /// no se sepa.
  ///
  /// Es lo que permite calcular la rejilla entera antes de pintarla, y con ello
  /// que la barra de desplazamiento deje de moverse sola.
  final List<double?> ratios;

  final double fallbackRatio;

  /// A qué posición hay que ir. `null` si no hay que ir a ninguna, que es lo
  /// normal: sólo se vuelve del visor de vez en cuando.
  final int? focusIndex;

  final Widget Function(BuildContext context, int index) itemBuilder;

  const ReturningMasonryGrid({
    super.key,
    required this.columns,
    required this.padding,
    required this.cacheExtent,
    required this.spacing,
    required this.ratios,
    required this.itemBuilder,
    required this.fallbackRatio,
    this.focusIndex,
  });

  @override
  State<ReturningMasonryGrid> createState() => _ReturningMasonryGridState();
}

class _ReturningMasonryGridState extends State<ReturningMasonryGrid> {
  final _controller = ScrollController();

  /// Las cuentas de la rejilla, según las va haciendo.
  MasonryLayout _layout = MasonryLayout.empty;

  /// A qué celda se ha ido ya.
  int? _honoured;

  @override
  void initState() {
    super.initState();
    _scheduleReturn();
  }

  @override
  void didUpdateWidget(ReturningMasonryGrid old) {
    super.didUpdateWidget(old);
    _scheduleReturn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleReturn() {
    final index = widget.focusIndex;
    if (index == null || index == _honoured) return;

    _honoured = index;
    WidgetsBinding.instance.addPostFrameCallback((_) => _returnTo(index));
  }

  /// Lleva la rejilla hasta la celda [index] y la deja a media altura.
  ///
  /// **Exacto y de un salto.** Antes esto era una estimación por la posición en
  /// la lista, y luego un afinado con la celda de verdad si había llegado a
  /// construirse: en una rejilla de mampostería cada celda tiene el alto que le
  /// toca y la cuenta se desviaba tanto como se desviaran las proporciones.
  /// Ahora la rejilla está calculada entera, así que dónde cae una celda es un
  /// dato, no una aproximación.
  void _returnTo(int index) {
    if (!mounted || !_controller.hasClients || _layout.isEmpty) return;

    _controller.jumpTo(_layout.offsetToCentre(
      index,
      _controller.position.viewportDimension,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Mientras la rejilla va lanzada, las celdas no empiezan a cargar nada: se
    // pedirían cientos de miniaturas que no da tiempo a enseñar, y ese trabajo
    // se lo quitan a las que sí se van a quedar delante.
    return FastScrollDetector(
      child: FernMasonryGrid(
        controller: _controller,
        padding: widget.padding,
        cacheExtent: widget.cacheExtent,
        columns: widget.columns,
        spacing: widget.spacing,
        ratios: widget.ratios,
        fallbackRatio: widget.fallbackRatio,
        onLayout: (layout) => _layout = layout,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}
