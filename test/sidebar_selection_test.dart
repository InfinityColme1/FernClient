// Qué botón del menú lateral se ve marcado.
//
// Lo decidía el último clic, así que navegar por código dejaba el menú
// señalando la pantalla anterior: se pulsaba un aviso de repetidos, se llegaba a
// la pantalla, y el menú seguía marcando la biblioteca. Lo que se sostiene aquí
// es que mande la dirección, sin perder lo único que la dirección no sabe
// contar: que filtrar por una etiqueta no cambia de pantalla.

import 'package:Fern/core/navigation/sidebar_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ids = [
    '/media',
    '/import',
    '/favorites',
    '/repeated-media',
    'tag:7',
    'tag:9',
  ];

  String? selected(String location, {String? tapped, String? tappedLocation}) =>
      sidebarSelectedId(
        location: location,
        ids: ids,
        tapped: tapped,
        tappedLocation: tappedLocation,
      );

  test('manda la pantalla en la que se está', () {
    expect(selected('/import'), '/import');
  });

  // Lo que fallaba.
  test('aunque se haya llegado sin pulsar el menú', () {
    // Un aviso de repetidos lleva a su pantalla; el menú seguía marcando la
    // anterior.
    expect(
      selected('/repeated-media', tapped: '/media', tappedLocation: '/media'),
      '/repeated-media',
    );
  });

  test('una dirección con algo detrás marca igual su botón', () {
    expect(selected('/media/7'), '/media');
  });

  test('y una que sólo empieza parecido, no', () {
    expect(selected('/mediateca'), isNull);
  });

  test('gana la más larga, no la primera que encaje', () {
    expect(
      sidebarSelectedId(location: '/media/repeated', ids: ['/media', '/media/repeated']),
      '/media/repeated',
    );
  });

  group('las etiquetas', () {
    // Filtrar por una etiqueta no cambia de pantalla: la dirección no puede
    // contarlo y lo que vale es lo que se pulsó.
    test('se quedan marcadas mientras no se cambie de pantalla', () {
      expect(
        selected('/media', tapped: 'tag:7', tappedLocation: '/media'),
        'tag:7',
      );
    });

    test('pero se sueltan en cuanto se cambia', () {
      expect(
        selected('/favorites', tapped: 'tag:7', tappedLocation: '/media'),
        '/favorites',
      );
    });

    test('y una que ya no está en el menú no marca nada', () {
      // Se borra la etiqueta mientras se está filtrando por ella.
      expect(
        selected('/media', tapped: 'tag:99', tappedLocation: '/media'),
        '/media',
      );
    });
  });

  test('una pantalla que no está en el menú no marca nada', () {
    // El visor, los ajustes: se llega a ellos desde dentro, no desde el menú.
    expect(selected('/viewer'), isNull);
  });
}
