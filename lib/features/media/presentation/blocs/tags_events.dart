abstract class TagsEvents {
  const TagsEvents();
}

/// Vuelve a leer las etiquetas de la base de datos.
///
/// Lo pide el menú lateral al arrancar y cualquiera que cree una etiqueta, para
/// que aparezca en el listado sin tener que reiniciar la aplicación.
class LoadTagsEvent extends TagsEvents {
  const LoadTagsEvent();
}
