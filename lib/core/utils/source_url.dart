/// Las direcciones con las que se reconoce de dónde viene un contenido.
///
/// Es lo que permite etiquetar solo sin saber nada de la plataforma: una
/// etiqueta lleva apuntadas unas cuantas direcciones (la de un subreddit, la de
/// la galería de un autor) y todo lo que llegue de debajo de alguna de ellas se
/// lleva esa etiqueta. Como la comparación es por dirección y no por un campo de
/// una API concreta, vale igual para una plataforma que tiene API que para una
/// de la que sólo se puede leer la página.
library;

/// Deja una dirección en la forma con la que se compara y se guarda.
///
/// Se quitan las partes que no dicen a qué apunta el enlace sino cómo se pidió:
/// el protocolo, el `www.`, el puerto, la barra final y lo que va detrás de `?`
/// o de `#`. El resto se pasa a minúsculas, porque el nombre del servidor no
/// distingue mayúsculas y las plataformas escriben sus rutas de las dos
/// maneras (`/r/Gifs` y `/r/gifs` son la misma comunidad).
///
/// Devuelve la cadena vacía si no queda nada con lo que comparar, que es la
/// forma de decir "esto no sirve como enlace".
String normalizedSourceUrl(String url) {
  var value = url.trim().toLowerCase();
  if (value.isEmpty) return '';

  // Lo que va detrás de `?` o de `#` es cómo se ha llegado al enlace (la
  // campaña, el ancla dentro de la página), no a dónde apunta.
  value = value.split('?').first.split('#').first;

  // Sin protocolo `Uri` lo lee todo como una ruta y se queda sin servidor, así
  // que se le pone uno para poder separar las dos partes.
  final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
  if (uri == null) return '';

  var host = uri.host;
  if (host.startsWith('www.')) host = host.substring(4);
  if (host.isEmpty) return '';

  final path = uri.path.replaceAll(RegExp(r'/+$'), '');

  return '$host$path';
}

/// Si [url] cae debajo de [rule], las dos ya normalizadas.
///
/// La comparación es por tramos de la ruta y no por texto: la publicación
/// `reddit.com/r/gifs/comments/abc` cae debajo de `reddit.com/r/gifs`, pero
/// `reddit.com/r/gifsofotracosa` no, aunque empiece igual. Una regla que sea
/// sólo el servidor (`reddit.com`) recoge todo lo de ese sitio.
bool sourceUrlMatches(String url, String rule) {
  if (rule.isEmpty || url.isEmpty) return false;
  if (url == rule) return true;

  return url.startsWith('$rule/');
}

/// Las direcciones de [urls] que valen, normalizadas y sin repetir.
///
/// Mantiene el orden en el que se escribieron: son los campos del diálogo, y
/// el usuario espera encontrárselos como los dejó.
List<String> normalizedSourceUrls(Iterable<String> urls) {
  final result = <String>[];
  for (final url in urls) {
    final normalized = normalizedSourceUrl(url);
    if (normalized.isEmpty || result.contains(normalized)) continue;

    result.add(normalized);
  }
  return result;
}
