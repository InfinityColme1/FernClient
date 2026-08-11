import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/search/search_suggestion_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Todo el contenido definitivo de la base de datos: el que ya se ha revisado
/// y guardado desde el visor. Lo pendiente de revisar vive en la pantalla de
/// importación.
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  void initState() {
    super.initState();

    // Si hay una búsqueda en marcha (se ha escrito en el buscador desde otra
    // pantalla) se repite, no se descarta: es lo que se ha pedido ver. Y se
    // repite tal cual era: si venía de pulsar una sugerencia, por esa
    // sugerencia; si no, por el texto.
    final bloc = getIt<MediaBloc>();
    final suggestion = bloc.state.searchSuggestion;
    final searchQuery = bloc.state.searchQuery;

    bloc.add(switch ((suggestion, searchQuery)) {
      (final SearchSuggestionEntity suggestion, _) =>
        SearchSuggestionSelectedEvent(suggestion),
      (_, final String query) => SearchMediaEvent(query),
      _ => const LoadMediaLibraryEvent(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _MediaView(),
    );
  }
}

class _MediaView extends StatelessWidget {
  const _MediaView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // El contenido ya revisado se abre a pantalla completa: la
          // información se despliega sólo si se pide.
          context.push(viewerRoute);
        }
      },
      builder: (context, state) {
        final mediaList = state.mediaList ?? const [];
        final sections = state.searchSections;

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
                      "${mediaList.length} media",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // TODO: los filtros son otra tarea; el botón ya está en su
                    // sitio para colgarlos de él.
                    FernPillButton(
                      label: "Filters",
                      icon: Icons.tune,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sections == null
                    ? MediaGrid(mediaList: mediaList, columns: 4)
                    : MediaGrid.sections(sections: sections, columns: 4),
              ),
            ],
          ),
        );
      },
    );
  }
}
