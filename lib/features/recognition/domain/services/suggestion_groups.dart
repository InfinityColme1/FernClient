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

  const SuggestionGroup(this.instances);

  MediaSuggestionEntity get best => instances.first;

  int get count => instances.length;

  /// Si el modelo lo ha visto más de una vez.
  bool get isMultiple => instances.length > 1;

  /// Los identificadores de todas, que es lo que hay que contestar: aceptar o
  /// rechazar van sobre el grupo entero.
  List<int> get ids => [for (final one in instances) one.id];

  /// Las que tienen caja, para poder señalarlas sobre el contenido.
  List<MediaSuggestionEntity> get located =>
      [for (final one in instances) if (one.box != null) one];
}

/// Junta las detecciones que son lo mismo visto varias veces.
///
/// Se agrupa por **modelo y fernie**, no sólo por fernie: el mismo fernie visto
/// por dos modelos distintos son dos opiniones separadas, y juntarlas escondería
/// que uno de los dos lo dice y el otro no.
///
/// El orden de los grupos es el de la primera detección de cada uno, y dentro de
/// cada grupo mandan las más seguras. Así la lista no baila entre dos lecturas.
List<SuggestionGroup> groupSuggestions(
  Iterable<MediaSuggestionEntity> suggestions,
) {
  final byKey = <String, List<MediaSuggestionEntity>>{};

  for (final one in suggestions) {
    final key = '${one.result.modelId}:${one.fernie.id}';

    byKey.putIfAbsent(key, () => []).add(one);
  }

  return [
    for (final group in byKey.values)
      SuggestionGroup(
        group..sort((a, b) => b.confidence.compareTo(a.confidence)),
      ),
  ];
}
