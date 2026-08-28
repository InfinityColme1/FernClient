import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/recognition_result_repository.dart';
import 'package:flutter/foundation.dart';

/// Qué sugerencias se contestan y con qué.
class AnswerSuggestionsParams {
  final List<int> ids;
  final SuggestionStatus status;

  const AnswerSuggestionsParams({required this.ids, required this.status});
}

/// Da por aceptadas o rechazadas unas cuantas sugerencias.
///
/// En lote y no de una en una porque las dos formas de contestar que tiene el
/// panel —el botón de cada fila y el de «todas»— acaban aquí, y con una sola
/// entrada no hay dos caminos que puedan divergir.
///
/// Contestar **no toca el contenido**: poner la etiqueta es cosa de quien edita
/// el contenido, y va con el resto de sus cambios sin guardar. Aquí sólo se
/// apunta lo que el usuario ha decidido sobre la propuesta, que es lo que
/// después mide el acierto real del modelo.
class AnswerSuggestionsUseCase
    extends UseCase<DataState<int>, AnswerSuggestionsParams> {
  final RecognitionResultRepository _repository;

  AnswerSuggestionsUseCase(this._repository);

  @override
  Future<DataState<int>> call({AnswerSuggestionsParams? params}) async {
    var answered = 0;

    for (final id in params!.ids) {
      final result = await _repository.setStatus(id: id, status: params.status);

      if (result is DataSuccess) {
        answered++;
        continue;
      }

      // Una que falle no puede dejar sin contestar a las demás: son decisiones
      // independientes, y el usuario ya las ha tomado todas. Lo que sí se
      // devuelve es cuántas han cuajado, para que quien llame sepa si hubo
      // problemas.
      debugPrint('No se pudo contestar la sugerencia $id: ${result.exception}');
    }

    return DataSuccess(answered);
  }
}
