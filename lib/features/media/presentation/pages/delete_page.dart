import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Papelera: el contenido marcado para borrar desde cualquier otra pantalla.
///
/// Sigue en la base de datos, así que desde aquí se puede restablecer o forzar
/// el borrado definitivo; los ficheros del disco no se tocan en ninguno de los
/// dos casos, de modo que lo borrado se puede volver a escanear.
class DeletePage extends StatefulWidget {
  const DeletePage({super.key});

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  @override
  void initState() {
    super.initState();
    getIt<MediaBloc>().add(const LoadDeletedMediaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _DeleteView(),
    );
  }
}

class _DeleteView extends StatelessWidget {
  const _DeleteView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // Se abre a pantalla completa, como el contenido ya revisado: aquí no
          // se revisa nada, sólo se mira antes de decidir.
          context.push(viewerRoute);
        }
      },
      builder: (context, state) {
        final mediaList = state.mediaList ?? const [];
        final hasMedia = mediaList.isNotEmpty;

        // El botón de restablecer actúa sobre la selección de la rejilla, así
        // que sin selección no hay nada que devolver a su sitio.
        final selectedCount = state.selectedIds.length;
        final hasSelection = selectedCount > 0;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.xl,
                  bottom: AppSpacing.l,
                ),
                child: Row(
                  children: [
                    Text(
                      texts.deletedCount(mediaList.length),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (hasMedia) ...[
                      const SizedBox(width: AppSpacing.m),
                      // La papelera se vacía sola, y eso hay que decirlo donde se
                      // ve lo que hay dentro. Flexible para que se recorte si la
                      // ventana se estrecha en vez de desbordar la fila.
                      Flexible(
                        child: Text(
                          texts.deletedRetentionNotice(deletedRetention.inDays),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.unremarked),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (hasSelection) ...[
                      Text(
                        texts.selectedCount(selectedCount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.terciary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                    ],
                    // Borrado definitivo de todo lo marcado: sin nada marcado no
                    // hay nada que forzar.
                    IconButton(
                      tooltip: texts.deleteForeverTooltip,
                      // El color va en el botón y no en el icono para que se
                      // atenúe solo cuando no hay nada marcado.
                      color: AppColors.black,
                      onPressed: hasMedia
                          ? () => context
                              .read<MediaBloc>()
                              .add(const PurgeDeletedMediaEvent())
                          : null,
                      icon: const Icon(Icons.delete_forever_outlined),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    FernPillButton(
                      label: texts.actionRestore,
                      icon: Icons.restore_from_trash_outlined,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      onPressed: hasSelection
                          ? () => context
                              .read<MediaBloc>()
                              .add(const RestoreSelectedMediaEvent())
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MediaGrid(
                  mediaList: mediaList,
                  columns: 4,
                  isLoading: state.isBusy,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
