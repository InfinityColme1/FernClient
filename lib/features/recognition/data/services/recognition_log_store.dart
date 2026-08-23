import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';

/// El parte de lo que hizo cada reconocimiento, guardado en memoria.
///
/// En memoria y no en la base de datos a propósito: es material de diagnóstico
/// —«¿por qué aquí no ha salido nada?»— que sólo interesa mientras el usuario
/// tiene la pregunta fresca. Bajarlo a disco significaría una fila por contenido
/// y por modelo en cada reconocimiento, que en una biblioteca grande son cientos
/// de miles de filas para responder algo que se pregunta dos veces al mes.
///
/// Se guarda **por trabajo**, que es como se llega a él: la lista de tareas
/// enseña los trabajos terminados y desde ahí se abre el suyo.
class RecognitionLogStore {
  /// Cuántos trabajos se recuerdan. El mismo número que la cola conserva: más
  /// sería guardar el parte de trabajos que ya no se pueden ni ver.
  final int limit;

  /// Cuántos contenidos se recuerdan **de cada trabajo**.
  ///
  /// Sin este tope, «reconocer la biblioteca» sobre diez mil contenidos deja
  /// diez mil partes en memoria hasta que se cierre la aplicación, cada uno con
  /// una entrada por modelo y sus detecciones. Y no sirven de nada: nadie abre
  /// un log de diez mil filas a buscar la suya.
  ///
  /// Se conservan **los últimos**, que son los que se estaban mirando cuando
  /// terminó.
  final int perJobLimit;

  final Map<String, List<MediaRecognitionLog>> _byJob = {};
  final List<String> _order = [];

  RecognitionLogStore({this.limit = 20, this.perJobLimit = 200});

  /// Apunta lo que pasó con un contenido dentro de un trabajo.
  void add(String jobId, MediaRecognitionLog log) {
    final logs = _byJob.putIfAbsent(jobId, () {
      _order.add(jobId);
      return [];
    });

    logs.add(log);

    // El más viejo del trabajo se cae. Uno a uno y no en bloque: así el coste va
    // repartido en vez de dar un tirón cada doscientos contenidos.
    if (logs.length > perJobLimit) logs.removeAt(0);

    _trim();
  }

  /// El parte de un trabajo, en el orden en que se fue reconociendo.
  List<MediaRecognitionLog> of(String jobId) =>
      List.unmodifiable(_byJob[jobId] ?? const []);

  /// Si hay algo que enseñar de este trabajo.
  bool has(String jobId) => (_byJob[jobId] ?? const []).isNotEmpty;

  /// Lo que se apuntó de un contenido concreto dentro de un trabajo.
  ///
  /// Es lo que abre el aviso del visor: allí se reconoce un solo contenido y lo
  /// que interesa es el suyo, no el del trabajo entero.
  MediaRecognitionLog? forMedia(String jobId, int mediaId) {
    for (final log in _byJob[jobId] ?? const <MediaRecognitionLog>[]) {
      if (log.mediaId == mediaId) return log;
    }

    return null;
  }

  void clear() {
    _byJob.clear();
    _order.clear();
  }

  void _trim() {
    while (_order.length > limit) {
      _byJob.remove(_order.removeAt(0));
    }
  }
}
