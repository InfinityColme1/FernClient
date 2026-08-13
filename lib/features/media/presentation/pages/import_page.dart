import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';


class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  @override
  void initState() {
    super.initState();
    // CARGA AUTOMÁTICA: Disparamos el evento al iniciar la pantalla
    getIt<MediaBloc>().add(const LoadScannedMediaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _ImportView(),
    );
  }
}

class _ImportView extends StatelessWidget {
  const _ImportView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // El contenido escaneado se abre con la información desplegada: es
          // la pantalla donde se revisa antes de darlo por definitivo.
          context.push(viewerRouteWithInfo(true));
        }
      },
      builder: (context, state) {
        final hasMedia = state.mediaList != null && state.mediaList!.isNotEmpty;
        // Los botones masivos actúan sobre la selección de la rejilla, así que
        // sin selección no hay nada que borrar ni que confirmar.
        final selectedCount = state.selectedIds.length;
        final hasSelection = selectedCount > 0;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
          child: Column(
            children: [
              // HEADER ROW DINÁMICA
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.xl,
                  bottom: AppSpacing.l,
                ),
                child: Row(
                  children: [
                    FernDropdownPill<String>(
                      value: importSources.first,
                      items: importSources,
                      // El valor es el identificador de la fuente; sólo el
                      // equipo local tiene nombre que traducir (Pixiv y
                      // Twitter son marcas).
                      labelBuilder: (source) => source == localComputerSource
                          ? texts.sourceLocalComputer
                          : source,
                      onChanged: (_) {},
                    ),
                    const Spacer(),
                    if (hasMedia) ...[
                      // CENTER: Stats
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
                      Text(
                        texts.mediaFetched(state.mediaList!.length),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      // RIGHT: Actions with content
                      IconButton(
                        onPressed: () => context
                            .read<MediaBloc>()
                            .add(const ScanDirectoryEvent()),
                        icon: const Icon(Icons.refresh, color: AppColors.black),
                      ),
                      IconButton(
                        onPressed: () => context
                            .read<MediaBloc>()
                            .add(const SelectAndScanDirectoryEvent()),
                        icon: const Icon(Icons.folder_open_outlined,
                            color: AppColors.black),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      FernPillButton(
                        label: texts.actionDelete,
                        icon: Icons.delete_outline,
                        backgroundColor: AppColors.terciary,
                        foregroundColor: AppColors.white,
                        onPressed: hasSelection
                            ? () => context
                                .read<MediaBloc>()
                                .add(const DeleteSelectedMediaEvent())
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      FernPillButton(
                        label: texts.actionConfirm,
                        icon: Icons.check,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black,
                        onPressed: hasSelection
                            ? () => context
                                .read<MediaBloc>()
                                .add(const ConfirmSelectedMediaEvent())
                            : null,
                      ),
                    ] else ...[
                      // RIGHT: Actions when empty
                      IconButton(
                        onPressed: () => context
                            .read<MediaBloc>()
                            .add(const SelectAndScanDirectoryEvent()),
                        icon: const Icon(Icons.folder_open_outlined,
                            color: AppColors.black),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      FernPillButton(
                        label: texts.actionImport,
                        icon: Icons.file_download_outlined,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black,
                        onPressed: () => context
                            .read<MediaBloc>()
                            .add(const ScanDirectoryEvent()),
                      ),
                    ],
                  ],
                ),
              ),

              // GRID
              Expanded(
                child: MediaGrid(
                  mediaList: state.mediaList ?? [],
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
