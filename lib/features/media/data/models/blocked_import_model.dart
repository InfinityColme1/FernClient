import 'package:isar/isar.dart';

part 'blocked_import_model.g.dart';

/// Una pieza de una fuente remota que el usuario ha dicho que no quiere.
///
/// La fuente guarda lo que el usuario tiene marcado, así que cada importación
/// vuelve a ofrecer lo mismo. Eso es correcto y no se toca: lo que faltaba era
/// poder decir de una pieza concreta «ésta no, y no me la vuelvas a ofrecer»,
/// porque hasta ahora la única salida era descartarla otra vez cada vez.
///
/// Se identifica por **su dirección en la fuente** y no por su contenido. Es lo
/// que se conoce antes de descargar, así que el fichero ni se baja. La huella
/// perceptual pillaría además lo mismo subido en otro sitio, pero sólo se puede
/// calcular con el fichero delante: habría que bajarlo igual y lo único que se
/// ahorraría es que apareciera.
///
/// Consecuencia que conviene tener clara: lo mismo subido por otra cuenta, o en
/// otra plataforma, **sí** se volverá a ofrecer. Para eso está el detector de
/// repetidos.
@collection
@Name("BlockedImports")
class BlockedImportModel {
  /// La huella de la fuente y el identificador juntos.
  ///
  /// Así, bloquear dos veces lo mismo no deja dos filas y desbloquear no tiene
  /// que buscar por dos campos.
  Id id = Isar.autoIncrement;

  /// El `ImportSource.id` del que venía.
  @Index()
  late String source;

  /// El `RemoteMediaItem.id`, que es único dentro de esa fuente.
  @Index()
  late String remoteId;

  /// Lo que se leía de la pieza cuando se bloqueó, sólo para poder enseñar la
  /// lista en Ajustes: un identificador a secas no le dice nada a nadie.
  String? description;

  /// La dirección desde la que se ofrecía, si se sabía.
  String? sourceUrl;

  late DateTime at;

  BlockedImportModel();

  /// Con qué identificador se guarda la pareja fuente + pieza.
  ///
  /// FNV-1a de 64 bits sobre los dos juntos, como ya hace `MediaRegistry` con la
  /// ruta de un fichero: es determinista, cabe en un `Id` y no obliga a llevar
  /// un contador.
  static int idOf(String source, String remoteId) {
    const prime = 0x100000001b3;
    var hash = 0xcbf29ce484222325;

    for (final unit in '$source\u0000$remoteId'.codeUnits) {
      hash = (hash ^ unit) * prime;
      // A 63 bits: `Id` es con signo y un negativo lo aceptaría igual, pero un
      // identificador que a veces sale negativo es un quebradero al depurar.
      hash &= 0x7fffffffffffffff;
    }

    return hash;
  }
}
