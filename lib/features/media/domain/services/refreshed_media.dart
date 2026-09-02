import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

/// El contenido del panel después de que algo le haya cambiado las etiquetas
/// por detrás.
///
/// Pasa al marcar una región: los fernies marcados le ponen al contenido lo que
/// enlazan, y eso se escribe en la base sin pasar por el panel. Como el panel
/// seguía enseñando lo de antes, había que volver a leer.
///
/// **Se suma, no se sustituye**, y ahí estaba el fallo: lo que el panel lleva
/// sin guardar —unas etiquetas recién elegidas, un creador recién puesto— no
/// está en la base todavía, así que sustituir con lo de la base los borraba a
/// todos. Quien acababa de rellenar el panel y marcaba una región se lo
/// encontraba vacío, sin nada que lo explicara.
///
/// Sumar no resucita nada: quitar una etiqueta desde el panel **se escribe en el
/// momento**, así que lo que ya no está en la base tampoco está en [current].
///
/// El creador es la excepción a «lo de la base también entra»: se coge sólo si
/// el panel no tiene ninguno. El fernie pone el suyo cuando falta, y un creador
/// elegido a mano y sin guardar es exactamente lo que la base no puede saber.
///
/// Lo demás de [current] no se toca: una descripción a medio escribir no puede
/// perderse por haber marcado una región.
MediaEntity refreshedMedia(MediaEntity current, MediaEntity saved) {
  final known = {for (final tag in current.tags ?? const <TagEntity>[]) tag.id};

  return current.copyWith(
    tags: [
      ...?current.tags,
      for (final tag in saved.tags ?? const <TagEntity>[])
        if (known.add(tag.id)) tag,
    ],
    creator: current.creator.name == unknownCreator.name
        ? saved.creator
        : current.creator,
  );
}

/// El contenido con [creator] puesto y lo que el creador trae ([brings])
/// sumado a lo que ya llevaba.
///
/// **Suma, no sustituye.** Antes el diálogo mandaba el contenido entero tal y
/// como estaba al abrirlo, así que confirmar devolvía esa foto al panel y se
/// llevaba por delante cualquier cosa tocada mientras. Aquí sólo entra lo que
/// hay que añadir, sobre lo que el panel tenga en ese momento.
///
/// Ponerle un creador a un contenido no le quita ninguna de sus etiquetas: las
/// que trae se añaden a las que hubiera, sin repetir.
MediaEntity mediaWithCreator(
  MediaEntity media,
  CreatorEntity creator,
  List<TagEntity> brings,
) {
  if (brings.isEmpty) return media.copyWith(creator: creator);

  final known = {for (final tag in media.tags ?? const <TagEntity>[]) tag.id};

  return media.copyWith(
    creator: creator,
    tags: [
      ...?media.tags,
      for (final tag in brings)
        if (known.add(tag.id)) tag,
    ],
  );
}
