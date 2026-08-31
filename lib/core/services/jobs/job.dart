import 'package:equatable/equatable.dart';

/// Qué clase de trabajo largo es.
///
/// Sólo el tipo, sin ningún texto: cómo se llama cada uno en pantalla lo pone la
/// interfaz con el idioma que esté puesto, igual que con el resto del dominio.
enum JobType {
  /// Entrenar un modelo de reconocimiento.
  training,

  /// Reconocer contenido con el árbol de modelos.
  recognition,

  /// Buscar contenido repetido.
  duplicateScan,

  /// Calcular las huellas con las que se compara el contenido.
  hashing,

  /// Traerse contenido de una fuente.
  ///
  /// Se llama así y no `import` porque en Dart eso es una palabra con oficio
  /// propio.
  mediaImport,

  /// Una publicación con varios enlaces, esperando a que el usuario decida qué
  /// se hace con ellos.
  ///
  /// **No es trabajo, es una pregunta**, y por eso no se ejecuta nunca: se queda
  /// en la lista hasta que alguien la abre y contesta, o hasta que la quita. Ver
  /// [isPassive].
  linkReview,

  /// Traerse los enlaces que alguien ya ha elegido.
  linkImport,

  /// Marcar todo el contenido de una etiqueta como regiones de un fernie.
  tagRegions,
}

extension JobTypeBehaviour on JobType {
  /// Este trabajo no se ejecuta: espera al usuario.
  ///
  /// La cola lo deja donde está y no le da turno, que es lo que hace que cinco
  /// preguntas sin contestar no dejen la aplicación sin poder hacer nada. En la
  /// lista se ve como lo que es: algo que está esperando.
  bool get isPassive => this == JobType.linkReview;
}

/// Por dónde va un trabajo.
enum JobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled;

  /// Sigue vivo: o está trabajando o espera su turno.
  bool get isActive => this == JobStatus.queued || this == JobStatus.running;

  /// Ya no va a cambiar más.
  bool get isFinished => !isActive;
}

/// Cuánta prisa corre.
///
/// [low] es para lo que la aplicación hace por su cuenta sin que nadie lo haya
/// pedido (el escaneo periódico de repetidos): no arranca mientras haya algo
/// más importante en marcha y puede tardar lo que haga falta. [high] es lo que
/// el usuario acaba de pedir y está mirando.
enum JobPriority { low, normal, high }

/// Un trabajo largo que corre por detrás mientras se sigue usando la
/// aplicación.
///
/// Es inmutable: la cola va emitiendo copias con el avance, y la interfaz pinta
/// la última que le haya llegado.
class Job extends Equatable {
  final String id;
  final JobType type;
  final JobPriority priority;
  final JobStatus status;

  /// Cuántas unidades van hechas de [total].
  final int done;

  /// Cuántas unidades hay que hacer, o `0` si no se sabe de antemano (entrenar
  /// sabe las épocas, reconocer una carpeta entera no sabe cuántos ficheros hay
  /// hasta que los cuenta).
  final int total;

  /// Qué ha fallado, cuando [status] es [JobStatus.failed].
  final String? error;

  /// Qué está haciendo ahora mismo, dicho por quien lo ejecuta.
  ///
  /// Va aparte del nombre porque cambia: el nombre es «Biblioteca entera» de
  /// principio a fin, y esto es «Figuras de prueba» y un momento después
  /// «Formas nuevas». Sin ello, un trabajo largo es una barra que avanza sin
  /// que se sepa en qué se está yendo el tiempo.
  final String? stage;

  /// Lo que necesita saber quien lo ejecute: el modelo que se entrena, los
  /// contenidos que se reconocen. La cola no lo mira, sólo lo transporta.
  final Map<String, Object?> payload;

  /// La clave con la que un trabajo puede decir **sobre qué** va.
  ///
  /// Está aquí y no en quien lo encola para que la lista de tareas pueda
  /// enseñarlo sin saber de qué tipo de trabajo se trata: si supiera, tendría
  /// que importar cada rincón de la aplicación que encola algo.
  static const nameKey = 'displayName';

  /// Sobre qué va este trabajo, si lo dijo al encolarse.
  ///
  /// Hace falta porque se pueden encolar varios del mismo tipo: «Entrenando
  /// modelo» tres veces seguidas no distingue cuál se está parando al pulsar el
  /// aspa.
  String? get name {
    final value = payload[nameKey];

    return value is String && value.isNotEmpty ? value : null;
  }

  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const Job({
    required this.id,
    required this.type,
    required this.createdAt,
    this.priority = JobPriority.normal,
    this.status = JobStatus.queued,
    this.done = 0,
    this.total = 0,
    this.error,
    this.stage,
    this.payload = const {},
    this.startedAt,
    this.finishedAt,
  });

  /// De 0 a 1, o `null` si no se sabe cuánto queda: es la diferencia entre una
  /// barra que avanza y una que da vueltas.
  double? get progress {
    if (total <= 0) return null;

    return (done / total).clamp(0.0, 1.0);
  }

  Job copyWith({
    JobStatus? status,
    int? done,
    int? total,
    String? error,
    String? stage,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return Job(
      id: id,
      type: type,
      priority: priority,
      createdAt: createdAt,
      payload: payload,
      status: status ?? this.status,
      done: done ?? this.done,
      total: total ?? this.total,
      error: error ?? this.error,
      stage: stage ?? this.stage,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        status,
        done,
        total,
        error,
        // **Sin esto, un cambio sólo de `stage` no se notifica.** La cola
        // descarta la actualización si el trabajo compara igual, así que la
        // línea de estado de la barra de tareas se quedaba con lo de antes: es
        // lo que hacía invisible el «Cancelando…» de un entrenamiento.
        //
        // `payload` sigue fuera a propósito: puede llevar listas de miles de
        // identificadores y se compararía entera en cada avance.
        stage,
        createdAt,
        startedAt,
        finishedAt,
      ];
}
