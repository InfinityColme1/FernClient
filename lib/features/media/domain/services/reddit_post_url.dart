import 'package:Fern/core/constants/app_constants.dart';

/// De dónde se descarga una publicación de Reddit que no es una galería.
///
/// **Por qué esto es una decisión y no un campo.** Una publicación que enlaza a
/// otro sitio trae, además del enlace, una copia que Reddit se hace para poder
/// enseñarla sin salir de su web: `preview.reddit_video_preview`. Esa copia es
/// **muda siempre** —es la que se reproduce sola al pasar por encima— y de menos
/// calidad. Quedarse con ella porque llega antes en el objeto es cómo se acaba
/// con una biblioteca de vídeos sin sonido: la descarga funciona, el fichero es
/// un vídeo de verdad, y no falla nada por el camino.
///
/// El orden, entonces:
///
/// 1. El vídeo que aloja Reddit, cuando la publicación es suya de verdad.
/// 2. El enlace al sitio de fuera, si es uno de los que la aplicación sabe
///    visitar. Ahí está el original, con su sonido y su calidad.
/// 3. La copia de Reddit, sólo si no hay forma de llegar al original.
/// 4. Y si no, el enlace tal cual, por si acaso apunta a un fichero.
///
/// Devuelve `null` cuando no hay nada que descargar (una publicación de texto).
String? redditPostUrl(Map<String, dynamic> post) {
  final hosted = _redditVideo(post['media']) ?? _redditVideo(post['secure_media']);
  if (hosted != null) return hosted;

  final link = _destination(post);
  if (link != null && isExternalMediaUrl(link)) return link;

  final preview = _fallbackUrl(
    (post['preview'] as Map<String, dynamic>?)?['reddit_video_preview'],
  );
  if (preview != null) return preview;

  return link;
}

/// El enlace de la publicación, si lleva a alguna parte.
String? _destination(Map<String, dynamic> post) {
  if (post['is_self'] == true) return null;

  final url = (post['url_overridden_by_dest'] ?? post['url']) as String?;
  if (url == null || !url.startsWith('https')) return null;

  return url;
}

/// El vídeo que aloja Reddit, no la copia que hace de lo de fuera.
String? _redditVideo(Object? media) {
  if (media is! Map<String, dynamic>) return null;

  return _fallbackUrl(media['reddit_video']);
}

String? _fallbackUrl(Object? video) {
  if (video is! Map<String, dynamic>) return null;

  return video['fallback_url'] as String?;
}

/// Si [url] está en uno de los sitios que la aplicación se atreve a visitar
/// para buscar el fichero que hay detrás.
///
/// La comparación es por punto para que `noredgifs.com` no pase por
/// `redgifs.com`.
bool isExternalMediaUrl(String url) {
  final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
  if (host.isEmpty) return false;

  return externalMediaHosts.any(
    (allowed) => host == allowed || host.endsWith('.$allowed'),
  );
}
