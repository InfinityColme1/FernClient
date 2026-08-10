import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/widgets/media_info.dart';
import 'package:Fern/features/media/presentation/widgets/media_viewer.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<MediaBloc>().add(SetInfoVisibilityEvent(widget.openInfo));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaStates>(
      builder: (context, state) {
        return Scaffold(
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
                            onPressed: () => context.read<MediaBloc>().add(const ViewerNextEvent(next: false)),
                            icon: Image.asset(icLeft, width: AppSizes.buttonHeightSmall),
                          ),
                          Expanded(
                            child: BlocBuilder<MediaBloc, MediaStates>(
                              buildWhen: (previous, current) =>
                              previous.currentMedia?.path != current.currentMedia?.path,
                              builder: (context, state) {
                                if (state.currentMedia != null) {
                                  return MediaViewer(
                                    key: ValueKey(state.currentMedia!.path),
                                    path: state.currentMedia!.path,
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.read<MediaBloc>().add(const ViewerNextEvent(next: true)),
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
                            onPressed: () { /* TODO: Implementar delete */ },
                          ),
                          IconButton(
                            icon: Image.asset(icHeart, scale: 2),
                            onPressed: () { /* TODO: Implementar favorite */ },
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
        );
      },
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
