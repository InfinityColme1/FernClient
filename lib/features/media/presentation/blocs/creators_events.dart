abstract class CreatorsEvents {
  const CreatorsEvents();
}

/// Vuelve a leer los creadores de la base de datos.
///
/// Lo pide la pantalla de gestión de creadores al abrirse y cualquiera que
/// cree, edite o borre uno, para que la lista se vea al día sin tener que
/// reiniciar la aplicación.
class LoadCreatorsEvent extends CreatorsEvents {
  const LoadCreatorsEvent();
}
