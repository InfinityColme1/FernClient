import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Creador que ya existe y las etiquetas que se le quieren dejar puestas.
class SaveCreatorTagsParams {
  final int creatorId;
  final List<int> tagIds;

  const SaveCreatorTagsParams({required this.creatorId, required this.tagIds});
}

/// Relaciona unas etiquetas con un creador: a partir de ahí, ponerle el creador
/// a un contenido se las pone también.
///
/// Es la otra mitad de [SaveCreatorSourceUrlsUseCase]. Aquélla dice de dónde
/// sale lo suyo; ésta, qué lleva puesto lo suyo.
///
/// **No toca lo que ya está etiquetado.** Un cambio aquí vale para lo
/// siguiente, no reescribe la biblioteca: relacionar una etiqueta con un
/// creador de cuatrocientos contenidos no puede etiquetar cuatrocientos
/// contenidos sin avisar.
class SaveCreatorTagsUseCase
    extends UseCase<DataState<CreatorEntity>, SaveCreatorTagsParams> {
  final LocalMediaRepository _repository;

  SaveCreatorTagsUseCase(this._repository);

  @override
  Future<DataState<CreatorEntity>> call({SaveCreatorTagsParams? params}) {
    return _repository.saveCreatorTags(params!.creatorId, params.tagIds);
  }
}
