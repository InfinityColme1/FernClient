import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_ancestors_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/tag_entity.dart';
import '../blocs/media_bloc.dart';
import '../blocs/media_events.dart';
import 'fern_create_dialog.dart';

/// Diálogo para asignar etiquetas al contenido.
///
/// A diferencia del de creadores, el panel izquierdo no muestra un avatar sino
/// la lista de etiquetas que va a llevar el contenido: las que ya tiene y las
/// que se van eligiendo, éstas en tono apagado. Nada de lo que se hace aquí
/// toca el contenido hasta pulsar "Confirm", y cualquiera de ellas se puede
/// quitar con su botón.
///
/// Al elegir una etiqueta se proponen también las que están por encima de ella
/// en la jerarquía, porque una etiqueta hija es un caso de su madre. Es una
/// propuesta y no una imposición: se quitan como cualquier otra, y quitar la
/// madre dejando la hija es una decisión del usuario que se respeta.
class AssignTagDialog extends StatefulWidget {
  final MediaEntity media;

  /// Etiquetas elegidas en el diálogo, con las del contenido dentro. Sirve para
  /// reabrirlo sin perder lo hecho, por ejemplo al volver de crear una
  /// etiqueta. Con `null` se arranca con las que tiene el contenido.
  final List<TagEntity>? selectedTags;

  const AssignTagDialog({
    super.key,
    required this.media,
    this.selectedTags,
  });

  @override
  State<AssignTagDialog> createState() => _AssignTagDialogState();
}

class _AssignTagDialogState extends State<AssignTagDialog> {
  final _searchTags = getIt<SearchTagsUseCase>();
  final _tagAncestors = getIt<GetTagAncestorsUseCase>();

  /// Las etiquetas que va a llevar el contenido al confirmar.
  late final List<TagEntity> _tags = [...(widget.selectedTags ?? _mediaTags)];

  /// Las que el contenido ya tenía al abrir el diálogo.
  List<TagEntity> get _mediaTags => widget.media.tags ?? const [];

  /// Una etiqueta está pendiente mientras no sea de las que el contenido ya
  /// tenía: es lo que la pinta en tono apagado.
  bool _isPending(TagEntity tag) => !_mediaTags.any((e) => e.id == tag.id);

  bool _isAlreadyAdded(TagEntity tag) => _tags.any((e) => e.id == tag.id);

  Future<List<TagEntity>> _search(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    // Las que ya están elegidas no se sugieren: no se pueden añadir dos veces.
    final tags = result.data ?? const <TagEntity>[];
    return tags.where((tag) => !_isAlreadyAdded(tag)).toList();
  }

  /// Elige una etiqueta y propone con ella las que estén por encima en la
  /// jerarquía: elegir "marinette" propone también "miraculous".
  Future<void> _addTag(TagEntity tag) async {
    setState(() => _tags.add(tag));

    final ancestors = await _missingAncestors([tag], _tags);
    if (!mounted || ancestors.isEmpty) return;

    setState(() => _tags.addAll(ancestors.where((e) => !_isAlreadyAdded(e))));
  }

  /// Quita una etiqueta de las elegidas, sea de las propuestas o de las que el
  /// contenido ya tenía. Al confirmar, la que se ha quitado se le quita.
  void _removeTag(TagEntity tag) {
    setState(() => _tags.removeWhere((e) => e.id == tag.id));
  }

  /// Las etiquetas por encima de [tags] que no estén ya en [current].
  Future<List<TagEntity>> _missingAncestors(
    List<TagEntity> tags,
    List<TagEntity> current,
  ) async {
    final result = await _tagAncestors(params: tags);
    if (result is! DataSuccess) return const [];

    final ids = {for (final tag in current) tag.id};
    return (result.data ?? const <TagEntity>[])
        .where((ancestor) => ids.add(ancestor.id))
        .toList();
  }

  /// Deja en el contenido las etiquetas elegidas, ni más ni menos.
  ///
  /// Se avisa aunque la lista se haya quedado vacía o sólo se hayan quitado
  /// etiquetas: quitar es un cambio igual que añadir.
  void _confirm(BuildContext context) {
    final unchanged = _tags.length == _mediaTags.length &&
        _tags.every((tag) => !_isPending(tag));

    if (!unchanged) {
      context.read<MediaBloc>().add(UpdateMediaInfoEvent(
            widget.media.copyWith(tags: List<TagEntity>.of(_tags)),
          ));
    }
    context.pop();
  }

  /// Cede el sitio al diálogo de creación y, al cerrarse éste, vuelve aquí: si
  /// se ha creado una etiqueta llega ya elegida (con las de encima propuestas),
  /// y lo que hubiera elegido antes no se pierde.
  Future<void> _openCreateTagDialog(BuildContext context) async {
    final bloc = context.read<MediaBloc>();
    final media = widget.media;
    final selected = List<TagEntity>.of(_tags);

    // Este diálogo desaparece al abrir el de creación, así que para volver hace
    // falta el contexto del navegador, que sigue en pie.
    final navigatorContext = Navigator.of(context).context;

    final created = await replaceFernDialog<TagEntity, MediaBloc>(
      context: context,
      bloc: bloc,
      builder: (_) => const FernCreateDialog.tag(),
    );

    // Las de encima se piden aquí y no al volver: este estado ya no existe, y
    // proponerlas otra vez sobre toda la lista devolvería las que se hubieran
    // quitado.
    if (created != null) {
      selected
        ..add(created)
        ..addAll(await _missingAncestors([created], selected));
    }

    if (!navigatorContext.mounted) return;

    showFernDialog(
      context: navigatorContext,
      bloc: bloc,
      builder: (_) => AssignTagDialog(media: media, selectedTags: selected),
    );
  }

  /// Píldora de etiqueta igual que la del panel de información, con el botón de
  /// quitarla; apagada mientras la etiqueta esté pendiente de confirmar.
  Widget _tagChip(TagEntity tag) {
    final isPending = _isPending(tag);

    return FernChip(
      label: tag.name,
      backgroundColor: isPending ? context.colors.background : context.colors.white,
      labelColor: isPending ? context.colors.unremarked : null,
      onRemove: () => _removeTag(tag),
      leading: FernAvatar(
        imagePath: tag.picturePath,
        fallbackIcon: Icons.label,
        radius: AppSizes.avatarSmall,
        iconSize: AppSizes.iconCompact,
        backgroundColor: isPending ? context.colors.lightgray : context.colors.secondary,
        iconColor: isPending ? context.colors.gray : context.colors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    final chips = [for (final tag in _tags) _tagChip(tag)];

    return FernDialog(
      onClose: () => context.pop(),
      leftContent: FernDialogSidePanel.list(
        header: FernSectionHeader(
          icon: Icons.label_outline,
          title: texts.tagsTitle,
        ),
        items: chips.isNotEmpty
            ? chips
            : [
                Text(
                  texts.noTagsYet,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.colors.gray),
                ),
              ],
      ),
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FernEntitySearchField<TagEntity>(
            label: texts.tagNameSearchLabel,
            hintText: texts.tagSearchHint,
            search: _search,
            labelOf: (tag) => tag.name,
            onSelected: _addTag,
            debounce: searchDebounceDuration,
          ),
          const SizedBox(height: AppSpacing.xl),
          FernAddButton(
            label: texts.createTag,
            onTap: () => _openCreateTagDialog(context),
          ),
        ],
      ),
      actionButton: FernConfirmButton(onPressed: () => _confirm(context)),
    );
  }
}
