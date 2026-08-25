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
      // La ruta va entre comillas dentro del mismo argumento: `explorer.exe`
      // no entiende `/select` y la ruta como dos argumentos sueltos, y sin
      // comillas se pierde en cuanto la carpeta lleva un espacio.
      //
      // Y no se mira el código de salida: `explorer.exe` devuelve 1 aun
      // habiendo abierto la ventana. Lo que se comprueba antes es lo que se
      // puede comprobar —que el fichero está—; a partir de ahí, o abre o no,
      // pero decir que ha fallado cuando ha funcionado sería peor.
      await Process.run(
        'explorer.exe',
        ['/select,"${File(path).absolute.path}"'],
      );

      return true;
    } on Object catch (error) {
      debugPrint('FileExplorerService: no se pudo abrir "$path": $error');

      return false;
    }
  }
}
