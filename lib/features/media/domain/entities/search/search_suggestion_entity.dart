import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:equatable/equatable.dart';

/// Sugerencia del buscador principal.
///
/// Puede ser un contenido (encontrado por su descripción), una etiqueta o un
/// creador; [label] es el nombre con el que se muestra y [imagePath] la imagen
/// que la acompaña: la del propio contenido, o el avatar de la etiqueta o del
/// creador.
///
/// [id] es el de la entidad a la que apunta, que es lo que permite buscar por
/// **ella** al elegirla y no por su nombre: pulsar el creador "Pompeu" trae sus
/// contenidos, no todo lo que contenga "pompeu".
class SearchSuggestionEntity extends Equatable {
  final int id;
  final SearchResultType type;
  final String label;
  final String? imagePath;

  const SearchSuggestionEntity({
    required this.id,
    required this.type,
    required this.label,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, type, label, imagePath];
}
