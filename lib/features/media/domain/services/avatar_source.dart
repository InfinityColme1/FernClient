import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

/// Si de este contenido se puede elegir **qué trozo** se queda como avatar.
///
/// Sólo de las imágenes quietas. En vídeo y GIF se coge el fotograma entero sin
/// preguntar nada, que es lo que ya hacía: allí lo que se ve no es lo que hay en
/// el fichero, y un recorte marcado sobre un fotograma que se mueve señalaría
/// algo que ya no está.
bool cropsAvatarOf(String path) => !path.isVideoPath && !path.isGifPath;

/// Por qué se está buscando en el diálogo que elige una imagen de la
/// biblioteca: la etiqueta marcada, lo escrito, o las dos cosas.
///
/// Van por el mismo camino que las pastillas de la barra de búsqueda, **y se
/// cruzan**: una etiqueta y un texto enseñan lo que cumple las dos cosas. Aquí
/// no puede haber una segunda forma de buscar que diga algo distinto de la de
/// siempre.
///
/// Sin nada puesto no hay criterios: eso es la biblioteca entera, que no es una
/// búsqueda de nada.
List<SearchCriterionEntity> libraryPickerCriteria({
  TagEntity? tag,
  String query = '',
}) {
  final term = query.trim();

  return [
    if (tag case final tag?)
      SearchCriterionEntity(
        kind: SearchCriterionKind.tag,
        id: tag.id,
        label: tag.name,
      ),
    if (term.isNotEmpty) SearchCriterionEntity.text(term),
  ];
}
