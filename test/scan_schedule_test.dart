// Cuándo toca que la aplicación busque repetidos por su cuenta.
//
// Es la única pieza del escaneo automático que puede fallar en silencio: si
// decide que no toca nunca, la función queda apagada sin que nada lo diga; si
// decide que sí de más, se come el disco cada vez que se abre la aplicación. Se
// comprueban los dos bordes del periodo, el primer arranque y el reloj movido.

import 'package:Fern/features/duplicates/domain/services/scan_schedule.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 24, 12);

  bool due({
    bool enabled = true,
    DuplicateScanPeriod period = DuplicateScanPeriod.quarterly,
    DateTime? lastScan,
  }) {
    return isDuplicateScanDue(
      enabled: enabled,
      period: period,
      lastScan: lastScan,
      now: now,
    );
  }

  group('isDuplicateScanDue', () {
    test('apagado no escanea, por muy viejo que sea el último', () {
      expect(due(enabled: false, lastScan: DateTime(2020)), isFalse);
    });

    test('sin escaneo previo toca: la primera vez es la que más encuentra', () {
      expect(due(), isTrue);
    });

    test('no toca mientras no se cumpla el periodo', () {
      expect(due(lastScan: now.subtract(const Duration(days: 89))), isFalse);
    });

    test('toca justo al cumplirse el periodo', () {
      expect(due(lastScan: now.subtract(const Duration(days: 90))), isTrue);
    });

    test('toca de sobra cuando hace mucho que no se mira', () {
      expect(due(lastScan: now.subtract(const Duration(days: 400))), isTrue);
    });

    test('el periodo elegido manda: un mes toca donde tres no', () {
      final lastScan = now.subtract(const Duration(days: 40));

      expect(due(period: DuplicateScanPeriod.monthly, lastScan: lastScan), isTrue);
      expect(
        due(period: DuplicateScanPeriod.quarterly, lastScan: lastScan),
        isFalse,
      );
    });

    test('un año no toca a los seis meses y sí a los trece', () {
      expect(
        due(
          period: DuplicateScanPeriod.yearly,
          lastScan: now.subtract(const Duration(days: 180)),
        ),
        isFalse,
      );
      expect(
        due(
          period: DuplicateScanPeriod.yearly,
          lastScan: now.subtract(const Duration(days: 400)),
        ),
        isTrue,
      );
    });

    // Si el reloj del equipo se adelantó y luego se corrigió, la marca queda en
    // el futuro. Sin este caso, la función no volvería a correr en meses y nada
    // lo explicaría.
    test('una marca en el futuro no deja el escaneo apagado', () {
      expect(due(lastScan: now.add(const Duration(days: 500))), isTrue);
    });
  });
}
