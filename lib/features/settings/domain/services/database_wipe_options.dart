import 'package:equatable/equatable.dart';

/// Cuánto se lleva por delante el vaciado.
enum DatabaseWipeScope {
  /// Todo: la base de datos entera, como se ha hecho siempre.
  everything,

  /// Sólo el contenido no apto, y **nada más**: las etiquetas, los creadores,
  /// los fernies y los modelos se quedan.
  ///
  /// Es lo que hace útil poder elegir: dejar de tener guardado lo que no se
  /// quiere tener guardado no debería costar empezar la biblioteca de cero.
  nsfwOnly,
}

/// Qué se ha pedido vaciar y si se van también los ficheros.
///
/// Las dos cosas viajan juntas porque el segundo aviso —el de escribir la
/// frase— tiene que **decir lo que se eligió**: no es lo mismo confirmar que se
/// vacía una base de datos que confirmar que se borran mil ficheros del disco.
class DatabaseWipeOptions extends Equatable {
  final DatabaseWipeScope scope;

  /// Con `true` los ficheros del contenido se borran del disco.
  ///
  /// Apagado de fábrica, que es lo que esto ha hecho siempre: vaciar la base y
  /// dejar los ficheros donde estaban es reversible —un escaneo los vuelve a dar
  /// de alta— y borrarlos no.
  final bool deletesFiles;

  const DatabaseWipeOptions({
    this.scope = DatabaseWipeScope.everything,
    this.deletesFiles = false,
  });

  DatabaseWipeOptions copyWith({
    DatabaseWipeScope? scope,
    bool? deletesFiles,
  }) =>
      DatabaseWipeOptions(
        scope: scope ?? this.scope,
        deletesFiles: deletesFiles ?? this.deletesFiles,
      );

  /// Si esto deja la aplicación como recién instalada.
  bool get isEverything => scope == DatabaseWipeScope.everything;

  @override
  List<Object?> get props => [scope, deletesFiles];
}
