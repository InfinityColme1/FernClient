import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
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

  MediaRegistry({required Isar database}) : _database = database;

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
  /// los datos por defecto: sin etiquetas, con el creador desconocido y con la
  /// [source] de la que ha venido.
  ///
  /// Devuelve `null` si ya estaba: lo que ya se conoce no se toca, que puede
  /// llevar horas de revisión encima.
  Future<MediaSummaryEntity?> register({
    required String path,
    required ImportSource source,
    String? description,
    String? sourceTagName,
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

    final creator = await unknownCreatorModel();
    final sourceTag =
        sourceTagName == null ? null : await _tagNamed(sourceTagName);

    await _database.writeTxn(() async {
      await _database.mediaSummaryModels.put(summary);
      await _database.mediaModels.put(details);

      details.creator.value = creator;
      await details.creator.save();

      if (sourceTag != null) {
        details.source.value = sourceTag;
        await details.source.save();
      }

      summary.details.value = details;
      await summary.details.save();
    });

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
