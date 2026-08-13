import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_tree_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tags_events.dart';
import 'tags_states.dart';

/// Las etiquetas de la aplicación, con su jerarquía.
///
/// Es único y vive en el localizador porque quien las enseña es el menú lateral,
/// que está en el marco de la aplicación y no en una pantalla: la lista se lee
/// una vez y se vuelve a leer cuando se crea una etiqueta desde cualquier sitio.
class TagsBloc extends Bloc<TagsEvents, TagsState> {
  final GetTagTreeUseCase _getTagTree;

  TagsBloc({required GetTagTreeUseCase getTagTree})
      : _getTagTree = getTagTree,
        super(const TagsState()) {
    on<LoadTagsEvent>(onLoadTags);
  }

  Future<void> onLoadTags(LoadTagsEvent event, Emitter<TagsState> emit) async {
    // Las etiquetas que ya hubiera se quedan a la vista mientras se leen las
    // nuevas; lo que dice que hay que esperar es el indicador.
    emit(state.copyWith(isBusy: true));

    final result = await _getTagTree();

    emit(TagsState(
      tags: result is DataSuccess
          ? result.data ?? const []
          : const <TagEntity>[],
      isLoaded: true,
    ));
  }
}
