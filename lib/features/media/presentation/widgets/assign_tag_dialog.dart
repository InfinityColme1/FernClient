import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
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
/// la lista de etiquetas del contenido; las que se van eligiendo se añaden a
/// esa lista en tono apagado y sólo se relacionan con el contenido al pulsar
/// "Confirm".
class AssignTagDialog extends StatefulWidget {
  final MediaEntity media;

  /// Etiquetas ya elegidas y sin confirmar. Sirve para reabrir el diálogo sin
  /// perder lo elegido, por ejemplo al volver de crear una etiqueta.
  final List<TagEntity> pendingTags;

  const AssignTagDialog({
    super.key,
    required this.media,
    this.pendingTags = const [],
  });

  @override
  State<AssignTagDialog> createState() => _AssignTagDialogState();
}

class _AssignTagDialogState extends State<AssignTagDialog> {
  final _searchTags = getIt<SearchTagsUseCase>();

  /// Etiquetas elegidas y todavía sin confirmar.
  late final List<TagEntity> _pendingTags = [...widget.pendingTags];

  List<TagEntity> get _assignedTags => widget.media.tags ?? const [];

  bool _isAlreadyAdded(TagEntity tag) =>
      _assignedTags.any((e) => e.id == tag.id) ||
      _pendingTags.any((e) => e.id == tag.id);

  Future<List<TagEntity>> _search(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    // Las que ya están en el contenido no se sugieren: no se pueden añadir dos
    // veces.
    final tags = result.data ?? const <TagEntity>[];
    return tags.where((tag) => !_isAlreadyAdded(tag)).toList();
  }

  void _confirm(BuildContext context) {
    if (_pendingTags.isNotEmpty) {
      context.read<MediaBloc>().add(UpdateMediaInfoEvent(
            widget.media.copyWith(tags: [..._assignedTags, ..._pendingTags]),
          ));
    }
    context.pop();
  }

  /// Cede el sitio al diálogo de creación y, al cerrarse éste, vuelve aquí: si
  /// se ha creado una etiqueta llega ya elegida, y las que hubiera elegidas
  /// antes no se pierden.
  Future<void> _openCreateTagDialog(BuildContext context) async {
    final bloc = context.read<MediaBloc>();
    final media = widget.media;
    final pending = List<TagEntity>.from(_pendingTags);

    // Este diálogo desaparece al abrir el de creación, así que para volver hace
    // falta el contexto del navegador, que sigue en pie.
    final navigatorContext = Navigator.of(context).context;

    final created = await replaceFernDialog<TagEntity, MediaBloc>(
      context: context,
      bloc: bloc,
      builder: (_) => const FernCreateDialog.tag(),
    );

    if (!navigatorContext.mounted) return;

    showFernDialog(
      context: navigatorContext,
      bloc: bloc,
      builder: (_) => AssignTagDialog(
        media: media,
        pendingTags: [...pending, ?created],
      ),
    );
  }

  /// Píldora de etiqueta igual que la del panel de información; apagada
  /// mientras la etiqueta esté pendiente de confirmar.
  Widget _tagChip(TagEntity tag, {required bool isPending}) {
    return FernChip(
      label: tag.name,
      backgroundColor: isPending ? AppColors.background : AppColors.white,
      labelColor: isPending ? AppColors.unremarked : null,
      leading: FernAvatar(
        imagePath: tag.picturePath,
        fallbackIcon: Icons.label,
        radius: AppSizes.avatarSmall,
        iconSize: AppSizes.iconCompact,
        backgroundColor: isPending ? AppColors.lightgray : AppColors.secondary,
        iconColor: isPending ? AppColors.gray : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    final chips = [
      for (final tag in _assignedTags) _tagChip(tag, isPending: false),
      for (final tag in _pendingTags) _tagChip(tag, isPending: true),
    ];

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
                      ?.copyWith(color: AppColors.gray),
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
            onSelected: (tag) => setState(() => _pendingTags.add(tag)),
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
