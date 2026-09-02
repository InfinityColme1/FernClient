import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_relatives_usecase.dart';

/// Las etiquetas que [creator] trae consigo: las suyas y lo que ellas arrastran
/// —su rama y sus hermanas—.
///
/// **Sólo dice qué trae, no dónde va.** Quien lo pide se lo suma a lo que el
/// contenido tenga en ese momento, y eso lo decide el bloc con lo que hay en el
/// panel ahora: aquí se trabajaría con la foto de cuando se abrió el diálogo, y
/// cualquier cosa que se hubiera tocado mientras tanto se perdería.
///
/// Las suyas **y** lo que arrastran: `GetTagRelativesUseCase` contesta sólo lo
/// que viene *con* las que se le dan, sin ellas. Dándolas por hechas, poner un
/// creador ponía la madre de su etiqueta y no la etiqueta.
///
/// Está aquí y no en cada sitio porque a un contenido se le pone un creador por
/// dos caminos desde el panel —eligiéndolo en su diálogo y aceptando lo que
/// propone un modelo— y los dos acaban escribiendo la lista de etiquetas tal
/// cual se deja. Con la regla escrita dos veces, el mismo creador daría dos
/// resultados según por dónde se le hubiera puesto: es el fallo que ya tuvieron
/// una vez las etiquetas hermanas.
///
/// Lo automático —al importar, al marcar un fernie— no pasa por aquí: eso lo
/// resuelve el repositorio al escribir el creador, que es donde no hay panel que
/// enseñe nada.
Future<List<TagEntity>> tagsOfCreator(CreatorEntity creator) async {
  if (creator.tags.isEmpty) return const [];

  final result = await getIt<GetTagRelativesUseCase>()(params: creator.tags);

  final relatives = result is DataSuccess && result.data != null
      ? result.data!
      : const <TagEntity>[];

  final known = <int>{};

  return [
    for (final tag in [...creator.tags, ...relatives])
      if (known.add(tag.id)) tag,
  ];
}
