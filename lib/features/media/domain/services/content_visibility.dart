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
}
