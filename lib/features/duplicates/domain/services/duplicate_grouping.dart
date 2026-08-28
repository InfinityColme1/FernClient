import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';
import 'package:flutter/foundation.dart';

/// Un contenido con sus dos hashes, que es todo lo que la agrupación necesita
/// saber de él.
@immutable
class HashedMedia {
  final int mediaId;
  final int dHash;
  final int pHash;

  const HashedMedia({
    required this.mediaId,
    required this.dHash,
    required this.pHash,
  });

  @override
  bool operator ==(Object other) =>
      other is HashedMedia &&
      other.mediaId == mediaId &&
      other.dHash == dHash &&
      other.pHash == pHash;

  @override
  int get hashCode => Object.hash(mediaId, dHash, pHash);
}

/// Un puñado de contenidos que parecen el mismo.
@immutable
class DuplicateGroup {
  /// Los contenidos, en orden ascendente para que dos escaneos den lo mismo.
  final List<int> mediaIds;

  /// Lo más lejos que están dos cualesquiera de ellos entre sí.
  ///
  /// Es lo que ordena la lista de la pantalla: primero lo idéntico, que es lo
  /// fácil de decidir, y al final lo que hay que mirar con calma.
  ///
  /// Se mide **entre todos los miembros**, no sólo entre los que quedaron
  /// emparejados. En un grupo que se formó en cadena —A se parece a B y B a C,
  /// pero A y C no— lo que hay que mirar con calma es justo lo lejos que están A
  /// y C, y contar sólo los pares cercanos lo haría pasar por fácil.
  final int maxDistance;

  const DuplicateGroup({required this.mediaIds, required this.maxDistance});

  @override
  bool operator ==(Object other) =>
      other is DuplicateGroup &&
      other.maxDistance == maxDistance &&
      listEquals(other.mediaIds, mediaIds);

  @override
  int get hashCode => Object.hash(Object.hashAll(mediaIds), maxDistance);

  @override
  String toString() => 'DuplicateGroup($mediaIds, d=$maxDistance)';
}

/// Junta los contenidos que se parecen lo bastante.
///
/// Compararlos todos contra todos crece con el cuadrado de la biblioteca: con
/// cincuenta mil son mil doscientos millones de pares. Hay un atajo, pero **sólo
/// sirve con listones bajos**, y conviene saber por qué antes de confiar en él:
/// si se parten los 64 bits en cuatro bloques y dos hashes difieren en tres bits
/// o menos, por fuerza queda algún bloque idéntico —tres diferencias no llenan
/// cuatro bloques—. Con ocho ya no: se reparten dos por bloque y no queda
/// ninguno limpio.
///
/// Así que el reparto en bloques vale hasta [_blocks] − 1, o sea hasta tres, y a
/// partir de ahí se compara sin atajos. Y el listón de fábrica son ocho, así que
/// **el camino normal es el de todos contra todos**: eso es lo que hay que medir
/// cuando se mida, y es por lo que agrupar se hace en otro hilo.
///
/// Es exacto en los dos caminos: no se pierde ningún par que estuviera por debajo
/// del listón. Un atajo que se salta pares deja duplicados sin encontrar y nadie
/// se entera.
///
/// Los dos hashes cuentan: basta con que **uno** vea cerca a los dos contenidos.
/// El dHash aguanta los reescalados y el pHash los cambios de brillo, y una copia
/// puede haber pasado por cualquiera de las dos cosas.
List<DuplicateGroup> groupDuplicates(
  List<HashedMedia> media, {
  int threshold = defaultDuplicateThreshold,
}) {
  if (media.length < 2) return const [];

  final pairs = _closePairs(media, threshold);
  if (pairs.isEmpty) return const [];

  return _componentsOf(media, pairs);
}

/// En cuántos bloques se parte cada hash para buscar candidatos.
const _blocks = 4;

/// Un par de contenidos cercanos, por su posición en la lista.
typedef _Pair = (int a, int b);

/// Los pares que están por debajo del listón, con su distancia.
List<(_Pair, int)> _closePairs(List<HashedMedia> media, int threshold) {
  // Con un listón tan alto que el reparto en bloques dejaría de garantizar un
  // bloque idéntico, se compara todo contra todo. Es el camino de fábrica.
  if (threshold >= _blocks) return _allPairs(media, threshold);

  return _bucketedPairs(media, threshold);
}

/// Todos contra todos.
///
/// Sin mapa y sin comprobar si el par ya estaba: recorriendo `b > a` cada pareja
/// sale una sola vez, así que preguntarlo era construir una tupla y consultar una
/// tabla mil doscientos millones de veces para que la respuesta fuera siempre no.
List<(_Pair, int)> _allPairs(List<HashedMedia> media, int threshold) {
  final pairs = <(_Pair, int)>[];

  for (var a = 0; a < media.length; a++) {
    final one = media[a];

    for (var b = a + 1; b < media.length; b++) {
      final distance = _distanceBetween(one, media[b]);

      if (distance <= threshold) pairs.add(((a, b), distance));
    }
  }

  return pairs;
}

/// Sólo los que comparten algún trozo de hash. Aquí sí hay que deduplicar: dos
/// contenidos pueden coincidir en varios bloques y por los dos hashes.
List<(_Pair, int)> _bucketedPairs(List<HashedMedia> media, int threshold) {
  final pairs = <(_Pair, int)>[];
  final seen = <_Pair>{};

  void consider(int a, int b) {
    if (a == b) return;

    final key = a < b ? (a, b) : (b, a);
    if (!seen.add(key)) return;

    final distance = _distanceBetween(media[key.$1], media[key.$2]);
    if (distance <= threshold) pairs.add((key, distance));
  }

  for (final buckets in [
    _bucketsOf(media, (one) => one.dHash),
    _bucketsOf(media, (one) => one.pHash),
  ]) {
    for (final bucket in buckets.values) {
      if (bucket.length < 2) continue;

      for (var i = 0; i < bucket.length; i++) {
        for (var j = i + 1; j < bucket.length; j++) {
          consider(bucket[i], bucket[j]);
        }
      }
    }
  }

  return pairs;
}

