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

/// El contenido marcado con el corazón del visor.
///
/// Es la pantalla de contenido con un filtro: la misma rejilla y la misma
/// cabecera, pero sólo con lo que es favorito. Quitarle el corazón a un
/// contenido desde el visor lo saca de aquí.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    getIt<MediaBloc>().add(const LoadFavoriteMediaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // Como en la pantalla de contenido: a pantalla completa y con la
          // información recogida hasta que se pida.
          context.push(viewerRoute);
        }
      },
      builder: (context, state) {
        final mediaList = state.mediaList ?? const [];

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
                      texts.favoritesCount(mediaList.length),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // TODO: los filtros son otra tarea; el botón ya está en su
                    // sitio para colgarlos de él.
                    FernPillButton(
                      label: texts.filters,
                      icon: Icons.tune,
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.black,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MediaGrid(
                  mediaList: mediaList,
                  columns: mediaGridColumns,
                  isLoading: state.isBusy,
                  returnsToViewed: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
