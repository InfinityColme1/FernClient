import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/source_url.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/media/data/services/tag_hierarchy.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:isar/isar.dart';

/// Da de alta en la base de datos los ficheros que aparecen, vengan de donde
/// vengan.
///
/// Es el único sitio donde nace un contenido: el escaneo del equipo y la
/// descarga de una fuente remota acaban los dos aquí, así que un contenido
/// recién llegado es igual de un lado que del otro (pendiente de revisar, con
/// el creador desconocido) y sólo se diferencian en la fuente que queda
/// anotada.
class MediaRegistry {
  final Isar _database;
  final TagHierarchy _tagHierarchy;

  /// A quién avisar de que ha nacido un contenido.
  ///
  /// Es el único sitio por el que pasan todos, así que es el único sitio donde
  /// hace falta enganchar lo que tenga que ocurrirles a todos —hoy, mandarlos a
  /// reconocer—. Es una función y no un servicio para que el alta no tenga que
  /// saber quién escucha ni para qué: este fichero es de la biblioteca y el
  /// reconocimiento es otra cosa.
  final void Function(int mediaId)? _onRegistered;

  MediaRegistry({
    required Isar database,
    required TagHierarchy tagHierarchy,
    void Function(int mediaId)? onRegistered,
  })  : _database = database,
        _tagHierarchy = tagHierarchy,
        _onRegistered = onRegistered;

