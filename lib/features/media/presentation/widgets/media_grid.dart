import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/widgets/media_context_menu.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/utils/grid_layout_cache.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/features/media/presentation/widgets/highlight_scroll_marks.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/features/media/presentation/widgets/returning_masonry_grid.dart';
import 'package:Fern/features/media/presentation/widgets/viewed_media.dart';
import 'package:Fern/features/media/presentation/widgets/search_result_row.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/media/media_summary_entity.dart';
import '../../domain/entities/search/media_search_section_entity.dart';

/// Una celda que es **un recorte** de un contenido, no el contenido entero.
///
/// [id] identifica la celda y no el fichero: un mismo contenido con tres
/// regiones marcadas da tres celdas, cada una con su identificador, y la
/// selección se lleva por ese identificador.
///
/// Vive aquí y no en el dominio del reconocimiento porque la rejilla no tiene
/// por qué saber que existen los fernies: lo que pinta es un fichero y un
/// rectángulo suyo.
class MediaCrop {
  final int id;
  final MediaSummaryEntity media;
  final RegionCrop crop;

  /// Los fotogramas seguidos que la celda agrupa, cuando es un tramo de vídeo.
  ///
  /// [crop] es el primero de ellos. Con más de uno la celda se mueve sola, en
  /// bucle: varios fotogramas seguidos del mismo fernie son **una escena**, no
  /// cinco celdas casi idénticas puestas en fila.
  final List<RegionCrop> frames;

  /// Las regiones que la celda representa, [id] incluido.
  ///
  /// Es lo que hace que marcarla marque el tramo entero: agrupar es cosa de la
  /// interfaz, pero para quien la borra o la selecciona siguen siendo todas las
  /// regiones que son.
  final List<int> regionIds;

  const MediaCrop({
    required this.id,
    required this.media,
    required this.crop,
    this.frames = const [],
    this.regionIds = const [],
  });

  /// Las regiones de la celda, contando la de siempre cuando no se agrupa nada.
  List<int> get ids => regionIds.isEmpty ? [id] : regionIds;
}

class MediaGrid extends StatelessWidget {
  final List<MediaSummaryEntity> mediaList;
  final int columns;

  /// Los recortes de la variante [MediaGrid.crops]. `null` en las demás, que
  /// pintan contenidos enteros.
  final List<MediaCrop>? crops;

  /// Recortes marcados, por identificador de celda. La variante de recortes
  /// lleva su propia selección en vez de la del `MediaBloc`: lo que se marca
  /// aquí son regiones, y de esas el bloc de contenido no sabe nada.
  final Set<int> selectedCropIds;

  /// Qué hacer al pulsar un contenido en la variante [MediaGrid.picker].
  ///
  /// Es lo que la separa de la rejilla normal: allí pulsar abre el visor y
  /// marca, y las dos cosas las decide el `MediaBloc`. Aquí se está eligiendo
  /// una imagen para otra cosa, así que lo que pasa al pulsar lo pone quien
  /// pregunta.
  final void Function(MediaSummaryEntity media)? onMediaTap;

  final void Function(MediaCrop crop)? onCropTap;
  final void Function(MediaCrop crop)? onCropSelectionToggled;

  /// Mayúsculas + clic sobre un recorte: la selección se estira hasta él desde
  /// el último con el que se hizo algo, igual que en la rejilla de contenido.
  final void Function(MediaCrop crop)? onCropRangeSelectionRequested;

  /// Se invoca cuando el fichero de un recorte no se ha podido cargar. Quien lo
  /// escuche decide si la fila sobra.
  final void Function(MediaCrop crop)? onCropLoadFailed;

  /// Aviso que llevan los recortes cuyo contenido todavía no es definitivo.
  ///
  /// El texto viene de fuera: la rejilla pinta lo que le den y no se inventa
  /// mensajes. Sin él, los recortes no llevan aviso.
  final String? pendingWarning;

  /// Grupos de una búsqueda, cada uno con su cabecera. `null` en la rejilla
  /// normal, que pinta [mediaList] de un tirón.
  final List<MediaSearchSectionEntity>? sections;

  /// Si la rejilla va sobre una superficie propia. Con `false` el contenido va
  /// directamente sobre el fondo de la pantalla, para las pantallas en las que la
  /// superficie es de otra cosa (la ficha de gestión de etiquetas).
  final bool hasSurface;

