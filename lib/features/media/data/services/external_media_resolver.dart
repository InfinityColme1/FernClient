import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:http/http.dart' as http;

/// Averigua qué ficheros hay detrás de un enlace.
///
/// Lo que el usuario guarda en una plataforma no siempre es un fichero: muchas
/// veces es un enlace a otro sitio que enseña un vídeo o una imagen. Esto lo
/// convierte en las direcciones de los ficheros de verdad, que es lo único que
/// se puede descargar.
///
/// No sabe de ninguna plataforma en concreto y por eso vale para todas: mira
/// primero cómo se anuncia la página a las redes sociales y, si eso no da nada,
/// recorre lo que la página enseña. Lo único que conoce por su nombre es
/// Redgifs, que arma sus páginas en el navegador y no deja nada que mirar.
///
/// Lo que **no** hace, y es a propósito:
///
/// - No sale de [externalMediaHosts]. Un enlace a cualquier otro sitio se
///   descarta sin llegar a pedirlo, así que la aplicación nunca visita una
///   dirección desconocida por el hecho de estar guardada en una cuenta. Una
///   fuente que sepa lo que hace puede levantar esa restricción con [anyHost],
///   pero entonces es ella la que responde de a dónde se va.
/// - No acepta nada que no vaya por `https`.
/// - No se queda con lo que resuelva si no es un fichero multimedia de los que
///   la aplicación reconoce; el tipo se vuelve a comprobar al descargar, con lo
///   que dice el propio servidor.
class ExternalMediaResolver {
  final http.Client _client;

  ExternalMediaResolver({http.Client? client})
      : _client = client ?? http.Client();

  /// La dirección del fichero al que lleva [url], o `null` si no lleva a
  /// ninguno o si el sitio no es de los aceptados.
  ///
  /// De todo lo que haya en la página se queda con lo primero, que es lo que
  /// la propia página pone por delante: en una de vídeo, el vídeo.
  Future<String?> resolve(
    String url, {
    Map<String, String> headers = const {},
    bool anyHost = false,
  }) async {
    final found = await resolveAll(url, headers: headers, anyHost: anyHost);
    return found.isEmpty ? null : found.first;
  }

  /// Todas las direcciones de contenido que hay detrás de [url], sin repetir y
  /// en el orden en el que la página las pone.
  ///
  /// [headers] son las que pida el sitio, si es que pide alguna. [anyHost]
  /// salta la lista de sitios conocidos, para cuando quien llama ya sabe a
  /// dónde está mandando.
  ///
  /// Devuelve la lista vacía si no hay nada, si el sitio no es de los aceptados
  /// o si la página no se deja leer: un enlace que no lleva a contenido no es
  /// un fallo, es un enlace que no lleva a contenido.
  Future<List<String>> resolveAll(
    String url, {
    Map<String, String> headers = const {},
    bool anyHost = false,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return const [];

    // Ya es el fichero: no hay nada que averiguar.
    if (mediaExtensionOfUrl(url) != null) return [url];

    if (!anyHost && !_isAllowed(uri.host)) return const [];

    try {
      if (_isRedgifs(uri.host)) {
        final gif = await _redgifsUrl(uri);
        return gif == null ? const [] : _playable([gif]);
      }

      return await _pageMedia(uri, headers);
    } on Exception {
      return const [];
    }
  }

  /// Si [url] es algo que la aplicación pueda descargar y enseñar: una
  /// dirección segura que apunta a un fichero de los que reconoce.
  ///
  /// Es la última palabra sobre qué se descarga, venga de donde venga la
  /// dirección. Lo de fuera no se cree a ciegas: ni lo que diga una página en
  /// sus etiquetas, ni lo que encuentre quien mire la página por su cuenta (el
  /// navegador de la aplicación lo hace, y pregunta aquí).
  bool isPlayable(String url) {
    return Uri.tryParse(url)?.scheme == 'https' &&
        mediaExtensionOfUrl(url) != null;
  }

  List<String> _playable(Iterable<String> urls) {
    return [
      for (final each in urls)
        if (isPlayable(each)) each,
    ];
  }

  /// Si [host] es uno de los sitios aceptados o un subdominio suyo.
  ///
  /// La comparación es por punto para que `noredgifs.com` no pase por
  /// `redgifs.com`.
  bool _isAllowed(String host) {
    final name = host.toLowerCase();

    return externalMediaHosts.any(
      (allowed) => name == allowed || name.endsWith('.$allowed'),
    );
  }

  bool _isRedgifs(String host) {
    final name = host.toLowerCase();
    return name == 'redgifs.com' || name.endsWith('.redgifs.com');
  }

  /// El vídeo de un enlace de Redgifs, preguntándoselo a su API.
  ///
  /// El permiso es temporal y se pide sin cuenta: es el mismo que usa su web
  /// para poder reproducir el vídeo.
  Future<String?> _redgifsUrl(Uri uri) async {
    final id = uri.pathSegments.isEmpty ? null : uri.pathSegments.last;
    if (id == null || id.isEmpty) return null;

    final token = await _client
        .get(Uri.parse(redgifsTokenUrl), headers: _headers)
        .timeout(remoteRequestTimeout);
    if (token.statusCode != 200) return null;

    final auth =
        (jsonDecode(token.body) as Map<String, dynamic>)['token'] as String?;
    if (auth == null) return null;

    final response = await _client.get(
      Uri.parse('$redgifsGifUrl${id.toLowerCase()}'),
      headers: {..._headers, 'Authorization': 'Bearer $auth'},
    ).timeout(remoteRequestTimeout);
    if (response.statusCode != 200) return null;

    final gif = (jsonDecode(response.body) as Map<String, dynamic>)['gif']
        as Map<String, dynamic>?;
    final urls = gif?['urls'] as Map<String, dynamic>?;
    if (urls == null) return null;

    return (urls['hd'] ?? urls['sd']) as String?;
  }

  /// Todo el contenido que hay en una página, en el orden en el que conviene
  /// mirarlo.
  ///
  /// Primero lo que la página dice tener, según las etiquetas con las que se
  /// anuncia a las redes sociales (`og:video`, `og:image`): es lo que usa
  /// cualquier sitio para que su contenido se vea al compartirlo, así que sirve
  /// para casi todos sin saber nada de cada uno, y es lo que la página
  /// considera *su* contenido y no un adorno. Se prefiere el vídeo: en una
  /// página de vídeo, la imagen es sólo su miniatura.
  ///
  /// Después, lo que la página enseña de verdad: sus imágenes, sus vídeos y los
  /// enlaces que llevan directos a un fichero. Con esto una galería da todas
  /// sus imágenes y no sólo la de la portada, que es lo que las etiquetas de
  /// arriba dan.
  Future<List<String>> _pageMedia(Uri uri, Map<String, String> headers) async {
    final response = await _client
        .get(uri, headers: {..._headers, ...headers})
        .timeout(remoteRequestTimeout);
    if (response.statusCode != 200) return const [];

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('text/html')) return const [];

    final body = response.bodyBytes.length > maxExternalPageBytes
        ? utf8.decode(
            response.bodyBytes.sublist(0, maxExternalPageBytes),
            allowMalformed: true,
          )
        : response.body;

    return _mediaInHtml(body, uri);
  }

