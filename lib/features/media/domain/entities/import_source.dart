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
  reddit(id: 'reddit', isRemote: true, label: 'Reddit'),

  /// Obras marcadas en la cuenta de Pixiv del usuario, tanto las públicas como
  /// las privadas.
  pixiv(id: 'pixiv', isRemote: true, label: 'Pixiv'),

  /// Contenido que el usuario ha traído desde el navegador de la aplicación:
  /// una página cualquiera de internet de la que se ha sacado lo que enseñaba.
  ///
  /// No se escanea ni se configura, así que no está ni en [scannable] ni en
  /// [remote]: no se le puede pedir nada, es el usuario quien lo trae página a
  /// página. Sí está en [listed], porque lo que ha traído hay que poder verlo y
  /// filtrarlo como lo de cualquier otra fuente.
  browser(id: 'browser');

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
    ImportSource.pixiv,
  ];

  /// Las fuentes que se enseñan al elegir de dónde se está viendo o trayendo
  /// contenido: las que se pueden escanear y, además, las que llenan la
  /// biblioteca por otro camino.
  ///
  /// No es lo mismo que [scannable]: del navegador hay contenido que ver y que
  /// filtrar, pero no hay nada que pedirle.
  static const List<ImportSource> listed = [
    ...scannable,
    ImportSource.browser,
  ];

  /// Todas las fuentes de las que puede haber contenido guardado. Es con lo que
  /// arranca el filtro por fuente de la pantalla de media: de partida se ve
  /// todo.
  static const Set<ImportSource> allSources = {
    ImportSource.local,
    ImportSource.reddit,
    ImportSource.pixiv,
    ImportSource.browser,
  };

  /// Las fuentes remotas, las que necesitan configuración para poder usarse.
  static const List<ImportSource> remote = [
    ImportSource.reddit,
    ImportSource.pixiv,
  ];

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
