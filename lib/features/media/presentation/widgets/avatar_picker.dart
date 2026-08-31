import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/services/avatar_source.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_crop_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_library_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_source_dialog.dart';
import 'package:Fern/features/settings/data/services/avatar_janitor.dart';
import 'package:Fern/features/settings/domain/usecases/crop_avatar_usecase.dart';
import 'package:Fern/features/settings/domain/usecases/store_avatar_usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Pregunta qué imagen se quiere de avatar y por qué trozo de ella.
///
/// Los tres pasos que antes eran uno solo —abrir el explorador y copiar el
/// fichero elegido—:
///
/// 1. De dónde sale: de la biblioteca o del equipo. Buscar en el disco una
///    imagen que la aplicación ya tiene guardada y sabe enseñar era el trabajo
///    de más.
/// 2. Cuál.
/// 3. Qué trozo. El avatar es redondo y pequeño: una ilustración apaisada
///    entera dentro de un círculo no se ve.
///
/// Devuelve qué recortar y por dónde, o `null` si se abandona en cualquiera de
/// los tres pasos. **No escribe nada**: quien pregunta guarda con
/// [storeChosenAvatar], que es lo que deja el guardado dentro de su espera y
/// deja fuera el tiempo que ponga el usuario eligiendo.
Future<AvatarCrop?> chooseAvatarImage(BuildContext context) async {
  final source = await showFernDialog<AvatarSource, MediaBloc>(
    context: context,
    builder: (_) => const AvatarSourceDialog(),
  );

  if (source == null || !context.mounted) return null;

  final chosen = switch (source) {
    AvatarSource.library => await _fromLibrary(context),
    AvatarSource.device => await _fromDevice(),
  };

  if (chosen == null || !context.mounted) return null;

  // Lo que no se recorta se coge entero y no se pregunta nada: preguntar por un
  // trozo de algo que sólo puede ir entero sería un paso que siempre se contesta
  // igual.
  if (!chosen.crops) return (path: chosen.path, rect: wholeImageRect);

  return cropOf(context, chosen.path);
}

/// Una imagen elegida y si de ella se puede coger un trozo.
///
/// Las dos cosas juntas porque no siempre coinciden: de un vídeo lo que se
/// guarda es **su miniatura**, que es una imagen y se dejaría recortar, pero lo
/// que se ha elegido es un vídeo y de ésos se coge el fotograma entero.
typedef _Chosen = ({String path, bool crops});

/// Qué trozo de [path] se queda, preguntándolo si tiene sentido preguntarlo.
///
/// De un vídeo o un GIF se coge el fotograma entero sin abrir nada, que es lo
/// que ya hacía: allí lo que se ve no es lo que hay en el fichero, y un recorte
/// marcado sobre un fotograma que se mueve señalaría algo que ya no está.
Future<AvatarCrop?> cropOf(BuildContext context, String path) async {
  if (!cropsAvatarOf(path)) return (path: path, rect: wholeImageRect);

  final rect = await showFernDialog<Rect, MediaBloc>(
    context: context,
    builder: (_) => AvatarCropDialog(path: path),
  );

  return rect == null ? null : (path: path, rect: rect);
}

/// Lo elegido de la biblioteca.
///
/// De un vídeo se coge **su miniatura**, no el fichero: un `.mp4` en la carpeta
/// de avatares no se puede pintar en ningún círculo. Ya está sacada —es la que
/// se ve en la rejilla— así que esto no abre nada.
Future<_Chosen?> _fromLibrary(BuildContext context) async {
  final media = await showFernDialog<MediaSummaryEntity, MediaBloc>(
    context: context,
    builder: (_) => const AvatarLibraryDialog(),
  );

  if (media == null) return null;
  if (cropsAvatarOf(media.path)) return (path: media.path, crops: true);

  final thumbnail =
      (await MediaPreviewService.instance.load(media.path))?.thumbnailPath;
  if (thumbnail == null) return null;

  return (path: thumbnail, crops: false);
}

/// Lo elegido del equipo. El explorador sólo ofrece imágenes, así que lo que
/// venga de ahí se recorta —salvo un GIF, que [cropOf] deja entero para no
/// quedarse con un fotograma de algo que se mueve—.
Future<_Chosen?> _fromDevice() async {
  final result = await FilePicker.pickFiles(type: FileType.image);
  final path = result?.files.single.path;

  return path == null ? null : (path: path, crops: true);
}

/// Guarda lo elegido en la carpeta de avatares y devuelve dónde ha quedado.
///
/// La imagen entera no pasa por el recorte: descodificarla y volver a
/// escribirla para quedarse con lo mismo sería trabajo y pérdida de calidad a
/// cambio de nada. Copiarla es lo que se ha hecho siempre.
///
/// [replacing] es el avatar que tenía la ficha antes, si lo había, y se borra
/// **cuando ya no lo usa nadie**. Sin esto, cambiar de idea dos veces antes de
/// guardar dejaba dos ficheros en la carpeta de avatares que no apunta nadie y
/// que no se ven en ninguna pantalla. El que sí esté guardado en la base se
/// queda: lo borra el repositorio al guardar la ficha, que es cuando deja de
/// estar en uso de verdad.
Future<String> storeChosenAvatar(AvatarCrop choice, {String? replacing}) async {
  final stored = choice.rect == wholeImageRect
      ? await getIt<StoreAvatarUseCase>()(params: choice.path)
      : await getIt<CropAvatarUseCase>()(params: choice);

  if (replacing != null && replacing.isNotEmpty && replacing != stored) {
    await getIt<AvatarJanitor>().removeIfUnused(replacing);
  }

  return stored;
}
