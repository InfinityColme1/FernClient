/// Cuál de las direcciones que da Redgifs es la que hay que descargar.
///
/// **Por qué hace falta elegir con cuidado.** Redgifs sirve el mismo vídeo en
/// varias formas, y una de ellas es **muda a propósito**: la que su web usa para
/// la previsualización que se reproduce sola al pasar por encima. Se llama igual
/// que las demás salvo por un sufijo, así que quedarse con la primera que venga
/// —o con la que el objeto ponga por delante— es cómo se acaba con una biblioteca
/// entera de vídeos sin sonido, sin que nada haya fallado por el camino.
///
/// El orden es: la de calidad alta, la normal, y nunca la muda. Y si aun así lo
/// que llega es la muda, se reescribe: la del vídeo con sonido es la misma
/// dirección sin ese sufijo.
///
/// Es una función aparte y sin red para poder comprobarlo: lo que decide esto no
/// se ve en ningún error, se ve al darle al play un mes después.
library;

/// El sufijo con el que Redgifs nombra la copia sin sonido.
const redgifsSilentSuffix = '-silent';

/// Las claves de [urls] que llevan vídeo, en el orden en que se prefieren.
const redgifsVideoKeys = ['hd', 'sd'];

/// Las que no son vídeo o son la copia muda, y que no hay que coger nunca.
const redgifsRejectedKeys = ['silent', 'poster', 'thumbnail', 'vthumbnail'];

/// Si una dirección es de Redgifs, mirando el nombre del servidor.
///
/// Vale tanto para el enlace a la página como para el del fichero, que están en
/// servidores distintos pero del mismo dominio.
bool isRedgifsHost(String host) {
  final name = host.toLowerCase();

  return name == 'redgifs.com' || name.endsWith('.redgifs.com');
}

/// La dirección del vídeo con sonido, o `null` si no hay ninguna que valga.
///
/// [hasAudio] es lo que dice el propio Redgifs de ese vídeo. Cuando dice que no
/// tiene sonido no se reescribe nada: no lo hay, y pedir la copia con sonido de
/// algo que nunca lo tuvo daría un fichero que no existe.
String? redgifsVideoUrl(
  Map<String, dynamic> urls, {
  bool hasAudio = true,
}) {
  for (final key in redgifsVideoKeys) {
    final value = urls[key];
    if (value is! String || value.isEmpty) continue;

    return hasAudio ? withRedgifsAudio(value) : value;
  }

  return null;
}

/// La misma dirección, pero la del vídeo con sonido.
///
/// Lo único que las separa es el sufijo, así que quitarlo es todo el trabajo.
/// Una dirección que no lo lleve sale tal cual.
///
/// Se quita **sólo el del final del nombre**, el que va justo antes de la
/// extensión. Uno que aparezca en medio no es el suyo —forma parte del nombre—
/// y borrarlo daría una dirección que no existe, que es la forma de perder ese
/// contenido sin que nada falle.
String withRedgifsAudio(String url) {
  return url.replaceFirst(_silentSuffix, '');
}

/// El sufijo de mudo, y sólo donde acaba el nombre del fichero: antes de la
/// extensión, de los parámetros o del final de la dirección.
final _silentSuffix = RegExp('$redgifsSilentSuffix(?=[.?#]|\$)');