  /// Identificador de un contenido a partir de su ruta. Es el mismo desde
  /// siempre: cambiarlo dejaría sin reconocer lo que ya está guardado.
  int idOf(String path) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < path.length) {
      final codeUnit = path.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xff;
      hash *= 0x100000001b3;
    }
    return hash;
  }

  /// Si el fichero de [path] ya está en la base de datos.
  ///
  /// Se mira por identificador y también por ruta: el identificador es el hash
  /// de la ruta con la que se dio de alta, así que un contenido que la
  /// aplicación haya movido a la carpeta de la biblioteca ya no coincide por
  /// hash y volvería a entrar como si fuera nuevo.
  Future<MediaSummaryModel?> existing(String path) async {
    return await _database.mediaSummaryModels.get(idOf(path)) ??
        await _database.mediaSummaryModels.filter().pathEqualTo(path).findFirst();
  }

  /// Da de alta el fichero de [path] como contenido pendiente de revisar, con
  /// los datos por defecto: con el creador desconocido y con la [source] de la
  /// que ha venido.
  ///
  /// [sourceUrls] son las direcciones que dicen de dónde sale el contenido
  /// dentro de la plataforma (la comunidad, el autor, la publicación). Con ellas
  /// se buscan las etiquetas que el usuario haya vinculado a esas direcciones y
  /// el contenido nace ya con ellas puestas. Es un etiquetado que no sabe nada
  /// de la plataforma: lo mismo vale para una API que para una web de la que
  /// sólo se puede leer la dirección.
  ///
  /// [sourceTagName] es la etiqueta de la plataforma, y sólo llega cuando el
  /// usuario ha encendido el auto-etiquetado de la fuente en los ajustes: por
  /// defecto no se crea una etiqueta por plataforma, que la fuente ya queda
  /// anotada en el sumario.
  ///
  /// Devuelve `null` si ya estaba: lo que ya se conoce no se toca, que puede
  /// llevar horas de revisión encima.
  Future<MediaSummaryEntity?> register({
    required String path,
    required ImportSource source,
    String? description,
    String? sourceTagName,
    List<String> sourceUrls = const [],
  }) async {
    if (await existing(path) != null) return null;

    final id = idOf(path);

    final summary = MediaSummaryModel()
      ..id = id
      ..path = path
      ..isImported = false
      ..importSource = source.id;

    final details = MediaModel(id: id, path: path)
      ..downloaded = DateTime.now()
      ..isFavorite = false
      ..description = description;

    // El creador sale de las direcciones igual que las etiquetas; si ninguna
    // está vinculada con nadie, el contenido nace con el desconocido y se le
    // pone a mano al revisarlo.
    final creator =
        await creatorForSourceUrls(sourceUrls) ?? await unknownCreatorModel();
    final sourceTag =
        sourceTagName == null ? null : await _tagNamed(sourceTagName);
    // Con las etiquetas van las que están por encima de ellas: lo que nace con
    // la etiqueta de una comunidad nace también con la de la serie de la que
    // cuelga.
    final automaticTags = await _tagHierarchy
        .withRelatives(await tagsForSourceUrls(sourceUrls));

    await _database.writeTxn(() async {
      await _database.mediaSummaryModels.put(summary);
      await _database.mediaModels.put(details);

      details.creator.value = creator;
      await details.creator.save();

      if (automaticTags.isNotEmpty) {
        await details.tags.update(link: automaticTags);
      }

      if (sourceTag != null) {
        details.source.value = sourceTag;
        await details.source.save();
      }

      summary.details.value = details;
      await summary.details.save();
    });

    // Después de guardar, no antes: quien escuche va a querer leerlo.
    _onRegistered?.call(summary.id);

    return summary.toEntity();
  }

  /// Creador "Unknown", creándolo la primera vez que hace falta.
  ///
  /// Es el creador con el que nacen los contenidos recién dados de alta y el
  /// respaldo cuando el creador de un contenido ya no existe en la base.
  Future<CreatorModel> unknownCreatorModel() async {
    final existing = await _database.creatorModels
        .filter()
        .nameEqualTo(unknownCreator.name)
        .findFirst();
    if (existing != null) return existing;

    final model = CreatorModel.fromEntity(unknownCreator);
    await _database.writeTxn(() async {
      model.id = await _database.creatorModels.put(model);
    });
    return model;
  }

  /// Las etiquetas que el usuario ha vinculado con alguna de [urls].
  ///
  /// Una etiqueta recoge todo lo que cuelga de sus direcciones, así que la
  /// etiqueta de `reddit.com/r/gifs` se la lleva también la publicación
  /// `reddit.com/r/gifs/comments/abc`; la de `reddit.com` se lo llevaría todo.
  ///
  /// Se recorren en memoria las etiquetas que tienen alguna dirección puesta (que
  /// son las pocas que el usuario haya vinculado a mano) porque la comparación es
  /// por tramos de la ruta y no por igualdad, que es algo que un índice no sabe
  /// resolver.
  Future<List<TagModel>> tagsForSourceUrls(List<String> urls) async {
    final normalized = normalizedSourceUrls(urls);
    if (normalized.isEmpty) return const [];

    final candidates = await _database.tagModels
        .filter()
        .sourceUrlsIsNotEmpty()
        .findAll();

    return [
      for (final tag in candidates)
        if (tag.sourceUrls.any(
          (rule) => normalized.any((url) => sourceUrlMatches(url, rule)),
        ))
          tag,
    ];
  }

  /// El creador que el usuario ha vinculado con alguna de [urls], si hay
  /// alguno.
  ///
  /// Funciona igual que [tagsForSourceUrls] (un creador recoge todo lo que
  /// cuelga de sus direcciones), con una diferencia: un contenido tiene un solo
  /// creador, así que de los que encajen se coge el primero. Devuelve `null` si
  /// ninguna dirección está vinculada, que es cuando toca el creador
  /// desconocido.
  Future<CreatorModel?> creatorForSourceUrls(List<String> urls) async {
    final normalized = normalizedSourceUrls(urls);
    if (normalized.isEmpty) return null;

    final candidates = await _database.creatorModels
        .filter()
        .sourceUrlsIsNotEmpty()
        .findAll();

    for (final creator in candidates) {
      final matches = creator.sourceUrls.any(
        (rule) => normalized.any((url) => sourceUrlMatches(url, rule)),
      );
      if (matches) return creator;
    }

    return null;
  }

  /// La etiqueta que se llama [name], creándola la primera vez.
  ///
  /// Es la que se le pone de origen al contenido de una fuente remota, que es
  /// lo que mira la ordenación de ficheros por origen. Al ser una etiqueta
  /// normal, el usuario puede darle avatar o colgarla de otra.
  Future<TagModel> _tagNamed(String name) async {
    final existing =
        await _database.tagModels.filter().nameEqualTo(name).findFirst();
    if (existing != null) return existing;

    final model = TagModel.fromEntity(
      TagEntity(id: unsavedId, name: name, children: const []),
    );
    await _database.writeTxn(() async {
      model.id = await _database.tagModels.put(model);
    });
    return model;
  }
}
