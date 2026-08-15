/// Las dos maneras en las que un contenido sale de la base de datos.
///
/// Las dos avisan antes de borrar y las dos dejan elegir si el fichero se va con
/// la fila; en lo que se diferencian es en con qué valor sale marcada esa
/// casilla la primera vez, porque no significan lo mismo: vaciar la papelera es
/// el final de un contenido que ya se había marcado, mientras que descartar al
/// importar es no querer una fila que acaba de nacer del propio fichero.
enum MediaDeletionKind {
  /// Borrado definitivo de la papelera, a mano o por caducidad.
  trash(deletesFiles: true),

  /// Descarte de lo que está pendiente de revisar, desde importación o desde el
  /// visor.
  discard(deletesFiles: false);

  const MediaDeletionKind({required this.deletesFiles});

  /// Si de fábrica este borrado se lleva el fichero del disco. A partir de la
  /// primera vez manda lo que el usuario dejara marcado.
  final bool deletesFiles;
}
