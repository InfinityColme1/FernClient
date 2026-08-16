import 'package:Fern/features/media/domain/entities/post_link.dart';

/// Qué hacer con los enlaces de una publicación.
enum LinkChoiceKind {
  /// No traerse nada de esta publicación.
  ignore,

  /// Traerse todo lo que se pueda de sus enlaces.
  all,

  /// Traerse sólo lo que el usuario haya marcado.
  selection,
}

/// La respuesta del usuario a una publicación con varios enlaces.
class LinkChoice {
  final LinkChoiceKind kind;

  /// Las direcciones marcadas, cuando la respuesta es una selección.
  final Set<String> selected;

  /// La misma respuesta vale para el resto de la importación: no se vuelve a
  /// preguntar.
  final bool applyToAll;

  const LinkChoice({
    required this.kind,
    this.selected = const {},
    this.applyToAll = false,
  });

  const LinkChoice.ignore({bool applyToAll = false})
      : this(kind: LinkChoiceKind.ignore, applyToAll: applyToAll);

  /// Si este enlace entra, según lo que haya respondido el usuario.
  bool accepts(PostLink link) => switch (kind) {
        LinkChoiceKind.ignore => false,
        LinkChoiceKind.all => true,
        LinkChoiceKind.selection => selected.contains(link.url),
      };
}

/// Quien sabe preguntarle al usuario. Lo pone la interfaz; sin ella no hay a
/// quién preguntar.
abstract class ImportDecisionHandler {
  /// Una publicación trae varios enlaces y hay que decidir qué se hace.
  Future<LinkChoice> chooseLinks(String postTitle, List<PostLink> links);

  /// Una publicación lleva a un sitio de descargas, que no se puede recorrer
  /// solo. Sólo se informa: la importación no espera una decisión, sigue.
  Future<void> noticeRepository(String postTitle, List<PostLink> links);
}

/// El canal por el que una importación en marcha le pregunta cosas al usuario.
///
/// Hace falta porque una importación no es una operación silenciosa de
/// principio a fin: hay publicaciones que no se pueden resolver solas (varios
/// enlaces, cada uno con contenido distinto) y ahí decide quien la lanzó.
///
/// Está en medio, y no la interfaz directamente, por dos motivos:
///
/// - La importación corre por debajo y el usuario puede estar en cualquier
///   pantalla, o en otro programa. Quien enseñe la pregunta se encarga de que
///   aparezca donde haga falta; aquí sólo se pide.
/// - Cuando no hay nadie escuchando (una importación sin interfaz, o una
///   prueba), la pregunta se responde sola por lo más prudente: no traerse
///   nada. Así una importación nunca se queda esperando a alguien que no está.
class ImportDecisions {
  ImportDecisionHandler? handler;

  /// Lo que el usuario dijo que valía para todo lo que quedaba. Se olvida al
  /// empezar cada importación: es una respuesta para *ésta*, no para siempre.
  LinkChoice? _forEverything;

  /// Empieza una importación: lo respondido en la anterior no cuenta.
  void reset() => _forEverything = null;

  /// Qué se hace con los enlaces de una publicación.
  ///
  /// Con un solo enlace no se pregunta nada: se trae si se puede, que es lo que
  /// el usuario esperaría. Se pregunta cuando hay varios y hay que elegir.
  Future<LinkChoice> chooseLinks(String postTitle, List<PostLink> links) async {
    final downloadable = [
      for (final link in links)
        if (link.isDownloadable) link,
    ];

    if (downloadable.isEmpty) return const LinkChoice.ignore();
    if (downloadable.length == 1) {
      return const LinkChoice(kind: LinkChoiceKind.all);
    }

    final remembered = _forEverything;
    if (remembered != null) return remembered;

    final answer = await handler?.chooseLinks(postTitle, downloadable) ??
        const LinkChoice.ignore();

    if (answer.applyToAll) _forEverything = answer;

    return answer;
  }

  /// Avisa de que la publicación lleva a un sitio de descargas.
  ///
  /// No se espera respuesta: el usuario mira el aviso cuando quiera y la
  /// importación sigue mientras tanto.
  void noticeRepository(String postTitle, List<PostLink> links) {
    if (links.isEmpty) return;

    handler?.noticeRepository(postTitle, links);
  }
}
