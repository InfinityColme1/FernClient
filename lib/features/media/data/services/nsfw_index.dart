import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:isar/isar.dart';

/// Qué etiquetas y qué contenidos están bloqueados, en memoria.
///
/// Existe por rendimiento y por corrección, en ese orden de urgencia pero al
/// revés de importancia:
///
/// - **Rendimiento.** Decidir si un contenido se puede enseñar es una pregunta
///   que se hace una vez por celda de la rejilla. Resolverla consultando la
///   jerarquía de etiquetas cada vez sería una consulta por elemento y por
///   pintado; aquí es mirar en un `Set`.
/// - **Corrección.** La marca de una etiqueta se guarda sólo donde el usuario la
///   puso, y se propaga hacia abajo **al leerla**. Así, mover una rama de sitio
///   cambia el filtro sola: no hay marcas propagadas que se queden viejas ni
///   migraciones que reescriban media biblioteca.
///
/// Hay **dos** formas de que un contenido esté marcado y aquí se suman: la suya
/// propia, puesta a mano sobre él, y la que hereda de sus etiquetas. Ninguna
/// pisa a la otra: desmarcar una etiqueta no toca lo que se marcó a mano, y
/// quitarle la marca a un contenido no lo saca de la rama de una etiqueta que
/// sigue marcada.
///
/// Se reconstruye entero. Recalcular sólo lo que cambia es tentador y es donde
/// se cuelan los fallos: un contenido que se queda visible porque nadie avisó
/// de que su etiqueta cambió de madre no da error, sólo enseña lo que no debía.
class NsfwIndex {
  final Isar _database;
  final TagHierarchy _hierarchy;

  /// Si marcar una etiqueta arrastra a las que cuelgan de ella.
  ///
  /// Llega como función y no como valor para no tener que enterarse de que el
  /// usuario lo ha cambiado: se lee al reconstruir, y quien lo cambia manda
  /// reconstruir.
  final bool Function() _marksChildren;

  Set<int> _tags = const {};
  Set<int> _media = const {};
  Set<int> _byHand = const {};

  NsfwIndex({
    required Isar database,
    required TagHierarchy hierarchy,
    bool Function()? marksChildren,
  })  : _database = database,
        _hierarchy = hierarchy,
        _marksChildren = marksChildren ?? _always;

  static bool _always() => true;

  /// Las etiquetas bloqueadas: las marcadas y todo lo que cuelga de ellas.
  Set<int> get tags => _tags;

  /// Los contenidos filtrados: los marcados a mano y los que llevan alguna de
  /// esas etiquetas.
  Set<int> get media => _media;

  /// Si no hay nada marcado, ni etiquetas ni contenido suelto.
  ///
  /// Con nada marcado el filtro no esconde nada y no hay por qué pedir
  /// contraseñas para ver una biblioteca entera.
  bool get isEmpty => _tags.isEmpty && _media.isEmpty;

  /// Los contenidos marcados **a mano**, sin los que lo están por su etiqueta.
  ///
  /// Va aparte de [media] porque son dos preguntas distintas: «¿esto se
  /// esconde?» la contesta [media], y «¿esta marca la puso el usuario sobre este
  /// contenido?» sólo la puede contestar esto. El interruptor del visor necesita
  /// la segunda: enseñarlo encendido por una etiqueta y que al pulsarlo no pase
  /// nada visible sería un interruptor roto.
  bool isMarkedByHand(int mediaId) => _byHand.contains(mediaId);

  bool hasTag(int tagId) => _tags.contains(tagId);

  bool hasMedia(int mediaId) => _media.contains(mediaId);

  /// Vuelve a mirarlo todo: las etiquetas marcadas, su rama y el contenido que
  /// las lleva.
  ///
  /// Lo llama quien toca etiquetas —marcarlas, moverlas, borrarlas— y quien
  /// toca las etiquetas de un contenido. Y el arranque, antes de pintar nada.
  Future<void> rebuild() async {
    // Lo marcado a mano se lee siempre, haya etiquetas marcadas o no: es una
    // marca que vive sola y no depende de ninguna etiqueta.
    final byHand = await _markedByHand();
    _byHand = byHand;

    final marked =
        await _database.tagModels.filter().isNsfwEqualTo(true).findAll();

    if (marked.isEmpty) {
      _tags = const {};
      _media = byHand;

      return;
    }

    final rooted = marked.map((tag) => tag.id);

    // La rama sólo cuenta si el usuario lo quiere. Apagado, cada etiqueta
    // responde por lo suyo y una hija de una marcada se ve como cualquier otra.
    final branch = _marksChildren()
        ? await _hierarchy.descendantsOf(rooted)
        : const <TagModel>[];

    _tags = {...rooted, for (final tag in branch) tag.id};
    _media = {...byHand, ...await _mediaWithAny(_tags)};
  }

  /// Los contenidos que alguien marcó uno a uno.
  Future<Set<int>> _markedByHand() async {
    final rows =
        await _database.mediaSummaryModels.filter().isNsfwEqualTo(true).findAll();

    return {for (final row in rows) row.id};
  }

  /// El contenido que lleva alguna de estas etiquetas.
  ///
  /// Se pregunta por etiqueta y no por contenido: las marcadas son unas pocas y
  /// los contenidos son decenas de miles, y el enlace de vuelta de la etiqueta
  /// da justo los suyos.
  Future<Set<int>> _mediaWithAny(Set<int> tagIds) async {
    final blocked = <int>{};

    for (final tagId in tagIds) {
      final tag = await _database.tagModels.get(tagId);
      if (tag == null) continue;

      await tag.media.load();

      for (final media in tag.media) {
        final id = media.id;
        if (id != null) blocked.add(id);
      }
    }

    return blocked;
  }
}

/// Las etiquetas de [tags] que están bloqueadas por [index], y las que no.
///
/// Es la operación que repiten el listado lateral, las sugerencias y los
/// buscadores de etiquetas, y está aquí para que ninguno la escriba por su
/// cuenta.
List<TagModel> withoutBlocked(Iterable<TagModel> tags, NsfwIndex index) => [
      for (final tag in tags)
        if (!index.hasTag(tag.id)) tag,
    ];
