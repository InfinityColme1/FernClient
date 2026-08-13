/// De dónde sale el contenido que se importa.
///
/// Es a la vez lo que se elige en el desplegable de la pantalla de importación
/// y lo que se guarda en el sumario de cada contenido, así que la rejilla puede
/// enseñar sólo lo que ha venido de una fuente.
///
/// [all] no es una fuente: es la opción del desplegable que no filtra nada y
/// que, al escanear, recorre todas las demás. Nunca se guarda en la base de
/// datos.
enum ImportSource {
  all(id: 'all'),

  /// Ficheros que ya están en este equipo, los que recoge el escaneo de una
  /// carpeta.
  local(id: 'local'),

  /// Contenido guardado en la cuenta de Reddit del usuario, que la aplicación
  /// se descarga a este equipo.
  reddit(id: 'reddit', isRemote: true, label: 'Reddit');

  const ImportSource({
    required this.id,
    this.isRemote = false,
    this.label,
  });

  /// Identificador con el que se guarda en la base de datos y en las
  /// preferencias. No se traduce.
  final String id;

  /// El contenido no está en este equipo: hay que ir a buscarlo a una API y
  /// descargarlo. Cambia lo que la pantalla de importación deja hacer (no hay
  /// carpeta que elegir) y de dónde salen los ficheros.
  final bool isRemote;

  /// Nombre de la plataforma, para las que se llaman igual en todos los
  /// idiomas. `null` en las que la pantalla traduce.
  final String? label;

  /// Las fuentes que se pueden escanear, en el orden en el que se listan. [all]
  /// se queda fuera: no es una fuente, es todas.
  static const List<ImportSource> scannable = [
    ImportSource.local,
    ImportSource.reddit,
  ];

  /// Las fuentes remotas, las que necesitan configuración para poder usarse.
  static const List<ImportSource> remote = [ImportSource.reddit];

  /// Las fuentes que hay que recorrer al escanear con esta opción elegida:
  /// todas si es [all], y si no ella sola.
  List<ImportSource> get sources => this == ImportSource.all ? scannable : [this];

  static ImportSource fromId(String? id) {
    return ImportSource.values.firstWhere(
      (source) => source.id == id,
      orElse: () => ImportSource.local,
    );
  }
}