  /// Hay una consulta en marcha: lo que se está viendo es lo de antes y está a
  /// punto de cambiar.
  ///
  /// Con contenido a la vista se pone el indicador de espera encima, y sin nada
  /// que enseñar el indicador ocupa el sitio de la rejilla: mientras se está
  /// leyendo no se puede decir que no haya nada, todavía no se sabe.
  final bool isLoading;

  /// Lo que está en marcha es una importación, y no una operación sobre lo que
  /// ya hay.
  ///
  /// Cambia lo que se ve y, sobre todo, **lo que se puede hacer**. El velo de
  /// espera existe para tapar contenido que está a punto de cambiar: mientras se
  /// borra una selección o se recarga una lista, tocar algo sería tocar lo que
  /// ya no va a estar. Una importación no cambia nada de lo que hay —sólo va
  /// añadiendo—, así que taparlo era impedir mirar la biblioteca durante los
  /// veinte minutos que tarda en traerse mil ficheros.
  final bool isImporting;

  /// Qué hacer si el usuario quiere parar lo que se está haciendo. Con esto
  /// puesto, el indicador de espera lleva encima el botón de parar; sin ello,
  /// sólo se espera.
  final VoidCallback? onStop;

  /// Ya se ha pedido parar y todavía no ha parado.
  ///
  /// Parar no es inmediato: la señal se mira entre un contenido y el siguiente,
  /// así que lo que se esté descargando termina de llegar. Sin decirlo, el botón
  /// parece no haber hecho nada y se pulsa otra vez.
  final bool isStopping;

  /// Lo que se dice cuando la rejilla está vacía. Sin decir nada, que la
  /// biblioteca está vacía, que es lo que toca en casi todas las pantallas.
  final String? emptyMessage;

  /// Lo que se dice debajo del mensaje cuando no hay nada: por qué está vacío o
  /// qué hacer. Sin él, la rejilla de la biblioteca pone el suyo.
  final String? emptyDescription;

  const MediaGrid({
    super.key,
    required this.mediaList,
    required this.columns,
    this.hasSurface = true,
    this.isLoading = false,
    this.isImporting = false,
    this.onStop,
    this.isStopping = false,
    this.returnsToViewed = false,
  })  : sections = null,
        crops = null,
        onMediaTap = null,
        selectedCropIds = const {},
        onCropTap = null,
        onCropSelectionToggled = null,
        onCropRangeSelectionRequested = null,
        onCropLoadFailed = null,
        pendingWarning = null,
        emptyMessage = null,
        emptyDescription = null;

  /// Rejilla de recortes: cada celda es una región de un contenido y se pinta
  /// con la proporción de la región, no con la del fichero.
  ///
  /// Es la rejilla de la pantalla de fernies. No necesita un `MediaBloc` por
  /// encima: la selección y lo que pasa al pulsar vienen de fuera.
  /// Si al volver del visor esta rejilla va a buscar lo que se acaba de mirar.
  ///
  /// Lo dice la pantalla y no esta clase: la de contenido y la de importación
  /// enseñan listas distintas, y volver a «esa» posición en la lista que no es
  /// sería saltar a un sitio cualquiera.
  final bool returnsToViewed;

  const MediaGrid.crops({
    super.key,
    required List<MediaCrop> this.crops,
    required this.columns,
    this.selectedCropIds = const {},
    this.onCropTap,
    this.onCropSelectionToggled,
    this.onCropRangeSelectionRequested,
    this.onCropLoadFailed,
    this.pendingWarning,
    this.hasSurface = true,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyDescription,
  })  : mediaList = const [],
        isImporting = false,
        isStopping = false,
        sections = null,
        onMediaTap = null,
        onStop = null,
        returnsToViewed = false;

