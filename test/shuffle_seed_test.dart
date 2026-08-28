// Con que se baraja el contenido al pedirlo al azar.
//
// Son dos exigencias que tiran en direcciones contrarias, y por eso hay una
// pieza aparte para ellas:
//
// - **Al leer tiene que ser estable.** La rejilla vuelve a pedir el contenido al
//   desplazarse y al volver del visor; si barajara ahi, se recolocaria sola por
//   el camino y se acabaria viendo lo mismo dos veces y contenido ninguna.
// - **Al pulsar tiene que cambiar.** Con una semilla fija para siempre, «al
//   azar» sale una vez y a partir de ahi es un orden fijo mas.

import 'package:Fern/core/services/shuffle_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('leerla muchas veces da siempre lo mismo', () {
    final semilla = ShuffleSeed();
    final primera = semilla.value;

    expect(semilla.value, primera);
    expect(semilla.value, primera);
  });

  test('renovarla la cambia', () {
    final semilla = ShuffleSeed();
    final antes = semilla.value;

    semilla.renew();

    expect(semilla.value, isNot(antes));
  });

  test('cada pulsacion cambia respecto a la anterior', () {
    // Es el caso real de pulsar «al azar» varias veces seguidas. Sin cuidado,
    // dos pulsaciones dentro del mismo microsegundo darian la misma semilla y el
    // mismo orden: desde fuera eso se ve como un boton que no ha hecho nada.
    //
    // Lo que se exige es que cambie respecto a **la que esta puesta**, que es lo
    // que se esta viendo. Que una semilla coincida con otra de hace diez
    // pulsaciones no lo nota nadie.
    final semilla = ShuffleSeed();
    var anterior = semilla.value;

    for (var i = 0; i < 200; i++) {
      semilla.renew();
      expect(
        semilla.value,
        isNot(anterior),
        reason: 'la pulsacion $i ha dejado el mismo orden',
      );
      anterior = semilla.value;
    }
  });

  test('dos barajas distintas nacen con semillas distintas', () {
    // No es lo que usa la aplicacion —hay una sola— pero si dos naciesen iguales
    // seria por leer un reloj demasiado grueso, que es el mismo problema.
    final una = ShuffleSeed();
    final otra = ShuffleSeed()..renew();

    expect(una.value, isNot(otra.value));
  });
}
