import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/widgets/media_info.dart';
import 'package:Fern/features/media/presentation/widgets/media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../blocs/media_bloc.dart';
import '../blocs/media_events.dart';
import '../blocs/media_states.dart';

class ViewerPage extends StatelessWidget {
  const ViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ViewerPageView();
  }
}

class _ViewerPageView extends StatelessWidget {
  const _ViewerPageView({super.key});

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
                            icon: Image.asset(ic_left, width: 40),
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
                            icon: Image.asset(ic_right, width: 40),
                          ),
                        ],
                      ),
                    ),

                    // Barra Superior de Acciones
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Image.asset(ic_share, scale: 2),
                            onPressed: () { /* TODO: Implementar share */ },
                          ),
                          IconButton(
                            icon: Image.asset(ic_info, scale: 2),
                            // DISPARAR EL EVENTO DE TOGGLE
                            onPressed: () => context.read<MediaBloc>().add(const ToggleInfoEvent()),
                          ),
                          IconButton(
                            icon: Image.asset(ic_delete, scale: 2),
                            onPressed: () { /* TODO: Implementar delete */ },
                          ),
                          IconButton(
                            icon: Image.asset(ic_heart, scale: 2),
                            onPressed: () { /* TODO: Implementar favorite */ },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LADO DERECHO: Panel de Información (Solo si showInfo es true)
              if (state.showInfo)
                SizedBox(
                  width: 350, // Ajusta el ancho según tus necesidades
                  child: MediaInfo(),
                ),
            ],
          ),
        );
      },
    );
  }
}