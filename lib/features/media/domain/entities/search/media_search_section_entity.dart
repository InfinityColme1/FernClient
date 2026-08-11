import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:equatable/equatable.dart';

/// Grupo de contenidos de una búsqueda, tal y como se pinta en la rejilla.
///
/// Cada grupo lleva su propia cabecera: [title] es el texto buscado cuando el
/// grupo son las coincidencias por descripción, y el nombre de la etiqueta o del
/// creador en los demás casos. [imagePath] es el avatar que se pinta al lado.
class MediaSearchSectionEntity extends Equatable {
  final SearchResultType type;
  final String title;
  final String? imagePath;
  final List<MediaSummaryEntity> media;

  const MediaSearchSectionEntity({
    required this.type,
    required this.title,
    required this.media,
    this.imagePath,
  });

  @override
  List<Object?> get props => [type, title, imagePath, media];
}
