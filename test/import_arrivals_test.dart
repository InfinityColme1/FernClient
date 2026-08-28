// Lo que se ve cuando una importación en marcha suelta un contenido.
//
// **El fallo que esto cierra.** La importación llevaba su propia copia de la
// lista y la volcaba entera en cada llegada. Al volver a la pantalla de
// importación se relee de la base de datos, así que había dos listas que podían
// discrepar: la copia de la importación machacaba lo que la relectura había
// traído, y lo importado sólo reaparecía cerrando y abriendo la aplicación.
//
// Partiendo siempre de lo que se está viendo no hay dos listas que puedan
// discrepar, y ésa es toda la regla.

import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/import_arrivals.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _media(int id) =>
    MediaSummaryEntity(id: id, path: 'C:/media/$id.jpg');

void main() {
  test('lo que llega se pone detrás de lo que hay', () {
    final visible = [_media(1), _media(2)];

    expect(
      withArrival(visible, _media(3)).map((each) => each.id),
      [1, 2, 3],
    );
  });

  test('sin nada a la vista, empieza la lista', () {
    expect(withArrival(null, _media(1)).single.id, 1);
  });

  test('lo que ya está no se repite', () {
    // La relectura de la base de datos y el flujo de la importación pueden dar
    // el mismo contenido: de esa coincidencia no puede salir un duplicado.
    final visible = [_media(1), _media(2)];

    expect(withArrival(visible, _media(2)), same(visible));
  });

  test('lo que traiga la relectura manda', () {
    // Lo que de verdad estaba roto: tras volver a la pantalla, la lista buena es
    // la que acaba de leerse, no la que la importación llevara apuntada. Como se
    // parte de la que se ve, lo leído se conserva entero y lo nuevo se suma.
    final reread = [_media(1), _media(2), _media(3)];

    expect(
      withArrival(reread, _media(4)).map((each) => each.id),
      [1, 2, 3, 4],
    );
  });

  test('no toca la lista que se le pasa', () {
    final visible = [_media(1)];
    withArrival(visible, _media(2));

    expect(visible, hasLength(1));
  });
}
