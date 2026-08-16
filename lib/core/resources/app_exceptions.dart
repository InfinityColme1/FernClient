/// Fallos que la aplicación distingue de un error cualquiera.
///
/// Llegan a la interfaz dentro de un `DataException`, que es lo que devuelven
/// los casos de uso: quien la lanza dice qué ha pasado y quien la recibe decide
/// cómo contarlo.
library;

/// Ya hay un creador que se llama así.
///
/// Los creadores se distinguen por el nombre (es lo único que se ve de ellos en
/// la lista y en el buscador), así que no puede haber dos iguales: ni al crear
/// uno nuevo ni al renombrar uno que ya existe.
class DuplicateCreatorNameException implements Exception {
  final String name;

  const DuplicateCreatorNameException(this.name);

  @override
  String toString() => "DuplicateCreatorNameException: $name";
}
