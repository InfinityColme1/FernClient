// Que los textos de los cuatro idiomas estén bien escritos.
//
// El fallo que esto protege se coló entero: unas comillas latinas salieron como
// «Â«IRLÂ»» en pantalla, y ni `flutter analyze` ni dos mil pruebas dijeron nada
// —para todos ellos era una cadena perfectamente válida—. Lo vio el usuario.
//
// Pasó por escribir el fichero dos veces codificado: el texto se pasa a UTF-8 y
// esos bytes se vuelven a leer como si fueran Latin-1, así que cada carácter con
// acento o cada comilla se convierte en dos. Es lo típico de generar un `.arb`
// desde un guion, que es justo como se añaden aquí.
//
// La comprobación no busca la lista de destrozos conocidos —serían infinitos—
// sino su firma: los tres caracteres por los que empiezan **todas** las
// secuencias mal leídas, que en un texto de verdad no aparecen jamás sueltos.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _languages = ['en', 'es', 'ca', 'fr'];

/// Por dónde empieza un carácter mal leído.
///
/// Al leer UTF-8 como Latin-1, el primer byte de la secuencia se ve como uno de
/// éstos: `Â` para las comillas y símbolos, `Ã` para las letras acentuadas y `â`
/// para la comilla tipográfica y las rayas.
const _mojibakeLeads = {'Â', 'Ã', 'â'};

/// Si [text] lleva algún carácter mal leído.
///
/// **No basta con encontrar uno de los tres.** `â` es una letra francesa de pleno
/// derecho —«tâche», «relâchez»— y buscarla a secas señalaba media traducción.
/// Lo que no pasa nunca en un texto de verdad es que a uno de esos tres le siga
/// un carácter del tramo 0x80–0xBF: ahí es donde caen los bytes de continuación
/// de UTF-8 leídos como Latin-1, así que esa pareja **es** la firma del
/// destrozo, y una `â` seguida de letra normal se queda tranquila.
bool _isBroken(String text) {
  for (var i = 0; i < text.length - 1; i++) {
    if (!_mojibakeLeads.contains(text[i])) continue;

    final next = text.codeUnitAt(i + 1);
    if (next >= 0x80 && next <= 0xBF) return true;
  }

  return false;
}

Map<String, dynamic> _read(String language) {
  final file = File('lib/l10n/app_$language.arb');

  expect(file.existsSync(), isTrue, reason: 'falta ${file.path}');

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('los textos están bien codificados', () {
    for (final language in _languages) {
      test('en $language', () {
        final entries = _read(language);
        final broken = <String>[];

        for (final entry in entries.entries) {
          // Los metadatos (`@clave`) no son texto que se enseñe.
          if (entry.key.startsWith('@')) continue;
          if (entry.value is! String) continue;

          final text = entry.value as String;

          if (_isBroken(text)) broken.add('${entry.key}: $text');
        }

        expect(
          broken,
          isEmpty,
          reason: 'textos mal codificados en $language:\n${broken.join('\n')}',
        );
      });
    }
  });

  // Lo otro que se coló en la misma tanda, y que ninguna comprobación de
  // codificación habría visto: «Étre» por «Être». Un texto puede estar
  // perfectamente escrito y aun así estar mal.
  group('lo que hay que mirar a mano', () {
    test('los cuatro idiomas tienen las mismas claves', () {
      final reference = _read('en')
          .keys
          .where((key) => !key.startsWith('@'))
          .toSet();

      for (final language in _languages.skip(1)) {
        final keys =
            _read(language).keys.where((key) => !key.startsWith('@')).toSet();

        expect(
          keys.difference(reference),
          isEmpty,
          reason: '$language tiene claves que no están en inglés',
        );
        expect(
          reference.difference(keys),
          isEmpty,
          reason: 'a $language le faltan claves que sí están en inglés',
        );
      }
    });

    // Una cadena vacía se pinta como un hueco y no se nota hasta que alguien la
    // busca en pantalla.
    test('ninguno se ha quedado vacío', () {
      for (final language in _languages) {
        for (final entry in _read(language).entries) {
          if (entry.key.startsWith('@')) continue;
          if (entry.value is! String) continue;

          expect(
            (entry.value as String).trim(),
            isNotEmpty,
            reason: '${entry.key} está vacío en $language',
          );
        }
      }
    });
  });
}
