// Que el script del sidecar de disco se ponga al día solo.
//
// Esto existe por un fallo que costó una sesión encontrar. La versión del
// script era **un número puesto a mano**: se le añadió el método `inspect` —el
// que mira unos pesos traídos de fuera— y nadie subió el número. La aplicación
// arrancaba tan contenta, el script de disco seguía siendo el viejo, y todas las
// instalaciones que ya existían respondían «Unknown method: inspect» al importar
// unos pesos. No daba ningún error hasta que alguien usaba justo esa función.
//
// Ahora lo que se compara es la huella del contenido, así que cambiar el script
// basta para que se reescriba. Lo que se comprueba aquí es exactamente eso, y
// que una instalación con el número viejo se actualiza en cuanto se arranca.

import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:Fern/features/recognition/data/services/uv_bootstrap.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory runtime;
  late SidecarProvisioner provisioner;

  setUp(() {
    runtime = Directory.systemTemp.createTempSync('fern_sidecar_test');

    final paths = SidecarPaths.forCurrentPlatform(runtime.path);
    if (paths == null) {
      throw StateError('Este sistema no tiene rutas de sidecar');
    }

    provisioner = SidecarProvisioner(
      paths: paths,
      bootstrap: UvBootstrap(paths: paths),
    );
  });

  tearDown(() {
    if (runtime.existsSync()) runtime.deleteSync(recursive: true);
  });

  File script() => File(provisioner.paths.sidecarScript);
  File version() => File(provisioner.paths.sidecarVersionFile);

  test('sin nada instalado, el script se escribe', () async {
    await provisioner.writeScript();

    expect(script().existsSync(), isTrue);
    expect(version().readAsStringSync(), isNotEmpty);
  });

  test('lo que se escribe es lo que trae la aplicación', () async {
    await provisioner.writeScript();

    final bundled = await rootBundle.loadString(sidecarScriptAsset);

    expect(script().readAsStringSync(), bundled);

    // Y trae `inspect`, que es el método que faltaba: sin él, importar unos
    // pesos de fuera contesta «Unknown method».
    expect(script().readAsStringSync(), contains('"inspect": handle_inspect'));
  });

  test('un script de disco distinto se reemplaza', () async {
    script().parent.createSync(recursive: true);
    script().writeAsStringSync('# un sidecar viejo, sin inspect\n');
    version().writeAsStringSync('sea lo que sea esto');

    await provisioner.writeScript();

    final bundled = await rootBundle.loadString(sidecarScriptAsset);
    expect(script().readAsStringSync(), bundled);
  });

  test('una instalación con el número viejo se actualiza', () async {
    script().parent.createSync(recursive: true);
    script().writeAsStringSync('# el sidecar de antes\n');

    // Es literalmente lo que hay en las instalaciones que existen: la versión
    // era un '1' escrito a mano y se quedó ahí para siempre.
    version().writeAsStringSync('1');

    await provisioner.writeScript();

    expect(script().readAsStringSync(), contains('handle_inspect'));
    expect(version().readAsStringSync(), isNot('1'));
  });

  test('con todo al día no se toca nada', () async {
    await provisioner.writeScript();

    final stamp = version().readAsStringSync();
    final modified = script().lastModifiedSync();

    // Se marca el fichero para notar si lo reescribe: pasar por aquí en cada
    // arranque no puede reescribir dieciséis kilobytes cada vez.
    script().writeAsStringSync(script().readAsStringSync());
    script().setLastModifiedSync(DateTime(2020));

    await provisioner.writeScript();

    expect(version().readAsStringSync(), stamp);
    expect(script().lastModifiedSync(), DateTime(2020));
    expect(modified, isNotNull);
  });

  test('forzando se reescribe aunque esté al día', () async {
    await provisioner.writeScript();
    script().writeAsStringSync('# alguien lo ha tocado a mano\n');

    await provisioner.writeScript(force: true);

    expect(script().readAsStringSync(), contains('handle_inspect'));
  });

  test('si falta el script se vuelve a escribir aunque la huella cuadre',
      () async {
    await provisioner.writeScript();

    // La huella guardada sigue siendo la buena, pero el fichero ya no está:
    // fiarse sólo de la huella dejaría el entorno sin script y sin arreglo.
    script().deleteSync();

    await provisioner.writeScript();

    expect(script().existsSync(), isTrue);
  });

  // Reconocer reventaba con «no se puede encontrar la ruta especificada:
  // runs\detect\predict». No era del reconocimiento: ultralytics **siempre**
  // crea su carpeta de salida al armar el predictor, aunque no se guarde nada, y
  // sin decirle donde la pone en `runs/detect` **relativa al directorio de
  // trabajo**. Con un directorio de trabajo que no servia, mkdir fallaba y el
  // fallo salia como si el modelo estuviera roto.
  group('donde escribe ultralytics', () {
    test('se le dice en cada prediccion', () async {
      final script = await rootBundle.loadString(sidecarScriptAsset);

      // Tantas veces como se llama a predict: la segunda es la que cae al
      // procesador cuando la tarjeta no puede, y olvidarla ahi dejaria el fallo
      // esperando justo en el equipo sin tarjeta.
      expect(
        'project=_runs_directory()'.allMatches(script).length,
        // Dos: la normal y la que cae al procesador cuando la tarjeta no
        // puede. Olvidar la segunda dejaria el fallo esperando justo en el
        // equipo sin tarjeta.
        2,
      );
    });

    test('y es una ruta absoluta, no relativa al directorio de trabajo',
        () async {
      final script = await rootBundle.loadString(sidecarScriptAsset);

      expect(script, contains('def _runs_directory():'));
      expect(script, contains('os.path.dirname(os.path.abspath(__file__))'));
    });

    test('siempre la misma carpeta', () async {
      // Sin `exist_ok`, ultralytics crea predict2, predict3, predict4... una por
      // imagen mirada, y reconocer la biblioteca deja miles de carpetas vacias.
      final script = await rootBundle.loadString(sidecarScriptAsset);

      expect(script, contains('exist_ok=True'));
    });
  });

  // **El fallo que dejo el reconocimiento sin funcionar entero.**
  //
  // Hubo una version que leia la entrada en un hilo aparte, para poder atender
  // el "cancel" mientras se entrenaba. En Windows eso cuelga la importacion de
  // numpy y de torch: con un hilo bloqueado leyendo la entrada, cargar las
  // extensiones nativas se queda esperando para siempre, sin gastar procesador y
  // sin decir nada. Reconocer no daba error: se quedaba pensando.
  //
  // Se comprobo con las tres formas de leer —iterando, `sys.stdin.buffer` y
  // `os.read`— y las tres cuelgan. Asi que la regla es la que dice el nombre: en
  // el sidecar no hay hilos.
  group('un solo hilo', () {
    test('el script no importa threading', () async {
      final script = await rootBundle.loadString(sidecarScriptAsset);

      expect(script, isNot(contains('import threading')));
      expect(script, isNot(contains('threading.Thread')));
    });

    test('ni lee la entrada desde ninguno', () async {
      final script = await rootBundle.loadString(sidecarScriptAsset);

      // La entrada se lee en un sitio y sólo en uno: el bucle principal.
      expect('sys.stdin'.allMatches(script).length, 1);
    });

    // Lo que se queria de aquel hilo: poder parar algo que lleva horas dentro de
    // ultralytics. Ahora la senal llega por fichero, que se mira sin leer nada.
    test('y la parada se mira por fichero', () async {
      final script = await rootBundle.loadString(sidecarScriptAsset);

      expect(script, contains('def _cancel_directory():'));
      expect(script, contains('os.path.exists(_cancel_path(request_id))'));
    });

    test('que se borra al terminar', () async {
      // Los identificadores se repiten entre arranques —el primero siempre es
      // `r0`—, asi que una senal olvidada pararia sola la primera peticion de la
      // proxima sesion.
      final script = await rootBundle.loadString(sidecarScriptAsset);

      expect(script, contains('def _forget_cancel(request_id):'));
      expect(script, contains('_forget_cancel(request_id)'));
    });
  });
}
