import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';

/// Guarda de una vez todas las regiones marcadas en una sesión de modo fernie.
///
/// Va en una sola transacción a propósito: se aceptan todas o no se acepta
/// ninguna. Guardar la mitad sería peor que no guardar nada, porque el usuario
/// creería que su trabajo esta a salvo.
class AddFernieRegionsUseCase extends UseCase<DataState<List<FernieRegionEntity>>,
    List<FernieRegionEntity>> {
  final FernieRepository _repository;

  AddFernieRegionsUseCase(this._repository);

  @override
  Future<DataState<List<FernieRegionEntity>>> call({
    List<FernieRegionEntity>? params,
  }) {
    return _repository.addRegions(params ?? const []);
  }
}
