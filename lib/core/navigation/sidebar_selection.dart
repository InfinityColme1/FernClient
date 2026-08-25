/// Qué botón del menú lateral se ve marcado.
///
/// Antes lo decidía sólo el último clic, y por eso navegar por código —una
/// notificación que lleva a importación, el aviso de repetidos, volver atrás—
/// dejaba el menú señalando la pantalla anterior. Manda la dirección.
///
/// Con una excepción: las etiquetas. Filtrar por una no cambia de pantalla, así
/// que la dirección no puede contarlo y lo que vale es lo que se pulsó. Por eso
/// se pasa además [tappedLocation], la pantalla en la que se estaba al
/// pulsarlo: mientras se siga en ella lo pulsado manda, y en cuanto se cambia
/// de pantalla —por donde sea— vuelve a mandar la dirección.
///
/// [ids] son los botones que hay, y para los de pantalla el identificador **es**
/// su ruta. Se compara por prefijo para que las direcciones con algo detrás
/// (`/media/7`) marquen igualmente su botón, y gana la más larga: si no,
/// cualquier ruta marcaría la raíz.
String? sidebarSelectedId({
  required String location,
  required List<String> ids,
  String? tapped,
  String? tappedLocation,
}) {
  if (tapped != null && ids.contains(tapped) && tappedLocation == location) {
    return tapped;
  }

  String? best;

  for (final id in ids) {
    if (!_covers(id, location)) continue;
    if (best == null || id.length > best.length) best = id;
  }

  return best;
}

/// Si el botón [id] es el de la pantalla [location].
bool _covers(String id, String location) {
  // Los que no son rutas (las etiquetas, que van con su propio prefijo) no
  // pueden ser la pantalla en la que se está.
  if (!id.startsWith('/')) return false;
  if (id == location) return true;

  // `/media` cubre `/media/7`, pero no `/mediateca`.
  return location.startsWith(id.endsWith('/') ? id : '$id/');
}
