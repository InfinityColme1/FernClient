import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:equatable/equatable.dart';

/// Lo que hay propuesto sobre el contenido que se está viendo.
///
/// Va aparte del `MediaBloc` por lo mismo que el modo fernie: aquél tiene tres
/// estados con su `copyWith` cada uno y ya arrastra veinte campos, y esto no es
/// información del contenido sino de lo que unos modelos opinan sobre él, que
/// puede cambiar sin que el contenido se toque.
/// En qué quedó la última vez que se pidió reconocer.
enum RecognitionAttempt {
  /// Todavía no se ha pedido nada.
  none,

  /// Se ha encolado.
  queued,

  /// No se ha encolado porque no había con qué. El motivo está en
  /// [SuggestionsState.readiness].
  refused,
}

class SuggestionsState extends Equatable {
  /// De qué contenido es esto. Sirve para tirar lo que llegue tarde: leer es
  /// asíncrono y entre medias se puede haber pasado al siguiente.
  final int? mediaId;

  final List<MediaSuggestionEntity> suggestions;

  /// Si se están leyendo. No se enseña un cargando: leer una docena de filas es
  /// instantáneo, y un parpadeo en el panel al pasar de contenido molesta más de
  /// lo que informa.
  final bool isLoading;

  /// Las aceptadas que todavía no se han confirmado.
  ///
  /// Aceptar no baja a la base de datos en el acto: lo que hace es meter la
  /// etiqueta en el contenido que se está editando, y eso no está guardado hasta
  /// que se pulsa «Guardar». Si se apuntara aquí de inmediato y el usuario se
  /// fuera sin guardar, la sugerencia quedaría contestada y la etiqueta no
  /// puesta: se habría perdido, y no habría forma de volver a proponerla salvo
  /// reconociendo otra vez.
  ///
  /// Rechazar sí baja en el acto, y no es una incoherencia: rechazar no cambia
  /// nada del contenido, así que no hay ningún «Guardar» que lo confirme. De
  /// hecho, si alguien rechaza todas y no acepta ninguna, el botón de guardar ni
  /// siquiera se enciende.
  final List<MediaSuggestionEntity> accepted;

  /// Si el árbol da para reconocer algo, y si no, por qué.
  ///
  /// Se sabe **antes** de pulsar nada: un trabajo sin modelos entrenados con los
  /// que trabajar termina en milisegundos y sin dejar rastro, así que ni siquiera
  /// llega a verse en la lista de tareas.
  final RecognitionReadiness readiness;

  /// Cómo acabó la última petición de reconocer.
  ///
  /// La decide el bloc y no la pantalla porque saber si se puede reconocer es
  /// una lectura de la base de datos: mirarlo desde el botón obligaría a
  /// contestar antes de tener la respuesta, y el aviso diría lo que no es.
  final RecognitionAttempt lastAttempt;

  /// Cuántas veces se ha pedido reconocer, se haya encolado o no.
  ///
  /// Es lo que dispara el aviso. Va aparte de [lastAttempt] porque pedirlo dos
  /// veces con el mismo resultado tiene que avisar las dos: con sólo el
  /// resultado, la segunda vez no cambiaría nada y parecería que no ha pasado
  /// nada.
  final int attempts;

  /// Cuántas veces ha terminado aquí un reconocimiento.
  ///
  /// Es un contador y no un `bool` porque lo que hace falta es **avisar cada
  /// vez**: con una bandera, reconocer dos veces seguidas sólo avisaría la
  /// primera, y la segunda volvería a parecer que no ha pasado nada.
  final int finishedRuns;

  /// Cuántas sugerencias dejó el último reconocimiento de aquí.
  final int lastRunSuggestions;

  /// El trabajo del último reconocimiento de este contenido.
  ///
  /// Hace falta para llegar al parte de lo que hicieron los modelos, que se
  /// guarda por trabajo.
  final String? lastJobId;

  /// Si hay un reconocimiento en marcha sobre **este** contenido.
  ///
  /// Sale de la cola de trabajos y no de aquí: la cola es la que sabe por dónde
  /// va, y duplicar ese estado es duplicar la forma de que se desincronice.
  final bool isRecognizing;

  const SuggestionsState({
    this.mediaId,
    this.suggestions = const [],
    this.accepted = const [],
    this.isLoading = false,
    this.isRecognizing = false,
    this.readiness = RecognitionReadiness.unknown,
    this.lastAttempt = RecognitionAttempt.none,
    this.attempts = 0,
    this.finishedRuns = 0,
    this.lastRunSuggestions = 0,
    this.lastJobId,
  });

  /// Las que proponen una etiqueta, que son las que van a la sección de tags.
  List<MediaSuggestionEntity> get tagSuggestions =>
      [for (final one in suggestions) if (one.proposes == FernieLinkKind.tag) one];

  /// Las que no proponen nada: el fernie no enlaza ninguna etiqueta ni ningún
  /// creador, o el que enlazaba ya no existe.
  ///
  /// Se enseñan igualmente, junto a las de etiqueta y sin botón de aceptar. No
  /// esconderlas no es un capricho: la marca de «tiene algo sin mirar» cuenta
  /// **todas** las sugerencias sin contestar, así que una invisible dejaría el
  /// contenido señalado para siempre en la pantalla de importación sin nada que
  /// el usuario pudiera hacer al respecto.
  List<MediaSuggestionEntity> get unlinkedSuggestions => [
        for (final one in suggestions)
          if (one.proposes == FernieLinkKind.none) one,
      ];

  /// Las que proponen un creador.
  List<MediaSuggestionEntity> get creatorSuggestions => [
        for (final one in suggestions)
          if (one.proposes == FernieLinkKind.creator) one,
      ];

  SuggestionsState copyWith({
    int? mediaId,
    List<MediaSuggestionEntity>? suggestions,
    List<MediaSuggestionEntity>? accepted,
    bool? isLoading,
    bool? isRecognizing,
    RecognitionReadiness? readiness,
    RecognitionAttempt? lastAttempt,
    int? attempts,
    int? finishedRuns,
    int? lastRunSuggestions,
    String? lastJobId,
  }) {
    return SuggestionsState(
      mediaId: mediaId ?? this.mediaId,
      suggestions: suggestions ?? this.suggestions,
      accepted: accepted ?? this.accepted,
      isLoading: isLoading ?? this.isLoading,
      isRecognizing: isRecognizing ?? this.isRecognizing,
      readiness: readiness ?? this.readiness,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      attempts: attempts ?? this.attempts,
      finishedRuns: finishedRuns ?? this.finishedRuns,
      lastRunSuggestions: lastRunSuggestions ?? this.lastRunSuggestions,
      lastJobId: lastJobId ?? this.lastJobId,
    );
  }

  @override
  List<Object?> get props => [
        mediaId,
        suggestions,
        accepted,
        isLoading,
        isRecognizing,
        readiness,
        lastAttempt,
        attempts,
        finishedRuns,
        lastRunSuggestions,
        lastJobId,
      ];
}
