import 'package:Fern/features/media/domain/services/grid_return_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  final int itemCount;

  /// A qué posición hay que ir. `null` si no hay que ir a ninguna, que es lo
  /// normal: sólo se vuelve del visor de vez en cuando.
  final int? focusIndex;

  /// La celda número [index]. La que toca centrar recibe [key]: es con lo que
  /// se sabe dónde ha caído de verdad, si ha llegado a construirse.
  final Widget Function(BuildContext context, int index, Key? key) itemBuilder;

  const ReturningMasonryGrid({
    super.key,
    required this.columns,
    required this.padding,
    required this.cacheExtent,
    required this.spacing,
    required this.itemCount,
    required this.itemBuilder,
    this.focusIndex,
  });

  @override
  State<ReturningMasonryGrid> createState() => _ReturningMasonryGridState();
}

class _ReturningMasonryGridState extends State<ReturningMasonryGrid> {
  final _controller = ScrollController();
  final _focusKey = GlobalKey();

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

  Future<void> _returnTo(int index) async {
    if (!mounted || !_controller.hasClients) return;

    final position = _controller.position;
    _controller.jumpTo(gridReturnOffset(
      index: index,
      count: widget.itemCount,
      maxScrollExtent: position.maxScrollExtent,
      viewportHeight: position.viewportDimension,
    ));

    // Y se afina. Lo de arriba es una estimación por la posición en la lista: en
    // una rejilla de mampostería cada celda tiene el alto que le toca, y la
    // cuenta se desvía tanto como se desvíen las proporciones. Después del
    // salto, si la celda se ha llegado a construir, ya se sabe dónde cae de
    // verdad y se corrige.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final cell = _focusKey.currentContext;
    if (cell == null) return;

    await Scrollable.ensureVisible(cell, alignment: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      controller: _controller,
      padding: widget.padding,
      cacheExtent: widget.cacheExtent,
      crossAxisCount: widget.columns,
      mainAxisSpacing: widget.spacing,
      crossAxisSpacing: widget.spacing,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => widget.itemBuilder(
        context,
        index,
        index == widget.focusIndex ? _focusKey : null,
      ),
    );
  }
}
