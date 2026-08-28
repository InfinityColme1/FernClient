import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/media_type.dart';

/// Qué hay al otro lado de un enlace de una publicación.
enum PostLinkKind {
  /// Lleva directo a un fichero que la aplicación sabe guardar.
  media,

  /// Lleva a un fichero comprimido, que hay que abrir para saber qué trae.
  archive,

  /// Lleva a un sitio de descargas, a **un solo fichero**, y no hay forma de
  /// deducir su dirección directa (Mega cifra en el navegador, MediaFire arma
  /// el enlace con javascript). No se puede bajar solo, pero tampoco hay nada
  /// que elegir: es uno.
  repositoryFile,

  /// Lleva a un sitio de descargas, a **una carpeta o un listado**. Ahí sí hay
  /// que entrar: esas páginas tienen su propia espera, su captcha o su lista de
  /// ficheros, y sólo el usuario puede decidir qué se trae.
  repositoryFolder,

  /// Cualquier otra cosa: una plataforma de pago, la publicación original, una
  /// red social. No da el contenido, así que se pasa por alto.
  other,
}

/// Un enlace encontrado dentro de una publicación, ya con su veredicto.
class PostLink {
  final String url;
  final PostLinkKind kind;

  /// De dónde se baja de verdad, cuando no es de [url].
  ///
  /// Hay sitios de descargas cuyo enlace de fichero se deduce de la propia
  /// dirección: Pixeldrain, Dropbox, Drive y compañía publican una forma
  /// «directa» que devuelve el fichero sin pasar por su página. Con eso, un
  /// enlace a un solo contenido se baja como cualquier otro y **no hay nada que
  /// preguntar**.
  final String? directUrl;

  const PostLink({required this.url, required this.kind, this.directUrl});

  /// De dónde se baja: la directa si la hay, y si no la del enlace.
  String get downloadUrl => directUrl ?? url;

  /// La aplicación puede traerse esto por su cuenta.
  bool get isDownloadable =>
      kind == PostLinkKind.media ||
      kind == PostLinkKind.archive ||
      (kind == PostLinkKind.repositoryFile && directUrl != null);

  /// Lleva a algo que hace falta que mire el usuario.
  ///
  /// Son los dos casos que la aplicación no puede resolver: una carpeta, donde
  /// hay que elegir, y un fichero suelto de un sitio que no deja bajarlo sin
  /// pasar por su página.
  bool get needsUser =>
      kind == PostLinkKind.repositoryFolder ||
      (kind == PostLinkKind.repositoryFile && directUrl == null);

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

  // Los sitios de descargas se miran primero, y no después de la extensión: sus
  // páginas de fichero llevan el nombre dentro de la dirección
  // (`dropbox.com/s/abc/foto.png`) y eso **no** es la imagen, es la página que
  // la enseña. Bajársela daría un HTML con nombre de foto.
  final host = uri.host.toLowerCase();
  final isRepository = fileRepositoryHosts.any(
    (each) => host == each || host.endsWith('.$each'),
  );

  if (isRepository) return _repositoryLink(uri, url);

  if (mediaExtensionOfUrl(url) != null) {
    return PostLink(url: url, kind: PostLinkKind.media);
  }

  if (archiveExtensions.any(uri.path.toLowerCase().endsWith)) {
    return PostLink(url: url, kind: PostLinkKind.archive);
  }

  return PostLink(url: url, kind: PostLinkKind.other);
}

/// Qué es un enlace de un sitio de descargas: una carpeta o un fichero.
///
/// Se decide **por la forma de la dirección**, que es lo único que se puede
/// saber sin visitar la página. Cada sitio distingue las dos cosas en la ruta y
/// lo hace igual desde hace años: `/file/` y `/folder/`, `/u/` y `/l/`, `/f/` y
/// `/a/`.
///
/// Lo que no encaje en ninguna forma conocida se da por **carpeta**, que es la
/// opción prudente: se le enseña al usuario en vez de intentar bajar a ciegas
/// algo que no se sabe qué es.
PostLink _repositoryLink(Uri uri, String url) {
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();
  final fragment = uri.fragment;

  PostLink folder() => PostLink(url: url, kind: PostLinkKind.repositoryFolder);
  PostLink file([String? direct]) =>
      PostLink(url: url, kind: PostLinkKind.repositoryFile, directUrl: direct);

  bool at(String prefix) => path.startsWith(prefix);

  if (host.endsWith('mega.nz') || host.endsWith('mega.io')) {
    // Mega cifra en el navegador: ni con la dirección directa se puede bajar
    // desde aquí, así que un fichero suyo sigue necesitando al usuario.
    if (at('/folder/') || fragment.startsWith('F!')) return folder();
    if (at('/file/') || fragment.isNotEmpty) return file();

    return folder();
  }

  if (host.endsWith('drive.google.com')) {
    if (at('/drive/folders/') || at('/folderview')) return folder();

    final id = _driveFileId(uri);
    if (id != null) {
      return file('https://drive.google.com/uc?export=download&id=$id');
    }

    return folder();
  }

  if (host.endsWith('dropbox.com')) {
    if (at('/sh/') || at('/scl/fo/')) return folder();
    if (at('/s/') || at('/scl/fi/')) {
      // Su propia forma de pedir el fichero en vez de la página que lo enseña.
      return file(uri.replace(queryParameters: {
        ...uri.queryParameters,
        'dl': '1',
      }).toString());
    }

    return folder();
  }

  if (host.endsWith('pixeldrain.com')) {
    if (at('/l/')) return folder();
    if (at('/u/') && uri.pathSegments.length >= 2) {
      return file('https://pixeldrain.com/api/file/${uri.pathSegments[1]}?download');
    }

    return folder();
  }

  if (host.endsWith('mediafire.com')) {
    // Arma el enlace de descarga con javascript, así que no se deduce.
    if (at('/folder/')) return folder();

    return at('/file/') ? file() : folder();
  }

  if (host.endsWith('gofile.io')) {
    // Su `/d/` no es un fichero: es la página de un contenido, que puede llevar
    // varios dentro.
    return folder();
  }

  if (host.endsWith('catbox.moe')) {
    if (at('/c/')) return folder();
  }

  // Una dirección que ya apunta a un fichero es un fichero, venga de donde
  // venga: `files.catbox.moe/abc.png` no es una página, es la imagen.
  if (mediaExtensionOfUrl(url) != null) {
    return PostLink(url: url, kind: PostLinkKind.media);
  }

  if (archiveExtensions.any(path.endsWith)) {
    return PostLink(url: url, kind: PostLinkKind.archive);
  }

  // Bunkr, Cyberdrop y los de su estilo: `/a/` es un álbum y lo demás, una
  // ficha de fichero.
  if (at('/a/')) return folder();
  if (at('/f/') || at('/v/') || at('/i/') || at('/d/') || at('/view/')) {
    return file();
  }

  return folder();
}

/// El identificador de un fichero de Drive, esté en la ruta o en la consulta.
String? _driveFileId(Uri uri) {
  final segments = uri.pathSegments;

  final index = segments.indexOf('d');
  if (index != -1 && index + 1 < segments.length) return segments[index + 1];

  final id = uri.queryParameters['id'];

  return id != null && id.isNotEmpty ? id : null;
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
