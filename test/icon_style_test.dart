// Que los iconos sean todos del mismo juego y del mismo estilo.
//
// La aplicacion tenia dos juegos conviviendo: el resto de pantallas usaba
// `Icons` —los clasicos, de trazo fijo— y la barra del visor usaba `Symbols`,
// que son los nuevos y si dejan pedir el grosor. Encima, dentro de `Icons` se
// mezclaban hasta tres estilos del mismo concepto: `person` con `person_outline`,
// `label` con `label_outline`, `visibility_off` con `visibility_off_outlined`.
//
// Cada mezcla es pequena y ninguna rompe nada; el conjunto es lo que se nota, y
// por eso no lo caza nadie leyendo un diff. De ahi esta prueba.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Los ficheros de codigo de la aplicacion.
Iterable<File> _fuentes() sync* {
  for (final entrada in Directory('lib').listSync(recursive: true)) {
    if (entrada is File && entrada.path.endsWith('.dart')) yield entrada;
  }
}

void main() {
  test('no queda ningun icono del juego antiguo', () {
    // `AnimatedIcons` es otra cosa —una pareja de iconos que se transforma de
    // una a otra— y no tiene equivalente en Symbols, asi que se queda.
    final patron = RegExp(r'(?<!Animated)\bIcons\.[a-zA-Z0-9_]+');
    final restos = <String>[];

    for (final fichero in _fuentes()) {
      // El fichero que centraliza los iconos nombra `Icons` en su documentacion
      // para explicar de que se viene.
      if (fichero.path.endsWith('app_icons.dart')) continue;

      for (final match in patron.allMatches(fichero.readAsStringSync())) {
        restos.add('${fichero.path}: ${match.group(0)}');
      }
    }

    expect(
      restos,
      isEmpty,
      reason: 'estos siguen en el juego antiguo: $restos.\n'
          'Con Symbols el trazo se puede pedir y el relleno es un eje, asi que '
          'mezclarlos deja media pantalla con otro peso.',
    );
  });

  test('ningun simbolo lleva el estilo pegado al nombre', () {
    // En Symbols el estilo no va en el nombre: `Symbols.favorite` a secas es el
    // contorno, y relleno es el mismo con `fill: 1`. Un nombre con `_outlined` o
    // `_border` detras es un icono clasico que se ha colado, o dos nombres para
    // el mismo dibujo que alguien tendra que acordarse de mantener a juego.
    final patron = RegExp(
      r'Symbols\.[a-zA-Z0-9_]*(_outlined|_outline|_rounded|_sharp|_border)\b',
    );
    final sobran = <String>[];

    for (final fichero in _fuentes()) {
      for (final match in patron.allMatches(fichero.readAsStringSync())) {
        sobran.add('${fichero.path}: ${match.group(0)}');
      }
    }

    expect(sobran, isEmpty, reason: 'el estilo se pide al pintar: $sobran');
  });

  test('ningun dibujo propio en mapa de bits', () {
    // Un PNG se ablanda en cuanto la pantalla escala y solo cambia de color si
    // alguien se acordo de tenirlo; un glifo hace las dos cosas solo. Hoy no
    // hace falta ningun dibujo propio —todos los conceptos tienen glifo— y la
    // carpeta ni existe, pero si alguien vuelve a necesitar uno, que sea vector.
    final carpeta = Directory('assets/icons');
    if (!carpeta.existsSync()) return;

    final sueltos = carpeta
        .listSync()
        .whereType<File>()
        .where((f) => !f.path.endsWith('.svg'))
        .map((f) => f.path)
        .toList();

    expect(sueltos, isEmpty);
  });
}
