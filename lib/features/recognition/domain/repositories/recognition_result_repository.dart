import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';

/// Lo que los modelos han propuesto sobre los contenidos.
///
/// Una propuesta no es una etiqueta: vive aquí hasta que alguien la mira, y sólo
/// si la acepta pasa a tocar el contenido. Mezclarlas dejaría que un modelo a
/// medio entrenar ensuciara la biblioteca sin que nadie lo hubiera revisado.
abstract class RecognitionResultRepository {
  /// Lo propuesto sobre un contenido, de más seguro a menos.
  ///
  /// Por confianza y no por fecha: quien lo abre viene a decir que sí o que no,
  /// y lo que más probablemente sea correcto es lo primero que quiere ver.
  Future<DataState<List<RecognitionResultEntity>>> getForMedia(int mediaId);

  /// Cambia lo que hay propuesto sobre un contenido por lo que se acaba de ver.
  ///
  /// Reemplaza y no añade: reconocer otra vez el mismo contenido con un modelo
  /// mejor tiene que dar **su** respuesta, no la de antes y la de ahora juntas.
  /// Lo ya revisado —aceptado o rechazado— no se toca: es la única medida del
  /// acierto real de un modelo, y también evita volver a preguntar por algo que
  /// el usuario ya contestó.
  ///
  /// Deja el contenido marcado según si queda algo por mirar, y con la fecha de
  /// cuándo se reconoció, **en la misma escritura**: si la marca y las filas se
  /// separan, la pantalla de importación filtra por una cosa y enseña otra.
  ///
  /// Con [returnToReview], el contenido que reciba alguna sugerencia deja de ser
  /// definitivo y vuelve a la pantalla de importación. Es la decisión D16: una
  /// sugerencia sin validar es contenido a medias, y dejarlo en la biblioteca
  /// como si nada esconde el trabajo pendiente. Va aquí y no en una escritura
  /// aparte por lo mismo que la marca: entre las dos escrituras el contenido
  /// estaría en la biblioteca con sugerencias sin revisar.
  ///
  /// Sin sugerencias no se mueve nada: reconocer algo y no encontrarle nada no
  /// es motivo para sacarlo de la biblioteca.
  Future<DataState<int>> replaceSuggestions({
    required int mediaId,
    required List<RecognitionResultEntity> results,
    bool returnToReview = false,
  });

  /// Da una propuesta por aceptada o rechazada.
  ///
  /// Actualiza también si al contenido le queda algo por mirar.
  Future<DataState<RecognitionResultEntity>> setStatus({
    required int id,
    required SuggestionStatus status,
  });

  /// Borra lo rechazado hace más de [before].
  ///
  /// Los rechazos sirven un tiempo para contar el acierto real de un modelo, y
  /// después son sólo tamaño: esta colección crece con cada contenido y cada
  /// modelo. Los aceptados no se tocan.
  Future<DataState<int>> purgeRejectedBefore(DateTime before);
}
