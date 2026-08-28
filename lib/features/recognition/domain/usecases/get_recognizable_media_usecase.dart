import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';

/// Qué contenido se manda a reconocer al pedir «toda la biblioteca».
class RecognizableMediaParams {
  /// Sólo lo que no se ha mirado nunca.
  ///
  /// Es lo que se ofrece de partida: sin ello, la segunda pulsación vuelve a
  /// pagar por todo lo que ya está hecho. Quien acaba de entrenar un modelo
  /// mejor sí quiere lo contrario, y por eso se puede elegir.
  final bool onlyUnrecognized;

  const RecognizableMediaParams({this.onlyUnrecognized = true});
}

/// Los identificadores de todo lo que se puede mandar a reconocer.
class GetRecognizableMediaUseCase
    extends UseCase<DataState<List<int>>, RecognizableMediaParams> {
  final LocalMediaRepository _repository;

  GetRecognizableMediaUseCase(this._repository);

  @override
  Future<DataState<List<int>>> call({RecognizableMediaParams? params}) {
    return _repository.getRecognizableMediaIds(
      onlyUnrecognized: (params ?? const RecognizableMediaParams())
          .onlyUnrecognized,
    );
  }
}
