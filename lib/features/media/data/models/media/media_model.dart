import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:isar/isar.dart';

import '../persona/creator_model.dart';
import '../tag_model.dart';

part 'media_model.g.dart';

@collection
@Name("Media")
class MediaModel {

  Id? id = Isar.autoIncrement;

  late String path;

  /// Cuándo llegó el contenido a la biblioteca.
  ///
  /// Indexado porque es por lo que se ordena la rejilla de fábrica. Con el
  /// índice, Isar recorre las filas **en ese orden** y no tiene que cargarlas
  /// todas para ordenarlas después, que con una biblioteca de decenas de miles
  /// es la diferencia entre abrir la pantalla y esperar a que abra.
  @Index()
  late DateTime downloaded;

  late bool isFavorite;

  String? description;

  final creator = IsarLink<CreatorModel>();

  final tags = IsarLinks<TagModel>();

  final source = IsarLink<TagModel>();

  MediaModel({this.id, required this.path});


  /// [isImported] e [importSource] viven en el sumario, así que se pasan desde
  /// el repositorio.
  ///
  /// Los enlaces son perezosos en Isar: hay que haberlos cargado antes de
  /// llamar a este método, y aun así el creador puede faltar en filas
  /// antiguas, de ahí el `unknownCreator` de reserva.
  MediaEntity toEntity({
    bool isImported = false,
    ImportSource importSource = ImportSource.local,
  }) {
    return MediaEntity(
      id: id!,
      path: path,
      isImported: isImported,
      importSource: importSource,
      downloaded: downloaded,
      isFavorite: isFavorite,
      description: description,
      creator: creator.value?.toEntity() ?? unknownCreator,
      tags: tags.map((tag) => tag.toEntity()).toList(),
      source: source.value?.toEntity(),
    );
  }

  factory MediaModel.fromEntity(MediaEntity entity) {
    final model = MediaModel(
        id: entity.id,
        path: entity.path
    );
    model.downloaded = entity.downloaded;
    model.isFavorite = entity.isFavorite;
    model.description = entity.description;
    // Note: Links should be handled in the repository/mapper context
    // because they require fetching or creating related models in Isar.
    return model;
  }
}