  /// Rejilla para **elegir** un contenido: pulsar uno lo devuelve y ya está.
  ///
  /// Como la de recortes, no necesita un `MediaBloc` por encima. Y por lo mismo
  /// no lleva selección, ni menú del botón derecho, ni arrastre: aquí no se
  /// trabaja con la biblioteca, se coge una cosa de ella y se cierra.
  const MediaGrid.picker({
    super.key,
    required this.mediaList,
    required this.columns,
    required void Function(MediaSummaryEntity media) this.onMediaTap,
    this.hasSurface = true,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyDescription,
  })  : sections = null,
        crops = null,
        selectedCropIds = const {},
        onCropTap = null,
        onCropSelectionToggled = null,
        onCropRangeSelectionRequested = null,
        onCropLoadFailed = null,
        pendingWarning = null,
        isImporting = false,
        isStopping = false,
        onStop = null,
        returnsToViewed = false;

  /// Rejilla de resultados de búsqueda: el contenido va separado en grupos
  /// (descripciones, etiquetas y creadores) con una cabecera delante de cada
  /// uno.
  const MediaGrid.sections({
    super.key,
    this.emptyDescription,
    required List<MediaSearchSectionEntity> this.sections,
    required this.columns,
    this.hasSurface = true,
    this.isLoading = false,
    this.onStop,
  })  : mediaList = const [],
        isImporting = false,
        isStopping = false,
        returnsToViewed = false,
        onMediaTap = null,
        crops = null,
        selectedCropIds = const {},
        onCropTap = null,
        onCropSelectionToggled = null,
        onCropRangeSelectionRequested = null,
        onCropLoadFailed = null,
        pendingWarning = null,
        emptyMessage = null;

  /// De dónde sale todo lo que la rejilla deriva: la lista que está pintando.
  ///
  /// Es la clave de la caché, así que tiene que ser **la instancia** y no una
  /// copia: ninguna de las tres se toca por dentro, cada cambio construye una
  /// nueva.
  Object get _source => sections ?? crops ?? mediaList;

  /// Dónde se guarda lo derivado entre pantallas. Ver [GridLayoutCache].
  ///
  /// Sin localizador montado —una prueba que pinta la rejilla y nada más— vale
  /// una suelta: la clave es la identidad de la lista, así que una caché
  /// compartida no puede contestar por la lista de otro.
  GridLayoutCache get _cache => getIt.isRegistered<GridLayoutCache>()
      ? getIt<GridLayoutCache>()
      : _looseCache;

  static final GridLayoutCache _looseCache = GridLayoutCache();

  /// Todo el contenido de la rejilla en el orden en el que se pinta, que es el
  /// que sigue la selección por rango. Con grupos, los recorre de arriba abajo
  /// como una sola lista, igual que se ven.
  List<int> get _orderedIds => _cache.idsOf(
        _source,
        () => switch ((sections, crops)) {
          (final sections?, _) => [
              for (final section in sections)
                for (final media in section.media) media.id,
            ],
          (_, final crops?) => [for (final crop in crops) crop.id],
          _ => [for (final media in mediaList) media.id],
        },
      );

  /// La proporción de cada celda, por la caché y por lo mismo.
  List<double?> get _ratios =>
      _cache.ratiosOf(_source, () => [for (final media in mediaList) _ratioOf(media)]);

  /// El hueco que la rejilla deja hasta el borde de la ventana.
  ///
  /// La pantalla ya separa por arriba y por la izquierda (que es donde están la
  /// cabecera y el menú), así que aquí se completan los otros dos lados: la
  /// superficie nunca toca el borde, ni con contenido ni vacía.
  static const _padding =
      EdgeInsets.only(bottom: AppSpacing.l, right: AppSpacing.l);

