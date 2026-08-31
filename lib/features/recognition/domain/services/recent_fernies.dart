import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';

/// Pone delante los fernies a los que se les acaba de marcar una región.
///
/// El menú que sale al marcar los enseñaba por orden de creación, con el recién
/// creado arriba. Ese orden vale exactamente una vez: en cuanto hay tres
/// fernies, el de arriba es el que menos se usa. Marcar es un gesto que se
/// repite mucho y casi siempre sobre el mismo, así que lo que tiene que estar a
/// mano es lo último que se usó.
///
/// Va aparte y sobre listas ya leídas para que no cueste una consulta: quien
/// llama ya tiene los fernies delante, y esto sólo los recoloca. Un
/// identificador que ya no existe no encaja con ninguno y desaparece solo.
List<FernieEntity> ferniesByRecent(
  List<FernieEntity> fernies,
  List<int> recentIds,
) {
  if (recentIds.isEmpty) return fernies;

  final byId = {for (final fernie in fernies) fernie.id: fernie};

  final recent = <FernieEntity>[];
  for (final id in recentIds) {
    final fernie = byId.remove(id);
    if (fernie != null) recent.add(fernie);
  }

  // Los demás detrás y en el orden en el que venían: quien no se ha usado
  // todavía no tiene por qué reordenarse.
  return [
    ...recent,
    for (final fernie in fernies)
      if (byId.containsKey(fernie.id)) fernie,
  ];
}
