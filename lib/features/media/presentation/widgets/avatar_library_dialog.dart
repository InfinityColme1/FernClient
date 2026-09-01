import 'dart:async';

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/search/search_criterion_entity.dart';
import 'package:Fern/features/media/domain/services/avatar_source.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_media_list_usercase.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_tree_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_media_by_criteria_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/media/presentation/widgets/tag_list.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Elige una imagen **de la propia biblioteca** para usarla de avatar.
///
/// La cara de una etiqueta suele estar en su propio contenido, y hasta ahora la
/// única forma de ponerla era ir a buscar el fichero por el disco con el
/// explorador: una imagen que la aplicación ya tiene guardada, sabe enseñar y
/// tiene etiquetada.
///
/// Es la biblioteca de verdad, con lo mismo con lo que se busca en la pantalla
/// de contenido: el buscador arriba y el árbol de etiquetas al lado. Los dos se
/// cruzan, como las pastillas de la barra —una etiqueta y un texto enseñan lo
/// que cumple las dos cosas—, y por eso van por el mismo camino: aquí no puede
/// haber una segunda forma de buscar que diga otra cosa que la de siempre.
///
/// Devuelve el contenido elegido, o `null` si se cierra sin elegir. **No decide
/// qué se hace con él**: quien lo abre recorta y guarda.
class AvatarLibraryDialog extends StatefulWidget {
  /// El árbol de etiquetas y la lista de contenido, ya dados.
  ///
  /// Normalmente llegan `null` y se leen al abrir. Se pueden dar hechos desde
  /// fuera, que es lo que hacen las pruebas para no montar media aplicación.
  final List<TagEntity>? tags;
  final List<MediaSummaryEntity>? media;

  const AvatarLibraryDialog({super.key, this.tags, this.media});

  @override
  State<AvatarLibraryDialog> createState() => _AvatarLibraryDialogState();
}

class _AvatarLibraryDialogState extends State<AvatarLibraryDialog> {
  final _tagTree = getIt<GetTagTreeUseCase>();
  final _mediaList = getIt<GetMediaListUsercase>();
  final _search = getIt<SearchMediaByCriteriaUseCase>();

  late List<TagEntity> _tags = widget.tags ?? const [];
  late List<MediaSummaryEntity> _media = widget.media ?? const [];
  late bool _isLoading = widget.media == null;

  /// La etiqueta por la que se está filtrando, si hay alguna.
  TagEntity? _tag;

  String _query = '';

  /// La espera antes de buscar lo escrito, para no lanzar una consulta por
  /// tecla.
  Timer? _debounce;

  /// Cuántas búsquedas se han pedido. Lo que llega tarde se descarta: escribir
  /// deprisa lanza varias, y la última en salir no es siempre la última en
  /// volver.
  int _requests = 0;

  @override
  void initState() {
    super.initState();

    if (widget.tags == null) unawaited(_loadTags());
    if (widget.media == null) unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final result = await _tagTree();
    if (!mounted || result is! DataSuccess) return;

    setState(() => _tags = result.data ?? const []);
  }

  /// Lee el contenido que cumple lo que hay puesto ahora mismo.
  ///
  /// Sin nada puesto es la biblioteca entera; con etiqueta, texto, o los dos, va
  /// por el mismo camino que la barra de búsqueda.
  Future<void> _load() async {
    final request = ++_requests;
    setState(() => _isLoading = true);

    final criteria = libraryPickerCriteria(tag: _tag, query: _query);

    final media =
        criteria.isEmpty ? await _wholeLibrary() : await _matching(criteria);

    if (!mounted || request != _requests) return;

    setState(() {
      _media = media;
      _isLoading = false;
    });
  }

  Future<List<MediaSummaryEntity>> _wholeLibrary() async {
    final result = await _mediaList();

    return result is DataSuccess ? result.data ?? const [] : const [];
  }

  /// Lo que cumple los criterios, en una sola lista y sin repetidos.
  ///
  /// La búsqueda devuelve grupos —descripciones, etiquetas, creadores— y el
  /// mismo contenido puede salir en dos. Aquí se está eligiendo una imagen:
  /// verla dos veces sólo obliga a mirar el doble.
  Future<List<MediaSummaryEntity>> _matching(
    List<SearchCriterionEntity> criteria,
  ) async {
    final result = await _search(
      params: (criteria: criteria, order: MediaSortOrder.newestFirst),
    );
    if (result is! DataSuccess) return const [];

    final seen = <int>{};

    return [
      for (final section in result.data ?? const [])
        for (final media in section.media)
          if (seen.add(media.id)) media,
    ];
  }

  /// Pulsar la etiqueta ya elegida la suelta: es la única forma de volver a la
  /// biblioteca entera sin cerrar el diálogo.
  void _chooseTag(TagEntity tag) {
    setState(() => _tag = _tag?.id == tag.id ? null : tag);
    unawaited(_load());
  }

  void _type(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(searchDebounceDuration, () => unawaited(_load()));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.libraryPickerMaxWidth,
      leftContent: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: AppSizes.libraryPickerHeight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El árbol entero, con su propio buscador dentro: es la lista de la
            // pantalla de gestión, sin arrastre. Aquí no se reordena nada.
            SizedBox(
              width: AppSizes.tagListWidth,
              child: TagList(
                tags: _tags,
                // Personas y etiquetas juntas: aquí no se está gestionando el
                // árbol, se está buscando una imagen, y para eso «Marinette» es
                // una etiqueta más.
                mixesPeople: true,
                selectedTagId: _tag?.id,
                onSelected: _chooseTag,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                children: [
                  FernFilterField(
                    hintText: texts.searchEllipsisHint,
                    onChanged: _type,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Expanded(
                    child: MediaGrid.picker(
                      mediaList: _media,
                      columns: mediaGridColumns,
                      isLoading: _isLoading,
                      emptyMessage: texts.avatarLibraryEmpty,
                      onMediaTap: (media) => Navigator.of(context).pop(media),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
