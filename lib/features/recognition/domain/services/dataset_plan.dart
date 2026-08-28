import 'dart:math';

import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';

/// A qué parte del dataset va una imagen.
enum DatasetSplitKind {
  train(folder: 'train'),
  validation(folder: 'val'),
  test(folder: 'test');

  const DatasetSplitKind({required this.folder});

  /// Cómo se llama su carpeta. Son los nombres que espera YOLO.
  final String folder;
}

/// Una región marcada, con lo que hace falta para meterla en un dataset.
///
/// El rectángulo llega **en esquina** (dónde empieza y cuánto mide), que es como
/// se guarda en la base de datos.
class DatasetRegion {
  final int regionId;

  /// De qué contenido es. Es la clave por la que se agrupa, y de eso depende que
  /// el reparto no mienta.
  final int mediaId;
  final String mediaPath;

  /// De qué fotograma, en lo que se mueve. `null` en una imagen.
  final int? frameMs;

  final double x;
  final double y;
  final double w;
  final double h;

  final int classIndex;

  /// Si el contenido sobre el que está marcada ya es definitivo.
  ///
  /// Una región sobre contenido pendiente de revisar se guarda igual —está lista
  /// por si el contenido se confirma— pero **no entrena** (D29). Viaja como un
  /// dato de la región y no se filtra fuera para que la regla viva donde se
  /// puede comprobar: aquí, sin base de datos por medio.
  final bool isDefinitive;

  const DatasetRegion({
    required this.regionId,
    required this.mediaId,
    required this.mediaPath,
    this.frameMs,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.classIndex,
    this.isDefinitive = true,
  });

  /// Si tiene tamaño y su contenido ya está confirmado.
  ///
  /// Una región degenerada no enseña nada y rompería la etiqueta; una sobre
  /// contenido sin confirmar enseñaría algo que el usuario todavía no ha dado
  /// por bueno.
  bool get isUsable => w > 0 && h > 0 && isDefinitive;
}

/// Una línea del fichero de etiquetas.
///
/// YOLO las quiere **en centro**: qué clase, dónde está el medio y cuánto mide.
/// La base de datos las guarda en esquina, así que aquí se convierten.
class DatasetLabel {
  final int classIndex;
  final double centerX;
  final double centerY;
  final double width;
  final double height;

  const DatasetLabel({
    required this.classIndex,
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
  });

  factory DatasetLabel.fromRegion(DatasetRegion region) {
    return DatasetLabel(
      classIndex: region.classIndex,
      centerX: (region.x + region.w / 2).clamp(0.0, 1.0),
      centerY: (region.y + region.h / 2).clamp(0.0, 1.0),
      width: region.w.clamp(0.0, 1.0),
      height: region.h.clamp(0.0, 1.0),
    );
  }

  /// Seis decimales: con menos, una región pequeña en una imagen grande pierde
  /// píxeles por el redondeo.
  String toLine() => '$classIndex '
      '${centerX.toStringAsFixed(6)} '
      '${centerY.toStringAsFixed(6)} '
      '${width.toStringAsFixed(6)} '
      '${height.toStringAsFixed(6)}';
}

/// Una imagen del dataset: de qué fichero sale, de qué fotograma, a qué parte va
/// y qué lleva marcado.
class DatasetImage {
  final int mediaId;
  final String sourcePath;
  final int? frameMs;
  final DatasetSplitKind split;

  /// Todo lo marcado en este fotograma, **de todas las clases**: un fichero
  /// puede llevar regiones de varios fernies y todas van en el mismo `.txt`.
  final List<DatasetLabel> labels;

  /// Cómo se va a llamar el fichero dentro de su carpeta, sin extensión.
  final String stem;

  const DatasetImage({
    required this.mediaId,
    required this.sourcePath,
    this.frameMs,
    required this.split,
    required this.labels,
    required this.stem,
  });

  /// Si hay que sacar el fotograma de dentro de algo que se mueve.
  bool get needsFrameExtraction => frameMs != null;

  String get labelFile => labels.map((label) => label.toLine()).join('\n');
}

/// Lo que se va a escribir en disco, ya decidido.
class DatasetPlan {
  final List<DatasetImage> images;

  /// El nombre de cada clase por su número, que es lo que va en `data.yaml`.
  final Map<int, String> classNames;

