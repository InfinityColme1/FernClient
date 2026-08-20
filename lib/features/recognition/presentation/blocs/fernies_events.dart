abstract class FerniesEvents {
  const FerniesEvents();
}

/// Vuelve a leer los fernies de la base de datos.
///
/// Lo pide la pantalla de fernies al entrar y cualquiera que cree, edite o borre
/// uno, para que el cambio se vea sin reiniciar. Es el mismo trato que se le da
/// a las etiquetas y a los creadores.
class LoadFerniesEvent extends FerniesEvents {
  const LoadFerniesEvent();
}

/// Elige un fernie y pide sus regiones para la rejilla.
class FernieSelectedEvent extends FerniesEvents {
  final int fernieId;

  const FernieSelectedEvent(this.fernieId);
}

/// Vuelve a leer las regiones del fernie elegido, sin tocar la lista.
///
/// Es lo que hace falta después de borrar regiones desde la ficha: la lista de
/// fernies cambia sólo en el recuento, pero la rejilla cambia entera.
class ReloadFernieRegionsEvent extends FerniesEvents {
  const ReloadFernieRegionsEvent();
}

/// Marca o desmarca una región de la rejilla.
/// Marca o desmarca una región y, con ella, las de su tramo.
///
/// Es lo que necesita una celda de la rejilla que agrupa fotogramas seguidos de
/// un vídeo: agrupar es cosa de la interfaz, pero para quien selecciona o borra
/// siguen siendo todas las regiones que son, y dejar fuera a las demás dejaría
/// medio tramo suelto al borrar.
class ToggleRegionSelectionEvent extends FerniesEvents {
  final int regionId;

  /// Las demás regiones del mismo tramo, que siguen a [regionId].
  final List<int> alsoRegionIds;

  const ToggleRegionSelectionEvent(
    this.regionId, {
    this.alsoRegionIds = const [],
  });
}

/// Estira la selección hasta la celda pulsada, desde la última con la que se
/// hizo algo.
///
/// Es mayúsculas + clic, el mismo gesto que en la rejilla de contenido. Va por
/// celdas y no por regiones porque es lo que se ve: una celda que agrupa un
/// tramo de vídeo entra entera o no entra.
class SelectRegionRangeEvent extends FerniesEvents {
  /// Las regiones de la celda pulsada.
  final List<int> regionIds;

  /// Las celdas de la rejilla en el orden exacto en el que se ven, cada una con
  /// sus regiones. Lo pone la pantalla: el bloc no sabe cómo se han agrupado.
  final List<List<int>> orderedCells;

  const SelectRegionRangeEvent({
    required this.regionIds,
    required this.orderedCells,
  });
}

class ClearRegionSelectionEvent extends FerniesEvents {
  const ClearRegionSelectionEvent();
}

/// Borra las regiones marcadas en la rejilla. El fernie se queda con las demás.
class DeleteSelectedRegionsEvent extends FerniesEvents {
  const DeleteSelectedRegionsEvent();
}
