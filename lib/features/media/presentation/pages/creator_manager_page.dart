import 'dart:math' as math;

import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/presentation/blocs/creators_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/creators_events.dart';
import 'package:Fern/features/media/presentation/blocs/creators_states.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/creator_card.dart';
import 'package:Fern/features/media/presentation/widgets/creator_list.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Gestión de creadores: a la derecha todos los creadores de la aplicación y, a
/// la izquierda, el elegido.
///
/// Está armada igual que la de etiquetas: del creador elegido se ven su ficha
/// (`CreatorCard`), donde se editan su nombre, su avatar y las direcciones que lo
/// asignan solo, y su contenido en una rejilla, donde se puede seleccionar para
/// quitarle el creador desde la ficha.
class CreatorManagerPage extends StatefulWidget {
  const CreatorManagerPage({super.key});

  @override
  State<CreatorManagerPage> createState() => _CreatorManagerPageState();
}

class _CreatorManagerPageState extends State<CreatorManagerPage> {
  final _creatorsBloc = getIt<CreatorsBloc>();

  /// El creador elegido, por identificador y no por entidad: al guardarlo
  /// cambian su nombre y su avatar, pero sigue siendo el mismo creador.
  int? _selectedCreatorId;

  @override
  void initState() {
    super.initState();

    // Se releen siempre al entrar y no sólo la primera vez: mientras la pantalla
    // no estaba puede haberse creado un creador desde cualquier otro sitio (el
    // "+" del menú o el diálogo que se lo asigna a un contenido), y lo que hay
    // en el bloc sería de antes.
    _creatorsBloc.add(const LoadCreatorsEvent());

    // Los creadores que ya hubiera leídos se enseñan mientras llega la relectura,
    // y con ellos no va a llegar ningún estado nuevo que dispare la selección por
    // defecto, así que se resuelve en cuanto se puede llamar a `setState`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSelection(_creatorsBloc.state);
    });
  }

  /// Deja elegido un creador que exista.
  ///
  /// Se llama al entrar y cada vez que cambian los creadores: por defecto queda
  /// elegido el primero, y si el que estaba elegido ha desaparecido se hace lo
  /// mismo en lugar de quedarse enseñando algo que ya no está.
  void _syncSelection(CreatorsState state) {
    final creators = state.creators;
    if (creators.isEmpty) return;

    final isStillThere = creators.any(
      (creator) => creator.id == _selectedCreatorId,
    );
    if (isStillThere) return;

    _select(creators.first);
  }

  /// Elige un creador y pide su contenido para la rejilla.
  void _select(CreatorEntity creator) {
    if (_selectedCreatorId == creator.id) return;

    setState(() => _selectedCreatorId = creator.id);
    getIt<MediaBloc>().add(LoadMediaByCreatorEvent(creator.id));
  }

  CreatorEntity? _selectedCreator(List<CreatorEntity> creators) {
    for (final creator in creators) {
      if (creator.id == _selectedCreatorId) return creator;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: BlocConsumer<CreatorsBloc, CreatorsState>(
        bloc: _creatorsBloc,
        listener: (context, state) => _syncSelection(state),
        builder: (context, state) {
          final creators = state.creators;

          // Sin creadores no hay nada que gestionar: se dice y punto. Mientras la
          // primera lectura está en marcha no se dice que no haya ninguno,
          // todavía no se sabe: se espera con el indicador.
          if (creators.isEmpty) {
            // Con la transición de la pantalla, igual que el resto.
            //
            // Sin ella, la pantalla vacía era lo único que no pasaba por la
            // coreografía: al ir de una gestión a otra estando las dos vacías,
            // los dos textos se pintaban a la vez y centrados en el mismo sitio,
            // así que se leían uno encima del otro.
            return ScreenSlotTransition(
              slot: ScreenSlot.grid,
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: state.isLoaded
                    ? FernEmptyState(
                        imageAsset: fernEmptyImage,
                        message: AppLocalizations.of(context).noCreatorsYet,
                        description:
                            AppLocalizations.of(context).noCreatorsYetHint,
                      )
                    : const Center(child: FernProgressIndicator()),
              ),
            );
          }

          final selected = _selectedCreator(creators) ?? creators.first;

          return FernManagementScreen(
            padding: const EdgeInsets.only(
              top: AppSpacing.l,
              left: AppSpacing.l,
              right: AppSpacing.l,
              bottom: AppSpacing.l,
            ),
            listWidth: AppSizes.tagListWidth,
            cardBuilder: (context, space) => _creatorCard(selected, space),
            grid: _creatorMedia(),
            // Al guardar o borrar un creador la lista se vuelve a leer: hasta que
            // llegue se queda la de antes, con el indicador encima.
            list: FernBusyOverlay(
              isBusy: state.isBusy,
              // La lista va directamente sobre el fondo, sin superficie propia
              // de la que copiar el redondeo.
              radius: AppSizes.radiusMedium,
              child: CreatorList(
                creators: creators,
                selectedCreatorId: selected.id,
                onSelected: _select,
              ),
            ),
          );
        },
      ),
    );
  }

  /// La columna del creador elegido: su ficha arriba y su contenido debajo.
  ///
  /// La ficha se rehace al cambiar de creador (de eso se encarga la clave): los
  /// campos arrancan con los valores del creador, así que tienen que volver a
  /// nacer con los del nuevo.
  /// La ficha del creador elegido, con su alto ya repartido.
  ///
  /// El alto lo pone la pantalla y no el contenido de la ficha: así todos los
  /// creadores tienen la misma y la rejilla de debajo no se mueve de sitio al
  /// cambiar de uno a otro ni al añadirle un enlace.
  Widget _creatorCard(CreatorEntity creator, BoxConstraints space) {
    final cardHeight = math.min(
      creatorCardHeight,
      // En una ventana baja la ficha cede antes que la rejilla, pero sólo hasta
      // el mínimo con el que su formulario sigue cabiendo.
      math.max(space.maxHeight - creatorGridMinHeight, creatorCardMinHeight),
    );

    return SizedBox(
      height: cardHeight,
      child: CreatorCard(key: ValueKey(creator.id), creator: creator),
    );
  }

  /// El contenido del creador elegido.
  Widget _creatorMedia() {
    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          previous is! DetailedMedia && current is DetailedMedia,
      listener: (context, state) {
        // Como en las demás rejillas: el contenido se abre a pantalla completa y
        // al cerrarlo se vuelve aquí, con el creador elegido tal y como estaba.
        if (state is DetailedMedia) context.push(viewerRoute);
      },
      builder: (context, state) => MediaGrid(
        mediaList: state.mediaList ?? const [],
        columns: tagManagerGridColumns,
        isLoading: state.isBusy,
        // La superficie de esta pantalla es la de la ficha: la rejilla va
        // directamente sobre el fondo.
        hasSurface: false,
      ),
    );
  }
}
