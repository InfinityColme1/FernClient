import 'package:Fern/core/constants/app_constants.dart';
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
          final media = state.currentMedia;
          final isFavorite = media?.isFavorite ?? false;

          // El contenido que ya está en la papelera se trata distinto: su botón
          // de borrar es el definitivo y, junto a él, aparece el de devolverlo a
          // su sitio.
          final isMarked = media != null &&
              (state.mediaList?.any(
                    (summary) => summary.id == media.id && summary.isDeleted,
                  ) ??
                  false);

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
                            // Mientras hay algo en marcha (los detalles del
                            // contenido siguiente, guardar, el corazón) el
                            // indicador de espera se pone sobre el contenido, que
                            // es lo único que va a cambiar: las flechas y la barra
                            // de acciones se quedan fuera del velo, atendiendo.
                            Expanded(
                              child: FernBusyOverlay(
                                isBusy: state.isBusy,
                                color: AppColors.black,
                                radius: AppSizes.radiusSmall,
                                indicatorColor: AppColors.white,
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
                                    // Todavía no hay nada que enseñar: se están
                                    // leyendo los detalles del contenido.
                                    return const Center(
                                      child: FernProgressIndicator(
                                        color: AppColors.white,
                                      ),
                                    );
                                  },
                                ),
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
                            // Lo que ya está en la papelera se restablece desde
                            // aquí: es la otra salida que tiene, y sin ella
                            // habría que volver a la rejilla para deshacerlo.
                            if (isMarked)
                              IconButton(
                                tooltip: AppLocalizations.of(context).actionRestore,
                                // De trazo, como los demás iconos de la barra:
                                // el de restablecer desde la papelera lleva la
                                // flecha maciza y desentonaba al lado de ellos.
                                // Que sea sacar de la papelera ya lo dice el
                                // sitio, que es el visor de algo que está
                                // dentro.
                                icon: const Icon(
                                  Icons.restore,
                                  color: AppColors.white,
                                  size: AppSizes.iconExtraLarge,
                                ),
                                onPressed: () => context
                                    .read<MediaBloc>()
                                    .add(RestoreMediaEvent(media)),
                              ),
                            IconButton(
                              icon: Image.asset(icDelete, scale: 2),
                              onPressed: media == null
                                  ? null
                                  : () => _delete(context, media, isMarked: isMarked),
                            ),
                            IconButton(
                              // El corazón se rellena al marcar como favorito:
                              // relleno o vacío se distingue de un vistazo, que
                              // es más de lo que decía el color por sí solo.
                              // Éste no sale de los iconos de la aplicación
                              // (entre ellos no hay ninguno relleno) sino del
                              // juego de Material, que tiene las dos versiones.
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: AppSizes.iconExtraLarge,
                                color: isFavorite
                                    ? AppColors.terciary
                                    : AppColors.white,
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
