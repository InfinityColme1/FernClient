import 'package:equatable/equatable.dart';

/// Por qué un contenido acabó con una etiqueta —o con un creador— puesto.
///
/// Es la pregunta que no tenía respuesta: la aplicación etiqueta sola por tres
/// caminos distintos —la dirección de la que se bajó, la etiqueta que traía la
/// plataforma, y lo que arrastran la rama y las hermanas— y desde fuera todo se
/// ve igual. Cuando aparece una etiqueta que nadie esperaba, no había forma de
/// saber de dónde salió ni, por lo tanto, qué corregir para que no vuelva a
/// pasar.
enum TagLogReason {
  /// La puso el usuario.
  manual,

  /// Una dirección vinculada de la etiqueta casaba con la de origen del
  /// contenido.
  sourceUrl,

  /// Es la etiqueta de la plataforma de la que se bajó.
  platform,

  /// Se hereda por estar por encima de otra que sí se pidió.
  ancestor,

  /// Va con otra que se pidió por ser hermana suya.
  sibling,

  /// Se aceptó lo que propuso un modelo de reconocimiento.
  recognition,

  /// Es lo que enlaza un fernie marcado en el contenido.
  fernie,

  /// No consta.
  ///
  /// **No se guarda nunca**: sale sólo de la deducción del contenido anterior al
  /// registro, cuando ninguno de los caminos explica una etiqueta. Y se enseña
  /// igual, porque una etiqueta sin explicación es justo la que se está buscando
  /// cuando alguien abre esto.
  unknown,
}

/// Una línea del registro: qué se puso, por qué y cuándo.
///
/// El nombre se guarda **con la fila** y no se busca al leerla: la etiqueta se
/// puede renombrar o borrar después, y un registro que dijera «se puso la
/// etiqueta 47» —o que perdiera la línea al borrarla— no serviría para lo único
/// que existe, que es entender lo que pasó.
class TagLogEntryEntity extends Equatable {
  final int mediaId;
  final TagLogReason reason;

  /// Qué se puso. Uno de los dos, nunca los dos.
  final int? tagId;
  final int? creatorId;

  /// Cómo se llamaba en ese momento.
  final String label;

  /// El porqué concreto, cuando lo hay: la dirección que casó o de qué otra
  /// etiqueta viene lo heredado.
  final String? detail;

  /// El avatar de la etiqueta o del creador, **tal y como está ahora**.
  ///
  /// No se guarda con la línea, al revés que el nombre: la imagen es cómo se
  /// reconoce una etiqueta de un vistazo, así que tiene que ser la de ahora y no
  /// la que tuviera el día que se puso. Se resuelve al leer el registro, y llega
  /// vacía si la etiqueta ya no existe.
  final String? imagePath;

  final DateTime at;

  /// Esta línea **no se apuntó**: se deduce de cómo están los datos ahora.
  ///
  /// Va por línea y no por registro entero porque los dos se mezclan: un
  /// contenido anterior al registro al que hoy se le pone una etiqueta tiene una
  /// línea de verdad y diecinueve deducidas, y enseñar sólo la primera
  /// escondería justo lo que se ha ido a mirar.
  ///
  /// Nunca se guarda: sale de la deducción y muere con ella.
  final bool isGuess;

  const TagLogEntryEntity({
    required this.mediaId,
    required this.reason,
    required this.label,
    required this.at,
    this.tagId,
    this.creatorId,
    this.detail,
    this.imagePath,
    this.isGuess = false,
  });

  /// Lo apuntado es un creador y no una etiqueta.
  bool get isCreator => creatorId != null;

  @override
  List<Object?> get props =>
      [mediaId, reason, tagId, creatorId, label, detail, at, isGuess];
}

/// El registro de un contenido y si lleva algo deducido dentro.
///
/// Los dos juntos porque no se pueden enseñar por separado: una lista de motivos
/// sin decir que parte de ella se deduce se lee entera como un registro, y para
/// el contenido anterior a esto diría que consta algo que no consta.
typedef MediaTagLogView = ({List<TagLogEntryEntity> entries, bool isGuess});
