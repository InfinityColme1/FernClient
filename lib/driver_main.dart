// Punto de entrada sólo para conducir la aplicación desde fuera.
//
// No entra en la compilación normal: `main.dart` sigue siendo el de siempre.
// Esto añade la extensión de flutter_driver antes de arrancar, que es lo que
// permite pulsar botones de verdad y comprobar comportamientos que ninguna
// prueba unitaria alcanza.
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

Future<void> main() async {
  enableFlutterDriverExtension();

  await app.main();
}
