import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Cambia nombre, avatar y enlace de un fernie. Sus regiones no se tocan: el
/// identificador es el mismo y siguen colgando de él.
///
/// Y si el enlace nuevo es una etiqueta marcada, **el fernie queda marcado**.
/// Un fernie enlazado a una etiqueta escondida es esa etiqueta dicha con otro
/// nombre: sus regiones son recortes del contenido que la lleva, y lo que
/// propone al detectarse es justo lo que la marca escondía. Pedirle al usuario
/// que se acuerde de marcarlo aparte es pedirle que no se olvide nunca.
///
/// Se **escribe** en lugar de deducirse al leer, al revés que la rama de las
/// etiquetas o que los modelos. Aquí interesa que se vea: el interruptor de la
/// ficha aparece encendido y el distintivo sale en la lista, así que la marca
/// deja de ser una consecuencia invisible del enlace. Y como es una marca suya,
/// se queda puesta si más adelante se quita el enlace, que es lo prudente.
class UpdateFernieUseCase
    extends UseCase<DataState<FernieEntity>, FernieEntity> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  UpdateFernieUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<FernieEntity>> call({FernieEntity? params}) async {
    final saved = await _repository.updateFernie(params!);
    if (saved is! DataSuccess || saved.data == null) return saved;

    final tagId = params.linkedTagId;

    // `marksTag` y no `hidesTag`: lo que importa es que la etiqueta esconda
    // contenido, no que el filtro esté puesto ahora mismo. Enlazar con una
    // marcada mientras se está mirando sin filtro tiene que marcar igual.
    if (tagId == null || !_visibility.marksTag(tagId)) return saved;
    if (saved.data!.isNsfw) return saved;

    final marked = await _repository.setFernieNsfw(params.id, isNsfw: true);
    if (marked is! DataSuccess) return saved;

    // Se relee para devolver el fernie tal y como ha quedado: la ficha enciende
    // su interruptor con esto, y sin releer lo dejaría apagado sobre algo que ya
    // está marcado.
    return _repository.getFernie(params.id);
  }
}
