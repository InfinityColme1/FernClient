import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:isar/isar.dart';

/// Resuelve la jerarquía de etiquetas hacia arriba.
///
/// Una etiqueta que cuelga de otra es un caso de ella: "marinette" es
/// "miraculous", así que el contenido de la hija es también contenido de la
/// madre. Por eso lo que se etiqueta con una lleva puestas todas las de encima,
/// y por eso la expansión se hace aquí y no en la pantalla: da igual si la
/// etiqueta la ha puesto el usuario a mano o el etiquetado automático al
/// importar, el contenido acaba en la base de datos con la rama entera.
class TagHierarchy {
  final Isar _database;

  TagHierarchy({required Isar database}) : _database = database;

  /// [tags] junto con todas las etiquetas de las que cuelgan, a cualquier
  /// profundidad y sin repetir ninguna.
  Future<List<TagModel>> withAncestors(Iterable<TagModel> tags) async {
    final ancestors = await ancestorsOf(tags.map((tag) => tag.id));
    return [...tags, ...ancestors];
  }

  /// Las etiquetas que están por encima de [tagIds], sin ellas.
  Future<List<TagModel>> ancestorsOf(Iterable<int> tagIds) async {
    final found = <int, TagModel>{};
    // Una jerarquía mal formada no deja la búsqueda dando vueltas: cada
    // etiqueta se mira una sola vez.
    final visited = <int>{...tagIds};
    final pending = <int>[...visited];

    while (pending.isNotEmpty) {
      final current = pending.removeLast();

      for (final parent in await _parentsOf(current)) {
        if (!visited.add(parent.id)) continue;
        found[parent.id] = parent;
        pending.add(parent.id);
      }
    }

    return found.values.toList();
  }

  /// Las etiquetas que tienen a [tagId] entre sus hijas.
  ///
  /// Normalmente es una sola, pero la base de datos no lo impide, así que se
  /// suben todas.
  Future<List<TagModel>> _parentsOf(int tagId) {
    return _database.tagModels
        .filter()
        .children((q) => q.idEqualTo(tagId))
        .findAll();
  }
}
