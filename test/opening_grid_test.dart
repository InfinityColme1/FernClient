// Que rejilla enseña una pantalla que se acaba de abrir.
//
// El bloc de contenido es **uno solo** y lo comparten seis pantallas, asi que su
// lista sobrevive al cambio de pantalla. Sin decidir esto, la biblioteca se
// abria enseñando lo que hubiera dejado la importacion —y durante toda la
// transicion, que es cuando mas se mira—: contenido de otro sitio, con la
// cabecera y los botones de este.

import 'package:Fern/features/media/domain/services/opening_grid.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Lo que se veia: se va a importar, se vuelve, y la biblioteca enseña lo de
  // importacion.
  test('lo de otra pantalla se suelta', () {
    expect(
      gridOnOpening(
        shown: MediaListing.scanned,
        opening: MediaListing.library,
        hasFreshLibrary: false,
      ),
      OpeningGrid.clear,
    );
  });

  test('y lo de una pantalla de gestion tambien', () {
    expect(
      gridOnOpening(
        shown: MediaListing.byTag,
        opening: MediaListing.library,
        hasFreshLibrary: false,
      ),
      OpeningGrid.clear,
    );
  });

  // Volver del visor a la biblioteca no puede vaciarla, ni tirar la busqueda
  // que hubiera puesta: es la misma pantalla.
  test('la misma pantalla se queda como estaba', () {
    expect(
      gridOnOpening(
        shown: MediaListing.library,
        opening: MediaListing.library,
        hasFreshLibrary: false,
      ),
      OpeningGrid.keep,
    );
  });

  test('aunque haya una guardada al dia', () {
    expect(
      gridOnOpening(
        shown: MediaListing.library,
        opening: MediaListing.library,
        hasFreshLibrary: true,
      ),
      OpeningGrid.keep,
    );
  });

  // Ni lectura, ni hueco, ni espera: es exactamente lo que se habria vuelto a
  // leer.
  test('volviendo a la biblioteca sin cambios, se devuelve la guardada', () {
    expect(
      gridOnOpening(
        shown: MediaListing.scanned,
        opening: MediaListing.library,
        hasFreshLibrary: true,
      ),
      OpeningGrid.restore,
    );
  });

  // Lo guardado es la biblioteca: no vale para ninguna otra pantalla.
  test('pero no vale para otra pantalla', () {
    expect(
      gridOnOpening(
        shown: MediaListing.library,
        opening: MediaListing.favorites,
        hasFreshLibrary: true,
      ),
      OpeningGrid.clear,
    );
  });

  // Al arrancar no hay ninguna puesta.
  test('la primera vez se abre con su hueco', () {
    expect(
      gridOnOpening(
        shown: MediaListing.none,
        opening: MediaListing.library,
        hasFreshLibrary: false,
      ),
      OpeningGrid.clear,
    );
  });
}
