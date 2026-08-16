import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';

/// Deja varias descargas en marcha a la vez.
///
/// Una importación se pasa casi todo el tiempo esperando a que lleguen ficheros
/// por la red, y esa espera no ocupa nada: mientras uno baja se pueden estar
/// bajando otros. Lo que no puede es no tener fin, o se acaba castigando tanto
/// a la conexión como al sitio del que se descarga; por eso hay un tope de
/// [limit] a la vez.
///
/// No sabe qué es lo que corre: recibe trabajos y los lanza. Quien los da
/// decide qué se puede solapar y qué no (traerse un fichero suelto, sí;
/// preguntarle algo al usuario, no).
class DownloadPool {
  final int limit;

  final _running = <Future<void>>{};

  DownloadPool({this.limit = maxParallelDownloads});

  /// Cuántos hay ahora mismo en marcha.
  int get running => _running.length;

  /// Pone un trabajo en marcha.
  ///
  /// Devuelve en cuanto ha arrancado, no cuando termina: es lo que permite
  /// seguir mirando la publicación siguiente mientras la anterior se descarga.
  /// Si ya hay [limit] en marcha, espera a que acabe alguno.
  ///
  /// Un trabajo que falla no tumba a los demás ni al que espera: se da por
  /// terminado y ya está.
  Future<void> add(Future<void> Function() task) async {
    while (_running.length >= limit) {
      await Future.any(_running);
    }

    // El trabajo arranca aquí mismo, no en el hueco siguiente: lo que se está
    // pidiendo es justamente que empiece ya y se siga con otra cosa.
    final Future<void> work;
    try {
      work = task().catchError((_) {});
    } on Exception {
      return;
    }

    _running.add(work);
    unawaited(work.whenComplete(() => _running.remove(work)));
  }

  /// Espera a que termine todo lo que quede en marcha.
  Future<void> drain() async {
    while (_running.isNotEmpty) {
      await Future.wait(_running.toList());
    }
  }
}