  const DatasetPlan({required this.images, required this.classNames});

  List<DatasetImage> of(DatasetSplitKind split) =>
      [for (final image in images) if (image.split == split) image];

  int countIn(DatasetSplitKind split) => of(split).length;

  /// Cuántas regiones hay de cada clase, que es de lo que avisan las
  /// comprobaciones previas al entrenamiento.
  Map<int, int> get regionsByClass {
    final counts = <int, int>{};

    for (final image in images) {
      for (final label in image.labels) {
        counts[label.classIndex] = (counts[label.classIndex] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Sobre cuántos contenidos distintos está marcada cada clase.
  ///
  /// Cien regiones de un solo fichero enseñan el fondo, no el objeto.
  Map<int, int> get mediaByClass {
    final seen = <int, Set<int>>{};

    for (final image in images) {
      for (final label in image.labels) {
        (seen[label.classIndex] ??= {}).add(image.mediaId);
      }
    }

    return {for (final entry in seen.entries) entry.key: entry.value.length};
  }
}

/// Decide qué va a cada parte del dataset.
///
/// Hay dos cosas a la vez, y conviene tenerlas separadas:
///
/// **Los porcentajes son de las regiones de cada fernie.** Poner 70/20/10 en un
/// fernie quiere decir que siete de cada diez de *sus* regiones entrenan, dos
/// validan y una prueba. Cada fernie lleva los suyos y no se hablan entre ellos:
/// añadir uno nuevo al modelo aplica sus porcentajes sobre sus propias regiones
/// y ya está.
///
/// **Pero lo que se mueve de una parte a otra es el contenido entero**, no la
/// región suelta. Un fichero puede llevar diez regiones; si unas cayeran en
/// entrenamiento y otras en validación, el modelo se estaría examinando de la
/// misma imagen con la que ha estudiado y las métricas dirían lo que uno quiere
/// oír. Es el error clásico de estos datasets y se evita aquí, a propósito y por
/// escrito.
///
/// Las dos cosas se cumplen a la vez repartiendo **contenidos** pero llevando la
/// cuenta **en regiones**: a cada contenido se le da la parte que más lejos ande
/// de lo que le tocaba. Con contenidos de tamaños dispares (un vídeo con
/// trescientos fotogramas marcados es un solo contenido) los porcentajes no
/// pueden salir exactos, pero se quedan todo lo cerca que permite no partir
/// ninguno.
///
/// Un contenido con regiones de varios fernies lo coloca el primero que llega, y
/// los siguientes cuentan las suyas donde haya caído y se corrigen con lo que
/// les queda por repartir.
///
/// El reparto es **el mismo siempre** para los mismos datos: se ordena por
/// identificador y se baraja con una semilla fija. Reentrenar sin haber cambiado
/// nada tiene que dar las mismas métricas, o no hay forma de saber si un cambio
/// ha mejorado algo.
DatasetPlan planDataset({
  required List<DatasetRegion> regions,
  required Map<int, DatasetSplit> splitByClass,
  required Map<int, String> namesByClass,
  int seed = 0,
}) {
  final usable = [for (final region in regions) if (region.isUsable) region];

  // Por contenido primero, que es la unidad que se reparte.
  final byMedia = <int, List<DatasetRegion>>{};
  for (final region in usable) {
    (byMedia[region.mediaId] ??= []).add(region);
  }

  // Cuántas regiones pone cada fernie en cada contenido. Es la cuenta con la
  // que se mide el reparto.
  final regionsOf = <int, Map<int, int>>{};
  for (final region in usable) {
    final perMedia = regionsOf[region.classIndex] ??= {};
    perMedia[region.mediaId] = (perMedia[region.mediaId] ?? 0) + 1;
  }

  final splitOf = <int, DatasetSplitKind>{};

  for (final classIndex in regionsOf.keys.toList()..sort()) {
    _assignClass(
      perMedia: regionsOf[classIndex]!,
      split: splitByClass[classIndex] ?? DatasetSplit.balanced,
      splitOf: splitOf,
      seed: seed + classIndex,
    );
  }

  // Ahora sí, una imagen por contenido y fotograma.
  final images = <DatasetImage>[];
  final counters = {for (final kind in DatasetSplitKind.values) kind: 0};

  for (final mediaId in byMedia.keys.toList()..sort()) {
    final kind = splitOf[mediaId] ?? DatasetSplitKind.train;

    // Dentro de un mismo fichero, cada fotograma es una imagen distinta: lo que
    // se recorta de un vídeo en el segundo tres no es lo mismo que en el nueve.
    final byFrame = <int?, List<DatasetRegion>>{};
    for (final region in byMedia[mediaId]!) {
      (byFrame[region.frameMs] ??= []).add(region);
    }

    final frames = byFrame.keys.toList()
      ..sort((a, b) => (a ?? -1).compareTo(b ?? -1));

    for (final frame in frames) {
      final group = byFrame[frame]!
        ..sort((a, b) => a.regionId.compareTo(b.regionId));

      final number = (counters[kind] = counters[kind]! + 1);

      images.add(DatasetImage(
        mediaId: mediaId,
        sourcePath: group.first.mediaPath,
        frameMs: frame,
        split: kind,
        labels: [for (final region in group) DatasetLabel.fromRegion(region)],
        stem: number.toString().padLeft(4, '0'),
      ));
    }
  }

  return DatasetPlan(images: images, classNames: {...namesByClass});
}

/// Reparte los contenidos de un fernie, midiendo en **sus** regiones.
///
/// [perMedia] dice cuántas regiones suyas hay en cada contenido. Se calcula
/// cuántas le tocan a cada parte, se cuentan las que ya han caído en contenidos
/// que colocó otro fernie, y los que quedan libres se van dando a la parte que
/// más lejos ande de su objetivo.
///
/// Es un reparto voraz y no exacto, y no puede serlo: un contenido no se parte,
/// así que un vídeo con trescientos fotogramas marcados va entero a un sitio y
/// mueve el porcentaje lo que lo mueva. Lo que sí garantiza es que ninguna parte
/// se queda vacía teniendo derecho a algo, y que sin contenidos compartidos ni
/// tamaños dispares sale clavado.
void _assignClass({
  required Map<int, int> perMedia,
  required DatasetSplit split,
  required Map<int, DatasetSplitKind> splitOf,
  required int seed,
}) {
  const order = [
    DatasetSplitKind.train,
    DatasetSplitKind.validation,
    DatasetSplitKind.test,
  ];
  final percents = [split.train, split.validation, split.test];

  var total = 0;
  for (final count in perMedia.values) {
    total += count;
  }
  if (total == 0) return;

  final target = [for (final percent in percents) total * percent / 100];
  final placed = [0.0, 0.0, 0.0];

  // Lo que ya está colocado porque el contenido lo puso otro fernie: cuenta
  // igual, y es lo que permite corregirse con lo que queda.
  final free = <int>[];
  for (final mediaId in perMedia.keys.toList()..sort()) {
    final already = splitOf[mediaId];

    if (already == null) {
      free.add(mediaId);
      continue;
    }

    placed[order.indexOf(already)] += perMedia[mediaId]!;
  }

  // Barajado con semilla: el orden de identificadores va con el de importación,
  // y sin barajar el reparto acabaría siendo «lo primero que entró para
  // entrenar, lo último para probar».
  free.shuffle(Random(seed));

  // De mayor a menor: colocando primero los contenidos gordos, los pequeños que
  // vienen detrás sirven para afinar. Al revés, el último en entrar sería el que
  // más descuadra.
  free.sort((a, b) => perMedia[b]!.compareTo(perMedia[a]!));

  for (final mediaId in free) {
    final regions = perMedia[mediaId]!;

    var best = -1;
    var bestDeficit = double.negativeInfinity;

    for (var index = 0; index < order.length; index++) {
      if (percents[index] == 0) continue;

      final deficit = target[index] - placed[index];
      // En empate manda la validación: sin ella el entrenamiento no sabe cuándo
      // parar, y quedarse sin validación es motivo de bloqueo.
      final wins = deficit > bestDeficit ||
          (deficit == bestDeficit && index == 1);

      if (wins) {
        best = index;
        bestDeficit = deficit;
      }
    }

    // Todos los porcentajes a cero no debería pasar (un reparto válido suma
    // cien), pero si pasara, a entrenar: es lo que menos duele.
    if (best < 0) best = 0;

    splitOf[mediaId] = order[best];
    placed[best] += regions;
  }
}
