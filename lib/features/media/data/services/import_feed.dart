import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';

/// Por dónde llega a la pantalla lo que va trayendo una importación.
///
/// Hace falta porque la importación se ha mudado a la cola de trabajos: la
/// recorre un runner, que no conoce a nadie, y la rejilla sigue teniendo que
/// pintar el contenido según llega. Esto es el cable entre los dos, una tubería
/// por trabajo.
///
/// Cada tubería es de **una sola escucha y con memoria**: el trabajo puede
/// arrancar antes de que la pantalla se suscriba, y con una de difusión lo que
/// hubiera llegado en ese hueco se perdería sin más.
class ImportFeed {
  final _runs = <String, StreamController<DataState<MediaSummaryEntity>>>{};

  StreamController<DataState<MediaSummaryEntity>> _of(String jobId) =>
      _runs.putIfAbsent(
        jobId,
        StreamController<DataState<MediaSummaryEntity>>.new,
      );

  /// Lo que trae el trabajo [jobId]. Termina cuando el trabajo termina.
  Stream<DataState<MediaSummaryEntity>> of(String jobId) => _of(jobId).stream;

  /// Un contenido más, o lo que haya pasado al ir a por él.
  void add(String jobId, DataState<MediaSummaryEntity> result) {
    final controller = _runs[jobId];
    if (controller == null || controller.isClosed) return;

    controller.add(result);
  }

  /// El trabajo ha terminado: se cierra su tubería para que quien la escuche
  /// sepa que no viene nada más.
  ///
  /// Si nadie llegó a escucharla, se tira: un controlador sin escuchar guarda
  /// lo emitido para siempre, y son contenidos enteros.
  Future<void> close(String jobId) async {
    final controller = _runs.remove(jobId);
    if (controller == null) return;

    await controller.close();
  }
}
