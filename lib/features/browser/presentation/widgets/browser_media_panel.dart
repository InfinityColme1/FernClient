import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/browser/domain/entities/browser_media.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// El catálogo de lo que se ha encontrado en la página, colgando del botón que
/// lo buscó.
///
/// Cada fila es un contenido: se marca o se desmarca con su casilla y, al pasar
/// por encima, se señala en la página de al lado ([onHover]) para saber cuál es
/// sin tener que adivinarlo por el nombre del fichero.
///
/// Abajo, el botón que se trae lo marcado. Lo que no esté marcado no se toca:
/// una página cualquiera tiene mucho que no es contenido, y quien decide es el
/// usuario.
class BrowserMediaPanel extends StatelessWidget {
  final List<BrowserMedia> media;
  final Set<String> selected;

  /// Marca o desmarca un contenido. Llega la dirección porque es lo que lo
  /// identifica: no todo lo encontrado está en la página.
  final void Function(String url) onToggle;

  final VoidCallback onToggleAll;
  final VoidCallback onClose;
  final VoidCallback onImport;

  /// El ratón ha entrado o salido de una fila. `null` al salir.
  final void Function(BrowserMedia? media) onHover;

  /// Hay una descarga en marcha: mientras dure no se toca nada.
  final bool isBusy;

  const BrowserMediaPanel({
    super.key,
    required this.media,
    required this.selected,
    required this.onToggle,
    required this.onToggleAll,
    required this.onClose,
    required this.onImport,
    required this.onHover,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernSurface(
      radius: AppSizes.radiusSmall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.m,
              AppSpacing.s,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    texts.browserFound(media.length),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: texts.browserSelectAll,
                  onPressed: isBusy ? null : onToggleAll,
                  icon: Icon(
                    selected.length == media.length
                        ? Symbols.deselect
                        : Symbols.select_all,
                    size: AppSizes.iconMedium,
                  ),
                ),
                IconButton(
                  tooltip: texts.browserClose,
                  onPressed: onClose,
                  icon: const Icon(Symbols.close, size: AppSizes.iconMedium),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.m),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: media.length,
              itemBuilder: (context, index) => _row(context, media[index]),
            ),
          ),
          const Divider(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: FernPillButton(
              label: texts.browserImportAction(selected.length),
              icon: Symbols.download,
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.black,
              onPressed: isBusy || selected.isEmpty ? null : onImport,
            ),
          ),
        ],
      ),
    );
  }

  /// Una fila del catálogo: su casilla, qué es y cómo se llama.
  ///
  /// Lo que no se está viendo en la página (lo que la página declara de sí
  /// misma, o lo que tiene escondido) se marca aparte: se puede descargar, pero
  /// señalarlo no llevaría a ninguna parte.
  Widget _row(BuildContext context, BrowserMedia item) {
    final theme = Theme.of(context);
    final isSelected = selected.contains(item.url);

    return MouseRegion(
      onEnter: (_) => onHover(item),
      onExit: (_) => onHover(null),
      child: InkWell(
        onTap: isBusy ? null : () => onToggle(item.url),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: isBusy ? null : (_) => onToggle(item.url),
              ),
              Icon(
                item.mark == null
                    ? Symbols.sell
                    : Symbols.image,
                size: AppSizes.iconCompact,
                color: context.colors.gray,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                item.isVisible ? '${item.width}×${item.height}' : item.extension,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.colors.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
