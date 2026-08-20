import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_states.dart';
import 'package:Fern/features/recognition/presentation/services/region_cells.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_card.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Gestión de fernies: a la derecha todos los fernies de la aplicación y, a la
/// izquierda, el que esté elegido.
///
/// Del fernie elegido se ven dos cosas, como en las pantallas de etiquetas y de
/// creadores: su ficha, donde se editan nombre, avatar y a qué se enlaza, y sus
/// regiones en una rejilla.
///
/// Lo que distingue a esta rejilla de las otras dos es que **cada celda es una
/// región**, no un contenido: se ve sólo el trozo marcado, con la proporción del
/// trozo. Pulsar una celda abre el contenido entero en el visor y lo señala con
/// un parpadeo, que es la forma de recuperar el contexto de lo que se está
/// viendo recortado.
class FerniesPage extends StatefulWidget {
  /// Fernie que llega ya elegido, cuando se ha llegado aquí pulsando uno.
  ///
  /// Sin él se elige el primero de la lista, que es lo que pasa al entrar por el
  /// menú lateral.
  final int? selectedFernieId;

  const FerniesPage({super.key, this.selectedFernieId});

  @override
  State<FerniesPage> createState() => _FerniesPageState();
}

class _FerniesPageState extends State<FerniesPage> {
  final _ferniesBloc = getIt<FerniesBloc>();
  final _mediaBloc = getIt<MediaBloc>();

  /// La región que se acaba de pulsar, a la espera de que lleguen los detalles
  /// del contenido para abrir el visor señalándola.
  int? _pendingHighlightId;

  /// Los contenidos que ya se le han pasado al bloc de contenido.
  ///
  /// Se guardan para no repetir el aviso: el estado de esta pantalla cambia
  /// también al marcar regiones en la rejilla, y republicar la lista por eso
  /// soltaría la selección del otro bloc sin motivo.
  List<int> _publishedMediaIds = const [];

  /// Si ya se ha atendido el fernie que llegaba elegido en la ruta.
  ///
  /// Se hace una sola vez: a partir de ahí manda lo que el usuario pulse en la
  /// lista, y volver a forzarlo le devolvería al de la ruta en cada relectura.
  bool _appliedRouteSelection = false;

