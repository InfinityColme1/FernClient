import 'dart:async';
import 'dart:ui';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_icons.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/services/clipboard_service.dart';
import 'package:Fern/core/services/fullscreen_service.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/add_fernie_regions_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/apply_fernie_link_to_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/get_regions_of_media_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_region_usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_events.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/domain/usecases/answer_suggestions_usecase.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/usecases/get_media_suggestions_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_states.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_states.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/recognition/data/services/recognition_log_store.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_log_entity.dart';
import 'package:Fern/features/media/presentation/widgets/viewed_media.dart';
import 'package:Fern/features/recognition/presentation/widgets/recognition_log_dialog.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
import 'package:Fern/features/recognition/data/services/suggestion_spotlight.dart';
import 'package:Fern/features/recognition/presentation/widgets/assign_region_menu.dart';
import 'package:Fern/features/media/presentation/services/media_playback_controller.dart';
import 'package:Fern/features/recognition/domain/services/region_track.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_confirm_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_timeline.dart';
import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_info.dart';
import 'package:Fern/features/media/presentation/widgets/media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_sizes.dart';
import '../../../../config/theme/app_spacing.dart';
import '../blocs/media_bloc.dart';
import '../blocs/media_events.dart';
import '../blocs/media_states.dart';

class ViewerPage extends StatefulWidget {
  /// `true` cuando el panel de información debe estar abierto al entrar, que es
  /// el caso del contenido que llega desde la pantalla de importación.
  final bool openInfo;

  /// Región que hay que señalar con un parpadeo nada más abrir.
  ///
  /// Se llega así desde la rejilla de fernies, que enseña sólo recortes: el
  /// contenido se abre entero y el parpadeo dice de qué trozo se trataba.
  final int? highlightRegionId;

  /// Se está revisando una tanda recién importada.
  ///
  /// Es lo único que hace que guardar pase al siguiente contenido. Ese salto
  /// existe para no volver a la rejilla entre uno y otro mientras se revisa lo
  /// que acaba de llegar; desde cualquier otro sitio se ha abierto **ese**
  /// contenido, y llevarse al usuario a otro al guardar sería perder de vista lo
  /// que estaba mirando.
  final bool isReviewing;