/// Los índices de cada contenido agrupados por trozo de hash.
///
/// La clave lleva **qué bloque es** además de su valor: un cubo tiene que
/// significar «el mismo trozo en el mismo sitio». Sin eso, dos hashes que
/// coinciden en trozos distintos caen juntos y se comparan sin motivo. No da
/// resultados falsos —la distancia se calcula igual— pero es trabajo de más.
Map<(int, int), List<int>> _bucketsOf(
  List<HashedMedia> media,
  int Function(HashedMedia) hashOf,
) {
  final buckets = <(int, int), List<int>>{};

  for (var index = 0; index < media.length; index++) {
    final hash = hashOf(media[index]);

    for (var block = 0; block < _blocks; block++) {
      final chunk = (hash >>> (block * 16)) & 0xffff;

      (buckets[(block, chunk)] ??= <int>[]).add(index);
    }
  }

  return buckets;
}

/// Lo más lejos que están dos cualesquiera de un grupo.
///
/// Se mide entre todos los miembros y no sólo entre los emparejados: un grupo
/// formado en cadena —A con B y B con C, pero A y C no— pasaría por idéntico
/// contando sólo los pares cercanos, y la pantalla lo pondría el primero, entre
/// los que se deciden sin mirar. Son grupos de dos o tres copias, así que
/// medirlo entero no cuesta nada.
int _spanOf(List<HashedMedia> media, Set<int> indexes) {
  final all = indexes.toList(growable: false);

  var span = 0;
  for (var i = 0; i < all.length; i++) {
    for (var j = i + 1; j < all.length; j++) {
      final distance = _distanceBetween(media[all[i]], media[all[j]]);

      if (distance > span) span = distance;
    }
  }

  return span;
}

/// Lo cerca que están dos contenidos: lo que diga el hash más generoso.
int _distanceBetween(HashedMedia one, HashedMedia other) {
  final byD = hammingDistance(one.dHash, other.dHash);
  final byP = hammingDistance(one.pHash, other.pHash);

  return byD < byP ? byD : byP;
}

/// Junta en un grupo todo lo que esté conectado por algún par.
///
/// Es transitivo a propósito: si A se parece a B y B a C, los tres van al mismo
/// grupo aunque A y C no se parezcan entre sí. Son la misma imagen pasando por
/// copias sucesivas, y separarlos obligaría a decidir dos veces sobre lo mismo.
List<DuplicateGroup> _componentsOf(
  List<HashedMedia> media,
  List<(_Pair, int)> pairs,
) {
  final parent = List<int>.generate(media.length, (index) => index);

  int rootOf(int index) {
    var current = index;
    while (parent[current] != current) {
      // Aplanado sobre la marcha: sin esto, una cadena larga de copias hace que
      // cada consulta recorra la cadena entera.
      parent[current] = parent[parent[current]];
      current = parent[current];
    }

    return current;
  }

  for (final (pair, _) in pairs) {
    final one = rootOf(pair.$1);
    final other = rootOf(pair.$2);

    if (one != other) parent[one] = other;
  }

  // Un conjunto por componente: con `contains` sobre una lista, un grupo de
  // trescientas copias del mismo dibujo cuesta el cuadrado de trescientas.
  final members = <int, Set<int>>{};
  for (final (pair, _) in pairs) {
    for (final index in [pair.$1, pair.$2]) {
      (members[rootOf(index)] ??= <int>{}).add(index);
    }
  }

  final groups = [
    for (final entry in members.entries)
      DuplicateGroup(
        mediaIds: [for (final index in entry.value) media[index].mediaId]..sort(),
        maxDistance: _spanOf(media, entry.value),
      ),
  ];

  // Lo idéntico primero, que es lo que se decide sin pensar; y con la misma
  // distancia, por identificador, para que dos escaneos den el mismo orden.
  groups.sort((one, other) {
    final byDistance = one.maxDistance.compareTo(other.maxDistance);

    return byDistance != 0
        ? byDistance
        : one.mediaIds.first.compareTo(other.mediaIds.first);
  });

  return groups;
}

/// Lo que hace falta para agrupar, en un solo objeto.
///
/// Existe porque `compute` sólo lleva un argumento al otro hilo, y el listón
/// tiene que viajar con los contenidos: agrupar con el listón de fábrica cuando
/// el usuario lo había movido daría un resultado que no se corresponde con lo que
/// dicen los ajustes.
@immutable
class GroupingRequest {
  final List<HashedMedia> media;
  final int threshold;

  const GroupingRequest({required this.media, required this.threshold});
}

/// Agrupa en otro hilo.
///
/// Comparar cada contenido con todos los demás crece con el cuadrado de la
/// biblioteca: medido, veinte mil contenidos son segundos y cincuenta mil son
/// medio minuto. En el hilo de la interfaz eso es la aplicación congelada, y para
/// el escaneo de fondo —que existe precisamente para no notarse— es lo contrario
/// de lo que promete.
Future<List<DuplicateGroup>> groupInIsolate(GroupingRequest request) =>
    compute(groupRequest, request);

/// Lo que corre en el otro hilo. Tiene que ser una función de primer nivel.
List<DuplicateGroup> groupRequest(GroupingRequest request) =>
    groupDuplicates(request.media, threshold: request.threshold);
