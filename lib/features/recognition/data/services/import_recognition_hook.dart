import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:flutter/foundation.dart';

/// Si el reconocimiento automático al importar está encendido.
typedef RecognizeOnImportSetting = bool Function();

/// Manda a reconocer lo que acaba de importarse, agrupado.
///
/// Una importación no llega de golpe: va soltando ficheros de uno en uno durante
/// minutos. Reconocer cada uno según nace llenaría la lista de tareas con
/// trescientas entradas de un segundo y pondría al equipo a saltar entre la
/// descarga y la inferencia. Aquí se acumula lo que va llegando y se manda de
/// una vez cuando la importación se calma, que es lo que el usuario entiende
/// como «reconocer lo que acaba de llegar».
///
/// Hay además un tope: sin él, una importación de miles de ficheros que dure
/// media hora no reconocería nada hasta el final, y no habría nada que revisar
/// mientras tanto.
///
/// El ajuste se consulta **al mandar**, no al acumular: entre que llega el
/// primer fichero y sale el trabajo pueden pasar minutos, y lo que vale es lo
/// que el usuario quiere ahora.
class ImportRecognitionHook {
  final RecognitionLauncher _launcher;
  final RecognizeOnImportSetting _isEnabled;

  /// Cómo se llama el trabajo en la lista de tareas.
  final String Function() _name;

  /// Cuánto se espera desde el último contenido antes de mandar.
  final Duration _wait;

  /// Cuántos se dejan acumular antes de mandar sin esperar más.
  final int _batchMax;

  final Set<int> _pending = {};
  Timer? _timer;

  ImportRecognitionHook({
    required RecognitionLauncher launcher,
    required RecognizeOnImportSetting isEnabled,
    required String Function() name,
    Duration wait = recognitionImportDebounce,
    int batchMax = recognitionImportBatchMax,
  })  : _launcher = launcher,
        _isEnabled = isEnabled,
        _name = name,
        _wait = wait,
        _batchMax = batchMax;

  /// Cuántos hay esperando a salir. Para pruebas y diagnóstico.
  @visibleForTesting
  int get pendingCount => _pending.length;

  /// Ha nacido un contenido.
  ///
  /// Se llama desde el alta, que es el único sitio por el que pasan todos: el
  /// escaneo del equipo, las plataformas remotas y el navegador acaban los tres
  /// ahí, y engancharlo en cada uno sería tres sitios donde olvidarse.
  void mediaArrived(int mediaId) {
    // Con el ajuste apagado no se acumula nada. Guardarlos por si acaso lo
    // encienden a mitad de importación sería mandar a reconocer cosas que
    // llegaron cuando había dicho que no.
    if (!_isEnabled()) return;

    _pending.add(mediaId);

    if (_pending.length >= _batchMax) {
      unawaited(flush());

      return;
    }

    _timer?.cancel();
    _timer = Timer(_wait, () => unawaited(flush()));
  }

  /// Manda lo acumulado ahora mismo, sin esperar.
  ///
  /// Se vacía **antes** de encolar: encolar puede tardar, y lo que llegue
  /// mientras tanto pertenece a la tanda siguiente, no a ésta.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;

    if (_pending.isEmpty) return;

    final batch = _pending.toList();
    _pending.clear();

    // Y aquí otra vez: apagarlo mientras se acumulaba tiene que servir de algo.
    if (!_isEnabled()) return;

    // Prioridad baja: esto no lo ha pedido nadie. Un reconocimiento que el
    // usuario sí ha lanzado a mano está esperando una respuesta y tiene que
    // pasar por delante.
    await _launcher.request(
      batch,
      name: _name(),
      priority: JobPriority.low,
    );
  }

  /// Deja de esperar y tira lo acumulado. Se llama al cerrar.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pending.clear();
  }
}
