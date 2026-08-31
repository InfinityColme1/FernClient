import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Papelera: el contenido marcado para borrar desde cualquier otra pantalla.
///
/// Sigue en la base de datos, así que desde aquí se puede restablecer o forzar
/// el borrado definitivo. Antes de lo segundo se avisa, y en ese aviso se decide
/// si los ficheros del disco se van con las filas o se quedan para poder
/// volverlos a escanear.
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

  /// Vacía la papelera, avisando antes de cuánto se va a borrar y preguntando
  /// qué se hace con sus ficheros. Si se cancela no se toca nada.
  Future<void> _purge(BuildContext context, int count) async {
    final bloc = context.read<MediaBloc>();

    final decision = await showFernDialog<DeleteDecision, MediaBloc>(
      context: context,
      builder: (_) =>
          ConfirmDeleteDialog(kind: MediaDeletionKind.trash, count: count),
    );
    if (decision == null) return;

    bloc.add(PurgeDeletedMediaEvent(deleteFiles: decision.deletesFiles));
  }

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

        return FernGridScreen(
          header: Row(
            children: [
              Text(
                texts.deletedCount(mediaList.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasMedia) ...[
                const SizedBox(width: AppSpacing.m),
                // La papelera se vacía sola, y eso hay que decirlo donde
                // se ve lo que hay dentro. Se lleva el hueco que sobra en
                // la fila (en vez de sólo el que le hiciera falta) porque
                // es el único texto de aquí que se puede quedar sin sitio,
                // y un aviso recortado no avisa de nada.
                Expanded(
                  child: Text(
                    texts.deletedRetentionNotice(deletedRetention.inDays),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.unremarked,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
              ] else
                const Spacer(),
              if (hasSelection) ...[
                Text(
                  texts.selectedCount(selectedCount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.terciary,
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
              ],
              // Borrado definitivo de todo lo marcado: sin nada marcado no
              // hay nada que forzar.
              IconButton(
                tooltip: texts.deleteForeverTooltip,
                onPressed: hasMedia
                    ? () => _purge(context, mediaList.length)
                    : null,
                icon: const Icon(Symbols.delete_forever),
              ),
              const SizedBox(width: AppSpacing.s),
              FernPillButton(
                label: texts.actionRestore,
                icon: Symbols.restore_from_trash,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.black,
                onPressed: hasSelection
                    ? () => context.read<MediaBloc>().add(
                        const RestoreSelectedMediaEvent(),
                      )
                    : null,
              ),
            ],
          ),
          body: MediaGrid(
            mediaList: mediaList,
            columns: mediaGridColumns,
            isLoading: state.isBusy,
            returnsToViewed: true,
          ),
        );
      },
    );
  }
}
