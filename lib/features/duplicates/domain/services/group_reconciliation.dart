import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:flutter/foundation.dart';

/// Un grupo tal y como quedó la última vez que alguien lo miró.
@immutable
class KnownGroup {
  /// Los contenidos que lo formaban, ordenados.
  final List<int> mediaIds;

  /// El usuario lo revisó y decidió, aunque decidiera no borrar nada.
  final bool isResolved;

  /// El usuario dijo «estos no son duplicados».
  final bool isDismissed;

  const KnownGroup({
    required this.mediaIds,
    this.isResolved = false,
    this.isDismissed = false,
  });

  /// Cómo se reconoce este grupo de un escaneo a otro.
  ///
  /// Son sus contenidos y nada más: ni la distancia ni la fecha, que cambian al
  /// recalcular sin que el grupo sea otro.
  String get signature => signatureOf(mediaIds);
}

/// La firma de un grupo a partir de sus contenidos.
String signatureOf(Iterable<int> mediaIds) =>
    ([...mediaIds]..sort()).join(',');

/// Lo que hay que hacer con un grupo recién encontrado.
enum GroupOutcome {
  /// Es nuevo: hay que guardarlo y enseñarlo.
  fresh,

  /// Ya se conocía y sigue sin revisar: se deja como estaba.
  known,

  /// El usuario dijo que no eran duplicados: no se vuelve a proponer.
  dismissed,

  /// El usuario ya lo resolvió: no se vuelve a proponer.
  resolved,
}

/// Un grupo encontrado, con lo que toca hacer con él.
@immutable
class ReconciledGroup {
  final DuplicateGroup group;
  final GroupOutcome outcome;

  const ReconciledGroup({required this.group, required this.outcome});

  /// Si hay que ponerlo delante del usuario.
  bool get needsReview => outcome == GroupOutcome.fresh;

  @override
  bool operator ==(Object other) =>
      other is ReconciledGroup &&
      other.group == group &&
      other.outcome == outcome;

  @override
  int get hashCode => Object.hash(group, outcome);

  @override
  String toString() => 'ReconciledGroup(${group.mediaIds}, $outcome)';
}

/// Cruza lo que acaba de encontrar el escaneo con lo que ya se sabía.
///
/// Sin esto, cada escaneo automático volvería a poner delante los mismos falsos
/// positivos que el usuario ya descartó, y el aviso del menú pasaría a ser ruido
/// permanente: la primera vez se mira, la tercera se ignora, y con ella se
/// ignoran también los grupos que sí valían la pena.
///
/// Un grupo se reconoce **por los contenidos que lo forman**. Si aparece una
/// copia más, es otro grupo y vuelve a preguntarse: el usuario dijo que aquellos
/// dos no eran el mismo, no que éste tercero no lo fuera.
List<ReconciledGroup> reconcileGroups(
  List<DuplicateGroup> found,
  Iterable<KnownGroup> known,
) {
  final bySignature = {
    for (final one in known) one.signature: one,
  };

  return [
    for (final group in found)
      ReconciledGroup(
        group: group,
        outcome: _outcomeOf(bySignature[signatureOf(group.mediaIds)]),
      ),
  ];
}

GroupOutcome _outcomeOf(KnownGroup? known) {
  if (known == null) return GroupOutcome.fresh;
  if (known.isDismissed) return GroupOutcome.dismissed;
  if (known.isResolved) return GroupOutcome.resolved;

  return GroupOutcome.known;
}
