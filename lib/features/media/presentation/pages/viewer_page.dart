import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/widgets/media_info.dart';
import 'package:Fern/features/media/presentation/widgets/media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<MediaBloc>().add(SetInfoVisibilityEvent(widget.openInfo));
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _goTo({required bool next}) =>
      context.read<MediaBloc>().add(ViewerNextEvent(next: next));

  /// Flechas izquierda/derecha para navegar entre contenidos y escape para
  /// volver a la pantalla anterior.
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
      child: BlocBuilder<MediaBloc, MediaStates>(
        builder: (context, state) {
          return Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Scaffold(
            backgroundColor: AppColors.black,
            body: Row(
              children: [
                // LADO IZQUIERDO: Visor y Controles
                Expanded(
                  child: Stack(
                    children: [
                      // Visor de Media
                      Center(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _goTo(next: false),
                              icon: Image.asset(icLeft, width: AppSizes.buttonHeightSmall),
                            ),
                            Expanded(
                              child: BlocBuilder<MediaBloc, MediaStates>(
                                buildWhen: (previous, current) =>
                                previous.currentMedia?.path != current.currentMedia?.path,
                                builder: (context, state) {
                                  final media = state.currentMedia;
                                  if (media != null) {
                                    return MediaViewer(
                                      key: ValueKey(media.path),
                                      path: media.path,
                                      // Si el fichero ya no está, su fila sale
                                      // de la base de datos y el visor pasa al
                                      // siguiente contenido.
                                      onLoadFailed: () => context
                                          .read<MediaBloc>()
                                          .add(MediaLoadFailedEvent(media.id)),
                                    );
                                  }
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _goTo(next: true),
                              icon: Image.asset(icRight, width: AppSizes.buttonHeightSmall),
                            ),
                          ],
                        ),
                      ),

                      // Barra Superior de Acciones
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.white,
                                  size: AppSizes.iconExtraLarge),
                              onPressed: () => context.pop(),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Image.asset(icShare, scale: 2),
                              onPressed: () { /* TODO: Implementar share */ },
                            ),
                            IconButton(
                              icon: Image.asset(icInfo, scale: 2),
                              // DISPARAR EL EVENTO DE TOGGLE
                              onPressed: () => context.read<MediaBloc>().add(const ToggleInfoEvent()),
                            ),
                            IconButton(
                              icon: Image.asset(icDelete, scale: 2),
                              onPressed: () => context.read<MediaBloc>().add(DeleteMediaEvent(state.currentMedia!)),
                            ),
                            IconButton(
                              // No hay corazón relleno entre los iconos, así
                              // que lo que dice si el contenido es favorito es
                              // el color: teñido cuando lo es y tal cual
                              // cuando no.
                              icon: Image.asset(
                                icHeart,
                                scale: 2,
                                color: (state.currentMedia?.isFavorite ?? false)
                                    ? AppColors.terciary
                                    : null,
                              ),
                              onPressed: state.currentMedia == null
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

                // LADO DERECHO: Panel de Información
                _InfoPanel(isOpen: state.showInfo),
              ],
            ),
          ),
        );
        },
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
