import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';

/// Marcas al borde del scroll que dicen a qué altura está lo señalado.
///
/// Sin ellas, un aviso que lleva a una rejilla de trescientas miniaturas señala
/// unas cuantas que casi siempre están fuera de la pantalla: el usuario ve un
/// contador, llega, y no encuentra nada. Las marcas convierten «hay algo tuyo
/// aquí» en «está por aquí abajo».
///
/// La altura de cada marca sale de **la posición del contenido en la lista**, no
/// de dónde cae de verdad en el lienzo. En una rejilla de mampostería lo segundo
/// exigiría medir cada celda antes de pintar ninguna; lo primero se acerca lo
/// suficiente para lo que esto tiene que hacer, que es decir hacia dónde
/// desplazarse.
class HighlightScrollMarks extends StatelessWidget {
  /// Los contenidos de la rejilla, en el orden en que se pintan.
  final List<int> orderedIds;

  /// Cuáles de ellos están señalados.
  final Set<int> highlighted;

  const HighlightScrollMarks({
    super.key,
    required this.orderedIds,
    required this.highlighted,
  });

  /// A qué altura, de 0 a 1, va cada marca.
  ///
  /// Público sólo para poder comprobarlo: el reparto de las marcas es lo único
  /// que puede salir mal aquí, y pintarlas para medirlas después sería probar el
  /// renderizado de Flutter en vez de esta cuenta.
  @visibleForTesting
  List<double> get positionsForTest => _positions;

  List<double> get _positions {
    if (orderedIds.isEmpty || highlighted.isEmpty) return const [];

    final marks = <double>[];

    for (var index = 0; index < orderedIds.length; index++) {
      if (!highlighted.contains(orderedIds[index])) continue;

      marks.add(index / orderedIds.length);
    }

    return marks;
  }

  @override
  Widget build(BuildContext context) {
    final positions = _positions;
    if (positions.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: highlightMarkWidth,
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              for (final position in positions)
                Positioned(
                  top: position * constraints.maxHeight,
                  right: 0,
                  child: Container(
                    width: highlightMarkWidth,
                    height: highlightMarkHeight,
                    decoration: BoxDecoration(
                      color: context.colors.terciary,
                      borderRadius: BorderRadius.circular(highlightMarkWidth),
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
