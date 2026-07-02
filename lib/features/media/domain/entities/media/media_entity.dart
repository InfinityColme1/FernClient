import '../persona/creator_entity.dart';
import '../tag_entity.dart';
import 'media_summary_entity.dart';


class MediaEntity extends MediaSummaryEntity {

  final DateTime downloaded;
  final bool isFavorite;

  final CreatorEntity creator;
  final List<TagEntity> ? tags;
  final TagEntity ? source;


  const MediaEntity({
    required super.id,
    required super.path,
    required this.downloaded,
    this.isFavorite = false,
    required this.creator,
    this.tags,
    this.source
});

  @override
  List<Object?> get props => [
    id,
    path,
    downloaded,
    isFavorite,
    creator,
    tags,
    source
  ];
}