  @override
  void initState() {
    super.initState();

    // Se relee siempre, no sólo la primera vez: borrar contenido en otra
    // pantalla se lleva por delante sus regiones, y los recuentos que decidían
    // si un fernie da para entrenar se habrían quedado mintiendo.
    _ferniesBloc.add(const LoadFerniesEvent());
    _ferniesBloc.add(const ReloadFernieRegionsEvent());

    // Si los fernies ya estaban leídos no va a llegar ningún estado nuevo que
    // dispare la selección por defecto, así que se resuelve en cuanto se puede
    // tocar el bloc.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _syncSelection(_ferniesBloc.state);
      _publishMediaList(_ferniesBloc.state);
    });
  }

  /// Deja elegido un fernie que exista.
  ///
  /// Se llama al entrar y cada vez que cambia la lista: por defecto queda
  /// elegido el primero, y si el que estaba elegido ha desaparecido se hace lo
  /// mismo en lugar de quedarse enseñando algo que ya no está.
  void _syncSelection(FerniesState state) {
    if (state.fernies.isEmpty) return;

    // El que venga en la ruta manda la primera vez, y sólo si existe: se puede
    // haber borrado entre que se pulsó y que se llegó aquí.
    if (!_appliedRouteSelection) {
      final wanted = widget.selectedFernieId;
      _appliedRouteSelection = true;

      if (wanted != null && state.fernies.any((f) => f.id == wanted)) {
        _ferniesBloc.add(FernieSelectedEvent(wanted));
        return;
      }
    }

    if (state.selectedFernie != null) return;

    _ferniesBloc.add(FernieSelectedEvent(state.fernies.first.id));
  }

  /// Deja en el bloc de contenido los contenidos del fernie elegido.
  ///
  /// Sin esto el visor no tendría lista por la que pasar con las flechas: lo que
  /// se ve aquí no sale de una consulta suya, sino de las regiones del fernie.
  /// Van sin repetir: un contenido con tres regiones da tres celdas, pero en el
  /// visor es un contenido y no tres.
  void _publishMediaList(FerniesState state) {
    final seen = <int>{};
    final media = <MediaSummaryEntity>[];

    for (final entry in state.regions) {
      if (seen.add(entry.media.id)) media.add(entry.media);
    }

    final ids = [for (final summary in media) summary.id];
    if (_sameAsPublished(ids)) return;

    _publishedMediaIds = ids;
    _mediaBloc.add(SetMediaListEvent(media));
  }

  bool _sameAsPublished(List<int> ids) {
    if (ids.length != _publishedMediaIds.length) return false;

    for (var index = 0; index < ids.length; index++) {
      if (ids[index] != _publishedMediaIds[index]) return false;
    }
    return true;
  }

  /// Pide los detalles del contenido de la región pulsada. El visor se abre
  /// cuando lleguen, que es lo que hacen todas las rejillas de la aplicación.
  void _openRegion(MediaCrop crop) {
    _pendingHighlightId = crop.id;
    _mediaBloc.add(MediaClickedEvent(media: crop.media));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FerniesBloc>.value(value: _ferniesBloc),
        BlocProvider<MediaBloc>.value(value: _mediaBloc),
      ],
      child: BlocListener<MediaBloc, MediaStates>(
        bloc: _mediaBloc,
        listenWhen: (previous, current) =>
            previous is! DetailedMedia && current is DetailedMedia,
        listener: (context, state) {
          final highlight = _pendingHighlightId;
          if (highlight == null) return;

          _pendingHighlightId = null;

          // Se abre el contenido entero y se le dice al visor qué región tiene
          // que señalar: la celda enseñaba sólo el recorte y sin la pista habría
          // que buscar a ojo de qué trozo se trataba.
          context.push(viewerRouteWithHighlight(highlight));
        },
        child: BlocConsumer<FerniesBloc, FerniesState>(
          bloc: _ferniesBloc,
          listener: (context, state) {
            _syncSelection(state);
            _publishMediaList(state);
          },
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FerniesState state) {
    final texts = AppLocalizations.of(context);

    // Sin fernies no hay nada que gestionar: se dice y punto. Mientras la
    // primera lectura está en marcha no se dice que no haya ninguno, todavía no
    // se sabe: se espera con el indicador.
    if (state.fernies.isEmpty) {
      return Padding(
        padding: AppSpacing.pagePadding,
        child: state.isLoaded
            ? FernEmptyState(
                imageAsset: fernEmptyImage,
                message: texts.noFerniesYet,
              )
            : const Center(child: FernProgressIndicator()),
      );
    }

    final selected = state.selectedFernie ?? state.fernies.first;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
      child: Row(
        children: [
          Expanded(child: _fernieContent(state, selected)),
          Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.l,
              bottom: AppSpacing.l,
            ),
            child: SizedBox(
              width: AppSizes.tagListWidth,
              // Al guardar o borrar un fernie la lista se vuelve a leer: hasta
              // que llegue se queda la de antes, con el indicador encima.
              child: FernBusyOverlay(
                isBusy: state.isBusy,
                // La lista va directamente sobre el fondo, sin superficie propia
                // de la que copiar el redondeo.
                radius: AppSizes.radiusMedium,
                child: FernieList(
                  fernies: state.fernies,
                  selectedFernieId: selected.id,
                  onSelected: (fernie) =>
                      _ferniesBloc.add(FernieSelectedEvent(fernie.id)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// La columna del fernie elegido: su ficha arriba y sus regiones debajo.
  ///
  /// La ficha se rehace al cambiar de fernie (de eso se encarga la clave): los
  /// campos arrancan con los valores del fernie, así que tienen que volver a
  /// nacer con los del nuevo.
  Widget _fernieContent(FerniesState state, FernieEntity fernie) {
    final texts = AppLocalizations.of(context);

    // Las celdas se arman una vez y se usan dos: para pintarlas y para saber en
    // qué orden están cuando se estira la selección con mayúsculas.
    final cells = groupRegionCells(state.regions);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: AppSpacing.l,
            bottom: AppSpacing.l,
          ),
          child: FernieCard(key: ValueKey(fernie.id), fernie: fernie),
        ),
        Expanded(
          child: MediaGrid.crops(
            crops: cells,
            columns: fernieManagerGridColumns,
            selectedCropIds: state.selectedRegionIds,
            onCropTap: _openRegion,
            // Mayúsculas + clic: la selección se estira hasta aquí desde la
            // última celda tocada, igual que en la rejilla de contenido.
            onCropRangeSelectionRequested: (crop) => _ferniesBloc.add(
              SelectRegionRangeEvent(
                regionIds: crop.ids,
                orderedCells: [for (final cell in cells) cell.ids],
              ),
            ),
            onCropSelectionToggled: (crop) => _ferniesBloc.add(
              // El tramo entero y no sólo su primer fotograma: la celda es una
              // escena, y borrar media escena no es lo que nadie pide.
              ToggleRegionSelectionEvent(
                crop.id,
                alsoRegionIds: crop.ids.skip(1).toList(),
              ),
            ),
            pendingWarning: texts.fernieRegionPending,
            // Si el fichero de una región ya no está, su fila sale de la base de
            // datos y con ella se van sus regiones: no puede quedar contenido
            // fuera de la base que siga contando para entrenar.
            onCropLoadFailed: (crop) =>
                _mediaBloc.add(MediaLoadFailedEvent(crop.media.id)),
            isLoading: state.areRegionsBusy,
            emptyMessage: texts.fernieNoRegions,
            // La superficie de esta pantalla es la de la ficha: la rejilla va
            // directamente sobre el fondo.
            hasSurface: false,
          ),
        ),
      ],
    );
  }
}
