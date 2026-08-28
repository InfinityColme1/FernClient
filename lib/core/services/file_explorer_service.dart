import 'dart:io';

import 'package:flutter/foundation.dart';

/// Abre la carpeta de un fichero en el explorador del sistema, con el fichero
/// ya seleccionado.
///
/// **Seleccionado** es el requisito, y es lo que descarta `url_launcher` —que
/// ya está en el proyecto—: abre la carpeta, pero deja al usuario buscando su
/// fichero entre otros trescientos. En Windows eso lo hace `explorer.exe` con
/// `/select,`.
///
/// Es el primer sitio del proyecto donde se lanza un proceso, así que va
/// encapsulado aquí en lugar de suelto en un widget: el día que haya que
/// soportar otro sistema, se cambia una función.
class FileExplorerService {
  const FileExplorerService();

  /// `true` si esta plataforma sabe hacerlo.
  ///
  /// Con `false`, quien ofrezca el botón no debería enseñarlo: un botón que no
  /// hace nada es peor que su ausencia.
  bool get isSupported => Platform.isWindows;

  /// Enseña [path] en el explorador. Devuelve `false` si no se ha podido.
  ///
  /// Se comprueba que el fichero exista antes de lanzar nada: `explorer.exe`
  /// con una ruta que ya no está abre la carpeta de documentos sin decir por
  /// qué, y eso es más desconcertante que un aviso de que el fichero no está.
  Future<bool> reveal(String path) async {
    if (!isSupported) return false;
    if (!File(path).existsSync()) return false;

    try {
      // No se mira el código de salida: `explorer.exe` devuelve 1 aun habiendo
      // abierto la ventana. Lo que se comprueba antes es lo que se puede
      // comprobar —que el fichero está—; a partir de ahí, o abre o no, pero
      // decir que ha fallado cuando ha funcionado sería peor.
      await Process.run('explorer.exe', revealArguments(path));

      return true;
    } on Object catch (error) {
      debugPrint('FileExplorerService: no se pudo abrir "$path": $error');

      return false;
    }
  }

  /// Cómo se le pide a `explorer.exe` que abra la carpeta con el fichero ya
  /// seleccionado.
  ///
  /// **Un solo argumento y sin comillas dentro.** Es lo único que tiene truco
  /// aquí, y es lo que estaba mal: llevaba la ruta entrecomillada dentro del
  /// argumento, imitando lo que se escribiría en una consola. Pero Dart, en
  /// Windows, escapa por su cuenta cualquier argumento que lleve comillas —lo
  /// envuelve en comillas y escapa las de dentro con barras—, así que a
  /// `explorer.exe` le llegaba una ruta con barras y comillas de más. Y
  /// `explorer.exe` con una ruta que no entiende no protesta: abre la carpeta de
  /// documentos, que es justo lo que se veía.
  ///
  /// Sin comillas propias, Dart entrecomilla el argumento entero cuando la ruta
  /// lleva espacios, que es la forma que `explorer.exe` sí entiende.
  ///
  /// Aparte para poder comprobarlo: lanzar el proceso de verdad en una prueba
  /// seria abrir ventanas en la maquina de quien la ejecute.
  @visibleForTesting
  static List<String> revealArguments(String path) =>
      ['/select,${File(path).absolute.path}'];
}
