import 'package:Fern/core/utils/source_url.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_log_entry_entity.dart';

/// Lo que se puede deducir de por qué un contenido tiene lo que tiene, sin
/// registro.
///
/// Todo lo que estaba en la biblioteca antes de que existiera el registro no
/// tiene ninguna línea apuntada, y ésos son casi todos. La mayor parte de lo que
/// el registro cuenta **se puede reconstruir mirando los datos**: una etiqueta
/// cuya dirección vinculada casa con la del contenido llegó por ahí, una que
/// está por encima de otra que también tiene llegó heredada, y una hermana de
/// otra que tiene llegó con ella.
///
/// **No se escribe nada de esto.** Es una lectura, no un registro: si mañana se
/// cambia la dirección de una etiqueta, la deducción cambia con ella, y eso es
/// justo lo que la separa de lo que pasó de verdad. Quien la lee tiene que
/// saberlo, así que la pantalla lo dice.
///
/// Lo que no encaja en ninguno de los caminos se devuelve con [TagLogReason.unknown]
/// y no se calla: una etiqueta sin explicación es exactamente la que se está
/// buscando cuando alguien abre esto.
List<TagLogEntryEntity> guessTagLog({
  required int mediaId,
  required List<TagEntity> tags,
  required DateTime at,
  List<String> mediaUrls = const [],
  TagEntity? platformTag,
  Map<int, String> byFernie = const {},
}) {
  final own = {for (final tag in tags) tag.id};

  // De quién cuelga cada una, entre las que el contenido tiene. Se mira contra
  // sus propias etiquetas y no contra el árbol entero: lo que explica una
  // etiqueta heredada es la que la arrastró, y ésa tiene que estar puesta.
  final childrenOf = <int, List<TagEntity>>{
    for (final tag in tags) tag.id: _descendants(tag).toList(),
  };

  return [
    for (final tag in tags)
      TagLogEntryEntity(
        mediaId: mediaId,
        tagId: tag.id,
        label: tag.name,
        imagePath: tag.picturePath,
        at: at,
        isGuess: true,
        reason: _reasonOf(
          tag,
          own: own,
          childrenOf: childrenOf,
          mediaUrls: mediaUrls,
          platformTag: platformTag,
          byFernie: byFernie,
        ),
        detail: _detailOf(
          tag,
          own: own,
          childrenOf: childrenOf,
          byFernie: byFernie,
        ),
      ),
  ];
}

/// Por qué está puesta, con los caminos mirados de más seguro a menos.
///
/// La plataforma y la dirección vinculada son datos, no deducciones: o casan o
/// no. Lo heredado se deduce de la forma del árbol, y por eso va después: una
/// etiqueta puede ser a la vez la de la plataforma y madre de otra, y en ese
/// caso lo que explica de dónde salió es lo primero.
TagLogReason _reasonOf(
  TagEntity tag, {
  required Set<int> own,
  required Map<int, List<TagEntity>> childrenOf,
  required List<String> mediaUrls,
  required TagEntity? platformTag,
  required Map<int, String> byFernie,
}) {
  if (platformTag?.id == tag.id) return TagLogReason.platform;
  if (_matchesUrl(tag, mediaUrls)) return TagLogReason.sourceUrl;
  if (byFernie.containsKey(tag.id)) return TagLogReason.fernie;
  if (_ancestorOfOwn(tag, own, childrenOf) != null) return TagLogReason.ancestor;
  if (_siblingOfOwn(tag, own) != null) return TagLogReason.sibling;

  return TagLogReason.unknown;
}

String? _detailOf(
  TagEntity tag, {
  required Set<int> own,
  required Map<int, List<TagEntity>> childrenOf,
  required Map<int, String> byFernie,
}) {
  if (byFernie[tag.id] case final fernie?) return fernie;

  return _ancestorOfOwn(tag, own, childrenOf) ?? _siblingOfOwn(tag, own);
}

/// Si alguna dirección vinculada de la etiqueta recoge alguna del contenido.
bool _matchesUrl(TagEntity tag, List<String> urls) {
  // Las marcadas cuentan igual: esconder una dirección es no enseñarla, no
  // dejar de etiquetar por ella.
  for (final rule in [...tag.sourceUrls, ...tag.nsfwSourceUrls]) {
    for (final url in urls) {
      if (sourceUrlMatches(url, rule)) return true;
    }
  }

  return false;
}

/// El nombre de una etiqueta del contenido que cuelga de ésta, si la hay: es la
/// que la arrastró hasta aquí.
String? _ancestorOfOwn(
  TagEntity tag,
  Set<int> own,
  Map<int, List<TagEntity>> childrenOf,
) {
  for (final descendant in childrenOf[tag.id] ?? const <TagEntity>[]) {
    if (own.contains(descendant.id)) return descendant.name;
  }

  return null;
}

/// El nombre de una etiqueta del contenido de la que ésta es hermana.
String? _siblingOfOwn(TagEntity tag, Set<int> own) {
  for (final sibling in tag.siblings) {
    if (own.contains(sibling.id)) return sibling.name;
  }

  return null;
}

Iterable<TagEntity> _descendants(TagEntity tag) sync* {
  for (final child in tag.children) {
    yield child;
    yield* _descendants(child);
  }
}
