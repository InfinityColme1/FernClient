import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/core/constants/app_constants.dart';
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

/// Todo lo que hace falta saber de una publicación para poder decidir sobre sus
/// enlaces más tarde.
///
/// Lleva de dónde venía y cómo se nombra lo que salga: la respuesta llega a
/// destiempo, cuando la importación de la que salió ya ha terminado, así que no
/// se le puede preguntar a nadie.
class LinkReviewRequest {
  final String postTitle;
  final List<PostLink> links;
  final ImportSource source;
  final String namePrefix;
  final List<String> sourceUrls;

  const LinkReviewRequest({
    required this.postTitle,
    required this.links,
    required this.source,
    required this.namePrefix,
    this.sourceUrls = const [],
  });
}

/// Una publicación que ha quedado con enlaces que la aplicación no puede
/// resolver sola.
class PendingLinkPost {
  final String title;
  final List<PostLink> links;

  const PendingLinkPost({required this.title, required this.links});
}

/// Quien sabe preguntarle al usuario. Lo pone la interfaz; sin ella no hay a
/// quién preguntar.
abstract class ImportDecisionHandler {
  /// Una publicación trae varios enlaces y hay que decidir qué se hace.
  ///
  /// **No espera respuesta.** Se aparca como una tarea y el usuario la abre
  /// cuando le viene bien; la importación sigue sin él. Antes esto se quedaba
  /// esperando delante de un diálogo, y ese diálogo se perdía en cuanto alguien
  /// se iba al navegador a mirar uno de los enlaces — la importación quedaba
  /// parada esperando una respuesta que ya no se podía dar.
  void parkLinks(LinkReviewRequest request);

  /// La importación ha terminado y estas publicaciones llevaban a sitios de
  /// descargas. **Una vez, al final y sin parar nada.**
  Future<void> showPendingLinks(List<PendingLinkPost> posts);
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

  /// Lo que ha ido quedando sin resolver, para contarlo **al final y de una
  /// vez**.
  ///
  /// Antes cada publicación con un enlace a Mega o a Drive abría su propio
  /// aviso, sin esperar a que se cerrara el anterior: una importación de
  /// doscientas publicaciones montaba doscientos diálogos uno encima de otro y
  /// cerrarlos era el trabajo. Y el aviso saltaba incluso cuando el enlace
  /// llevaba a un solo fichero, que es justo el caso en el que no hay nada que
  /// decidir.
  final List<PendingLinkPost> _pending = [];

  /// Empieza una importación: lo respondido en la anterior no cuenta, y lo que
  /// quedó pendiente ya se contó cuando aquélla terminó.
  void reset() {
    _forEverything = null;
    _pending.clear();
  }

  /// Qué se hace con los enlaces de una publicación.
  ///
  /// Con un solo enlace no se pregunta nada: se trae si se puede, que es lo que
  /// el usuario esperaría. Con varios hay que elegir, y elegir es cosa del
  /// usuario — así que **se aparca y la importación sigue**. Lo que devuelve
  /// entonces es «de ésta, nada por ahora»: lo que se elija se traerá cuando se
  /// conteste, en su propia tarea.
  Future<LinkChoice> chooseLinks(LinkReviewRequest request) async {
    final downloadable = [
      for (final link in request.links)
        if (link.isDownloadable) link,
    ];

    if (downloadable.isEmpty) return const LinkChoice.ignore();
    if (downloadable.length == 1) {
      return const LinkChoice(kind: LinkChoiceKind.all);
    }

    final remembered = _forEverything;
    if (remembered != null) return remembered;

    handler?.parkLinks(request);

    return const LinkChoice.ignore();
  }

  /// Lo que vale para todo lo que queda de esta importación.
  ///
  /// Lo pone quien contesta una tarea marcando la casilla: a partir de ahí, las
  /// publicaciones que queden por mirar se resuelven solas y dejan de aparcarse.
  void applyToEverything(LinkChoice choice) => _forEverything = choice;

  /// Apunta los enlaces de una publicación que hacen falta al usuario.
  ///
  /// No enseña nada: sólo lo anota. Lo que se ve es [flushPendingLinks], al
  /// terminar.
  void notePendingLinks(String postTitle, List<PostLink> links) {
    final pending = [
      for (final link in links)
        if (link.needsUser) link,
    ];

    if (pending.isEmpty) return;

    // Con un tope: una importación de miles de publicaciones no puede acabar
    // con una lista que nadie va a leer, y llevarla entera en memoria durante
    // horas tampoco aporta nada.
    if (_pending.length >= pendingLinkPostsLimit) return;

    _pending.add(PendingLinkPost(title: postTitle, links: pending));
  }

  /// Cuántas publicaciones han quedado con enlaces que necesitan al usuario.
  int get pendingCount => _pending.length;

  /// Enseña de una vez lo que ha quedado pendiente, y lo olvida.
  ///
  /// Se llama al terminar la importación. No espera a nadie: es un resumen, no
  /// una pregunta.
  Future<void> flushPendingLinks() async {
    if (_pending.isEmpty) return;

    final posts = List<PendingLinkPost>.unmodifiable(_pending);
    _pending.clear();

    await handler?.showPendingLinks(posts);
  }
}
