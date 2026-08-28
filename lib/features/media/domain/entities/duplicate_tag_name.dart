/// Se ha intentado guardar una etiqueta con un nombre que ya tiene otra.
///
/// **Los nombres de etiqueta son únicos.** Dos etiquetas llamadas igual no se
/// pueden distinguir en el menú, ni en el buscador, ni al arrastrarles
/// contenido encima: quien las ve no tiene forma de saber cuál es cuál, y
/// quien las creó tampoco.
///
/// Se compara sin distinguir mayúsculas y sin los espacios de los extremos: si
/// «Paisajes» ya existe, «paisajes » es la misma etiqueta escrita de otra
/// manera, no una nueva.
class DuplicateTagNameException implements Exception {
  /// El nombre que ya estaba cogido, tal y como lo escribió quien lo intentó.
  final String name;

  const DuplicateTagNameException(this.name);

  @override
  String toString() => 'DuplicateTagNameException: $name';
}
