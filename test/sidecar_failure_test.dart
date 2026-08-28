// Cómo se traduce un fallo del entorno a algo que se pueda contar.
//
// Lo que llega de `uv`, de Python o del sistema es un mensaje técnico y encima
// en el idioma del sistema, así que hay que reconocerlo en las dos formas. Lo
// que se prueba aquí es que cada caso cae donde debe: si el de los ficheros
// ocupados se confundiera con el del antivirus, al usuario se le diría que
// toque la configuración del antivirus cuando lo único que hace falta es cerrar
// la aplicación.

import 'package:Fern/features/recognition/data/services/sidecar_failure.dart';
import 'package:flutter_test/flutter_test.dart';

SidecarFailureKind kindOf(String message) =>
    SidecarFailure.from(Exception(message)).kind;

void main() {
  group('ficheros en uso', () {
    test('el fallo real que dio uv al cambiar a la tarjeta gráfica', () {
      // Copiado tal cual de la ejecución que lo destapó: el sidecar seguía en
      // marcha y `uv venv` no podía borrar la carpeta desde la que corría.
      const message = '''
UvBootstrapException: uv venv failed (1): Using CPython 3.12.8
Creating virtual environment at: C:\\Users\\x\\Documents\\FeRN\\recognition\\runtime\\venv
uv::venv::creation

  x Failed to create virtualenv
  |-> failed to remove directory
      `C:\\Users\\x\\Documents\\FeRN\\recognition\\runtime\\venv`: Acceso
      denegado. (os error 5)
''';

      expect(kindOf(message), SidecarFailureKind.filesInUse);
    });

    test('el mismo fallo con el sistema en inglés', () {
      expect(
        kindOf('failed to remove directory: Access is denied. (os error 5)'),
        SidecarFailureKind.filesInUse,
      );
    });

    test('un fichero que otro programa tiene abierto', () {
      expect(
        kindOf('The process cannot access the file because it is being used '
            'by another process. (os error 32)'),
        SidecarFailureKind.filesInUse,
      );
    });
  });

  test('sin espacio en el disco', () {
    expect(
      kindOf('failed to write: No space left on device'),
      SidecarFailureKind.notEnoughSpace,
    );
    expect(
      kindOf('No hay espacio en disco suficiente'),
      SidecarFailureKind.notEnoughSpace,
    );
  });

  test('problemas de red', () {
    expect(
      kindOf('SocketException: Failed host lookup: github.com'),
      SidecarFailureKind.network,
    );
    expect(
      kindOf('Could not download uv: connection timed out'),
      SidecarFailureKind.network,
    );
    expect(
      kindOf('UvBootstrapException: https://... answered 404'),
      SidecarFailureKind.network,
    );
  });

  test('el sistema no deja ejecutar lo descargado', () {
    expect(
      kindOf('ProcessException: Operation not permitted'),
      SidecarFailureKind.blocked,
    );
  });

  test('falta una pieza', () {
    expect(
      kindOf('uv.exe was not inside the downloaded archive'),
      SidecarFailureKind.missingPiece,
    );
  });

  test('lo que no se reconoce se admite como desconocido', () {
    expect(
      kindOf('algo rarísimo ha pasado'),
      SidecarFailureKind.unknown,
    );
  });

  test('el detalle técnico se conserva para el registro', () {
    final failure = SidecarFailure.from(Exception('os error 5: acceso denegado'));

    expect(failure.kind, SidecarFailureKind.filesInUse);
    expect(failure.detail, contains('os error 5'));
  });

  test('los que se arreglan reintentando se distinguen del resto', () {
    expect(
      SidecarFailure.from(Exception('os error 5')).isRecoverableByRetry,
      isTrue,
    );
    expect(
      SidecarFailure.from(Exception('No space left on device'))
          .isRecoverableByRetry,
      isFalse,
    );
  });
}
