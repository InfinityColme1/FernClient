import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';

/// Qué hace el visor después de guardar.
enum ViewerSaveAction {
  /// Se queda donde está, enseñando lo mismo.
  stay,

  /// Pasa al siguiente de la tanda que se está revisando.
  goToNext,

  /// Se cierra y devuelve a la rejilla.
  close,
}

/// Qué tiene que pasar al pulsar Guardar.
///
/// Hay tres reglas y las tres tienen su motivo:
///
/// **Lo que ya era definitivo se queda.** Guardarlo no lo saca de ninguna lista,
/// así que el visor puede seguir enseñándolo. Es lo que pasa editando desde la
/// biblioteca.
///
/// **Lo pendiente no puede quedarse.** Darlo por definitivo lo saca de la lista
/// de la que se abrió, y quedarse dejaría el visor apuntando a un sitio que ya
/// no es el suyo. O pasa al siguiente, o se cierra.
///
/// **Y sólo pasa al siguiente revisando.** Ese salto existe para recorrer una
/// tanda recién importada sin volver a la rejilla entre uno y otro. Lo pendiente
/// también se abre desde otras pantallas —la de una etiqueta, la de un fernie—,
/// y allí se ha ido a **ese** contenido: llevarse al usuario a otro al guardar
/// sería quitarle de delante justo lo que estaba mirando.
ViewerSaveAction viewerSaveActionFor({
  required bool isNew,
  required bool isReviewing,
  required ViewerSaveBehavior behavior,
}) {
  if (!isNew) return ViewerSaveAction.stay;

  if (isReviewing && behavior == ViewerSaveBehavior.goToNext) {
    return ViewerSaveAction.goToNext;
  }

  return ViewerSaveAction.close;
}
