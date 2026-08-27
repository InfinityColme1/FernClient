import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:flutter/foundation.dart';

/// Una publicación con enlaces que hay que decidir, esperando a que alguien la
/// mire.
class LinkReview {
  /// El trabajo de la lista de tareas al que corresponde.
  final String jobId;

  final String postTitle;
  final List<PostLink> links;

  /// De qué fuente venía, para que lo que se traiga de aquí quede donde le toca.
  final ImportSource source;

  /// Con qué se nombran los ficheros que salgan de estos enlaces.
  final String namePrefix;

  /// Las direcciones que dicen de dónde sale, para el etiquetado por origen.
  final List<String> sourceUrls;

  const LinkReview({
    required this.jobId,
    required this.postTitle,
    required this.links,
    required this.source,
    required this.namePrefix,
    this.sourceUrls = const [],
  });
}

/// Las publicaciones con enlaces que están esperando una decisión.
///
/// **Por qué esto existe.** El diálogo de enlaces paraba la importación hasta
/// que alguien lo contestara, y encima se perdía: pulsar «ver en el navegador»
/// cambiaba de pantalla, el diálogo se iba con ella, y al volver ya no había
/// forma de seguir revisando. La importación se quedaba parada esperando una
/// respuesta que nadie podía dar.
///
/// Ahora cada publicación así se aparca aquí y sale como una tarea. La
/// importación sigue sin esperar a nadie, y el usuario abre la tarea cuando le
/// venga bien —después de mirar los enlaces en el navegador, o al día siguiente—.
/// Quitar la tarea de la lista es decir que no interesa.
class PendingLinkReviews extends ChangeNotifier {
  final Map<String, LinkReview> _byJob = {};

  /// Quién las guarda en disco, si es que hay alguien.
  ///
  /// Va por fuera porque esto es de la interfaz y guardar es de la capa de
  /// datos; sin nadie —en una prueba— sigue funcionando todo salvo sobrevivir a
  /// cerrar la aplicación.
  Future<void> Function(List<LinkReview> reviews)? persist;

  /// Todas las que hay ahora mismo.
  List<LinkReview> get all => List.unmodifiable(_byJob.values);

  /// Aparca una publicación. [jobId] es la tarea con la que se la va a
  /// encontrar.
  void add(LinkReview review) {
    _byJob[review.jobId] = review;
    _save();
    notifyListeners();
  }

  /// La que corresponde a esa tarea, o `null` si no es de éstas.
  LinkReview? of(String jobId) => _byJob[jobId];

  bool has(String jobId) => _byJob.containsKey(jobId);

  /// La quita: o se ha contestado, o se ha sacado de la lista de tareas.
  void remove(String jobId) {
    if (_byJob.remove(jobId) == null) return;

    _save();
    notifyListeners();
  }

  /// Se queda sólo con las que siguen teniendo su tarea viva.
  ///
  /// Quitar la tarea de la lista es decir que esa pregunta no interesa, así que
  /// la pregunta se va con ella. Sin esto, quedarían aparcadas para siempre
  /// preguntas a las que ya no se puede llegar por ninguna parte.
  void keepOnly(Set<String> jobIds) {
    final gone = _byJob.keys.where((id) => !jobIds.contains(id)).toList();
    if (gone.isEmpty) return;

    for (final id in gone) {
      _byJob.remove(id);
    }

    _save();
    notifyListeners();
  }

  /// Que guardar falle no puede romper nada de lo que se está haciendo: lo único
  /// que se pierde es que sobrevivan a cerrar.
  void _save() {
    persist?.call(all).catchError(
          (Object error) => debugPrint('No se pudieron guardar: $error'),
        );
  }

  int get length => _byJob.length;
}
