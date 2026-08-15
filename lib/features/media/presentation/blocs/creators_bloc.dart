import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_creators_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'creators_events.dart';
import 'creators_states.dart';

/// Los creadores de la aplicación.
///
/// Es el hermano de `TagsBloc` para la pantalla de gestión de creadores: vive en
/// el localizador para que la lista sobreviva a los cambios de pantalla y para
/// que quien cree un creador desde cualquier sitio pueda pedir que se relea.
class CreatorsBloc extends Bloc<CreatorsEvents, CreatorsState> {
  final GetCreatorsUseCase _getCreators;

  CreatorsBloc({required GetCreatorsUseCase getCreators})
      : _getCreators = getCreators,
        super(const CreatorsState()) {
    on<LoadCreatorsEvent>(onLoadCreators);
  }

  Future<void> onLoadCreators(
    LoadCreatorsEvent event,
    Emitter<CreatorsState> emit,
  ) async {
    // Los creadores que ya hubiera se quedan a la vista mientras se leen los
    // nuevos; lo que dice que hay que esperar es el indicador.
    emit(state.copyWith(isBusy: true));

    final result = await _getCreators();

    emit(CreatorsState(
      creators: result is DataSuccess
          ? result.data ?? const []
          : const <CreatorEntity>[],
      isLoaded: true,
    ));
  }
}
