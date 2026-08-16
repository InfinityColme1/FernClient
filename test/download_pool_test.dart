// Las descargas que corren a la vez.
//
// Lo que hay que sostener son dos cosas opuestas: que de verdad se solapen (si
// no, no sirve de nada) y que no se solapen sin fin (una importación no puede
// abrir cien descargas a la vez). Y que una que falle no arrastre a las demás.

import 'dart:async';

import 'package:Fern/features/media/data/services/download_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('varias corren a la vez', () async {
    final pool = DownloadPool(limit: 3);
    final started = <int>[];
    final gates = [Completer<void>(), Completer<void>(), Completer<void>()];

    for (var i = 0; i < 3; i++) {
      await pool.add(() async {
        started.add(i);
        await gates[i].future;
      });
    }

    // Las tres han arrancado sin que ninguna haya terminado.
    expect(started, [0, 1, 2]);
    expect(pool.running, 3);

    for (final gate in gates) {
      gate.complete();
    }
    await pool.drain();

    expect(pool.running, 0);
  });

  test('pero no más de las que caben', () async {
    final pool = DownloadPool(limit: 2);
    final started = <int>[];
    final gates = [Completer<void>(), Completer<void>()];

    await pool.add(() async {
      started.add(0);
      await gates[0].future;
    });
    await pool.add(() async {
      started.add(1);
      await gates[1].future;
    });

    // La tercera no arranca hasta que se libere un hueco.
    final third = pool.add(() async => started.add(2));
    await Future<void>.delayed(Duration.zero);
    expect(started, [0, 1]);

    // Al terminar una, la que esperaba arranca.
    gates[0].complete();
    await third;
    expect(started, [0, 1, 2]);

    gates[1].complete();
    await pool.drain();
  });

  test('una que falla no tumba a las demás', () async {
    final pool = DownloadPool(limit: 2);
    var finished = 0;

    await pool.add(() async => throw Exception('nope'));
    await pool.add(() async => finished++);
    await pool.drain();

    expect(finished, 1);
    expect(pool.running, 0);
  });

  test('esperar al final espera de verdad', () async {
    final pool = DownloadPool(limit: 4);
    var finished = 0;

    for (var i = 0; i < 8; i++) {
      await pool.add(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        finished++;
      });
    }

    await pool.drain();

    expect(finished, 8);
  });
}