  /// El barrido en sí, sobre el texto de la página.
  ///
  /// Es lo único que hay que saber hacer para entender una plataforma que no se
  /// conoce, así que vale igual para lo que llega por la red y para lo que trae
  /// ya pintado el navegador.
  List<String> _mediaInHtml(String body, Uri uri) {
    // Un `Set` con el orden de inserción: la misma imagen suele estar a la vez
    // en las etiquetas de la cabecera y en el cuerpo de la página, y basta con
    // descargarla una vez.
    final found = <String>{};

    final tags = _metaTags(body);
    for (final property in const [
      'og:video:secure_url',
      'og:video:url',
      'og:video',
      'twitter:player:stream',
      'og:image:secure_url',
      'og:image',
    ]) {
      final content = tags[property];
      if (content != null && content.isNotEmpty) {
        found.add(_absolute(content, uri));
      }
    }

    for (final each in _elementUrls(body)) {
      found.add(_absolute(each, uri));
    }

    return _playable(found);
  }

  /// Las direcciones de contenido que salen de las etiquetas del cuerpo de la
  /// página: lo que enseña (`img`, `video`, `source`) y los enlaces que llevan
  /// directos a un fichero.
  ///
  /// Se leen con expresiones regulares por lo mismo que las de la cabecera:
  /// aquí no hay que entender la página, sólo sacarle las direcciones. Lo que no
  /// apunte a un fichero de los que la aplicación reconoce se cae después, al
  /// comprobar la extensión.
  Iterable<String> _elementUrls(String html) sync* {
    final elements = RegExp(
      r'<(?:img|source|video|a)\s[^>]*>',
      caseSensitive: false,
    );

    for (final match in elements.allMatches(html)) {
      final tag = match.group(0)!;

      // `srcset` no se mira: son varias direcciones de la misma imagen a
      // distintos tamaños, y la buena ya está en `src`.
      final url = _attribute(tag, 'src') ?? _attribute(tag, 'href');
      if (url != null && url.isNotEmpty) yield _unescape(url);
    }
  }

  /// Deja una dirección de la página en una absoluta, que es la única que se
  /// puede pedir. Las páginas escriben las suyas de cualquier manera: enteras,
  /// colgando de la raíz del sitio o sin protocolo.
  String _absolute(String url, Uri page) {
    final resolved = Uri.tryParse(url);
    if (resolved == null) return url;

    return resolved.hasScheme ? url : page.resolveUri(resolved).toString();
  }

  /// Las etiquetas `meta` de la página, por el nombre con el que se identifican.
  ///
  /// Se leen con expresiones regulares en lugar de con un analizador de HTML:
  /// aquí no hay que entender la página, sólo sacarle un puñado de etiquetas de
  /// la cabecera.
  Map<String, String> _metaTags(String html) {
    final tags = <String, String>{};

    for (final match in RegExp(r'<meta\s[^>]*>', caseSensitive: false)
        .allMatches(html)) {
      final tag = match.group(0)!;

      final name = _attribute(tag, 'property') ?? _attribute(tag, 'name');
      final content = _attribute(tag, 'content');
      if (name == null || content == null) continue;

      tags.putIfAbsent(name.toLowerCase(), () => _unescape(content));
    }

    return tags;
  }

  String? _attribute(String tag, String name) {
    final match = RegExp(
      '$name\\s*=\\s*["\']([^"\']*)["\']',
      caseSensitive: false,
    ).firstMatch(tag);

    return match?.group(1);
  }

  /// Lo justo para las direcciones: en los atributos de HTML el `&` viene
  /// escapado, y una dirección con `&amp;` no lleva a ninguna parte.
  String _unescape(String value) => value
      .replaceAll('&amp;', '&')
      .replaceAll('&#38;', '&')
      .replaceAll('&quot;', '"');

  Map<String, String> get _headers => {
        'User-Agent': remoteUserAgent.replaceFirst('%s', 'fern'),
      };

  void close() => _client.close();
}
