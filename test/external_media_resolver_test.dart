// Lo que la aplicación se atreve a abrir al importar.
//
// Lo guardado en una cuenta puede llevar a cualquier parte de internet, así que
// lo que se comprueba aquí es sobre todo lo que **no** se hace: no salir de los
// sitios aceptados y no quedarse con nada que no sea un fichero multimedia.

import 'package:Fern/features/media/data/services/external_media_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Un cliente que apunta a qué direcciones se le ha pedido ir.
class _Recorder {
  final List<Uri> requests = [];
  final http.Response Function(http.Request request) respond;

  _Recorder(this.respond);

  http.Client get client => MockClient((request) async {
        requests.add(request.url);
        return respond(request);
      });
}

http.Response _html(String body) => http.Response(
      body,
      200,
      headers: {'content-type': 'text/html; charset=utf-8'},
    );

void main() {
  group('el resolvedor de enlaces externos', () {
    test('devuelve tal cual lo que ya es un fichero, sin pedir nada',
        () async {
      final recorder = _Recorder((_) => _html(''));
      final resolver = ExternalMediaResolver(client: recorder.client);

      final url = await resolver.resolve('https://i.redd.it/abc.jpg');

      expect(url, 'https://i.redd.it/abc.jpg');
      expect(recorder.requests, isEmpty);
    });

    test('no visita un sitio que no está en la lista', () async {
      final recorder = _Recorder((_) => _html(
            '<meta property="og:video" content="https://evil.test/a.mp4">',
          ));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('https://cualquier-sitio.test/algo'), isNull);
      expect(recorder.requests, isEmpty);
    });

    test('no confunde un dominio que acaba igual con uno aceptado', () async {
      final recorder = _Recorder((_) => _html(
            '<meta property="og:video" content="https://falso.test/a.mp4">',
          ));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('https://noimgur.com/abc'), isNull);
      expect(recorder.requests, isEmpty);
    });

    test('no acepta enlaces sin cifrar', () async {
      final recorder = _Recorder((_) => _html(''));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('http://imgur.com/abc'), isNull);
      expect(recorder.requests, isEmpty);
    });

    test('saca el vídeo de las etiquetas de la página', () async {
      final recorder = _Recorder((_) => _html('''
        <html><head>
          <meta property="og:image" content="https://cdn.streamable.com/a.jpg">
          <meta property="og:video" content="https://cdn.streamable.com/a.mp4?token=1&amp;x=2">
        </head></html>
      '''));
      final resolver = ExternalMediaResolver(client: recorder.client);

      final url = await resolver.resolve('https://streamable.com/abc');

      expect(url, 'https://cdn.streamable.com/a.mp4?token=1&x=2');
      expect(recorder.requests.single, Uri.parse('https://streamable.com/abc'));
    });

    test('se queda con la imagen cuando la página no tiene vídeo', () async {
      final recorder = _Recorder((_) => _html(
            '<meta property="og:image" content="https://i.imgur.com/a.png">',
          ));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(
        await resolver.resolve('https://imgur.com/a'),
        'https://i.imgur.com/a.png',
      );
    });

    test('descarta lo que la página anuncia si no es un fichero', () async {
      final recorder = _Recorder((_) => _html(
            '<meta property="og:video" content="https://imgur.com/embed/a">',
          ));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('https://imgur.com/a'), isNull);
    });

    test('descarta lo que la página anuncia si no va cifrado', () async {
      final recorder = _Recorder((_) => _html(
            '<meta property="og:video" content="http://i.imgur.com/a.mp4">',
          ));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('https://imgur.com/a'), isNull);
    });

    test('a Redgifs le pregunta a su API en lugar de leer la página', () async {
      final recorder = _Recorder((request) {
        if (request.url.path.contains('auth/temporary')) {
          return http.Response('{"token":"t"}', 200);
        }
        return http.Response(
          '{"gif":{"urls":{"hd":"https://media.redgifs.com/Abc.mp4",'
          '"sd":"https://media.redgifs.com/Abc-mobile.mp4"}}}',
          200,
        );
      });
      final resolver = ExternalMediaResolver(client: recorder.client);

      final url =
          await resolver.resolve('https://www.redgifs.com/watch/dodgerbluedunlin');

      expect(url, 'https://media.redgifs.com/Abc.mp4');
      expect(recorder.requests.last.path, endsWith('/dodgerbluedunlin'));
    });

    test('un fallo del sitio deja el contenido sin resolver', () async {
      final recorder = _Recorder((_) => http.Response('nope', 500));
      final resolver = ExternalMediaResolver(client: recorder.client);

      expect(await resolver.resolve('https://streamable.com/abc'), isNull);
    });
  });
}
