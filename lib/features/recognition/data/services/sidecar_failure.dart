/// Por qué no se ha podido montar el entorno de reconocimiento.
///
/// Lo que llega de `uv`, de Python o del sistema es un mensaje técnico y encima
/// en el idioma del sistema. Aquí se reduce a un puñado de casos que sí se
/// pueden explicar y, sobre todo, que el usuario puede arreglar.
enum SidecarFailureKind {
  /// Hay algo usando los ficheros del entorno, así que no se dejan borrar ni
  /// reemplazar. En Windows es el caso más habitual con diferencia.
  filesInUse,

  /// No cabe en el disco.
  notEnoughSpace,

  /// No se ha podido descargar: sin conexión, cortada a medias, o el servidor
  /// no ha contestado.
  network,

  /// El sistema no deja ejecutar lo que se acaba de descargar. Suele ser el
  /// antivirus, o los permisos de la carpeta.
  blocked,

  /// Falta algo que tendría que estar (el propio `uv`, el Python del entorno).
  missingPiece,

  /// Cualquier otra cosa.
  unknown,
}

/// Un fallo del entorno, ya clasificado, con el detalle técnico aparte.
///
/// [detail] no se le enseña al usuario en la cara: va al registro plegable, que
/// es donde sirve de algo cuando hay que contar qué ha pasado.
class SidecarFailure {
  final SidecarFailureKind kind;
  final String detail;

  const SidecarFailure(this.kind, this.detail);

  /// Traduce lo que sea que haya salido mal a uno de los casos conocidos.
  ///
  /// Se busca por texto porque no hay otra: `uv` devuelve un código de salida y
  /// un mensaje, y el mensaje viene en el idioma del sistema. Por eso se miran
  /// las dos formas de cada cosa, la inglesa y la castellana.
  factory SidecarFailure.from(Object error) {
    final detail = error.toString();
    final text = detail.toLowerCase();

    // Primero el de los ficheros ocupados: su mensaje también contiene
    // "denegado", que si no se lo llevaría el caso del antivirus.
    if (_mentions(text, const [
      'os error 5',
      'acceso denegado',
      'access is denied',
      'access denied',
      'failed to remove directory',
      'being used by another process',
      'siendo utilizado por otro proceso',
      'used by another process',
      'no se puede tener acceso al archivo',
      'os error 32',
    ])) {
      return SidecarFailure(SidecarFailureKind.filesInUse, detail);
    }

    if (_mentions(text, const [
      'no space left',
      'not enough space',
      'insufficient disk',
      'espacio en disco',
      'espacio insuficiente',
      'os error 112',
    ])) {
      return SidecarFailure(SidecarFailureKind.notEnoughSpace, detail);
    }

    if (_mentions(text, const [
      'socketexception',
      'clientexception',
      'connection',
      'conexion',
      'conexión',
      'timed out',
      'timeout',
      'network',
      'failed to fetch',
      'could not download',
      'handshake',
      'certificate',
      'answered 404',
      'answered 5',
      'temporary failure in name resolution',
    ])) {
      return SidecarFailure(SidecarFailureKind.network, detail);
    }

    if (_mentions(text, const [
      'operation not permitted',
      'permission denied',
      'permiso denegado',
      'virus',
      'blocked',
      'bloqueado',
      'no se puede ejecutar',
      'cannot execute',
    ])) {
      return SidecarFailure(SidecarFailureKind.blocked, detail);
    }

    if (_mentions(text, const [
      'processexception',
      'no such file',
      'cannot find the file',
      'no se encuentra el archivo',
      'was not inside the downloaded archive',
      'not found',
    ])) {
      return SidecarFailure(SidecarFailureKind.missingPiece, detail);
    }

    return SidecarFailure(SidecarFailureKind.unknown, detail);
  }

  static bool _mentions(String text, List<String> needles) =>
      needles.any(text.contains);

  /// Si tiene pinta de arreglarse cerrando lo que esté usando los ficheros.
  ///
  /// Es lo que decide si se ofrece el botón de rehacer el entorno en lugar del
  /// de reintentar a secas.
  bool get isRecoverableByRetry =>
      kind == SidecarFailureKind.filesInUse ||
      kind == SidecarFailureKind.network;

  @override
  String toString() => 'SidecarFailure(${kind.name}): $detail';
}
