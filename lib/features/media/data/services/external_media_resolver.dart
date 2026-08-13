import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:http/http.dart' as http;

/// Averigua qué fichero hay detrás de un enlace.
///
/// Lo que el usuario guarda en una plataforma no siempre es un fichero: muchas
/// veces es un enlace a otro sitio que enseña un vídeo o una imagen. Esto lo
/// convierte en la dirección del fichero de verdad, que es lo único que se
/// puede descargar.
///
/// Lo que **no** hace, y es a propósito:
///
/// - No sale de [externalMediaHosts]. Un enlace a cualquier otro sitio se
///   descarta sin llegar a pedirlo, así que la aplicación nunca visita una
///   dirección desconocida por el hecho de estar guardada en una cuenta.
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
  Future<String?> resolve(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return null;

    // Ya es el fichero: no hay nada que averiguar.
    if (mediaExtensionOfUrl(url) != null) return url;

    if (!_isAllowed(uri.host)) return null;

    try {
      final resolved = _isRedgifs(uri.host)
          ? await _redgifsUrl(uri)
          : await _openGraphUrl(uri);

      if (resolved == null) return null;

      // Lo que diga la página tampoco se cree a ciegas: tiene que ser una
      // dirección segura y apuntar a un fichero que se pueda pintar.
      final resolvedUri = Uri.tryParse(resolved);
      if (resolvedUri == null || resolvedUri.scheme != 'https') return null;

      return mediaExtensionOfUrl(resolved) == null ? null : resolved;
    } on Exception {
      return null;
    }
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

  /// El fichero que la página dice tener, según las etiquetas con las que se
  /// anuncia a las redes sociales (`og:video`, `og:image`).
  ///
  /// Es lo que usa cualquier sitio para que su contenido se vea al compartirlo,
  /// así que sirve para casi todos sin saber nada de cada uno. Se prefiere el
  /// vídeo: en una página de vídeo, la imagen es sólo su miniatura.
  Future<String?> _openGraphUrl(Uri uri) async {
    final response =
        await _client.get(uri, headers: _headers).timeout(remoteRequestTimeout);
    if (response.statusCode != 200) return null;

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('text/html')) return null;

    final body = response.bodyBytes.length > maxExternalPageBytes
        ? utf8.decode(
            response.bodyBytes.sublist(0, maxExternalPageBytes),
            allowMalformed: true,
          )
        : response.body;

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
      if (content != null && content.isNotEmpty) return content;
    }

    return null;
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
