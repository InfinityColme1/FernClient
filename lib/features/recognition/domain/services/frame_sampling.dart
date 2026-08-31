import 'package:Fern/core/constants/app_constants.dart';

/// En qué momentos se mira un contenido que se mueve.
///
/// Una imagen se predice y ya. Un vídeo hay que muestrearlo: mirarlo entero es
/// pagar una predicción por fotograma —treinta por segundo— para responder algo
/// que casi siempre se decide con cinco.
///
/// Reparto **uniforme y sin los extremos**: el primer fotograma de un vídeo es a
/// menudo negro y el último un cartel de cierre, así que empezar en cero y
/// terminar en la duración es tirar dos de las cinco miradas. Se reparten por el
/// centro de tramos iguales, que es lo mismo que decir «un vistazo por cada
/// trozo».
///
/// Es puro: se prueba sin abrir un fichero.
List<Duration> sampleFrames({
  required Duration duration,
  int count = defaultFrameSamples,
}) {
  if (duration <= Duration.zero) return const [Duration.zero];

  final wanted = count.clamp(1, maxFrameSamples);

  // Con uno solo, el de en medio: es el que menos probabilidades tiene de ser un
  // negro de entrada o de salida.
  if (wanted == 1) return [duration ~/ 2];

  final step = duration.inMilliseconds / wanted;

  return [
    for (var index = 0; index < wanted; index++)
      Duration(milliseconds: (step * (index + 0.5)).round()),
  ];
}

/// Ordena lo extraído como se pidió, dejando fuera lo que no salió.
///
/// Sacar los fotogramas de una sola apertura obliga a saltar de menor a mayor
/// —ir y volver dentro de un vídeo cuesta— y a devolverlos por momento, no en
/// una lista. Aquí se recompone el orden en que se pidieron, que es el del
/// vídeo y con el que cuenta quien los mira.
///
/// Lo que falta simplemente no está: un fotograma que no se pudo sacar es una
/// mirada menos, no un hueco que rellenar con nada.
List<T> framesInOrder<T>(
  List<Duration> asked,
  Map<Duration, T> extracted,
) {
  return [
    for (final moment in asked)
      if (extracted[moment] case final frame?) frame,
  ];
}

/// Qué fotogramas distintos hay que mirar para cubrir estos momentos.
///
/// Un GIF tiene los fotogramas que tiene. Pedirle cinco miradas a uno de tres
/// hace que dos caigan en el mismo, y mirar dos veces la misma imagen es pagar
/// dos predicciones por una respuesta que ya se tenía.
///
/// [indexAt] dice qué fotograma toca en cada momento. Devuelve los índices sin
/// repetir y en el orden en que aparecen.
List<int> distinctFrames(
  List<Duration> moments,
  int Function(Duration) indexAt,
) {
  final seen = <int>{};

  return [
    for (final moment in moments)
      if (seen.add(indexAt(moment))) indexAt(moment),
  ];
}

/// Junta lo visto en varios fotogramas en una sola respuesta por fernie.
///
/// Un fernie se da por detectado si aparece **en algún fotograma**, y se guarda
/// la confianza **más alta** con el momento en que se dio. Pedir que aparezca en
/// varios sería más estricto, pero un personaje que sale tres segundos en un
/// vídeo de dos minutos aparecería en un solo fotograma de cinco, y ése es
/// justamente el caso que se quiere encontrar.
List<T> bestPerFernie<T>(
  Iterable<T> detections, {
  required int Function(T) fernieOf,
  required double Function(T) confidenceOf,
}) =>
    topPerFernie(
      detections,
      fernieOf: fernieOf,
      confidenceOf: confidenceOf,
      limit: 1,
    );

/// Lo mismo, pero quedándose con las [limit] mejores de cada fernie.
///
/// Un modelo puede ver **lo mismo varias veces** en un contenido: cuatro coches
/// en una foto son cuatro detecciones de la clase «coche». Quedarse sólo con la
/// mejor tiraba las otras tres antes de que llegaran a la pantalla, y con ellas
/// la posibilidad de marcarlas como regiones.
///
/// **Con tope**, y por eso hay un tope: una foto de un aparcamiento puede dar
/// cincuenta, y eso son cincuenta filas por contenido en la base y un panel
/// imposible de leer. Lo elige el usuario en los ajustes.
///
/// Salen ordenadas de más a menos confianza: la primera es la que manda cuando
/// hay que enseñar un solo número.
List<T> topPerFernie<T>(
  Iterable<T> detections, {
  required int Function(T) fernieOf,
  required double Function(T) confidenceOf,
  required int limit,
}) {
  if (limit <= 0) return const [];

  final byFernie = <int, List<T>>{};

  for (final detection in detections) {
    byFernie.putIfAbsent(fernieOf(detection), () => []).add(detection);
  }

  final kept = <T>[];

  for (final group in byFernie.values) {
    group.sort((a, b) => confidenceOf(b).compareTo(confidenceOf(a)));
    kept.addAll(group.take(limit));
  }

  return kept;
}

/// La caja de una detección, tal y como hay que guardarla.
///
/// El sidecar la manda en el formato de ultralytics —**centro y tamaño**, ya
/// normalizados de 0 a 1—, y FeRN guarda las regiones con la **esquina superior
/// izquierda** y el tamaño, que es lo que el visor pinta sin convertir nada.
///
/// Traducir entre los dos formatos es el tipo de cosa que se hace mal una vez y
/// no se nota: una caja mal convertida sale desplazada media anchura, que es
/// exactamente el aspecto de un modelo que detecta regular. Por eso está aquí,
/// suelto y probado, y no dentro de la función que lee el JSON.
///
/// Devuelve `null` si lo que llega no tiene forma de caja o no ocupa nada.
({double x, double y, double w, double h})? boxFromCenter(Object? box) {
  if (box is! List) return null;

  final values = [
    for (final one in box.take(4))
      if (one is num) one.toDouble(),
  ];

  if (values.length < 4) return null;

  final [centerX, centerY, width, height] = values;

  if (width <= 0 || height <= 0) return null;

  return (
    x: centerX - width / 2,
    y: centerY - height / 2,
    w: width,
    h: height,
  );
}