  @override
  Widget build(BuildContext context) {
    final isEmpty = sections?.isEmpty ?? crops?.isEmpty ?? mediaList.isEmpty;

    if (isEmpty) {
      // Mientras se está leyendo, el indicador de espera; sólo cuando ya se sabe
      // que no hay nada se dice que la rejilla está vacía.
      // Esperando se pinta el hueco de lo que va a llegar, no un círculo dando
      // vueltas: dice además **qué** viene y cuánto va a ocupar, así que al
      // llegar el contenido no se recoloca la pantalla de golpe.
      //
      // El botón de parar va encima, que es lo único que se puede hacer mientras.
      final Widget placeholder = isLoading
          ? Stack(
              children: [
                Positioned.fill(child: FernSkeletonGrid(columns: columns)),
                if (_stopButton(context) case final stop?)
                  Positioned.fill(child: Center(child: stop)),
              ],
            )
          : FernEmptyState(
              imageAsset: fernEmptyImage,
              message: emptyMessage ?? AppLocalizations.of(context).emptyLibrary,
              // Sin mensaje propio, la rejilla es la de la biblioteca y se
              // explica sola. Con uno puesto, quien lo puso dirá si hace falta
              // decir algo más: `emptyDescription`.
              description: emptyDescription ??
                  (emptyMessage == null
                      ? AppLocalizations.of(context).emptyLibraryHint
                      : null),
            );

      return Padding(
        padding: _padding,
        child: hasSurface
            ? FernSurface(width: double.infinity, child: placeholder)
            : SizedBox(width: double.infinity, child: placeholder),
      );
    }

    final orderedIds = _orderedIds;

    // Elegir no pasa por la capa del menú del botón derecho: lo que ese menú
    // ofrece —borrar, etiquetar, mandar a reconocer— es trabajar con la
    // biblioteca, y aquí sólo se está cogiendo una imagen prestada.
    if (onMediaTap case final onTap?) {
      return Padding(
        padding: _padding,
        child: FernBusyOverlay(
          isBusy: isLoading,
          radius: hasSurface ? AppSizes.radiusSurface : AppSizes.radiusMedium,
          child: hasSurface
              ? FernSurface(
                  clipBehavior: Clip.antiAlias,
                  child: _buildPickerGrid(onTap),
                )
              : _buildPickerGrid(onTap),
        ),
      );
    }

    final content = _MediaContextMenuLayer(
      builder: (context, requestMenu) => switch ((sections, crops)) {
        (final sections?, _) when sections.isNotEmpty =>
          _buildSections(orderedIds, requestMenu),
        (_, final crops?) => _buildCropGrid(crops),
        _ => _buildGrid(orderedIds, requestMenu),
      },
    );

    final highlight = getIt<RecognitionHighlight>();

    // Importando no se tapa: lo que llega se suma a lo que ya hay, y taparlo
    // sería impedir mirar la biblioteca mientras dura. La cuenta y el botón de
    // parar se enseñan encima, sin quitarle el paso a nada.
    if (isLoading && isImporting) {
      return Padding(
        padding: _padding,
        child: Column(
          children: [
            _importingBar(context),
            Expanded(child: _framed(content, orderedIds, highlight)),
          ],
        ),
      );
    }

    return Padding(
      padding: _padding,
      child: FernBusyOverlay(
        isBusy: isLoading,
        action: _stopButton(context),
        radius: hasSurface ? AppSizes.radiusSurface : AppSizes.radiusMedium,
        // Las marcas van **encima** del scroll y fuera de la superficie: dicen a
        // qué altura está lo señalado, que en una rejilla de trescientas
        // miniaturas casi siempre queda fuera de la pantalla.
        child: _framed(content, orderedIds, highlight),
      ),
    );
  }

  /// La rejilla con sus marcas de desplazamiento encima.
  ///
  /// Las marcas van **encima** del scroll y fuera de la superficie: dicen a qué
  /// altura está lo señalado, que en una rejilla de trescientas miniaturas casi
  /// siempre queda fuera de la pantalla.
  Widget _framed(
    Widget content,
    List<int> orderedIds,
    RecognitionHighlight highlight,
  ) {
    return Stack(
      children: [
        hasSurface
            ? FernSurface(clipBehavior: Clip.antiAlias, child: content)
            : content,
        ListenableBuilder(
          listenable: highlight,
          builder: (context, _) => HighlightScrollMarks(
            orderedIds: orderedIds,
            highlighted: highlight.mediaIds,
          ),
        ),
      ],
    );
  }

