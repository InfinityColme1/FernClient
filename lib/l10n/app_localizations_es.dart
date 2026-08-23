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
  String get menuNewCollection => 'Nueva colección';

  @override
  String get collectionsWip => 'Las colecciones todavía están en construcción';

  @override
  String get mobileLayoutWip => 'La versión móvil llegará pronto';

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
  String get actionRemoveParentTag => 'Quitar padre';

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
  String get trainingQueued => 'Entrenamiento en cola';

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
  String get modelImportWeights => 'Importar pesos';

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
  String get jobsNone => 'Nada en marcha';

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
  String get treeAddAsRoot => 'Meter suelto';

  @override
  String treeAddAsChild(String parent) {
    return 'Colgar de «$parent»';
  }

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
  String get mediaInfoTitle => 'Información';

  @override
  String get descriptionHint => 'Añade una descripción';

  @override
  String get createdBy => 'Creado por:';

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
  String repositoryLinkTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta publicación lleva a $count repositorios de contenido',
      one: 'Esta publicación lleva a un repositorio de contenido',
    );
    return '$_temp0';
  }

  @override
  String get repositoryLinkDescription =>
      'Fern no puede traerse esto por su cuenta: son páginas con su propia espera y sus comprobaciones. Puedes abrirlas en el navegador de Fern y traerte desde ahí lo que quieras. Mientras tanto la importación sigue.';

  @override
  String get repositoryLinkOpen => 'Ver en el navegador';

  @override
  String get pawchiveByCreators => 'Importar por creadores favoritos';

  @override
  String get pawchiveByCreatorsDescription =>
      'En lugar de las publicaciones que hayas marcado, Fern recorre todo lo que publiquen los creadores que tengas en favoritos. Trae bastante más, y cada creador se sigue por su cuenta.';

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
  String get sourceUrlsLabel => 'Direcciones';

  @override
  String get sourceUrlHint => 'reddit.com/r/ejemplo';

  @override
  String get addSourceUrl => 'Añadir dirección';

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
  String get jobsTooltip => 'Tareas en marcha';

  @override
  String get jobsTitle => 'Tareas en segundo plano';

  @override
  String get jobsEmpty => 'Ahora mismo no hay nada en marcha';

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
  String get notifyRemoteImport => 'Importación remota terminada';

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
  String get fernieModeTooltip => 'Marcar regiones';

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
  String get viewerRecognize => 'Reconocer con los modelos';

  @override
  String get viewerRecognizing => 'Reconociendo…';

  @override
  String get viewerRecognizeQueued => 'Reconocimiento en cola';

  @override
  String get suggestionsTitle => 'Sugerencias';

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
  String get suggestionsNone => 'Aquí no hay nada propuesto';

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
  String get jobDetailTooltip => 'Ver qué hicieron los modelos';

  @override
  String get jobsClearFinished => 'Dar por vistas las terminadas';

  @override
  String get recognitionLogFromToast =>
      'Pulsa para ver qué hicieron los modelos';

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
}
