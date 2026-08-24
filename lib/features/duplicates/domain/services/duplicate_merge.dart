import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:flutter/foundation.dart';

/// Lo que hace falta saber de una copia para elegir cuál se queda.
///
/// Va aparte de `MediaEntity` porque el tamaño en píxeles y el peso no viven en
/// ella: salen del fichero y del servicio de previsualizaciones. Juntarlos aquí
/// deja la decisión pura y comprobable sin abrir un solo fichero.
@immutable
class DuplicateCandidate {
  final int mediaId;
  final int? width;
  final int? height;
  final int? sizeInBytes;
  final int tagCount;
  final DateTime? downloaded;

  const DuplicateCandidate({
    required this.mediaId,
    this.width,
    this.height,
    this.sizeInBytes,
    this.tagCount = 0,
    this.downloaded,
  });

  int get pixels => (width ?? 0) * (height ?? 0);
}

/// Cuál de las copias merece quedarse.
///
/// Es sólo una propuesta: el usuario la ve marcada y puede cambiarla. Pero es la
/// que se aplica cuando revisa cuarenta grupos seguidos sin mirar mucho, así que
/// tiene que acertar sola en el caso normal.
///
/// El orden de los criterios no es caprichoso:
///
/// 1. **Más píxeles.** Lo que se pierde al quedarse con la pequeña no se
///    recupera; lo que sobra en la grande, sí.
/// 2. **Más pesada.** A igual tamaño, la que menos comprimida está.
/// 3. **Más etiquetada.** Empataron en imagen: gana en la que ya hay trabajo
///    hecho. Aunque se fusione, lo que no se toca no se puede estropear.
/// 4. **Más antigua.** La que lleva más tiempo en la biblioteca es la que
///    aparece en lo que el usuario recuerde de ella.
///
/// Con todo empatado manda el identificador, para que dos ejecuciones propongan
/// lo mismo.
DuplicateCandidate? bestCopyOf(List<DuplicateCandidate> copies) {
  if (copies.isEmpty) return null;

  final sorted = [...copies]..sort((one, other) {
      final byPixels = other.pixels.compareTo(one.pixels);
      if (byPixels != 0) return byPixels;

      final byWeight = (other.sizeInBytes ?? 0).compareTo(one.sizeInBytes ?? 0);
      if (byWeight != 0) return byWeight;

      final byTags = other.tagCount.compareTo(one.tagCount);
      if (byTags != 0) return byTags;

      final byAge = _epochOf(one).compareTo(_epochOf(other));
      if (byAge != 0) return byAge;

      return one.mediaId.compareTo(other.mediaId);
    });

  return sorted.first;
}

/// La copia que se conserva, con lo que valía la pena de las demás.
///
/// Quedarse con una copia y tirar las otras pierde el trabajo hecho sobre ellas:
/// las etiquetas que alguien puso a mano en la que resultó ser peor, el creador
/// que sólo tenía una, el corazón que se le dio a la otra. Esto lo recoge todo
/// **antes** de que las descartadas se vayan a la papelera.
///
/// Nunca quita nada de la superviviente: sólo suma.
MediaEntity mergeInto(MediaEntity keeper, List<MediaEntity> discarded) {
  if (discarded.isEmpty) return keeper;

  final tags = <int, TagEntity>{
    for (final tag in _tagsOf(keeper)) tag.id: tag,
  };

  for (final one in discarded) {
    for (final tag in _tagsOf(one)) {
      tags.putIfAbsent(tag.id, () => tag);
    }
  }

  return keeper.copyWith(
    tags: tags.values.toList(),
    creator: _creatorFor(keeper, discarded),
    // Basta con que le gustara en una: marcar un favorito es una decisión y
    // dejar de serlo por elegir la copia equivocada es perderla.
    isFavorite: keeper.isFavorite || discarded.any((one) => one.isFavorite),
    description: _descriptionFor(keeper, discarded),
  );
}

/// El creador de la superviviente, o el primero de verdad que haya en las otras.
///
/// «Unknown» no es un creador: es no haberlo puesto. Si la que se conserva lo
/// tiene sin poner y una descartada sí lo tenía, ese dato lo puso alguien a mano
/// y sería lo primero que se perdería.
CreatorEntity _creatorFor(MediaEntity keeper, List<MediaEntity> discarded) {
  if (_hasRealCreator(keeper)) return keeper.creator;

  for (final one in discarded) {
    if (_hasRealCreator(one)) return one.creator;
  }

  return keeper.creator;
}

bool _hasRealCreator(MediaEntity media) =>
    media.creator.name != unknownCreator.name;

/// Las descripciones que haya, sin perder ninguna.
///
/// Si las dos copias tienen texto y es distinto, se juntan en dos líneas en vez
/// de elegir: son notas que escribió alguien, y descartar una por quedarse con la
/// otra es tirar algo que no se puede recuperar. Limpiarlo después es un momento;
/// recuperarlo, imposible.
String? _descriptionFor(MediaEntity keeper, List<MediaEntity> discarded) {
  final parts = <String>[];

  for (final one in [keeper, ...discarded]) {
    final text = one.description?.trim();
    if (text == null || text.isEmpty) continue;
    if (parts.contains(text)) continue;

    parts.add(text);
  }

  return parts.isEmpty ? keeper.description : parts.join('\n');
}

List<TagEntity> _tagsOf(MediaEntity media) => media.tags ?? const [];

DateTime _epochOf(DuplicateCandidate candidate) =>
    candidate.downloaded ?? DateTime.fromMillisecondsSinceEpoch(0);
