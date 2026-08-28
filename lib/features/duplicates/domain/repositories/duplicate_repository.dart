import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:Fern/features/duplicates/data/services/perceptual_hash.dart';

/// Todo lo que el contenido repetido necesita de la base de datos.
abstract class DuplicateRepository {
  /// Los contenidos vivos con lo que hace falta para decidir si hay que
  /// hashearlos.
  ///
  /// Sin lo que está en la papelera: lo que ya se ha tirado no puede ser el
  /// duplicado de nada.
  Future<DataState<List<HashableMedia>>> getHashable();

  /// Guarda los hashes de un contenido y la fecha en que se calcularon.
  Future<DataState<bool>> saveHashes(int mediaId, PerceptualHashes hashes);

  /// Borra las huellas de todo el contenido, para que se vuelvan a calcular.
  ///
  /// No toca los grupos: los descartados son decisión del usuario y borrarlos
  /// aquí haría reaparecer todo lo que ya había contestado. Devuelve a cuántos
  /// contenidos les ha quitado la huella.
  Future<DataState<int>> clearHashes();

  /// Los contenidos que ya tienen hash, listos para comparar.
  Future<DataState<List<HashedMedia>>> getHashed();

  /// Los grupos tal y como quedaron la última vez.
  Future<DataState<List<KnownGroup>>> getKnownGroups();

  /// Guarda lo que ha encontrado un escaneo.
  ///
  /// Lo que el usuario ya contestó se queda como estaba: guardar un escaneo no
  /// puede resucitar un grupo que alguien descartó. Devuelve cuántos son nuevos,
  /// que es lo que se cuenta en el aviso.
  ///
  /// Con [retireUnseen] se retiran además **los grupos sin contestar que este
  /// escaneo ya no ha encontrado**. Sin eso, la lista sólo crece: cuando a un
  /// grupo le aparece una copia más pasa a ser otro grupo —lo identifican sus
  /// contenidos— y el anterior se queda ahí para siempre, enseñando lo mismo dos
  /// veces. Y bajar el listón desde los ajustes no quitaría de la lista nada de
  /// lo que ya no lo cumple.
  ///
  /// Va por parámetro y no siempre porque retirar sólo tiene sentido cuando el
  /// escaneo ha podido comparar de verdad: si no había ni una huella que mirar,
  /// «no he encontrado nada» no significa que no haya nada.
  Future<DataState<int>> saveGroups(
    List<ReconciledGroup> groups, {
    bool retireUnseen = false,
  });

  /// Los grupos que hay que enseñar, de menor a mayor distancia.
  ///
  /// Sin los que se han quedado sin copias que comparar: si una de las dos se
  /// mandó a la papelera por otro camino, el grupo ya no es una decisión, y
  /// enseñarlo invita a conservar precisamente la copia que ya está borrada.
  /// No se borran, se esconden: de la papelera se vuelve durante siete días, y
  /// con la copia vuelve el grupo.
  ///
  /// Lo mismo con lo que esconde el filtro NSFW, y cada grupo llega **sólo con
  /// las copias que se pueden enseñar**: comparar dos copias es abrirlas, y un
  /// recuento que incluyera las escondidas contaría que están ahí. El escaneo,
  /// en cambio, las mira todas: lo que se filtra es la vista, no el trabajo.
  Future<DataState<List<DuplicateGroupSummary>>> getGroupsToReview();

  /// Da un grupo por revisado.
  Future<DataState<bool>> markResolved(int groupId);

  /// Marca que ese grupo no era de duplicados.
  Future<DataState<bool>> markDismissed(int groupId);
}

/// Un grupo guardado, con lo que la pantalla necesita para pintarlo.
class DuplicateGroupSummary {
  final int id;
  final List<int> mediaIds;
  final int maxDistance;
  final DateTime foundAt;

  const DuplicateGroupSummary({
    required this.id,
    required this.mediaIds,
    required this.maxDistance,
    required this.foundAt,
  });
}
