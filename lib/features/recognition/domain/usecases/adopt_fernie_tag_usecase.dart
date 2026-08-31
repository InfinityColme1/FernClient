import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Le da al fernie la etiqueta que le corresponde por su nombre, creándola si no
/// existía, y lo deja enlazado con ella.
///
/// Es lo que hace aceptable la sugerencia de un fernie que no enlaza nada. Antes
/// esas filas sólo se podían rechazar: el modelo acertaba, se veía que acertaba,
/// y lo único que se podía hacer era decirle que no.
///
/// **Enlaza además de etiquetar**, y eso es lo que arregla el problema de raíz:
/// sin el enlace, la siguiente detección del mismo fernie volvería a llegar sin
/// proponer nada y habría que repetir esto una vez por contenido.
///
/// Un fernie cuya etiqueta alguien borró llega igual de vacío y se trata igual:
/// se recrea por el nombre. Distinguirlos obligaría a guardar qué enlace tuvo
/// antes, y el botón haría cosas distintas en dos filas que se ven idénticas.
class AdoptFernieTagUseCase
    extends UseCase<DataState<TagEntity>, FernieEntity> {
  final LocalMediaRepository _media;
  final FernieRepository _fernies;
  final SaveTagUseCase _saveTag;

  AdoptFernieTagUseCase({
    required LocalMediaRepository media,
    required FernieRepository fernies,
    required SaveTagUseCase saveTag,
  })  : _media = media,
        _fernies = fernies,
        _saveTag = saveTag;

  @override
  Future<DataState<TagEntity>> call({FernieEntity? params}) async {
    final fernie = params!;
    final name = fernie.name.trim();

    if (name.isEmpty) {
      return DataException(Exception('El fernie ${fernie.id} no tiene nombre'));
    }

    // Ya enlazado no hay nada que adoptar. No es un caso raro: aceptar dos
    // sugerencias del mismo fernie pasa por aquí dos veces, y la segunda tiene
    // que encontrárselo hecho.
    if (fernie.linkedTagId case final linked?) {
      final existing = await _media.getTag(linked);

      if (existing.data case final tag?) return DataSuccess(tag);
    }

    // La que ya se llama así antes que una nueva: crear una segunda «Patas» no
    // se puede —los nombres no se repiten— y, si se pudiera, partiría en dos lo
    // que el usuario ve como una sola etiqueta.
    final found = await _media.findTagNamed(name);
    if (found is DataException) return DataException(found.exception!);

    var tag = found.data;

    if (tag == null) {
      final created = await _saveTag(
        params: SaveTagParams(
          tag: TagEntity(id: unsavedId, name: name, children: const []),
        ),
      );
      if (created is DataException) {
        return DataException(created.exception!);
      }

      tag = created.data!;
    }

    // El enlace se escribe con la etiqueta ya en la mano, no antes: si crearla
    // falla, el fernie se queda como estaba en vez de apuntar a algo que no
    // llegó a existir.
    //
    // Que el enlace falle no tira lo hecho: la etiqueta existe y ponerla en el
    // contenido sigue siendo correcto. Lo único que se pierde es no tener que
    // repetir esto la próxima vez.
    await _fernies.updateFernie(
      fernie.copyWith(linkedTagId: tag.id, linkedName: tag.name),
    );

    return DataSuccess(tag);
  }
}
