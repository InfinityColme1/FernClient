import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';

/// Cómo queda la rejilla cuando una importación en marcha suelta un contenido.
///
/// **Se parte de lo que se está viendo, no de una copia aparte.** Esa es toda la
/// regla, y es lo que estaba mal: la importación llevaba su propia lista y la
/// volcaba entera en cada llegada. Al volver a la pantalla de importación se
/// relee de la base de datos, así que había dos listas que podían discrepar —y
/// discrepaban—: la copia de la importación machacaba lo que la relectura había
/// traído, y sólo se recuperaba cerrando la aplicación.
///
/// Lo que ya está no se añade otra vez: la relectura de la base de datos y el
/// flujo de la importación pueden dar el mismo contenido, y de esa coincidencia
/// no puede salir un duplicado en pantalla.
List<MediaSummaryEntity> withArrival(
  List<MediaSummaryEntity>? visible,
  MediaSummaryEntity arrival,
) {
  final current = visible ?? const <MediaSummaryEntity>[];
  if (current.any((each) => each.id == arrival.id)) return current;

  return [...current, arrival];
}
