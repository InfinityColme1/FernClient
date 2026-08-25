import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/file_explorer_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lo que se puede hacer con el contenido sin abrirlo, al pulsar con el botón
/// derecho sobre una celda.
///
/// **La regla de a qué se aplica**: si hay selección, a la selección entera; si
/// no, al contenido pulsado. Es la misma que la del arrastre, y por eso la
/// cabecera del menú dice a cuántos afecta: pulsar con el derecho sobre una
/// celda que no está marcada teniendo otras veinte marcadas actúa sobre las
/// veinte, y esa sorpresa hay que quitarla antes de que ocurra, no después.
class MediaContextMenu extends StatelessWidget {
  /// El contenido sobre el que se ha pulsado.
  final MediaSummaryEntity media;

  /// A qué contenidos se aplica lo que se elija.
  final List<int> targetIds;

  /// Se llama al elegir cualquier cosa: el menú se cierra solo.
  final VoidCallback onDone;

  const MediaContextMenu({
    super.key,
    required this.media,
    required this.targetIds,
    required this.onDone,
  });

  /// Si lo que se va a hacer afecta a más de un contenido.
  bool get _isBulk => targetIds.length > 1;

  void _run(BuildContext context, MediaEvents event) {
    context.read<MediaBloc>().add(event);
    onDone();
  }

  /// Marca la selección y lanza [event], en ese orden.
  ///
  /// Las acciones en tanda del bloc trabajan sobre `selectedIds`, así que actuar
  /// sobre el contenido pulsado sin marcarlo antes no haría nada. Marcarlo es
  /// además lo que hace ver sobre qué se acaba de actuar.
  void _runOnSelection(BuildContext context, MediaEvents event) {
    final bloc = context.read<MediaBloc>();

    bloc.add(SelectAllMediaEvent(targetIds));
    bloc.add(event);
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A cuántos afecta, siempre. También con uno: es lo que separa este menú
        // de uno que hace cosas a bulto.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Text(
            texts.contextMenuTarget(targetIds.length),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: context.colors.gray),
          ),
        ),
        _entry(
          context,
          icon: Icons.favorite_border,
          label: texts.favoriteSelectedTooltip,
          onTap: () =>
              _runOnSelection(context, const FavoriteSelectedMediaEvent()),
        ),
        _entry(
          context,
          icon: Icons.auto_awesome_outlined,
          label: texts.recognizeSelectedTooltip,
          onTap: () {
            requestRecognition(
              context,
              targetIds,
              name: texts.recognizeJobSelection,
            );
            onDone();
          },
        ),
        if (getIt<NsfwModeService>().isConfigured)
          _entry(
            context,
            icon: Icons.visibility_off_outlined,
            label: texts.mediaNsfwMark,
            onTap: () => _runOnSelection(
              context,
              const SetSelectedMediaNsfwEvent(isNsfw: true),
            ),
          ),
        // Abrir el fichero es de **uno**: con veinte seleccionados no hay una
        // carpeta que enseñar, hay veinte ventanas que abrir. Así que se ofrece
        // sólo cuando el gesto va sobre uno solo.
        if (!_isBulk && const FileExplorerService().isSupported)
          _entry(
            context,
            icon: Icons.folder_open_outlined,
            label: texts.actionRevealInExplorer,
            onTap: () async {
              final revealed =
                  await const FileExplorerService().reveal(media.path);

              if (!context.mounted) return;
              if (!revealed) {
                showFernToast(
                  context,
                  texts.revealInExplorerFailed,
                  icon: Icons.error_outline,
                );
              }

              onDone();
            },
          ),
        const Divider(),
        _entry(
          context,
          icon: Icons.delete_outline,
          label: texts.deleteSelectedTooltip,
          color: context.colors.error,
          onTap: () =>
              _runOnSelection(context, const DeleteSelectedMediaEvent()),
        ),
      ],
    );
  }

  Widget _entry(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMedium, color: color),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
