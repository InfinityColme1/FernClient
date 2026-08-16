import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';

/// Qué hay al otro lado de un enlace de una publicación.
enum PostLinkKind {
  /// Lleva directo a un fichero que la aplicación sabe guardar.
  media,

  /// Lleva a un fichero comprimido, que hay que abrir para saber qué trae.
  archive,

  /// Lleva a un sitio donde alguien ha dejado ficheros para descargar (Mega,
  /// Pixeldrain y compañía). No se puede bajar solo: esas páginas tienen su
  /// propia espera o su captcha, así que ahí entra el usuario.
  repository,

  /// Cualquier otra cosa: una plataforma de pago, la publicación original, una
  /// red social. No da el contenido, así que se pasa por alto.
  other,
}

/// Un enlace encontrado dentro de una publicación, ya con su veredicto.
class PostLink {
  final String url;
  final PostLinkKind kind;

  const PostLink({required this.url, required this.kind});

  /// La aplicación puede traerse esto por su cuenta.
  bool get isDownloadable =>
      kind == PostLinkKind.media || kind == PostLinkKind.archive;

  /// Cómo se llama para enseñarlo en una lista: el sitio y el final de la
  /// dirección, que es lo que distingue un enlace de otro de un vistazo.
  String get label {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;

    return last.isEmpty ? uri.host : '${uri.host}/$last';
  }
}

/// Clasifica un enlace por lo que hay detrás.
///
/// No se abre nada para decidirlo: se mira la dirección, que es lo que se
/// puede saber sin salir a internet. Lo que no se reconoce se deja fuera a
/// propósito: entre bajarse algo que no toca y no bajarse algo que sí, lo
/// segundo lo arregla el usuario y lo primero no.
PostLink classifyPostLink(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.scheme.startsWith('http')) {
    return PostLink(url: url, kind: PostLinkKind.other);
  }

  if (mediaExtensionOfUrl(url) != null) {
    return PostLink(url: url, kind: PostLinkKind.media);
  }

  final path = uri.path.toLowerCase();
  if (archiveExtensions.any(path.endsWith)) {
    return PostLink(url: url, kind: PostLinkKind.archive);
  }

  final host = uri.host.toLowerCase();
  final isRepository = fileRepositoryHosts.any(
    (each) => host == each || host.endsWith('.$each'),
  );

  return PostLink(
    url: url,
    kind: isRepository ? PostLinkKind.repository : PostLinkKind.other,
  );
}

/// Los enlaces que hay en el cuerpo de una publicación, sin repetir y en el
/// orden en el que aparecen.
///
/// El cuerpo es HTML, así que se leen con una expresión regular por lo mismo
/// que en el resolvedor de enlaces externos: aquí no hay que entender la
/// página, sólo sacarle las direcciones.
List<PostLink> linksInPost(String? html) {
  if (html == null || html.isEmpty) return const [];

  final hrefs = RegExp(r'''href=["']([^"']+)["']''', caseSensitive: false);

  final seen = <String>{};

  return [
    for (final match in hrefs.allMatches(html))
      if (seen.add(match.group(1)!)) classifyPostLink(match.group(1)!),
  ];
}
