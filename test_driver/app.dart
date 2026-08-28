// La aplicación de siempre, pero dejándose conducir desde fuera.
//
// Es la misma FeRN: no cambia nada de lo que hace ni de lo que se ve. Lo único
// que añade es la extensión de `flutter_driver`, que abre una puerta por la que
// otro proceso puede pulsar, escribir y leer la pantalla. Sirve para probar a
// mano lo que no se puede probar con `flutter test` —el visor con vídeo de
// verdad, el reproductor, los ficheros del disco— sin tener que ir pulsando uno
// mismo y contando lo que pasa.
//
// **No es la puerta de entrada de la aplicación.** Vive aquí fuera de `lib/` a
// propósito: así `flutter_driver` no entra en lo que se compila para publicar, y
// nadie puede arrancar por aquí sin querer. Se usa con:
//
// ```
// flutter run -d windows -t test_driver/app.dart
// ```
//
// La emulación de escritura se deja **apagada**: encendida, los campos de texto
// dejan de recibir el teclado de verdad y la aplicación se vuelve incómoda de
// usar con las manos. Quien conduzca y necesite escribir la enciende sobre la
// marcha (`set_text_entry_emulation`).

import 'package:Fern/main.dart' as fern;
import 'package:flutter/foundation.dart';
import 'package:flutter_driver/driver_extension.dart';

Future<void> main() async {
  // Sólo la primera vez.
  //
  // Al reiniciar en caliente, `main` se vuelve a ejecutar pero el marco sigue
  // montado del arranque anterior, y montar otro encima **mata la aplicación**.
  // La puerta que se abrió entonces sigue abierta, así que no hay nada que
  // volver a abrir: basta con no intentarlo.
  if (BindingBase.debugBindingType() == null) {
    enableFlutterDriverExtension(enableTextEntryEmulation: false);
  }

  await fern.main();
}
