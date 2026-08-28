import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/media_size_store.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Guarda lo que mide cada contenido, de una tanda de una vez.
///
/// Lo que se da de alta hoy ya nace con su tamaño; esto es para lo que entró
/// antes, que lo va descubriendo la rejilla la primera vez que lo pinta. Una vez
/// guardado, esa pantalla deja de abrir ficheros para saber cómo colocarlos.
class RememberMediaSizesUseCase
    extends UseCase<DataState<int>, Map<int, MediaSize>> {
  final LocalMediaRepository _repository;

  RememberMediaSizesUseCase({required LocalMediaRepository repository})
      : _repository = repository;

  @override
  Future<DataState<int>> call({Map<int, MediaSize>? params}) {
    return _repository.rememberSizes(params ?? const {});
  }
}