  /// Lo que se enseña mientras entra contenido: que está entrando, y el botón
  /// de parar. Encima de la rejilla y sin quitarle el paso a nada.
  Widget _importingBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          const Expanded(child: LinearProgressIndicator(minHeight: 2)),
          if (_stopButton(context) case final stop?) ...[
            const SizedBox(width: AppSpacing.s),
            stop,
          ],
        ],
      ),
    );
  }

  /// El botón que para lo que se está haciendo, o `null` si esta rejilla no
  /// deja pararlo.
  ///
  /// Va del color del indicador que tiene debajo porque es parte de él: no es
  /// una acción de la pantalla, es lo único que se puede hacer con la espera
  /// que se está mirando.
  Widget? _stopButton(BuildContext context) {
    if (onStop == null) return null;

    final color = Theme.of(context).progressIndicatorTheme.color ??
        Theme.of(context).colorScheme.primary;

    final texts = AppLocalizations.of(context);

    return IconButton(
      // Mientras para, el botón lo dice y deja de responder: volver a pulsarlo
      // no para más rápido, y sin apagarlo parece que la primera vez no contó.
      tooltip: isStopping ? texts.importStopping : texts.actionStopImport,
      onPressed: isStopping ? null : onStop,
      icon: Icon(
        isStopping ? Symbols.hourglass_top : Symbols.stop_circle,
        color: color,
      ),
      iconSize: AppSizes.iconLarge,
    );
  }

  /// Cuánto se separa la rejilla de su borde.
  ///
  /// Dentro de una superficie hace falta más: su curva muerde las celdas de las
  /// esquinas. Fuera de ella no, y ponerlo igual sería un margen de más en las
  /// pantallas de gestión, donde la rejilla llega hasta el borde a propósito.
  double get _inset => hasSurface ? AppSpacing.gridInset : AppSpacing.s;

  /// El relleno de la rejilla, con sitio a la derecha para la barra.
  ///
  /// El carril va **sumado** al margen de siempre, no en su lugar: el margen es
  /// lo que separa las miniaturas del borde y el carril es lo que ocupa la barra.
  /// Quedandose con el mayor de los dos, la barra se comia el margen y la
  /// pastilla acababa rozando la esquina de la ultima miniatura de cada fila.
  EdgeInsets get _gridPadding => EdgeInsets.fromLTRB(
        _inset,
        _inset,
        _inset + AppSizes.scrollbarLane,
        _inset,
      );

  Widget _buildGrid(List<int> orderedIds, RequestMediaMenu requestMenu) {
    return ReturningMasonryGrid(
      padding: _gridPadding,
      // Lo justo para que desplazarse no vaya construyendo a tirones, y no
      // tanto como para tener cientos de celdas montadas fuera de la pantalla:
      // cada una pide su miniatura y decodifica su imagen.
      cacheExtent: mediaGridCacheExtent,
      columns: columns,
      spacing: AppSpacing.s,
      // Con esto la rejilla se calcula entera antes de pintar nada, y la barra
      // de desplazamiento deja de moverse sola.
      ratios: _ratios,
      cache: _cache,
      fallbackRatio: mediaFallbackAspectRatio,
      focusIndex: _returnIndex,
      itemBuilder: (context, index) =>
          _buildItem(
            mediaList[index],
            orderedIds,
            requestMenu,
            // Solo la rejilla llana vuela: aqui cada contenido sale una vez, asi
            // que su etiqueta es unica. En la vista por grupos no.
            fliesToViewer: true,
          ),
    );
  }

  /// La rejilla de elegir: una celda por contenido y nada más que pulsar.
  Widget _buildPickerGrid(void Function(MediaSummaryEntity media) onTap) {
    return ReturningMasonryGrid(
      padding: _gridPadding,
      cacheExtent: mediaGridCacheExtent,
      columns: columns,
      spacing: AppSpacing.s,
      ratios: _ratios,
      cache: _cache,
      fallbackRatio: mediaFallbackAspectRatio,
      itemBuilder: (context, index) => MediaItem(
        key: ValueKey(mediaList[index].id),
        media: mediaList[index],
        onTap: () => onTap(mediaList[index]),
      ),
    );
  }

  /// La proporción de un recorte: la de la región, no la del fichero.
  ///
  /// Sin el tamaño del fichero no se puede saber: una región es una fracción de
  /// él, y una fracción de algo que no se sabe cuánto mide no mide nada.
  double? _cropRatioOf(MediaCrop crop) {
    final media = crop.media;
    if (!media.hasSize) return null;

    return crop.crop.aspectRatio(
      Size(media.width!.toDouble(), media.height!.toDouble()),
    );
  }

  /// La proporción de un contenido, o `null` si todavía no se sabe.
  ///
  /// Sale del sumario y no del fichero: es justamente lo que se guarda para no
  /// tener que abrirlo. Lo que no la tenga se coloca con la de reserva y se
  /// recoloca solo en cuanto la rejilla la descubra.
  double? _ratioOf(MediaSummaryEntity media) {
    if (!media.hasSize) return null;

    return media.width! / media.height!;
  }

  /// A qué celda hay que volver, si es que hay que volver a alguna.
  int? get _returnIndex {
    if (!returnsToViewed) return null;

    // Se pregunta cada vez y no se guarda: el ajuste se puede apagar mientras
    // se está mirando la rejilla, y lo que vale es lo que esté puesto ahora.
    if (!getIt<SettingsRepository>().getSettings().returnToViewedMedia) {
      return null;
    }

    final viewed = getIt<ViewedMedia>().mediaId;
    if (viewed == null) return null;

    final index = mediaList.indexWhere((media) => media.id == viewed);

    // Lo que se miró puede no estar en esta lista: se ha borrado, o se ha
    // filtrado desde que se abrió.
    return index < 0 ? null : index;
  }

  /// Un bloque por grupo: la cabecera que lo identifica y su rejilla. Todo va en
  /// el mismo scroll, así que los grupos se recorren de arriba abajo como una
  /// sola lista.
  Widget _buildSections(List<int> orderedIds, RequestMediaMenu requestMenu) {
    return CustomScrollView(
      slivers: [
        for (final section in sections!) ...[
          // Un grupo sin título no lleva cabecera: es el del cruce de varias
          // pastillas, y lo que se está buscando ya se lee en la barra. Una
          // cabecera vacía sería una franja de nada empujando la rejilla.
          if (section.title.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.xs,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchResultRow.header(
                  label: section.title,
                  imagePath: section.imagePath,
                  type: section.type,
                ),
              ),
            ),
          SliverPadding(
            // Mismo carril para la barra que en la rejilla normal: esto se
            // desplaza igual y esta dentro de la misma superficie.
            padding: EdgeInsets.only(
              left: _inset,
              right: _inset + AppSizes.scrollbarLane,
            ),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.s,
              crossAxisSpacing: AppSpacing.s,
              childCount: section.media.length,
              itemBuilder: (context, index) =>
                  _buildItem(section.media[index], orderedIds, requestMenu),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s)),
      ],
    );
  }

  /// La rejilla de recortes. Se arma igual que la de contenidos: lo único que
  /// cambia es que cada celda lleva su región y su propia selección.
  Widget _buildCropGrid(List<MediaCrop> crops) {
    return ReturningMasonryGrid(
      padding: _gridPadding,
      cacheExtent: mediaGridCacheExtent,
      columns: columns,
      spacing: AppSpacing.s,
      ratios: [for (final crop in crops) _cropRatioOf(crop)],
      fallbackRatio: mediaFallbackAspectRatio,
      itemBuilder: (context, index) {
        final crop = crops[index];

        return MediaItem(
          // La celda es la región, no el fichero: sin esto, dos regiones del
          // mismo contenido compartirían estado al desplazar la rejilla.
          key: ValueKey(crop.id),
          media: crop.media,
          crop: crop.crop,
          frames: crop.frames,
          // El contenido pendiente de revisar se avisa: su región está marcada,
          // pero no cuenta para entrenar mientras no se dé por definitivo.
          warning: crop.media.isImported ? null : pendingWarning,
          isSelected: selectedCropIds.contains(crop.id),
          onTap: onCropTap == null ? null : () => onCropTap!(crop),
          onSelectionToggled: onCropSelectionToggled == null
              ? null
              : () => onCropSelectionToggled!(crop),
          onRangeSelectionRequested: onCropRangeSelectionRequested == null
              ? null
              : () => onCropRangeSelectionRequested!(crop),
          onLoadFailed:
              onCropLoadFailed == null ? null : () => onCropLoadFailed!(crop),
        );
      },
    );
  }

  Widget _buildItem(
    MediaSummaryEntity media,
    List<int> orderedIds,
    RequestMediaMenu requestMenu, {
    bool fliesToViewer = false,
  }) {
    final highlight = getIt<RecognitionHighlight>();

    return BlocSelector<MediaBloc, MediaStates, Set<int>>(
      key: key,
      selector: (state) => state.selectedIds,
      builder: (context, selectedIds) {
        final isSelected = selectedIds.contains(media.id);

        return ListenableBuilder(
        // Se escucha aquí y no arriba para que apagar el destacado no rehaga la
        // rejilla entera: son trescientas celdas, y cada una sabe si le toca.
        listenable: highlight,
          builder: (context, _) => MediaItem(
            media: media,
            isSelected: isSelected,
            fliesToViewer: fliesToViewer,
            isHighlighted: highlight.contains(media.id),
            // La regla del arrastre: con selección, la selección entera; sin
            // ella, sólo ésta. Arrastrar una celda que no está marcada teniendo
            // otras marcadas mueve las marcadas, que es lo acordado, y por eso
            // el retrato del arrastre lleva el número delante.
            dragIds: selectedIds.isEmpty ? [media.id] : selectedIds.toList(),
            // Y la misma regla para el menú del botón derecho.
            onContextMenu: (position) => requestMenu(
              media,
              position,
              selectedIds.isEmpty ? [media.id] : selectedIds.toList(),
            ),
            // Pasar el ratón por encima es una de las tres formas de dar el
            // aviso por visto; las otras dos son salir de la pantalla y abrir
            // algo.
            onHighlightSeen: highlight.clear,
            onTap: () =>
                context.read<MediaBloc>().add(MediaClickedEvent(media: media)),
            onSelectionToggled: () => context
                .read<MediaBloc>()
                .add(ToggleMediaSelectionEvent(media: media)),
            // Mayúsculas + clic: la selección se estira hasta aquí desde el
            // último elemento marcado, siguiendo el orden de la rejilla.
            onRangeSelectionRequested: () => context.read<MediaBloc>().add(
                  SelectMediaRangeEvent(media: media, orderedIds: orderedIds),
                ),
            // Si el contenido no se pinta porque su fichero ya no está, la fila
            // de la base de datos sobra y el elemento desaparece de la rejilla.
            onLoadFailed: () =>
                context.read<MediaBloc>().add(MediaLoadFailedEvent(media.id)),
          ),
        );
      },
    );
  }
}

