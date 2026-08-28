import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Fernies que se parecen al texto escrito, para los buscadores. Con el texto
/// vacío devuelve una lista vacía, igual que el de etiquetas.
///
/// Los escondidos no se autocompletan. Un buscador que los propusiera sería la
/// forma más fácil de saltarse el filtro: bastaría con escribir tres letras.
class SearchFerniesUseCase
    extends UseCase<DataState<List<FernieEntity>>, String> {
  final FernieRepository _repository;
  final ContentVisibility _visibility;

  SearchFerniesUseCase(
    this._repository, {
    ContentVisibility visibility = const ContentVisibility(),
  }) : _visibility = visibility;

  @override
  Future<DataState<List<FernieEntity>>> call({String? params}) async {
    final result = await _repository.searchFernies(params ?? '');
    if (result is! DataSuccess) return result;

    return DataSuccess([
      for (final fernie in result.data ?? const <FernieEntity>[])
        if (!_visibility.hidesFernie(fernie.id)) fernie,
    ]);
  }
}
