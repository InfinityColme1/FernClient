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
  final int regionCount;
  final int mediaCount;

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
  }) : createdAt = createdAt ?? DateTime.now();

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
      ];
}
