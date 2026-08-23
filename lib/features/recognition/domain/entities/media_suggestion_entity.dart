import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_result_entity.dart';
import 'package:equatable/equatable.dart';

/// Lo fiable que es una sugerencia, en tres tramos.
///
/// Tres y no un número suelto porque lo que el usuario decide es «me lo creo o
/// lo miro»: el porcentaje exacto está escrito al lado para quien lo quiera, y
/// el tramo es lo que se ve sin leer.
enum SuggestionConfidence { high, medium, low }

/// Una sugerencia con todo lo que hace falta para enseñarla y para aceptarla.
///
/// La fila guardada sólo tiene números —un modelo, un fernie, una confianza—, y
/// eso no se puede enseñar. Aquí llega ya resuelto qué propone: **la etiqueta o
/// el creador de verdad**, no su identificador. Es lo que permite que aceptar
/// sea inmediato y que el panel enseñe el mismo avatar que enseñará después,
/// cuando ya sea una etiqueta puesta.
///
/// Que venga resuelto es también lo que hace honesto el [proposes]: un fernie
/// enlazado a una etiqueta que alguien borró sigue diciendo que enlaza una
/// etiqueta, pero no hay ninguna que proponer.
class MediaSuggestionEntity extends Equatable {
  final RecognitionResultEntity result;
  final FernieEntity fernie;

  /// La etiqueta que se pondría al aceptarla, si el fernie enlaza una y sigue
  /// existiendo.
  final TagEntity? tag;

  /// El creador que se pondría al aceptarla.
  final CreatorEntity? creator;

  const MediaSuggestionEntity({
    required this.result,
    required this.fernie,
    this.tag,
    this.creator,
  });

  int get id => result.id;
  double get confidence => result.confidence;
  int get mediaId => result.mediaId;
  SuggestionStatus get status => result.status;

  /// Qué propone: una etiqueta, un creador, o nada.
  FernieLinkKind get proposes {
    if (tag != null) return FernieLinkKind.tag;
    if (creator != null) return FernieLinkKind.creator;

    return FernieLinkKind.none;
  }

  /// Con qué nombre se enseña.
  ///
  /// El de lo propuesto, si lo hay: quien mira el panel está decidiendo si le
  /// pone **esa etiqueta** al contenido, y el nombre del fernie puede no ser el
  /// mismo. Sin nada que proponer se cae al del fernie, que es lo único que hay.
  String get label => tag?.name ?? creator?.name ?? fernie.name;

  /// Qué cara se le pone.
  ///
  /// La de lo propuesto antes que la del fernie, por lo mismo: es la que el
  /// usuario va a ver ahí mismo en cuanto acepte.
  String? get picturePath =>
      tag?.picturePath ?? creator?.picturePath ?? fernie.picturePath;

  SuggestionConfidence get level {
    if (confidence >= suggestionHighConfidence) return SuggestionConfidence.high;
    if (confidence >= suggestionLowConfidence) {
      return SuggestionConfidence.medium;
    }

    return SuggestionConfidence.low;
  }

  /// Dónde lo vio, si lo apuntó.
  ///
  /// Normalizado (0..1) como todo lo que se pinta encima de un contenido, para
  /// que siga valiendo con cualquier zoom y en cualquier ventana.
  ///
  /// Puede faltar: una detección sobre un fichero que el sidecar no supo medir
  /// llega sin caja, y una sugerencia sin caja se sigue pudiendo aceptar. Lo
  /// único que no se puede es enseñar dónde.
  ({double x, double y, double w, double h})? get box {
    final x = result.x;
    final y = result.y;
    final w = result.w;
    final h = result.h;

    if (x == null || y == null || w == null || h == null) return null;
    if (w <= 0 || h <= 0) return null;

    return (x: x, y: y, w: w, h: h);
  }

  /// De qué fotograma es lo que vio. `null` en imágenes.
  int? get frameMs => result.frameMs;

  /// La confianza en tanto por ciento, redondeada.
  ///
  /// Sin decimales: la diferencia entre un 92,4 % y un 92,7 % no cambia ninguna
  /// decisión, y dos cifras más por sugerencia en un panel estrecho sí.
  int get percent => (confidence * 100).round();

  @override
  List<Object?> get props => [result, fernie, tag, creator];
}
