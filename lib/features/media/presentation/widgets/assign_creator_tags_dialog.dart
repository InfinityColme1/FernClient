import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Las etiquetas que un creador trae consigo.
///
/// A partir de aquí, ponerle este creador a un contenido se las pone también.
/// Es la otra mitad de las direcciones vinculadas: aquéllas dicen de dónde sale
/// lo suyo, éstas qué lleva puesto lo suyo.
///
/// **Devuelve la lista y no escribe nada.** Quien lo abre guarda, igual que con
/// las direcciones: cerrarlo sin confirmar no puede dejar al creador etiquetando
/// con algo que nadie llegó a aceptar.
///
/// No hace falta proponer aquí lo que cada etiqueta arrastra —su rama, sus
/// hermanas—: eso se resuelve al ponérselo al contenido, que es cuando importa,
/// y proponerlo aquí llenaría la lista del creador de etiquetas que ya vienen
/// solas.
class AssignCreatorTagsDialog extends StatefulWidget {
  /// Las que el creador tiene ahora.
  final List<TagEntity> tags;

  /// Cómo se llama, para que el panel diga de quién son estas etiquetas.
  final String name;

  const AssignCreatorTagsDialog({
    super.key,
    required this.tags,
    required this.name,
  });

  @override
  State<AssignCreatorTagsDialog> createState() =>
      _AssignCreatorTagsDialogState();
}

class _AssignCreatorTagsDialogState extends State<AssignCreatorTagsDialog> {
  final _searchTags = getIt<SearchTagsUseCase>();

  late final List<TagEntity> _tags = [...widget.tags];

  bool _isAlreadyAdded(TagEntity tag) => _tags.any((e) => e.id == tag.id);

  Future<List<TagEntity>> _search(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    // Las que ya están puestas no se sugieren: no se pueden añadir dos veces.
    final tags = result.data ?? const <TagEntity>[];

    return [
      for (final tag in tags)
        if (!_isAlreadyAdded(tag)) tag,
    ];
  }

  Widget _tagChip(TagEntity tag) => FernChip(
        label: tag.name,
        backgroundColor: context.colors.white,
        onRemove: () => setState(
          () => _tags.removeWhere((each) => each.id == tag.id),
        ),
        leading: FernAvatar(
          imagePath: tag.picturePath,
          fallbackIcon: Symbols.label,
          radius: AppSizes.avatarSmall,
          iconSize: AppSizes.iconCompact,
          backgroundColor: context.colors.secondary,
          iconColor: context.colors.primary,
        ),
        trailing: tag.isUnderNsfw ? const NsfwTagMark() : null,
      );

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    final chips = [for (final tag in _tags) _tagChip(tag)];

    return FernDialog(
      onClose: () => context.pop(),
      leftContent: FernDialogSidePanel.list(
        header: FernSectionHeader(
          icon: Symbols.label,
          title: widget.name,
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
          Text(
            texts.creatorTagsHint,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.l),
          FernEntitySearchField<TagEntity>(
            label: texts.tagNameSearchLabel,
            hintText: texts.tagSearchHint,
            search: _search,
            labelOf: (tag) => tag.name,
            // Se ponen varias seguidas y la elegida ya se ve como píldora en el
            // panel de la izquierda: dejarla escrita sólo obliga a borrarla a
            // mano antes de buscar la siguiente.
            clearOnSelected: true,
            // Las marcadas se distinguen al autocompletar: elegir una sin
            // saberlo es esconder contenido sin querer, y aquí de golpe todo lo
            // que se le ponga a este creador de aquí en adelante.
            trailingOf: (tag) => tag.isUnderNsfw ? const NsfwTagMark() : null,
            onSelected: (tag) => setState(() => _tags.add(tag)),
            debounce: searchDebounceDuration,
          ),
        ],
      ),
      actionButton: FernConfirmButton(
        onPressed: () => context.pop(List<TagEntity>.of(_tags)),
      ),
    );
  }
}
