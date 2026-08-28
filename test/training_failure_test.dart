// Lo que dijo el sidecar, traducido a algo que diga que hacer.
//
// Lo que importa aqui es el **orden de las comprobaciones**: los mensajes se
// solapan —el de quedarse sin memoria menciona «cuda», el del dataset menciona
// «dataset», y el de un fallo cualquiera puede mencionar las dos— y colocar una
// regla antes que otra cambia el consejo que se le da al usuario.

import 'package:Fern/features/recognition/domain/services/training_failure.dart';
import 'package:flutter_test/flutter_test.dart';

TrainingFailureKind kindOf(String error) => TrainingFailure.from(error).kind;

void main() {
  test('el motor parado se reconoce por sus dos formas', () {
    expect(
      kindOf('SidecarException(SIDECAR_NOT_READY): The sidecar stopped while '
          'the request was in flight'),
      TrainingFailureKind.engineStopped,
    );

    expect(
      kindOf('Exception: The sidecar is not running'),
      TrainingFailureKind.engineStopped,
    );
  });

  test('quedarse sin memoria, tambien en castellano', () {
    expect(kindOf('OUT_OF_MEMORY'), TrainingFailureKind.outOfMemory);
    expect(
      kindOf('RuntimeError: CUDA error: out of memory'),
      TrainingFailureKind.outOfMemory,
    );
    expect(
      kindOf('El proceso se quedo sin memoria'),
      TrainingFailureKind.outOfMemory,
    );
  });

  test('el disco lleno no se confunde con la memoria', () {
    // Son dos «no cabe» distintos y el consejo es distinto: uno se arregla
    // bajando el lote y el otro haciendo sitio.
    expect(
      kindOf('FileSystemException: No space left on device'),
      TrainingFailureKind.notEnoughSpace,
    );
  });

  test('el material que ya no esta', () {
    expect(
      kindOf('SidecarException(DATASET_INVALID): No data.yaml at C:/x'),
      TrainingFailureKind.datasetInvalid,
    );
  });

  test('los pesos que faltan', () {
    expect(
      kindOf('SidecarException(MODEL_NOT_FOUND): No weights at yolo11n.pt'),
      TrainingFailureKind.weightsMissing,
    );
  });

  test('lo que no se reconoce se queda como desconocido', () {
    expect(kindOf('Algo rarisimo del 2031'), TrainingFailureKind.unknown);
    expect(kindOf(''), TrainingFailureKind.unknown);
  });

  group('el orden importa', () {
    test('un fallo de memoria que menciona el dataset sigue siendo de memoria',
        () {
      // Pasa de verdad: la traza de PyTorch al quedarse sin memoria menciona el
      // cargador de datos. Decirle al usuario que revise sus ficheros seria
      // mandarle a buscar donde no hay nada.
      expect(
        kindOf('CUDA out of memory while loading the dataset'),
        TrainingFailureKind.outOfMemory,
      );
    });

    test('el disco lleno gana al dataset', () {
      expect(
        kindOf('No space left on device writing the dataset'),
        TrainingFailureKind.notEnoughSpace,
      );
    });
  });

  group('el detalle tecnico', () {
    test('se guarda siempre', () {
      const raw = 'SidecarException(OUT_OF_MEMORY): sin memoria';

      expect(TrainingFailure.from(raw).detail, raw);
    });

    test('solo se enseña cuando no hay nada mejor que decir', () {
      // En los casos conocidos la frase ya dice que hacer, y añadir la traza
      // solo asusta.
      expect(TrainingFailure.from('OUT_OF_MEMORY').showsDetail, isFalse);
      expect(TrainingFailure.from('vete a saber').showsDetail, isTrue);
    });
  });
}