  const ViewerPage({
    super.key,
    this.openInfo = false,
    this.highlightRegionId,
    this.isReviewing = false,
  });

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> with TickerProviderStateMixin {
  /// Nodo que recibe el foco al entrar para poder atender el teclado.
  final FocusNode _keyboardFocusNode = FocusNode(
    debugLabel: 'ViewerPageKeyboard',
  );

  /// El modo del visor y lo que se lleva marcado sin guardar.
  ///
  /// Nace y muere con la pantalla: salir del visor no puede dejar medio marcado
  /// en memoria esperando a la próxima vez.
  late final FernieModeBloc _fernieMode = FernieModeBloc(
    getRegions: getIt<GetRegionsOfMediaUseCase>(),
    getFernies: getIt<GetFerniesOfMediaUseCase>(),
    addRegions: getIt<AddFernieRegionsUseCase>(),
    updateRegion: getIt<UpdateFernieRegionUseCase>(),
    deleteRegion: getIt<DeleteFernieRegionUseCase>(),
    applyLink: getIt<ApplyFernieLinkToMediaUseCase>(),
  );

  /// Lo que los modelos proponen sobre lo que se está viendo, y el botón de
  /// pedirlo.
  ///
  /// Nace y muere con la pantalla por lo mismo que el anterior: las sugerencias
  /// son de un contenido concreto, y guardarlas en un bloc global sería
  /// arrastrar las de algo que ya nadie está mirando.
  late final SuggestionsBloc _suggestions = SuggestionsBloc(
    getSuggestions: getIt<GetMediaSuggestionsUseCase>(),
    answer: getIt<AnswerSuggestionsUseCase>(),
    launcher: getIt<RecognitionLauncher>(),
    jobs: getIt<JobQueue>(),
  );

  /// El zoom y el desplazamiento, compartidos entre el visor y la capa que
  /// dibuja las regiones encima: sin la misma transformación, los rectángulos se
  /// quedarían quietos mientras la imagen se mueve.
  final TransformationController _transformation = TransformationController();

  /// El mando del contenido que se reproduce: por dónde va, pararlo y recorrerlo
  /// de fotograma en fotograma.
  ///
  /// Con una imagen se queda en reposo y la línea de tiempo no aparece.
  final MediaPlaybackController _playback = MediaPlaybackController();

  /// Tamaño real del contenido que se está viendo. Hace falta para convertir un
  /// rectángulo de la pantalla en coordenadas de la imagen.
  Size? _contentSize;
  String? _sizeRequestedFor;

  /// La región recién arrastrada, a la espera de que el menú diga a qué fernie
  /// va, y dónde hay que abrir ese menú.
  Rect? _pendingRect;
  Offset? _menuPosition;

  /// Si el menú abierto es para cambiarle el fernie a una región que ya existe,
  /// en vez de para asignar una recién dibujada.
  bool _isReassigning = false;

  /// Si el ratón está sobre la ayuda del modo fernie.
  ///
  /// Mientras lo esté, la ayuda se quita de en medio: ocupa la franja de arriba
  /// del contenido, que es donde sale la pestaña de una región marcada cerca del
  /// borde superior.
  bool _isHintHovered = false;

  /// Si está puesto el papel cebolla.
  ///
  /// Con él, lo marcado en el fotograma anterior se ve apagado y se puede
  /// copiar a éste de un clic. Sin eso, marcar el mismo objeto fotograma a
  /// fotograma es hacerlo a ojo cada vez.
  bool _isOnionSkinOn = false;

  /// Si al copiar del papel cebolla se deja copia en cada fotograma de en medio.
  ///
  /// Es lo mismo que poner dos claves con el mismo valor en un vídeo: lo que hay
  /// entre ellas se queda igual. Sirve para lo que no se mueve durante un rato.
  bool _isDraggingRegions = false;

  /// Si se está arrastrando un rectángulo ahora mismo.
  ///
  /// Mientras dura, los mandos del visor se apartan: la barra de acciones ocupa
  /// justo la franja de arriba del contenido, que es donde más incómodo resulta
  /// no poder empezar a marcar.
  bool _isDrawingRegion = false;

  /// Las preguntas del modo fernie, de una en una.
  ///
  /// Preguntar es esperar, y entre la pulsación y el diálogo caben más
  /// pulsaciones: aporreando escape para salir salían tres y cuatro preguntas
  /// idénticas apiladas, y había que contestarlas todas. Lo de borrar tenía
  /// media protección (`isRepeat`, que sólo tapa tener la tecla pulsada); ésta
  /// mira si ya hay una puesta, que es lo que de verdad hay que saber.
  ///
  /// Una para las dos: nunca se pregunta por dos cosas a la vez, y con una
  /// bandera por pregunta habría que acordarse de añadir la siguiente.
  final _prompts = SinglePrompt();

  /// Clave del área del visor, para llevar la posición del ratón (que llega en
  /// coordenadas de la ventana) a coordenadas de esa área.
  final GlobalKey _stackKey = GlobalKey();

  late final AnimationController _highlightController = AnimationController(
    vsync: this,
    duration: fernieHighlightFadeDuration * 2 + fernieHighlightHoldDuration,
  );

  /// El resaltado: se oscurece todo menos la región, se queda así un momento y
  /// se vuelve a la normalidad. Los pesos son los milisegundos de cada tramo,
  /// así que cambiar las constantes cambia el reparto sin tocar nada más.
  /// Dónde vio el modelo lo que el panel de sugerencias está señalando.
  late final SuggestionSpotlight _spotlight = getIt<SuggestionSpotlight>();


  late final Animation<double> _highlight = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: fernieHighlightFadeDuration.inMilliseconds.toDouble(),
    ),
    TweenSequenceItem(
      tween: ConstantTween(1.0),
      weight: fernieHighlightHoldDuration.inMilliseconds.toDouble(),
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: fernieHighlightFadeDuration.inMilliseconds.toDouble(),
    ),
  ]).animate(_highlightController);

  /// Cuánto se ven las regiones guardadas.
  ///
  /// Fuera del modo fernie no se ven: el visor es para mirar el contenido. Entra
  /// y sale con un desvanecido corto porque aparecer de golpe encima de una
  /// imagen se lee como un fallo de pintado.
  late final AnimationController _regionsFadeController = AnimationController(
    vsync: this,
    duration: fernieRegionsFadeDuration,
  );

  late final CurvedAnimation _regionsFade = CurvedAnimation(
    parent: _regionsFadeController,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  /// Si los mandos (la barra de acciones con su sombreado y las flechas) están
  /// a la vista. Se esconden cuando el ratón lleva un rato quieto para dejar el
  /// contenido limpio, y vuelven en cuanto se mueve.
  bool _areControlsVisible = true;

  /// Cuenta atrás para esconderlos. Cada movimiento del ratón la reinicia.
  Timer? _hideTimer;

  /// Si la ventana está a pantalla completa por haberlo pedido desde aquí.
  bool _isFullscreen = false;

  /// Si el panel de información estaba abierto antes de la pantalla completa.
  ///
  /// A pantalla completa se cierra: lo que se pide ahí es ver el contenido y
  /// nada más, igual que en cualquier reproductor. Al salir vuelve a estar como
  /// estaba, que es lo que espera quien lo había abierto.
  bool _infoWasOpenBeforeFullscreen = false;

  /// Hacia dónde va el pase: hacia delante (el contenido entra por la derecha)
  /// o hacia atrás (entra por la izquierda).
  ///
  /// Es de la pantalla y no del bloc porque no es información del contenido sino
  /// de cómo se ha llegado a él, y sólo la necesita la animación. Al guardar un
  /// contenido importado el visor también pasa al siguiente, y ése va hacia
  /// delante, que es como se queda de partida.
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    context.read<MediaBloc>().add(SetInfoVisibilityEvent(widget.openInfo));
    _restartHideTimer();

    // Las flechas se atienden antes que el foco: ver [_onArrowKey].
    HardwareKeyboard.instance.addHandler(_onArrowKey);

    // El volumen que el usuario dejo puesto la ultima vez. Se le da al mando
    // antes de que se enganche ningun reproductor, asi que el primer video ya
    // suena como toca en vez de arrancar a tope y bajar despues.
    _playback.setVolume(getIt<PreferencesService>().getViewerVolume());

    // Al visor se llega con el contenido ya resuelto, así que el aviso de
    // «contenido nuevo» no va a llegar nunca para el primero: se atiende aquí a
    // mano. Sin esto no se mide el fichero, y sin medida no hay forma de marcar
    // regiones sobre él.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final media = context.read<MediaBloc>().state.currentMedia;
      if (media != null) _onMediaChanged(media);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    // La pantalla completa es de esta pantalla: al salir de ella (por el botón
    // de volver, por escape o porque el contenido ha desaparecido) la ventana
    // vuelve a como estaba.
    FullscreenService.instance.exit();
    _highlightController.dispose();
    _regionsFade.dispose();
    _regionsFadeController.dispose();
    _transformation.dispose();
    _playback.dispose();
    _fernieMode.close();
    _suggestions.close();
    // El señalado vive fuera de esta pantalla porque lo enciende el panel, así
    // que apagarlo al salir es cosa de aquí: nadie más sabe que se ha salido.
    _spotlight.release();
    HardwareKeyboard.instance.removeHandler(_onArrowKey);
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Las flechas pasan de contenido, **tenga el foco quien lo tenga**.
  ///
  /// El resto del teclado del visor va por el foco (ver [_handleKeyEvent]), y
  /// para las flechas eso no basta: en cuanto se pulsa un botón del panel, una
  /// píldora de etiqueta o el propio reproductor, el foco se va allí y quien
  /// decide qué pasa con la flecha es ese widget. El resultado era que pasar de
  /// contenido dejaba de funcionar hasta volver a pulsar sobre la imagen, sin
  /// que nada lo explicara.
  ///
  /// Atendiéndolas aquí —antes del reparto por foco— pasan siempre. Con tres
  /// excepciones, que son las tres veces que la flecha significa otra cosa:
  ///
  /// - **Hay algo delante.** Un diálogo abierto es otra ruta encima de ésta, y
  ///   las flechas son suyas. Es lo que dice [ModalRoute.isCurrent].
  /// - **Se está escribiendo.** En un campo de texto la flecha mueve el cursor,
  ///   y quitársela sería romper el campo.
  /// - **El modo fernie está abierto.** Ahí las flechas se comen a propósito:
  ///   pasar de contenido perdería lo marcado. De eso sigue encargándose
  ///   [_handleFernieKey], así que aquí sólo hay que no adelantarse.
  bool _onArrowKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final key = event.logicalKey;
    final isLeft = key == LogicalKeyboardKey.arrowLeft;
    final isRight = key == LogicalKeyboardKey.arrowRight;
    if (!isLeft && !isRight) return false;

    if (!mounted || _fernieMode.state.isFernieMode) return false;
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    if (_isTypingText) return false;

    _goTo(next: isRight);

    return true;
  }

  /// Si el foco está dentro de un campo de texto.
  ///
  /// Se mira el `EditableText` que hay por encima del nodo con el foco, que es
  /// lo que tienen en común todos los campos de la aplicación: comprobar cada
  /// clase de campo por su cuenta sería una lista que hay que acordarse de
  /// ampliar.
  static bool get _isTypingText {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;

    return focused.widget is EditableText ||
        focused.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _goTo({required bool next}) {
    // Con el modo abierto no se pasa de contenido: se perdería lo marcado sin
    // que nadie lo hubiera pedido.
    if (_fernieMode.state.isFernieMode) return;

    _isForward = next;
    context.read<MediaBloc>().add(ViewerNextEvent(next: next));
  }

  // ---------------------------------------------------------------------------
  // Contenido actual
  // ---------------------------------------------------------------------------

  /// Se entera de que el visor está enseñando otro contenido.
  ///
  /// Hay dos cosas que hacer con cada contenido nuevo: leer sus regiones y medir
  /// el fichero. Lo segundo es asíncrono, así que hasta que llegue no se puede
  /// marcar nada, que es justo lo que se quiere.
  void _onMediaChanged(MediaEntity media) {
    // Para volver a ella al salir: la rejilla se coloca donde está lo último
    // que se miró.
    getIt<ViewedMedia>().see(media.id);

    if (_fernieMode.state.mediaId != media.id) {
      _fernieMode.add(LoadMediaRegionsEvent(media.id));

      // Y con el contenido se va lo que estuviera señalado: la caja es de la
      // imagen anterior, y dejarla puesta la pinta sobre ésta en un sitio que no
      // significa nada.
      _spotlight.release();
    }

    // Se leen tenga el panel abierto o no: el botón de la barra necesita saber
    // si este contenido ya se está reconociendo antes de que nadie abra nada.
    if (_suggestions.state.mediaId != media.id) {
      _suggestions.add(LoadSuggestionsEvent(media.id));
    }

    if (_sizeRequestedFor == media.path) return;
    _sizeRequestedFor = media.path;

    _measure(media.path);
  }

  Future<void> _measure(String path) async {
    final preview = await MediaPreviewService.instance.load(path);
    if (!mounted || _sizeRequestedFor != path) return;

    final width = preview?.width;
    final height = preview?.height;
    if (width == null || height == null || width <= 0 || height <= 0) return;

    setState(() => _contentSize = Size(width.toDouble(), height.toDouble()));
  }

  /// Arranca el parpadeo cuando las regiones ya están leídas y entre ellas está
  /// la que había que señalar.
  ///
  /// En un vídeo, antes hay que llevar el contenido a su sitio: la región es de
  /// un instante concreto, y señalarla desde el principio del vídeo es señalar
  /// un fotograma en el que no está.
  void _maybeHighlight(FernieModeState state) {
    final id = widget.highlightRegionId;
    if (id == null || _highlightController.isAnimating) return;
    if (_highlightController.value != 0) return;

    final index = _highlightIndexIn(state);
    if (index == null) return;

    final frameMs = state.views[index].frameMs;
    final path = context.read<MediaBloc>().state.currentMedia?.path;

    if (frameMs != null && (path?.isVideoPath ?? false)) {
      _highlightAtFrame(Duration(milliseconds: frameMs));
      return;
    }

    _highlightController.forward(from: 0);
  }

  /// Lleva el vídeo al instante de la región que hay que señalar, lo para ahí y
  /// entonces la señala.
  ///
  /// **Parado**: la región es de un fotograma, y con el vídeo corriendo se iría
  /// justo cuando se está enseñando. Quien quiera verlo moverse le da a
  /// reproducir, que para eso está la barra de abajo.
  ///
  /// El reproductor tarda en abrir el fichero, así que puede no estar listo
  /// todavía cuando llegan las regiones. En ese caso se espera al primer aviso
  /// suyo que diga que ya se puede: el parpadeo no vale de nada sobre un
  /// fotograma que no es.
  void _highlightAtFrame(Duration at) {
    final path = context.read<MediaBloc>().state.currentMedia?.path;

    _playback.whenPlayable(() {
      if (!mounted) return;

      // Se esperaba a **este** contenido. Pasar al siguiente mientras el
      // reproductor abría el fichero dejaba la espera viva, y el vídeo nuevo
      // acababa saltando al fotograma de una región que no es suya.
      if (context.read<MediaBloc>().state.currentMedia?.path != path) return;

      _playback.pause();
      _playback.seekToFrame(_playback.frameIndexOf(at));
      _highlightController.forward(from: 0);
    });
  }

  int? _highlightIndexIn(FernieModeState state) {
    final id = widget.highlightRegionId;
    if (id == null) return null;

    final views = state.views;
    for (var index = 0; index < views.length; index++) {
      if (views[index].savedId == id) return index;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Modo fernie
  // ---------------------------------------------------------------------------

  /// Sale del modo. Con `save: false` avisa antes, si es que hay algo que
  /// perder.
  Future<void> _exitFernieMode({required bool save}) async {
    if (!_fernieMode.state.isFernieMode) return;

    if (!save && _fernieMode.state.hasChanges) {
      final discard = await _prompts.ask(_confirmDiscard) ?? false;

      // El diálogo se puede quedar abierto mientras la pantalla se va (el
      // contenido desaparece, alguien navega): al volver, aquí ya no hay nada
      // que tocar.
      if (!discard || !mounted) return;
    }

    _dismissMenu();
    _fernieMode.add(ExitFernieModeEvent(save: save));
  }

  Future<bool> _confirmDiscard() async {
    final texts = AppLocalizations.of(context);

    final confirmed = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => FernieConfirmDialog(
        title: texts.fernieDiscardTitle,
        message: texts.fernieDiscardMessage,
        confirmLabel: texts.actionDiscard,
      ),
    );

    return confirmed ?? false;
  }

  /// Cambia de herramienta, avisando antes si la región elegida tiene cambios
  /// a medias.
  Future<void> _requestTool(FernieTool tool) async {
    if (_fernieMode.state.tool == tool) return;
    if (!await _confirmLosingDraft()) return;

    _dismissMenu();
    _fernieMode.add(FernieToolChangedEvent(tool));
  }

  /// Elige otra región, o suelta la que hubiera, avisando antes si se pierde
  /// algo.
  Future<void> _requestSelection(int? index) async {
    if (index != null) _pauseForWork();
    if (_fernieMode.state.selectedIndex == index) return;
    if (!await _confirmLosingDraft()) return;

    _dismissMenu();
    _fernieMode.add(RegionSelectedEvent(index));
  }

  /// Pregunta si se pueden tirar los cambios de la región elegida.
  ///
  /// Sin cambios no pregunta nada: avisar de que no se pierde nada sólo
  /// estorbaría en un gesto que se repite mucho.
  Future<bool> _confirmLosingDraft() async {
    if (!_fernieMode.state.hasDraftEdits) return true;

    final texts = AppLocalizations.of(context);

    final discard = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => FernieConfirmDialog(
        title: texts.fernieRegionDiscardTitle,
        message: texts.fernieRegionDiscardMessage,
        confirmLabel: texts.actionDiscard,
      ),
    );

    if (discard != true || !mounted) return false;

    // Descartar es exactamente lo que hace la cruz de la pestaña de la región.
    _fernieMode.add(const RegionEditsDiscardedEvent());
    return true;
  }

  /// Borra la región elegida, avisando de lo que se lleva por delante.
  Future<void> _deleteSelectedRegion(int index) async {
    final texts = AppLocalizations.of(context);

    final confirmed = await _prompts.ask(
      () => showFernDialog<bool, MediaBloc>(
        context: context,
        builder: (_) => FernieConfirmDialog(
          title: texts.fernieRegionDeleteTitle,
          message: texts.fernieRegionDeleteMessage,
          confirmLabel: texts.actionDelete,
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    _dismissMenu();
    _fernieMode.add(RegionDeletedEvent(index));
  }

  /// Abre el menú para cambiarle el fernie a la región elegida.
  void _onReassignRequested(Offset globalPosition) {
    setState(() {
      _isReassigning = true;
      _pendingRect = null;
      _menuPosition = _toStackPosition(globalPosition);
    });
  }

  /// Reproduce o para, si hay algo que reproducir.
  void _togglePlayback() {
    if (!_playback.isPlayable) return;
    _playback.togglePlay();
  }

  /// Para la reproducción antes de tocar nada.
  ///
  /// Marcar y editar se hacen sobre un fotograma quieto: si el contenido siguiera
  /// corriendo, la región acabaría puesta sobre un instante que ya ha pasado. Al
  /// terminar no se reanuda nada, así que el trabajo sigue donde se dejó.
  void _pauseForWork() {
    if (_playback.isPlaying) _playback.pause();
  }

  /// Guarda el rectángulo recién dibujado y abre el menú donde se soltó.
  void _onRegionDrawn(Rect normalized, Offset globalPosition) {
    _pauseForWork();

    setState(() {
      _isReassigning = false;
      _pendingRect = normalized;
      _menuPosition = _toStackPosition(globalPosition);
    });
  }

  /// Si esta propuesta es de lo que se está viendo ahora mismo.
  ///
  /// Las de otro fotograma se esconden, como las regiones marcadas: son el mismo
  /// objeto en otro momento, y verlas todas a la vez llena la imagen de cajas
  /// que se pisan.
  bool _isProposedVisible(ProposedRegion one, int currentFrame) {
    final frameMs = one.frameMs;
    if (frameMs == null) return true;
    if (!_playback.isPlayable) return true;

    return _playback.isSameFrame(frameMs, currentFrame);
  }

  /// Marca el fotograma **entero** como región, sin tener que arrastrarlo.
  ///
  /// Es el caso más repetido y el más incómodo de hacer a mano: cuando lo que
  /// hay en la imagen es justo lo que se quiere marcar, arrastrar de esquina a
  /// esquina obliga a apuntar a dos bordes con precisión para acabar diciendo
  /// «todo».
  ///
  /// Entra por el mismo sitio que el arrastre —el menú de asignar y
  /// [_assignPendingRegion]—, así que hereda el fotograma en el que se está y el
  /// guardado del modo. Como no hay ratón que haya soltado nada, el menú se abre
  /// en el centro del visor.
  void _markWholeFrame() {
    _pauseForWork();

    final box = _stackKey.currentContext?.findRenderObject();
    final size = box is RenderBox && box.hasSize ? box.size : Size.zero;

    setState(() {
      _isReassigning = false;
      _pendingRect = const Rect.fromLTWH(0, 0, 1, 1);
      _menuPosition = Offset(size.width / 2, size.height / 2);
    });
  }

  /// Lleva un punto de la ventana a coordenadas del área del visor, que es
  /// donde se coloca el menú.
  Offset _toStackPosition(Offset globalPosition) {
    final box = _stackKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return globalPosition;

    return box.globalToLocal(globalPosition);
  }

  /// Pulsar fuera del menú descarta la región: un menú del que no se elige nada
  /// es un gesto que se cancela.
  void _dismissMenu() {
    if (!mounted) return;
    if (_pendingRect == null && _menuPosition == null) return;

    setState(() {
      _pendingRect = null;
      _menuPosition = null;
      _isReassigning = false;
    });
  }

  void _assignPendingRegion(FernieEntity fernie) {
    // Se apunta aquí y no en el menú: marcar y reasignar entran los dos por este
    // punto, y los dos cuentan como haberlo usado. Sin esperar, que es una
    // preferencia y no puede hacer esperar a un gesto que se repite tanto.
    unawaited(getIt<PreferencesService>().pushRecentFernie(fernie.id));

    // Reasignar no marca nada nuevo: cambia el fernie de la región elegida y
    // queda en su borrador hasta que se confirme desde la pestaña.
    if (_isReassigning) {
      _fernieMode.add(RegionDraftReassignedEvent(fernie));
      _dismissMenu();
      return;
    }

    final rect = _pendingRect;
    if (rect == null) return;

    _fernieMode.add(
      RegionAssignedEvent(
        rect: rect,
        fernie: fernie,
        // El fotograma sólo se apunta en lo que se reproduce: en una imagen no
        // significa nada, y el mando se queda en reposo.
        frameMs: _playback.isPlayable
            ? _playback.frameStart.inMilliseconds
            : null,
      ),
    );

    // Un aviso, no un impedimento: una región diminuta se guarda igual, pero
    // conviene saber que aporta poco antes de marcar cincuenta así.
    if (rect.width * rect.height < fernieTinyRegionFraction) {
      showFernToast(
        context,
        AppLocalizations.of(context).fernieRegionTiny,
        icon: Symbols.info,
      );
    }

    _dismissMenu();
  }

  // ---------------------------------------------------------------------------
  // Mandos que se esconden solos
  // ---------------------------------------------------------------------------

  /// Los enseña y vuelve a poner en marcha la cuenta atrás. Es lo que hace
  /// cualquier movimiento del ratón sobre el contenido.
  void _wakeControls() {
    if (!_areControlsVisible) setState(() => _areControlsVisible = true);
    _restartHideTimer();
  }

  /// Sobre cuántos mandos está el ratón ahora mismo.
  ///
  /// Un contador y no un sí o un no: al pasar de un mando al de al lado, el aviso
  /// de que se ha entrado en el segundo puede llegar antes que el de que se ha
  /// salido del primero, y con un `bool` el segundo aviso lo dejaría en «fuera»
  /// teniendo el ratón encima.
  int _controlsUnderPointer = 0;

  bool get _isPointerOnControls => _controlsUnderPointer > 0;

  /// El ratón ha entrado o salido de uno de los mandos.
  void _onControlsHover(bool isOver) {
    _controlsUnderPointer += isOver ? 1 : -1;
    if (_controlsUnderPointer < 0) _controlsUnderPointer = 0;

    if (isOver) {
      _wakeControls();
    } else {
      _restartHideTimer();
    }
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();

    // Con el ratón encima de un mando no se cuenta. Quieto sobre un botón no hay
    // movimiento que reinicie la cuenta, así que se desvanecía justo cuando se
    // estaba a punto de pulsarlo. Al salir se vuelve a contar desde el
    // principio.
    if (_isPointerOnControls) return;

    _hideTimer = Timer(viewerControlsHideDelay, () {
      if (!mounted || !_areControlsVisible) return;
      setState(() => _areControlsVisible = false);
    });
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  /// Pone o quita la pantalla completa: la ventana ocupa el monitor entero y se
  /// queda sin barra de título, que es lo que la aplicación no puede hacer sola
  /// estando maximizada.
  void _toggleFullscreen() {
    final isFullscreen = FullscreenService.instance.toggle();
    setState(() => _isFullscreen = isFullscreen);

    final bloc = context.read<MediaBloc>();

    if (isFullscreen) {
      _infoWasOpenBeforeFullscreen = bloc.state.showInfo;
      bloc.add(const SetInfoVisibilityEvent(false));
      return;
    }

    // Si se ha abierto estando a pantalla completa, se queda abierto: lo que
    // se restaura es lo que había, no lo que el usuario acaba de pedir.
    if (bloc.state.showInfo) return;

    bloc.add(SetInfoVisibilityEvent(_infoWasOpenBeforeFullscreen));
    _wakeControls();
  }

  /// Deja el contenido en el portapapeles para poder pegarlo en cualquier otro
  /// sitio, y lo cuenta: copiar no se ve por ningún lado, así que sin el aviso
  /// no habría manera de saber si ha ido bien.
  Future<void> _copyToClipboard(MediaEntity media) async {
    final copied = await ClipboardService.instance.copyMedia(media.path);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    showFernToast(
      context,
      copied ? l10n.viewerCopied : l10n.viewerCopyFailed,
      icon: copied ? Symbols.check : Symbols.error,
    );
  }

  /// El botón de borrar hace una cosa u otra según dónde esté el contenido: lo
  /// que ya está en la papelera se borra del todo (desde ahí no hay a dónde
  /// mandarlo) y el resto se marca o se descarta, según sea definitivo o esté
  /// pendiente de revisar. Los dos casos avisan antes.
  void _delete(
    BuildContext context,
    MediaEntity media, {
    required bool isMarked,
  }) {
    if (isMarked) {
      purgeMediaWithConfirmation(context, media);
      return;
    }

    deleteMediaWithConfirmation(context, media);
  }

  /// Flechas izquierda/derecha para navegar entre contenidos y escape para
  /// salir: primero de la pantalla completa, si se estaba en ella, y sólo
  /// después de la pantalla.
  ///
  /// Solo atendemos pulsaciones (incluidas las repeticiones al mantener la
  /// tecla) y dejamos pasar el resto de eventos para no interferir con los
  /// campos de texto del panel de información, que consumen las flechas antes
  /// de que el evento llegue hasta aquí.
  ///
  /// Con el modo fernie abierto las teclas significan otra cosa, así que se
  /// atienden aparte: las flechas se callan (pasar de contenido perdería el
  /// trabajo) y aparecen deshacer y borrar.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // Hay teclas que se pueden tener pulsadas (pasar de contenido, deshacer) y
    // otras que no: las que abren una pregunta o cambian de estado apilarían un
    // diálogo por repetición, o encenderían y apagarían la reproducción veinte
    // veces por segundo.
    final isRepeat = event is KeyRepeatEvent;

    // El parpadeo es una pista de bienvenida: en cuanto el usuario hace algo,
    // sobra. Se corta **y se lleva a cero**: pararlo a medias dejaba el velo que
    // lo acompaña congelado encima del contenido, y de ahí no se movía.
    _highlightController.stop();
    _highlightController.value = 0;

    if (_fernieMode.state.isFernieMode) {
      return _handleFernieKey(key, isRepeat: isRepeat);
    }

    // Las flechas no están aquí: se atienden antes del reparto por foco, para
    // que pasar de contenido no dependa de qué se haya pulsado antes. Ver
    // [_onArrowKey].

    // El espacio reproduce y para, como en cualquier reproductor. Con un campo
    // de texto delante ni llega: el campo se lo queda para escribir un espacio y
    // el evento no sube hasta aquí.
    if (key == LogicalKeyboardKey.space && _playback.isPlayable) {
      if (!isRepeat) _playback.togglePlay();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape) {
      if (_isFullscreen) {
        _toggleFullscreen();
        return KeyEventResult.handled;
      }
      if (context.canPop()) context.pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handleFernieKey(
    LogicalKeyboardKey key, {
    required bool isRepeat,
  }) {
    if (key == LogicalKeyboardKey.escape) {
      // Con el menú abierto, escape cierra sólo el menú: es lo que está
      // delante, y salir del modo entero sorprendería.
      if (_menuPosition != null) {
        _dismissMenu();
        return KeyEventResult.handled;
      }

      _exitFernieMode(save: false);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.keyZ &&
        HardwareKeyboard.instance.isControlPressed) {
      _fernieMode.add(const UndoLastRegionEvent());
      return KeyEventResult.handled;
    }

    // Con una región elegida, la tecla de borrar la quita: es lo mismo que el
    // botón de su pestaña, con la misma pregunta de por medio, y es el gesto que
    // ya se usa para deshacerse de cualquier otra cosa.
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      final index = _fernieMode.state.selectedIndex;
      if (index == null) return KeyEventResult.ignored;

      // Tenerla pulsada no apila preguntas: la de borrar abre un diálogo, y con
      // la repetición salían tantos como avisos llegaran.
      if (!isRepeat) _deleteSelectedRegion(index);
      return KeyEventResult.handled;
    }

    // Las flechas se comen a propósito: sin esto pasarían al contenido
    // siguiente y se perdería lo marcado.
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // El bloc del modo se pasa a mano a quien lo mira, en vez de colgarlo del
    // árbol con un `BlocProvider`.
    //
    // Sus consumidores son dos y están aquí al lado (esta pantalla y la sección
    // de fernies de su panel), así que el proveedor no ahorraba nada y sí metía
    // un `InheritedWidget` de por medio que hay que desmontar con cuidado al
    // salir del visor.
    return MultiBlocListener(
      listeners: [
        // El contenido que se estaba viendo ha desaparecido (su fichero ya no
        // estaba) y no queda nada más que enseñar: se vuelve a la rejilla.
        BlocListener<MediaBloc, MediaStates>(
          listenWhen: (previous, current) =>
              previous.currentMedia != null && current.currentMedia == null,
          listener: (context, state) {
            if (context.canPop()) context.pop();
          },
        ),
        // Abrir o cerrar el panel de información cuenta como actividad: al
        // cerrarlo los mandos se quedan un rato a la vista en lugar de irse de
        // golpe, que es lo que pasaría si la cuenta atrás hubiera terminado
        // mientras el panel estaba abierto.
        BlocListener<MediaBloc, MediaStates>(
          listenWhen: (previous, current) =>
              previous.showInfo != current.showInfo,
          listener: (context, state) => _wakeControls(),
        ),
        // Cada contenido nuevo trae sus regiones y su medida.
        BlocListener<MediaBloc, MediaStates>(
          listenWhen: (previous, current) =>
              previous.currentMedia?.id != current.currentMedia?.id,
          listener: (context, state) {
            final media = state.currentMedia;
            if (media != null) _onMediaChanged(media);
          },
        ),
        // En qué ha quedado cada pulsación del botón de reconocer.
        BlocListener<SuggestionsBloc, SuggestionsState>(
          bloc: _suggestions,
          listenWhen: (previous, current) =>
              previous.attempts != current.attempts,
          listener: (context, state) => _reportAttempt(state),
        ),
        // En qué ha quedado el reconocimiento de este contenido. El botón se
        // apaga mientras trabaja y se vuelve a encender al acabar, y eso por sí
        // solo no distingue «no ha visto nada» de «está roto».
        BlocListener<SuggestionsBloc, SuggestionsState>(
          bloc: _suggestions,
          listenWhen: (previous, current) =>
              previous.finishedRuns != current.finishedRuns,
          listener: (context, state) => _reportRun(state),
        ),
        // El panel de información se cierra al entrar al modo y se restaura al
        // salir, tal y como estuviera.
        BlocListener<FernieModeBloc, FernieModeState>(
          bloc: _fernieMode,
          listenWhen: (previous, current) => previous.mode != current.mode,
          listener: (context, state) {
            final bloc = context.read<MediaBloc>();

            if (state.isFernieMode) {
              bloc.add(const SetInfoVisibilityEvent(false));
              _regionsFadeController.forward();

              // El resaltado estorba mientras se marca: si seguía en marcha,
              // se corta.
              _highlightController.stop();
              _highlightController.value = 0;
              return;
            }

            bloc.add(SetInfoVisibilityEvent(state.infoWasOpen));
            _regionsFadeController.reverse();

            // La ayuda se va con el modo, así que su aviso de que el ratón ha
            // salido puede no llegar nunca: se deja como estaba.
            _isHintHovered = false;

            // Lo marcado cambia los recuentos de la pantalla de fernies, que
            // es única y sigue montada por detrás.
            getIt<FerniesBloc>().add(const LoadFerniesEvent());
          },
        ),
        // El parpadeo espera a que las regiones estén leídas: hasta entonces
        // no se sabe cuál hay que señalar.
        BlocListener<FernieModeBloc, FernieModeState>(
          bloc: _fernieMode,
          listenWhen: (previous, current) => previous.saved != current.saved,
          listener: (context, state) => _maybeHighlight(state),
        ),
        // Marcar una región le ha puesto al contenido lo que el fernie enlaza,
        // así que el panel tiene que enseñarlo ya. Sin esto había que salir del
        // visor y volver a entrar, y eso hacía dudar de si se había puesto.
        BlocListener<FernieModeBloc, FernieModeState>(
          bloc: _fernieMode,
          listenWhen: (previous, current) =>
              previous.appliedLinks != current.appliedLinks,
          listener: (context, _) => context
              .read<MediaBloc>()
              .add(const RefreshCurrentMediaTagsEvent()),
        ),
      ],
      child: BlocBuilder<MediaBloc, MediaStates>(
        builder: (context, state) =>
            BlocBuilder<FernieModeBloc, FernieModeState>(
              bloc: _fernieMode,
              builder: (context, fernieState) =>
                  _buildScaffold(context, state, fernieState),
            ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    MediaStates state,
    FernieModeState fernieState,
  ) {
    final texts = AppLocalizations.of(context);
    final media = state.currentMedia;

    // El contenido que ya está en la papelera se trata distinto: su botón de
    // borrar es el definitivo y, junto a él, aparece el de devolverlo a su
    // sitio.
    final isMarked = state.isCurrentMediaMarked;

    // Con el panel de información abierto los mandos no se esconden: se está
    // trabajando con el contenido, no mirándolo. En el modo fernie, tampoco:
    // aceptar y cancelar tienen que estar siempre a mano.
    final showControls =
        (_areControlsVisible || state.showInfo || fernieState.isFernieMode) &&
        !_isDrawingRegion;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            // LADO IZQUIERDO: Visor y Controles
            Expanded(
              child: MouseRegion(
                onHover: (_) => _wakeControls(),
                child: Stack(
                  key: _stackKey,
                  children: [
                    // Visor de Media
                    Center(
                      child: Row(
                        children: [
                          _buildNavigationArrow(
                            icon: Symbols.chevron_left,
                            tooltip: texts.viewerPrevious,
                            isVisible:
                                showControls && !fernieState.isFernieMode,
                            isCollapsed: _isFullscreen,
                            onPressed: () => _goTo(next: false),
                          ),
                          // Mientras hay algo en marcha (los detalles del
                          // contenido siguiente, guardar, el corazón) el
                          // indicador de espera se pone sobre el contenido, que
                          // es lo único que va a cambiar: las flechas y la barra
                          // de acciones se quedan fuera del velo, atendiendo.
                          Expanded(
                            child: FernBusyOverlay(
                              isBusy: state.isBusy || fernieState.isBusy,
                              color: Colors.black,
                              radius: AppSizes.radiusSmall,
                              indicatorColor: Colors.white,
                              child: _buildContent(state, fernieState),
                            ),
                          ),
                          _buildNavigationArrow(
                            icon: Symbols.chevron_right,
                            tooltip: texts.viewerNext,
                            isVisible:
                                showControls && !fernieState.isFernieMode,
                            isCollapsed: _isFullscreen,
                            onPressed: () => _goTo(next: true),
                          ),
                        ],
                      ),
                    ),

                    // A pantalla completa las flechas se ponen **encima** del
                    // contenido en vez de a los lados. Ahí el contenido va de
                    // borde a borde, y quitarle cien píxeles para hacerles sitio
                    // es justo lo contrario de lo que se pide al entrar; pero
                    // sin ellas no hay forma de pasar al siguiente sin salir.
                    //
                    // Los huecos de la fila siguen ahí, encogidos: sacar y
                    // volver a meter hijos en esa fila cambia de sitio al
                    // `Expanded` del contenido, y eso rehace el reproductor de
                    // vídeo entero.
                    if (_isFullscreen && !fernieState.isFernieMode) ...[
                      _buildOverlayArrow(
                        icon: Symbols.chevron_left,
                        tooltip: texts.viewerPrevious,
                        isLeading: true,
                        isVisible: showControls,
                        onPressed: () => _goTo(next: false),
                      ),
                      _buildOverlayArrow(
                        icon: Symbols.chevron_right,
                        tooltip: texts.viewerNext,
                        isLeading: false,
                        isVisible: showControls,
                        onPressed: () => _goTo(next: true),
                      ),
                    ],

                    // Panel de herramientas, sólo en el modo de marcar.
                    if (fernieState.isFernieMode)
                      _buildToolPanel(fernieState, isVisible: showControls),

                    // Y la línea de tiempo, para el contenido que se mueve.
                    // Es la misma barra mirando y marcando: lo que cambia son
                    // los botones de los lados.
                    _buildTimeline(fernieState, isVisible: showControls),

                    // Barra Superior de Acciones
                    _buildActionBar(
                      media: media,
                      isMarked: isMarked,
                      isVisible: showControls,
                      fernieState: fernieState,
                    ),

                    // El menú que asigna la región recién marcada, donde se
                    // soltó el ratón.
                    if (_menuPosition case final position?)
                      Positioned.fill(
                        child: FernContextMenu(
                          position: position,
                          onDismiss: _dismissMenu,
                          child: AssignRegionMenu(
                            onSelected: _assignPendingRegion,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // LADO DERECHO: Panel de Información
            _InfoPanel(
              isOpen: state.showInfo,
              isReviewing: widget.isReviewing,
              fernieMode: _fernieMode,
              suggestions: _suggestions,
            ),
          ],
        ),
      ),
    );
  }

  /// El contenido con su capa de regiones encima.
  ///
  /// La capa va siempre, también fuera del modo: apagada no atiende al ratón y
  /// sólo dibuja, que es lo que hace falta para el parpadeo de bienvenida.
  ///
  /// Ojo con envolver esto en un `BlocBuilder` con `buildWhen`: el modo fernie
  /// no cambia el contenido, así que un filtro por la ruta del fichero dejaría
  /// esta rama congelada y la capa de selección no llegaría a encenderse nunca.
  /// Se construye con el estado que ya trae el `build` de la pantalla.
  Widget _buildContent(MediaStates state, FernieModeState fernieState) {
    final media = state.currentMedia;

    if (media == null) {
      // Todavía no hay nada que enseñar: se están leyendo los detalles del
      // contenido.
      return const _CarouselTransition(
        isForward: true,
        child: Center(
          key: ValueKey('viewer-loading'),
          child: FernProgressIndicator(color: Colors.white),
        ),
      );
    }

    final viewer = MediaViewer(
      key: ValueKey(media.path),
      path: media.path,
      controller: _transformation,
      // En el modo fernie los gestos los reparte la capa de selección.
      interactive: !fernieState.isFernieMode,
      playback: _playback,
      // Se entra a marcar sobre lo que se estaba viendo, no sobre lo que siga
      // corriendo.
      paused: fernieState.isFernieMode,
      // Y en el modo de marcar el contenido se recorre fotograma a fotograma,
      // que es lo que cambia como se trata un GIF.
      stepped: fernieState.isFernieMode,
      // Si el fichero ya no está, su fila sale de la base de datos y el visor
      // pasa al siguiente contenido.
      onLoadFailed: () =>
          context.read<MediaBloc>().add(MediaLoadFailedEvent(media.id)),
    );

    return _CarouselTransition(
      isForward: _isForward,
      child: KeyedSubtree(
        key: ValueKey(media.path),
        child: _buildRegionLayer(fernieState, viewer),
      ),
    );
  }

  /// Si [view] se pinta ahora mismo.
  ///
  /// Lo que no lleva fotograma apuntado es de una imagen y se ve siempre. Lo
  /// demás sólo en su fotograma, comparando números de fotograma y no
  /// milisegundos: el reproductor devuelve el instante con las micras que le da
  /// la pista, y un margen en milisegundos deja fuera lo que es del mismo sitio.
  ///
  /// Mientras suena no se ve ninguna: allí lo que hay es el recorrido, que pasa
  /// por todas ellas. Alternar entre la región y el recorrido en cada clave sería
  /// un parpadeo de dos dibujos distintos. La elegida se queda, que es sobre la
  /// que se está trabajando.
  bool _isRegionVisible(
    RegionView view,
    int currentFrame, {
    required bool isSelected,
  }) {
    final frameMs = view.frameMs;
    if (frameMs == null) return true;

    // Sin nada que reproducir no hay fotogramas que distinguir. Es el caso de un
    // GIF fuera del modo de marcar: se anima solo y no se recorre, así que sus
    // regiones se ven todas —lo que hace falta, por ejemplo, para señalar una al
    // llegar desde la rejilla de fernies.
    if (!_playback.isPlayable) return true;

    if (_playback.isPlaying) return isSelected;

    return _playback.isSameFrame(frameMs, currentFrame);
  }

  /// Medio fotograma, que es lo que separa un instante del de al lado.
  ///
  /// Sale del mando y no de una constante: depende de a cuántos fotogramas por
  /// segundo vaya el contenido. Con un margen fijo y ancho se verían a la vez
  /// las regiones de medio segundo alrededor, y marcar fotograma a fotograma
  /// sería imposible.
  int get _frameToleranceMs => _playback.isPlayable
      ? _playback.frameTolerance.inMilliseconds
      : fernieFrameTolerance.inMilliseconds;

  /// Por dónde va cada fernie en este instante.
  ///
  /// Se dibuja una caja por fernie que recorre las regiones que tiene marcadas,
  /// interpolando entre ellas: cada región es una clave, igual que en un vídeo.
  ///
  /// Sólo existe **entre la primera clave y la última**. Fuera de ahí el fernie
  /// no está marcado en ninguna parte y no se pinta nada, que es lo que
  /// distingue este recorrido de una caja fija encima de todo el contenido.
  ///
  /// Es lo que hace útil el botón de reproducir del modo: sirve para comprobar
  /// si lo marcado acompaña a lo que se mueve debajo.
  /// La caja de la sugerencia que el panel está señalando, si toca enseñarla.
  ///
  /// En contenido que se mueve sólo se enseña si es de este fotograma: una caja
  /// dibujada sobre el fotograma equivocado dice que el modelo vio algo donde no
  /// lo vio.
  List<RegionVisual> _spotlightVisuals(int currentFrame) {
    return [
      for (final one in _spotlight.spotted)
        if (_isSpottedHere(one, currentFrame))
          RegionVisual(
            rect: Rect.fromLTWH(one.box.x, one.box.y, one.box.w, one.box.h),
            label: one.label,
            isDimmed: true,
          ),
    ];
  }

  /// Si esta detección es de lo que se está viendo ahora mismo.
  bool _isSpottedHere(SpottedBox one, int currentFrame) {
    final frameMs = one.frameMs;
    if (frameMs == null) return true;
    if (!_playback.isPlayable) return true;

    return _playback.isSameFrame(frameMs, currentFrame);
  }

  List<RegionVisual> _buildTracks(List<RegionView> views, int currentFrame) {
    // Sólo mientras suena. Parado, el recorrido es un estorbo: se está marcando
    // fotograma a fotograma y lo que hace falta es el fotograma limpio.
    if (!_playback.isPlayable || !_playback.isPlaying) return const [];

    // Cada fernie, con sus momentos marcados.
    final byFernie = <int, List<TrackKeyframe>>{};
    final labels = <int, String>{};

    for (final view in views) {
      final frameMs = view.frameMs;
      if (frameMs == null) continue;

      byFernie
          .putIfAbsent(view.fernieId, () => [])
          .add(TrackKeyframe(rect: view.rect, frameMs: frameMs));
      labels[view.fernieId] = view.label;
    }

    final tracks = <RegionVisual>[];

    for (final entry in byFernie.entries) {
      final track = RegionTrack(entry.value);

      // El margen es de los dos extremos: sin él, la primera clave y la última
      // se verían medio fotograma y el recorrido entraría y saldría cortado.
      final rect = track.rectAt(currentFrame, toleranceMs: _frameToleranceMs);
      if (rect == null) continue;

      tracks.add(RegionVisual(rect: rect, label: labels[entry.key]));
    }

    return tracks;
  }

  /// Lo marcado en el último fotograma anterior a éste.
  ///
  /// Se enseña apagado y se puede pulsar: al hacerlo se copia a este fotograma,
  /// que es la forma de seguir a un objeto que se mueve poco sin volver a
  /// dibujarle la caja desde cero cada vez.
  ///
  /// No aparece mientras suena: allí lo que se ve es el recorrido.
  List<RegionView> _onionViews(List<RegionView> views, int currentFrame) {
    if (!_isOnionSkinOn || !_playback.isPlayable || _playback.isPlaying) {
      return const [];
    }

    // El fotograma marcado más cercano por detrás. Se cogen todas sus regiones,
    // no una por fernie: lo que se copia es lo que había allí.
    int? previous;

    for (final view in views) {
      final frameMs = view.frameMs;
      if (frameMs == null || frameMs >= currentFrame) continue;

      if (previous == null || frameMs > previous) previous = frameMs;
    }

    if (previous == null) return const [];

    return [
      for (final view in views)
        if (view.frameMs == previous) view,
    ];
  }

  /// Copia al fotograma de ahora una región del papel cebolla.
  ///
  /// Nace como cualquier otra región recién marcada: entra en lo pendiente de
  /// guardar y se queda elegida, lista para ajustarla con la herramienta de
  /// editar.
  void _copyFromOnionSkin(RegionView onion) {
    final fernie = _fernieOf(onion.fernieId);
    if (fernie == null) return;

    _pauseForWork();

    final views = _fernieMode.state.views;
    final current = _playback.frameStart;

    // Con el arrastre puesto, la región se deja también en cada fotograma de en
    // medio: es lo mismo que poner dos claves con el mismo valor, que deja
    // quieto todo lo que hay entre ellas.
    final instants = _isDraggingRegions
        ? _playback.framesBetween(
            Duration(milliseconds: onion.frameMs ?? 0),
            current,
          )
        : <Duration>[current];

    if (instants.isEmpty) return;

    for (final instant in instants) {
      _fernieMode.add(
        RegionAssignedEvent(
          rect: onion.rect,
          fernie: fernie,
          frameMs: instant.inMilliseconds,
        ),
      );
    }

    // La última en marcarse es la de este fotograma, y es la que se queda
    // elegida: es sobre la que se sigue trabajando.
    _fernieMode.add(RegionSelectedEvent(views.length + instants.length - 1));
  }

  FernieEntity? _fernieOf(int id) {
    for (final fernie in _fernieMode.state.fernies) {
      if (fernie.id == id) return fernie;
    }
    return null;
  }

  Widget _buildRegionLayer(FernieModeState fernieState, Widget viewer) {
    final views = fernieState.visibleViews;
    final currentFrame = _playback.position.inMilliseconds;
    final onionViews = _onionViews(views, currentFrame);

    // Se repinta con las dos animaciones y con la reproducción: el resaltado
    // mueve el velo, el desvanecido enseña y esconde las regiones, y la posición
    // decide cuáles son de este fotograma.
    // El orden de la lista manda: primero las regiones de verdad, luego el
    // papel cebolla, luego lo que el modelo propone y al final lo señalado. De
    // ahí sale a qué corresponde cada índice al pulsarlo.
    final proposedFrom = views.length + onionViews.length;
    final spottedFrom = proposedFrom + fernieState.proposed.length;

    return AnimatedBuilder(
      animation: Listenable.merge(
        [_highlight, _regionsFade, _playback, _spotlight],
      ),
      builder: (context, _) {
        // Dentro del constructor y no fuera: lo que se está señalando cambia
        // con el ratón, y calcularlo antes deja al dibujo con el valor que
        // había cuando se montó la pantalla, que es siempre «nada».
        //
        // Fuera del modo fernie las regiones se pintan con opacidad cero, así
        // que una caja más en la lista no se vería. El resaltado sí manda sobre
        // esa opacidad —es lo que hace visible una región al llegar desde la
        // rejilla de fernies—, y es por donde tiene que ir ésta.
        final spotted = _spotlightVisuals(currentFrame);
        // Los índices que ocupan al final de la lista, para poder resaltarlos
        // todos: son cajas de mirar y tienen que verse aunque las regiones estén
        // escondidas.
        final spottedIndexes = {
          for (var offset = 0; offset < spotted.length; offset++)
            spottedFrom + offset,
        };

        return FernRegionSelectionLayer(
        enabled: fernieState.isFernieMode,
        tool: fernieState.tool == FernieTool.edit
            ? FernRegionTool.edit
            : FernRegionTool.mark,
        selectedIndex: fernieState.selectedIndex,
        // Puede faltar: mientras no se haya medido el fichero, la capa no
        // dibuja ni deja marcar, pero el zoom y el doble clic siguen siendo
        // suyos.
        contentSize: _contentSize,
        controller: _transformation,
        minRegionFraction: fernieMinRegionFraction,
        minScale: viewerMinZoomScale,
        maxScale: fernieMaxZoomScale,
        regions: [
          for (final (index, view) in views.indexed)
            RegionVisual(
              rect: view.rect,
              label: view.label,
              // Las de otro fotograma se esconden en vez de apilarse: son el
              // mismo objeto en otro momento, y verlas todas a la vez llena la
              // imagen de cajas que se pisan.
              isVisible: _isRegionVisible(
                view,
                currentFrame,
                isSelected: index == fernieState.selectedIndex,
              ),
            ),
          // El papel cebolla va detrás, para que los índices de lo de arriba no
          // se muevan: lo que pase de ahí es una copia por hacer, no una región.
          for (final onion in onionViews)
            RegionVisual(rect: onion.rect, label: onion.label, isDimmed: true),
          // Lo que el modelo propone: dibujado y **sin marcar**, con su
          // porcentaje en la pestaña. Con cuatro rectángulos delante, saber cuál
          // es el del 94 % y cuál el del 51 % es lo que permite elegir bien.
          for (final one in fernieState.proposed)
            RegionVisual(
              rect: one.rect,
              label: '${one.label} '
                  '${AppLocalizations.of(context).suggestionConfidence(
                    (one.confidence * 100).round(),
                  )}',
              isDimmed: true,
              isVisible: _isProposedVisible(one, currentFrame),
            ),
          // Dónde vio el modelo lo que el panel está señalando. Va al final por
          // lo mismo que el papel cebolla: es una caja de mirar, no una región,
          // y no puede moverle el índice a las que sí lo son.
          ...spotted,
        ],
        previews: _buildTracks(views, currentFrame),
        // Señalar una detección manda sobre el resaltado que venga de la
        // rejilla de fernies: es lo que el usuario está mirando ahora mismo.
        highlightedIndexes: spotted.isNotEmpty
            ? spottedIndexes
            : {?_highlightIndexIn(fernieState)},
        highlightIntensity: spotted.isNotEmpty ? 1 : _highlight.value,
        regionsOpacity: _regionsFade.value,
        // Un toque sobre el contenido reproduce y para, como en cualquier
        // reproductor. Sólo mirando: marcando, un toque significa otra cosa.
        onTap: fernieState.isFernieMode ? null : _togglePlayback,
        onRegionDrawn: _onRegionDrawn,
        onDrawingChanged: (isDrawing) {
          // En cuanto se empieza a arrastrar, el contenido se para: se está
          // marcando sobre este fotograma y no sobre el que venga.
          if (isDrawing) _pauseForWork();

          if (!mounted || _isDrawingRegion == isDrawing) return;
          setState(() => _isDrawingRegion = isDrawing);
        },
        onSelectionRequested: (index) {
          if (index != null && index >= spottedFrom) {
            // Lo señalado es una caja de mirar: pulsarla no hace nada.
            return;
          }

          // Lo que el modelo propone se acepta al pulsarlo: es la forma de
          // quedarse con los que estén bien y dejar los demás.
          if (index != null && index >= proposedFrom) {
            _fernieMode.add(ProposedRegionAcceptedEvent(index - proposedFrom));
            return;
          }

          // Lo que cae más allá de las regiones de verdad es papel cebolla:
          // pulsarlo no elige nada, copia.
          if (index != null && index >= views.length) {
            _copyFromOnionSkin(onionViews[index - views.length]);
            return;
          }

          _requestSelection(index);
        },
        onReassignRequested: _onReassignRequested,
        onDraftChanged: (rect) =>
            _fernieMode.add(RegionDraftResizedEvent(rect)),
        selectionOverlayBuilder: (context, _) =>
            _buildRegionTab(fernieState.selectedIndex!),
        child: viewer,
        );
      },
    );
  }

  /// Una de las dos flechas de navegación. Se desvanecen con la barra: el
  /// teclado sigue pasando de un contenido a otro aunque no estén a la vista.
  ///
  /// A pantalla completa no ocupan ni sitio: allí lo que se pide es el contenido
  /// de borde a borde, y desvanecidas seguirían guardándose su hueco a los
  /// lados. Se encogen **sin salirse de la fila**: quitarlas de ella corría al
  /// visor un puesto, Flutter lo daba por otro widget y rehacía el reproductor
  /// entero, con lo que el vídeo perdía de golpe la línea de tiempo, el espacio
  /// y el clic.
  Widget _buildNavigationArrow({
    required IconData icon,
    required String tooltip,
    required bool isVisible,
    required bool isCollapsed,
    required VoidCallback onPressed,
  }) {
    return FernFadingControls(
      isVisible: isVisible,
      onHoverChanged: _onControlsHover,
      child: isCollapsed
          ? const SizedBox.shrink()
          : IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              iconSize: AppSizes.iconExtraLarge,
              color: Colors.white,
              icon: Icon(icon),
            ),
    );
  }

  /// Una flecha de pasar de contenido, puesta sobre el propio contenido.
  ///
  /// Es la de pantalla completa. Lleva su propia sombra por detrás porque encima
  /// de una imagen clara un icono blanco no se ve, y ahí no hay margen gris que
  /// haga de fondo como en la ventana.
  Widget _buildOverlayArrow({
    required IconData icon,
    required String tooltip,
    required bool isLeading,
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      left: isLeading ? AppSpacing.l : null,
      right: isLeading ? null : AppSpacing.l,
      top: 0,
      bottom: 0,
      child: Center(
        child: FernFadingControls(
          isVisible: isVisible,
          onHoverChanged: _onControlsHover,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: fullscreenArrowScrimOpacity),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              iconSize: AppSizes.iconExtraLarge,
              color: Colors.white,
              icon: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }

  /// La línea de tiempo del modo fernie, pegada al borde de abajo.
  ///
  /// Sólo aparece con contenido que se mueve: de eso se encarga ella misma, que
  /// se queda en nada cuando no hay nada que recorrer. Es la misma barra en los
  /// dos modos; mirando lleva play, saltos de cinco segundos y repetición, y
  /// marcando pasa a ir de fotograma en fotograma.
  Widget _buildTimeline(
    FernieModeState fernieState, {
    required bool isVisible,
  }) {
    return Positioned(
      left: AppSpacing.xxl,
      right: AppSpacing.xxl,
      bottom: AppSpacing.l,
      child: FernFadingControls(
        isVisible: isVisible,
        onHoverChanged: _onControlsHover,
        child: MediaTimeline(
          playback: _playback,
          // Coger la barra para o no según lo que el usuario tenga puesto. En
          // el modo de marcar la barra no lo mira: allí se para siempre.
          pauseOnSeek:
              context.watch<SettingsBloc>().state.settings.pauseWhenSeeking,
          mode: fernieState.isFernieMode
              ? MediaTimelineMode.marking
              : MediaTimelineMode.viewing,
          // Las muescas son del trabajo, así que fuera del modo no pintan nada.
          marks: fernieState.isFernieMode
              ? _timelineMarks(fernieState.visibleViews)
              : const [],
          isOnionSkinOn: _isOnionSkinOn,
          onToggleOnionSkin: () =>
              setState(() => _isOnionSkinOn = !_isOnionSkinOn),
          isDraggingRegions: _isDraggingRegions,
          onToggleDragRegions: () =>
              setState(() => _isDraggingRegions = !_isDraggingRegions),
          // Se guarda al soltar y no en cada pixel: mientras se arrastra ya se
          // oye, y esto es solo para el volumen que sobrevive al cierre.
          onVolumeCommitted: (value) => unawaited(
            getIt<PreferencesService>().setViewerVolume(value),
          ),
          // Con el panel abierto, los mandos del visor no se desvanecen: el
          // panel vive fuera de ellos y se quedaria flotando sobre un boton que
          // ya no esta. Es el mismo contador que usa el raton al pasar por
          // encima, asi que las dos cosas se suman sin pisarse.
          onVolumePanelChanged: _onControlsHover,
        ),
      ),
    );
  }

  /// Los instantes del contenido que ya tienen alguna región marcada.
  ///
  /// Se enseñan como muescas en la línea de tiempo, y al pasar el cursor por
  /// una salen los fernies que hay en ella. Es lo que permite ver de un vistazo
  /// dónde hay trabajo hecho y de quién es, en vez de buscarlo abriendo
  /// fotogramas a ciegas.
  List<FernieMark> _timelineMarks(List<RegionView> views) {
    final byInstant = <int, List<FernieEntity>>{};

    for (final view in views) {
      if (view.frameMs case final frameMs?) {
        final fernie = _fernieOf(view.fernieId);
        if (fernie == null) continue;

        // Un fernie una vez por muesca: dos regiones suyas en el mismo
        // fotograma son dos cajas, pero sigue siendo el mismo nombre.
        final atInstant = byInstant.putIfAbsent(frameMs, () => []);
        if (atInstant.any((other) => other.id == fernie.id)) continue;

        atInstant.add(fernie);
      }
    }

    return [
      for (final frameMs in byInstant.keys.toList()..sort())
        FernieMark(
          at: Duration(milliseconds: frameMs),
          fernies: byInstant[frameMs]!,
        ),
    ];
  }

  /// La columna de herramientas del modo fernie, pegada al borde izquierdo.
  ///
  /// Va aparte de la barra de arriba porque no son acciones sino un estado: lo
  /// que dice con qué se está trabajando, y que se queda puesto hasta que se
  /// cambie. Se esconde y se enseña con el resto de mandos.
  Widget _buildToolPanel(
    FernieModeState fernieState, {
    required bool isVisible,
  }) {
    final l10n = AppLocalizations.of(context);

    return Positioned(
      left: AppSpacing.s,
      top: 0,
      bottom: 0,
      child: Center(
        child: FernFadingControls(
          isVisible: isVisible,
          onHoverChanged: _onControlsHover,
          child: Material(
            color: context.colors.scrim.withValues(alpha: viewerShadeOpacity),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTool(
                    tooltip: l10n.fernieToolSelect,
                    icon: Symbols.crop_free,
                    tool: FernieTool.mark,
                    current: fernieState.tool,
                  ),
                  _buildTool(
                    tooltip: l10n.fernieToolEdit,
                    icon: Symbols.edit,
                    tool: FernieTool.edit,
                    current: fernieState.tool,
                  ),

                  // El fotograma entero. **No es una herramienta**: no cambia lo
                  // que hace el ratón, hace algo y se acaba — por eso no se
                  // queda encendido ni se pinta con el acento.
                  IconButton(
                    tooltip: l10n.fernieToolWholeFrame,
                    onPressed: _markWholeFrame,
                    icon: const Icon(
                      Symbols.select_all,
                      color: Colors.white,
                      size: AppSizes.iconExtraLarge,
                      weight: viewerIconWeight,
                    ),
                  ),

                  // Aceptar todo lo que el modelo propone. Sólo sale cuando
                  // hay algo propuesto: el caso normal es que acierte, y con
                  // doce coches bien detectados pulsarlos de uno en uno es el
                  // trabajo que esto venía a ahorrar.
                  if (fernieState.proposed.isNotEmpty)
                    IconButton(
                      tooltip: l10n.fernieAcceptAllProposed(
                        fernieState.proposed.length,
                      ),
                      onPressed: () => _fernieMode
                          .add(const AllProposedRegionsAcceptedEvent()),
                      icon: const Icon(
                        Symbols.done_all,
                        color: Colors.white,
                        size: AppSizes.iconExtraLarge,
                        weight: viewerIconWeight,
                      ),
                    ),

                  // Deshacer no es una herramienta: no cambia lo que hace el
                  // ratón, hace algo y se acaba. Va en el mismo panel porque es
                  // donde se está mirando mientras se marca, pero separado por
                  // una raya para que no se lea como una tercera herramienta.
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xs,
                    ),
                    child: Divider(
                      height: AppSizes.borderThin,
                      thickness: AppSizes.borderThin,
                      color: Colors.white24,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.fernieUndo,
                    // Sin nada marcado en esta sesión no hay nada que deshacer.
                    onPressed: fernieState.pending.isEmpty
                        ? null
                        : () => _fernieMode.add(const UndoLastRegionEvent()),
                    icon: Icon(
                      Symbols.undo,
                      color: fernieState.pending.isEmpty
                          ? Colors.white.withValues(
                              alpha: pillButtonDisabledOpacity,
                            )
                          : Colors.white,
                      size: AppSizes.iconExtraLarge,
                      weight: viewerIconWeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Un botón del panel de herramientas. La que está puesta se pinta con el
  /// color de acento; las demás, en blanco como el resto de mandos.
  Widget _buildTool({
    required String tooltip,
    required IconData icon,
    required FernieTool tool,
    required FernieTool current,
  }) {
    final isCurrent = tool == current;

    return IconButton(
      tooltip: tooltip,
      onPressed: () => _requestTool(tool),
      icon: Icon(
        icon,
        color: isCurrent ? context.colors.terciary : Colors.white,
        size: AppSizes.iconExtraLarge,
        weight: viewerIconWeight,
        fill: isCurrent ? 1 : 0,
      ),
    );
  }

  /// La pestaña que sale de la región elegida: borrarla, tirar sus cambios o
  /// darlos por buenos.
  ///
  /// Los dos últimos hacen lo mismo que los de la barra de arriba pero para una
  /// sola región, y por eso llevan los mismos iconos: lo que se aprende en un
  /// sitio vale en el otro.
  Widget _buildRegionTab(int index) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: context.colors.scrim.withValues(alpha: viewerShadeOpacity),
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: SizedBox(
        width: regionTabWidth,
        height: regionTabHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRegionTabAction(
              tooltip: l10n.fernieRegionDelete,
              icon: Symbols.delete,
              onPressed: () => _deleteSelectedRegion(index),
            ),
            _buildRegionTabAction(
              tooltip: l10n.fernieRegionCancel,
              icon: Symbols.close,
              onPressed: () =>
                  _fernieMode.add(const RegionEditsDiscardedEvent()),
            ),
            _buildRegionTabAction(
              tooltip: l10n.fernieRegionConfirm,
              icon: Symbols.check,
              color: context.colors.terciary,
              onPressed: () =>
                  _fernieMode.add(const RegionEditsConfirmedEvent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionTabAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(),
      icon: Icon(
        icon,
        color: color,
        size: AppSizes.iconMedium,
        weight: viewerIconWeight,
      ),
    );
  }

  /// La barra de acciones, con el sombreado que la acompaña.
  ///
  /// El sombreado es el mismo recurso que usan las celdas de la rejilla: sin él
  /// los botones blancos desaparecen sobre un contenido claro. Va dentro del
  /// mismo desvanecido que los botones porque es suyo: sombrear un contenido que
  /// ya no tiene nada encima no tendría sentido.
  ///
  /// En el modo fernie se queda con dos botones y nada más: lo único que se
  /// puede hacer con lo marcado es quedárselo o tirarlo.
  Widget _buildActionBar({
    required MediaEntity? media,
    required bool isMarked,
    required bool isVisible,
    required FernieModeState fernieState,
  }) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FernFadingControls(
        isVisible: isVisible,
        onHoverChanged: _onControlsHover,
        child: Stack(
          children: [
            _buildShade(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Row(
                children: fernieState.isFernieMode
                    ? _fernieActions()
                    : _viewingActions(media: media, isMarked: isMarked),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fernieActions() {
    final l10n = AppLocalizations.of(context);

    return [
      _buildAction(
        tooltip: l10n.fernieModeCancel,
        icon: Symbols.close,
        onPressed: () => _exitFernieMode(save: false),
      ),
      const Spacer(),
      // La ayuda del reparto de gestos va aquí y no en un diálogo: es lo que hay
      // que saber justo mientras se está marcando, y en cuanto se aprende deja
      // de leerse.
      Flexible(child: _buildFernieHint(l10n.fernieModeHint)),
      const Spacer(),
      _buildAction(
        tooltip: l10n.fernieModeAccept,
        icon: Symbols.check,
        color: context.colors.terciary,
        onPressed: () => _exitFernieMode(save: true),
      ),
    ];
  }

  /// La ayuda del reparto de gestos, que se aparta en cuanto estorba.
  ///
  /// Nunca atiende a las pulsaciones (de ahí el `IgnorePointer`): lo que hay
  /// debajo es la pestaña de la región elegida, y un texto no puede quedarse con
  /// los clics que van a un botón. Lo que sí escucha es por dónde anda el ratón,
  /// para desvanecerse mientras esté encima.
  ///
  /// El `translucent` es lo que hace que las dos cosas convivan: el nodo recibe
  /// el paso del ratón, pero no cuenta como acierto, así que la pila sigue
  /// buscando debajo y el clic llega a su sitio.
  Widget _buildFernieHint(String hint) {
    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: (_) => _setHintHovered(true),
      onExit: (_) => _setHintHovered(false),
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _isHintHovered ? 0 : 1,
          duration: viewerControlsFadeDuration,
          child: Text(
            hint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  void _setHintHovered(bool value) {
    if (!mounted || _isHintHovered == value) return;

    setState(() => _isHintHovered = value);
  }

  List<Widget> _viewingActions({
    required MediaEntity? media,
    required bool isMarked,
  }) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = media?.isFavorite ?? false;

    // Lo que todavía no se ha confirmado no se puede marcar como favorito.
    //
    // Se mira si el contenido es definitivo y no de dónde se ha llegado: un
    // parámetro de navegación se olvida en cuanto alguien abra el visor desde
    // otro sitio, y esto es verdad venga de donde venga. Marcar favorito algo
    // que a lo mejor se descarta en el paso siguiente no lleva a ninguna parte:
    // la pantalla de favoritos sólo enseña lo definitivo, así que la marca se
    // haría y no se vería.
    final isPending = media != null && !media.isImported;

    // Marcar va sobre cualquier contenido: en lo que se mueve, la línea de
    // tiempo es la que deja elegir el fotograma.
    final canMark = media != null;

    // La barra va en bloques separados por aire, y el orden no es casual.
    //
    // A la izquierda, salir. A la derecha lo que se hace **con** el contenido,
    // de lo que se deshace con otro clic a lo que no tiene vuelta atrás, con un
    // hueco antes del último bloque: borrar estaba encajado entre restablecer y
    // el corazón, que es donde un clic de más cuesta caro.
    //
    // Dentro de la derecha: primero lo que se marca (favorito, NSFW), que es lo
    // que más se usa; después las herramientas que abren algo (marcar regiones,
    // reconocer); después lo que cambia cómo se ve (información, pantalla
    // completa); y al final lo que saca el contenido de aquí (compartir,
    // restablecer, borrar).
    return [
      _buildAction(
        tooltip: l10n.viewerBack,
        icon: Symbols.arrow_back,
        onPressed: () => context.pop(),
      ),
      const Spacer(),

      // --- Lo que se marca ------------------------------------------------
      if (!isPending)
        _buildAction(
          // El corazón se rellena al marcar como favorito: relleno o vacío se
          // distingue de un vistazo, que es más de lo que decía el color por sí
          // solo.
          tooltip: isFavorite ? l10n.viewerUnfavorite : l10n.viewerFavorite,
          icon: AppIcons.favorite,
          fill: isFavorite ? 1 : 0,
          color: isFavorite ? context.colors.terciary : Colors.white,
          onPressed: media == null
              ? null
              : () => context.read<MediaBloc>().add(const ToggleFavoriteEvent()),
        ),
      // Esconder esto detrás del filtro NSFW, o sacarlo. Es el único sitio donde
      // se puede quitar la marca de uno solo: la barra de la rejilla marca en
      // tanda pero no sabe cómo está cada contenido, y aquí sí se sabe.
      //
      // Sólo con contraseña puesta, como el resto: sin ella marcar no escondería
      // nada.
      if (media != null && getIt<NsfwModeService>().isConfigured)
        _buildAction(
          tooltip: _isMarkedNsfw(media)
              ? l10n.mediaNsfwUnmark
              : l10n.mediaNsfwMark,
          icon: AppIcons.hidden,
          fill: _isMarkedNsfw(media) ? 1 : 0,
          color: _isMarkedNsfw(media) ? context.colors.terciary : Colors.white,
          onPressed: () => context.read<MediaBloc>().add(
                SetMediaNsfwEvent(
                  mediaId: media.id,
                  isNsfw: !_isMarkedNsfw(media),
                ),
              ),
        ),

      // --- Herramientas ---------------------------------------------------
      const SizedBox(width: AppSpacing.m),
      // Marcar regiones se pide desde aquí, junto al resto de lo que se puede
      // hacer con el contenido. Antes estaba escondido dentro del panel de
      // información, que hay que abrir para verlo.
      //
      // Con el icono de los fernies, que es lo que se va a marcar. Llevaba el de
      // recortar, y en esta barra ése es prácticamente el mismo dibujo que el de
      // pantalla completa: dos botones iguales a dos sitios de distancia.
      _buildAction(
        tooltip: l10n.fernieModeTooltip,
        icon: AppIcons.fernie,
        onPressed: canMark ? _enterFernieMode : null,
      ),
      _buildRecognizeAction(enabled: media != null),

      // --- Lo que cambia cómo se ve ----------------------------------------
      const SizedBox(width: AppSpacing.m),
      _buildAction(
        tooltip: l10n.viewerInfoTooltip,
        icon: AppIcons.info,
        onPressed: () => context.read<MediaBloc>().add(const ToggleInfoEvent()),
      ),
      // La pantalla completa la da el sistema, así que sólo se ofrece donde la
      // aplicación sabe pedirla.
      if (FullscreenService.instance.isSupported)
        _buildAction(
          tooltip: _isFullscreen
              ? l10n.viewerExitFullscreen
              : l10n.viewerFullscreen,
          icon: _isFullscreen ? Symbols.fullscreen_exit : Symbols.fullscreen,
          onPressed: _toggleFullscreen,
        ),

      // --- Lo que saca el contenido de aquí --------------------------------
      const SizedBox(width: AppSpacing.xl),
      _buildAction(
        tooltip: l10n.viewerShare,
        icon: Symbols.ios_share,
        onPressed: media == null ? null : () => _copyToClipboard(media),
      ),
      // Lo que ya está en la papelera se restablece desde aquí: es la otra
      // salida que tiene, y sin ella habría que volver a la rejilla para
      // deshacerlo.
      if (isMarked)
        _buildAction(
          tooltip: l10n.actionRestore,
          // El reloj con la flecha —`restore`— es el mismo dibujo que el de «hace
          // tanto» de la pantalla de importación, y aquí no se vuelve atrás en el
          // tiempo: se saca algo de la papelera.
          icon: Symbols.restore_from_trash,
          onPressed: media == null
              ? null
              : () => context.read<MediaBloc>().add(RestoreMediaEvent(media)),
        ),
      _buildAction(
        tooltip: l10n.actionDelete,
        icon: AppIcons.deleted,
        onPressed: media == null
            ? null
            : () => _delete(context, media, isMarked: isMarked),
      ),
    ];
  }

  /// Si este contenido lleva la marca NSFW **suya**, la que se pone a mano.
  ///
  /// No vale preguntar si está escondido: puede estarlo por una etiqueta, y
  /// entonces el interruptor saldría encendido y al pulsarlo no pasaría nada
  /// visible, porque la etiqueta lo seguiría escondiendo.
  bool _isMarkedNsfw(MediaEntity media) =>
      getIt<NsfwIndex>().isMarkedByHand(media.id);

  /// El botón de mandar esto a reconocer.
  ///
  /// Va aparte del resto porque es el único que depende de un bloc que no está
  /// en el árbol: mientras el trabajo esté vivo el botón se apaga y el icono se
  /// rellena, que es lo que dice «esto ya está pedido» sin ocupar sitio con un
  /// texto ni mover la barra con un indicador de progreso.
  Widget _buildRecognizeAction({required bool enabled}) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SuggestionsBloc, SuggestionsState>(
      bloc: _suggestions,
      builder: (context, state) {
        final isBusy = state.isRecognizing;

        return _buildAction(
          tooltip: isBusy ? l10n.viewerRecognizing : l10n.viewerRecognize,
          icon: AppIcons.recognize,
          fill: isBusy ? 1 : 0,
          color: isBusy ? context.colors.terciary : Colors.white,
          onPressed: (enabled && !isBusy) ? _recognize : null,
        );
      },
    );
  }

  /// Manda el contenido actual a la cola y lo cuenta.
  ///
  /// El aviso no sobra: encolar no se ve por ningún lado —la barra sólo cambia
  /// cuando el trabajo arranca, que puede ser dentro de un rato si hay algo por
  /// delante—, así que sin él pulsar el botón parecería no hacer nada.
  /// Pide reconocer. Lo que se cuente después lo decide el bloc.
  ///
  /// El aviso no sale de aquí porque saber si se puede reconocer es una lectura
  /// de la base de datos: contestarlo desde el botón obligaría a hacerlo antes
  /// de tener la respuesta, y nada más abrir un contenido todavía no la hay.
  void _recognize() => _suggestions.add(const RecognizeCurrentMediaEvent());

  /// Cuenta cómo ha quedado el reconocimiento de este contenido.
  ///
  /// El aviso lleva a algún sitio: pulsándolo se abre el parte de lo que hizo
  /// cada modelo. Es donde se contesta «¿por qué aquí no ha salido nada?», que
  /// casi nunca es «no vio nada» sino «lo vio poco», y eso sí se puede arreglar.
  void _reportRun(SuggestionsState state) {
    final l10n = AppLocalizations.of(context);
    final log = _logOf(state);

    showFernToast(
      context,
      state.lastRunSuggestions > 0
          ? l10n.recognizeFoundCount(state.lastRunSuggestions)
          : l10n.recognizeFoundNothing,
      icon: Symbols.info,
      // Sin parte no hay a dónde llevar, y entonces el aviso se va solo como
      // cualquier otro.
      onTap: log == null
          ? null
          : () => showFernDialog<void, MediaBloc>(
                context: context,
                builder: (_) => RecognitionLogDialog(logs: [log]),
              ),
    );
  }

  /// El parte de lo que pasó con este contenido, si se guardó alguno.
  MediaRecognitionLog? _logOf(SuggestionsState state) {
    final jobId = state.lastJobId;
    final mediaId = state.mediaId;
    if (jobId == null || mediaId == null) return null;

    return getIt<RecognitionLogStore>().forMedia(jobId, mediaId);
  }

  /// Cuenta en qué ha quedado la petición.
  ///
  /// Encolar no se ve por ningún lado —la barra sólo cambia cuando el trabajo
  /// arranca, que puede ser dentro de un rato si hay otro por delante— y no
  /// poder encolar tampoco: las dos cosas se parecen demasiado a que el botón
  /// esté roto.
  /// Cuenta en qué ha quedado la petición.
  ///
  /// El recado sale del mismo sitio que el de los otros tres puntos de entrada
  /// del D16: son los mismos motivos y no pueden explicarse distinto según desde
  /// dónde se pida.
  void _reportAttempt(SuggestionsState state) {
    final queued = state.lastAttempt == RecognitionAttempt.queued;

    showFernToast(
      context,
      recognitionMessage(
        AppLocalizations.of(context),
        RecognitionRequest(
          outcome: queued
              ? RecognitionOutcome.queued
              : RecognitionOutcome.notReady,
          readiness: state.readiness,
          count: 1,
        ),
      ),
      icon: queued ? Symbols.info : Symbols.error,
    );
  }

  /// Todos los botones de la barra salen de aquí: mismo juego de iconos, mismo
  /// tamaño, mismo grosor de trazo y mismo color, que es lo que hace que la
  /// barra se lea como una sola cosa y no como iconos sueltos de distintos
  /// sitios.
  ///
  /// [fill] es lo lleno que va el icono, de 0 a 1. Sólo lo usa el corazón: el
  /// relleno es lo que distingue a un favorito, y con estos iconos es el mismo
  /// dibujo con el interior pintado, no otro dibujo distinto.
  Widget _buildAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    Color color = Colors.white,
    double fill = 0,
  }) {
    final isEnabled = onPressed != null;
    final effective = isEnabled
        ? color
        : color.withValues(alpha: pillButtonDisabledOpacity);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: effective,
        size: AppSizes.iconExtraLarge,
        weight: viewerIconWeight,
        fill: fill,
      ),
    );
  }

  /// Entra al modo de marcar, recordando si el panel estaba abierto para
  /// dejarlo como estaba al salir.
  void _enterFernieMode() {
    final showInfo = context.read<MediaBloc>().state.showInfo;

    _fernieMode.add(EnterFernieModeEvent(infoWasOpen: showInfo));
  }

  /// Oscurecido que baja desde el borde superior y se va difuminando, para que
  /// los botones se lean también sobre un contenido claro.
  ///
  /// Es más alto que la fila de botones a propósito: así el degradado termina
  /// de apagarse por debajo de ellos y no se ve dónde acaba.
  Widget _buildShade() {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: viewerShadeHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: viewerShadeOpacity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El pase de un contenido al siguiente, como el de un carrusel: el que se va
/// sale deslizándose por un lado mientras el que llega entra por el otro.
///
/// Hacia qué lado lo dice [isForward], que es por dónde se ha pedido el pase (la
/// flecha de la derecha o la de la izquierda, del ratón o del teclado): sin eso,
/// ir hacia atrás se vería igual que ir hacia delante y el gesto no diría nada.
///
/// Los dos contenidos se recortan a la caja del visor mientras dura: si no,
/// durante el pase se verían por encima de las flechas y de la barra.
class _CarouselTransition extends StatelessWidget {
  final bool isForward;
  final Widget child;

  const _CarouselTransition({required this.isForward, required this.child});

  @override
  Widget build(BuildContext context) {
    // El que llega es el que trae la misma llave que el contenido de ahora; el
    // otro es el que se está yendo, y sale por el lado contrario.
    final incomingKey = child.key;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: viewerSlideDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == incomingKey;
          final from = isForward ? 1.0 : -1.0;

          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isIncoming ? from : -from, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

/// Panel de información que entra y sale deslizándose de derecha a izquierda.
///
/// El panel siempre se dispone a su ancho completo y lo que se anima es cuánto
/// de él se recorta, de modo que la maquetación interior nunca se comprime y no
/// puede desbordar durante la animación.
class _InfoPanel extends StatelessWidget {
  final bool isOpen;

  /// Si guardar pasa al siguiente contenido. Ver [ViewerPage.isReviewing].
  final bool isReviewing;

  /// El modo del visor, que la sección de fernies del panel necesita mirar.
  final FernieModeBloc fernieMode;

  /// Lo propuesto por los modelos, que el panel enseña bajo las etiquetas.
  final SuggestionsBloc suggestions;

  const _InfoPanel({
    required this.isOpen,
    required this.isReviewing,
    required this.fernieMode,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isOpen ? 1.0 : 0.0),
      duration: infoPanelAnimationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        if (progress == 0) return const SizedBox.shrink();

        return ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: progress,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: AppSizes.infoPanelWidth,
        child: MediaInfo(
          isReviewing: isReviewing,
          fernieMode: fernieMode,
          suggestions: suggestions,
        ),
      ),
    );
  }
}
