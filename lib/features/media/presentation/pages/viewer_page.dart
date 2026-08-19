import 'dart:async';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/clipboard_service.dart';
import 'package:Fern/core/services/fullscreen_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
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

  const ViewerPage({super.key, this.openInfo = false});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  /// Nodo que recibe el foco al entrar para poder atender el teclado.
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'ViewerPageKeyboard');

  /// Si los mandos (la barra de acciones con su sombreado y las flechas) están
  /// a la vista. Se esconden cuando el ratón lleva un rato quieto para dejar el
  /// contenido limpio, y vuelven en cuanto se mueve.
  bool _areControlsVisible = true;

  /// Cuenta atrás para esconderlos. Cada movimiento del ratón la reinicia.
  Timer? _hideTimer;

  /// Si la ventana está a pantalla completa por haberlo pedido desde aquí.
  bool _isFullscreen = false;

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
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    // La pantalla completa es de esta pantalla: al salir de ella (por el botón
    // de volver, por escape o porque el contenido ha desaparecido) la ventana
    // vuelve a como estaba.
    FullscreenService.instance.exit();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _goTo({required bool next}) {
    _isForward = next;
    context.read<MediaBloc>().add(ViewerNextEvent(next: next));
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

  void _restartHideTimer() {
    _hideTimer?.cancel();
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
      icon: copied ? Icons.check_rounded : Icons.error_outline_rounded,
    );
  }

  /// El botón de borrar hace una cosa u otra según dónde esté el contenido: lo
  /// que ya está en la papelera se borra del todo (desde ahí no hay a dónde
  /// mandarlo) y el resto se marca o se descarta, según sea definitivo o esté
  /// pendiente de revisar. Los dos casos avisan antes.
  void _delete(BuildContext context, MediaEntity media, {required bool isMarked}) {
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
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowLeft) {
      _goTo(next: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _goTo(next: true);
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaBloc, MediaStates>(
      // El contenido que se estaba viendo ha desaparecido (su fichero ya no
      // estaba) y no queda nada más que enseñar: se vuelve a la rejilla.
      listenWhen: (previous, current) =>
          previous.currentMedia != null && current.currentMedia == null,
      listener: (context, state) {
        if (context.canPop()) context.pop();
      },
      // Abrir o cerrar el panel de información cuenta como actividad: al
      // cerrarlo los mandos se quedan un rato a la vista en lugar de irse de
      // golpe, que es lo que pasaría si la cuenta atrás hubiera terminado
      // mientras el panel estaba abierto.
      child: BlocListener<MediaBloc, MediaStates>(
        listenWhen: (previous, current) => previous.showInfo != current.showInfo,
        listener: (context, state) => _wakeControls(),
        child: BlocBuilder<MediaBloc, MediaStates>(
        builder: (context, state) {
          final media = state.currentMedia;

          // El contenido que ya está en la papelera se trata distinto: su botón
          // de borrar es el definitivo y, junto a él, aparece el de devolverlo a
          // su sitio.
          final isMarked = state.isCurrentMediaMarked;

          // Con el panel de información abierto los mandos no se esconden: se
          // está trabajando con el contenido, no mirándolo.
          final showControls = _areControlsVisible || state.showInfo;

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
                      children: [
                        // Visor de Media
                        Center(
                          child: Row(
                            children: [
                              _buildNavigationArrow(
                                asset: icLeft,
                                isVisible: showControls,
                                onPressed: () => _goTo(next: false),
                              ),
                              // Mientras hay algo en marcha (los detalles del
                              // contenido siguiente, guardar, el corazón) el
                              // indicador de espera se pone sobre el contenido, que
                              // es lo único que va a cambiar: las flechas y la barra
                              // de acciones se quedan fuera del velo, atendiendo.
                              Expanded(
                                child: FernBusyOverlay(
                                  isBusy: state.isBusy,
                                  color: Colors.black,
                                  radius: AppSizes.radiusSmall,
                                  indicatorColor: Colors.white,
                                  child: BlocBuilder<MediaBloc, MediaStates>(
                                    buildWhen: (previous, current) =>
                                    previous.currentMedia?.path != current.currentMedia?.path,
                                    builder: (context, state) {
                                      final media = state.currentMedia;

                                      final content = media != null
                                          ? MediaViewer(
                                              key: ValueKey(media.path),
                                              path: media.path,
                                              // Si el fichero ya no está, su fila sale
                                              // de la base de datos y el visor pasa al
                                              // siguiente contenido.
                                              onLoadFailed: () => context
                                                  .read<MediaBloc>()
                                                  .add(MediaLoadFailedEvent(media.id)),
                                            )
                                          // Todavía no hay nada que enseñar: se están
                                          // leyendo los detalles del contenido.
                                          : const Center(
                                              key: ValueKey('viewer-loading'),
                                              child: FernProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            );

                                      return _CarouselTransition(
                                        isForward: _isForward,
                                        child: content,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              _buildNavigationArrow(
                                asset: icRight,
                                isVisible: showControls,
                                onPressed: () => _goTo(next: true),
                              ),
                            ],
                          ),
                        ),

                        // Barra Superior de Acciones
                        _buildActionBar(
                          media: media,
                          isMarked: isMarked,
                          isVisible: showControls,
                        ),
                      ],
                    ),
                  ),
                ),

                // LADO DERECHO: Panel de Información
                _InfoPanel(isOpen: state.showInfo),
              ],
            ),
          ),
        );
        },
        ),
      ),
    );
  }

  /// Una de las dos flechas de navegación. Se desvanecen con la barra: el
  /// teclado sigue pasando de un contenido a otro aunque no estén a la vista.
  Widget _buildNavigationArrow({
    required String asset,
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return _FadingControls(
      isVisible: isVisible,
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(asset, width: AppSizes.buttonHeightSmall),
      ),
    );
  }

  /// La barra de acciones, con el sombreado que la acompaña.
  ///
  /// El sombreado es el mismo recurso que usan las celdas de la rejilla: sin él
  /// los botones blancos desaparecen sobre un contenido claro. Va dentro del
  /// mismo desvanecido que los botones porque es suyo: sombrear un contenido que
  /// ya no tiene nada encima no tendría sentido.
  Widget _buildActionBar({
    required MediaEntity? media,
    required bool isMarked,
    required bool isVisible,
  }) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = media?.isFavorite ?? false;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _FadingControls(
        isVisible: isVisible,
        child: Stack(
          children: [
            _buildShade(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Row(
                children: [
                  _buildAction(
                    tooltip: l10n.viewerBack,
                    icon: Symbols.arrow_back,
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  _buildAction(
                    tooltip: l10n.viewerShare,
                    icon: Symbols.ios_share,
                    onPressed:
                        media == null ? null : () => _copyToClipboard(media),
                  ),
                  // La pantalla completa la da el sistema, así que sólo se
                  // ofrece donde la aplicación sabe pedirla.
                  if (FullscreenService.instance.isSupported)
                    _buildAction(
                      tooltip: _isFullscreen
                          ? l10n.viewerExitFullscreen
                          : l10n.viewerFullscreen,
                      icon: _isFullscreen
                          ? Symbols.fullscreen_exit
                          : Symbols.fullscreen,
                      onPressed: _toggleFullscreen,
                    ),
                  _buildAction(
                    tooltip: l10n.mediaInfoTitle,
                    icon: Symbols.info,
                    onPressed: () =>
                        context.read<MediaBloc>().add(const ToggleInfoEvent()),
                  ),
                  // Lo que ya está en la papelera se restablece desde aquí: es
                  // la otra salida que tiene, y sin ella habría que volver a la
                  // rejilla para deshacerlo.
                  if (isMarked)
                    _buildAction(
                      tooltip: l10n.actionRestore,
                      icon: Symbols.restore,
                      onPressed: media == null
                          ? null
                          : () => context
                              .read<MediaBloc>()
                              .add(RestoreMediaEvent(media)),
                    ),
                  _buildAction(
                    tooltip: l10n.actionDelete,
                    icon: Symbols.delete,
                    onPressed: media == null
                        ? null
                        : () => _delete(context, media, isMarked: isMarked),
                  ),
                  _buildAction(
                    // El corazón se rellena al marcar como favorito: relleno o
                    // vacío se distingue de un vistazo, que es más de lo que
                    // decía el color por sí solo.
                    tooltip: isFavorite
                        ? l10n.viewerUnfavorite
                        : l10n.viewerFavorite,
                    icon: Symbols.favorite,
                    fill: isFavorite ? 1 : 0,
                    color: isFavorite ? context.colors.terciary : Colors.white,
                    onPressed: media == null
                        ? null
                        : () => context
                            .read<MediaBloc>()
                            .add(const ToggleFavoriteEvent()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: AppSizes.iconExtraLarge,
        weight: viewerIconWeight,
        fill: fill,
      ),
    );
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

/// Envuelve los mandos del visor para que aparezcan y desaparezcan juntos.
///
/// Mientras están escondidos no atienden al ratón: si no, se podría pulsar un
/// botón que no se ve.
class _FadingControls extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const _FadingControls({required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: viewerControlsFadeDuration,
      child: IgnorePointer(ignoring: !isVisible, child: child),
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

  const _InfoPanel({required this.isOpen});

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
      child: const SizedBox(
        width: AppSizes.infoPanelWidth,
        child: MediaInfo(),
      ),
    );
  }
}
