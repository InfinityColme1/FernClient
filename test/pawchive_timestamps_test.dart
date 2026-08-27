// Las fechas que da Pawchive.
//
// El caso que importa es el de la cadena sin zona: es UTC, pero no lo dice, y
// leerla tal cual la desplaza el huso de quien este delante. Como se compara con
// la fecha de la ultima importacion para decir si hay novedades, ese desfase son
// novedades que aparecen o desaparecen al cambiar el dia.

import 'package:Fern/features/media/domain/services/pawchive_timestamps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las dos formas del mismo instante coinciden', () {
    // Comprobado contra la API el 2026-08-27: el mismo creador y el mismo campo,
    // servidos distinto segun por donde se pregunte.
    expect(
      pawchiveTimestamp(1787774400),
      pawchiveTimestamp('2026-08-26T20:00:00'),
    );
  });

  test('la cadena sin zona se lee como UTC', () {
    expect(
      pawchiveTimestamp('2026-08-26T20:00:00'),
      DateTime.utc(2026, 8, 26, 20),
    );
  });

  test('y la que si la trae se respeta', () {
    expect(
      pawchiveTimestamp('2026-08-26T20:00:00Z'),
      DateTime.utc(2026, 8, 26, 20),
    );
    expect(
      pawchiveTimestamp('2026-08-26T22:00:00+02:00'),
      DateTime.utc(2026, 8, 26, 20),
    );
  });

  test('el epoch vale como numero y como cadena', () {
    expect(pawchiveTimestamp(1787774400), DateTime.utc(2026, 8, 26, 20));
    expect(pawchiveTimestamp('1787774400'), DateTime.utc(2026, 8, 26, 20));
    expect(pawchiveTimestamp(1787774400.5), DateTime.utc(2026, 8, 26, 20, 0, 0, 500));
  });

  test('una fecha suelta se entiende igual', () {
    expect(pawchiveTimestamp('2026-08-26'), DateTime(2026, 8, 26));
  });

  test('lo que no es una fecha no lo es', () {
    expect(pawchiveTimestamp(null), isNull);
    expect(pawchiveTimestamp(''), isNull);
    expect(pawchiveTimestamp('   '), isNull);
    expect(pawchiveTimestamp('el martes'), isNull);
    expect(pawchiveTimestamp(const {}), isNull);
  });
}
