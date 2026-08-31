import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:isar/isar.dart';

/// Qué etiquetas, creadores, contenidos, fernies y modelos están bloqueados, en
/// memoria.
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
/// Hay **tres** formas de que un contenido esté marcado y aquí se suman: la suya
/// propia, puesta a mano sobre él, la que hereda de sus etiquetas y la de su
/// creador. Ninguna pisa a las otras: desmarcar una etiqueta no toca lo que se
/// marcó a mano, y quitarle la marca a un contenido no lo saca de la rama de una
/// etiqueta que sigue marcada ni de la galería de un creador que sigue marcado.
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
  Set<int> _creators = const {};
  Set<int> _media = const {};
  Set<int> _byHand = const {};
  Set<int> _fernies = const {};
  Set<int> _models = const {};

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

  /// Los creadores bloqueados. No hay rama que resolver: un creador no cuelga de
  /// otro, así que son exactamente los marcados.
  Set<int> get creators => _creators;

  /// Los contenidos filtrados: los marcados a mano, los que llevan alguna de
  /// esas etiquetas y los de esos creadores.
  Set<int> get media => _media;

  /// Los fernies bloqueados: los marcados y los que proponen una etiqueta o un
  /// creador bloqueados.
  Set<int> get fernies => _fernies;

  /// Los modelos bloqueados: los marcados y aquellos cuyos fernies **están
  /// todos** bloqueados.
  ///
  /// Todos y no alguno. Un modelo que mezcla clases marcadas y sin marcar sigue
  /// sirviendo para lo segundo, así que se enseña y lo que se le quita de la
  /// vista son sus fernies escondidos, uno a uno. Uno cuyas clases estén todas
  /// escondidas no es más que la lista de esas clases: su nombre, su cara y sus
  /// recuentos hablan sólo de ellas.
  Set<int> get models => _models;

  /// Si no hay nada marcado, ni etiquetas ni contenido suelto.
  ///
  /// Con nada marcado el filtro no esconde nada y no hay por qué pedir
  /// contraseñas para ver una biblioteca entera.
  bool get isEmpty =>
      _tags.isEmpty &&
      _creators.isEmpty &&
      _media.isEmpty &&
      _fernies.isEmpty &&
      _models.isEmpty;

  /// Los contenidos marcados **a mano**, sin los que lo están por su etiqueta.
  ///
  /// Va aparte de [media] porque son dos preguntas distintas: «¿esto se
  /// esconde?» la contesta [media], y «¿esta marca la puso el usuario sobre este
  /// contenido?» sólo la puede contestar esto. El interruptor del visor necesita
  /// la segunda: enseñarlo encendido por una etiqueta y que al pulsarlo no pase
  /// nada visible sería un interruptor roto.
  bool isMarkedByHand(int mediaId) => _byHand.contains(mediaId);

  bool hasTag(int tagId) => _tags.contains(tagId);

  bool hasCreator(int creatorId) => _creators.contains(creatorId);

  bool hasMedia(int mediaId) => _media.contains(mediaId);

  bool hasFernie(int fernieId) => _fernies.contains(fernieId);

  bool hasModel(int modelId) => _models.contains(modelId);

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
    } else {
      final rooted = marked.map((tag) => tag.id);

      // La rama sólo cuenta si el usuario lo quiere. Apagado, cada etiqueta
      // responde por lo suyo y una hija de una marcada se ve como cualquier
      // otra.
      final branch = _marksChildren()
          ? await _hierarchy.descendantsOf(rooted)
          : const <TagModel>[];

      _tags = {...rooted, for (final tag in branch) tag.id};
    }

    _creators = await _markedCreators();

    _media = {
      ...byHand,
      if (_tags.isNotEmpty) ...await _mediaWithAny(_tags),
      if (_creators.isNotEmpty) ...await _mediaOfCreators(_creators),
    };

    // En este orden y no en otro: los fernies heredan de las etiquetas y de los
    // creadores, y los modelos heredan de sus fernies.
    _fernies = await _blockedFernies(_tags, _creators);
    _models = await _blockedModels(_fernies);
  }

  /// Los fernies que no se pueden enseñar: los marcados y los que proponen una
  /// etiqueta que tampoco se puede enseñar.
  ///
  /// La herencia del enlace no es un adorno. Un fernie enlazado a una etiqueta
  /// marcada **es** esa etiqueta dicha con otro nombre: enseñarlo delata lo que
  /// la marca escondía, y sus regiones son recortes del contenido que la lleva.
  /// Como con la rama de etiquetas, no se escribe nada: se resuelve al leer, y
  /// desmarcar la etiqueta devuelve el fernie a la vista sola.
  Future<Set<int>> _blockedFernies(
    Set<int> blockedTags,
    Set<int> blockedCreators,
  ) async {
    final rows =
        await _database.fernieModels.filter().isNsfwEqualTo(true).findAll();

    final blocked = {for (final row in rows) row.id};

    if (blockedTags.isEmpty && blockedCreators.isEmpty) return blocked;

    // Se recorren todos y se filtra aquí: los fernies son unas decenas, y
    // preguntar por cada etiqueta bloqueada sería una consulta por etiqueta
    // para leer lo mismo.
    final linked = await _database.fernieModels.where().findAll();

    for (final row in linked) {
      final tagId = row.linkedTagId;
      final creatorId = row.linkedCreatorId;

      if (tagId != null && blockedTags.contains(tagId)) blocked.add(row.id);
      if (creatorId != null && blockedCreators.contains(creatorId)) {
        blocked.add(row.id);
      }
    }

    return blocked;
  }

  /// Los creadores que alguien marcó.
  Future<Set<int>> _markedCreators() async {
    final rows =
        await _database.creatorModels.filter().isNsfwEqualTo(true).findAll();

    return {for (final row in rows) row.id};
  }

  /// El contenido de estos creadores.
  ///
  /// Se pregunta por creador y no por contenido, como con las etiquetas: los
  /// marcados son unos pocos y los contenidos son decenas de miles.
  Future<Set<int>> _mediaOfCreators(Set<int> creatorIds) async {
    final blocked = <int>{};

    for (final creatorId in creatorIds) {
      final rows = await _database.mediaModels
          .filter()
          .creator((q) => q.idEqualTo(creatorId))
          .findAll();

      for (final media in rows) {
        final id = media.id;
        if (id != null) blocked.add(id);
      }
    }

    return blocked;
  }

  /// Los modelos que no se pueden enseñar: los marcados y los que sólo aprenden
  /// fernies bloqueados.
  ///
  /// Se deriva en vez de escribirse, y por una razón concreta: los fernies de un
  /// modelo se meten y se sacan a menudo. Una marca guardada se quedaría vieja
  /// en cuanto alguien le añadiera una clase normal —el modelo seguiría
  /// escondido sin nada que lo esconda— y al revés, sacar la única clase marcada
  /// no lo devolvería a la vista. Resuelto al leer, se corrige solo.
  ///
  /// El modelo **sin fernies** no se esconde: no habla de nada todavía.
  Future<Set<int>> _blockedModels(Set<int> blockedFernies) async {
    final rows = await _database.recognitionModelModels.where().findAll();
    final blocked = <int>{};

    // Las asignaciones se leen de una vez y se reparten por modelo: preguntar
    // por modelo sería una consulta por tarjeta de la rejilla.
    final ferniesOf = <int, List<int>>{};

    for (final assignment in await _database.modelFernieModels.where().findAll()) {
      await assignment.model.load();
      await assignment.fernie.load();

      final modelId = assignment.model.value?.id;
      final fernieId = assignment.fernie.value?.id;
      if (modelId == null || fernieId == null) continue;

      (ferniesOf[modelId] ??= []).add(fernieId);
    }

    for (final row in rows) {
      if (row.isNsfw) {
        blocked.add(row.id);
        continue;
      }

      final fernies = ferniesOf[row.id];
      if (fernies == null || fernies.isEmpty) continue;

      if (fernies.every(blockedFernies.contains)) blocked.add(row.id);
    }

    return blocked;
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
