import '../persona/creator_entity.dart';
import '../tag_entity.dart';
import 'media_summary_entity.dart';


class MediaEntity extends MediaSummaryEntity {

  final DateTime downloaded;
  final bool isFavorite;

  /// Texto libre que describe el contenido. `null` mientras nadie lo haya
  /// escrito (es el estado en el que queda tras un escaneo).
  final String? description;

  final CreatorEntity creator;
  final List<TagEntity> ? tags;
  final TagEntity ? source;


  const MediaEntity({
    required super.id,
    required super.path,
    super.isImported,
    required this.downloaded,
    this.isFavorite = false,
    this.description,
    required this.creator,
    this.tags,
    this.source
});

  MediaEntity copyWith({
    String? path,
    bool? isImported,
    DateTime? downloaded,
    bool? isFavorite,
    String? description,
    CreatorEntity? creator,
    List<TagEntity>? tags,
    TagEntity? source,
  }) {
    return MediaEntity(
      id: id,
      path: path ?? this.path,
      isImported: isImported ?? this.isImported,
      downloaded: downloaded ?? this.downloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      creator: creator ?? this.creator,
      tags: tags ?? this.tags,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
    id,
    path,
    isImported,
    downloaded,
    isFavorite,
    description,
    creator,
    tags,
    source
  ];
}
