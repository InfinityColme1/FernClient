import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Fernies que se parecen al texto escrito, para los buscadores. Con el texto
/// vacío devuelve una lista vacía, igual que el de etiquetas.
class SearchFerniesUseCase
    extends UseCase<DataState<List<FernieEntity>>, String> {
  final FernieRepository _repository;

  SearchFerniesUseCase(this._repository);

  @override
  Future<DataState<List<FernieEntity>>> call({String? params}) {
    return _repository.searchFernies(params ?? '');
  }
}
