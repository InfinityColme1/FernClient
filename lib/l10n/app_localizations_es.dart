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
      'Desactivar el filtro desmarca todas las etiquetas y deja de esconder nada. El contenido no se toca: estaba marcado, no cifrado.';

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
  String get tutorialSectionTitle => 'Vuelta guiada';

  @override
  String get tutorialSectionNote =>
      'Un recorrido por las pantallas de la aplicación y por lo que se hace en cada una. Se puede dejar en cualquier momento.';

  @override
  String get tutorialOfferTitle => '¿Te enseño la aplicación?';

  @override
  String get tutorialOfferBody =>
      'Es un recorrido de ocho pasos y se deja cuando quieras. Si prefieres mirar por tu cuenta, lo tienes en los ajustes.';

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
      'Un recorrido rápido por lo que hace la aplicación. Se avanza con Siguiente o con las flechas, y se sale con Escape.';

  @override
  String get tutorialSidebarTitle => 'Por aquí se navega';

  @override
  String get tutorialSidebarBody =>
      'Todas las pantallas están aquí: tu biblioteca, lo que traes de fuera, tus favoritos y los gestores. El botón de arriba lo pliega para dejarle sitio al contenido.';

  @override
  String get tutorialImportTitle => 'Por aquí entra el contenido';

  @override
  String get tutorialImportBody =>
      'Traes contenido de una fuente remota o de una carpeta de tu disco. Lo que llega se queda pendiente de revisar hasta que lo aceptas, así que nada entra en la biblioteca sin que lo veas.';

  @override
  String get tutorialContentTitle => 'Aquí aparece todo';

  @override
  String get tutorialContentBody =>
      'Tu biblioteca. Un clic abre el visor, el botón derecho saca las acciones, y se pueden marcar varios a la vez para tratarlos juntos.';

  @override
  String get tutorialTagsTitle => 'Etiqueta arrastrando';

  @override
  String get tutorialTagsBody =>
      'Las etiquetas del menú son también sitios donde soltar: arrastra uno o varios contenidos encima de una y quedan etiquetados. Al pulsarla, la biblioteca enseña sólo lo suyo.';

  @override
  String get tutorialCreateTitle => 'Creadores, etiquetas y fernies';

  @override
  String get tutorialCreateBody =>
      'Desde aquí se crea todo lo que sirve para organizar: creadores, etiquetas y fernies, que son las caras que la aplicación aprende a reconocer.';

  @override
  String get tutorialSearchTitle => 'Buscar';

  @override
  String get tutorialSearchBody =>
      'Busca por nombre, creador o etiqueta desde cualquier pantalla.';

  @override
  String get tutorialSettingsTitle => 'Todo lo demás está aquí';

  @override
  String get tutorialSettingsBody =>
      'Idioma, tema, carpetas, fuentes remotas y reconocimiento. Y este mismo tutorial, por si quieres repetirlo.';

  @override
  String get tourGeneralTitle => 'Vuelta general';

  @override
  String get tourGeneralDescription =>
      'Dónde está cada cosa y por dónde entra el contenido. Es el que se ofrece la primera vez.';

  @override
  String get tourImportingTitle => 'Traer y revisar contenido';

  @override
  String get tourImportingDescription =>
      'De dónde sale el contenido, cómo se revisa y qué hace falta para que llegue a la biblioteca.';

  @override
  String get tourImporting1Title => 'De dónde y cuánto';

  @override
  String get tourImporting1Body =>
      'Eliges la fuente —una remota o una carpeta de este equipo—, si quieres todo o sólo lo nuevo desde la última vez, y pulsas Traer.';

  @override
  String get tourImporting2Title => 'Lo traído se revisa aquí';

  @override
  String get tourImporting2Body =>
      'Nada de esto está todavía en tu biblioteca. Esta rejilla es la bandeja de entrada: lo que se ha traído, esperando a que digas qué hacer con ello.';

  @override
  String get tourImporting3Title => 'Abre uno y decide';

  @override
  String get tourImporting3Body =>
      'Un clic lo abre en el visor. Ahí lo guardas, y pasa a ser definitivo, o lo descartas: descartar lo saca de la base de datos y te pregunta si borrar también el fichero.';

  @override
  String get tourImporting4Title => 'La ficha, sin salir del visor';

  @override
  String get tourImporting4Body =>
      'El panel de información es donde se le pone creador, etiquetas, título y enlaces. Se edita mientras se mira, que es cuando se sabe qué es.';

  @override
  String get tourImporting5Title => 'Y ya está en Contenido';

  @override
  String get tourImporting5Body =>
      'Lo que has guardado sale de la rejilla de importación y aparece en la biblioteca.';

  @override
  String get tourManagersTitle => 'Creadores y etiquetas';

  @override
  String get tourManagersDescription =>
      'Las dos formas de ordenar lo que tienes, y la manera rápida de etiquetar de golpe.';

  @override
  String get tourManagers1Title => 'La lista de creadores';

  @override
  String get tourManagers1Body =>
      'Todos los que tienes. Al elegir uno, la pantalla se llena con lo suyo.';

  @override
  String get tourManagers2Title => 'Su ficha';

  @override
  String get tourManagers2Body =>
      'Nombre, avatar y los enlaces a sus sitios. Lo que cambies aquí se guarda en el creador.';

  @override
  String get tourManagers3Title => 'Todo lo suyo';

  @override
  String get tourManagers3Body =>
      'El contenido que le has asignado, en una rejilla como la de la biblioteca.';

  @override
  String get tourManagers4Title => 'Las etiquetas van igual';

  @override
  String get tourManagers4Body =>
      'Con una diferencia: una etiqueta puede colgar de otra, así que se pueden ordenar en árbol.';

  @override
  String get tourManagers5Title => 'Y se ponen arrastrando';

  @override
  String get tourManagers5Body =>
      'Desde la biblioteca, arrastra uno o varios contenidos sobre una etiqueta del menú. Es la forma rápida de etiquetar de golpe.';

  @override
  String get tourFernieTitle => 'Modo fernie';

  @override
  String get tourFernieDescription =>
      'Qué es un fernie, de dónde salen sus ejemplos y cómo se marcan en el visor.';

  @override
  String get tourFernie1Title => 'Qué es un fernie';

  @override
  String get tourFernie1Body =>
      'Una cara, un personaje o un objeto que quieres que Fern aprenda a reconocer en tu contenido.';

  @override
  String get tourFernie2Title => 'Aquí están los tuyos';

  @override
  String get tourFernie2Body =>
      'Cada fernie puede proponer una etiqueta o un creador cuando se le encuentre. Sin nada enlazado sólo sirve para entrenar: por sí solo no etiqueta nada.';

  @override
  String get tourFernie3Title => 'Sus regiones';

  @override
  String get tourFernie3Body =>
      'Cada recorte es un ejemplo suyo, y son los ejemplos con los que aprende un modelo. Cuantos más y más variados, mejor: con poca variedad aprenderá el fondo y no el fernie.';

  @override
  String get tourFernie4Title => 'Se marcan en el visor';

  @override
  String get tourFernie4Body =>
      'Abre un contenido, entra en modo fernie y arrastra sobre lo que quieras marcar. Con la barra espaciadora o el botón central te mueves por la imagen.';

  @override
  String get tourFernie5Title => 'Y luego se entrena';

  @override
  String get tourFernie5Body =>
      'Los fernies solos no reconocen nada. Lo que reconoce es un modelo entrenado con ellos.';

  @override
  String get tourModelsTitle => 'Modelos y reconocimiento';

  @override
  String get tourModels1Title => 'Tus modelos';

  @override
  String get tourModels1Body =>
      'Un modelo es lo que de verdad reconoce. Se arma con los fernies que le pongas.';

  @override
  String get tourModels2Title => 'Crear uno';

  @override
  String get tourModels2Body =>
      'Le eliges sus fernies y qué tiene que contestar: si cada uno está o no está, o cuál de ellos ha encontrado y dónde. Lo segundo necesita al menos dos, porque con uno no hay entre qué elegir.';

  @override
  String get tourModels3Title => 'Entrenar tarda';

  @override
  String get tourModels3Body =>
      'Corre por detrás y puedes seguir usando Fern mientras tanto. El indicador de la barra de arriba dice por dónde va.';

  @override
  String get tourModels4Title => 'Reconocer';

  @override
  String get tourModels4Body =>
      'Un modelo ya entrenado repasa el contenido que le eches y propone lo que ve. Por debajo del listón de seguridad no propone nada.';

  @override
  String get tourModels5Title => 'Nada se aplica solo';

  @override
  String get tourModels5Body =>
      'Lo que ve se queda en sugerencia hasta que la aceptas. Puedes aceptar de golpe todas las que pasen de un porcentaje de seguridad.';

  @override
  String get tourDuplicatesTitle => 'Contenido repetido';

  @override
  String get tourDuplicatesDescription =>
      'Cómo se busca lo repetido, cómo se decide qué copia se queda y de qué depende que dos cosas cuenten como la misma.';

  @override
  String get tourDuplicates1Title => 'Buscar repetidos';

  @override
  String get tourDuplicates1Body =>
      'Pulsa Buscar ahora y Fern repasa la biblioteca entera calculando una huella de cada contenido. La primera vez puede tardar un rato.';

  @override
  String get tourDuplicates2Title => 'Los grupos';

  @override
  String get tourDuplicates2Body =>
      'Cada grupo son copias que se parecen lo bastante como para ser lo mismo. Los que ya has contestado no vuelven a salir.';

  @override
  String get tourDuplicates3Title => 'Se decide cuál se queda';

  @override
  String get tourDuplicates3Body =>
      'Eliges la copia que conservas y las demás se descartan. Puedes fusionar en la que se queda las etiquetas, el creador, el favorito y la descripción de las descartadas.';

  @override
  String get tourDuplicates4Title => 'El listón, en Ajustes';

  @override
  String get tourDuplicates4Body =>
      'Cuánto pueden diferenciarse dos contenidos y seguir contando como el mismo. Subirlo agrupa más y empieza a juntar cosas que sólo se parecen; bajarlo deja repetidos sin encontrar.';

  @override
  String get tourDuplicates5Title => 'Y se busca solo';

  @override
  String get tourDuplicates5Body =>
      'Cada cierto tiempo Fern lo repasa por su cuenta y avisa si encuentra algo. Ese periodo también está en Ajustes.';

  @override
  String get tourModelsDescription =>
      'Cómo se arma un modelo, qué tarda en entrenar, qué pasa con lo que propone y cómo el árbol decide cuáles se ejecutan.';

  @override
  String get tourModels6Title => 'El árbol de modelos';

  @override
  String get tourModels6Body =>
      'Un modelo que no está en el árbol no se ejecuta nunca al reconocer. El árbol es lo que dice cuáles corren y en qué orden.';

  @override
  String get tourModels7Title => 'Meterlos y colgarlos';

  @override
  String get tourModels7Body =>
      'El panel de la derecha son los modelos que están fuera. Elige un nodo del árbol y lo que metas colgará de él. Un modelo no puede colgar de sí mismo ni cerrar un círculo: el árbol se mordería la cola.';

  @override
  String get tourModels8Title => 'Cada rama tiene su condición';

  @override
  String get tourModels8Body =>
      'Un hijo sólo se ejecuta cuando el padre detecta el fernie que le hayas puesto a esa unión. Ahí está la gracia: uno general filtra, y sólo lo que encuentra abre los especializados. Sin condición se ejecutan ante cualquier detección, y un padre sin entrenar no abre nada.';

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
