// El peso de un fichero escrito para leerlo de un vistazo.
//
// Sale al lado de otro peso, en la pantalla donde se elige qué copia sobrevive:
// si las dos líneas no se comparan solas, la comparación no sirve de nada.

import 'package:Fern/core/utils/file_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lo pequeño va en bytes', () {
    expect(formatFileWeight(0), '0 B');
    expect(formatFileWeight(1023), '1023 B');
  });

  test('a partir de mil veinticuatro cambia de unidad', () {
    expect(formatFileWeight(1024), '1,0 KB');
    expect(formatFileWeight(1024 * 1024), '1,0 MB');
    expect(formatFileWeight(1024 * 1024 * 1024), '1,0 GB');
  });

  test('un decimal, con coma', () {
    expect(formatFileWeight(2516582), '2,4 MB');
    expect(formatFileWeight(9113), '8,9 KB');
  });

  test('con tres cifras sobra el decimal', () {
    // «102,4 MB» al lado de «98,7 MB» alarga la línea sin decidir nada.
    expect(formatFileWeight(107374182), '102 MB');
  });

  test('sin peso no se escribe nada', () {
    // Un fichero que ya no está no dice «0 B», que sería mentira y además
    // parecería el peor candidato de los dos.
    expect(formatFileWeight(null), '');
    expect(formatFileWeight(-1), '');
  });

  test('no se sale de la mayor unidad', () {
    expect(formatFileWeight(1024 * 1024 * 1024 * 1024 * 5), '5,0 TB');
  });
}
