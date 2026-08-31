// Qué rueda de PyTorch se instala para cada tarjeta.
//
// Esto existe por un fallo que no daba la cara donde estaba. Se instalaba
// siempre `cu124`, que no se compiló para Blackwell (las tarjetas de la serie
// 50, `sm_120`): torch se instalaba, arrancaba, decía que había CUDA y cogía la
// tarjeta. Lo que fallaba era el primer kernel, ya reconociendo, con un «no
// kernel image is available for execution on the device» que ni el instalador ni
// el panel de configuración veían, porque tarjeta y controlador **sí** están.
//
// Se prueba sin tarjeta delante a propósito: lo que decide qué se instala no
// puede depender de la máquina en la que se ejecuten las pruebas.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('la capacidad que dice nvidia-smi', () {
    test('una tarjeta, su número', () {
      expect(highestComputeCapability('12.0\n'), 12.0);
    });

    test('sin salto de línea al final tampoco se pierde', () {
      expect(highestComputeCapability('8.9'), 8.9);
    });

    // La rueda tiene que servir para la que se vaya a usar, y una más moderna
    // sigue valiendo para las antiguas.
    test('con varias, la más capaz', () {
      expect(highestComputeCapability('8.6\n12.0\n7.5\n'), 12.0);
    });

    test('los espacios de los extremos no estorban', () {
      expect(highestComputeCapability('  12.0  \n'), 12.0);
    });

    // Los controladores viejos no conocen la consulta y contestan con un error o
    // con un texto que no es un número.
    test('lo que no es un número no cuenta', () {
      expect(highestComputeCapability('N/A\n'), isNull);
      expect(highestComputeCapability(''), isNull);
      expect(
        highestComputeCapability('Failed to query compute_cap'),
        isNull,
      );
    });

    test('y una línea buena entre basura se recoge igual', () {
      expect(highestComputeCapability('N/A\n8.6\n'), 8.6);
    });
  });

  group('la rueda que le toca', () {
    test('Blackwell necesita la de CUDA 12.8', () {
      // Una RTX 5060 es `sm_120`.
      expect(torchCudaIndexUrlFor(12.0), torchCuda128IndexUrl);
    });

    test('y lo que venga después, también', () {
      expect(torchCudaIndexUrlFor(12.8), torchCuda128IndexUrl);
    });

    test('lo anterior se queda con la de siempre, que pesa menos', () {
      for (final capability in [6.1, 7.5, 8.6, 8.9, 9.0]) {
        expect(
          torchCudaIndexUrlFor(capability),
          torchCudaIndexUrl,
          reason: 'sm_$capability',
        );
      }
    });

    // Equivocarse hacia atrás deja el reconocimiento lento pero funcionando;
    // hacia delante lo deja sin funcionar. Sin saber, se elige lo primero.
    test('sin saber cuál es, la de siempre', () {
      expect(torchCudaIndexUrlFor(null), torchCudaIndexUrl);
    });

    test('las dos ruedas son índices distintos de verdad', () {
      expect(torchCuda128IndexUrl, isNot(torchCudaIndexUrl));
      expect(torchCuda128IndexUrl, contains('cu128'));
      expect(torchCudaIndexUrl, contains('cu124'));
    });
  });
}
