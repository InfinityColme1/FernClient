// Con qué nombre conoce la fuente a un contenido que ya está aquí.
//
// Es el eslabón del que cuelga todo el bloqueo: se guarda ese nombre y se
// compara con el que la fuente da **antes de descargar**, así que si sale mal el
// bloqueo se guarda igual y no se dispara nunca — sin avisar de nada, que es la
// peor forma de fallar.
//
// Lo normal es que esté guardado desde que entró. El respaldo es para lo que ya
// estaba en la biblioteca antes de que se guardara, y se apoya en cómo se
// nombran las descargas: `<identificador>.<extensión>` (`RemoteMediaDownloader`),
// intacto mientras el contenido esté pendiente de revisar, porque los ficheros
// sólo se recolocan al darlos por definitivos.

import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

MediaSummaryEntity _summary(String path, {String? remoteId}) =>
    MediaSummaryEntity(
      id: 1,
      path: path,
      importSource: ImportSource.reddit,
      remoteId: remoteId,
    );

void main() {
  group('lo guardado manda', () {
    test('se usa tal cual', () {
      expect(
        remoteIdOf(_summary(r'C:\d\otra_cosa.jpg', remoteId: 'gatos_abc')),
        'gatos_abc',
      );
    });

    // Lo que sale de un comprimido se llama como venía dentro, así que de su
    // ruta no se saca nada: es justo el caso para el que se guarda.
    test('aunque el fichero no se llame como él', () {
      expect(
        remoteIdOf(_summary(
          r'C:\d\pawchive\portada final (1).png',
          remoteId: 'pawchive_9876_link0',
        )),
        'pawchive_9876_link0',
      );
    });

    test('vacío no cuenta como guardado', () {
      expect(
        remoteIdOf(_summary(r'C:\d\reddit\aww_t3_abc.jpg', remoteId: '')),
        'aww_t3_abc',
      );
    });
  });

  group('el respaldo, para lo que entró antes', () {
    test('es el nombre del fichero sin su extensión', () {
      expect(remoteIdOf(_summary(r'C:\d\reddit\aww_t3_abc.jpg')), 'aww_t3_abc');
    });

    test('vale para las de todas las fuentes', () {
      expect(remoteIdOf(_summary(r'C:\d\gelbooru_1234.png')), 'gelbooru_1234');
      expect(remoteIdOf(_summary(r'C:\d\danbooru_55.webp')), 'danbooru_55');
      expect(remoteIdOf(_summary(r'C:\d\pixiv\4242_9999_p0.jpg')),
          '4242_9999_p0');
    });

    test('y da igual cómo esté escrita la extensión', () {
      expect(remoteIdOf(_summary(r'C:\d\reddit\aww_t3_abc.JPG')), 'aww_t3_abc');
    });

    // Los ugoira de Pixiv se guardan montados en un GIF, y los comprimidos de
    // Pawchive con su `.zip`: las dos son extensiones que la aplicación pone.
    test('cuenta también lo que se guarda convertido o comprimido', () {
      expect(remoteIdOf(_summary(r'C:\d\pixiv\4242_9999.gif')), '4242_9999');
      expect(
        remoteIdOf(_summary(r'C:\d\pawchive\pawchive_1_link0.zip')),
        'pawchive_1_link0',
      );
    });

    // Cortando por el último punto sin mirar qué hay detrás, un identificador
    // con un punto dentro se quedaría a medias y el bloqueo no se dispararía
    // nunca. Sólo se quita lo que la aplicación sabe que pone ella.
    test('un punto que no es una extensión no se toca', () {
      expect(remoteIdOf(_summary(r'C:\d\pinterest_12.34.jpg')), 'pinterest_12.34');
      expect(remoteIdOf(_summary(r'C:\d\pawchive_7.5_0')), 'pawchive_7.5_0');
    });

    test('sin ruta ni identificador guardado, no se inventa nada', () {
      // Antes que bloquear con un identificador vacío, que casaría con
      // cualquier pieza que tampoco lo tuviera.
      expect(remoteIdOf(_summary('')), isNull);
    });
  });
}
