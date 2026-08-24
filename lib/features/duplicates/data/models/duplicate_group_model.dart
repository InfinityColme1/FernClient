import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:isar/isar.dart';

part 'duplicate_group_model.g.dart';

/// Un puñado de contenidos que parecen el mismo, tal y como se guarda.
///
/// Se guarda en vez de recalcularlo cada vez que se abre la pantalla porque
/// encontrarlos cuesta un escaneo entero, y porque hay dos cosas que sólo tienen
/// sentido si sobreviven: que el usuario ya lo revisó, y que dijo que no eran
/// duplicados. Sin lo segundo, cada escaneo automático volvería a poner delante
/// los mismos falsos positivos.
@collection
@Name("DuplicateGroups")
class DuplicateGroupModel {
  Id id = Isar.autoIncrement;

  /// Los contenidos del grupo, ordenados.
  late List<int> mediaIds;

  /// Cómo se reconoce este grupo de un escaneo a otro.
  ///
  /// Es la lista de contenidos hecha texto. Está guardada e indexada, y no
  /// calculada al vuelo, porque cruzar los grupos nuevos con los que ya se
  /// conocían es lo primero que hace cada escaneo: sin índice sería recorrer la
  /// tabla entera por cada grupo encontrado.
  ///
  /// El índice es normal y no único: uno único genera una API que Isar todavía
  /// marca como experimental, y no hace falta —quien guarda ya busca por firma
  /// antes de escribir, que es donde se decide si se actualiza o se crea.
  @Index()
  late String signature;

  /// La mayor distancia que hay dentro del grupo.
  ///
  /// Es lo que ordena la pantalla: primero lo idéntico, que se decide sin
  /// pensar.
  late int maxDistance;

  late DateTime foundAt;

  /// El usuario lo revisó y decidió, aunque decidiera no borrar nada.
  bool isResolved = false;

  /// El usuario dijo «estos no son duplicados»: no se vuelve a proponer.
  bool isDismissed = false;

  KnownGroup toKnown() => KnownGroup(
        mediaIds: mediaIds,
        isResolved: isResolved,
        isDismissed: isDismissed,
      );
}
