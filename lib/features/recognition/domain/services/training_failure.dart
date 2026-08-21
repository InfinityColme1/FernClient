/// Por qué se rompió un entrenamiento.
///
/// Lo que se guarda en el modelo es lo que dijo el sidecar: un código y un
/// mensaje en inglés, cuando no una traza de Python entera. Eso vale para
/// contarlo en un informe y no vale para nada más: quien lo lee necesita saber
/// **qué hacer**, y «SidecarException(SIDECAR_NOT_READY)» no se lo dice.
///
/// Es la misma idea que [SidecarFailure] hace con la instalación, pero para el
/// entrenamiento, que falla por otras cosas.
enum TrainingFailureKind {
  /// El motor se paró a media faena.
  ///
  /// Casi siempre por quedarse sin memoria del sistema o porque algo mató el
  /// proceso; lo razonable es volver a intentarlo con menos exigencia.
  engineStopped,

  /// Sin memoria en la tarjeta o en el sistema. Tiene arreglo desde
  /// «Avanzado»: bajar el lote o el tamaño de imagen.
  outOfMemory,

  /// El material no se pudo preparar o ya no está donde estaba.
  datasetInvalid,

  /// Faltan los pesos de partida y no se han podido descargar.
  weightsMissing,

  /// No cabe: los datasets de vídeo son miles de imágenes.
  notEnoughSpace,

  /// Cualquier otra cosa. Se enseña el detalle técnico tal cual, que es más de
  /// lo que se puede decir de una frase inventada.
  unknown,
}

/// Un fallo de entrenamiento, ya clasificado, con el detalle técnico aparte.
class TrainingFailure {
  final TrainingFailureKind kind;

  /// Lo que dijo el sidecar. No es lo que se le enseña al usuario en la cara:
  /// va debajo y en pequeño, que es donde sirve de algo cuando hay que contar
  /// qué ha pasado.
  final String detail;

  const TrainingFailure(this.kind, this.detail);

  /// Traduce lo que se guardó a uno de los casos conocidos.
  ///
  /// Se busca por texto y no por un campo aparte porque lo que hay guardado es
  /// un `toString()` de una excepción: el código va dentro del mensaje. Se
  /// miran también las formas en castellano porque el sistema puede contestar
  /// en el idioma del usuario.
  factory TrainingFailure.from(String error) {
    final text = error.toLowerCase();

    if (_mentions(text, const [
      'sidecar_not_ready',
      'the sidecar stopped',
      'sidecar is not running',
    ])) {
      return TrainingFailure(TrainingFailureKind.engineStopped, error);
    }

    if (_mentions(text, const [
      'out_of_memory',
      'out of memory',
      'sin memoria',
      'cuda error',
    ])) {
      return TrainingFailure(TrainingFailureKind.outOfMemory, error);
    }

    if (_mentions(text, const [
      'no space left',
      'not enough space',
      'espacio en disco',
      'espacio insuficiente',
      'os error 112',
    ])) {
      return TrainingFailure(TrainingFailureKind.notEnoughSpace, error);
    }

    if (_mentions(text, const [
      'dataset_invalid',
      'no data.yaml',
      'dataset',
    ])) {
      return TrainingFailure(TrainingFailureKind.datasetInvalid, error);
    }

    if (_mentions(text, const [
      'model_not_found',
      'model_invalid',
      'no weights at',
    ])) {
      return TrainingFailure(TrainingFailureKind.weightsMissing, error);
    }

    return TrainingFailure(TrainingFailureKind.unknown, error);
  }

  /// Si merece la pena enseñar el detalle técnico debajo.
  ///
  /// En los casos conocidos no: la frase ya dice lo que hay que saber, y añadir
  /// la traza sólo asusta. En el desconocido sí, porque es lo único que hay.
  bool get showsDetail => kind == TrainingFailureKind.unknown;

  static bool _mentions(String text, List<String> needles) =>
      needles.any(text.contains);
}
