/// Las direcciones con las que se reconoce de dónde viene un contenido.
///
/// Es lo que permite etiquetar solo sin saber nada de la plataforma: una
/// etiqueta lleva apuntadas unas cuantas direcciones (la de un subreddit, la de
/// la galería de un autor) y todo lo que llegue de debajo de alguna de ellas se
/// lleva esa etiqueta. Como la comparación es por dirección y no por un campo de
/// una API concreta, vale igual para una plataforma que tiene API que para una
/// de la que sólo se puede leer la página.
library;

/// Los parámetros que dicen **cómo se ha llegado** a un enlace, no a dónde
/// apunta.
///
/// Se tiran. El resto se conserva, y eso es lo que arregla las plataformas que
/// identifican una galería con la parte de detrás del `?`: hasta ahora se
/// tiraba todo, así que **todas** las publicaciones de Danbooru se guardaban
/// como `danbooru.donmai.us/posts` y todas las de Gelbooru como
/// `gelbooru.com/index.php`. No es que una regla por artista no encontrara nada:
/// es que una regla por artista se los llevaba a todos.
///
/// Es una lista de lo que se descarta y no una de lo que se acepta, a propósito.
/// Lo contrario obligaría a este fichero a conocer los parámetros de cada
/// plataforma —justo lo que no sabe y no debe saber—, y una plataforma nueva
/// entraría rota.
const _trackingParams = {
  'utm_source',
  'utm_medium',
  'utm_campaign',
  'utm_term',
  'utm_content',
  'fbclid',
  'gclid',
  'igshid',
  'ref',
  'ref_src',
  'ref_url',
  'share_id',
  'si',
  'source',
};

/// Deja una dirección en la forma con la que se compara y se guarda.
///
/// Se quitan las partes que no dicen a qué apunta el enlace sino cómo se pidió:
/// el protocolo, el `www.`, el puerto, la barra final, el ancla y los
/// parámetros de seguimiento. El resto se pasa a minúsculas, porque el nombre
/// del servidor no distingue mayúsculas y las plataformas escriben sus rutas de
/// las dos maneras (`/r/Gifs` y `/r/gifs` son la misma comunidad).
///
/// Los parámetros que quedan **se conservan y se ordenan** por su nombre: hay
/// plataformas en las que la galería está ahí y no en la ruta, y ordenarlos hace
/// que dos enlaces a lo mismo escritos en distinto orden se comparen igual.
///
/// Devuelve la cadena vacía si no queda nada con lo que comparar, que es la
/// forma de decir "esto no sirve como enlace".
String normalizedSourceUrl(String url) {
  var value = url.trim().toLowerCase();
  if (value.isEmpty) return '';

  // El ancla sí se va siempre: es un sitio dentro de la página, no otra página.
  value = value.split('#').first;

  // Sin protocolo `Uri` lo lee todo como una ruta y se queda sin servidor, así
  // que se le pone uno para poder separar las partes.
  final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
  if (uri == null) return '';

  var host = uri.host;
  if (host.startsWith('www.')) host = host.substring(4);
  if (host.isEmpty) return '';

  final path = uri.path.replaceAll(RegExp(r'/+$'), '');
  final query = _normalizedQuery(uri);

  return '$host$path$query';
}

/// Los parámetros que identifican a dónde apunta el enlace, ordenados y con el
/// `?` delante. Cadena vacía si no queda ninguno.
String _normalizedQuery(Uri uri) {
  final kept = [
    for (final entry in uri.queryParameters.entries)
      if (!_trackingParams.contains(entry.key) && entry.value.isNotEmpty)
        '${entry.key}=${entry.value}',
  ]..sort();

  return kept.isEmpty ? '' : '?${kept.join('&')}';
}

/// Si [url] cae debajo de [rule], las dos ya normalizadas.
///
/// La comparación es por tramos de la ruta y no por texto: la publicación
/// `reddit.com/r/gifs/comments/abc` cae debajo de `reddit.com/r/gifs`, pero
/// `reddit.com/r/gifsofotracosa` no, aunque empiece igual. Una regla que sea
/// sólo el servidor (`reddit.com`) recoge todo lo de ese sitio.
///
/// **Una regla con parámetros identifica una galería concreta**, así que ahí se
/// exige que sean la misma: en las plataformas donde la galería vive detrás del
/// `?`, dos direcciones que sólo se parecen en la ruta no tienen nada que ver
/// —`posts?tags=uno` y `posts?tags=otro` son dos artistas distintos—.
///
/// Al revés sí manda la ruta: una regla sin parámetros recoge lo que cuelgue de
/// ella, lleve la dirección los parámetros que lleve.
bool sourceUrlMatches(String url, String rule) {
  if (rule.isEmpty || url.isEmpty) return false;
  if (url == rule) return true;
  if (rule.contains('?')) return false;

  final withoutQuery = url.split('?').first;

  return withoutQuery == rule || withoutQuery.startsWith('$rule/');
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
