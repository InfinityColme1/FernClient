// El porcentaje que enseña la instalación del entorno.
//
// Es aproximado a propósito: `uv` no dice por dónde va al instalar un paquete,
// así que lo único real es en qué etapa se está y, dentro de la descarga, cuánto
// lleva bajado. Lo que hay que sostener es que el número no retroceda ni se
// quede clavado en cero durante los minutos que dura instalar torch, que es lo
// que hace pensar que se ha colgado.

import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el avance no retrocede al pasar de etapa', () {
    var previous = -1.0;

    for (final stage in [
      SidecarSetupStage.downloadingUv,
      SidecarSetupStage.installingPython,
      SidecarSetupStage.creatingVenv,
      SidecarSetupStage.detectingHardware,
      SidecarSetupStage.installingTorch,
      SidecarSetupStage.installingUltralytics,
      SidecarSetupStage.cleaning,
      SidecarSetupStage.verifying,
      SidecarSetupStage.ready,
    ]) {
      final progress = SidecarSetupState(stage: stage).overallProgress;

      expect(
        progress,
        greaterThanOrEqualTo(previous),
        reason: 'la etapa ${stage.name} va hacia atrás',
      );
      previous = progress;
    }

    expect(previous, 1.0);
  });

  test('dentro de la descarga el avance sigue a los bytes', () {
    const stage = SidecarSetupStage.downloadingUv;
    final (start, end) = stage.span;

    final half = SidecarSetupState(
      stage: stage,
      received: 50,
      total: 100,
    ).overallProgress;

    expect(half, closeTo(start + (end - start) / 2, 0.001));
  });

  test('una etapa sin número se queda al principio de su tramo', () {
    // Instalar torch tarda minutos y no da progreso: la barra se queda donde
    // empieza su tramo, que es bastante más que cero, y el texto que rota es lo
    // que dice que se sigue trabajando.
    const state = SidecarSetupState(stage: SidecarSetupStage.installingTorch);

    expect(state.overallProgress, SidecarSetupStage.installingTorch.span.$1);
    expect(state.overallProgress, greaterThan(0.25));
    expect(state.downloadProgress, isNull);
  });

  test('las etapas que no están trabajando se reconocen como tales', () {
    expect(SidecarSetupStage.installingTorch.isWorking, isTrue);
    expect(SidecarSetupStage.ready.isWorking, isFalse);
    expect(SidecarSetupStage.error.isWorking, isFalse);
    expect(SidecarSetupStage.notInstalled.isWorking, isFalse);
  });
}
