import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:isar/isar.dart';
import 'media_model.dart';

part 'media_summary_model.g.dart';

@collection
@Name("MediaSummaries")
class MediaSummaryModel {
  Id id = Isar.autoIncrement; // Usaremos el hash aquí

  @Index(unique: true, replace: true)
  late String path;

  bool isImported = false; // Nuevo campo para diferenciar

  /// Fuente de la que ha llegado el contenido, con el identificador de
  /// [ImportSource]. Es lo que filtra la rejilla de la pantalla de importación.
  ///
  /// Lo que se guardó antes de que hubiera fuentes remotas se lee como local,
  /// que es de donde vino.
  @Index()
  String importSource = ImportSource.local.id;

  /// El identificador de la pieza en la fuente de la que vino, si se sabe.
  ///
  /// Es lo que hace falta para poder decir «esto no me lo vuelvas a ofrecer»:
  /// se compara con el `RemoteMediaItem.id` que la fuente da **antes de
  /// descargar**, así que un bloqueo se resuelve sin bajar el fichero.
  ///
  /// `null` en lo local y en todo lo que entró antes de que esto se guardara.
  /// Para eso hay respaldo: en lo remoto el fichero se guarda con el propio
  /// identificador por nombre, así que se puede recuperar de la ruta. El
  /// respaldo no vale para lo que salió de un comprimido —esos ficheros se
  /// llaman como venían dentro—, y de ahí que se guarde.
  String? remoteId;

  /// Contenido marcado para borrar: sigue en la base de datos, pero sólo se ve
  /// en la pantalla de eliminados hasta que se restablezca o se fuerce el
  /// borrado definitivo.
  bool isDeleted = false;

  /// Cuándo se marcó para borrar, que es lo que decide cuándo caduca: pasada la
  /// semana de gracia, la papelera se vacía sola. `null` en lo que no está
  /// marcado.
  DateTime? deletedAt;

  /// Tiene sugerencias sin revisar.
  ///
  /// Se guarda aquí, repetido, para poder filtrar la rejilla de importación sin
  /// preguntar por las sugerencias de cada elemento: son cientos de contenidos y
  /// serían cientos de consultas por cada pintado.
  @Index()
  bool hasPendingSuggestions = false;

  /// Lo que mide el contenido, en píxeles. `null` mientras no se sepa.
  ///
  /// Se guarda para que la rejilla no tenga que abrir el fichero sólo para saber
  /// cómo colocarlo: leer la cabecera de una imagen obliga a cargarla entera en
  /// memoria, y con mil contenidos eso es lo que hacía que desplazarse deprisa
  /// fuera a tirones.
  int? mediaWidth;
  int? mediaHeight;

  /// El usuario ha marcado **este contenido** como NSFW, uno a uno o en tanda.
  ///
  /// Es una marca propia y no la que hereda de sus etiquetas: las dos existen y
  /// se suman. Separarlas es lo que permite que desmarcar una etiqueta no se
  /// lleve por delante lo que alguien marcó a mano, y que el contenido nuevo que
  /// entre en una etiqueta marcada quede escondido sin tener que reescribir
  /// nada.
  ///
  /// Indexado: la lista de lo marcado se pregunta al arrancar y cada vez que
  /// cambia algo, y sin índice sería recorrer la biblioteca entera.
  @Index()
  bool isNsfw = false;

  /// Cuándo se reconoció por última vez.
  ///
  /// Evita repasar lo ya hecho al pedir «reconocer toda la biblioteca», que con
  /// unos miles de contenidos es la diferencia entre unos minutos y una tarde.
  DateTime? recognizedAt;

  /// Cómo se ve este contenido, para reconocer que otro es el mismo.
  ///
  /// Los dos hashes perceptuales: no dicen qué bytes tiene el fichero sino qué
  /// aspecto tiene la imagen, que es lo que hace que la misma foto bajada de dos
  /// sitios distintos se reconozca aunque no comparta un solo byte.
  ///
  /// Indexado el primero: el escaneo agrupa por los bits altos para no comparar
  /// todo contra todo, y ese índice es lo que hace que buscar candidatos no
  /// recorra la tabla entera.
  @Index()
  int? perceptualHash;

  int? dctHash;

  /// Cuándo se calcularon. `null` es «todavía sin mirar».
  ///
  /// Es lo que hace el escaneo incremental: la primera pasada sobre una
  /// biblioteca grande es la cara, y las siguientes sólo tocan lo que ha entrado
  /// desde entonces.
  DateTime? hashedAt;

  final details = IsarLink<MediaModel>();

  MediaSummaryModel();

  MediaSummaryEntity toEntity() {
    return MediaSummaryEntity(
        id: id,
        path: path,
        isImported: isImported,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        importSource: ImportSource.fromId(importSource),
        remoteId: remoteId,
        hasPendingSuggestions: hasPendingSuggestions,
        recognizedAt: recognizedAt,
        width: mediaWidth,
        height: mediaHeight,
    );
  }

  factory MediaSummaryModel.fromEntity(MediaSummaryEntity entity) {
    final model = MediaSummaryModel()
      ..id = entity.id
      ..path = entity.path
      ..isImported = entity.isImported
      ..isDeleted = entity.isDeleted
      ..deletedAt = entity.deletedAt
      ..importSource = entity.importSource.id
      ..remoteId = entity.remoteId
      ..mediaWidth = entity.width
      ..mediaHeight = entity.height;
    return model;
  }
}