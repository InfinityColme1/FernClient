
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:equatable/equatable.dart';

class MediaSummaryEntity extends Equatable {
  final int id; // Cambiado a int no nulo
  final String path;
  final bool isImported; // Nuevo campo

  /// Marcado para borrar: no se muestra en contenido ni en importación, sólo en
  /// la pantalla de eliminados.
  final bool isDeleted;

  /// Cuándo se marcó para borrar: pasada una semana, el contenido sale solo de
  /// la base de datos. `null` en lo que no está marcado.
  final DateTime? deletedAt;

  /// De dónde ha llegado el contenido: el equipo o una plataforma remota. Es lo
  /// que filtra la rejilla de la pantalla de importación.
  ///
  /// No tiene nada que ver con la etiqueta de origen de [MediaEntity], que es un
  /// dato del contenido y lo pone quien lo revisa.
  final ImportSource importSource;

  /// El identificador de la pieza en la fuente de la que vino, si se sabe.
  ///
  /// Es lo que permite decir «esto no me lo vuelvas a ofrecer»: la fuente lo da
  /// antes de descargar, así que un bloqueo se resuelve sin bajar el fichero.
  /// `null` en lo local y en lo que entró antes de que esto se guardara.
  final String? remoteId;

  /// La página de la que salió, si se sabe. Es lo que permite volver a verla
  /// desde la lista de lo que se ha dicho que no se vuelva a importar.
  final String? sourceUrl;

  /// Si algún modelo ha propuesto algo sobre esto y nadie lo ha contestado.
  ///
  /// Está en el sumario y no se pregunta por las sugerencias de cada celda a
  /// propósito: la rejilla de importación pinta cientos de miniaturas, y una
  /// consulta por celda para decidir si lleva un distintivo es una consulta por
  /// celda de más.
  final bool hasPendingSuggestions;

  /// Cuándo se miró por última vez con los modelos. `null` si nunca.
  ///
  /// Va junto a lo anterior porque el filtro de la pantalla de importación las
  /// necesita a las dos: «con sugerencias» y «sin mirar nunca» son dos listas
  /// distintas, y la segunda no se puede sacar de la primera.
  final DateTime? recognizedAt;

  /// Lo que mide el contenido, en píxeles. `null` mientras no se sepa.
  ///
  /// Está aquí y no se pregunta al fichero porque **la rejilla lo necesita para
  /// colocar cada celda**, y averiguarlo obliga a cargar el fichero entero en
  /// memoria para leerle la cabecera. Con mil trescientos contenidos eso son mil
  /// trescientas lecturas completas de disco cada vez que se abre la pantalla, y
  /// es lo que hacía que desplazarse deprisa fuera a tirones.
  ///
  /// Se rellena al dar de alta el contenido. Lo que entró antes de que esto
  /// existiera lo va rellenando la propia rejilla, la primera vez que lo pinta.
  final int? width;
  final int? height;

  /// Si ya se sabe lo que mide, que es lo que decide si hay que ir al fichero.
  bool get hasSize => width != null && height != null && width! > 0 && height! > 0;

  const MediaSummaryEntity({
    required this.id,
    required this.path,
    this.isImported = false,
    this.isDeleted = false,
    this.deletedAt,
    this.importSource = ImportSource.local,
    this.remoteId,
    this.sourceUrl,
    this.hasPendingSuggestions = false,
    this.recognizedAt,
    this.width,
    this.height,
  });

  @override
  List<Object?> get props => [
        id,
        path,
        isImported,
        isDeleted,
        deletedAt,
        importSource,
        remoteId,
        sourceUrl,
        hasPendingSuggestions,
        recognizedAt,
        width,
        height,
      ];
}