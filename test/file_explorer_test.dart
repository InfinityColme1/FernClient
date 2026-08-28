// Cómo se le pide a `explorer.exe` que enseñe un fichero.
//
// Se comprueba el argumento y no el proceso: lanzarlo de verdad abriría ventanas
// en la máquina de quien ejecute las pruebas. Y el argumento es justamente donde
// estaba el fallo, así que es lo que hay que sujetar.
//
// **El fallo.** La ruta iba entrecomillada dentro del argumento, imitando lo que
// se escribe en una consola. Pero Dart, en Windows, escapa por su cuenta
// cualquier argumento que lleve comillas: lo envuelve y escapa las de dentro con
// barras. A `explorer.exe` le llegaba una ruta con barras y comillas de más, y
// `explorer.exe` con una ruta que no entiende no protesta — abre la carpeta de
// documentos, que es lo que se veía en lugar de la ubicación del contenido.

import 'dart:io';

import 'package:Fern/core/services/file_explorer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('es un solo argumento: `/select,` y la ruta pegada', () {
    final args = FileExplorerService.revealArguments(r'C:\media\gato.jpg');

    expect(args, hasLength(1));
    expect(args.single, startsWith('/select,'));
    expect(args.single, endsWith('gato.jpg'));
  });

  test('no lleva comillas propias', () {
    // Lo que rompía: con comillas dentro, Dart las escapa al construir la línea
    // de comandos y la ruta deja de ser una ruta.
    for (final path in [
      r'C:\media\gato.jpg',
      r'C:\Mis cosas\con espacios\gato de campo.jpg',
      r'C:\media\comilla.jpg',
    ]) {
      expect(FileExplorerService.revealArguments(path).single, isNot(contains('"')));
    }
  });

  test('la ruta va entera y absoluta', () {
    // Una relativa dejaría a `explorer.exe` resolviéndola contra su propio
    // directorio de trabajo, que no es el de la aplicación.
    final args = FileExplorerService.revealArguments('gato.jpg');
    final ruta = args.single.substring('/select,'.length);

    expect(File(ruta).isAbsolute, isTrue);
    expect(ruta, endsWith('gato.jpg'));
  });

  test('los espacios de la ruta se conservan tal cual', () {
    // Sin tocarlos: entrecomillar el argumento entero cuando hace falta es cosa
    // de Dart, y hacerlo aquí también es lo que provocaba el doble escapado.
    const path = r'C:\Mis cosas\gato de campo.jpg';

    expect(
      FileExplorerService.revealArguments(path).single,
      contains('gato de campo.jpg'),
    );
  });
}
