import 'package:equatable/equatable.dart';

/// A qué se engancha un fernie cuando un modelo lo detecta.
///
/// No son tres cosas que hace el fernie, son tres formas de existir: o propone
/// una etiqueta, o propone un creador, o no propone nada y sólo sirve para
/// entrenar. Los dos enlaces a la vez no tienen sentido, y es este tipo el que
/// lo impide sin necesidad de comprobarlo en cada pantalla.
enum FernieLinkKind { none, tag, creator }

/// Un conjunto de regiones marcadas sobre contenido multimedia, con un nombre y
/// un avatar que las identifican.
///
/// Es la unidad con la que se entrena: un modelo aprende a reconocer fernies, no
/// contenidos sueltos. El enlace opcional a una etiqueta o a un creador es lo
/// que convierte una detección en una propuesta de etiquetado; sin él el fernie
/// es auxiliar y sólo aporta muestras.
class FernieEntity extends Equatable {
  final int id;
  final String name;
  final String? picturePath;

  /// Etiqueta que se propondrá al detectarlo. Excluyente con [linkedCreatorId].
  final int? linkedTagId;

  /// Creador que se propondrá al detectarlo. Excluyente con [linkedTagId].
  final int? linkedCreatorId;

  /// Nombre de lo enlazado, resuelto al leer de la base de datos. Sólo es para
  /// enseñarlo: quien manda es el identificador.
  final String? linkedName;

  final DateTime createdAt;

  /// Cuántas regiones tiene y sobre cuántos contenidos distintos.
  ///
  /// Los dos números viven aquí porque los dos hacen falta a la vez para saber
  /// si el fernie da para entrenar: cien regiones de un único contenido enseñan
  /// el fondo, no el objeto.
  ///
  /// Es lo **marcado**, que es lo que el usuario ha hecho. Lo que de eso llega a
  /// entrenar es [usableRegionCount].
  final int regionCount;
  final int mediaCount;

  /// Lo mismo, pero contando sólo lo que de verdad entrena.
  ///
  /// Una región sobre contenido todavía sin confirmar se guarda igual —está
  /// lista por si el contenido se confirma— pero **no entra en el conjunto de
  /// datos** (D29). Contarla junto a las demás dejaba los avisos de calidad
  /// mintiendo por lo alto: un fernie con cien regiones sin confirmar decía que
  /// estaba listo para entrenar y entrenaba con cero.
  ///
  /// Son dos números y no uno porque el usuario necesita ver los dos: el que ha
  /// marcado explica el trabajo hecho, y el que entrena explica el resultado.
  final int usableRegionCount;
  final int usableMediaCount;

  FernieEntity({
    required this.id,
    required this.name,
    this.picturePath,
    this.linkedTagId,
    this.linkedCreatorId,
    this.linkedName,
    DateTime? createdAt,
    this.regionCount = 0,
    this.mediaCount = 0,
    int? usableRegionCount,
    int? usableMediaCount,
  })  : createdAt = createdAt ?? DateTime.now(),
        // Sin decir nada se asume que todo lo marcado entrena. Es lo que vale
        // para quien construye un fernie sin mirar la biblioteca —las pruebas y
        // los formularios— y deja el filtrado donde sí se sabe: el repositorio.
        usableRegionCount = usableRegionCount ?? regionCount,
        usableMediaCount = usableMediaCount ?? mediaCount;

  FernieLinkKind get linkKind {
    if (linkedTagId != null) return FernieLinkKind.tag;
    if (linkedCreatorId != null) return FernieLinkKind.creator;
    return FernieLinkKind.none;
  }

  /// Copia con los enlaces reescritos desde cero.
  ///
  /// [linkedTagId] y [linkedCreatorId] no se arrastran con el `??` de siempre a
  /// propósito: pasar de etiqueta a creador exige poder dejar el otro en `null`,
  /// y con el operador de siempre no habría manera de quitarlo.
  FernieEntity copyWith({
    int? id,
    String? name,
    String? picturePath,
    int? linkedTagId,
    int? linkedCreatorId,
    String? linkedName,
    int? regionCount,
    int? mediaCount,
    int? usableRegionCount,
    int? usableMediaCount,
  }) {
    return FernieEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      picturePath: picturePath ?? this.picturePath,
      linkedTagId: linkedTagId,
      linkedCreatorId: linkedCreatorId,
      linkedName: linkedName,
      createdAt: createdAt,
      regionCount: regionCount ?? this.regionCount,
      mediaCount: mediaCount ?? this.mediaCount,
      usableRegionCount: usableRegionCount ?? this.usableRegionCount,
      usableMediaCount: usableMediaCount ?? this.usableMediaCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        picturePath,
        linkedTagId,
        linkedCreatorId,
        linkedName,
        regionCount,
        mediaCount,
        usableRegionCount,
        usableMediaCount,
      ];
}
