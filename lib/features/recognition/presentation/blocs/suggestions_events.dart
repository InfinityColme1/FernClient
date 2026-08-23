import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';

abstract class SuggestionsEvents {
  const SuggestionsEvents();
}

/// Lee lo que hay propuesto sobre este contenido.
///
/// Se pide al abrir el visor y al pasar de uno a otro, tenga el panel abierto o
/// no: el botón de la barra necesita saber si ya hay algo antes de que nadie
/// abra nada.
class LoadSuggestionsEvent extends SuggestionsEvents {
  final int mediaId;

  /// Si esta lectura viene de un reconocimiento que acaba de terminar.
  ///
  /// Sólo entonces tiene sentido avisar de que no se ha encontrado nada: al
  /// abrir un contenido cualquiera, lo normal es que no haya sugerencias y
  /// decirlo cada vez sería ruido.
  final bool afterRecognizing;

  const LoadSuggestionsEvent(this.mediaId, {this.afterRecognizing = false});
}

/// Manda a reconocer el contenido que se está viendo.
///
/// Encola: reconocer un vídeo son varias predicciones y puede tardar, así que ni
/// bloquea la pantalla ni se pierde al cambiar de contenido.
class RecognizeCurrentMediaEvent extends SuggestionsEvents {
  const RecognizeCurrentMediaEvent();
}

/// La cola ha cambiado.
///
/// Es interno: lo dispara la suscripción a la cola, no una pantalla. Sirve para
/// dos cosas, y las dos importan: saber si este contenido se está reconociendo
/// ahora mismo, y releer en cuanto deja de estarlo, que es lo que hace que las
/// sugerencias aparezcan solas sin salir y volver a entrar.
class JobsChangedEvent extends SuggestionsEvents {
  final List<Job> jobs;

  const JobsChangedEvent(this.jobs);
}

/// El usuario dice que sí a unas cuantas sugerencias.
///
/// No escribe nada todavía: quien las acepta es también quien mete la etiqueta
/// en el contenido que está editando, y eso no baja a la base de datos hasta que
/// se guarda. Apuntarlas aquí de inmediato dejaría la sugerencia contestada y la
/// etiqueta sin poner si el usuario se marchara sin guardar.
///
/// En lote porque el botón de cada fila y el de «aceptar todas» son lo mismo con
/// distinto número de elementos.
class SuggestionsAcceptedEvent extends SuggestionsEvents {
  final List<MediaSuggestionEntity> suggestions;

  const SuggestionsAcceptedEvent(this.suggestions);
}

/// El usuario dice que no a unas cuantas sugerencias.
///
/// Esto sí baja en el acto: rechazar no cambia nada del contenido, así que no
/// hay ningún «Guardar» que pudiera confirmarlo. Quien rechaza todas y no acepta
/// ninguna no llega a encender el botón de guardar, y con un rechazo aplazado se
/// habría quedado sin registrar.
class SuggestionsRejectedEvent extends SuggestionsEvents {
  final List<MediaSuggestionEntity> suggestions;

  const SuggestionsRejectedEvent(this.suggestions);
}

/// El contenido se ha guardado: lo aceptado ya es de verdad.
///
/// Lo dispara el mismo sitio que guarda el contenido. Es lo que convierte «he
/// dicho que sí» en «esto lo acertó el modelo», que es de donde sale su
/// rendimiento real.
class SuggestionsCommittedEvent extends SuggestionsEvents {
  const SuggestionsCommittedEvent();
}
