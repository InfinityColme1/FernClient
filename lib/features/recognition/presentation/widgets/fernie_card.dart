import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/delete_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/update_fernie_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_states.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_tag_mark.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ficha del fernie elegido en la pantalla de gestión de fernies.
///
/// Lleva lo mismo que las fichas de etiqueta y de creador —avatar editable con
/// el nombre debajo, campo del nombre y botonera— y una cosa que sólo tiene
/// ésta: el selector de a qué se enlaza, que es lo que convierte una detección
/// en una propuesta de etiquetado.
///
/// Escribe con los casos de uso, sin pasar por el bloc, igual que `TagCard`; lo
/// que sí hace es avisar al `FerniesBloc` de que relea, porque la lista de al
/// lado y el menú de asignación del visor salen de él.
class FernieCard extends StatefulWidget {
  final FernieEntity fernie;

  const FernieCard({super.key, required this.fernie});

  @override
  State<FernieCard> createState() => _FernieCardState();
}

class _FernieCardState extends State<FernieCard> {
  final _searchTags = getIt<SearchTagsUseCase>();
  final _searchCreators = getIt<SearchCreatorsUseCase>();
  final _updateFernie = getIt<UpdateFernieUseCase>();
  final _deleteFernie = getIt<DeleteFernieUseCase>();
  final _avatarStorage = getIt<AvatarStorageService>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.fernie.name);

  late String? _picturePath = widget.fernie.picturePath;

  /// A qué se enlaza y con qué. Los tres campos van juntos porque cambiar de
  /// tipo tiene que dejar limpio el identificador del tipo anterior: un fernie
  /// no puede proponer una etiqueta y un creador a la vez.
  late FernieLinkKind _linkKind = widget.fernie.linkKind;
  late int? _linkedId =
      widget.fernie.linkedTagId ?? widget.fernie.linkedCreatorId;

  /// Lo que hay escrito en el buscador del enlace.
  ///
  /// Se guarda aparte de [_linkedId] porque lo que manda al guardar es el campo:
  /// vaciarlo deja el fernie sin enlace aunque tuviera uno al entrar.
  late String _linkQuery = widget.fernie.linkedName ?? '';

  /// Clave del buscador del enlace. Cambiarla lo hace nacer de nuevo, que es la
  /// forma de vaciarlo desde fuera.
  Key _linkFieldKey = UniqueKey();

  /// Hay una escritura en marcha (guardar, borrar o copiar el avatar elegido).
  bool _isBusy = false;

  Future<void> _run(Future<void> Function() operation) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  /// Elige la imagen del avatar y se queda con la copia que guarda la
  /// aplicación, como en las demás fichas.
  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);

    final path = result?.files.single.path;
    if (path == null) return;

    await _run(() async {
      final storedPath = await _avatarStorage.store(path);
      if (!mounted) return;

      setState(() => _picturePath = storedPath);
    });
  }

  Future<List<TagEntity>> _searchLinkTags(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
  }

  Future<List<CreatorEntity>> _searchLinkCreators(String query) async {
    final result = await _searchCreators(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
  }

  /// Cambia el tipo de enlace y suelta lo que hubiera elegido del tipo anterior.
  void _changeLinkKind(FernieLinkKind? kind) {
    if (kind == null || kind == _linkKind) return;

    setState(() {
      _linkKind = kind;
      _linkedId = null;
      _linkQuery = '';
      _linkFieldKey = UniqueKey();
    });
  }

  /// Suelta el enlace sin cambiar de tipo. El cambio se escribe al guardar, que
  /// es cuando el campo vacío se manda como «sin enlace».
  void _removeLink() {
    setState(() {
      _linkKind = FernieLinkKind.none;
      _linkedId = null;
      _linkQuery = '';
      _linkFieldKey = UniqueKey();
    });
  }

  /// Escribe los datos nuevos del fernie. Sus regiones no se tocan.
  ///
  /// Con el buscador del enlace vacío el fernie se queda **sin enlace**, aunque
  /// tuviera uno al entrar: manda lo que dice el formulario, igual que la ficha
  /// de etiquetas con su etiqueta padre.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final hasLink = _linkQuery.trim().isNotEmpty && _linkedId != null;

    final result = await _updateFernie(
      params: widget.fernie.copyWith(
        name: name,
        picturePath: _picturePath,
        linkedTagId:
            hasLink && _linkKind == FernieLinkKind.tag ? _linkedId : null,
        linkedCreatorId:
            hasLink && _linkKind == FernieLinkKind.creator ? _linkedId : null,
      ),
    );
    if (result is! DataSuccess || !mounted) return;

    context.read<FerniesBloc>().add(const LoadFerniesEvent());
  }

  /// Borra el fernie y, con él, sus regiones. El contenido sobre el que estaban
  /// marcadas no se toca.
  Future<void> _delete() async {
    final result = await _deleteFernie(params: widget.fernie.id);
    if (result is! DataSuccess || !mounted) return;

    context.read<FerniesBloc>().add(const LoadFerniesEvent());
  }

  // ---------------------------------------------------------------------------
  // Pintado
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    return FernBusyOverlay(
      isBusy: _isBusy,
      color: context.colors.white,
      child: FernSurface(
        color: context.colors.white,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FernDialogSidePanel(
                    // Sin nombre se enseña el del fernie en tono apagado: el
                    // campo está vacío, pero el fernie sigue llamándose así.
                    title: name.isEmpty ? widget.fernie.name : name,
                    titleColor: name.isEmpty ? context.colors.unremarked : null,
                    avatar: FernEditableAvatar(
                      imagePath: _picturePath,
                      fallbackIcon: Icons.face_retouching_natural,
                      fallbackAsset: icFernie,
                      radius: AppSizes.avatarXLarge,
                      iconSize: AppSizes.iconHuge,
                      onTap: _pickImage,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FernLabeledTextField(
                        label: texts.fernieNameLabel,
                        hintText: texts.enterNameHint,
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _linkField(texts),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _counters(texts),
            const SizedBox(height: AppSpacing.m),
            // Como en las fichas hermanas: los botones se reparten en varias
            // líneas si no caben, el rosa borra y el lavanda fuerte guarda.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                FernPillButton(
                  label: texts.actionDeleteFernie,
                  icon: Icons.delete_outline,
                  backgroundColor: context.colors.error,
                  foregroundColor: Colors.white,
                  onPressed: _isBusy ? null : () => _run(_delete),
                ),
                FernPillButton(
                  label: texts.actionRemoveLink,
                  icon: Icons.link_off,
                  backgroundColor: context.colors.secondary,
                  foregroundColor: context.colors.black,
                  onPressed:
                      _linkKind == FernieLinkKind.none ? null : _removeLink,
                ),
                _deleteRegionsButton(texts),
                FernPillButton(
                  label: texts.actionSave,
                  icon: Icons.check,
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.black,
                  onPressed: _isBusy ? null : () => _run(_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// El selector de a qué se enlaza: primero de qué tipo y, si es alguno, cuál.
  Widget _linkField(AppLocalizations texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FernFieldLabel(text: texts.fernieLinkLabel),
        const SizedBox(height: AppSpacing.s),
        FernDropdownPill<FernieLinkKind>(
          value: _linkKind,
          items: FernieLinkKind.values,
          labelBuilder: (kind) => switch (kind) {
            FernieLinkKind.none => texts.fernieLinkNone,
            FernieLinkKind.tag => texts.fernieLinkTag,
            FernieLinkKind.creator => texts.fernieLinkCreator,
          },
          onChanged: _isBusy ? null : _changeLinkKind,
        ),
        const SizedBox(height: AppSpacing.s),
        switch (_linkKind) {
          // Un fernie sin enlace no es un fernie a medias: es el auxiliar, el
          // que sólo aporta muestras. Se dice, para que no parezca un hueco por
          // rellenar.
          FernieLinkKind.none => Text(
              texts.fernieLinkNoneHint,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.colors.unremarked),
            ),
          FernieLinkKind.tag => FernEntitySearchField<TagEntity>(
              key: _linkFieldKey,
              label: '',
              hintText: texts.searchEllipsisHint,
              initialValue: _linkQuery,
              search: _searchLinkTags,
              labelOf: (tag) => tag.name,
      // Las marcadas se distinguen al autocompletar: elegir una sin
      // saberlo es esconder contenido sin querer.
      trailingOf: (tag) => tag.isUnderNsfw ? const NsfwTagMark() : null,
              onSelected: (tag) => setState(() => _linkedId = tag.id),
              onChanged: (query) => setState(() => _linkQuery = query),
              debounce: searchDebounceDuration,
            ),
          FernieLinkKind.creator => FernEntitySearchField<CreatorEntity>(
              key: _linkFieldKey,
              label: '',
              hintText: texts.searchEllipsisHint,
              initialValue: _linkQuery,
              search: _searchLinkCreators,
              labelOf: (creator) => creator.name,
              onSelected: (creator) => setState(() => _linkedId = creator.id),
              onChanged: (query) => setState(() => _linkQuery = query),
              debounce: searchDebounceDuration,
            ),
        },
      ],
    );
  }

  /// Cuántas regiones tiene el fernie y sobre cuántos contenidos, con los avisos
  /// que correspondan.
  ///
  /// Los avisos no son adorno: YOLO necesita muchas más muestras de las que uno
  /// intuye, y sin decirlo aquí la conclusión al entrenar sería que la función
  /// no funciona.
  Widget _counters(AppLocalizations texts) {
    final theme = Theme.of(context);
    final fernie = widget.fernie;

    final warnings = <String>[
      if (fernie.regionCount < fernieMinRegions) texts.fernieFewRegions,
      if (fernie.regionCount >= fernieMinRegions &&
          fernie.regionCount < fernieRecommendedRegions)
        texts.fernieRecommendedRegions(fernieRecommendedRegions),
      if (fernie.regionCount > 0 && fernie.mediaCount < fernieMinDistinctMedia)
        texts.fernieLowVariety,
      // El enlace apunta a algo que ya no está: el fernie sigue entrenando, pero
      // ha dejado de proponer nada y conviene enterarse aquí y no al reconocer.
      if (fernie.linkKind != FernieLinkKind.none && fernie.linkedName == null)
        texts.fernieLinkMissing,
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${texts.fernieRegionCount(fernie.regionCount)} '
            '${texts.fernieMediaCount(fernie.mediaCount)}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: AppSizes.iconSmall,
                    color: context.colors.terciary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(warning, style: theme.textTheme.labelSmall),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Borra las regiones marcadas en la rejilla. Sin nada marcado no hay qué
  /// borrar, así que queda atenuado.
  Widget _deleteRegionsButton(AppLocalizations texts) {
    return BlocSelector<FerniesBloc, FerniesState, bool>(
      selector: (state) => state.selectedRegionIds.isNotEmpty,
      builder: (context, hasSelection) => FernPillButton(
        label: texts.actionDeleteRegions,
        icon: Icons.crop_free,
        backgroundColor: context.colors.secondary,
        foregroundColor: context.colors.black,
        onPressed: hasSelection
            ? () => context
                .read<FerniesBloc>()
                .add(const DeleteSelectedRegionsEvent())
            : null,
      ),
    );
  }
}
