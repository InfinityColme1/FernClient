import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Lo que mide un contenido, tal y como se guarda.
typedef MediaSize = ({int width, int height});

/// Quien sabe escribirlo en la base de datos. Lo pone el arranque.
typedef MediaSizeWriter = Future<void> Function(Map<int, MediaSize> sizes);

/// Apunta lo que mide cada contenido según se va descubriendo.
///
/// La rejilla necesita las proporciones de cada celda para colocarla, y
/// averiguarlas obliga a cargar el fichero entero en memoria para leerle la
/// cabecera. Eso se paga **una vez por contenido y para siempre** si se guarda;
/// sin guardarlo se pagaba en cada arranque, mil trescientas veces, y era lo que
/// hacía que desplazarse deprisa fuera a tirones.
///
/// Lo que entra por aquí es lo que la rejilla ha tenido que descubrir por su
/// cuenta: contenido que se dio de alta antes de que esto existiera. Lo nuevo ya
/// nace con su tamaño puesto.
///
/// Las escrituras van **en tandas**: al desplazarse se descubren decenas por
/// segundo, y una transacción por cada una sería peor que el problema que
/// resuelve.
class MediaSizeStore {
  MediaSizeStore._();

  static final MediaSizeStore instance = MediaSizeStore._();

  /// Quien escribe de verdad. Sin él, esto no hace nada: es lo que pasa en las
  /// pruebas de widget, que no tienen base de datos detrás.
  MediaSizeWriter? writer;

  final Map<int, MediaSize> _pending = {};
  Timer? _timer;

  /// Apunta lo que mide un contenido. Se escribirá con los demás.
  void remember(int mediaId, {required int width, required int height}) {
    if (width <= 0 || height <= 0) return;

    _pending[mediaId] = (width: width, height: height);

    // Cuando se junta una tanda entera no se espera al reloj: al desplazarse
    // deprisa se llena en un momento, y dejarla crecer sin escribir sería
    // guardar toda la biblioteca en memoria.
    if (_pending.length >= mediaSizeBatchSize) {
      unawaited(flush());
      return;
    }

    _timer ??= Timer(mediaSizeBatchDelay, () => unawaited(flush()));
  }

  /// Escribe lo que haya apuntado.
  ///
  /// Que falle no puede romper nada: lo único que se pierde es haberlo guardado,
  /// y la próxima vez que se pinte esa celda se vuelve a descubrir.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;

    if (_pending.isEmpty) return;

    final batch = Map<int, MediaSize>.from(_pending);
    _pending.clear();

    try {
      await writer?.call(batch);
    } on Object catch (error) {
      debugPrint('No se pudo guardar el tamaño de ${batch.length}: $error');
    }
  }

  /// Para las pruebas: deja el almacén como recién creado.
  @visibleForTesting
  void reset() {
    _timer?.cancel();
    _timer = null;
    _pending.clear();
    writer = null;
  }

  /// Cuántos hay apuntados sin escribir.
  @visibleForTesting
  int get pendingCount => _pending.length;
}
