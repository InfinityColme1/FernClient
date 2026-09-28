import 'dart:math' as math;

import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';

/// Todas las veces que un modelo ha visto lo mismo en un contenido.
///
/// Un modelo puede ver **cuatro coches en una foto**: son cuatro detecciones de
/// la misma clase, cada una con su rectángulo. En el panel son **una sola fila**
/// —es la misma etiqueta, y ponerla cuatro veces no significa nada— pero las
/// cuatro cajas siguen ahí para poder señalarlas y para poder marcarlas como
/// regiones.
class SuggestionGroup {
  /// Las detecciones, de más a menos segura. La primera manda cuando hay que
  /// enseñar un solo número o un solo avatar.
  final List<MediaSuggestionEntity> instances;

  /// Desde qué parte solapadas —de 0 a 1— se juntan dos cajas en una sola al
  /// enseñarlas. `null` no junta ninguna.
  final double? mergeOverlap;

  const SuggestionGroup(this.instances, {this.mergeOverlap});

  MediaSuggestionEntity get best => instances.first;

  int get count => instances.length;

  /// Si el modelo lo ha visto más de una vez.
  bool get isMultiple => instances.length > 1;

  /// Los identificadores de todas, que es lo que hay que contestar: aceptar o
  /// rechazar van sobre el grupo entero.
  List<int> get ids => [for (final one in instances) one.id];

  /// Las que tienen caja, para poder señalarlas sobre el contenido, **con las
  /// que caen unas encima de otras ya juntas**.
  ///
  /// Un modelo que ve una cara la ve a veces tres veces casi en el mismo sitio:
  /// la cara, la cabeza, la cabeza con el pelo. Son tres propuestas que dicen lo
  /// mismo y que había que aceptar o tirar de una en una. Juntas son una región
  /// en **la media** de las tres, con la confianza de la mejor. Lo que sólo se
  /// roza se queda separado: dos personas una al lado de la otra son dos
  /// regiones.
  ///
  /// Sólo al enseñarlas: en la base de datos siguen las detecciones tal cual,
  /// así que cambiar el ajuste vale también para lo que ya se había reconocido.
  List<MediaSuggestionEntity> get located {
    final boxed = [
      for (final one in instances)
        if (one.box != null) one,
    ];

    final overlap = mergeOverlap;
    if (overlap == null) return boxed;

    return mergeOverlappingDetections(boxed, overlap: overlap);
  }
}

/// Junta las detecciones con caja que se solapan desde [overlap] (de 0 a 1).
///
/// El solapamiento se mide contra **la caja más pequeña de las dos**: una metida
/// entera dentro de otra cuenta como solapada del todo, que es justo el caso que
/// hay que juntar.
///
/// Las que se tocan así forman un grupo, **también de rebote**: si A pisa a B y
/// B pisa a C, las tres son lo mismo aunque A y C no se toquen. Cada grupo
/// queda en **la media** de sus cajas —cada borde, el promedio de los de todas—
/// con el identificador y la confianza de la más segura. La media y no la caja
/// que las engloba: el modelo ha visto lo mismo varias veces con un poco de
/// holgura hacia cada lado, y el sitio de verdad es el del medio.
///
/// Sólo entre las del mismo fotograma: en un vídeo, lo mismo en dos instantes no
/// es la misma región.
///
/// Espera [detections] de más a menos seguras, que es como llegan en un grupo.
List<MediaSuggestionEntity> mergeOverlappingDetections(
  List<MediaSuggestionEntity> detections, {
  required double overlap,
}) {
  final boxed = [
    for (final one in detections)
      if (one.box != null) one,
  ];

  // Unión de conjuntos: cada una apunta a la primera de su grupo, que por el
  // orden de entrada es la más segura.
  final parent = List<int>.generate(boxed.length, (index) => index);

  int root(int index) {
    var at = index;
    while (parent[at] != at) {
      parent[at] = parent[parent[at]];
      at = parent[at];
    }
    return at;
  }

  for (var i = 0; i < boxed.length; i++) {
    for (var j = i + 1; j < boxed.length; j++) {
      final a = boxed[i];
      final b = boxed[j];

      if (a.frameMs != b.frameMs) continue;
      if (_overlapOf(a.box!, b.box!) < overlap) continue;

      final ra = root(i);
      final rb = root(j);
      if (ra == rb) continue;

      // Manda la de menor posición, que es la más segura.
      if (ra < rb) {
        parent[rb] = ra;
      } else {
        parent[ra] = rb;
      }
    }
  }

  final groups = <int, List<MediaSuggestionEntity>>{};
  for (var index = 0; index < boxed.length; index++) {
    groups.putIfAbsent(root(index), () => []).add(boxed[index]);
  }

  return [
    for (final entry in groups.entries)
      entry.value.length == 1
          ? entry.value.single
          : _withBox(boxed[entry.key], _mean(entry.value)),
  ];
}

/// La caja media de [members]: cada borde, el promedio de los de todas.
_Box _mean(List<MediaSuggestionEntity> members) {
  var left = 0.0;
  var top = 0.0;
  var right = 0.0;
  var bottom = 0.0;

  for (final one in members) {
    final box = one.box!;
    left += box.x;
    top += box.y;
    right += box.x + box.w;
    bottom += box.y + box.h;
  }

  final count = members.length;
  left /= count;
  top /= count;
  right /= count;
  bottom /= count;

  return (x: left, y: top, w: right - left, h: bottom - top);
}

typedef _Box = ({double x, double y, double w, double h});

/// Qué parte de la más pequeña de las dos queda dentro de la otra.
double _overlapOf(_Box a, _Box b) {
  final width = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x);
  final height = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y);
  if (width <= 0 || height <= 0) return 0;

  final smaller = math.min(a.w * a.h, b.w * b.h);
  if (smaller <= 0) return 0;

  return (width * height) / smaller;
}

MediaSuggestionEntity _withBox(MediaSuggestionEntity one, _Box box) =>
    MediaSuggestionEntity(
      result: one.result.copyWith(x: box.x, y: box.y, w: box.w, h: box.h),
      fernie: one.fernie,
      tag: one.tag,
      creator: one.creator,
    );

/// Junta las detecciones que son lo mismo visto varias veces.
///
/// Se agrupa por **modelo y fernie**, no sólo por fernie: el mismo fernie visto
/// por dos modelos distintos son dos opiniones separadas, y juntarlas escondería
/// que uno de los dos lo dice y el otro no.
///
/// El orden de los grupos es el de la primera detección de cada uno, y dentro de
/// cada grupo mandan las más seguras. Así la lista no baila entre dos lecturas.
///
/// [mergeOverlapOf] dice, para cada fernie, desde qué parte solapadas —de 0 a
/// 1— se juntan sus cajas al enseñarlas; ver [SuggestionGroup.located]. Cada
/// fernie tiene el suyo: ver `RegionMergeOverlaps`.
List<SuggestionGroup> groupSuggestions(
  Iterable<MediaSuggestionEntity> suggestions, {
  double? Function(int fernieId)? mergeOverlapOf,
}) {
  final byKey = <String, List<MediaSuggestionEntity>>{};

  for (final one in suggestions) {
    final key = '${one.result.modelId}:${one.fernie.id}';

    byKey.putIfAbsent(key, () => []).add(one);
  }

  return [
    for (final group in byKey.values)
      SuggestionGroup(
        group..sort((a, b) => b.confidence.compareTo(a.confidence)),
        mergeOverlap: mergeOverlapOf?.call(group.first.fernie.id),
      ),
  ];
}
