// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get sidebarCollapse => 'Plegar el menú';

  @override
  String get sidebarExpand => 'Desplegar el menú';

  @override
  String get navGallery => 'Galería';

  @override
  String get navTags => 'Etiquetas';

  @override
  String get navMedia => 'Contenido';

  @override
  String get navImport => 'Importar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navDeleted => 'Eliminados';

  @override
  String get navCreatorManager => 'Gestor de creadores';

  @override
  String get navTagManager => 'Gestor de etiquetas';

  @override
  String get navBrowser => 'Navegador';

  @override
  String get searchHint => 'Buscar';

  @override
  String get menuNewCreator => 'Nuevo creador';

  @override
  String get menuNewTag => 'Nueva etiqueta';

  @override
  String mediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
      zero: 'Sin contenido',
    );
    return '$_temp0';
  }

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos',
      one: '1 favorito',
      zero: 'Todavía no hay favoritos',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get filtersResultsFrom => 'Mostrar resultados de';

  @override
  String get filterMedia => 'Contenido';

  @override
  String get filterTags => 'Etiquetas';

  @override
  String get filterCreators => 'Creadores';

  @override
  String get emptyLibrary => 'Esto está un poco vacío';

  @override
  String mediaFetched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos encontrados',
      one: '1 archivo encontrado',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String selectedOfCount(int selected, int total) {
    return '$selected de $total seleccionados';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos marcados para borrar',
      one: '1 archivo marcado para borrar',
      zero: 'Nada marcado para borrar',
    );
    return '$_temp0';
  }

  @override
  String deletedRetentionNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Se borra definitivamente al cabo de $days días',
      one: 'Se borra definitivamente al cabo de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get deleteForeverTooltip =>
      'Borrar definitivamente de la base de datos';

  @override
  String remoteImportWarning(String source) {
    return 'Se va a importar contenido de $source';
  }

  @override
  String get remoteImportAmountAll =>
      'Se traerá todo lo que tengas guardado en tu cuenta.';

  @override
  String get remoteImportAmountSinceLast =>
      'Se traerá lo que tengas guardado desde la última importación.';

  @override
  String remoteImportAmountLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se traerán $count contenidos como mucho.',
      one: 'Se traerá 1 contenido como mucho.',
    );
    return '$_temp0';
  }

  @override
  String get favoriteSelectedTooltip => 'Marcar la selección como favorita';

  @override
  String get deleteSelectedTooltip =>
      'Mandar la selección a la pantalla de eliminados';

  @override
  String deleteTrashWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a borrar definitivamente $count archivos',
      one: 'Se va a borrar definitivamente 1 archivo',
    );
    return '$_temp0';
  }

  @override
  String deleteDiscardWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a descartar $count archivos',
      one: 'Se va a descartar 1 archivo',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesFromDisk => 'Borrar también los ficheros del disco';

  @override
  String get deleteFilesFromDiskDescription =>
      'Si la quitas, el contenido sale de la base de datos pero sus ficheros se quedan donde están, así que un escaneo posterior puede recogerlos otra vez.';

  @override
  String get actionStopImport => 'Detener la importación';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionClearSearch => 'Vaciar la búsqueda';

  @override
  String get actionDecrease => 'Bajar';

  @override
  String get actionIncrease => 'Subir';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionSelectFolder => 'Elegir carpeta';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRestore => 'Restablecer';

  @override
  String get actionSave => 'Guardar';

  @override
  String get showPassword => 'Mostrar';

  @override
  String get hidePassword => 'Ocultar';

  @override
  String get actionUnassignTag => 'Quitar etiqueta';

  @override
  String get actionDeleteTag => 'Eliminar etiqueta';

  @override
  String get actionUnassignCreator => 'Quitar creador';

  @override
  String get actionDeleteCreator => 'Eliminar creador';

  @override
  String get sourceLocalComputer => 'Equipo local';

  @override
  String get sourceAll => 'Todas';

  @override
  String get sourceBrowser => 'Navegador';

  @override
  String get sourceBrowserNote => 'Ir al navegador';

  @override
  String get sourceBrowserHint =>
      'Este contenido no se pide desde aquí: se elige página a página en la pantalla del navegador.';

  @override
  String get sourceNotConfigured => 'Sin configurar';

  @override
  String sourceLogIn(String source) {
    return 'Inicia sesión en $source';
  }

  @override
  String sourceLogInHint(String source) {
    return 'Abre $source en el navegador de Fern. Cuando hayas entrado, pulsa allí el botón de la llave para guardar la sesión y vuelve aquí.';
  }

  @override
  String get selectItem => 'Seleccionar';

  @override
  String get deselectItem => 'Quitar selección';

  @override
  String get viewerBack => 'Volver';

  @override
  String get viewerShare => 'Copiar al portapapeles';

  @override
  String get viewerFullscreen => 'Pantalla completa';

  @override
  String get viewerExitFullscreen => 'Salir de pantalla completa';

  @override
  String get viewerSkipBack => 'Retroceder cinco segundos';

  @override
  String get viewerSkipForward => 'Adelantar cinco segundos';

  @override
  String get viewerLoop => 'Reproducir en bucle';

  @override
  String get viewerPlaybackSectionTitle => 'Reproducción de vídeo';

  @override
  String get viewerPlaybackSectionNote =>
      'Qué le hace el visor a un vídeo mientras se recorre su línea de tiempo.';

  @override
  String get viewerReturnToMedia => 'Volver a donde estabas mirando';

  @override
  String get viewerReturnToMediaDescription =>
      'Al salir del visor, la rejilla se coloca donde está el contenido que acabas de ver en vez de quedarse donde la dejaste.';

  @override
  String get viewerPauseWhenSeeking => 'Parar al coger la barra';

  @override
  String get viewerPauseWhenSeekingDescription =>
      'El vídeo se para en cuanto se coge la barra y se queda donde se suelte. Apagado, sigue reproduciéndose desde donde se deje. Marcar regiones para siempre, diga lo que diga esto: una región se marca sobre un fotograma quieto.';

  @override
  String get fernieUndo => 'Deshacer la última región marcada';

  @override
  String get createTooltip => 'Crear';

  @override
  String get menuNewModel => 'Nuevo modelo';

  @override
  String get newModelTitle => 'Nuevo modelo';

  @override
  String get modelNameLabel => 'Nombre del modelo';

  @override
  String get modelFunctionLabel => 'Qué responde';

  @override
  String get modelFunctionBoolean => '¿Está?';

  @override
  String get modelFunctionBooleanDescription =>
      'Dice si cada uno de sus fernies está en el contenido. Con varios, contesta por cada uno por separado.';

  @override
  String get modelFunctionClassification => '¿Cuál es?';

  @override
  String get modelFunctionClassificationDescription =>
      'Distingue entre sus fernies y dice cuál ha encontrado, y dónde. Necesita al menos dos: con uno no hay entre qué elegir.';

  @override
  String get modelsTitle => 'Modelos';

  @override
  String get modelsEmpty => 'Todavía no hay modelos';

  @override
  String get modelStatusUntrained => 'Sin entrenar';

  @override
  String get modelStatusTraining => 'Entrenando';

  @override
  String get modelStatusReady => 'Listo';

  @override
  String get modelStatusFailed => 'El entrenamiento falló';

  @override
  String get modelDegradedNotice =>
      'Con un solo fernie no hay entre qué elegir, así que responde si está o no está. Añade otro para que los distinga.';

  @override
  String modelRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regiones',
      one: '1 región',
      zero: 'sin regiones',
    );
    return '$_temp0';
  }

  @override
  String modelFernieCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fernies',
      one: '1 fernie',
      zero: 'sin fernies',
    );
    return '$_temp0';
  }

  @override
  String get modelDeleteTitle => '¿Borrar este modelo?';

  @override
  String get modelDeleteMessage =>
      'Sus fernies se quedan donde están: son tuyos, no del modelo. Lo que se pierde es lo que había aprendido: los pesos, las gráficas del entrenamiento y todo lo que dejó en el disco.';

  @override
  String get splitTrain => 'Entrenar';

  @override
  String get splitValidation => 'Validar';

  @override
  String get splitTest => 'Probar';

  @override
  String get modelRemoveFernie => 'Sacar de este modelo';

  @override
  String modelMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos',
      one: '1 contenido',
      zero: 'sin contenidos',
    );
    return '$_temp0';
  }

  @override
  String modelTooFewRegions(int count) {
    return 'Menos de $count regiones: no da para entrenar';
  }

  @override
  String modelFewRegions(int count) {
    return 'Menos de $count regiones: aprenderá poco';
  }

  @override
  String get modelTooFewMedia =>
      'Pocos contenidos distintos: aprenderá el fondo';

  @override
  String get modelAssignedFernies => 'Fernies asignados';

  @override
  String get modelAddFernie => 'Añadir fernie';

  @override
  String get modelNoFernies =>
      'Un modelo sin fernies no tiene nada que aprender. Añade al menos uno.';

  @override
  String get modelApplySplitToAll => 'Aplicar este reparto a todos';

  @override
  String get modelRetrainNotice =>
      'Cambiar los fernies de un modelo entrenado obliga a volver a entrenarlo: sus pesos ya no significan lo mismo.';

  @override
  String get modelSaved => 'Guardado';

  @override
  String get trainingTitle => 'Entrenamiento';

  @override
  String get presetFast => 'Rápido';

  @override
  String get presetFastDescription =>
      'Para ver si la idea funciona antes de dejar el equipo toda la noche. También lo razonable sin tarjeta gráfica.';

  @override
  String get presetBalanced => 'Equilibrado';

  @override
  String get presetBalancedDescription =>
      'Lo que se quiere casi siempre: da para usar el modelo de verdad.';

  @override
  String get presetAccurate => 'Esmerado';

  @override
  String get presetAccurateDescription =>
      'Cuando ya hay muchas regiones y el modelo importa. Tarda un buen rato.';

  @override
  String get presetCustom => 'Personalizado';

  @override
  String get presetCustomDescription =>
      'Los mandos no coinciden con ninguno de los de arriba, así que mandan los tuyos.';

  @override
  String get trainingAdvanced => 'Avanzado';

  @override
  String get trainingEpochsLabel => 'Épocas';

  @override
  String get trainingImageSizeLabel => 'Tamaño de imagen';

  @override
  String get trainingBatchLabel => 'Lote';

  @override
  String get trainingBatchAuto => '-1 deja que lo decida él';

  @override
  String trainingBackboneIs(String backbone) {
    return 'Red: $backbone';
  }

  @override
  String get trainingStart => 'Entrenar modelo';

  @override
  String get trainingRetrain => 'Volver a entrenar';

  @override
  String get trainingPreparing => 'Preparando el material...';

  @override
  String get trainingCancelling => 'Parando al terminar esta época…';

  @override
  String trainingEpoch(int done, int total) {
    return 'Época $done de $total';
  }

  @override
  String trainingRemaining(int minutes) {
    return 'Quedan unos $minutes min';
  }

  @override
  String get trainingEngineNotReady =>
      'El motor de reconocimiento todavía no está instalado. Se prepara desde los ajustes.';

  @override
  String get trainingNoValidation =>
      'no deja nada para validar, así que el entrenamiento no sabrá cuándo parar';

  @override
  String trainingImbalanced(int count) {
    return 'Un fernie tiene más de $count veces las regiones de otro: el modelo aprenderá a contestar siempre el mayoritario';
  }

  @override
  String get metricsLastTraining => 'Último entrenamiento';

  @override
  String get metricMap50 => 'mAP50';

  @override
  String get metricMap50to95 => 'mAP50-95';

  @override
  String get metricPrecision => 'Precisión';

  @override
  String get metricRecall => 'Recall';

  @override
  String get metricsPerClass => 'Por fernie';

  @override
  String get metricsConfusionMatrix => 'Matriz de confusión';

  @override
  String get metricsCurves => 'Curvas';

  @override
  String get metricsOpenRunFolder => 'Abrir carpeta de la run';

  @override
  String get metricsRunFolderMissing => 'Esa carpeta ya no está.';

  @override
  String get metricsRunImagesMissing =>
      'Esas imágenes ya no están en la carpeta de la run. Borrarla no rompe el modelo: los pesos son lo único que hace falta para reconocer.';

  @override
  String get metricsNotTrainedYet => 'Todavía sin entrenar.';

  @override
  String get metricsImportedWeights =>
      'Los pesos vienen de fuera, así que no hay métricas de entrenamiento.';

  @override
  String get metricsRetry => 'Volver a intentarlo';

  @override
  String get metricsRealPerformance => 'Rendimiento real';

  @override
  String get metricsRealPerformanceEmpty =>
      'Aún sin datos. Cuenta cuántas sugerencias de este modelo aceptas y cuántas rechazas al importar, que es la única medida honesta de si sirve.';

  @override
  String get modelImportWeightsHint =>
      'Un fichero .pt entrenado en otro sitio. Se copia a la carpeta de reconocimiento para que no desaparezca por debajo del modelo.';

  @override
  String get modelForgetTrainingHint => 'Olvidar lo entrenado';

  @override
  String modelForgetTrainingTitle(String model) {
    return '¿Olvidar lo que aprendió $model?';
  }

  @override
  String get modelForgetTrainingLoses =>
      'Se van los pesos, las métricas y la fecha del entrenamiento, ficheros incluidos. Volver a entrenarlo cuesta lo que costó la primera vez.';

  @override
  String get modelForgetTrainingKeeps =>
      'Los hiperparámetros, los fernies y el reparto se quedan como están. El modelo vuelve a estar sin entrenar y sigue donde estaba en el árbol.';

  @override
  String get modelForgetTrainingAction => 'Olvidarlo';

  @override
  String get modelForgetTrainingDone => 'De ese entrenamiento no queda nada.';

  @override
  String modelImportWeightsInvalid(String error) {
    return 'No se han podido leer esos pesos: $error';
  }

  @override
  String modelImportWeightsDone(String classes) {
    return 'Pesos importados: $classes';
  }

  @override
  String get modelImportedBadge => 'Pesos importados';

  @override
  String get trainingFailedEngineStopped =>
      'El motor de reconocimiento se paró a media faena. Vuelve a intentarlo; si se repite, lo más probable es que el equipo se esté quedando sin memoria: baja el tamaño de imagen o el lote en «Avanzado».';

  @override
  String get trainingFailedOutOfMemory =>
      'Se quedó sin memoria. Baja el lote o el tamaño de imagen en «Avanzado» y vuelve a intentarlo.';

  @override
  String get trainingFailedDataset =>
      'No se pudo preparar el material. Puede que algún contenido se haya movido o borrado desde que se marcaron las regiones.';

  @override
  String get trainingFailedWeights =>
      'Faltan los pesos de partida y no se han podido descargar. Comprueba la conexión, o importa unos pesos tuyos.';

  @override
  String get trainingFailedNoSpace =>
      'No cabe en el disco. Un conjunto de vídeo son miles de fotogramas, así que hacen falta unos cuantos gigas libres.';

  @override
  String get trainingFailedUnknown => 'El entrenamiento ha fallado.';

  @override
  String jobTrainingModel(String model) {
    return 'Entrenando «$model»';
  }

  @override
  String get jobsNone => 'No hay tareas';

  @override
  String get treeTitle => 'Árbol de modelos';

  @override
  String get treeOpen => 'Árbol';

  @override
  String get treeEmpty =>
      'Todavía no hay nada en el árbol. Un modelo que no esté aquí no se ejecuta nunca al reconocer: mete uno desde el panel de la derecha.';

  @override
  String get treeSearchModel => 'Buscar modelo';

  @override
  String get treeAvailableModels => 'Modelos';

  @override
  String get treeAllInTree => 'Ya están todos en el árbol.';

  @override
  String get treeNoModels => 'Todavía no hay modelos.';

  @override
  String get treeRemoveNode => 'Sacar del árbol';

  @override
  String get treeNodeNotTrained => 'Sin entrenar';

  @override
  String treeSelectedHint(String name) {
    return '«$name» está elegido: lo que metas desde el panel colgará de él.';
  }

  @override
  String get treeClearSelection => 'Soltar';

  @override
  String get treeEdgeAnyDetection => 'cualquier cosa';

  @override
  String get treeEdgeConditionTitle => '¿Cuándo se ejecuta?';

  @override
  String treeEdgeConditionMessage(String child, String parent) {
    return '«$child» sólo se ejecuta cuando «$parent» detecta esto. Sin fernie se ejecuta ante cualquier detección, que es tener los especializados corriendo todo el rato: funciona, pero es lo que hay que afinar.';
  }

  @override
  String get treeEdgeDisconnect => 'Descolgar';

  @override
  String get treeFitToView => 'Ajustar a la vista';

  @override
  String get treeZoomIn => 'Acercar';

  @override
  String get treeZoomOut => 'Alejar';

  @override
  String get treeCannotConnect =>
      'Eso no se puede colgar: el árbol se mordería la cola.';

  @override
  String treeOutsideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos fuera del árbol',
      one: '1 modelo fuera del árbol',
    );
    return '$_temp0';
  }

  @override
  String get viewerFavorite => 'Marcar como favorito';

  @override
  String get viewerUnfavorite => 'Quitar de favoritos';

  @override
  String get viewerCopied => 'Copiado al portapapeles';

  @override
  String get viewerCopyFailed => 'No se ha podido copiar el contenido';

  @override
  String get actionRevealInExplorer => 'Ver el fichero en el explorador';

  @override
  String get revealInExplorerFailed => 'El fichero ya no está donde estaba.';

  @override
  String get mediaInfoTitle => 'Información';

  @override
  String get descriptionHint => 'Añade una descripción';

  @override
  String get createdBy => 'Creado por:';

  @override
  String tagDropped(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos etiquetados con $tag',
      one: 'Etiquetado con $tag',
    );
    return '$_temp0';
  }

  @override
  String contextMenuTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sobre los $count seleccionados',
      one: 'Sobre este contenido',
    );
    return '$_temp0';
  }

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get noTagsYet => 'Todavía no hay etiquetas';

  @override
  String get creatorsTitle => 'Creadores';

  @override
  String get noCreatorsYet => 'Todavía no hay creadores';

  @override
  String get noSocialProfiles => 'Sin perfiles sociales';

  @override
  String get openProfileTooltip => 'Abrir el perfil en el navegador';

  @override
  String get editProfileTooltip => 'Editar el enlace';

  @override
  String get doneEditingProfileTooltip => 'Terminar de editar';

  @override
  String get removeProfileTooltip => 'Quitar el enlace';

  @override
  String get tagNameSearchLabel => 'Nombre de la etiqueta';

  @override
  String get tagSearchHint => 'Etiqueta';

  @override
  String get createTag => 'Crear etiqueta';

  @override
  String get searchCreatorLabel => 'Buscar creador';

  @override
  String get creatorSearchHint => 'Nombre';

  @override
  String get createCreator => 'Crear creador';

  @override
  String get newTagTitle => 'Nueva etiqueta';

  @override
  String get tagNameLabel => 'Nombre de la etiqueta';

  @override
  String get tagRelationsTitle => 'Dónde está esta etiqueta';

  @override
  String get tagRelationsNote =>
      'Arriba, la etiqueta de la que cuelga. A los lados, con las que va. Son dos cosas distintas: una etiqueta que cuelga de otra hereda su contenido en las búsquedas, y las que van juntas sólo están relacionadas.';

  @override
  String get tagRelationsAddParent => 'Poner etiqueta madre';

  @override
  String get tagRelationsChangeParent => 'Cambiar la madre';

  @override
  String get tagRelationsAddSibling => 'Añadir relacionada';

  @override
  String get tagCollapseBranch => 'Plegar lo que cuelga de esta';

  @override
  String get tagExpandBranch => 'Desplegar lo que cuelga de esta';

  @override
  String get siblingDirectionBoth => 'Cada una pone la otra';

  @override
  String siblingDirectionOneWay(String from, String to) {
    return '«$from» pone «$to»';
  }

  @override
  String get siblingDirectionNone => 'Ninguna pone la otra';

  @override
  String get siblingDirectionNote =>
      'Estar relacionadas dice que van juntas. La dirección dice qué pasa al poner una.';

  @override
  String get tagRelationsCreate => 'Crear una etiqueta nueva';

  @override
  String get tagRelationsTooltip => 'Etiqueta madre y relacionadas';

  @override
  String get tagRelationsNoParent => 'Etiqueta raíz';

  @override
  String tagRelationsParentIs(String name) {
    return 'Cuelga de $name';
  }

  @override
  String tagRelationsSiblingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relacionadas',
      one: '1 relacionada',
    );
    return '$_temp0';
  }

  @override
  String get addSiblingTag => 'Añadir relacionada';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get parentTagLabel => 'Etiqueta padre (opcional)';

  @override
  String get newCreatorTitle => 'Nuevo creador';

  @override
  String get creatorNameLabel => 'Nombre del creador';

  @override
  String get creatorNameTaken => 'Ya hay un creador con ese nombre';

  @override
  String get socialProfilesLabel => 'Perfiles sociales';

  @override
  String get enterNameHint => 'Escribe un nombre';

  @override
  String get searchEllipsisHint => 'Buscar...';

  @override
  String get profileLinkHint => 'Enlace al perfil';

  @override
  String get addProfile => 'Añadir perfil';

  @override
  String get resultTypeMedia => 'contenido';

  @override
  String get resultTypeTag => 'etiqueta';

  @override
  String get resultTypeCreator => 'creador';

  @override
  String get noFolderSelected => 'Ninguna carpeta seleccionada';

  @override
  String get chooseFolder => 'Elegir carpeta';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsViewer => 'Visor';

  @override
  String get settingsFiles => 'Archivos';

  @override
  String get settingsRemoteSources => 'Fuentes remotas';

  @override
  String get languageSectionTitle => 'Idioma de la aplicación';

  @override
  String get languageSectionNote =>
      'Toda la aplicación cambia de idioma en cuanto eliges uno.';

  @override
  String get sidebarSectionTitle => 'Menú lateral';

  @override
  String get sidebarSectionNote =>
      'Cómo se pinta la lista de etiquetas del menú lateral.';

  @override
  String get showListAvatars => 'Mostrar avatares en lista';

  @override
  String get showListAvatarsDescription =>
      'Cada etiqueta se pinta con su propia imagen en vez del icono común, así se distinguen con el menú plegado. Las etiquetas sin imagen se quedan con el icono.';

  @override
  String get keepsSelectionOnDrop =>
      'Mantener la selección al soltarla en una etiqueta';

  @override
  String get keepsSelectionOnDropDescription =>
      'Apagado, soltar contenido en una etiqueta lo deja sin marcar, que es dar el trabajo por terminado. Encendido se queda marcado, para poder ponerle otra etiqueta seguida sin volver a señalarlo todo.';

  @override
  String get useCurrentImageAsAvatar => 'Usar la imagen que estás viendo';

  @override
  String get avatarCropTitle => 'Elige el avatar';

  @override
  String get avatarCropHint =>
      'Arrastra un cuadrado sobre la imagen. Con la rueda se acerca.';

  @override
  String get avatarCropWholeImage => 'Usar la imagen entera';

  @override
  String get avatarSourceTitle => '¿De dónde sale la imagen?';

  @override
  String get avatarSourceLibrary => 'De la biblioteca de Fern';

  @override
  String get avatarSourceDevice => 'De un fichero del equipo';

  @override
  String get avatarLibraryEmpty => 'Aquí no hay nada que encaje';

  @override
  String get tagLogTitle => 'De dónde sale esto';

  @override
  String get tagLogNote =>
      'Lo que se le ha puesto a este contenido, y por qué.';

  @override
  String get tagLogGuessNote =>
      'Parte de esto no se apuntó: se deduce de cómo están los datos ahora, no de lo que pasó. Esas líneas van marcadas.';

  @override
  String get tagLogGuessed => 'deducido';

  @override
  String get tagLogLoading => 'Leyendo el registro…';

  @override
  String get tagLogEmpty => 'A este contenido no se le ha puesto nada.';

  @override
  String get tagLogManual => 'La pusiste tú';

  @override
  String get tagLogSourceUrl => 'Casó una dirección vinculada';

  @override
  String get tagLogPlatform => 'La plataforma de la que se bajó';

  @override
  String get tagLogAncestor => 'Heredada de la rama';

  @override
  String tagLogAncestorOf(String tag) {
    return 'Está por encima de $tag';
  }

  @override
  String get tagLogSibling => 'Va con otra etiqueta';

  @override
  String tagLogSiblingOf(String tag) {
    return 'Va con $tag';
  }

  @override
  String get tagLogRecognition => 'Aceptaste lo que propuso un modelo';

  @override
  String get tagLogFernie => 'Lo que enlaza un fernie marcado';

  @override
  String tagLogFernieOf(String fernie) {
    return 'Marcaste aquí a $fernie';
  }

  @override
  String get tagLogUnknown => 'No consta';

  @override
  String get actionTagLog => 'De dónde sale esto';

  @override
  String get viewerSaveSectionTitle => 'Al guardar contenido importado';

  @override
  String get viewerSaveSectionNote =>
      'Qué hace el visor cuando das por definitivo un contenido importado. Sea como sea deja de estar en la rejilla de importación, así que el visor no puede quedarse donde estaba.';

  @override
  String get viewerPrevious => 'Anterior';

  @override
  String get viewerNext => 'Siguiente';

  @override
  String get viewerSaveNext => 'Ir al siguiente contenido';

  @override
  String get viewerSaveNextDescription =>
      'El visor pasa al siguiente contenido, igual que si hubieras pulsado la flecha. Si no queda nada por revisar, se cierra.';

  @override
  String get viewerSaveClose => 'Cerrar la visualización';

  @override
  String get viewerSaveCloseDescription =>
      'El visor se cierra y vuelves a la rejilla de importación, ya sin ese contenido.';

  @override
  String get themeSectionTitle => 'Tema';

  @override
  String get themeSectionNote =>
      'Los colores con los que se pinta toda la aplicación.';

  @override
  String get themeSystem => 'Seguir al sistema';

  @override
  String get themeSystemDescription =>
      'Claro u oscuro, el que esté usando tu escritorio.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightDescription => 'Los colores de siempre de Fern.';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDarkDescription =>
      'La misma aplicación, para un escritorio oscuro.';

  @override
  String get themeCustom => 'A medida';

  @override
  String get themeCustomDescription =>
      'Tus colores, los que elijas aquí debajo.';

  @override
  String get customColorsTitle => 'Tus colores';

  @override
  String get customColorsNote =>
      'Sólo se pueden tocar con el tema a medida. Lo que no cambies se toma del tema claro o del oscuro, el que le vaya al fondo que hayas elegido.';

  @override
  String get customColorPrimary => 'Primario';

  @override
  String get customColorSecondary => 'Secundario';

  @override
  String get customColorTerciary => 'Acento';

  @override
  String get customColorError => 'Error';

  @override
  String get customColorBackground => 'Fondo';

  @override
  String get customColorSurface => 'Superficie';

  @override
  String get customColorForeground => 'Texto';

  @override
  String get customColorPick => 'Elegir color';

  @override
  String get customColorReset => 'Volver al color de fábrica';

  @override
  String get colorPickerTitle => 'Elige un color';

  @override
  String get colorPickerHex => 'Código hexadecimal';

  @override
  String get filesLocalTitle => 'Archivos locales';

  @override
  String get syncLocalFiles => 'Sincronizar archivos locales';

  @override
  String get syncLocalFilesDescription =>
      'Fern mueve a una carpeta propia el contenido con el que trabaja, tanto el que ya está importado como el que llegue después.';

  @override
  String get libraryFolder => 'Carpeta de la biblioteca';

  @override
  String get copyFiles => 'Copiar archivos';

  @override
  String get copyFilesDescription =>
      'Conserva el archivo original donde estaba y trabaja con una copia dentro de la carpeta de la biblioteca.';

  @override
  String get avatarsTitle => 'Avatares';

  @override
  String get avatarsDescription =>
      'Las imágenes de los avatares siempre se copian a una carpeta propia, esté o no activada la sincronización de archivos locales. Al cambiar de carpeta, los avatares que ya existan se llevan con ella.';

  @override
  String get avatarsFolder => 'Carpeta de avatares';

  @override
  String get organizationTitle => 'Ordenación';

  @override
  String get organizationDescription =>
      'Cómo se reparten los archivos dentro de la carpeta de la biblioteca. No afecta a las imágenes de los avatares.';

  @override
  String get organizationFlat => 'Todos los archivos juntos';

  @override
  String get organizationFlatDescription =>
      'Cada archivo queda directamente en la carpeta de la biblioteca';

  @override
  String get organizationByTag => 'Subcarpetas por etiqueta';

  @override
  String get organizationByTagDescription =>
      'Una carpeta por etiqueta, tomada de la primera etiqueta del contenido';

  @override
  String get organizationBySource => 'Subcarpetas por fuente';

  @override
  String get organizationBySourceDescription =>
      'Una carpeta por origen: local, Pixiv, Twitter...';

  @override
  String get organizationByCreator => 'Subcarpetas por creador';

  @override
  String get organizationByCreatorDescription => 'Una carpeta por creador';

  @override
  String get migrationTitle => 'Migración';

  @override
  String get migrationDescription =>
      'Ordena con los criterios de arriba todos los archivos que ya están en la biblioteca.';

  @override
  String get migrateFiles => 'Migrar archivos';

  @override
  String avatarsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avatares movidos a la carpeta nueva',
      one: '1 avatar movido a la carpeta nueva',
      zero: 'Los avatares ya estaban en esa carpeta',
    );
    return '$_temp0';
  }

  @override
  String get avatarsMoveFailed => 'No se han podido mover los avatares';

  @override
  String filesOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos movidos',
      one: '1 archivo movido',
      zero: 'Ya estaba todo en su sitio',
    );
    return '$_temp0';
  }

  @override
  String get filesOrganizeFailed => 'No se han podido ordenar los archivos';

  @override
  String get redditTitle => 'Reddit';

  @override
  String get redditDescription =>
      'Fern se descarga lo que tengas guardado en tu cuenta de Reddit. Registra una aplicación de tipo script en reddit.com/prefs/apps para conseguir las dos claves.';

  @override
  String get redditClientId => 'ID de cliente';

  @override
  String get redditClientIdHint =>
      'La clave que aparece bajo el nombre de tu aplicación';

  @override
  String get redditClientSecret => 'Secreto de cliente';

  @override
  String get redditClientSecretHint => 'El secreto de tu aplicación';

  @override
  String get redditUsername => 'Usuario';

  @override
  String get redditUsernameHint => 'Tu cuenta de Reddit, sin /u/';

  @override
  String get redditPassword => 'Contraseña';

  @override
  String get redditPasswordHint => 'La contraseña de esa cuenta';

  @override
  String get redditCredentialsNote =>
      'Las credenciales se quedan en este equipo y sólo se usan para hablar con Reddit.';

  @override
  String get settingsDatabase => 'Base de datos';

  @override
  String get databaseSectionTitle => 'Base de datos';

  @override
  String get databaseSectionNote =>
      'Todo lo que Fern sabe de tu biblioteca vive en una base de datos de este equipo: las fichas de los contenidos, las etiquetas, los creadores, los fernies, los modelos y las regiones marcadas.';

  @override
  String get databaseWipeTitle => 'Eliminar la base de datos';

  @override
  String get databaseWipeSectionNote =>
      'Deja Fern como recién instalado. No se puede deshacer y no hay copia de seguridad de la que tirar.';

  @override
  String get databaseWipeWarning =>
      'Esto no se puede deshacer. Fern no guarda ninguna copia de la base de datos.';

  @override
  String get databaseWipeLoses =>
      'Se pierden: todas las fichas de contenido con su descripción y sus favoritos, todas las etiquetas y creadores, los fernies y todas las regiones marcadas sobre ellos, los modelos entrenados y su árbol, las sugerencias del reconocimiento y los grupos de repetidos.';

  @override
  String get databaseWipeKeeps =>
      'Tus ficheros se quedan donde están: no se borra nada del disco, y escanear la carpeta de la biblioteca los vuelve a dar de alta. Los ajustes, las contraseñas y las credenciales de las fuentes también se quedan.';

  @override
  String get databaseWipeScopeAll => 'Todo';

  @override
  String get databaseWipeScopeAllNote =>
      'Etiquetas, creadores, fernies, modelos: todo. La aplicación empieza de cero.';

  @override
  String get databaseWipeScopeNsfw => 'Sólo lo marcado como NSFW';

  @override
  String get databaseWipeScopeNsfwNote =>
      'El contenido marcado y lo que hereda de etiquetas y creadores marcados. Las etiquetas, los creadores, los fernies y los modelos se quedan.';

  @override
  String get databaseWipeFiles => 'Borrar también los ficheros del disco';

  @override
  String get databaseWipeFilesNote =>
      'Sin esto los ficheros se quedan donde están y un escaneo los vuelve a traer. Con esto se van: es la parte que no tiene vuelta.';

  @override
  String get databaseWipeConfirmFiles =>
      'Los ficheros se van también del disco. Se borran en segundo plano y se puede seguir en la lista de tareas.';

  @override
  String get databaseWipeConfirmNsfw =>
      'Se va sólo lo marcado como NSFW. Todo lo demás se queda como está.';

  @override
  String get databaseWipeContinue => 'Lo entiendo, continuar';

  @override
  String get databaseWipeConfirmTitle => 'Escribe la frase para confirmar';

  @override
  String get databaseWipeConfirmNote =>
      'Para asegurar que no es un accidente, escribe la siguiente frase tal y como está:';

  @override
  String get databaseWipePhrase => 'Eliminar Base de Datos';

  @override
  String get databaseWipeFieldLabel => 'Frase de confirmación';

  @override
  String get databaseWipeAction => 'Eliminar base de datos';

  @override
  String get databaseWipeFailed => 'No se ha podido eliminar la base de datos.';

  @override
  String get databaseWipeDone => 'La base de datos está vacía.';

  @override
  String get settingsBrowser => 'Navegador';

  @override
  String get browserHome => 'Página de inicio';

  @override
  String get browserHomeTitle => 'Página de inicio';

  @override
  String get browserHomeDescription =>
      'Por dónde empieza el navegador de Fern al pulsar el botón de inicio. No decide por dónde se abre: al volver a la pantalla, el navegador se queda en la última página que visitaste.';

  @override
  String get browserHomeLabel => 'Dirección';

  @override
  String credentialsRejectedTitle(String source) {
    return '$source no ha aceptado tus credenciales';
  }

  @override
  String credentialsRejectedDescription(String source) {
    return 'No se ha podido importar nada: $source ha rechazado la cuenta o la clave que se le daban. Revísalas en Ajustes, en Fuentes remotas.';
  }

  @override
  String get actionOpenRemoteSettings => 'Abrir ajustes';

  @override
  String sessionExpiredTitle(String source) {
    return 'La sesión de $source ya no vale';
  }

  @override
  String sessionExpiredDescription(String source) {
    return 'No se ha podido importar nada: $source ha rechazado la sesión guardada. Vuelve a iniciar sesión en el navegador y pulsa allí el botón de la llave para guardar la nueva.';
  }

  @override
  String browserImportedInto(int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos listos para revisar en $source',
      one: '1 contenido listo para revisar en $source',
    );
    return '$_temp0';
  }

  @override
  String browserImportKnown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya estaban en la biblioteca',
      one: '1 ya estaba en la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String browserImportFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no se han podido descargar',
      one: '1 no se ha podido descargar',
    );
    return '$_temp0';
  }

  @override
  String get browserImportNothing => 'No se ha traído nada.';

  @override
  String get redditGuideAction => '¿Cómo consigo esto?';

  @override
  String get redditGuideTitle => 'Conectar Fern con Reddit';

  @override
  String get redditGuideIntro =>
      'Reddit no deja que nadie lea tus guardados hasta que registres una aplicación en tu cuenta. Son un par de minutos y se hace una sola vez.';

  @override
  String get redditGuideStep1 =>
      'Abre reddit.com/prefs/apps con el botón de abajo. Se abre dentro de Fern, así que ya estás dentro de tu cuenta.';

  @override
  String get redditGuideStep2 =>
      'Baja hasta el final de la página y pulsa «create another app...» (o «are you a developer? create an app...»).';

  @override
  String get redditGuideStep3 =>
      'Elige el tipo «script». Es el paso que se falla: con cualquier otro tipo Reddit crea la aplicación igual, y luego rechaza cada petición sin decir por qué.';

  @override
  String get redditGuideStep4 =>
      'Ponle el nombre que quieras, deja la descripción vacía y pega esto en «redirect uri»:';

  @override
  String get redditGuideStep5 =>
      'Pulsa «create app». Reddit te enseña la ficha de la aplicación que acabas de crear.';

  @override
  String get redditGuideStep6 =>
      'El client ID es la cadena corta que hay justo debajo de «personal use script», arriba a la izquierda de la ficha. El secret es el campo que pone «secret».';

  @override
  String get redditGuideStep7 =>
      'Vuelve aquí y pega los dos, más tu usuario y tu contraseña de Reddit.';

  @override
  String get redditGuideTwoFactor =>
      'Con la verificación en dos pasos activada, la contraseña se escribe como contraseña:código — Reddit espera las dos cosas en el mismo campo.';

  @override
  String get redditGuidePrivacy =>
      'Los cuatro datos se quedan en este equipo, cifrados, y sólo se mandan a Reddit.';

  @override
  String get redditGuideOpen => 'Abrir Reddit';

  @override
  String get redditGuideCopy => 'Copiar la dirección de redirección';

  @override
  String get redditGuideCopied => 'Dirección de redirección copiada';

  @override
  String get emptyLibraryHint =>
      'Lo que traigas de una plataforma o de una carpeta aparece aquí en cuanto lo hayas revisado.';

  @override
  String get noTagsYetHint =>
      'Las etiquetas son con lo que vuelves a encontrar las cosas. Crea una desde el + de la barra de arriba.';

  @override
  String get noCreatorsYetHint =>
      'Un creador agrupa todo lo que ha hecho la misma persona. Crea uno desde el + de la barra de arriba.';

  @override
  String get noFerniesYetHint =>
      'Un fernie es alguien que un modelo aprende a reconocer. Crea uno desde el + de la barra de arriba y márcalo en tu contenido.';

  @override
  String get modelsEmptyHint =>
      'Un modelo aprende a reconocer a tus fernies. Crea uno desde el + de la barra de arriba.';

  @override
  String get duplicatesNeverScannedHint =>
      'Pulsa «Buscar ahora» y Fern repasa la biblioteca entera. La primera vez puede tardar un rato.';

  @override
  String get duplicatesNoneHint =>
      'Vuelve a buscar después de importar, o baja el listón de parecido en Ajustes.';

  @override
  String get viewerInfoTooltip => 'Ver la información';

  @override
  String get settingsOpenTooltip => 'Abrir los ajustes';

  @override
  String get mediaFileMissing => 'El fichero ya no está donde estaba';

  @override
  String get danbooruTitle => 'Danbooru';

  @override
  String get danbooruDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Danbooru. Su API es pública: sólo hacen falta el nombre de tu cuenta y una clave de API.';

  @override
  String get danbooruUsername => 'Nombre de la cuenta';

  @override
  String get danbooruUsernameHint => 'Tu nombre de usuario en Danbooru';

  @override
  String get danbooruApiKey => 'Clave de API';

  @override
  String get danbooruApiKeyHint => 'Una clave de tu perfil de Danbooru';

  @override
  String get danbooruApiKeyNote =>
      'En Danbooru, abre tu perfil, ve a API Key y crea una. No es tu contraseña: puedes revocarla cuando quieras sin tocar nada más. Se queda en este equipo y sólo se usa para hablar con Danbooru.';

  @override
  String get gelbooruTitle => 'Gelbooru';

  @override
  String get gelbooruDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Gelbooru. Su API de favoritos es más lenta que las demás: da referencias en lugar de publicaciones, así que hay que pedir cada una aparte.';

  @override
  String get gelbooruUserId => 'Identificador de la cuenta';

  @override
  String get gelbooruUserIdHint => 'El número de tu cuenta de Gelbooru';

  @override
  String get gelbooruApiKey => 'Clave de API';

  @override
  String get gelbooruApiKeyHint => 'La clave de esa cuenta';

  @override
  String get gelbooruApiKeyNote =>
      'En Gelbooru, entra en My Account, luego en Options, y busca API Access Credentials: ahí están el identificador y la clave. Se quedan en este equipo y sólo se usan para hablar con Gelbooru.';

  @override
  String get pinterestTitle => 'Pinterest';

  @override
  String get pinterestDescription =>
      'Fern se descarga lo que tengas guardado en Pinterest. Para lo que esté en tableros públicos no hace falta nada más que el nombre de tu cuenta.';

  @override
  String get pinterestUsername => 'Nombre de la cuenta';

  @override
  String get pinterestUsernameHint => 'Tu nombre de usuario en Pinterest';

  @override
  String get pinterestSecretBoardsNote =>
      'Para traerte también lo que guardas en tableros secretos, inicia sesión en Pinterest desde el navegador de Fern y pulsa allí el botón de la llave: la sesión se guarda junto al nombre.';

  @override
  String get pawchiveTitle => 'Pawchive';

  @override
  String get pawchiveDescription =>
      'Fern se descarga las publicaciones que tengas en favoritos en Pawchive. Aquí no hay nada que rellenar: inicia sesión desde el navegador de Fern y pulsa allí el botón de la llave, y la sesión se guarda sola.';

  @override
  String get sourceGuideOpenSite => 'Abrir el sitio';

  @override
  String get sourceGuideOpenLogin => 'Abrir la pantalla de entrada';

  @override
  String get sourceGuidePrivacy =>
      'Lo que pegues se queda en este equipo, cifrado, y sólo se manda a ese sitio.';

  @override
  String get sessionGuideStep1 =>
      'Pulsa el botón de abajo. Fern abre el sitio en su propio navegador y te lleva a la pantalla de entrar.';

  @override
  String get sessionGuideStep2 =>
      'Entra igual que lo harías en cualquier otro sitio: captcha, código por correo y todo. Es justamente por eso por lo que esto no se puede hacer desde fuera.';

  @override
  String get sessionGuideStep3 =>
      'Cuando estés dentro, pulsa la llave de la barra del navegador para guardar la sesión. Sin este paso no se guarda nada y la importación seguirá diciendo que no está configurada.';

  @override
  String get sessionGuideExpires =>
      'Las sesiones caducan solas al cabo de un tiempo. Cuando pase, Fern te avisa y basta con repetir estos pasos.';

  @override
  String get danbooruGuideTitle => 'Conectar Fern con Danbooru';

  @override
  String get danbooruGuideIntro =>
      'Danbooru le da a cada cuenta una clave de API para que los programas puedan leer en su nombre. Se saca de tu ficha, y tu contraseña no entra en esto.';

  @override
  String get danbooruGuideStep1 =>
      'Abre tu ficha con el botón de abajo y asegúrate de que has entrado con tu cuenta.';

  @override
  String get danbooruGuideStep2 =>
      'Busca la fila «API Key» de tu ficha y pulsa «view». Danbooru te pide la contraseña para enseñártela.';

  @override
  String get danbooruGuideStep3 =>
      'Si no hay ninguna todavía, pulsa «Add» y ponle el nombre que quieras. A Fern le basta con una.';

  @override
  String get danbooruGuideStep4 => 'Copia la cadena larga que te enseña.';

  @override
  String get danbooruGuideStep5 =>
      'Vuelve aquí: el usuario es el mismo con el que entras, y en el segundo campo va la clave, no tu contraseña. Danbooru la acepta y sencillamente no devuelve nada.';

  @override
  String get danbooruGuideNote =>
      'Revocar la clave desde esa misma página le corta el paso a Fern al momento, sin tocar tu contraseña.';

  @override
  String get gelbooruGuideTitle => 'Conectar Fern con Gelbooru';

  @override
  String get gelbooruGuideIntro =>
      'Gelbooru te da los dos valores de golpe, escritos en una sola línea. Partir esa línea en dos es todo el trabajo.';

  @override
  String get gelbooruGuideStep1 =>
      'Abre las opciones de tu cuenta con el botón de abajo y asegúrate de que has entrado.';

  @override
  String get gelbooruGuideStep2 =>
      'Baja hasta «API Access Credentials» y abre el enlace que ofrece.';

  @override
  String get gelbooruGuideStep3 =>
      'Gelbooru te enseña una línea con esta pinta: &api_key=abc123&user_id=456.';

  @override
  String get gelbooruGuideStep4 =>
      'Esa línea lleva dos valores distintos dentro. No la pegues entera en un campo: Gelbooru la acepta y luego no funciona nada, sin decir por qué.';

  @override
  String get gelbooruGuideStep5 =>
      'Pon lo que viene después de user_id= en el primer campo, y lo que viene después de api_key= en el segundo.';

  @override
  String get pixivGuideTitle => 'Conectar Fern con Pixiv';

  @override
  String get pixivGuideIntro =>
      'Pixiv no tiene claves que copiar. Aquí no hay nada que escribir: entras dentro de Fern y la sesión es lo que te identifica.';

  @override
  String get pixivGuideStep4 =>
      'Ya está. Aquí no hay nada que pegar: vete a la pantalla de importación y elige Pixiv.';

  @override
  String get pinterestGuideTitle => 'Conectar Fern con Pinterest';

  @override
  String get pinterestGuideIntro =>
      'Con tu nombre de usuario basta para los tableros públicos. La sesión sólo hace falta para los secretos.';

  @override
  String get pinterestGuideStep1 =>
      'Escribe tu nombre de usuario de Pinterest en el campo de arriba. Con eso los tableros públicos ya funcionan.';

  @override
  String get pinterestGuideStep2 =>
      'Sólo si además quieres los tableros secretos, pulsa el botón de abajo y entra con tu cuenta.';

  @override
  String get pawchiveGuideTitle => 'Conectar Fern con Pawchive';

  @override
  String get pawchiveGuideIntro =>
      'Aquí tampoco hay claves: entras dentro de Fern y la sesión es lo que te identifica.';

  @override
  String get pawchiveGuideStep4 =>
      'De vuelta aquí, elige abajo si quieres tus guardados o todo lo de los creadores que sigues.';

  @override
  String get pawchiveGuideLinks =>
      'Las publicaciones suelen enlazar a sitios de descargas (Mega, Drive, Pixeldrain). Fern se trae lo que puede por su cuenta y te lista el resto al terminar la importación.';

  @override
  String linkChoiceTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta publicación trae $count enlaces',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceUntitledPost => 'Publicación sin título';

  @override
  String get linkChoiceApplyToAll => 'Aplicar al resto de la importación';

  @override
  String get linkChoiceApplyToAllDescription =>
      'Se usa la misma respuesta para todas las publicaciones que queden, y no se vuelve a preguntar.';

  @override
  String get linkChoiceIgnore => 'Ignorar publicación';

  @override
  String linkChoiceSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descargar $count',
      zero: 'Descargar selección',
    );
    return '$_temp0';
  }

  @override
  String get linkChoiceAll => 'Descargar todo';

  @override
  String get linkChoiceOpen => 'Ver en el navegador';

  @override
  String pendingLinksToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones llevan a sitios de descargas',
      one: '1 publicación lleva a un sitio de descargas',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones te necesitan',
      one: '1 publicación te necesita',
    );
    return '$_temp0';
  }

  @override
  String get pendingLinksDescription =>
      'Llevan a sitios de descargas que no se pueden recorrer solos: tienen su propia espera, su captcha o su listado de ficheros. Abre los que te interesen y tráetelos desde el navegador.';

  @override
  String get pendingLinksFolder => 'carpeta';

  @override
  String get pendingLinksFile => 'fichero';

  @override
  String get pawchiveByCreators => 'Importar por creadores favoritos';

  @override
  String get pawchiveByCreatorsDescription =>
      'En lugar de las publicaciones que hayas marcado, Fern recorre todo lo que publiquen los creadores que tengas en favoritos. Trae bastante más, y cada creador se sigue por su cuenta.';

  @override
  String get remoteImportAllWarning =>
      'Sin tope, Fern recorre la cuenta entera. Con una cuenta grande son horas de descarga y varios gigas de disco. Puedes pararlo cuando quieras desde la pantalla de importación, y lo que ya haya llegado se queda.';

  @override
  String get remoteImportHeavyWarning =>
      'Esto puede tardar bastante: sin tope, Fern recorre la cuenta entera y se trae todo, incluidos los ficheros que haya dentro de las publicaciones. Puedes pararlo cuando quieras desde la pantalla de importación, y lo que ya haya llegado se queda.';

  @override
  String emptySource(String source) {
    return 'No había nada que traer de $source.';
  }

  @override
  String get emptySourcePawchiveCreators =>
      'No tienes publicaciones marcadas en Pawchive, pero sí creadores favoritos. Activa «Importar por creadores favoritos» en Ajustes, dentro de Fuentes remotas, y Fern recorrerá todo lo que publiquen.';

  @override
  String get browserAddressHint => 'Dirección de un sitio';

  @override
  String get browserBack => 'Atrás';

  @override
  String get browserForward => 'Adelante';

  @override
  String browserLoadFailed(String reason) {
    return 'No se ha podido cargar la página ($reason)';
  }

  @override
  String browserLoadFailedHome(String reason) {
    return 'No se ha podido cargar la página ($reason); se vuelve a la de inicio';
  }

  @override
  String get browserReset => 'Empezar de cero';

  @override
  String get browserResetDone => 'El navegador se ha reiniciado';

  @override
  String get browserResetting => 'Cerrando el motor del navegador…';

  @override
  String get browserSlow => 'Esta página está tardando más de lo normal';

  @override
  String get browserEngineStuck =>
      'La página ha cargado pero no se está pintando nada. El motor del navegador ha dejado de responder: cierra Fern del todo y vuelve a abrirlo.';

  @override
  String get browserAsideImporting =>
      'El navegador está apartado mientras se importa';

  @override
  String get browserAsideImportingWhy =>
      'Traerse mucho contenido de golpe exprime la máquina, y eso es lo que deja al navegador cargando páginas que luego no pinta. Lo que no está en marcha no se puede romper.';

  @override
  String get browserAsideAnyway => 'Traerlo de vuelta igualmente';

  @override
  String get browserAsideOnce =>
      'Sólo para esta visita: al salir y volver se aparta otra vez.';

  @override
  String get browserAsideTitle => 'El navegador durante las importaciones';

  @override
  String get browserAsideNote =>
      'Traerse mucho contenido de golpe exprime la máquina, y eso es lo que deja al navegador cargando páginas que luego no pinta. Apartarlo lo evita.';

  @override
  String get browserAsideAlways => 'Apartarlo siempre';

  @override
  String get browserAsideAlwaysDescription =>
      'Mientras haya cualquier importación en marcha. Es lo que se ha visto funcionar.';

  @override
  String get browserAsideLarge => 'Sólo en importaciones grandes';

  @override
  String get browserAsideLargeDescription =>
      'Sólo cuando la importación se trae todo, todo lo nuevo, o 50 o más.';

  @override
  String get browserAsideNever => 'Nunca';

  @override
  String get browserAsideNeverDescription =>
      'El navegador se queda. Si se pone en blanco, «Empezar de cero» está en su barra.';

  @override
  String get browserReload => 'Recargar';

  @override
  String get browserSaveSessionHint =>
      'Guardar la sesión de este sitio para poder importar de él';

  @override
  String get browserFindMediaHint => 'Buscar contenido en esta página';

  @override
  String browserImportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count',
      one: 'Importar 1',
    );
    return '$_temp0';
  }

  @override
  String get browserSelectAll => 'Marcar o desmarcar todo';

  @override
  String get browserClose => 'Cerrar';

  @override
  String get browserNoSession =>
      'De este sitio no se puede importar, así que aquí no hay ninguna sesión que guardar.';

  @override
  String browserSessionSaved(String source) {
    return 'Sesión de $source guardada.';
  }

  @override
  String browserSessionMissing(String source) {
    return 'Aquí todavía no hay ninguna sesión de $source: inicia sesión primero.';
  }

  @override
  String get browserNothingFound =>
      'No se ha encontrado contenido en esta página.';

  @override
  String browserFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos encontrados',
      one: '1 contenido encontrado',
    );
    return '$_temp0';
  }

  @override
  String browserImporting(int done, int total) {
    return 'Descargando $done de $total…';
  }

  @override
  String importFailed(String error) {
    return 'La importación no ha podido completarse: $error';
  }

  @override
  String get importLimitAll => 'Todos';

  @override
  String get importLimitSinceLast => 'Nuevos';

  @override
  String get importLimitSinceLastTooltip =>
      'Sólo lo que se ha guardado desde la última importación';

  @override
  String get importLimitTooltip => 'Máximo de elementos que trae un escaneo';

  @override
  String get importAsNsfwTooltip => 'Marcar como NSFW todo lo que se importe';

  @override
  String get lastImportNever => 'Nunca importado';

  @override
  String get sourceNotConfiguredHint =>
      'Configura esta fuente en los ajustes antes de importar de ella';

  @override
  String get lastImportHint =>
      'Cuándo se miró por última vez si esta fuente tenía contenido nuevo';

  @override
  String lastImportMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count min',
      one: 'Hace 1 min',
      zero: 'Ahora mismo',
    );
    return '$_temp0';
  }

  @override
  String lastImportHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count h',
      one: 'Hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String lastImportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get assignUrlsTitle => 'Direcciones vinculadas';

  @override
  String assignUrlsTo(String name) {
    return 'Direcciones vinculadas a $name';
  }

  @override
  String get assignUrlsDescription =>
      'Lo que se importe de estas direcciones se lleva esta etiqueta solo, sin preguntarle nada a la plataforma.';

  @override
  String get assignUrlsTooltip => 'Vincular direcciones con esta etiqueta';

  @override
  String get assignUrlsCreatorDescription =>
      'Lo que se importe de estas direcciones se lleva este creador solo, sin preguntarle nada a la plataforma.';

  @override
  String get assignUrlsCreatorTooltip =>
      'Vincular direcciones con este creador';

  @override
  String get sourceUrlsNote =>
      'Vale cualquier plataforma: se recoge todo lo que cuelgue de la dirección. En las que identifican la galería con lo que va detrás del «?» —Danbooru, Gelbooru— hay que copiar la dirección entera, parámetros incluidos.';

  @override
  String get sourceUrlsLabel => 'Direcciones';

  @override
  String get sourceUrlHint => 'reddit.com/r/ejemplo, pixiv.net/users/123…';

  @override
  String get addSourceUrl => 'Añadir dirección';

  @override
  String get noSourceUrls => 'Sin direcciones vinculadas';

  @override
  String get databaseCleanupTitle => 'Limpiar ficheros sueltos';

  @override
  String get databaseCleanupNote =>
      'Los avatares son copias que hace Fern. Al cambiar uno, la copia anterior deja de usarla nadie y se queda en el disco. Esto se lleva todo lo que ya no apunta nadie.';

  @override
  String get databaseCleanupAction => 'Limpiar';

  @override
  String databaseCleanupFound(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ficheros sueltos, $size',
      one: '1 fichero suelto, $size',
    );
    return '$_temp0';
  }

  @override
  String get databaseCleanupAvatars => 'Avatares sin dueño';

  @override
  String get databaseCleanupDownloads => 'Descargas que ya no están en la base';

  @override
  String get databaseCleanupWeights => 'Pesos que no apunta ningún modelo';

  @override
  String get databaseCleanupKeeps =>
      'No se tocan el entorno de Python, los conjuntos de entrenamiento ni las cachés.';

  @override
  String get databaseCleanupFailed => 'La limpieza no ha podido terminar';

  @override
  String databaseCleanupDone(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ficheros borrados, $size liberados',
      one: '1 fichero borrado, $size liberados',
      zero: 'No había nada suelto',
    );
    return '$_temp0';
  }

  @override
  String get blockedImportsTitle => 'Que no se vuelva a importar';

  @override
  String get blockedImportsNote =>
      'Lo que pediste que no se te vuelva a ofrecer. Se salta sin llegar a descargarse.';

  @override
  String get blockedImportsNone => 'No hay nada bloqueado.';

  @override
  String get blockedImportsUnblock => 'Volver a importar esto';

  @override
  String get blockedImportsOpen => 'Abrir la página de la que salió';

  @override
  String get blockedImportsClear => 'Olvidarlos todos';

  @override
  String get blockImportAgain => 'No volver a importar esto';

  @override
  String get blockImportAgainDescription =>
      'La fuente sigue ofreciendo lo que tienes guardado allí. Marcado, esto se salta sin llegar a descargarse. Se deshace en Ajustes, en Base de datos.';

  @override
  String importSkippedBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltados: pediste no volver a verlos.',
      one: '1 saltado: pediste no volver a verlo.',
    );
    return '$_temp0';
  }

  @override
  String creatorNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esconde $count contenidos.',
      one: 'Esconde 1 contenido.',
      zero: 'Ahora mismo este creador no tiene contenido.',
    );
    return '$_temp0';
  }

  @override
  String get creatorNsfwOnTooltip =>
      'Marcado como NSFW · pulsa para desmarcarlo';

  @override
  String get creatorNsfwOffTooltip => 'Marcar como NSFW';

  @override
  String get searchChipDescription => 'Descripción';

  @override
  String get showsTagBranchOnFilter =>
      'Enseñar la rama entera al filtrar etiquetas';

  @override
  String get showsTagBranchOnFilterDescription =>
      'Al filtrar la lista de etiquetas, cada coincidencia llega con lo que cuelga de ella, para ver la rama y no sólo el nombre.';

  @override
  String get peopleTitle => 'Personas';

  @override
  String get navPersonaManager => 'Personas';

  @override
  String get tagIsPerson => 'Esta etiqueta es una persona';

  @override
  String get tagIsPersonDescription =>
      'Las personas y los personajes se gestionan en su propia pantalla. Sigue siendo una etiqueta: al asignar y al buscar se comporta igual.';

  @override
  String get openPeopleTooltip => 'Ir a las personas';

  @override
  String get openTagsTooltip => 'Ir a las etiquetas';

  @override
  String get noPeopleYet => 'Todavía no hay personas';

  @override
  String get noPeopleYetHint =>
      'Marca una etiqueta como persona desde su ficha, o crea una desde aquí.';

  @override
  String get markLinkNsfwTooltip => 'Marcar la dirección como no apta';

  @override
  String get unmarkLinkNsfwTooltip => 'La dirección está marcada como no apta';

  @override
  String get openSourceUrlTooltip => 'Abrir la dirección en el navegador';

  @override
  String get editSourceUrlTooltip => 'Editar la dirección';

  @override
  String get doneEditingSourceUrlTooltip => 'Terminar de editar';

  @override
  String get removeSourceUrlTooltip => 'Quitar la dirección';

  @override
  String get filtersType => 'Tipo de contenido';

  @override
  String get filterImages => 'Imágenes';

  @override
  String get filterGifs => 'GIF';

  @override
  String get filterVideos => 'Vídeos';

  @override
  String get selectAllTooltip => 'Seleccionar todo lo que se ve';

  @override
  String get selectNoneTooltip => 'Quitar la selección';

  @override
  String get sortNewestFirst => 'Lo último que llegó';

  @override
  String get sortOldestFirst => 'Lo primero que llegó';

  @override
  String get sortFileName => 'Por nombre de fichero';

  @override
  String get sortDescription => 'Por descripción';

  @override
  String get sortKind => 'Por tipo';

  @override
  String get sortRandom => 'Al azar';

  @override
  String get filtersSource => 'Mostrar contenido de';

  @override
  String get sourceLocal => 'Este equipo';

  @override
  String get autoTagRemoteSource => 'Auto-etiquetar fuente remota';

  @override
  String get autoTagRemoteSourceDescription =>
      'Fern crea una etiqueta por plataforma (Reddit, y las que vengan) y se la pone a lo que importa de ella. Apagado, la fuente se sigue guardando y se filtra por ella desde el botón de filtros.';

  @override
  String get startupFailedTitle => 'Fern no ha podido arrancar';

  @override
  String get startupFailedDatabase =>
      'No se ha podido poner la base de datos al día con lo que necesita esta versión.';

  @override
  String get startupFailedHint =>
      'No se ha perdido nada: tu contenido sigue donde estaba. Cierra Fern y vuelve a abrirlo, y si sigue pasando, el detalle de abajo dice qué ha fallado.';

  @override
  String get settingsRecognition => 'Reconocimiento';

  @override
  String get recognitionFolderTitle => 'Datos de reconocimiento';

  @override
  String get recognitionFolderDescription =>
      'Donde Fern guarda todo lo que necesita para reconocer tu contenido: el entorno con el que entrena, los modelos ya entrenados y los conjuntos de datos que prepara para entrenarlos. Puede ocupar varios gigas, así que quizá lo prefieras en otro disco.';

  @override
  String get recognitionFolder => 'Carpeta de reconocimiento';

  @override
  String recognitionFolderMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos movidos a la carpeta nueva',
      one: '1 archivo movido a la carpeta nueva',
      zero: 'La carpeta ya estaba ahí',
    );
    return '$_temp0';
  }

  @override
  String get recognitionFolderMoveFailed =>
      'No se han podido mover los datos de reconocimiento';

  @override
  String get jobsTooltip => 'Tareas';

  @override
  String get jobsTitle => 'Tareas';

  @override
  String get jobRunning => 'En marcha…';

  @override
  String get jobCancelled => 'Parada';

  @override
  String get jobDismissTooltip => 'Quitar de la lista';

  @override
  String get jobCancelTooltip => 'Cancelar esta tarea';

  @override
  String jobProgress(int done, int total) {
    return '$done de $total';
  }

  @override
  String get jobQueued => 'Esperando';

  @override
  String get jobFailed => 'Ha fallado';

  @override
  String get jobTraining => 'Entrenando modelo';

  @override
  String get jobRecognition => 'Reconociendo contenido';

  @override
  String get jobDuplicateScan => 'Buscando contenido repetido';

  @override
  String get jobHashing => 'Leyendo contenido';

  @override
  String get jobLinkReview => 'Enlaces por revisar';

  @override
  String get jobLinkImport => 'Trayendo enlaces';

  @override
  String get jobImport => 'Importando';

  @override
  String get settingsNotifications => 'Avisos';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get notificationsDescription =>
      'Entrenar un modelo, reconocer un lote o buscar contenido repetido puede tardar un buen rato. Fern te avisa cuando termina para que no tengas que estar mirando.';

  @override
  String get notificationsEnabled => 'Avisarme';

  @override
  String get notificationsEnabledDescription =>
      'Apagado no se cuenta nada ni suena nada. Lo que ya hubiera pendiente sigue anotado y vuelve a verse al encenderlo.';

  @override
  String get notificationsMuted => 'Silencio';

  @override
  String get notificationsMutedDescription =>
      'Los contadores se quedan, los sonidos no.';

  @override
  String get notificationsSoundTitle => 'Sonido';

  @override
  String get notificationsVolume => 'Volumen';

  @override
  String get notificationsMaxSeconds => 'Sonar como mucho';

  @override
  String notificationsSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get notificationsMaxSecondsDescription =>
      'Un aviso es un toque corto. Si el audio que eliges dura más, Fern lo corta aquí en lugar de reproducirlo entero. Tu fichero no se toca.';

  @override
  String get notificationsEventsTitle => 'De qué avisar';

  @override
  String get notificationsEventsDescription =>
      'De cada uno, si pone contador en el menú lateral y si suena.';

  @override
  String get notificationsBadge => 'Contador';

  @override
  String get notificationsSound => 'Sonido';

  @override
  String get notificationsDefaultSound => 'Sonido de Fern';

  @override
  String get notificationsPreview => 'Escuchar';

  @override
  String get notificationsChooseSound => 'Elegir un audio';

  @override
  String get notificationsResetSound => 'Volver al sonido de Fern';

  @override
  String get notifyDuplicates => 'Contenido repetido encontrado';

  @override
  String get notifyTraining => 'Modelo terminado de entrenar';

  @override
  String get notifyRecognition => 'Reconocimiento en lote terminado';

  @override
  String get notifyImport => 'Importación terminada';

  @override
  String get sidecarTitle => 'Motor de reconocimiento';

  @override
  String get sidecarDescription =>
      'Para entrenar y reconocer, Fern instala su propio entorno de Python dentro de la carpeta de reconocimiento. No toca tu sistema y no necesitas tener Python instalado de antes: se trae el suyo. Ocupa unos 1,2 GB en el disco y sólo se descarga cuando tú lo pides.';

  @override
  String get sidecarUnsupportedPlatform =>
      'El reconocimiento todavía no está disponible en este sistema.';

  @override
  String get sidecarNotInstalled => 'Sin instalar';

  @override
  String get sidecarDownloadingUv => 'Descargando el instalador';

  @override
  String get sidecarInstallingPython => 'Instalando Python';

  @override
  String get sidecarCreatingVenv => 'Preparando el entorno';

  @override
  String get sidecarDetectingHardware => 'Mirando tu equipo';

  @override
  String get sidecarInstallingTorch => 'Descargando el motor';

  @override
  String get sidecarInstallingUltralytics => 'Instalando YOLO';

  @override
  String get sidecarCleaning => 'Limpiando';

  @override
  String get sidecarVerifying => 'Comprobando que todo funciona';

  @override
  String get sidecarReady => 'Listo para entrenar y reconocer';

  @override
  String get sidecarError => 'Algo ha salido mal';

  @override
  String sidecarDownloaded(String received, String total) {
    return '$received MB de $total MB';
  }

  @override
  String get sidecarInstall => 'Instalar';

  @override
  String get sidecarReinstall => 'Reinstalar';

  @override
  String get sidecarEnableGpu => 'Usar la tarjeta gráfica';

  @override
  String get sidecarUninstall => 'Desinstalar';

  @override
  String get sidecarShowLog => 'Ver detalles';

  @override
  String get sidecarHideLog => 'Ocultar detalles';

  @override
  String get sidecarFailureInUse =>
      'Los archivos del motor están en uso ahora mismo';

  @override
  String get sidecarFailureInUseHint =>
      'Algo los tiene abiertos y no se pueden reemplazar. Cierra Fern del todo, vuelve a abrirlo y pulsa Instalar. Si sigue pasando, reinicia el equipo: eso siempre los suelta.';

  @override
  String get sidecarFailureSpace => 'No queda sitio en el disco';

  @override
  String get sidecarFailureSpaceHint =>
      'El motor necesita unos 1,5 GB libres, contando lo que ocupa mientras se instala. Libera espacio, o lleva la carpeta de reconocimiento a otro disco desde el campo de arriba.';

  @override
  String get sidecarFailureNetwork => 'No se ha podido terminar la descarga';

  @override
  String get sidecarFailureNetworkHint =>
      'Revisa tu conexión a internet y vuelve a pulsar Instalar. Lo que ya estaba descargado se conserva, así que sigue por donde iba.';

  @override
  String get sidecarFailureBlocked =>
      'El sistema no ha dejado a Fern ejecutar el instalador';

  @override
  String get sidecarFailureBlockedHint =>
      'Suele ser el antivirus, que frena los programas recién descargados. Permite Fern en tu antivirus, o elige una carpeta de reconocimiento dentro de tu carpeta de usuario, y vuelve a intentarlo.';

  @override
  String get sidecarFailureMissing => 'Falta algo que el motor necesita';

  @override
  String get sidecarFailureMissingHint =>
      'La instalación se ha quedado a medias. Pulsa Desinstalar para limpiarla y luego Instalar otra vez.';

  @override
  String get sidecarFailureUnknown => 'No se ha podido instalar el motor';

  @override
  String get sidecarFailureUnknownHint =>
      'Pulsa Instalar para reintentarlo. Si sigue fallando, abre los detalles de abajo: ahí se ve exactamente en qué paso ha fallado.';

  @override
  String get sidecarInstallCpu => 'Instalar para el procesador';

  @override
  String get sidecarInstallGpu => 'Instalar para la tarjeta gráfica';

  @override
  String get sidecarEnableCpu => 'Volver al procesador';

  @override
  String sidecarPercent(int percent) {
    return '$percent %';
  }

  @override
  String get sidecarBusyDownloading => 'Descargando paquetes...';

  @override
  String get sidecarBusyUnpacking => 'Descomprimiendo lo que va llegando...';

  @override
  String get sidecarBusyPatience => 'Este paso tarda unos minutos.';

  @override
  String get sidecarBusySettling => 'Colocando todo en su sitio...';

  @override
  String get sidecarBusyKeepUsing =>
      'Puedes seguir usando Fern mientras tanto.';

  @override
  String get gpuDialogTitle => '¿Instalar la versión de tarjeta gráfica?';

  @override
  String get gpuDialogBenefit =>
      'Entrenar va mucho más rápido: lo que en el procesador son horas, en la tarjeta gráfica pueden ser minutos.';

  @override
  String get gpuDialogTime =>
      'La descarga son unos 2,5 GB, así que en una conexión normal puede tardar un buen rato.';

  @override
  String get gpuDialogSize =>
      'Ocupa unos 5 GB en el disco, en vez de los 1,2 GB de la versión de procesador.';

  @override
  String get gpuDialogReversible =>
      'Puedes volver a la versión de procesador cuando quieras, sin reinstalarlo todo.';

  @override
  String get gpuDialogConfirm => 'Instalarla';

  @override
  String get navRecognition => 'Reconocimiento';

  @override
  String get navFernies => 'Fernies';

  @override
  String get navRepeatedMedia => 'Contenido repetido';

  @override
  String get navModels => 'Modelos';

  @override
  String get menuNewFernie => 'Nuevo fernie';

  @override
  String get newFernieTitle => 'Nuevo fernie';

  @override
  String get fernieNameLabel => 'Nombre del fernie';

  @override
  String get ferniesTitle => 'Fernies';

  @override
  String get addFernie => 'Añadir fernie';

  @override
  String get noFerniesYet => 'Aún no hay fernies';

  @override
  String get fernieNoRegions => 'Este fernie aún no tiene regiones';

  @override
  String get fernieNoneHere => 'Aún no hay fernies marcados aquí';

  @override
  String get fernieLinkLabel => 'Propone';

  @override
  String get fernieLinkNone => 'Nada';

  @override
  String get fernieLinkTag => 'Una etiqueta';

  @override
  String get fernieLinkCreator => 'Un creador';

  @override
  String get fernieLinkNoneHint => 'Solo entrena: por sí solo no etiqueta nada';

  @override
  String get fernieLinkMissing => 'Lo que tenía enlazado ya no existe';

  @override
  String get fernieFewRegions => 'Pocas regiones para entrenar de forma fiable';

  @override
  String get fernieLowVariety =>
      'Poca variedad: el modelo aprenderá el fondo, no el objeto';

  @override
  String get fernieRegionPending =>
      'Contenido pendiente de revisar: esta región no se usará para entrenar hasta que se guarde';

  @override
  String get fernieRegionTiny =>
      'Región muy pequeña: puede no aportar al entrenamiento';

  @override
  String get actionDeleteFernie => 'Eliminar fernie';

  @override
  String get actionRemoveLink => 'Quitar enlace';

  @override
  String get actionDeleteRegions => 'Eliminar regiones';

  @override
  String get fernieToolSelect => 'Marcar regiones';

  @override
  String get fernieToolEdit => 'Editar regiones';

  @override
  String get jobTagRegions => 'Marcando el contenido de una etiqueta';

  @override
  String get jobFileCleanup => 'Borrando ficheros';

  @override
  String get fernieImportTagTitle => 'Marcar una etiqueta entera';

  @override
  String get fernieImportTagNote =>
      'Todo lo que lleve esa etiqueta recibe una región con el fotograma entero, para este fernie. Es lo que harías a mano, uno a uno.';

  @override
  String get fernieImportTagAction => 'Marcarlos';

  @override
  String get fernieImportTagTooltip =>
      'Marcar una etiqueta entera como regiones';

  @override
  String get fernieImportTagFrames => 'Fotogramas por vídeo';

  @override
  String get fernieImportTagFramesNote =>
      'El entrenamiento saca una imagen por región, así que un vídeo entero serían miles de recortes casi idénticos.';

  @override
  String fernieImportTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos',
      one: '1 contenido',
      zero: 'Nada lleva esa etiqueta',
    );
    return '$_temp0';
  }

  @override
  String get fernieImportTagStarted =>
      'El marcado ha empezado; puedes seguirlo en la lista de tareas';

  @override
  String get fernieToolWholeFrame => 'Marcar el fotograma entero';

  @override
  String fernieAcceptAllProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aceptar las $count regiones detectadas',
      one: 'Aceptar la región detectada',
    );
    return '$_temp0';
  }

  @override
  String get fernieRegionConfirm => 'Guardar los cambios de esta región';

  @override
  String get fernieRegionCancel => 'Descartar los cambios de esta región';

  @override
  String get fernieRegionDelete => 'Eliminar esta región';

  @override
  String get fernieRegionDeleteTitle => '¿Eliminar esta región?';

  @override
  String get fernieRegionDeleteMessage =>
      'La región sale de su fernie. Si era la única de ese fernie en este contenido, el fernie deja de estar marcado aquí.';

  @override
  String get fernieRegionDiscardTitle => '¿Descartar los cambios de la región?';

  @override
  String get fernieRegionDiscardMessage =>
      'Lo que has cambiado en la región seleccionada no se guardará.';

  @override
  String get fernieTimelinePlay =>
      'Reproducir para comprobar las regiones marcadas';

  @override
  String get fernieTimelinePause => 'Parar';

  @override
  String get fernieFramePrevious => 'Fotograma anterior';

  @override
  String get fernieFrameNext => 'Fotograma siguiente';

  @override
  String get fernieOnionSkin =>
      'Papel cebolla: ver el fotograma marcado anterior';

  @override
  String get fernieDragRegions =>
      'Arrastrar la región por todos los fotogramas de en medio';

  @override
  String get fernieModeTooltip => 'Marcar fernies en este contenido';

  @override
  String get fernieModeAccept => 'Guardar las regiones';

  @override
  String get fernieModeCancel => 'Descartar las regiones';

  @override
  String get fernieModeHint =>
      'Arrastra sobre el contenido para marcar una región. Mantén espacio o el botón central para desplazar.';

  @override
  String get fernieDiscardTitle => '¿Descartar lo marcado?';

  @override
  String get fernieDiscardMessage =>
      'Se perderán las regiones marcadas en esta sesión.';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get assignRegionTitle => 'Asignar la región';

  @override
  String get searchFernieHint => 'Buscar fernie...';

  @override
  String get createFernie => 'Crear fernie';

  @override
  String fernieRegionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regiones',
      one: '1 región',
      zero: 'Sin regiones',
    );
    return '$_temp0';
  }

  @override
  String fernieMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count contenidos',
      one: 'en 1 contenido',
      zero: 'en ningún contenido',
    );
    return '$_temp0';
  }

  @override
  String fernieRecommendedRegions(int count) {
    return 'Se recomiendan al menos $count regiones';
  }

  @override
  String ferniePendingRegions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count regiones están sobre contenido sin confirmar, así que no entrenan',
      one: '1 región está sobre contenido sin confirmar, así que no entrena',
    );
    return '$_temp0';
  }

  @override
  String get viewerRecognize => 'Reconocer con los modelos';

  @override
  String get viewerRecognizing => 'Reconociendo…';

  @override
  String suggestionConfidence(int percent) {
    return '$percent%';
  }

  @override
  String suggestionInstances(int count) {
    return '×$count';
  }

  @override
  String get suggestionFromModel =>
      'Lo propone un modelo, todavía sin confirmar';

  @override
  String get suggestionCreatorTitle => 'Creador propuesto';

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionReject => 'Rechazar';

  @override
  String get suggestionAcceptAll => 'Aceptar todas';

  @override
  String get suggestionRejectAll => 'Rechazar todas';

  @override
  String get recognizeNoModelsInTree =>
      'Todavía no hay ningún modelo en el árbol. Añade uno desde la pantalla del árbol de modelos.';

  @override
  String get recognizeNoTrainedModels =>
      'Ningún modelo del árbol está entrenado. Entrena uno, o importa sus pesos desde la pantalla del modelo.';

  @override
  String get recognizeUnavailable =>
      'No se ha podido leer el árbol de modelos.';

  @override
  String get recognizeFoundNothing => 'Los modelos no han encontrado nada aquí';

  @override
  String get recognizeNothingToDo => 'Aquí no queda nada por reconocer';

  @override
  String get recognizeSelectedTooltip => 'Reconocer la selección';

  @override
  String get recognizeTagTooltip => 'Reconocer todo lo de esta etiqueta';

  @override
  String get recognizeCreatorTooltip => 'Reconocer todo lo de este creador';

  @override
  String get recognizeLibrary => 'Reconocer la biblioteca';

  @override
  String get recognizeLibraryTitle => 'Reconocer toda la biblioteca';

  @override
  String get recognizeLibraryQuestion =>
      'Reconocer cuesta una predicción por imagen, y varias por vídeo. Elige cuánto hay que mirar.';

  @override
  String get recognizeLibraryOnlyNew => 'Sólo lo que no se ha mirado nunca';

  @override
  String get recognizeLibraryAll => 'Todo, otra vez';

  @override
  String get recognizeLibraryAllHint =>
      'Útil después de entrenar un modelo mejor.';

  @override
  String get recognizeJobLibrary => 'Biblioteca entera';

  @override
  String get recognizeJobSelection => 'Selección';

  @override
  String recognizeQueuedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos en cola para reconocer',
      one: '1 contenido en cola para reconocer',
      zero: 'No se ha encolado nada',
    );
    return '$_temp0';
  }

  @override
  String recognizeCountable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos',
      one: '1 contenido',
    );
    return '$_temp0';
  }

  @override
  String get recognitionLogTitle => 'Qué hicieron los modelos';

  @override
  String get recognitionLogNearMiss => 'visto, bajo el listón';

  @override
  String get recognitionLogNothing => 'nada';

  @override
  String get recognitionLogVerdictProposed => 'lo propone';

  @override
  String recognitionLogVerdictBelow(int percent) {
    return 'lo vio, pero por debajo del $percent %';
  }

  @override
  String get recognitionLogVerdictNothing => 'no vio nada';

  @override
  String get recognitionLogVerdictNotReached =>
      'no corrió: su rama no se abrió';

  @override
  String get recognitionLogVerdictUntrained => 'no corrió: no tiene pesos';

  @override
  String get jobReviewTooltip => 'Decidir sobre estos enlaces';

  @override
  String get notifyLinkReview => 'Enlaces esperándote';

  @override
  String get jobDetailTooltip => 'Ver qué hicieron los modelos';

  @override
  String get jobsClearFinished => 'Dar por vistas las terminadas';

  @override
  String recognitionLogSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenidos',
      one: 'Un contenido',
    );
    return '$_temp0';
  }

  @override
  String recognitionLogProposed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerencias',
      one: '1 sugerencia',
    );
    return '$_temp0';
  }

  @override
  String get jobDone => 'Terminada';

  @override
  String recognizeFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerencias. Pulsa para ver cómo',
      one: '1 sugerencia. Pulsa para ver cómo',
    );
    return '$_temp0';
  }

  @override
  String get recognitionPanelTitle => 'Al reconocer';

  @override
  String get recognitionThresholdLabel => 'Confianza mínima para proponer';

  @override
  String get recognitionThresholdDescription =>
      'Por debajo de esto, lo que vea no se propone.';

  @override
  String get recognitionThresholdEverything =>
      'Se propone todo lo que vea, por poco seguro que esté.';

  @override
  String get recognitionThresholdAll => 'Todo';

  @override
  String get recognitionThresholdLower => 'Bajar el listón';

  @override
  String get recognitionThresholdRaise => 'Subir el listón';

  @override
  String get recognitionThresholdApplies =>
      'Vale para el próximo reconocimiento. Lo ya propuesto no cambia.';

  @override
  String get recognizeReturnTitle => 'Saldrán de la biblioteca por un rato';

  @override
  String get recognizeReturnHint =>
      'Sólo los que reciban alguna sugerencia. Se puede apagar en Ajustes, en Reconocimiento.';

  @override
  String get recognizeReturnConfirm => 'Reconocer de todas formas';

  @override
  String get returnRecognizedLabel =>
      'Devolver a importación el contenido reconocido';

  @override
  String get maxDetectionsLabel => 'Cuántas veces se guarda lo mismo';

  @override
  String get maxDetectionsDescription =>
      'Un modelo puede ver cuatro coches en una foto. Cada uno es una región distinta que se puede marcar, así que se guardan todos — hasta este número. Un aparcamiento podría dar cincuenta.';

  @override
  String get returnRecognizedDescription =>
      'Lo que reciba una sugerencia deja de ser definitivo hasta que lo valides. Apagado, las sugerencias se siguen viendo en el panel del visor y no se mueve nada de sitio.';

  @override
  String recognizeReturnWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count contenidos volverán a la pantalla de importación hasta que valides sus etiquetas.',
      one:
          'Un contenido volverá a la pantalla de importación hasta que valides sus etiquetas.',
    );
    return '$_temp0';
  }

  @override
  String get suggestionsPendingBadge => 'Tiene sugerencias sin mirar';

  @override
  String get suggestionFilterAll => 'Todo';

  @override
  String get suggestionFilterWith => 'Con sugerencias';

  @override
  String get suggestionFilterNever => 'Sin mirar nunca';

  @override
  String acceptAboveTooltip(int percent) {
    return 'Acepta lo que los modelos ven con más de un $percent % de seguridad, en la selección. No da nada por definitivo.';
  }

  @override
  String acceptAboveDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerencias aceptadas',
      one: '1 sugerencia aceptada',
      zero: 'Nada llegaba con seguridad suficiente',
    );
    return '$_temp0';
  }

  @override
  String get actionClearSelection => 'Dejar de seleccionar';

  @override
  String acceptAboveLabel(int percent) {
    return 'Aceptar más del $percent %';
  }

  @override
  String get remoteCreatorsMode => 'Creadores';

  @override
  String get remoteContentMode => 'Contenido';

  @override
  String remoteCreatorNewPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones nuevas',
      one: '1 publicación nueva',
      zero: 'nada nuevo',
    );
    return '$_temp0';
  }

  @override
  String remoteCreatorImporting(String name) {
    return 'Trayendo lo de $name…';
  }

  @override
  String remoteCreatorLastImport(String date) {
    return 'última vez, el $date';
  }

  @override
  String remoteCreatorNewsSince(String date) {
    return 'novedades desde el $date';
  }

  @override
  String get remoteCreatorNeverImported => 'nunca importado';

  @override
  String get remoteCreatorKnown => 'ya lo tienes';

  @override
  String get remoteCreatorsEmpty => 'No hay creadores en esta fuente';

  @override
  String remoteCreatorsImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Traer $count creadores',
      one: 'Traer 1 creador',
    );
    return '$_temp0';
  }

  @override
  String get importReviewLabel => 'Revisar';

  @override
  String get importSortLabel => 'Ordenar';

  @override
  String get importCreatorsLabel => 'Mostrar';

  @override
  String get importShowLabel => 'Ver';

  @override
  String get importFetchLabel => 'Traer';

  @override
  String get recognizeJobImported => 'Recién importado';

  @override
  String get recognizeOnImportLabel => 'Reconocer lo que acaba de importarse';

  @override
  String get recognizeOnImportDescription =>
      'El contenido nuevo pasa por los modelos solo, en cuanto la importación se calma. No cuesta nada si no hay ningún modelo entrenado.';

  @override
  String get suggestionMarkRegion => 'Guardar como región de este fernie';

  @override
  String get suggestionRegionSaved =>
      'Región guardada. Cuenta para el próximo entrenamiento.';

  @override
  String get suggestionRegionFailed => 'No se ha podido guardar la región';

  @override
  String get duplicatesScanNow => 'Buscar ahora';

  @override
  String get duplicatesScanning => 'Buscando repetidos';

  @override
  String get duplicatesQueued =>
      'Buscando contenido repetido. La primera vez puede tardar un rato.';

  @override
  String get duplicatesNone => 'No hay contenido repetido';

  @override
  String get duplicatesNeverScanned => 'Todavía no se ha buscado';

  @override
  String duplicatesScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Búsqueda terminada: $count grupos nuevos',
      one: 'Búsqueda terminada: 1 grupo nuevo',
    );
    return '$_temp0';
  }

  @override
  String duplicatesScanNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Búsqueda terminada: nada nuevo. Quedan $count grupos por revisar.',
      one: 'Búsqueda terminada: nada nuevo. Queda 1 grupo por revisar.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesScanClean =>
      'Búsqueda terminada: no hay contenido repetido.';

  @override
  String get duplicatesScanStopped =>
      'Búsqueda parada. Las huellas ya calculadas se quedan hechas.';

  @override
  String get duplicatesScanFailed =>
      'La búsqueda no ha podido terminar. Vuelve a intentarlo.';

  @override
  String duplicatesGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String duplicatesDistance(int distance) {
    return 'distancia $distance';
  }

  @override
  String get duplicatesIdentical => 'idéntico';

  @override
  String duplicatesCopyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copias',
      one: '1 copia',
    );
    return '$_temp0';
  }

  @override
  String duplicatesGroupPosition(int position, int total) {
    return 'Grupo $position de $total';
  }

  @override
  String get duplicatesKeepThis => 'Conservar esta';

  @override
  String get duplicatesMergeMetadata =>
      'Fusionar metadatos en la copia conservada';

  @override
  String get duplicatesMergeMetadataHint =>
      'Etiquetas, creador, favorito y descripción de las copias descartadas.';

  @override
  String get duplicatesNotDuplicates => 'No son duplicados';

  @override
  String get duplicatesApplyAndNext => 'Aplicar y siguiente';

  @override
  String duplicatesTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etiquetas',
      one: '1 etiqueta',
      zero: 'Sin etiquetas',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesFavorite => 'Favorito';

  @override
  String get duplicatesNoCreator => 'Sin creador';

  @override
  String get duplicatesUnknownSize => 'Tamaño desconocido';

  @override
  String get duplicatesPickGroup => 'Elige un grupo para comparar sus copias';

  @override
  String get settingsDuplicates => 'Contenido repetido';

  @override
  String get settingsNsfw => 'Contenido NSFW';

  @override
  String get nsfwCoveredLabel => 'Contenido NSFW';

  @override
  String get nsfwViewsTitle => 'Cómo se comporta';

  @override
  String get nsfwViewsNote =>
      'Qué se ve con el filtro puesto y qué se ve sin él. Los dos se aplican a lo siguiente que se pinte, sin reiniciar nada.';

  @override
  String get nsfwUnlockedViewLabel => 'Sin filtro NSFW';

  @override
  String get nsfwUnlockedViewMixed => 'Todo junto';

  @override
  String get nsfwUnlockedViewOnly => 'Sólo lo marcado';

  @override
  String get nsfwUnlockedViewNote =>
      '«Sólo lo marcado» lo convierte en una biblioteca aparte: mientras el filtro esté quitado, el resto de tu contenido no aparece.';

  @override
  String get nsfwLockedViewLabel => 'Con filtro NSFW';

  @override
  String get nsfwLockedViewHidden => 'No aparece';

  @override
  String get nsfwLockedViewBlurred => 'Aparece tapado';

  @override
  String get nsfwChildTagsLabel =>
      'Marcar una etiqueta marca también las que cuelgan de ella';

  @override
  String get nsfwChildTagsDescription =>
      'Una etiqueta que cuelga de una marcada esconde también su contenido, sin tener que marcarla aparte. Apagado, cada etiqueta responde sólo por lo suyo. No se reescribe nada en ningún caso: enciéndelo y apágalo las veces que quieras.';

  @override
  String get nsfwLockedViewNote =>
      'Tapado, el contenido marcado sigue ocupando su sitio en la rejilla, borroso y con un candado; al tocarlo se pide la contraseña. Es más cómodo, pero deja ver que ahí hay algo: cuánto hay y de qué forma es.';

  @override
  String get nsfwSectionTitle => 'Filtro de contenido NSFW';

  @override
  String get nsfwSectionNote =>
      'Lo que marques como NSFW se esconde: con el filtro puesto no aparece en ninguna parte, ni en la papelera ni en las búsquedas.';

  @override
  String get nsfwSectionWarning =>
      'Esto esconde, no cifra: los ficheros siguen en su carpeta con su nombre, y cualquiera que abra el explorador los ve.';

  @override
  String get nsfwNotConfiguredNote =>
      'Todavía no hay contraseña. Sin ella no se puede marcar nada, y lo que hay ahora se ve como siempre.';

  @override
  String get nsfwConfigureAction => 'Poner una contraseña';

  @override
  String get nsfwStateLocked =>
      'Con filtro NSFW: el contenido marcado no se ve';

  @override
  String get nsfwStateUnlocked => 'Sin filtro NSFW: se ve todo';

  @override
  String get nsfwOpenAction => 'Quitar el filtro NSFW';

  @override
  String get nsfwCloseAction => 'Volver a poner el filtro';

  @override
  String get nsfwRememberLabel => 'Seguir sin filtro al volver a abrir Fern';

  @override
  String get nsfwRememberDescription =>
      'Apagado, cerrar Fern vuelve a poner el filtro. Encendido se queda como lo dejaste, y lo primero que verás al abrirla es lo que hayas marcado.';

  @override
  String get nsfwChangePasswordAction => 'Cambiar la contraseña';

  @override
  String get nsfwChangeDone =>
      'Contraseña cambiada. El código de recuperación sigue siendo el mismo.';

  @override
  String get nsfwDisableNote =>
      'Desactivar el filtro desmarca todo lo que hubieras marcado —etiquetas, contenido, fernies y modelos— y deja de esconder nada. Nada se borra: estaba marcado, no cifrado.';

  @override
  String get nsfwDisableAction => 'Desactivar el filtro';

  @override
  String nsfwDisableDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtro desactivado y $count etiquetas desmarcadas.',
      one: 'Filtro desactivado y 1 etiqueta desmarcada.',
      zero: 'Filtro desactivado. No había ninguna etiqueta marcada.',
    );
    return '$_temp0';
  }

  @override
  String get nsfwSetupTitle => 'Poner la contraseña';

  @override
  String get nsfwPasswordLabel => 'Contraseña';

  @override
  String get nsfwPasswordRepeatLabel => 'Repítela';

  @override
  String get nsfwHintLabel => 'Frase clave (opcional)';

  @override
  String get nsfwHintNote =>
      'Se te enseña después de tres intentos fallidos, así que se puede leer sin saber la contraseña: que sea una pista para ti y no la contraseña escrita de otra forma.';

  @override
  String get nsfwSetupAction => 'Guardar';

  @override
  String get nsfwPasswordEmpty => 'Escribe una contraseña.';

  @override
  String get nsfwPasswordMismatch => 'Las dos contraseñas no son la misma.';

  @override
  String get nsfwCodeTitle => 'Tu código de recuperación';

  @override
  String get nsfwCodeIntro =>
      'Es lo único que quita el filtro si pierdes la contraseña, y sólo se enseña ahora: Fern no lo guarda, guarda una huella suya. Cópialo o guárdalo en un fichero antes de cerrar.';

  @override
  String get nsfwCodeCopy => 'Copiar';

  @override
  String get nsfwCodeCopied => 'Copiado al portapapeles.';

  @override
  String get nsfwCodeSave => 'Guardar en un fichero';

  @override
  String nsfwCodeSaved(String path) {
    return 'Guardado en $path';
  }

  @override
  String get nsfwCodeSaveFailed =>
      'No se ha podido guardar el fichero. Cópialo antes de cerrar.';

  @override
  String get nsfwCodeDone => 'Ya lo tengo guardado';

  @override
  String get nsfwCodeFileHeader =>
      'Código de recuperación del filtro de contenido NSFW de Fern. Guárdalo donde puedas encontrarlo: es lo único que quita el filtro si pierdes la contraseña.';

  @override
  String get nsfwUnlockTitle => 'Quitar el filtro NSFW';

  @override
  String get nsfwUnlockAction => 'Quitarlo';

  @override
  String get nsfwUnlockWrong => 'Esa no es la contraseña.';

  @override
  String nsfwUnlockHint(String hint) {
    return 'Tu frase clave: $hint';
  }

  @override
  String get nsfwUnlockNoHint =>
      'No pusiste ninguna frase clave. Si no te acuerdas de la contraseña, te queda el código de recuperación.';

  @override
  String get nsfwUnlockRecover => 'Usar el código de recuperación';

  @override
  String get nsfwRecoverTitle => 'Recuperar el acceso';

  @override
  String get nsfwRecoverIntro =>
      'Escribe el código que guardaste y elige una contraseña nueva. El código se gasta al usarlo: te daremos otro, y ese será el que valga a partir de ahora.';

  @override
  String get nsfwRecoverCodeLabel => 'Código de recuperación';

  @override
  String get nsfwRecoverAction => 'Recuperar';

  @override
  String get nsfwRecoverWrong =>
      'Ese código no es. Míralo otra vez: los guiones y las mayúsculas dan igual.';

  @override
  String get nsfwChangeTitle => 'Cambiar la contraseña';

  @override
  String get nsfwChangeCurrentLabel => 'Contraseña de ahora';

  @override
  String get nsfwChangeNewLabel => 'Contraseña nueva';

  @override
  String get nsfwChangeAction => 'Cambiarla';

  @override
  String get nsfwChangeWrong => 'La contraseña de ahora no es esa.';

  @override
  String get nsfwDisableTitle => 'Desactivar el filtro';

  @override
  String get nsfwDisableWarning =>
      'Se borra la contraseña, se desmarcan todas las etiquetas y su contenido vuelve a verse. No se borra nada de tu biblioteca. Para volver a tener filtro habrá que ponerlo de cero y marcar las etiquetas otra vez.';

  @override
  String get nsfwDisableSecretLabel => 'Contraseña o código de recuperación';

  @override
  String get nsfwDisableWrong => 'Ni la contraseña ni el código son.';

  @override
  String get nsfwDisableFailed =>
      'No se han podido quitar las marcas, así que la contraseña se ha quedado como estaba. Inténtalo otra vez.';

  @override
  String tagNsfwAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esconde $count contenidos.',
      one: 'Esconde 1 contenido.',
      zero: 'Ahora mismo no hay contenido con esta etiqueta.',
    );
    return '$_temp0';
  }

  @override
  String get tagNsfwOnTooltip => 'Marcada como NSFW · pulsa para desmarcarla';

  @override
  String get tagNsfwOffTooltip => 'Marcar como NSFW';

  @override
  String get nsfwMarkOnTooltip => 'Marcado como NSFW · pulsa para desmarcarlo';

  @override
  String get mediaNsfwMark => 'Marcar como NSFW';

  @override
  String get mediaNsfwUnmark => 'Quitar la marca NSFW';

  @override
  String get duplicatesScanSectionTitle => 'Búsqueda automática';

  @override
  String get duplicatesScanSectionNote =>
      'El contenido repetido no molesta el día que entra; molesta meses después, cuando ya hay cuarenta copias y nadie se acuerda de mirarlo.';

  @override
  String get duplicatesAutoScanLabel => 'Que Fern busque repetidos sola';

  @override
  String get duplicatesAutoScanDescription =>
      'Al abrir Fern, si ha pasado el tiempo que elijas aquí abajo, repasa la biblioteca entera sin que se lo pidas: corre por detrás con la prioridad más baja, así que no estorba a lo que estés haciendo, y sólo te avisa si encuentra algo. Apagado, los repetidos sólo se buscan cuando pulses «Buscar ahora» en Contenido repetido.';

  @override
  String get duplicatesScanPeriodLabel => 'Cada cuánto';

  @override
  String get duplicatesMovingLabel => 'Mirar también vídeos y GIF';

  @override
  String get duplicatesMovingDescription =>
      'De un vídeo se compara el fotograma del 10 % de su duración, no el primero: los vídeos empiezan en negro o con una carátula, y por ahí saldrían agrupados tres que no tienen nada que ver. Cuesta bastante más que una imagen, así que con una biblioteca llena de vídeos el primer escaneo se alarga. Lo que ya se haya calculado se sigue comparando aunque lo apagues.';

  @override
  String get duplicatesPeriodMonthly => 'Cada mes';

  @override
  String get duplicatesPeriodQuarterly => 'Cada tres meses';

  @override
  String get duplicatesPeriodBiannual => 'Cada seis meses';

  @override
  String get duplicatesPeriodYearly => 'Cada año';

  @override
  String duplicatesLastScan(String date) {
    return 'Último escaneo: $date';
  }

  @override
  String get duplicatesLastScanNever => 'Todavía no se ha escaneado nunca';

  @override
  String get duplicatesOpenViewer => 'Ver a pantalla completa';

  @override
  String get duplicatesThresholdSectionTitle => 'Listón de similitud';

  @override
  String get duplicatesThresholdSectionNote =>
      'Cuánto pueden diferenciarse dos contenidos y seguir contando como el mismo. Subirlo agrupa más y empieza a juntar cosas que sólo se parecen; bajarlo deja repetidos sin encontrar. Se aplica al escaneo siguiente, no a lo ya agrupado.';

  @override
  String get duplicatesThresholdLabel => 'Listón';

  @override
  String get duplicatesRehashSectionTitle => 'Empezar de cero';

  @override
  String get duplicatesRehashSectionNote =>
      'Tira todas las huellas y las vuelve a calcular en el escaneo siguiente. Es la salida para cuando la agrupación sale mal y no se sabe por qué. Los grupos que ya has contestado se quedan como están.';

  @override
  String get duplicatesRehashButton => 'Recalcular todas las huellas';

  @override
  String get duplicatesRehashRunning => 'Borrando las huellas';

  @override
  String duplicatesRehashDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Borradas $count huellas. Se volverán a calcular en el escaneo siguiente.',
      one: 'Borrada 1 huella. Se volverá a calcular en el escaneo siguiente.',
      zero: 'No había nada que borrar',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesRehashFailed => 'No se han podido borrar las huellas.';

  @override
  String get settingsHelp => 'Ayuda';

  @override
  String get tutorialSectionTitle => 'Vueltas guiadas';

  @override
  String get tutorialSectionNote =>
      'Diez recorridos que cubren la aplicación entera, uno por materia. Siguiéndolos todos no queda nada por explicar. Se puede dejar cualquiera en cualquier momento.';

  @override
  String get tutorialOfferTitle => '¿Te enseño la aplicación?';

  @override
  String get tutorialOfferBody =>
      'Un recorrido de diez pasos por lo que es cada cosa y dónde está. Hay nueve más, uno por materia, en Ajustes → Ayuda. Se deja cuando quieras.';

  @override
  String get tutorialOfferAccept => 'Empezar';

  @override
  String get tutorialOfferDecline => 'Ahora no';

  @override
  String tutorialProgress(int position, int total) {
    return '$position de $total';
  }

  @override
  String get tutorialSkip => 'Salir';

  @override
  String get tutorialBack => 'Atrás';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialDone => 'Listo';

  @override
  String get tutorialWelcomeTitle => 'Bienvenido a FeRN';

  @override
  String get tutorialWelcomeBody =>
      'FeRN guarda el contenido que coleccionas: lo trae, lo ordena con etiquetas y creadores, y puede aprender a reconocer lo que sale en él. Se avanza con Siguiente o con las flechas, y se sale con Escape.';

  @override
  String get tutorialSidebarTitle => 'Por aquí se navega';

  @override
  String get tutorialSidebarBody =>
      'Todas las pantallas están aquí: tu biblioteca, lo que traes de fuera, los favoritos, la papelera y los gestores de creadores, etiquetas, fernies y modelos. El botón de arriba lo pliega cuando hace falta sitio.';

  @override
  String get tutorialImportTitle => 'Por aquí entra el contenido';

  @override
  String get tutorialImportBody =>
      'Traes contenido de una fuente remota —Reddit, Pixiv, Danbooru, Gelbooru, Pinterest, Pawchive— o de una carpeta de tu disco. Lo que llega espera aquí hasta que lo aceptas, así que nada entra en tu biblioteca sin que lo veas.';

  @override
  String get tutorialContentTitle => 'Aquí aparece todo';

  @override
  String get tutorialContentBody =>
      'Tu biblioteca: todo lo que has aceptado. Un clic abre el visor, el botón derecho saca las acciones, y se pueden marcar varios a la vez para tratarlos juntos.';

  @override
  String get tutorialTagsTitle => 'Etiqueta arrastrando';

  @override
  String get tutorialTagsBody =>
      'Las etiquetas del menú son también sitios donde soltar: arrastra uno o varios contenidos encima de una y quedan etiquetados. Al pulsarla, la biblioteca se queda con lo que la lleva.';

  @override
  String get tutorialCreateTitle => 'Crear cosas';

  @override
  String get tutorialCreateBody =>
      'De aquí salen los creadores, las etiquetas, los fernies y los modelos. Un creador es quien hizo algo; una etiqueta es cualquier cosa por la que quieras agrupar; un fernie es una cara o un objeto que quieres que FeRN aprenda.';

  @override
  String get tutorialSearchTitle => 'Buscar';

  @override
  String get tutorialSearchBody =>
      'Escribe y FeRN te ofrece lo que encaja: una etiqueta, un creador, una descripción. Lo que elijas se queda como una pastilla, y las pastillas se acumulan: con dos puestas se enseña lo que cumple las dos.';

  @override
  String get tutorialSettingsTitle => 'Todo lo demás está aquí';

  @override
  String get tutorialSettingsBody =>
      'Idioma, tema, carpetas, fuentes remotas, reconocimiento y el bloqueo de contenido. En Ayuda están los otros nueve recorridos: uno por materia, y entre todos cubren la aplicación entera.';

  @override
  String get tourGeneralTitle => 'Vuelta general';

  @override
  String get tourGeneralDescription =>
      'Qué es FeRN, para qué es cada pantalla y dónde está cada cosa. Empieza por aquí.';

  @override
  String get tourImportingTitle => 'Traer y revisar contenido';

  @override
  String get tourImportingDescription =>
      'De dónde sale el contenido, cómo se revisa y qué hace falta para que llegue a la biblioteca.';

  @override
  String get tourImporting1Title => 'De dónde y cuánto';

  @override
  String get tourImporting1Body =>
      'Eliges la fuente —una remota o una carpeta de este equipo—, dices si quieres todo o sólo lo nuevo desde la última vez, y pulsas Traer. Una fuente remota trae lo que tengas marcado como favorito allí.';

  @override
  String get tourImporting2Title => 'Cada fuente pide sus claves';

  @override
  String get tourImporting2Body =>
      'Las fuentes remotas necesitan los datos de tu cuenta, y se ponen en Ajustes → Fuentes remotas. Cada una explica cómo conseguirlos: no son tu contraseña, sino claves que la plataforma da para esto.';

  @override
  String get tourImporting3Title => 'Nada de esto es tuyo todavía';

  @override
  String get tourImporting3Body =>
      'Esta rejilla es la bandeja de entrada: lo que se ha traído, esperando a que digas qué hacer con ello. Ya está en tu disco, pero no está en tu biblioteca y no sale en las búsquedas.';

  @override
  String get tourImporting4Title => 'Abre uno y decide';

  @override
  String get tourImporting4Body =>
      'Un clic lo abre en el visor. Ahí lo guardas, y pasa a ser definitivo, o lo descartas: descartar lo saca de la base de datos y te pregunta si borrar también el fichero.';

  @override
  String get tourImporting5Title => 'La ficha, sin salir del visor';

  @override
  String get tourImporting5Body =>
      'El panel lateral es donde se le pone creador, etiquetas, descripción y enlaces. Se edita mientras se mira, que es cuando se sabe qué es. Al guardar, además, se pasa al siguiente.';

  @override
  String get tourManagersTitle => 'Etiquetas, personas y creadores';

  @override
  String get tourManagersDescription =>
      'Todo lo que sirve para ordenar la biblioteca: el árbol de etiquetas, las hermanas, las personas, los creadores y el etiquetado automático.';

  @override
  String get tourManagers1Title => 'Los creadores';

  @override
  String get tourManagers1Body =>
      'Un creador es quien hizo algo: un artista, una cuenta, un estudio. Cada contenido tiene uno, y sólo uno. Al elegir uno aquí, la pantalla se llena con lo suyo.';

  @override
  String get tourManagers2Title => 'Su ficha';

  @override
  String get tourManagers2Body =>
      'Nombre, avatar y los enlaces a donde publica. Esos enlaces no son adorno: son lo que permite que FeRN le ponga el creador solo cuando llega algo desde una de esas direcciones.';

  @override
  String get tourManagers3Title => 'Los avatares';

  @override
  String get tourManagers3Body =>
      'Pulsa la imagen y eliges de dónde sale: un fichero del equipo, o tu propia biblioteca. De la biblioteca puedes recortar un cuadrado de cualquier imagen, que es lo que un avatar es de verdad.';

  @override
  String get tourManagers4Title => 'Las etiquetas van igual';

  @override
  String get tourManagers4Body =>
      'Con una diferencia: un contenido tiene un creador, pero tantas etiquetas como quieras. Una etiqueta es cualquier cosa por la que quieras agrupar: una serie, un color, un ambiente, un lugar.';

  @override
  String get tourManagers5Title => 'Las etiquetas cuelgan unas de otras';

  @override
  String get tourManagers5Body =>
      'Arrastra una sobre otra y queda colgando de ella. Ahí está la ventaja: poner una etiqueta hija pone también todas las que tiene encima, así que lo etiquetado con un personaje sale también al buscar su serie.';

  @override
  String get tourFernieTitle => 'Fernies y el modo fernie';

  @override
  String get tourFernieDescription =>
      'Qué es un fernie, de dónde salen sus ejemplos y todas las formas de marcarle regiones a tu contenido.';

  @override
  String get tourFernie1Title => 'Qué es un fernie';

  @override
  String get tourFernie1Body =>
      'Una cara, un personaje o un objeto que quieres que FeRN aprenda a reconocer en tu contenido. No es una etiqueta: una etiqueta dice qué es algo, un fernie es un ejemplo de qué aspecto tiene.';

  @override
  String get tourFernie2Title => 'Enlázalo con algo';

  @override
  String get tourFernie2Body =>
      'Cada fernie puede apuntar a una etiqueta o a un creador. Ese enlace es lo que convierte el reconocimiento en etiquetado: cuando se encuentre al fernie, eso es lo que se propone. Sin nada enlazado sólo sirve para entrenar.';

  @override
  String get tourFernie3Title => 'Sus regiones';

  @override
  String get tourFernie3Body =>
      'Cada recorte es un ejemplo suyo, y son los ejemplos con los que aprende un modelo. Cuantos más y más variados, mejor: con poca variedad aprenderá el fondo en vez de la cosa.';

  @override
  String get tourFernie4Title => 'Se marcan en el visor';

  @override
  String get tourFernie4Body =>
      'Abre un contenido y entra en modo fernie. Con la herramienta de marcar, arrastra un recuadro sobre lo que quieras y eliges de quién es. En vídeo y GIF la región es del fotograma en el que estés.';

  @override
  String get tourFernie5Title => 'Corregir lo marcado';

  @override
  String get tourFernie5Body =>
      'La otra herramienta elige lo que ya está: se mueve, se estira por sus tiradores, se le da a otro fernie o se borra. Nada se escribe hasta que sales guardando, así que se puede deshacer por el camino.';

  @override
  String get tourModelsTitle => 'Modelos y reconocimiento';

  @override
  String get tourModels1Title => 'Tus modelos';

  @override
  String get tourModels1Body =>
      'Un modelo es lo que de verdad reconoce. Se arma con los fernies que le pongas, se entrena una vez, y a partir de ahí puede mirar tu contenido y decir lo que ve.';

  @override
  String get tourModels2Title => 'Antes, el entorno';

  @override
  String get tourModels2Body =>
      'El reconocimiento corre sobre Python, y FeRN te lo instala: Ajustes → Reconocimiento y pulsar instalar. Son unos cientos de megas y se hace una sola vez. Con tarjeta gráfica va mucho más rápido.';

  @override
  String get tourModels3Title => 'Armar uno';

  @override
  String get tourModels3Body =>
      'Le eliges sus fernies y qué tiene que contestar: si cada uno está o no está, o cuál de ellos ha encontrado y dónde. Lo segundo necesita al menos dos fernies y regiones marcadas en el contenido.';

  @override
  String get tourModels4Title => 'Entrenar tarda';

  @override
  String get tourModels4Body =>
      'De minutos a horas, según lo que le hayas dado y la máquina que tengas. Corre por detrás y puedes seguir usando FeRN; el indicador de arriba dice por qué época va y cuánto queda a ojo.';

  @override
  String get tourModels5Title => 'Reconocer';

  @override
  String get tourModels5Body =>
      'Un modelo ya entrenado repasa el contenido que le eches —uno, una selección o la biblioteca entera— y propone lo que ve. Por debajo de su listón de seguridad no propone nada.';

  @override
  String get tourDuplicatesTitle => 'Contenido repetido';

  @override
  String get tourDuplicatesDescription =>
      'Cómo se busca lo repetido, cómo se decide qué copia se queda y de qué depende que dos cosas cuenten como la misma.';

  @override
  String get tourDuplicates1Title => 'Buscar repetidos';

  @override
  String get tourDuplicates1Body =>
      'Pulsa Buscar ahora y FeRN repasa la biblioteca entera calculando una huella de cada contenido. La primera vez puede tardar un rato; después sólo calcula la de lo nuevo.';

  @override
  String get tourDuplicates2Title => 'Los grupos';

  @override
  String get tourDuplicates2Body =>
      'Cada grupo son copias que se parecen lo bastante como para ser lo mismo: la misma imagen en dos tamaños, o guardada dos veces desde sitios distintos. Los que ya has contestado no vuelven a salir.';

  @override
  String get tourDuplicates3Title => 'Se decide cuál se queda';

  @override
  String get tourDuplicates3Body =>
      'Eliges la copia que conservas y las demás se descartan. Antes puedes fusionar en la que se queda las etiquetas, el creador, el favorito y la descripción de las que se van.';

  @override
  String get tourDuplicates4Title => 'O decir que no son la misma';

  @override
  String get tourDuplicates4Body =>
      'Si el grupo se equivoca, dilo y no se vuelve a ofrecer. Dos cosas que sólo se parecen no son un repetido, y eso sólo lo sabes tú.';

  @override
  String get tourDuplicates5Title => 'El listón, en Ajustes';

  @override
  String get tourDuplicates5Body =>
      'Cuánto pueden diferenciarse dos contenidos y seguir contando como el mismo. Subirlo agrupa más y empieza a juntar cosas que sólo se parecen; bajarlo deja sólo las copias casi idénticas.';

  @override
  String get tourModelsDescription =>
      'El entorno de Python, cómo se arma y se entrena un modelo, qué pasa con lo que propone y cómo el árbol decide cuáles se ejecutan.';

  @override
  String get tourModels6Title => 'Nada se aplica solo';

  @override
  String get tourModels6Body =>
      'Lo que ve se queda en sugerencia hasta que la aceptas, en el panel del contenido o de golpe desde la pantalla de importación. Rechazar una es decir que no se vuelva a ofrecer para ese contenido.';

  @override
  String get tourModels7Title => 'El árbol de modelos';

  @override
  String get tourModels7Body =>
      'Un modelo que no está en el árbol no se ejecuta nunca al reconocer. El árbol es lo que dice cuáles corren y en qué orden.';

  @override
  String get tourModels8Title => 'Meterlos y colgarlos';

  @override
  String get tourModels8Body =>
      'El panel de la derecha son los modelos que están fuera. Elige un nodo del árbol y lo que metas colgará de él. Un modelo no puede colgar de sí mismo ni estar dos veces en el árbol.';

  @override
  String get tourLibraryTitle => 'La biblioteca y el visor';

  @override
  String get tourLibraryDescription =>
      'La rejilla, marcar varios a la vez, el menú del botón derecho y todo lo que sabe hacer el visor.';

  @override
  String get tourSearchingTitle => 'Buscar y filtrar';

  @override
  String get tourSearchingDescription =>
      'Las pastillas que se acumulan, el texto libre, los filtros de la barra y las demás formas de acotar lo que ves.';

  @override
  String get tourNsfwTitle => 'El bloqueo de contenido';

  @override
  String get tourNsfwDescription =>
      'Una contraseña que esconde lo que marques, qué se esconde con ello y cómo se comporta abierto y cerrado.';

  @override
  String get tourFilesTitle => 'Ficheros y mantenimiento';

  @override
  String get tourFilesDescription =>
      'Dónde vive tu contenido en el disco, qué hace FeRN con esos ficheros y cómo se limpia después.';

  @override
  String get tutorialViewerTitle => 'El visor';

  @override
  String get tutorialViewerBody =>
      'Abrir algo ocupa la pantalla entera: se acerca con la rueda, se pasa de uno a otro con las flechas, y el panel lateral es donde se le pone creador, etiquetas y descripción mientras lo estás mirando.';

  @override
  String get tutorialJobsTitle => 'Lo que corre por detrás';

  @override
  String get tutorialJobsBody =>
      'Las importaciones, el reconocimiento, los entrenamientos y la búsqueda de repetidos corren por detrás: este indicador dice qué hay en marcha, por dónde va y deja pararlo. Mientras tanto puedes seguir usando FeRN.';

  @override
  String get tourImporting6Title => 'Lo que no quieres que vuelva';

  @override
  String get tourImporting6Body =>
      'Una fuente remota vuelve a ofrecer lo mismo cada vez. Al descartar algo puedes decir además que no te lo vuelva a ofrecer: se salta antes de descargarlo, y la lista de lo bloqueado está en Ajustes → Base de datos.';

  @override
  String get tourImporting7Title => 'Lo que puede pasar solo';

  @override
  String get tourImporting7Body =>
      'Lo que llega puede etiquetarse solo si la dirección de la que viene está vinculada a una etiqueta, marcarse como NSFW si lo enciendes en la cabecera, y pasar por tus modelos si lo pides en Ajustes.';

  @override
  String get tourImporting8Title => 'De golpe';

  @override
  String get tourImporting8Body =>
      'No hace falta ir de uno en uno: marca varios y la cabecera te deja aceptarlos todos, descartarlos todos, o aceptar de golpe las sugerencias de tus modelos que pasen de la seguridad que elijas.';

  @override
  String get tourImporting9Title => 'Y ya está en Contenido';

  @override
  String get tourImporting9Body =>
      'Lo que has guardado sale de la rejilla de importación y aparece en la biblioteca. A partir de ahí se busca, se etiqueta y entra en todo lo demás que hace FeRN.';

  @override
  String get tourLibrary1Title => 'Todo lo que tienes';

  @override
  String get tourLibrary1Body =>
      'La rejilla respeta la forma de cada contenido, así que se reconocen tanto por su silueta como por lo que hay dentro. Al desplazarte se va cargando lo que viene.';

  @override
  String get tourLibrary2Title => 'Varios a la vez';

  @override
  String get tourLibrary2Body =>
      'Cada celda tiene su casilla en la esquina: marca una y estás seleccionando. Mayúsculas y clic estira la selección hasta ahí, siguiendo el orden de la pantalla. Lo que hagas después va sobre todas.';

  @override
  String get tourLibrary3Title => 'El botón derecho';

  @override
  String get tourLibrary3Body =>
      'Sobre cualquier celda saca lo que se puede hacer: marcarlo como favorito, mandarlo a la papelera, reconocerlo con tus modelos o abrir la carpeta donde está. Con una selección hecha, va sobre toda ella.';

  @override
  String get tourLibrary4Title => 'La papelera devuelve';

  @override
  String get tourLibrary4Body =>
      'Mandar algo a la papelera no lo borra: se queda ahí un tiempo y se puede restablecer con todo lo que tenía. Vaciar la papelera es lo que borra de verdad, y eso pregunta antes.';

  @override
  String get tourLibrary5Title => 'Ordenar y filtrar aquí';

  @override
  String get tourLibrary5Body =>
      'La cabecera dice cuántos hay y deja ordenarlos —lo más nuevo, lo más viejo, al azar— y quedarte sólo con imágenes, sólo con vídeo, o sólo con lo que vino de una fuente.';

  @override
  String get tourLibrary6Title => 'Dentro del visor';

  @override
  String get tourLibrary6Body =>
      'La rueda acerca, el botón central —o la barra espaciadora— arrastra la imagen, y el doble clic la vuelve a ajustar a la pantalla. Las flechas pasan al anterior y al siguiente sin salir.';

  @override
  String get tourLibrary7Title => 'El panel de información';

  @override
  String get tourLibrary7Body =>
      'Creador, etiquetas, descripción y enlaces, todo editable ahí mismo. También enseña lo que proponen tus modelos, y un botón que explica de dónde ha salido cada etiqueta de ese contenido.';

  @override
  String get tourLibrary8Title => 'Favoritos';

  @override
  String get tourLibrary8Body =>
      'El corazón marca lo que quieres volver a encontrar sin acordarte de cómo lo etiquetaste. Todo lo marcado tiene su propia pantalla en el menú.';

  @override
  String get tourLibrary9Title => 'Vídeo y animación';

  @override
  String get tourLibrary9Body =>
      'El vídeo y los GIF se reproducen en el visor con una línea de tiempo que se puede recorrer fotograma a fotograma. Eso importa más adelante: una región de fernie es de un fotograma, no del vídeo entero.';

  @override
  String get tourManagers6Title => 'Y algunas van juntas';

  @override
  String get tourManagers6Body =>
      'Al soltar una sobre otra también se puede elegir relacionarlas en vez de colgarlas: son hermanas. Las hermanas no están ni encima ni debajo: poner una pone también la otra, porque van siempre juntas.';

  @override
  String get tourManagers7Title => 'Las personas son etiquetas';

  @override
  String get tourManagers7Body =>
      'Una etiqueta se puede marcar como persona: alguien o un personaje que sale en el contenido. Es sólo una forma de tener la lista ordenada —el botón de arriba cambia entre las dos listas— y en el resto de la aplicación se comportan como cualquier etiqueta.';

  @override
  String get tourManagers8Title => 'Etiquetar solo';

  @override
  String get tourManagers8Body =>
      'Una etiqueta puede tener direcciones vinculadas. Todo lo que llegue desde una de esas direcciones entra ya etiquetado, y con lo que haya por encima y sus hermanas. De ahí va a salir la mayor parte de tu etiquetado.';

  @override
  String get tourManagers9Title => 'Una lista larga, domada';

  @override
  String get tourManagers9Body =>
      'El chevron de una etiqueta pliega su rama, y el buscador de encima de la lista la encuentra por nombre. Las dos cosas van aquí y en el menú lateral, y lo que pliegues sigue plegado la próxima vez.';

  @override
  String get tourManagers10Title => 'Etiquetar de golpe';

  @override
  String get tourManagers10Body =>
      'Desde la biblioteca, arrastra uno o varios contenidos sobre una etiqueta del menú. Es la forma rápida, y es para lo que las etiquetas del menú son sitios donde soltar.';

  @override
  String get tourManagers11Title => '¿De dónde sale esa etiqueta?';

  @override
  String get tourManagers11Body =>
      'FeRN etiqueta solo por varios caminos, y en el panel todos se ven igual. El botón del reloj de cada contenido explica cada una: la pusiste tú, casó una dirección, se heredó, la propuso un modelo, la trajo un fernie.';

  @override
  String get tourSearching1Title => 'La barra de búsqueda';

  @override
  String get tourSearching1Body =>
      'Funciona desde cualquier pantalla. Según escribes, FeRN te ofrece lo que encaja: etiquetas, creadores y contenido por su descripción. Busca en tu biblioteca, no en internet.';

  @override
  String get tourSearching2Title => 'Lo que eliges se queda en una pastilla';

  @override
  String get tourSearching2Body =>
      'Elegir una etiqueta o un creador lo convierte en una pastilla de la barra. Una pastilla busca por esa cosa exacta y no por su nombre: el creador Pompeu trae lo suyo, y no lo que sólo menciona la palabra.';

  @override
  String get tourSearching3Title => 'Las pastillas se cruzan';

  @override
  String get tourSearching3Body =>
      'Con dos pastillas se enseña lo que cumple las dos, no lo que cumple alguna: esta etiqueta, de este creador. Ahí está su utilidad. El retroceso con el campo vacío quita la última.';

  @override
  String get tourSearching4Title => 'El texto libre';

  @override
  String get tourSearching4Body =>
      'Si lo que escribes no es una etiqueta ni un creador, pulsa Enter y se queda como pastilla de texto libre: busca en las descripciones y en los nombres de fichero. Útil para lo que nunca llegaste a etiquetar.';

  @override
  String get tourSearching5Title => 'Acotar el resultado';

  @override
  String get tourSearching5Body =>
      'El filtro de al lado de la barra decide qué clases de resultado cuentan y deja quedarte sólo con imágenes, sólo con vídeo o sólo con una fuente. Con una sola pastilla, además, deja descartar grupos enteros de resultados.';

  @override
  String get tourSearching6Title => 'El menú también filtra';

  @override
  String get tourSearching6Body =>
      'Pulsar una etiqueta del menú lateral es lo mismo que poner su pastilla en la barra, así que desde ahí puedes seguir: añade un creador, añade una palabra. La barra siempre enseña lo que está filtrando.';

  @override
  String get tourSearching7Title => 'Cada lista tiene el suyo';

  @override
  String get tourSearching7Body =>
      'Las listas de etiquetas, creadores y fernies tienen su propio filtro encima. Ése sólo acota la lista que estás mirando, y no toca lo que enseña la rejilla.';

  @override
  String get tourFernie6Title => 'Cuando el ejemplo es todo';

  @override
  String get tourFernie6Body =>
      'Hay un botón que marca el fotograma entero de una vez, para cuando el contenido no es más que la cosa. Y en la ficha de un fernie hay otro que coge una etiqueta entera y marca así todo su contenido.';

  @override
  String get tourFernie7Title => 'De sugerencia a ejemplo';

  @override
  String get tourFernie7Body =>
      'Cuando un modelo ya ha propuesto algo, el panel ofrece convertir lo que vio en regiones: dibuja los recuadros y tú aceptas los que estén bien. Es la forma más rápida de hacer crecer un fernie.';

  @override
  String get tourFernie8Title => 'Marcar también etiqueta';

  @override
  String get tourFernie8Body =>
      'Marcarle una región a un contenido es decir que ese fernie sale ahí, así que lo que enlaza se le pone al momento. El creador sólo si no tenía ya uno suyo.';

  @override
  String get tourFernie9Title => 'Y luego se entrena';

  @override
  String get tourFernie9Body =>
      'Los fernies solos no reconocen nada. Lo que reconoce es un modelo entrenado con ellos, y de eso va el siguiente recorrido.';

  @override
  String get tourModels9Title => 'Cada rama tiene su condición';

  @override
  String get tourModels9Body =>
      'Un hijo sólo se ejecuta cuando el padre detecta el fernie que le hayas puesto a esa unión. Ahí está la gracia: uno general filtra, y sólo lo que encuentra pasa a los especializados.';

  @override
  String get tourModels10Title => 'Cuando salió mal';

  @override
  String get tourModels10Body =>
      'Un entrenamiento se puede parar a medias, y a un modelo se le puede hacer olvidar lo aprendido: se van sus pesos y vuelve a estar sin entrenar, pero se quedan sus fernies, sus ajustes y su sitio en el árbol.';

  @override
  String get tourDuplicates6Title => 'Y busca solo';

  @override
  String get tourDuplicates6Body =>
      'Cada cierto tiempo FeRN lo repasa por su cuenta y avisa si encuentra algo. Ese periodo también está en Ajustes, y apagarlo también.';

  @override
  String get tourNsfw1Title => 'Qué es el bloqueo';

  @override
  String get tourNsfw1Body =>
      'Una contraseña que esconde parte de tu biblioteca. Lo que marques como NSFW desaparece mientras el bloqueo esté cerrado: no está en la rejilla, ni en las búsquedas, ni en los recuentos.';

  @override
  String get tourNsfw2Title => 'Ponerlo en marcha';

  @override
  String get tourNsfw2Body =>
      'En Ajustes, en la sección del bloqueo, se pone una contraseña. FeRN te da entonces un código de recuperación: apúntalo. Es la única forma de volver a entrar, porque la contraseña no se guarda en ninguna parte.';

  @override
  String get tourNsfw3Title => 'Abrir y cerrar';

  @override
  String get tourNsfw3Body =>
      'Abrir pide la contraseña; cerrar no pregunta nada y es inmediato. Puedes hacer que recuerde que está abierto entre sesiones, o que arranque cerrado siempre.';

  @override
  String get tourNsfw4Title => 'Marcar una etiqueta o un creador';

  @override
  String get tourNsfw4Body =>
      'Sus fichas tienen un botón de bloqueo. Marcar una etiqueta esconde todo lo que la lleva, y todo lo que cuelga de ella en el árbol. Marcar un creador lo esconde a él y a todo su contenido.';

  @override
  String get tourNsfw5Title => 'O un contenido suelto';

  @override
  String get tourNsfw5Body =>
      'Cualquier contenido se puede marcar por su cuenta desde el visor, digan lo que digan sus etiquetas. Y al importar puedes hacer que todo lo que llegue entre ya marcado, que ahorra marcar cincuenta cosas a mano.';

  @override
  String get tourNsfw6Title => 'Cómo se comporta';

  @override
  String get tourNsfw6Body =>
      'Eliges qué significa cerrado: que lo marcado desaparezca del todo, o que salga difuminado para saber que está. Y eliges si al abrir se ve todo o sólo lo marcado.';

  @override
  String get tourNsfw7Title => 'Los enlaces también se marcan';

  @override
  String get tourNsfw7Body =>
      'Una etiqueta o un creador pueden tener direcciones marcadas: no se enseñan con el bloqueo cerrado, pero siguen etiquetando lo que llegue de ellas. Esconder una dirección no es olvidarla.';

  @override
  String get tourNsfw8Title => 'Deshacerse de todo';

  @override
  String get tourNsfw8Body =>
      'En Ajustes → Base de datos se puede vaciar sólo lo marcado: sólo el contenido, porque las etiquetas, los creadores, los fernies y los modelos se quedan. Sólo se ofrece con el bloqueo abierto: cerrado sería borrar a ciegas.';

  @override
  String get tourFiles1Title => 'Dónde vive tu contenido';

  @override
  String get tourFiles1Body =>
      'FeRN guarda una base de datos con lo que sabe, y los ficheros se quedan en tu disco. En Ajustes eliges la carpeta de la biblioteca: ahí es donde va a parar lo que traes.';

  @override
  String get tourFiles2Title => 'Vigilar una carpeta tuya';

  @override
  String get tourFiles2Body =>
      'Puedes apuntar FeRN a una carpeta que ya tengas y traerte lo que hay dentro. Tú decides si copia los ficheros a la biblioteca o los deja donde están y sólo se acuerda de ellos.';

  @override
  String get tourFiles3Title => 'Ordenar solo';

  @override
  String get tourFiles3Body =>
      'FeRN puede archivar lo que gestiona en carpetas por fuente, por creador o por fecha, para que el disco se parezca a la biblioteca. Si cambias de idea después, mueve lo que ya está.';

  @override
  String get tourFiles4Title => 'La carpeta de avatares';

  @override
  String get tourFiles4Body =>
      'Los avatares son copias que hace FeRN, así que viven en su propia carpeta, que también eliges tú. Cambiar la carpeta se lleva lo que hay dentro: nada se queda sin su imagen.';

  @override
  String get tourFiles5Title => 'Mover la biblioteca';

  @override
  String get tourFiles5Body =>
      'Si apuntas la biblioteca a otro disco, FeRN se ofrece a mover allí lo que gestiona y a actualizar todas las rutas que tiene apuntadas. Es una operación larga, así que te cuenta cómo ha ido.';

  @override
  String get tourFiles6Title => 'Ficheros que no usa nadie';

  @override
  String get tourFiles6Body =>
      'Con el tiempo se acumulan huérfanos: avatares que reemplazaste, descargas cuya ficha descartaste, pesos de un modelo que ya no está. El botón de limpieza de Ajustes los encuentra, dice cuánto ocupan y pregunta antes de borrar.';

  @override
  String get tourFiles7Title => 'Empezar de cero';

  @override
  String get tourFiles7Body =>
      'Vaciar la base de datos es lo único de aquí sin vuelta atrás, y pregunta dos veces. Tú eliges si se lleva también los ficheros: sin eso, tus ficheros se quedan donde están y un escaneo los vuelve a traer.';

  @override
  String get tourFiles8Title => 'Y te avisa cuando termina';

  @override
  String get tourFiles8Body =>
      'Los trabajos largos —importar, entrenar, reconocer, buscar repetidos— pueden avisarte al terminar, con sonido o sin él. Eso también está en Ajustes, y puedes elegir de cuáles.';

  @override
  String get viewerVolume => 'Volumen';

  @override
  String get tagNameTaken => 'Ya hay una etiqueta con ese nombre';

  @override
  String get filterByNameHint => 'Filtrar por nombre';

  @override
  String tagDropAsChild(String name) {
    return 'Colgar de «$name»';
  }

  @override
  String tagDropAsSibling(String name) {
    return 'Relacionar con «$name»';
  }

  @override
  String get importStopping => 'Parando la importación…';
}
