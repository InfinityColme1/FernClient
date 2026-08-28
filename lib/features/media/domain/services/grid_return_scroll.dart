import 'dart:math' as math;

/// A qué altura hay que dejar la rejilla para que el contenido que se acaba de
/// mirar quede en el centro de la pantalla.
///
/// Al salir del visor la rejilla estaba donde se dejó, no donde está lo que se
/// acaba de ver. Con unos cientos de miniaturas eso es perder el sitio: uno
/// mira algo, vuelve, y tiene que buscar de nuevo por dónde iba.
///
/// El sitio se **estima** por la posición en la lista y no se mide: en una
/// rejilla de mampostería cada celda tiene el alto que le toca, y saber dónde
/// cae de verdad la número mil exigiría montar las mil anteriores. Es la misma
/// cuenta que usan las marcas del scroll, y por el mismo motivo. Luego, si la
/// celda ha llegado a construirse, quien lo pinta afina.
///
/// [maxScrollExtent] y [viewportHeight] salen del scroll ya montado: el alto
/// total de lo que hay es la suma de los dos.
double gridReturnOffset({
  required int index,
  required int count,
  required double maxScrollExtent,
  required double viewportHeight,
}) {
  // Sin nada que recorrer, o con un índice que no es de esta lista, no hay a
  // dónde ir: quedarse donde se está es mejor que saltar a ninguna parte.
  if (count <= 0 || index < 0 || index >= count) return 0;
  if (maxScrollExtent <= 0) return 0;

  // El centro de la celda, y no su borde: con el borde, la fila que se busca
  // queda pegada al canto de la pantalla justo cuando se la está buscando.
  final position = (index + 0.5) / count * (maxScrollExtent + viewportHeight);

  return math.min(
    math.max(position - viewportHeight / 2, 0),
    maxScrollExtent,
  );
}
