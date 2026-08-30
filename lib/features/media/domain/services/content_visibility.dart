/// Qué se puede enseñar ahora mismo y qué no.
///
/// El repositorio no sabe **por qué** algo está bloqueado: pregunta y obedece.
/// Hoy quien contesta es el modo NSFW (fase 7); si mañana hubiera otro motivo
/// para esconder contenido, entra por aquí sin tocar una sola consulta.
///
/// De fábrica no esconde nada, y eso es a propósito: quien monta el repositorio
/// sin decir nada obtiene el comportamiento de siempre. La alternativa —que
/// hubiera que pasarlo siempre— convierte cada sitio que construye el
/// repositorio en una ocasión de equivocarse, y aquí equivocarse es enseñar lo
/// que había que esconder.
class ContentVisibility {
  const ContentVisibility();

  /// Si este contenido no se puede **listar**.
  bool hidesMedia(int mediaId) => false;

  /// Si este contenido no se puede **abrir**.
  ///
  /// Va aparte de [hidesMedia] porque no siempre coinciden: con el contenido
  /// tapado en lugar de escondido, la celda aparece en la rejilla —así que no
  /// está «oculta»— y aun así abrirla tiene que seguir pidiendo la contraseña.
  /// Sin esta separación, tapar sería enseñar: bastaría abrir la celda de al
  /// lado y pasar a la siguiente con las flechas.
  bool hidesDetails(int mediaId) => hidesMedia(mediaId);

  /// Si este contenido se enseña **tapado**.
  ///
  /// Lo pregunta la celda de la rejilla, no el repositorio: aquí no se decide
  /// qué se lee, sino cómo se pinta lo que ya se ha leído.
  bool blursMedia(int mediaId) => false;

  /// Si esta etiqueta no se puede enseñar.
  ///
  /// Va aparte del contenido porque esconder una etiqueta es esconder también
  /// su nombre: con el modo apagado, que una etiqueta aparezca en el listado
  /// lateral o autocomplete en la barra de búsqueda ya delata lo que hay,
  /// aunque su contenido no se llegue a ver.
  bool hidesTag(int tagId) => false;

  /// Si esta etiqueta esconde contenido, esté el filtro puesto o no.
  ///
  /// Va aparte de [hidesTag], que dice si **la etiqueta** se puede enseñar
  /// ahora: esto dice si **lo suyo** está bajo el filtro, y sigue siendo cierto
  /// con el filtro quitado. Es lo que necesitan las listas y los buscadores para
  /// distinguirla, que es justo cuando se ven: con el filtro puesto ni siquiera
  /// aparece.
  ///
  /// Incluye las que cuelgan de una marcada. Una hija esconde contenido igual
  /// que su madre, y no distinguirla sería avisar a medias.
  bool marksTag(int tagId) => false;

  /// Si este fernie no se puede enseñar.
  ///
  /// Va aparte del contenido porque lo que esconde no es lo mismo: un fernie es
  /// un nombre, una cara y un puñado de recortes de la biblioteca. Sin esto,
  /// marcar contenido y luego recortarlo en un fernie devolvía ese contenido a
  /// la vista por la pantalla de fernies, con el filtro puesto.
  ///
  /// **No dice nada de lo que el fernie hace.** Escondido sigue entrenando y
  /// sigue proponiendo; por eso quien lee para trabajar —el conjunto de datos,
  /// el reconocimiento— va por el repositorio y no por los casos de uso, que
  /// son los que preguntan esto.
  bool hidesFernie(int fernieId) => false;

  /// Si este fernie esconde algo, esté el filtro puesto o no.
  ///
  /// Lo mismo que [marksTag] para las etiquetas: con el filtro quitado el
  /// fernie se ve, y hay que poder distinguirlo de los demás.
  bool marksFernie(int fernieId) => false;

  /// Si este modelo no se puede enseñar.
  ///
  /// Tampoco dice nada de lo que el modelo hace: escondido se entrena y el
  /// árbol lo sigue ejecutando.
  bool hidesModel(int modelId) => false;

  /// Si este modelo está marcado, esté el filtro puesto o no.
  bool marksModel(int modelId) => false;

  /// Si las direcciones marcadas no se pueden enseñar ahora mismo.
  ///
  /// No lleva identificador porque no depende de cuál sea: o el bloqueo está
  /// cerrado y no se enseña ninguna, o está abierto y se enseñan todas.
  ///
  /// Una dirección vinculada delata tanto como el nombre de una etiqueta: la
  /// galería de la que sale el contenido dice lo que hay dentro aunque el
  /// contenido no se llegue a ver.
  ///
  /// **No dice nada de lo que la dirección hace.** Escondida sigue etiquetando
  /// al importar, igual que un fernie escondido sigue entrenando: por eso quien
  /// lee para trabajar (`MediaRegistry`) no pregunta esto.
  bool get hidesMarkedLinks => false;
}
