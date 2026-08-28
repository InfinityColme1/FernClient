// Que dos botones distintos no acaben con el mismo dibujo.
//
// Material Symbols tiene muchos nombres que apuntan al **mismo glifo**:
// `close` y `clear` son los dos el aspa, `restore` y `history` son los dos el
// reloj con la flecha, `sell` y `local_offer` son los dos la etiqueta. Escrito
// en el codigo se leen como cosas distintas, y en pantalla son el mismo dibujo.
//
// Eso ya paso: el panel de tareas tenia `close` para parar un trabajo vivo y
// `clear` para quitar de la lista uno terminado. Dos acciones que no tienen nada
// que ver —una interrumpe trabajo, la otra solo ordena la lista— con el mismo
// boton. Nadie lo ve leyendo el codigo, porque los nombres son distintos.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Los nombres que la aplicacion usa, con el codigo del dibujo de cada uno.
///
/// El fichero de simbolos se localiza por el `package_config.json` del proyecto
/// y no por una ruta escrita a mano: la version del paquete cambia con cada
/// actualizacion.
Map<String, String> _codigosEnUso() {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final paquete = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == 'material_symbols_icons');

  // Con barra al final: sin ella, `resolve` sustituye el ultimo segmento en vez
  // de colgar de el, y la ruta sale del directorio del paquete.
  final crudo = paquete['rootUri'] as String;
  final raiz = Uri.parse(crudo.endsWith('/') ? crudo : '$crudo/');
  final fuente =
      File.fromUri(raiz.resolve('lib/symbols.dart')).readAsStringSync();

  final codigos = <String, String>{};
  for (final match in RegExp(
    r'static const IconData ([a-zA-Z0-9_]+) =\s*IconData\(0x([0-9a-f]+)',
  ).allMatches(fuente)) {
    codigos[match.group(1)!] = match.group(2)!;
  }

  final usados = <String>{};
  for (final entrada in Directory('lib').listSync(recursive: true)) {
    if (entrada is! File || !entrada.path.endsWith('.dart')) continue;

    usados.addAll(
      RegExp(r'Symbols\.([a-zA-Z0-9_]+)')
          .allMatches(entrada.readAsStringSync())
          .map((m) => m.group(1)!),
    );
  }

  return {
    for (final nombre in usados)
      if (codigos[nombre] case final codigo?) nombre: codigo,
  };
}

void main() {
  test('ningun dibujo se usa con dos nombres distintos', () {
    final porCodigo = <String, Set<String>>{};

    _codigosEnUso().forEach((nombre, codigo) {
      porCodigo.putIfAbsent(codigo, () => <String>{}).add(nombre);
    });

    final choques = {
      for (final entrada in porCodigo.entries)
        if (entrada.value.length > 1) '0x${entrada.key}': entrada.value.toList()
    };

    expect(
      choques,
      isEmpty,
      reason: 'estos nombres pintan lo mismo: $choques.\n'
          'Si son el mismo concepto, dejalos con un solo nombre. Si significan '
          'cosas distintas, uno de los dos necesita otro dibujo: en pantalla no '
          'hay manera de distinguirlos.',
    );
  });

  test('la comprobacion encuentra los simbolos de verdad', () {
    // Sin esto, un fallo al leer el paquete dejaria la prueba de arriba pasando
    // siempre con la lista vacia, que es la peor forma de estar en verde.
    expect(_codigosEnUso().length, greaterThan(50));
  });
}
