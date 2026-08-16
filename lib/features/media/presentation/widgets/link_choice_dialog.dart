import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Una publicación trae varios enlaces y hay que decidir qué se hace con ellos.
///
/// La importación está parada esperando esta respuesta, así que el diálogo dice
/// lo justo: de qué publicación viene, qué enlaces hay, y las tres cosas que se
/// pueden hacer. Cada enlace se puede abrir en el navegador de la aplicación
/// para ver qué es antes de decidir.
///
/// La casilla de abajo es la que evita tener que contestar cien veces: lo que
/// se responda vale para todo lo que quede de esta importación.
class LinkChoiceDialog extends StatefulWidget {
  final String postTitle;
  final List<PostLink> links;

  const LinkChoiceDialog({
    super.key,
    required this.postTitle,
    required this.links,
  });

  @override
  State<LinkChoiceDialog> createState() => _LinkChoiceDialogState();
}

class _LinkChoiceDialogState extends State<LinkChoiceDialog> {
  /// Lo marcado. De partida no hay nada: elegir es lo que distingue esta opción
  /// de traérselo todo, que ya tiene su propio botón.
  final _selected = <String>{};

  bool _applyToAll = false;

  void _answer(LinkChoice choice) => Navigator.of(context).pop(choice);

  /// Abre el enlace en el navegador de la aplicación para verlo.
  ///
  /// Cierra el diálogo con la respuesta más prudente: la importación no puede
  /// quedarse esperando mientras el usuario mira una página, y de esta
  /// publicación siempre se puede tirar después desde el navegador.
  void _open(PostLink link) {
    Navigator.of(context).pop(const LinkChoice.ignore());
    GoRouter.of(context).go(browserRouteWithUrl(link.url));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => _answer(const LinkChoice.ignore()),
      maxWidth: AppSizes.dialogMaxWidth,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.linkChoiceTitle(widget.links.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.postTitle.isEmpty
                ? texts.linkChoiceUntitledPost
                : widget.postTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.m),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.links.length,
              itemBuilder: (context, index) => _row(context, widget.links[index]),
            ),
          ),
          const Divider(height: AppSpacing.l),
          FernCheckboxTile(
            label: texts.linkChoiceApplyToAll,
            description: texts.linkChoiceApplyToAllDescription,
            value: _applyToAll,
            onChanged: (value) => setState(() => _applyToAll = value),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              FernPillButton(
                label: texts.linkChoiceIgnore,
                icon: Icons.block,
                backgroundColor: context.colors.secondary,
                foregroundColor: context.colors.black,
                onPressed: () => _answer(
                  LinkChoice.ignore(applyToAll: _applyToAll),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              FernPillButton(
                label: texts.linkChoiceSelection(_selected.length),
                icon: Icons.checklist,
                backgroundColor: context.colors.secondary,
                foregroundColor: context.colors.black,
                onPressed: _selected.isEmpty
                    ? null
                    : () => _answer(LinkChoice(
                          kind: LinkChoiceKind.selection,
                          selected: Set.of(_selected),
                          applyToAll: _applyToAll,
                        )),
              ),
              const SizedBox(width: AppSpacing.s),
              FernPillButton(
                label: texts.linkChoiceAll,
                icon: Icons.download_outlined,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.black,
                onPressed: () => _answer(LinkChoice(
                  kind: LinkChoiceKind.all,
                  applyToAll: _applyToAll,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Un enlace: su casilla, qué es, y el botón para ir a verlo.
  Widget _row(BuildContext context, PostLink link) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final isSelected = _selected.contains(link.url);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) => setState(() {
              isSelected ? _selected.remove(link.url) : _selected.add(link.url);
            }),
          ),
          Icon(
            link.kind == PostLinkKind.archive
                ? Icons.folder_zip_outlined
                : Icons.image_outlined,
            size: AppSizes.iconCompact,
            color: context.colors.gray,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              link.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: texts.linkChoiceOpen,
            onPressed: () => _open(link),
            icon: const Icon(Icons.open_in_new, size: AppSizes.iconCompact),
          ),
        ],
      ),
    );
  }
}