/// Cómo se pide el menú contextual: sobre qué contenido, dónde se ha pulsado y
/// a qué contenidos se va a aplicar.
typedef RequestMediaMenu = void Function(
  MediaSummaryEntity media,
  Offset globalPosition,
  List<int> targetIds,
);

/// La capa que sabe abrir el menú del botón derecho encima de la rejilla.
///
/// Va aparte y no en `MediaGrid` para no convertir la rejilla entera en un
/// widget con estado: lo único que cambia al abrir el menú es el menú, y
/// rehacer por eso las trescientas celdas que hay debajo sería pagar el
/// repintado más caro de la aplicación por enseñar un panel de seis filas.
class _MediaContextMenuLayer extends StatefulWidget {
  final Widget Function(BuildContext context, RequestMediaMenu requestMenu)
      builder;

  const _MediaContextMenuLayer({required this.builder});

  @override
  State<_MediaContextMenuLayer> createState() => _MediaContextMenuLayerState();
}

class _MediaContextMenuLayerState extends State<_MediaContextMenuLayer> {
  /// Con qué se sitúa el menú: las coordenadas del `Stack` que lo contiene.
  final GlobalKey _stackKey = GlobalKey();

  MediaSummaryEntity? _media;
  Offset? _position;
  List<int> _targetIds = const [];

  void _open(
    MediaSummaryEntity media,
    Offset globalPosition,
    List<int> targetIds,
  ) {
    final box = _stackKey.currentContext?.findRenderObject();

    setState(() {
      _media = media;
      _targetIds = targetIds;
      _position = box is RenderBox
          ? box.globalToLocal(globalPosition)
          : globalPosition;
    });
  }

  void _close() {
    if (!mounted || _position == null) return;

    setState(() {
      _media = null;
      _position = null;
      _targetIds = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = _media;
    final position = _position;

    return Stack(
      key: _stackKey,
      children: [
        widget.builder(context, _open),
        if (media != null && position != null)
          Positioned.fill(
            child: FernContextMenu(
              position: position,
              onDismiss: _close,
              child: MediaContextMenu(
                media: media,
                targetIds: _targetIds,
                onDone: _close,
              ),
            ),
          ),
      ],
    );
  }
}
